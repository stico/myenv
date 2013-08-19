#!/bin/bash

desc="Generate redis runtime dir"
usage="USAGE: $0 <port> <name>"
[ $# -lt 2 ] && echo -e "${desc}\n${usage}" && exit 1

# Var
port=$1
name=$2
base=~/data/redis/$name
pidfile=$base/${name}.pid
log=$base/logs/${name}.log
redis_home=$MY_DEV/redis
cmd_client=$redis_home/bin/redis-cli
cmd_server=$redis_home/bin/redis-server

# Util
func=$MY_ENV/ctrl/common.me.func.sh
[ ! -e $func ] && echo "ERROR: $func not exist" && exit 1 || source $func

# Check
func_validate_name $name
func_validate_port $port
func_validate_exist $cmd_client
func_validate_exist $cmd_server

# Init
func_init_data_dir $base
start_opts=" --dir $base --pidfile $pidfile --daemonize yes"
start_cmd="$cmd_server $start_opts &>> $log &"
start_check="$base/bin/status.sh &> /dev/null && echo 'ERROR: already running' && exit 1"
func_append_bash_script $base/bin/start.sh "$start_check"
func_append_bash_script $base/bin/start.sh "$start_cmd"
func_append_bash_script $base/bin/start.sh "sleep 1"
func_append_bash_script $base/bin/start.sh "$base/bin/status.sh &> /dev/null && echo 'Started'"

start_cli_cmd="$cmd_client -p $port"
func_append_bash_script $base/bin/start-client.sh "$start_cli_cmd"

stop_cmd="$cmd_client -p $port shutdown"
stop_func=`type func_pidfile_stop | tail -n +2`
func_append_bash_script $base/bin/stop.sh "$stop_func"
func_append_bash_script $base/bin/stop.sh func_pidfile_stop "$pidfile" "$stop_cmd"

status_cmd=`type func_pidfile_status | tail -n +2`
func_append_bash_script $base/bin/status.sh "$status_cmd"
func_append_bash_script $base/bin/status.sh func_pidfile_status "$pidfile"

cp $0 $base/bak
echo "Generation date: `date`" >> $base/README 
echo "Generation command: $0 $*" >> $base/README 
echo "Note: $0 backuped in $base/bak" >> $base/README 
echo "See default values in $redis_home/redis.conf" >> $base/conf/README 

echo "Generation success, at: $base"
