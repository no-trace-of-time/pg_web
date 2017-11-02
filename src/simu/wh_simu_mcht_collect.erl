%%%-------------------------------------------------------------------
%%% @author simonxu
%%% @copyright (C) 2016, <COMPANY>
%%% @doc 商户模拟器发起订单支付交易
%%%
%%% @end
%%% Created : 20. Apr 2016 17:07
%%%-------------------------------------------------------------------
-module(wh_simu_mcht_collect).
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

%%  {ok, FrontUrl} = gws_simu_mcht:get_front_url(),
%%  {ok, BackUrl} = gws_simu_mcht:get_back_url(),
  FrontUrl = pg_web:get_config_url(simu_mcht_front_url),
  BackUrl = pg_web:get_config_url(simu_mcht_back_url),

  MchtOrderVals = [
    {actionUrl, pg_web:get_config_url(simu_mcht_collect_final_url)}
    , {tranAmt, "50"}
    , {orderDesc, <<"测试交易"/utf8>>}
%%    , {orderId, "001"}
    , {merchId, ""}
    , {tranId, binary_to_list(OrderId)}
    , {tranDate, binary_to_list(Date)}
    , {tranTime, binary_to_list(Time)}
    , {signature, ""}
    , {trustBackUrl, BackUrl}
  ],
  lager:debug("~n MchtOrderVals = ~p~n", [MchtOrderVals]),

  %% mcht order parameters passed to dtl
  {ok, Body} = mcht_collect_dtl:render(MchtOrderVals),
  {ok, Req3} = cowboy_req:reply(200, [{<<"content-type">>, <<"text/html">>}], Body, Req),
  {ok, Req3, State}.

terminate(_Reason, _Req, _State) ->
  ok.
