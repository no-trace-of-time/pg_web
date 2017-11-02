%%%-------------------------------------------------------------------
%%% @author simonxu
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. Apr 2016 17:14
%%%-------------------------------------------------------------------
-module(wh_simu_mcht_collect_final).
-author("simonxu").

%% API
-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

%-import(utils_convert, [ext_req/2, b2i/1]).

%%-record(state, {}).

init(_, Req, []) ->
  {Reply, Req2} = xfutils:only_allow(post, Req),
  {Reply, Req2, no_state}.

handle(Req, State) ->
  %% get query string
  {ok, PostVals, Req2} = xfutils:post_get_qs(Req),
  lager:debug("PostVals = ~p", [PostVals]),

  {_, MerchId} = xfutils:ext_req(<<"merchId">>, PostVals),
  lager:debug("merchId = ~ts", [MerchId]),

  {SignString, Signature} =
    try
      ModelMchtReqCollect = pg_protocol:out_2_in(pg_mcht_protocol_req_collect, PostVals),
      {String, Sig} = pg_mcht_protocol:sign(pg_mcht_protocol_req_collect, ModelMchtReqCollect),


%%      {ok, MchtReq} = model_mcht_req_pay:new(PostVals),
%%      String = model_mcht_req_pay:sign_string(MchtReq),
      lager:debug("SignString = ~ts~n", [String]),
%%      Sig = gw_enc:sign_hex(binary_to_integer(MerchId), req, String),
      {String, Sig}
    catch
      throw :Reason ->
        lager:error("New pay req error!Reason = ~p", [Reason]),
        {<<"">>, <<"">>}
    end,

  Keys = [
    <<"tranAmt">>
    , <<"orderDesc">>
    , <<"tranId">>
    , <<"tranDate">>
    , <<"tranTime">>
%%    , <<"signature">>
    , <<"trustBackUrl">>
    , <<"bankCardNo">>
    , <<"certifType">>
    , <<"certifId">>
    , <<"certifName">>
    , <<"phoneNo">>
  ],

%%  {_, TranAmt} = xfutils:ext_req(<<"tranAmt">>, PostVals),
%%  {_, OrderDesc} = xfutils:ext_req(<<"orderDesc">>, PostVals),
%%  {_, OrderId} = xfutils:ext_req(<<"orderId">>, PostVals),
%%  {_, TranId} = xfutils:ext_req(<<"tranId">>, PostVals),
%%  {_, TranDate} = xfutils:ext_req(<<"tranDate">>, PostVals),
%%  {_, TranTime} = xfutils:ext_req(<<"tranTime">>, PostVals),
%{_,Signature} = xfutils:ext_req(<<"signature">>, PostVals),
%%  {_, TrustBackUrl} = xfutils:ext_req(<<"trustBackUrl">>, PostVals),
%%  {_, BankCardNo} = xfutils:ext_req(<<"bankCardNo">>, PostVals),
%%  {_, CertifType} = xfutils:ext_req(<<"certifType">>, PostVals),
%%  {_, CertifId} = xfutils:ext_req(<<"certifId">>, PostVals),
%%  {_, CertifName} = xfutils:ext_req(<<"certfName">>, PostVals),
%%  {_, PhoneNo} = xfutils:ext_req(<<"phoneNo">>, PostVals),

  MchtOrderVals = xfutils:ext_req(Keys, PostVals) ++
    [
      {actionUrl, pg_web:get_config_url(txn_collect_url)}
      , {merchId, MerchId}
      , {signString, SignString}
      , {signature, Signature}
    ],

%%    , {tranAmt, TranAmt}
%%    , {orderDesc, OrderDesc}
%%    , {orderId, OrderId}
%%    , {merchId, MerchId}
%%    , {tranId, TranId}
%%    , {tranDate, TranDate}
%%    , {tranTime, TranTime}
%%    , {signature, Signature}
%%    , {trustBackUrl, TrustBackUrl}
%%    , {signString, SignString}
%%    , {bankCardNo, BankCardNo}
%%    , {certifType, CertifType}
%%    , {certifId, CertifId}
%%    , {certifName, CertifName}
%%    , {phoneNo, PhoneNo}
%%  ],
  lager:debug("MchtOrderVals = ~p", [MchtOrderVals]),

%% mcht order parameters passed to dtl
  {ok, Body} = mcht_collect_final_dtl:render(MchtOrderVals),
  {ok, Req3} = cowboy_req:reply(200, [{<<"content-type">>, <<"text/html">>}], Body, Req2),
  {ok, Req3, State}.

terminate(_Reason, _Req, _State) ->
  ok.
