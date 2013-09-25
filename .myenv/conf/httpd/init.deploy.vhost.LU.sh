#!/bin/bash

desc="Generate (apache) httpd runtime vhost dir and config"
usage="USAGE: $0 <name(httpd_me)> <name_vhost>"
[ $# -lt 2 ] && echo -e "${desc}\n${usage}" && exit 1

# Var - Config
name=$1
name_vhost=$2
parent_base=~/data/httpd
common_func=$MY_ENV/ctrl/common.func.sh

# Var - Self
base=$parent_base/$name
data_vhost=$base/data-vhost-${name_vhost}
conf=$base/conf/httpd.conf
conf_vhost=$base/conf/httpd-vhost-${name_vhost}.conf

# Util
[ ! -e "$common_func" ] && echo "ERROR: $common_func not exist" && exit 1 || source $common_func

# Check
func_validate_name $name
func_validate_name $name_vhost
func_validate_exist $base
func_validate_inexist $data_vhost
grep -q "$conf_vhost" $conf && echo "ERROR: $name_vhost already added!" && exit 1
status=$($base/bin/status.sh)
( ! echo "$status" | grep -q "^Not running.*" ) && echo "ERROR: $name is running or status check failed!" && exit 1
port=$(sed -n "s/^Listen\s*\([0-9]\+\)/\1/p" $conf)
func_validate_numeric $port

# Add vhost
mkdir -p $data_vhost
echo "<?php echo ${name_vhost}; phpInfo(); ?>" > ${data_vhost}/phpinfo.php
cat > $conf_vhost <<-EOF
	<VirtualHost *:${port}>
	    ServerAdmin webmaster@dummy-host.example.com
	    DocumentRoot "${data_vhost}"
	    ServerName www.localhost.com
	</VirtualHost>

	Alias /${name_vhost} "${data_vhost}"

	<Directory "${data_vhost}">
	    Options Indexes FollowSymLinks Includes ExecCGI
	    #Options FollowSymLinks
	    #AllowOverride Limit FileInfo Indexes
	    AllowOverride All
	    Order deny,allow
	    Allow from all
	    #DirectoryIndex index.cgi
	    #AddHandler cgi-script .cgi
	    
	    # Without this line, will gets 403 (server log: "client denied by server configuration ...")
	    Require all granted
	</Directory>
EOF
echo "Include $conf_vhost" >> $conf

echo -e "Add vhost success"
echo -e "\tDocumentRoot: ${data_vhost}"
echo -e "\tConf Location: ${conf_vhost}"
echo -e "\tConf Included In: ${conf}"
