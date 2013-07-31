#!/bin/bash

# Variables
uniq_name=mysql_me
mysql_base=~/dev/mysql
mysql_data=~/data/$uniq_name
mysql_share=$mysql_base/share
mysql_pid=$mysql_data/mysql.pid
mysql_log=$mysql_data/log/error.log
mysql_conf=~/.myenv/conf/mysql/conf.${uniq_name}.cnf

cmd_mysqld=$mysql_base/bin/mysqld
cmd_mysqld_safe=$mysql_base/bin/mysqld_safe
cmd_instdb=$mysql_base/scripts/mysql_install_db

# NOTE 1: options here Overrides those in .cnf
# NOTE 2: (strange but yes), --defaults-file must as 1st option!
read mysql_opts <<-EOF
	--defaults-file=$mysql_conf				\
	--user=`whoami`						\
	--basedir=$mysql_base	 				\
	--datadir=$mysql_data 					\
	--lc-messages-dir=$mysql_share				\
	--socket=$mysql_data/mysql.sock				\
	--pid-file=$mysql_pid		 			\
	--log-error=$mysql_log
EOF

function mysql_me_start {
	# Prepare - Create DB for the 1st time
	[ ! -e $mysql_data ] && $cmd_instdb --basedir=$mysql_base --datadir=$mysql_data --user=`whoami`
	[ ! -e $mysql_log ] && mkdir $(dirname $mysql_log) && touch $mysql_log

	# TODO: use $cmd_mysqld_safe? seems not as easy as change the cmd
	#--ledir=$mysql_base/bin				# mysqld_safe to find the mysqld
	$cmd_mysqld $mysql_opts &
}

function mysql_me_status {
	[ -e $mysql_pid ] && ps -ef | grep $(cat $mysql_pid) | grep -v grep || echo "$uniq_name is Not running"
}

case "$1" in
start)
	mysql_me_start 
	;;
stop)
	echo "try to stop $uniq_name"
	[ -e $mysql_pid ] && kill `cat $mysql_pid` || echo "$uniq_name is NOT running"

	# TODO: better check
	sleep 3
	mysql_me_status

	# seems not work yet
	#$cmd_mysqld stop $mysql_opts
	;;
status)
	mysql_me_status
	;;
restart)
	mysql_me_start
	sleep 5
	$cmd_mysqld stop
	;;
*)
	options=`awk '/^\S*)$/{printf $0}' $0`
	echo "Usage: $(basename $0) (start|stop|restart)"
	exit 1
esac
exit 0

