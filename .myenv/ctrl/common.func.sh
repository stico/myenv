#!/bin/bash

COMMON_ENV=env.sh
COMMON_FUNC=common.func.sh
COMMON_TPL_SCRIPT=common.tpl.ctrl.sh

function func_pidfile_stop() {
	usage="USAGE: $FUNCNAME <pidfile> <cmd_stop>"
	[ "$#" -lt 2 ] && echo $usage && exit 1
	
	pidfile=$1
	shift
	cmd_stop="$*"
	[ ! -e "$pidfile" ] && echo "ERROR: pidfile not exist: $pidfile)" && exit 1

	pid=$(cat $pidfile)
	echo "Stopping ..."
	$cmd_stop
	while [ -x /proc/${pid} ]
	do 
		echo "Waiting for shutdown ..." 
		sleep 1
	done
	echo "Stopped"
}

function func_start() {
	usage="USAGE: $FUNCNAME <base> <start_cmd>"
	[ "$#" -lt 2 ] && echo $usage && exit 1

	base=$1
	shift
	
	# precheck
	$base/bin/status.sh &> /dev/null && echo 'ERROR: already running' && exit 1

	# start_cmd
	eval $*

	# postcheck
	sleep 1
	$base/bin/status.sh &> /dev/null && echo 'Started' || echo 'ERROR: seems failed!'
}

function func_pidfile_status() {
	usage="USAGE: $FUNCNAME <pidfile>"
	return_status="Return status: 0 is running, otherwise not running or error"
	[ "$#" -lt 1 ] && echo -e "${usage}\n${return_status}" && exit 1
	
	[ ! -e "$1" ] && echo "Not running (pidfile not exist: $1)" && return 1

	pid_info=`ps -ef | grep $(cat $1) | grep -v grep`
	[ ! -z "$pid_info" ] && echo -e "Running\n$pid_info" && return 0
	echo "Not running (pid $(cat $1) not exist)" && return 1
}

function func_append_script() {
	usage="USAGE: $FUNCNAME <path> <content>"
	[ "$#" -lt 2 ] && echo $usage && exit 1
	
	path=$1
	shift

	# init script
	if [ ! -e "$path" ] ; then
		dir=`dirname $path`
		cp $MY_ENV/ctrl/$COMMON_TPL_SCRIPT $path
		[ ! -e "$dir/$COMMON_FUNC" ] && cp $MY_ENV/ctrl/$COMMON_FUNC $dir
		chmod u+x $path
	fi

	echo "$*" >> $path
}

function func_append_readme() {
	usage="USAGE: $FUNCNAME <base> <content>"
	[ "$#" -lt 1 ] && echo $usage && exit 1

	base=$1
	readme=$base/README
	shift

	if [ ! -e "$readme" ] ; then
		echo "Generation date: `date`" >> $readme
	fi

	echo "$*" >> $readme
}

function func_init_data_dir() {
	usage="USAGE: $FUNCNAME <base>"
	[ "$#" -lt 1 ] && echo $usage && exit 1

	base=$1
	[ -d "$base" ] && echo "ERROR: $base already exist" && exit 1
	mkdir -p $base $base/bin $base/conf $base/logs $base/data
}

function func_validate_name() {
	usage="USAGE: $FUNCNAME <name>"
	[ "$#" -lt 1 ] && echo $usage && exit 1

	pattern="^[-_a-zA-Z0-9]*$"
	echo $1 | grep -q -v $pattern && echo "ERROR: <name> ($name) MUST match $pattern" && exit 1
}

function func_validate_exist() {
	usage="USAGE: $FUNCNAME <path> <path> ..."
	[ "$#" -lt 1 ] && echo $usage && exit 1
	
	for path in $@ ; do
		[ ! -e "$path" ] && echo "ERROR: $path not exist!" && exit 1
	done
}

function func_validate_addr() {
	usage="USAGE: $FUNCNAME <addr>"
	[ "$#" -lt 1 ] && echo $usage && exit 1

	#echo $1 | egrep '[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}' && echo "ERROR: <addr> ($addr) format not correct" && exit 1
	echo $1 | egrep '[0-255]{1,3}\.[0-255]{1,3}\.[0-255]{1,3}\.[0-255]{1,3}' && echo "ERROR: <addr> ($addr) format not correct" && exit 1
}

function func_validate_port() {
	usage="USAGE: $FUNCNAME <port>"
	[ "$#" -lt 1 ] && echo $usage && exit 1

	echo $1 | grep -q -v "^[0-9]*$" && echo "ERROR: <port> ($port) MUST be numeric" && exit 1
}
