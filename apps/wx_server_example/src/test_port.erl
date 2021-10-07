%%%-------------------------------------------------------------------
%%% @author WeiMengHuan
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. 三月 2021 11:47
%%%-------------------------------------------------------------------
-module(test_port).
%%%=======================STATEMENT====================
-description("test_port").
-copyright('').
-author("wmh, SuperMuscleMan@outlook.com").
%%%=======================EXPORT=======================
-export([add/2, create_role/2, transfer/3, get_money/1,
	test_event/1]).
%%%=======================INCLUDE======================
-include_lib("wx_log_library/include/wx_log.hrl").

%%-include("pb_GameProto.hrl").
%%%=======================RECORD=======================

%%%=======================DEFINE=======================
%%%=================EXPORTED FUNCTIONS=================
%% 测试事件
test_event(Num)->
	wx_event_server:throw_event("gameserver", test_e, Num).
%% 创建角色
create_role(RoleId, Money) ->
	TabUser = 'wx_server_example/user',
	wx_db_lib:update(?MODULE, fun create_role_/2, TabUser, RoleId, {user, 0}, Money).
create_role_(Money, {user, _}) ->
	{ok, ok, {user, Money}}.

%%  模拟两人相互转账
transfer(FromId, ToId, Money) ->
	TabUser = 'wx_server_example/user',
	TabKeys = [{TabUser, FromId, {user, 0}}, {TabUser, ToId, {user, 0}}],
	wx_db_lib:transaction(?MODULE, fun transfer_/2, TabKeys, Money).
transfer_(Money, [{Index1, {user, FromMoney}}, {Index2, {user, ToMoney}}]) ->
	FromMoney1 = FromMoney - Money,
	ToMoney1 = ToMoney + Money,
	{ok, ok, [{Index1, {user, FromMoney1}}, {Index2, {user, ToMoney1}}]}.

%% 获取余额
get_money(Id) ->
	TabUser = 'wx_server_example/user',
	{user, Money} = wx_db_lib:get(TabUser, Id),
	Money.
%% -----------------------------------------------------------------
%% Func:
%% Description:添加
%% Returns:
%% -----------------------------------------------------------------
add(RoleId, Num) ->
	TabUser = 'wx_server_example/user',
	TabVip = 'wx_server_example/vip',
	TabKeys = [{TabUser, RoleId, {user, 0}}, {TabVip, RoleId, {vip, 0}}],
	wx_db_lib:transaction(?MODULE, fun add_/2, TabKeys, Num).
add_(Num, [{Index1, {user, Account}}, {Index2, {vip, _Vip}}]) ->
	Account1 = Account + Num,
	Vip1 = Account div 10,
	{ok, ok, [{Index1, {user, Account1}}, {Index2, {vip, Vip1}}]}.


%% -----------------------------------------------------------------
%% Func: 
%% Description: 
%% Returns: 
%% -----------------------------------------------------------------
%%test_msg(Src,Attr,  A) ->
%%	?SOUT([Src, Attr,A]),
%%	Msg =
%%		#'pb_S2CTestMsg'{names = ["wmh", "wmh2", "wmh3"], ids = [1, 2, 3], equips = [
%%			#'pb_items'{itemName = "xixihaha", id = 999, people = [
%%				#'pb_Person'{config = 1},
%%				#'pb_Person'{config = 2},
%%				#'pb_Person'{config = 3}
%%			]}
%%		]},
%%	{reply, Msg}.
%==========================DEFINE=======================