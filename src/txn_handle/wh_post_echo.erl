%%%-------------------------------------------------------------------
%%% @author simonxu
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. Mar 2016 12:05
%%%-------------------------------------------------------------------
-module(wh_post_echo).
%-behaviour(cowboy_http_handler).

%% API
-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

%%-record(state, {}).

init(_, Req, []) ->
  {Reply,Req2} = xfutils:only_allow(post,Req),
  {Reply,Req2,no_state}.

handle(Req, State) ->
  {ok,PostVals,Req2} = xfutils:post_get_qs(Req),
  {ok, Body} = post_qs_list_dtl:render([{qs,PostVals}|PostVals]),
  {ok, Req3} = cowboy_req:reply(200, [{<<"content-type">>, <<"text/html">>}], Body, Req2),
  {ok, Req3, State}.

terminate(_Reason, _Req, _State) ->
  ok.
