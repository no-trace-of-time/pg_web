%%%-------------------------------------------------------------------
%%% @author simonxu
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. Apr 2016 11:36
%%%-------------------------------------------------------------------
-module(wh_simu_mcht_query_final).
-author("simonxu").

%% API
-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

%-import(utils_convert, [ext_req/2, b2i/1]).

%%-record(state, {}).

init(_, Req, []) ->
  {Reply, Req2} = xfutils:only_allow(post, Req),
  {Reply, Req2, no_state}.

handle(Req, State) ->
  %% get query string
  {ok, PostVals, Req2} = xfutils:post_get_qs(Req),
  Body = try
           lager:debug("PostVals = ~p~n", [PostVals]),

           {_, MerchId} = xfutils:ext_req(<<"merchId">>, PostVals),
           lager:debug("merchId = ~ts", [MerchId]),

           ModelMchtReqQuery = pg_protocol:out_2_in(pg_mcht_protocol_req_query, PostVals),
           lager:debug("ModelMchtReqQuery = ~ts", [pg_model:pr(pg_mcht_protocol_req_query, ModelMchtReqQuery)]),
           {SignString, Signature} = pg_mcht_protocol:sign(pg_mcht_protocol_req_query, ModelMchtReqQuery),


           lager:debug("SignString = ~ts~n", [SignString]),

           Keys = [
             <<"tranId">>
             , <<"tranDate">>
             , <<"tranTime">>
           ],

           MchtQueryVals = xfutils:ext_req(Keys, PostVals) ++
             [
               {actionUrl, pg_web:get_config_url(txn_query_url)}
               , {merchId, MerchId}
               , {signString, SignString}
               , {signature, Signature}
             ],

           lager:debug("MchtQueryVals = ~p", [MchtQueryVals]),

           %% mcht order parameters passed to dtl
           {ok, BodyResult} = mcht_query_final_dtl:render(MchtQueryVals),
           BodyResult
         catch
           _:X ->
             io_lib:format("Error = ~p<p>Stacktrace = ~ts<p>PostVals = ~p",
               [X,
                 lager:pr_stacktrace(erlang:get_stacktrace()),
                 PostVals
               ])
         end,

  %% mcht order parameters passed to dtl
  {ok, Req3} = cowboy_req:reply(200, [{<<"content-type">>, <<"text/html">>}], Body, Req2),
  {ok, Req3, State}.

terminate(_Reason, _Req, _State) ->
  ok.