#!/bin/bash

desc="Generate php-fpm runtime dir"
usage="USAGE: $0 <name> <port(9000)>"
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
log_slow=$base/logs/${name}.slow.log
log_error=$base/logs/${name}.error.log
log_access=$base/logs/www.access.log
cmd_server=$php_home/php-fpm

# Util
[ ! -e $common_func ] && echo "ERROR: $common_func not exist" && exit 1 || source $common_func

# Check
func_validate_name $name
func_validate_port $port
func_validate_exist $cmd_server

# Init
func_init_data_dir $base
touch $log_access
cp $php_conf $conf/php.ini
cp $php_conf_fpm $conf/php-fpm.conf
sed -i -e "s/^user = .*/user = $(whoami)/" $conf/php-fpm.conf
sed -i -e "s/^group = .*/group = $(whoami)/" $conf/php-fpm.conf
sed -i -e "s/^listen = .*/listen = 0.0.0.0:$port/" $conf/php-fpm.conf
sed -i -e "s+^;pid = .*+pid = $pidfile+" $conf/php-fpm.conf
sed -i -e "s+^;chdir = .*+chdir = /data+" $conf/php-fpm.conf
sed -i -e 's+^;chroot = .*+chroot = $prefix+' $conf/php-fpm.conf
sed -i -e "s+^;slowlog = .*+slowlog = $log_slow+" $conf/php-fpm.conf
sed -i -e "s+^;error_log = .*+error_log = $log_error+" $conf/php-fpm.conf
sed -i -e 's+^;access.log = .*+access.log = logs/$pool.access.log+' $conf/php-fpm.conf

# Prepare
start_opts="-p $base -c conf/php.ini 
	--fpm-config $conf/php-fpm.conf 
	--prefix $base 
	--daemonize"
start_cmd="$cmd_server $start_opts &>> $log &"
#stop_cmd="$cmd_server $start_opts stop"	# seems not work
stop_cmd='kill `cat '$pidfile'`'

# Gen scripts/files
echo 'export a=b' >> $base/bin/$COMMON_ENV
func_append_script $base/bin/start.sh		func_start "$base" "'$start_cmd'"		# '' help func_start's output to stdout, since start_cmd usually have ">/>>" inside
func_append_script $base/bin/stop.sh		func_pidfile_stop "$pidfile" "$stop_cmd"
func_append_script $base/bin/status.sh		func_pidfile_status "$pidfile"

func_append_readme $base "Generation command: $0 $*"
echo "Generation success, at: $base"
