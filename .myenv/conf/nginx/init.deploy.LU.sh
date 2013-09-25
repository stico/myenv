#!/bin/bash

desc="Generate nginx runtime dir"
usage="USAGE: $0 <name> <port(8000)>"
[ $# -lt 2 ] && echo -e "${desc}\n${usage}" && exit 1

# Var - Config
name=$1
port=$2
parent_base=~/data/nginx
nginx_home=$MY_DEV/nginx
nginx_html=$nginx_home/html
nginx_conf=$nginx_home/conf/nginx.conf
nginx_conf_mime=$nginx_home/conf/mime.types
nginx_conf_fcgi=$nginx_home/conf/fastcgi_params
common_func=$MY_ENV/ctrl/common.func.sh

# Var - Count
base=$parent_base/$name
conf=$base/conf/
pidfile=$base/${name}.pid
log=$base/logs/${name}.log
log_access=logs/access.log		# yes, relative path
cmd_server=$nginx_home/sbin/nginx

# Util
[ ! -e "$common_func" ] && echo "ERROR: $common_func not exist" && exit 1 || source $common_func

# Check
func_validate_name $name
func_validate_port $port
func_validate_exist $cmd_server

# Init
func_init_data_dir $base
cp $nginx_conf $conf
cp $nginx_conf_mime $conf
cp $nginx_conf_fcgi $conf
cp -R $nginx_html $base
sed -i -e "/#error_log\s\+.*.log;/s/#//" $base/conf/nginx.conf 
sed -i -e "s=#pid\s\+.*=pid `basename ${pidfile}`;=" $base/conf/nginx.conf 
sed -i -e "s=\(^[^#]*listen\s\+\)80\s*=\1$port=" $base/conf/nginx.conf 
sed -i -e '/log_format\s*main/,/;$/s/^\(\s*\)#/\1/' $base/conf/nginx.conf 
sed -i -e "/^[^#]*listen\s\+/,/access_log/s=#access_log\s\+.*=access_log $log_access main;=" $base/conf/nginx.conf 

# Prepare
start_opts="-p $base -c conf/nginx.conf "
start_cmd="$cmd_server $start_opts &>> $log &"
stop_cmd="$cmd_server $start_opts -s stop"

# Gen scripts/files
echo 'export a=b' >> $base/bin/$COMMON_ENV
func_append_script $base/bin/start.sh		func_start "$base" "'$start_cmd'"		# '' help func_start's output to stdout, since start_cmd usually have ">/>>" inside
func_append_script $base/bin/stop.sh		func_pidfile_stop "$pidfile" "$stop_cmd"
func_append_script $base/bin/status.sh		func_pidfile_status "$pidfile"

func_append_readme $base "Generation command: $0 $*"
echo "Generation success, at: $base"
