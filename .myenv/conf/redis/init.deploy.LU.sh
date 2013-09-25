#!/bin/bash

desc="Generate redis runtime dir"
usage="USAGE: $0 <name> <port(6379)>"
[ $# -lt 2 ] && echo -e "${desc}\n${usage}" && exit 1

# Var - Config
name=$1
port=$2
parent_base=~/data/redis
redis_home=$MY_DEV/redis
redis_conf=$redis_home/redis.conf
common_func=$MY_ENV/ctrl/common.func.sh

# Var - Count
base=$parent_base/$name
data=$base/data
conf=$base/conf/${name}.conf
pidfile=$base/${name}.pid
log=$base/logs/${name}.log
cmd_client=$redis_home/bin/redis-cli
cmd_server=$redis_home/bin/redis-server

# Util
[ ! -e "$common_func" ] && echo "ERROR: $common_func not exist" && exit 1 || source $common_func

# Check
func_validate_name $name
func_validate_port $port
func_validate_exist $cmd_client $cmd_server

# Init
func_init_data_dir $base
cp $redis_conf $conf

# Prepare
start_opts="$conf \
--dir $data \
--daemonize yes \
--pidfile $pidfile
"
start_cmd="$cmd_server $start_opts &>> $log &"
stop_cmd="$cmd_client -p $port shutdown"
start_cli_cmd="$cmd_client -p $port"

# Gen scripts/files
echo 'export a=b' >> $base/bin/$COMMON_ENV
func_append_script $base/bin/start.sh		func_start "$base" "'$start_cmd'"		# '' help func_start's output to stdout, since start_cmd usually have ">/>>" inside
func_append_script $base/bin/stop.sh		func_pidfile_stop "$pidfile" "$stop_cmd"
func_append_script $base/bin/status.sh		func_pidfile_status "$pidfile"
func_append_script $base/bin/start-client.sh	"$start_cli_cmd"

func_append_readme $base "Generation command: $0 $*"
echo "Generation success, at: $base"
