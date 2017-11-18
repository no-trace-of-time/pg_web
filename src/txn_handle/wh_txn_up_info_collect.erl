%%%-------------------------------------------------------------------
%%% @author simonxu
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. Apr 2016 17:21
%%%-------------------------------------------------------------------
-module(wh_txn_up_info_collect).
-author("simonxu").

%% API
-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

init(_, Req, []) ->
  {Reply, Req2} = xfutils:only_allow(post, Req),
  {Reply, Req2, no_state}.

terminate(_Reason, _Req, _State) ->
  ok.

handle(Req, State) ->

  %% get query string
  {ok, PV, Req2} = xfutils:post_get_qs(Req),
  lager:debug("in /info_collect,PostVals = ~p", [PV]),

  Body = try
           pg_txn:handle(up_txn_info_collect, PV)
         catch
           _:X ->
             io_lib:format("Error = ~p<p>Stacktrace = ~p<p>PostVals = ~p",
               [X,
                 lager:pr_stacktrace(erlang:get_stacktrace()),
                 PV
               ])
         end,

  {ok, Req3} = cowboy_req:reply(200, [{<<"content-type">>, <<"text/html">>}], Body, Req2),

  {ok, Req3, State}.

