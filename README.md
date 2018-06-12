# Dnspod动态解析Linux shell版 v1.0 by Binge
## 简介 
[DNSPOD](https://DNSPOD.CN)是一家域名解析服务提供商，利用[Dnspod API](https://support.dnspod.cn/Support/api)可以实现域名的动态解析。相比于花生壳等动态解析服务，在拥有自己域名情况下使用DNSPOD要好太多。

该脚本程序运行于LINUX，配置好后每个脚本对应一个子域名，如有多子域名解析的需要，可以复制多个脚本来实现多子域名解析。
有详细的日志输出，自判断网络连接情况和缓存记录。
## 使用
### 修改设置
使用编辑器打开dnspod.sh文件，修改以下设置

```bash
login_token="yourId,yourToken" #由"id,token"组成 DNSPOD-用户中心-安全设置
domain="xxx.com" #主域名
sub_domain="abc" #要动态解析的子域名记录 需要先在DNSPOD新建该记录
```
以下可保持默认

```bash
re_times=3 #网络连接重连次数 为启动时需要时间寻找网络而设计
re_interval=60 #重连间隔 /秒
```
如有必要请修改文件权限 `chmod +x dnspod.sh`

_使用前一定要在DNSPOD添加该子域名的解析记录并设置好类型、线路等，解析IP可以填写任意值_


### 添加至crontab
在终端键入`crontab -e `（提示没有crontab文件的需要用`crontab xxx`装入新文件xxx）
添加以下命令

```bash
*/10 * * * * bash (dir)/dnspod.sh >> (dir)/dnspod.log 2> /dev/null
```
表示每十分钟执行一次脚本，目录文件保存在(dir)/dnspod.log处，根据情况自行修改该命令
## 运行截图
![](http://files.bingestech.com/a73vWti6RJcMRLMBtgFbIahPSzdmTYql.jpg)

## 环境测试
- [x] MAC OS 10.11.6















