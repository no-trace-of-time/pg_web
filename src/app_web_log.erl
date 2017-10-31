%%%-------------------------------------------------------------------
%%% @author simonxu
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. Mar 2016 12:49
%%%-------------------------------------------------------------------
-module(app_web_log).
%-behaviour(cowboy_middleware).

-export([execute/2]).

execute(Req, Env) ->
  {Headers,Req1} = cowboy_req:headers(Req),
  {HostUrl,Req2} = cowboy_req:headers(Req1),
  {{Peer, _}, Req3} = cowboy_req:peer(Req2),
  {Method, Req4} = cowboy_req:method(Req3),
  {Path, Req5} = cowboy_req:path(Req4),
  {ForwardIps,Req6} = cowboy_req:header(<<"x-forwarded-for">>,Req5,""),
  {RealIp,Req7} = cowboy_req:header(<<"x-real-ip">>,Req6,""),
  %error_logger:info_msg("~p: [~p,~p,~p]: ~p ~p~n", [xfutils:now(), Peer, ForwardIps, RealIp, Method, Path]),
  lager:debug("[~s]: ~s ~ts", [RealIp, Method, Path]),
  %error_logger:info_msg("Headers = ~p~n", [Headers]),
  %error_logger:info_msg("HostUrl = ~p~n", [HostUrl]),
  {ok, Req7, Env}.

