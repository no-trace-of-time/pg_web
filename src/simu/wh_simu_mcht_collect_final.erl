%%%-------------------------------------------------------------------
%%% @author simonxu
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. Apr 2016 17:14
%%%-------------------------------------------------------------------
-module(wh_simu_mcht_collect_final).
-author("simonxu").

%% API
-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

init(_, Req, []) ->
  {Reply, Req2} = xfutils:only_allow(post, Req),
  {Reply, Req2, no_state}.

handle(Req, State) ->
  %% get query string
  {ok, PostVals, Req2} = xfutils:post_get_qs(Req),
  Body = try
           lager:debug("PostVals = ~p", [PostVals]),

           {_, MerchId} = xfutils:ext_req(<<"merchId">>, PostVals),
           lager:debug("merchId = ~ts", [MerchId]),

           ModelMchtReqCollect = pg_protocol:out_2_in(pg_mcht_protocol_req_collect, PostVals),
           {SignString, Signature} = pg_mcht_protocol:sign(pg_mcht_protocol_req_collect, ModelMchtReqCollect),


           lager:debug("SignString = ~ts~n", [SignString]),

           Keys = [
             <<"tranAmt">>
             , <<"orderDesc">>
             , <<"tranId">>
             , <<"tranDate">>
             , <<"tranTime">>
             , <<"trustBackUrl">>
             , <<"bankCardNo">>
             , <<"certifType">>
             , <<"certifId">>
             , <<"certifName">>
             , <<"phoneNo">>
           ],

           MchtOrderVals = xfutils:ext_req(Keys, PostVals) ++
             [
               {actionUrl, pg_web:get_config_url(txn_collect_url)}
               , {merchId, MerchId}
               , {signString, SignString}
               , {signature, Signature}
             ],

           lager:debug("MchtOrderVals = ~p", [MchtOrderVals]),

           %% mcht order parameters passed to dtl
           {ok, BodyResult} = mcht_collect_final_dtl:render(MchtOrderVals),
           BodyResult

         catch
           _:X ->
             io_lib:format("Error = ~p<p>Stacktrace = ~ts<p>PostVals = ~p",
               [X,
                 lager:pr_stacktrace(erlang:get_stacktrace()),
                 PostVals
               ])
         end,
  {ok, Req3} = cowboy_req:reply(200, [{<<"content-type">>, <<"text/html">>}], Body, Req2),
  {ok, Req3, State}.

terminate(_Reason, _Req, _State) ->
  ok.
