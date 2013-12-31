#!/bin/bash

# Load common function
func="${HOME}/.myenv/env_func_bash"; source "${func}" || eval "$(wget -q -O - "https://raw.github.com/stico/myenv/master/${func}")" || exit 1
func="${HOME}/.myenv/ctrl/common.func.sh"; source "${func}" || eval "$(wget -q -O - "https://raw.github.com/stico/myenv/master/${func}")" || exit 1

# Variable
ver=1.3.2
jar=logstash-${ver}-flatjar.jar
dev_base=~/dev/logstash-${ver}
env_base=~/.myenv/conf/logstash
pidfile=pidfile_auto

# Pre check
func_validate_exist "${dev_base}/${jar}"
func_validate_inexist "${data_base}"

# Deploy - shipper
name="shipper"
data_base=~/data/logstash/${name}
log=${data_base}/logs/shipper.log
conf=${data_base}/conf/shipper.conf
func_init_data_dir $data_base
cp ${env_base}/conf_${name}.conf ${conf}
start_cmd="${JAVA_HOME}/bin/java -jar "${dev_base}/${jar}" agent -f ${conf} -l ${log} &>> ${log} &"
stop_cmd='kill `cat '$pidfile'`'
echo 'export a=b' >> $base/bin/$COMMON_ENV
func_append_script $data_base/bin/start.sh	func_start "$data_base" "'$start_cmd'"		# '' help func_start's output to stdout, since start_cmd usually have ">/>>" inside
func_append_script $data_base/bin/stop.sh	func_pidfile_stop "$pidfile" "$stop_cmd"
func_append_script $data_base/bin/status.sh	func_pidfile_status "$pidfile"
func_append_readme $data_base "Generation command: $0 $*"
echo "Generation success, at: $data_base"

# Deploy - collector
name="collector"
data_base=~/data/logstash/${name}
log=${data_base}/logs/collector.log
conf=${data_base}/conf/collector.conf
func_init_data_dir $data_base
cp ${env_base}/conf_${name}.conf ${conf}
start_cmd="${JAVA_HOME}/bin/java -jar "${dev_base}/${jar}" agent -f ${conf} -l ${log} &>> ${log} &"
stop_cmd='kill `cat '$pidfile'`'
func_append_script $data_base/bin/start.sh	func_start "$data_base" "'$start_cmd'"		# '' help func_start's output to stdout, since start_cmd usually have ">/>>" inside
func_append_script $data_base/bin/stop.sh	func_pidfile_stop "$pidfile" "$stop_cmd"
func_append_script $data_base/bin/status.sh	func_pidfile_status "$pidfile"
func_append_readme $data_base "Generation command: $0 $*"
echo "Generation success, at: $data_base"
