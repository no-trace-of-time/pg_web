%%%-------------------------------------------------------------------
%%% @author simon
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 31. 十月 2017 10:32
%%%-------------------------------------------------------------------
-module(pg_web_SUITE).
-include_lib("eunit/include/eunit.hrl").
-author("simon").

%% API
-export([]).

setup() ->
  env_init(),
  ok.

env_init() ->
  Envs = [
    {pg_web,
      [
        {web_app_prefix, <<"pg">>}
        , {web_app_hostname, <<"http://localhost:8888">>}
        , {http_port, 8888}
        , {http_acceptors, 100}

        , {simu_mcht_front_url, <<"simu_mcht_front_succ">>}
        , {simu_mcht_back_url, <<"simu_mcht_back_succ_info">>}
        , {simu_mcht_collect_final_url, <<"simu_mcht_collect_final">>}
        , {simu_mcht_collect_url, <<"simu_mcht_collect">>}

        , {txn_collect_url, <<"collect">>}

      ]}
  ],
  pg_test_utils:env_init(Envs).



my_test_() ->
  {
    setup,
    fun setup/0,
    {
      inorder,
      [
        fun pg_web:get_config_url_test_1/0
        , fun pg_web_cowboy:add_prefix_test_1/0
      ]
    }
  }.
