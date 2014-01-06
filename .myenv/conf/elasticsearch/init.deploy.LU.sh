#!/bin/bash

# Load common function
source $HOME/.myenv/myenv_func.sh || eval "$(wget -q -O - "https://raw.github.com/stico/myenv/master/.myenv/myenv_func.sh")" || exit 1
func="${HOME}/.myenv/ctrl/common.func.sh"; source "${func}" || eval "$(wget -q -O - "https://raw.github.com/stico/myenv/master/${func}")" || exit 1

# Variable
ver=0.90.9
deploy_name=elasticsearch_me
dev_base=~/dev/elasticsearch-${ver}
env_base=~/.myenv/conf/elasticsearch
data_base=~/data/elasticsearch/${deploy_name}
log=${data_base}/logs/${deploy_name}.log

# Pre check
func_validate_exist "${dev_base}/bin/elasticsearch"
func_validate_inexist "${data_base}"

# Deploy
func_init_data_dir $data_base
cp ${env_base}/elasticsearch*.yml ${data_base}/conf

start_cmd="JAVA_HOME=${JAVA_HOME} ${dev_base}/bin/elasticsearch -Des.bootstrap.mlockall=true -Des.path.data=${data_base}/data -Des.path.logs=${data_base}/logs &>> ${log} &"
stop_cmd='kill `cat '$pidfile'`'

echo 'export a=b' >> $base/bin/$COMMON_ENV
func_append_script $data_base/bin/start.sh	func_start "$data_base" "'$start_cmd'"		# '' help func_start's output to stdout, since start_cmd usually have ">/>>" inside
func_append_script $data_base/bin/stop.sh	func_pidfile_stop "$pidfile" "$stop_cmd"
func_append_script $data_base/bin/status.sh	func_pidfile_status "$pidfile"

func_append_readme $data_base "Generation command: $0 $*"
echo "Generation success, at: $data_base"
