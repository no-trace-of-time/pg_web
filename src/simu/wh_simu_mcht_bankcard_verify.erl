%%%-------------------------------------------------------------------
%%% @author simonxu
%%% @copyright (C) 2016, <COMPANY>
%%% @doc 商户模拟器发起订单支付交易
%%%
%%% @end
%%% Created : 20. Apr 2016 17:07
%%%-------------------------------------------------------------------
-module(wh_simu_mcht_bankcard_verify).
-author("simonxu").

%% API
-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

%%-record(state, {}).

-define(APP, pg_web).

init(_, Req, []) ->
  {Reply, Req2} = xfutils:only_allow(get, Req),
  {Reply, Req2, no_state}.

handle(Req, State) ->
  OrderId = xfutils:get_new_order_id(),
  <<Date:8/bytes, Time:6/bytes, _/binary>> = OrderId,

  %% get query string
  {ok, PostVals, Req2} = xfutils:post_get_qs(Req),


  MchtOrderVals = [
    {actionUrl, pg_web:get_config_url(simu_mcht_bankcard_verify_final_url)}
    , {tranId, binary_to_list(OrderId)}
    , {tranDate, binary_to_list(Date)}
    , {tranTime, binary_to_list(Time)}
  ],
  lager:debug("~n MchtOrderVals = ~p~n", [MchtOrderVals]),

  %% mcht order parameters passed to dtl
  {ok, Body} = mcht_bankcard_verify_dtl:render(MchtOrderVals),
  {ok, Req3} = cowboy_req:reply(200, [{<<"content-type">>, <<"text/html">>}], Body, Req2),
  {ok, Req3, State}.

terminate(_Reason, _Req, _State) ->
  ok.
