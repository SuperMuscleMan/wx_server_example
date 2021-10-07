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