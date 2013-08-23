#!/bin/bash

desc="Generate mysql runtime dir"
usage="USAGE: $0 <name> <addr(127.0.0.1:3306)>"
[ $# -lt 1 ] && echo -e "${desc}\n${usage}" && exit 1

# Var - Config
name=$1
addr=${2%%:*}
port=${2##*:}
parent_base=~/data/mysql
mysql_home=~/dev/mysql
mysql_conf=$mysql_home/my.cnf				# not support unicode
#mysql_conf=$MY_ENV/conf/mysql/conf.${name}.cnf		# support unicode
common_func=$MY_ENV/ctrl/common.func.sh

# Var - Count
base=$parent_base/$name
data=$base/data
conf=$base/conf/${name}.cnf
pidfile=$base/${name}.pid
log=$base/logs/${name}.log
log_error=$base/logs/${name}-error.log
mysql_share=$mysql_home/share
cmd_client=$mysql_home/bin/mysql
cmd_server=$mysql_home/bin/mysqld
cmd_instdb=$mysql_home/scripts/mysql_install_db

# Util
[ ! -e $common_func ] && echo "ERROR: $common_func not exist" && exit 1 || source $common_func

# Check
func_validate_name $name
func_validate_addr $addr
func_validate_port $port
func_validate_exist $cmd_client $cmd_server $cmd_instdb $mysql_conf $mysql_share

# Init
func_init_data_dir $base "$init_cmd"
$cmd_instdb --basedir=$mysql_home --datadir=$data --user=`whoami`
cp $mysql_conf $conf
touch $log_error

# Prepare
# NOTE 1: options here Overrides those in .cnf
# NOTE 2: (strange but yes), --defaults-file must as first option!
read start_opts <<-EOF
--defaults-file=$conf \
--port=$port \
--user=`whoami` \
--datadir=$data \
--pid-file=$pidfile \
--bind-address=$addr \
--basedir=$mysql_home \
--log-error=$log_error \
--socket=$base/mysql.sock \
--character-set-server=utf8 \
--lc-messages-dir=$mysql_share \
--collation-server=utf8_unicode_ci
EOF
start_cmd="$cmd_server $start_opts &>> $log &"			# TODO: use mysqld_safe? seems not as easy as change the cmd
start_cli_cmd="$cmd_client -h127.0.0.1"
stop_cmd='kill `cat '$pidfile'`'

# Gen scripts/files
echo 'export a=b' >> $base/bin/$COMMON_ENV
func_append_script $base/bin/start.sh		func_start "$base" "'$start_cmd'"		# '' help func_start's output to stdout, since start_cmd usually have ">/>>" inside
func_append_script $base/bin/stop.sh		func_pidfile_stop "$pidfile" "$stop_cmd"
func_append_script $base/bin/status.sh		func_pidfile_status "$pidfile"
func_append_script $base/bin/start-client.sh	"$start_cli_cmd"

func_append_readme $base "Generation command: $0 $*"
echo "Generation success, at: $base"
