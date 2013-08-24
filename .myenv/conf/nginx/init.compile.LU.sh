#!/bin/bash
# (2013-08-23) works with nginx-1.4.1

name=nginx-1.4.1
source=/tmp/$name
target=$HOME/dev/$name
source_pkg=$HOME/Documents/ECS/nginx/${name}.tar.gz

[ -e "$source" ] && rm -rf $source
tar zxvf $source_pkg -C /tmp

[ ! -e $source ] && echo "ERROR: $source not exist!" && exit 1
[ -e $target ] && echo "ERROR: $target already exist!" && exit 1

sudo apt-get install build-essential libpcre3 libpcre3-dev libssl-dev

cd $source
make clean

#--with-debug \
#--with-http_stub_status_module \
#--with-http_flv_module \
#--with-http_ssl_module \
#--with-http_dav_module \
#--with-http_gzip_static_module \
#--with-http_realip_module \
#--with-mail \
#--with-mail_ssl_module \
#--with-ipv6 \
#--add-module=./modules/nginx-ey-balancer \
#--add-module=./modules/ngx_cache_purge
./configure --prefix=$target
[ "$?" -eq 0 ] && make && make install 

target_link=${target%-*}
[ ! -e "$target_link" ] && ln -s $target/ $target_link
