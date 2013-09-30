#!/bin/bash

desc="Generate (apache) httpd runtime dir"
usage="USAGE: $0 <name> <port(8070)>"
[ $# -lt 2 ] && echo -e "${desc}\n${usage}" && exit 1

# Var - Config
name=$1
port=$2
parent_base=~/data/httpd
httpd_home=$MY_DEV/httpd
httpd_conf=$httpd_home/etc/apache2/httpd.conf
common_func=$MY_ENV/ctrl/common.func.sh

# Var - Self
base=$parent_base/$name
data=$base/data
conf=$base/conf/httpd.conf
pidfile=$base/${name}.pid
log=$base/logs/${name}.log
log_error=$base/logs/${name}.error.log
log_access=$base/logs/www.access.log
cmd_server=$httpd_home/usr/sbin/apachectl

# Util
[ ! -e "$common_func" ] && echo "ERROR: $common_func not exist" && exit 1 || source $common_func

# Check
func_validate_name $name
func_validate_port $port
func_validate_exist $cmd_server

# Init
func_init_data_dir $base
echo '<?php phpInfo(); ?>' > $data/phpinfo.php
cp $httpd_conf $conf
sed -i -e "s/^Listen .*/Listen $port/" $conf
sed -i -e "s+^LogLevel .*+LogLevel info+" $conf
sed -i -e "/^#.*LoadModule.*mod_rewrite.so/s/^#//" $conf
sed -i -e "s+^ErrorLog .*+ErrorLog \"$log_error\"+" $conf
sed -i -e "s+^DocumentRoot .*+DocumentRoot \"$data\"+" $conf
sed -i -e "s+^\(\s*\)CustomLog.*+\1CustomLog \"$log_access\" common+" $conf
sed -i -e "s+^<Directory .*default-site/htdocs.*>+<Directory \"$data\">+" $conf
sed -i -e "s+^\(\s*\)AddType.*tgz+&\n\1AddType application/x-httpd-php .php\n\1AddType application/x-httpd-php-source .phps+" $conf
echo "PidFile $pidfile" >> $conf
#sed -i -e "s+^ServerRoot .*+ServerRoot $base+" $conf
#sed -i -e "s+\(^\s*[^#].*[^/]\)\(usr/\|etc/\|var/\)+\1$httpd_home/\2+" $conf

# Prepare
start_cmd="$cmd_server -f $conf &>> $log &"
stop_cmd='kill `cat '$pidfile'`'

# Gen scripts/files
echo 'export a=b' >> $base/bin/$COMMON_ENV
func_append_script $base/bin/start.sh		func_start "$base" "'$start_cmd'"		# '' help func_start's output to stdout, since start_cmd usually have ">/>>" inside
func_append_script $base/bin/stop.sh		func_pidfile_stop "$pidfile" "$stop_cmd"
func_append_script $base/bin/status.sh		func_pidfile_status "$pidfile"

func_append_readme $base "Generation command: $0 $*"
echo "Generation success, at: $base"
