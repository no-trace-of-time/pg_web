%%%-------------------------------------------------------------------
%%% @author simon
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 31. 十月 2017 22:25
%%%-------------------------------------------------------------------
-module(pg_web_cowboy).
-include_lib("eunit/include/eunit.hrl").
-author("simon").

-behaviour(gen_server).

%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

-export([
  add_prefix_test_1/0
]).

-define(SERVER, ?MODULE).
-define(APP, pg_web).
-define(DEFAULT_PORT, 8888).
-define(DEFAULT_ACCEPOTORS, 100).

-record(state, {}).

%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @end
%%--------------------------------------------------------------------
-spec(start_link() ->
  {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------
-spec(init(Args :: term()) ->
  {ok, State :: #state{}} | {ok, State :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term()} | ignore).
init([]) ->
  {ok, #state{}, 0}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_call(Request :: term(), From :: {pid(), Tag :: term()},
    State :: #state{}) ->
  {reply, Reply :: term(), NewState :: #state{}} |
  {reply, Reply :: term(), NewState :: #state{}, timeout() | hibernate} |
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), Reply :: term(), NewState :: #state{}} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_call(_Request, _From, State) ->
  {reply, ok, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_cast(Request :: term(), State :: #state{}) ->
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_cast(_Request, State) ->
  {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
-spec(handle_info(Info :: timeout() | term(), State :: #state{}) ->
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_info(timeout, State) ->

  wait_for(),

  Routes = routes(),
  ?debugFmt("Routes = ~p", [Routes]),
  Dispatch = cowboy_router:compile(Routes),
  Port = port(),
  Ip = bind_ip(),
  Acceptors = acceptors(),
  TransOpts = [{ip, Ip}, {port, Port}],
  ProtoOpts = [{env, [{dispatch, Dispatch}]}
    , {middlewares, [cowboy_router, app_web_log, cowboy_handler]}],
  %%{ok, _} =
  CowBoyStarted = cowboy:start_http(http, Acceptors, TransOpts, ProtoOpts),
  case CowBoyStarted of
    {ok, _} ->
      ok;
    {already_started, _} ->
      ok;
    {Code, Reason} ->
      lager:error("cowboy started error!Code = ~p,Reason = ~p", [Code, Reason])
  end,
  {noreply, State};
handle_info(_Info, State) ->
  {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
-spec(terminate(Reason :: (normal | shutdown | {shutdown, term()} | term()),
    State :: #state{}) -> term()).
terminate(_Reason, _State) ->
  ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
-spec(code_change(OldVsn :: term() | {down, term()}, State :: #state{},
    Extra :: term()) ->
  {ok, NewState :: #state{}} | {error, Reason :: term()}).
code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
wait_for() ->
  case application:get_env(?APP, waiting_for_func) of
    undefined ->
      %% start at once
      ok;
    {ok, {M, F, Args}} when is_atom(M), is_atom(F), is_list(Args) ->
      lager:info("Waiting for ....", []),
      apply(M, F, Args),
      lager:info("Waiting for ...done", []),
      ok
  end.

%%------------------------------------------------
add_prefix_to_url(Url) ->
  <<"/", (list_to_binary(xfutils:get_filename(?APP, [web_app_prefix, Url])))/binary>>.




add_prefix(Routes) when is_list(Routes) ->
  [{add_prefix_to_url(Url), Method, Options} || {Url, Method, Options} <- Routes].

add_prefix_test_1() ->
  ?assertEqual([{<<"/pg//">>, cowboy_static, aaa}],
    add_prefix([{<<"/">>, cowboy_static, aaa}])),

  ?assertEqual(<<"/pg/simu_mcht_collect">>, add_prefix_to_url(simu_mcht_collect_url)),

  ok.

%%------------------------------------------------
routes() ->
  {ok, Routes} = application:get_env(?APP, routes),
  RoutesAddPrefix = add_prefix(Routes),
  RoutesResult = [
    {'_', RoutesAddPrefix}
  ],
  RoutesResult.


%%------------------------------------------------
port() ->
  application:get_env(?APP, http_port, ?DEFAULT_PORT).
%%------------------------------------------------
bind_ip() ->
  application:get_env(?APP, http_bind_ip, ?DEFAULT_PORT).
%%------------------------------------------------
acceptors() ->
  application:get_env(?APP, http_acceptors, ?DEFAULT_ACCEPOTORS).
