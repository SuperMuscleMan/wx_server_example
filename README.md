wx_server_example
=====
wx Server服务器框架示例


## 简介 ##
这是个通过rebar3 创建的一个release项目，将底层的基础模块进行了解耦分离，通过rebar.config的deps配置项进行引用。

### 已开发的模块如下： ###
- [wx\_cfg_library](https://github.com/SuperMuscleMan/wx_cfg_library) :配置模块
- [wx\_db_library](https://github.com/SuperMuscleMan/wx_db_library) :数据层模块
- [wx\_event_library](https://github.com/SuperMuscleMan/wx_event_library) :事件管理模块
- [wx\_log_library](https://github.com/SuperMuscleMan/wx_log_library) :日志层模块
- [wx\_net_library](https://github.com/SuperMuscleMan/wx_net_library) :网络层模块
- [wx\_overman](https://github.com/SuperMuscleMan/wx_overman) :底层启动入口模块
- [wx\_tiemr_library](https://github.com/SuperMuscleMan/wx_timer_library) :定时器模块

### 特点 ###
1.	高效且带事务锁的数据库，可多表项同时操作，实现了一致性。事务锁是通过自己封装ets实现的。持久化是使用DETS实现。（银行交易转账测试中，20w次，耗时11.7s，见[wx_server_example项目的/src/db_SUITE.erl模块](https://github.com/SuperMuscleMan/wx_server_example/blob/main/apps/wx_server_example/src/db_SUITE.erl) ）
2.	解耦的业务逻辑处理模式，能让响应更快、能够让服务器更加稳定，从根本上避免程序员的失误（忘记添加try catch等）。业务功能没有自己独立的进程，只有相关的独立数据层，玩家拥有独立进程，在处理玩家请求的业务逻辑时，通过事务锁将相关的功能数据获取到玩家进程中进行计算处理，完成后在将其返回存储。所有的功能代码逻辑均在玩家进程进行操作，因此多个玩家同时操作一个功能的重逻辑（耗时较长）时会减少排队等待行为；同时，若存在异常问题，也只会影响当前玩家进程。
3.	灵活的配置模块，在服务器底层方面能够灵活的配置通讯协议及其参数，还有数据库ETS、DETS等配置。在业务逻辑方面，摆脱了excel表的臃肿，方便设定功能性的微小配置，例如功能开启条件（等级）、功能初始的配置ID、抽奖功能的次数、功能的领奖时间段、等，若用Excel，只能新建表、sheet或者添加到统一的全局配置表中，这种方式有些臃肿且不便于后期维护。
4.	HTTP接口是通过配置实现，依赖于cowboy库。配置例如：[{“/user/:route”, USER_MODULE, INIT_ARGS},…]，USER_MODULE为user功能相关的接口模块、”/user/:route”表示路由请求url路径为/user/*都会进入USER_MODULE进行处理、INIT_ARGS为初始参数。
5.	游戏中的应用协议实现方式，可以灵活修改，开发包含指定接口（解码、编码）的模块即可，见[wx_server_example项目的net.cfg配置](https://github.com/SuperMuscleMan/wx_server_example/blob/main/apps/wx_server_example/priv/.cfg/net.cfg) 这里的wx_tcp_protocol_game模块。
6.	灵活的底层架构，各个底层功能模块都是独立的项目，通过[框架启动入口模块](https://github.com/SuperMuscleMan/wx_overman) 依赖项目所需的其它模块。且项目的构建工具使用的rebar3，可方便打包、发布等。


## 启动过程 ##
首先由wx_overman入口模块读取整个项目下的配置文件（`.cfg` 后缀的Erlang term配置文件，有示例可看，路径为apps/wx_server_example/priv/.cfg/），从配置中检索出所有日志层配置、数据层配置、事件层配置、网络层配置，并通过这些配置项去启动依赖的功能模块。


## 如何启动(windows端) ##
*假设你已经clone了本项目，且具备Erlang/OTP 23、rebar3 等环境*

### 1.获取依赖 ###
    
    rebar3 upgrade

### 2.编译 ###
    
    rebar3 compile

### 3.打包 ###
	
    rebar3 release

### 4.运行 ###
	
	.\_build\default\rel\wx_server_example\bin\wx_server_example.cmd console