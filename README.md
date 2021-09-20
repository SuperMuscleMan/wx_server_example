wx_server_example
=====
wx Server服务器框架示例

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