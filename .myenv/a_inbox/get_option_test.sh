#!/bin/bash

function get_option_test {
	usage="ssh_with_jump -h <host> -p <host_pattern> <commands>"

	host=
	host_pattern=
	while getopts "h:p:" OPTION ; do
		case $OPTION in
			h) host=$OPTARG ;;
			p) host_pattern=$OPTARG ;;
			?) echo -e "$usage"; exit 1 ;;
		esac
	done

	if [ -z "$host" -a -z "$host_pattern" ]; then
	     echo -e "no target host/pattern was set!\n$usage"
	     exit 1
	fi

	echo $host
	echo $host_pattern
	echo $@
}


get_option_test -h 111 -p "*222?" -h 222 333 444 555
