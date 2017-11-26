%%%-------------------------------------------------------------------
%%% @author simon
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. 十一月 2017 8:56
%%%-------------------------------------------------------------------
-module(wh_txn_mcht_req_collect).
-author("simon").

%% API
-export([
  init/3
  , handle/2
  , terminate/3
]).

%%---------------------------------------------------------------------
init(_, Req, _Opts) ->
  {Reply, Req2} = xfutils:only_allow(post, Req),
  {Reply, Req2, no_state}.

terminate(_Reason, _Req, _State) ->
  ok.

handle(Req, State) ->
  {ok, PV, Req2} = xfutils:post_get_qs(Req),

  lager:debug("in /collect request qs = ~p", [PV]),

  Body = try
           pg_txn:handle(mcht_txn_req_collect, PV)
         catch
           _:X ->
             io_lib:format("Error = ~p<p>Stacktrace = ~p<p>PostVals = ~p",
               [X,
                 list_to_binary(lager:pr_stacktrace(erlang:get_stacktrace())),
                 PV
               ])
         end,

  lager:debug("Return Body = ~p", [Body]),
  {ok, Req3} = cowboy_req:reply(200, [{<<"content-type">>, <<"text/html;charset=UTF-8">>}], Body, Req2),
  {ok, Req3, State}.
