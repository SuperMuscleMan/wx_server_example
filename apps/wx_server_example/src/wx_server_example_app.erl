%%%-------------------------------------------------------------------
%% @doc wx_server_example public API
%% @end
%%%-------------------------------------------------------------------

-module(wx_server_example_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    wx_server_example_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
