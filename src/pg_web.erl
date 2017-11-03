%%%-------------------------------------------------------------------
%%% @author simon
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 31. 十月 2017 22:14
%%%-------------------------------------------------------------------
-module(pg_web).
-include_lib("eunit/include/eunit.hrl").
-author("simon").

%% API
-export([
  start/0
  , stop/0
  , get_prefix/0
  , get_config_url/1
]).

-export([
  get_config_url_test_1/0
]).

-define(APP, pg_web).

start() ->
  application:start(?APP).

stop() ->
  application:stop(?APP).


get_prefix() ->
  {ok, Prefix} = application:get_env(?APP, web_app_prefix),
  Prefix.

get_config_url(Env) when is_atom(Env) ->
  list_to_binary(xfutils:get_filename(?APP, [web_app_hostname, web_app_prefix, Env])).

get_config_url_test_1() ->
  ?assertEqual(<<"http://localhost:8888/pg/simu_mcht_front_succ">>,
    get_config_url(simu_mcht_front_url)),
  ?assertEqual(<<"http://localhost:8888/pg/simu_mcht_collect_final">>,
    pg_web:get_config_url(simu_mcht_collect_final_url)),
  ok.

