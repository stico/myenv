#!/bin/bash

# TODO: start-client not work
desc="Generate zookeeper runtime dir"
usage="USAGE: $0 <name> <port(2181)>"
[ $# -lt 2 ] && echo -e "${desc}\n${usage}" && exit 1

# Var - Config
name=$1
port=$2
parent_base=~/data/zookeeper
zookeeper_home=$MY_DEV/zookeeper
zookeeper_conf=$zookeeper_home/conf/zoo_sample.cfg
zookeeper_conf_log=$zookeeper_home/conf/log4j.properties
common_func=$MY_ENV/ctrl/common.func.sh

# Var - Count
base=$parent_base/$name
bin=$base/bin
data=$base/data
conf=$base/conf/${name}.cfg
conf_log=$base/conf/log4j.properties
pidfile=$base/pidfile_auto
log_dir=$base/logs
log=$log_dir/${name}.log
log_zk=$log_dir/${name}_zk.log

# Util
[ ! -e $common_func ] && echo "ERROR: $common_func not exist" && exit 1 || source $common_func

# Check
func_validate_name $name
func_validate_port $port
func_validate_exist $zookeeper_conf
###########################func_validate_exist $cmd_client $cmd_server

# Init
func_init_data_dir $base
cp $zookeeper_conf $conf
cp $zookeeper_conf_log $conf_log
sed -i -e "s+^clientPort=.*+clientPort=${port}+;s+^dataDir=.*+dataDir=${data}+;" $conf
sed -i -e "s+\${zookeeper.root.logger}+INFO, CONSOLE+;s+\${zookeeper.*.threshold}+info+;s+\${zookeeper.*.dir}+$log_dir+;s+\${zookeeper.*.file}+$(basename $log_zk)+" $conf_log

# Prepare
java_options="-cp $conf:$zookeeper_home/zookeeper-3.4.5.jar:$zookeeper_home/lib/slf4j-api-1.6.1.jar:$zookeeper_home/lib/slf4j-log4j12-1.6.1.jar:$zookeeper_home/lib/log4j-1.2.15.jar"
start_cmd="java $java_options org.apache.zookeeper.server.quorum.QuorumPeerMain $conf &>> $log &"
start_cli_cmd="java $java_options org.apache.zookeeper.ZooKeeperMain"
stop_cmd='kill `cat '$pidfile'`'

# Gen scripts/files
echo "export aaa=bbb" >> $base/bin/$COMMON_ENV
func_append_script $base/bin/start.sh		func_start "$base" "'$start_cmd'"		# '' help func_start's output to stdout, since start_cmd usually have ">/>>" inside
func_append_script $base/bin/stop.sh		func_pidfile_stop "$pidfile" "$stop_cmd"
func_append_script $base/bin/status.sh		func_pidfile_status "$pidfile"
func_append_script $base/bin/start-client.sh	"$start_cli_cmd"

func_append_readme $base "Generation command: $0 $*"
echo "Generation success, at: $base"
