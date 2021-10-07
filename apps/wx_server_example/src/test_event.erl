%%%-------------------------------------------------------------------
%%% @author WeiMengHuan
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. 三月 2021 18:03
%%%-------------------------------------------------------------------
-module(test_event).
%%%=======================STATEMENT====================
-description("test_event").
-copyright('').
-author("wmh, SuperMuscleMan@outlook.com").
%%%=======================EXPORT=======================
-export([test/4]).
%%%=======================INCLUDE======================
-include_lib("wx_log_library/include/wx_log.hrl").

%%%=======================RECORD=======================

%%%=======================DEFINE=======================

%%%=================EXPORTED FUNCTIONS=================
test(FA, Src, Event, Num) ->
	?DEBUG({FA, Src, Event, Num, process_info(self())}),
	timer:sleep(Num),
	io:format("[~p] [~p] | FA, Num:~p~n", [?MODULE, ?LINE, {FA, Num}]).
%% -----------------------------------------------------------------
%% Func: 
%% Description: 
%% Returns: 
%% -----------------------------------------------------------------
%==========================DEFINE=======================