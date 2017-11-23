%%%-------------------------------------------------------------------
%%% @author simonxu
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. Apr 2016 11:22
%%%-------------------------------------------------------------------
-module(wh_simu_mcht_query).
-author("simonxu").

%% API
-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

%%-record(state, {}).

init(_, Req, []) ->
  {Reply, Req2} = xfutils:only_allow(get, Req),
  {Reply, Req2, no_state}.

handle(Req, State) ->
  OrderId = xfutils:get_new_order_id(),
  <<Date:8/bytes, Time:6/bytes, _/binary>> = OrderId,

  %% get query string
  {ok, PostVals, Req2} = xfutils:post_get_qs(Req),


  MchtQueryVals = [
    {actionUrl, pg_web:get_config_url(simu_mcht_query_final_url)}
    , {merchId, ""}
    , {tranId, binary_to_list(OrderId)}
    , {tranDate, binary_to_list(Date)}
    , {tranTime, binary_to_list(Time)}
  ],
  lager:debug("~n MchtQueryVals = ~p~n", [MchtQueryVals]),

  %% mcht order parameters passed to dtl
  {ok, Body} = mcht_query_dtl:render(MchtQueryVals),
  {ok, Req3} = cowboy_req:reply(200, [{<<"content-type">>, <<"text/html">>}], Body, Req2),
  {ok, Req3, State}.

terminate(_Reason, _Req, _State) ->
  ok.