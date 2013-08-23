#!/bin/bash

desc="Generate php runtime dir"
usage="USAGE: $0 <name> <port(80)>"
[ $# -lt 2 ] && echo -e "${desc}\n${usage}" && exit 1

# Var - Config
name=$1
port=$2
parent_base=~/data/php
php_home=$MY_DEV/php
php_conf=$php_home/php.ini-production
php_conf_fpm=$php_home/php-fpm.conf.default
common_func=$MY_ENV/ctrl/common.func.sh

# Var - Count
base=$parent_base/$name
conf=$base/conf/
pidfile=$base/${name}.pid
log=$base/logs/${name}.log
cmd_server=$php_home/php-fpm

# Util
[ ! -e $common_func ] && echo "ERROR: $common_func not exist" && exit 1 || source $common_func

# Check
func_validate_name $name
func_validate_port $port
func_validate_exist $cmd_server

# Init
func_init_data_dir $base
cp $php_conf $conf/php.ini
cp $php_conf_fpm $conf/php-fpm.conf

-------------------------------------------------
exit

# Prepare
start_opts="-p $base -c conf/php.ini --fpm-config conf/php-fpm.conf --prefix $base --pid $pidfile --daemonize "
start_cmd="$cmd_server $start_opts &>> $log &"
stop_cmd="$cmd_server $start_opts stop"

# Gen scripts/files
echo 'export a=b' >> $base/bin/$COMMON_ENV
func_append_script $base/bin/start.sh		func_start "$base" "'$start_cmd'"		# '' help func_start's output to stdout, since start_cmd usually have ">/>>" inside
func_append_script $base/bin/stop.sh		func_pidfile_stop "$pidfile" "$stop_cmd"
func_append_script $base/bin/status.sh		func_pidfile_status "$pidfile"

func_append_readme $base "Generation command: $0 $*"
echo "Generation success, at: $base"
