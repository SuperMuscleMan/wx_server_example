%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%% db层并发测试 - 银行转账交易
%%% 运行方式：ct:run_test([{dir, "../lib/wx_server_example-0.1.0/src"}, {logdir, "../.sys_log"}]).
%%% 因为需要整个框架的运行，使用rebar3 ct启动时，项目启动路径问题没解决，所以没有使用rebar3 ct
%%% @end
%%% Created : 31. 十月 2020 14:27
%%%-------------------------------------------------------------------
-module(db_SUITE).
-author("Administrator").

%%-compile(export_all).

-export([all/0, init_per_suite/1, init_per_testcase/2, end_per_suite/1, end_per_testcase/2
	, suite/0
]).
-export([create_user/1, groups/0, transfer/1, get_total_money/0]).

-include_lib("common_test/include/ct.hrl").

all() ->
	%% 10组（并发执行） * 20实例（并发执行） * 1000交易（并发执行） = 20w次转账交易
	[create_user, {group, transfer_groups_repeat}].

%% 20w次转账交易-执行结果
%% 耗时：11.719s
%% 机器配置：
%% 		CPU Intel(R) Core(TM) i7-7700HQ CPU @ 2.80GHz
%% 		MEM 8.0 GB 2400 MHz
%%		Disk WDC WD10SPZX-22Z10T0
%% 资源占用峰值：
%%		CPU	70%
%%		MEM 190MB

groups() ->
	[
		%% 同时执行10个组
		{transfer_groups_repeat, [parallel],
			[
				{group, transfer_groups}, {group, transfer_groups}, {group, transfer_groups}, {group, transfer_groups},
				{group, transfer_groups}, {group, transfer_groups}, {group, transfer_groups}, {group, transfer_groups},
				{group, transfer_groups}, {group, transfer_groups}
			]
		},
		%% 一个组同时开启20个实例
		{transfer_groups, [parallel],
			[
				transfer, transfer, transfer, transfer, transfer, transfer, transfer, transfer, transfer, transfer,
				transfer, transfer, transfer, transfer, transfer, transfer, transfer, transfer, transfer, transfer
			]}
	].
suite() ->
	ok = application:ensure_started(sasl),
	ok = application:ensure_started(wx_cfg_library),
	ok = application:ensure_started(wx_db_library),
	ok = application:ensure_started(wx_event_library),
	ok = application:ensure_started(wx_log_library),
	ok = application:ensure_started(wx_net_library),
	ok = application:ensure_started(wx_timer_library),
	ok = application:ensure_started(wx_overman),
	ok = application:ensure_started(wx_server_example),
	[].
%%	 套件初始化。
init_per_suite(Config) ->
	[
		{role_num, 10000},        %% 1w 用户
		{money, 100}    %% 每人金额：100元
		| Config
	].
end_per_suite(_Config) ->
%%	套件执行结束
	ok.
init_per_testcase(_, Config) ->
%%	测试用例执行前
	Config.

end_per_testcase(_, _Config) ->
%%	测试用例执行后
	ok.


%%========================== 银行转账交易-测试用例 ===========================
%% 创建角色
create_user(Config) ->
	List = lists:seq(1, ?config(role_num, Config)),
	Money = ?config(money, Config),
	[test_port:create_role(E1, Money) || E1 <- List].

%% 随机相互转账
transfer(Config) ->
	Parent = self(),
	RoleNum = ?config(role_num, Config),
	List = lists:seq(1, RoleNum),
	Threshold = 1000,%% 单实例并发1000
	Left = wx_lib:rand(1, RoleNum - Threshold),
	RoleList1 = lists:sublist(List, Left, Threshold),
	[receive {Parent, Result} -> Result after 500 -> err end
		|| _ <-
		[erlang:spawn(fun() -> Parent ! {Parent, transfer_per(E, RoleNum)} end)
			|| E <- RoleList1]].
transfer_per(FromId, RoleNum) ->
	case rand:uniform(RoleNum) of
		FromId ->
			transfer_per(FromId, RoleNum);
		ToId ->
			transfer_(FromId, ToId)
	end.
transfer_(FromId, ToId) ->
	Money = test_port:get_money(FromId),
	case Money > 0 of
		false ->
			false;
		_ ->
			Money1 = rand:uniform(max((Money rem 59), 1)),
			ok = test_port:transfer(FromId, ToId, Money1)
	end.

%% 获取所有用户的金额总和
get_total_money() ->
	lists:sum([E || {_, {_, E}} <- ets:tab2list(wx_db_lib:get_table_name([{tab_src, 'wx_server_example.table'}], user))]).