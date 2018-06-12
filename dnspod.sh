#!/bin/sh 

##################################
#dnspod动态解析 bash单子域名版 by Binge
#v1.0 2018年06月12日
#
##################################
login_token="yourId,yourToken" #由"id,token"组成,DNSPOD-用户中心-安全设置
domain="xxx.com" #主域名
sub_domain="abc" #要动态解析的子域名记录 需要先在DNSPOD新建该记录 

re_times=3 #网络连接重连次数 为启动时需要时间寻找网络而设计
re_interval=60 #重连间隔 /秒

cur_dir=$(pwd)
cur_file=${0}
last_modified=$(stat -f %m $cur_file) #判断当前文件是否修改

file_config="$cur_dir/dnspod_${sub_domain}.cache" #缓存文件保存路径
url_list_record="https://dnsapi.cn/Record.List"
url_modify_record="https://dnsapi.cn/Record.Modify"

#获取公网IP,判断网络连接
Get_IP(){
  if [[ $re_times -lt 1 ]]; then
  	Error "网络无法连接"
  else 
  	re_times=$(($re_times - 1))
  fi
  ip=$(curl -s -m 10 http://ns1.dnspod.net:6666)
  local res=$((${#ip})) 
if [[ $res -lt 2 ]]; then
	Log "网络无法连接，稍后重连"
	sleep $re_interval
	Get_IP
else
	Log "获得IP "$ip
fi
}

Json_parse(){
    temp=`echo $1 | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $2 `
    json_res=${temp##*|}
}


Post(){
	post_res=$(curl -X POST ${post_url} -d ${post_data} --user-agent "Dnspod_DDNS_Bash_Binge/1.0(gdsxlr@gmail.com)" 2> /dev/null)
	Log "$post_res"
	Json_parse "$post_res" "code"
	if [ $json_res != 1 ]; then
		Error 'API返回错误,请查看日志'
	fi
	
}
#获取子域名ID
List_record(){
  post_url=$url_list_record
  post_data="login_token=${login_token}&format=json&domain=${domain}&sub_domain=${sub_domain}"
  Post
  Json_parse "$post_res" 'id'
  record_id=$(echo $json_res | cut -d " " -f7) #单域名下API设计返回值有两个ID（domain subdomain)
  Json_parse "$post_res" 'line_id'
  record_line_id=$(echo $json_res | cut -d " " -f2)
  Json_parse "$post_res" 'type'
  record_type=$(echo $json_res | cut -d " " -f2)
  Json_parse "$post_res" 'value'
  save_ip=$(echo $json_res | cut -d " " -f2)
  Log '获取记录ID成功'
}
#修改解析记录
Modify_record(){
  post_url=$url_modify_record
  post_data="login_token=${login_token}&format=json&domain=${domain}&record_id=${record_id}&sub_domain=${sub_domain}&record_type=${record_type}&value=${ip}&record_line_id=${record_line_id}"
  Post
  save_ip=$ip
  Log "解析成功"  
}

Config(){
	echo > $file_config #清空或新建
	echo save_record_id="$record_id" >> $file_config
	echo save_record_type="$record_type" >> $file_config
	echo save_record_line_id="$record_line_id" >> $file_config
	echo save_last_modified="$last_modified" >> $file_config
    echo save_ip="$save_ip" >> $file_config
}
Error(){
	Log "$1"
	Log "Exit"
	exit 
}

Log(){
    date_info=`date`
	str=$date_info':  '"$1"
	echo $str
}

Run()
{
	Get_IP
	if [[ -r $file_config ]]; then
		source $file_config #读取设置文件 输出到变量
		record_id=$save_record_id
		record_type=$save_record_type
		record_line_id=$save_record_line_id
	else 
		List_record
		Modify_record		
		Log "首次运行,已输出 $file_config(缓存文件)"
		Config
		exit 0
	fi
	#对比上次读取的IP
	
	if [ "$last_modified" != "$save_last_modified" ]; then
		Log "文件被修改 重新获取Record ID"
		List_record
		Config
		Log "已缓存"
	fi

	Log '之前IP '$save_ip

	if [ "$ip" != "$save_ip" ]; then
		Log 'IP变化,执行解析'
	    Modify_record		
	    Config
	else
		Log "IP相同,无需解析"
	fi


}
#使用crontab 不用循环
Log "开始运行"
Run
Log "结束"
exit 0

	

