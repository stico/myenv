#!/bin/bash

desc="Generate mysql runtime dir"
usage="USAGE: $0 <name>"
[ $# -lt 1 ] && echo -e "${desc}\n${usage}" && exit 1

# Var
name=$1
base=~/data/mysql/$name
pidfile=$base/${name}.pid
log=$base/logs/${name}.log
log_error=$base/logs/${name}-error.log
mysql_home=~/dev/mysql
mysql_share=$mysql_home/share
mysql_conf=$MY_ENV/conf/mysql/conf.${name}.cnf
cmd_mysql=$mysql_home/bin/mysql
cmd_mysqld=$mysql_home/bin/mysqld
cmd_instdb=$mysql_home/scripts/mysql_install_db

# Util
func=$MY_ENV/ctrl/common.me.func.sh
[ ! -e $func ] && echo "ERROR: $func not exist" && exit 1 || source $func

# Check
func_validate_name $name
func_validate_exist $cmd_mysql
func_validate_exist $cmd_mysqld
func_validate_exist $cmd_instdb
func_validate_exist $mysql_conf
func_validate_exist $mysql_share

# Init
init_cmd="$cmd_instdb --basedir=$mysql_home --datadir=$base --user=`whoami` && touch $log_error"
func_init_data_dir $base "$init_cmd"

# NOTE 1: options here Overrides those in .cnf
# NOTE 2: (strange but yes), --defaults-file must as 1st option!
# TODO: all options here, not need the xxx.cnf file?
read start_opts <<-EOF
	--defaults-file=$mysql_conf				\
	--user=`whoami`						\
	--basedir=$mysql_home	 				\
	--datadir=$base 					\
	--lc-messages-dir=$mysql_share				\
	--socket=$base/mysql.sock				\
	--pid-file=$pidfile		 			\
	--log-error=$log_error
EOF
# TODO: use mysqld_safe? seems not as easy as change the cmd
start_cmd="$cmd_mysqld $start_opts &>> $log &"
start_check="$base/bin/status.sh &> /dev/null && echo 'ERROR: already running' && exit 1"
func_append_bash_script $base/bin/start.sh "$start_check"
func_append_bash_script $base/bin/start.sh "$start_cmd"
func_append_bash_script $base/bin/start.sh "sleep 1"
func_append_bash_script $base/bin/start.sh "$base/bin/status.sh &> /dev/null && echo 'Started'"

start_cli_cmd="$cmd_mysql -h127.0.0.1"
func_append_bash_script $base/bin/start-client.sh "$start_cli_cmd"

stop_cmd='kill `cat '$pidfile'`'
stop_func=`type func_pidfile_stop | tail -n +2`
func_append_bash_script $base/bin/stop.sh "$stop_func"
func_append_bash_script $base/bin/stop.sh func_pidfile_stop "$pidfile" "$stop_cmd"

status_cmd=`type func_pidfile_status | tail -n +2`
status_cmd=`type func_pidfile_status | tail -n +2`
func_append_bash_script $base/bin/status.sh "$status_cmd"
func_append_bash_script $base/bin/status.sh func_pidfile_status "$pidfile"

cp $0 $base/bak
echo "Generation date: `date`" >> $base/README 
echo "Generation command: $0 $*" >> $base/README 
echo "Note: $0 backuped in $base/bak" >> $base/README 

echo "Generation success, at: $base"
