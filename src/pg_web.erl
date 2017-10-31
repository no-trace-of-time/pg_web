%%%-------------------------------------------------------------------
%%% @author simon
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 31. 十月 2017 22:14
%%%-------------------------------------------------------------------
-module(pg_web).
-author("simon").

%% API
-export([
  start/0
  , stop/0
]).


start() ->
  application:start(pg_web).

stop() ->
  application:stop(pg_web).


