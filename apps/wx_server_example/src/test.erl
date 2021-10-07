%%%-------------------------------------------------------------------
%%% @author WeiMengHuan
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. 二月 2021 0:14
%%%-------------------------------------------------------------------
-module(test).
%%%=======================STATEMENT====================
-description("test").
-copyright('').
-author("wmh, SuperMuscleMan@outlook.com").
-vsn(1).
%%%=======================EXPORT=======================
-export([test_rand/3, time_out/4, append/1]).
%%%=======================INCLUDE======================
-include_lib("wx_log_library/include/wx_log.hrl").
%%%=======================RECORD=======================

%%%=======================DEFINE=======================

-define(COUNTS, {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}).
%%%=================EXPORTED FUNCTIONS=================

% 测试字符串拼接时间
append(Num) ->
	Ets = ets:new(a, [named_table, {read_concurrency, true}]),
	erlang:statistics(wall_clock),
	Bytes = append_init_rand_bytes(Num, []),
	{_, Use1} = erlang:statistics(wall_clock),
	Ints = append_init_bytes_to_int(Bytes, []),
	{_, Use2} = erlang:statistics(wall_clock),
	Strs = append_init_int_to_str(Ints, []),
	{_, Use3} = erlang:statistics(wall_clock),
	append_ets(Strs, Ets),
	{_, Use4} = erlang:statistics(wall_clock),
	append_ets_get(Strs, Ets),
	{_, Use5} = erlang:statistics(wall_clock),
	Strs2 = append_(Strs, []),
	{_, Use6} = erlang:statistics(wall_clock),
	append_atom(Strs2, []),
	{_, Use7} = erlang:statistics(wall_clock),
	ets:delete(Ets),
	[{rand_bytes, Use1},
		{to_int, Use2},
		{to_str, Use3},
		{ets_set, Use4},
		{ets_get, Use5},
		{append_str, Use6},
		{to_atom, Use7}].
append_ets([{K, V}|T], Ets)->
	ets:insert(Ets, {K, V}),
	append_ets(T, Ets);
append_ets([], _)->
	ok.
append_ets_get([{K, _}|T], Ets)->
	ets:lookup(Ets, K),
	append_ets_get(T, Ets);
append_ets_get([], _)->
	ok.
append_init_rand_bytes(0, R) ->
	R;
append_init_rand_bytes(Num, R) ->
	Bytes = crypto:strong_rand_bytes(48),
	append_init_rand_bytes(Num - 1, [Bytes | R]).

append_init_bytes_to_int([H | T], R) ->
	BitSize = bit_size(H) div 2,
	<<Left:BitSize, Right:BitSize>> = H,
	append_init_bytes_to_int(T, [{Left, Right} | R]);
append_init_bytes_to_int([], R) ->
	R.

append_init_int_to_str([{Left, Right}|T], R)->
	Left1 = integer_to_list(Left, 16),
	Right1 = integer_to_list(Right, 16),
	append_init_int_to_str(T, [{Left1, Right1}|R]);
append_init_int_to_str([], R)->
	R.

append_([{H1, H2}|T], R)->
	append_(T, [H1++H2|R]);
append_([], R)->
	R.

append_atom([H|T], R)->
	append_atom(T, [list_to_atom(H)|R]);
append_atom([], R)->
	R.

%验证随机算法
test_rand(N1, N2, Num) ->
	test_rand_(N1, N2, Num, []).
test_rand_(N1, N2, Num, Result) when Num > 0 ->
	R = wx_lib:rand(N1, N2),
	RNum = proplists:get_value(R, Result, 0) + 1,
	Result1 = lists:keystore(R, 1, Result, {R, RNum}),
	test_rand_(N1, N2, Num - 1, Result1);
test_rand_(_, _, _, Result) ->
	Result.



% 计算去除一半条目所对应的超时时间
time_out(TimeRange, Size, I, C) when I > 0, Size > C ->
	time_out(TimeRange, Size, I - 1, C + element(I, TimeRange));
time_out(TimeRange, Size, I, C) when I > 0 ->
	T1 = 1 bsl (I - 1),
	?SOUT({I, T1, C, Size}),
	T1 + (T1 * (C - Size) div (element(I, TimeRange) + 1));
time_out(_TimeRange, _Size, _I, _C) ->
	0.
%==========================DEFINE=======================