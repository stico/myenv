#!/bin/bash

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

function func_pidfile_status() {
	usage="USAGE: $FUNCNAME <pidfile>"
	return_status="Return status: 0 is running, otherwise not running or error"
	[ "$#" -lt 1 ] && echo -e "${usage}\n${return_status}" && exit 1
	
	[ ! -e "$1" ] && echo "Not running (pidfile not exist: $1)" && return 1

	pid_info=`ps -ef | grep $(cat $1) | grep -v grep`
	[ ! -z "$pid_info" ] && echo -e "Running\n$pid_info" && return 0
	echo "Not running (pid $(cat $1) not exist)" && return 1
}

function func_append_bash_script() {
	usage="USAGE: $FUNCNAME <path> <content>"
	[ "$#" -lt 2 ] && echo $usage && exit 1
	
	path=$1
	shift

	[ ! -e "$path" ] && echo "#!/bin/bash" > $path && chmod u+x $path
	echo "$*" >> $path
}

function func_init_data_dir() {
	usage="USAGE: $FUNCNAME <base>"
	[ "$#" -lt 1 ] && echo $usage && exit 1

	base=$1
	cmd_init=$2
	[ -d "$base" ] && echo "ERROR: $base already exist" && exit 1
	mkdir -p $base $base/bin $base/conf $base/logs $base/bak

	[ ! -z "$cmd_init" ] && eval "$cmd_init" 
}

function func_validate_name() {
	usage="USAGE: $FUNCNAME <name>"
	[ "$#" -lt 1 ] && echo $usage && exit 1

	pattern="^[-_a-zA-Z0-9]*$"
	echo $1 | grep -q -v $pattern && echo "ERROR: <name> ($name) MUST match $pattern" && exit 1
}

function func_validate_exist() {
	usage="USAGE: $FUNCNAME <path>"
	[ "$#" -lt 1 ] && echo $usage && exit 1
	
	[ ! -e "$1" ] && echo "ERROR: $1 not exist!" && exit 1
}

function func_validate_port() {
	usage="USAGE: $FUNCNAME <port>"
	[ "$#" -lt 1 ] && echo $usage && exit 1

	echo $1 | grep -q -v "^[0-9]*$" && echo "ERROR: <port> ($port) MUST be numeric" && exit 1
}
