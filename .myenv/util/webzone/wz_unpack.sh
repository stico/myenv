#!/bin/bash

tmp_dir=/tmp/wz_tmp
pack_name=/tmp/wz.zip
tomcat_ver=7.0.29
rsync_ver=3.0.7.3
nginx_ver=1.2.3
java_ver=6.0.27

# init user/dir
EXEC_USER=tomcat   ; groupadd $EXEC_USER || : ; useradd $EXEC_USER -g $EXEC_USER -s /sbin/nologin || :
EXEC_USER=www-data ; groupadd $EXEC_USER || : ; useradd $EXEC_USER -g $EXEC_USER -s /sbin/nologin || :
mkdir -p /data/weblog		# for web log
chmod 777 -R /data/weblog
mkdir -p /data/var		# for ssl cert
chmod 777 -R /data/var
mkdir -p /data/file		# for file
chmod 777 -R /data/file
mkdir -p /data/webapps		# for webapps


# unzip file
[ -e $tmp_dir ] && mv ${tmp_dir}{,.bak.`date +%Y%m%d_%H%M%S`}
mkdir -p $tmp_dir
unzip $pack_name -d $tmp_dir

# clean useless files
rm -rf $tmp_dir/data/services/tomcat_base/*
rm -rf $tmp_dir/data/services/nginx_vhost/*

[ ! -e /data ] && mkdir /data && chmod 755 /data
cp -rf $tmp_dir/data/* /data/
cp -rf $tmp_dir/etc/init.d/* /etc/init.d/
ln -s /data/services/tomcat-$tomcat_ver /usr/local/tomcat
ln -s /data/services/nginx-$nginx_ver /usr/local/nginx
ln -s /data/services/java-$java_ver /usr/local/java
ln -s /data/services/rsync-$rsync_ver /usr/local/rsync
ln -s /etc/init.d/rsync_8730 /etc/rc2.d/S52rsync_8730
