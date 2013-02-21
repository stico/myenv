#!/bin/bash

pack_name=/tmp/wz.zip
tomcat_ver=7.0.29
rsync_ver=3.0.7.3
nginx_ver=1.2.3
java_ver=6.0.27

# zip files
[ -e $pack_name ] && mv ${pack_name}{,.bak.`date +%Y%m%d_%H%M%S`}
zip -r $pack_name							\
       /data/services/tomcat-${tomcat_ver}				\
       /data/services/tomcat_base					\
       /etc/init.d/tomcat						\
       /data/services/java-$java_ver					\
       /data/services/rsync-$rsync_ver					\
       /etc/init.d/rsync_8730						\
       /data/services/nginx-$nginx_ver					\
       /data/services/nginx_vhost					\
       /etc/init.d/nginx						\
    -x /data/services/tomcat-$tomcat_ver/admin/monitor.sh-err.log 	\
    -x /data/services/tomcat-$tomcat_ver/admin/report.sh-err.log 	\
    -x /data/services/tomcat-$tomcat_ver/admin/report-content.log\*

