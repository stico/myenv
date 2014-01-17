#!/bin/bash
# (2013-08-22) works with httpd-2.4.6

name=httpd-2.4.6
name_1=apr-1.4.8
name_2=apr-util-1.5.2
source=/tmp/$name
target=$HOME/dev/$name
source_pkg=$HOME/Documents/ECS/httpd/${name}.tar.gz
source_pkg_1=$HOME/Documents/ECS/httpd/${name_1}.tar.gz 
source_pkg_2=$HOME/Documents/ECS/httpd/${name_2}.tar.gz 

[ -e "$source" ] && rm -rf $source
tar zxvf $source_pkg -C /tmp
tar zxvf $source_pkg_1 -C $source/srclib && mv $source/srclib/$name_1 $source/srclib/${name_1%-*}
tar zxvf $source_pkg_2 -C $source/srclib && mv $source/srclib/$name_2 $source/srclib/${name_2%-*}

[ ! -e $source ] && echo "ERROR: $source not exist!" && exit 1
[ -e $target ] && echo "ERROR: $target already exist!" && exit 1

sudo apt-get install libpcre3-dev

cd $source
make clean

#--with-program-name=apache2  \
#--with-ldap=yes \
#--with-ldap-include=/usr/include \
#--with-ldap-lib=/usr/lib \
#--with-suexec-caller=www-data \
#--with-suexec-bin=/usr/lib/apache2/suexec \
#--with-suexec-docroot=/var/www \
#--with-suexec-userdir=public_html \
#--with-suexec-logfile=/var/log/apache2/suexec.log \
#--with-suexec-uidmin=100 \
#--with-apr=/usr/bin/apr-1-config \
#--with-apr-util=/usr/bin/apu-1-config \
conf_httpd="
--enable-so \
--enable-log-debug \
--enable-logio=static \
--enable-suexec=shared \
--enable-layout=Debian \
--enable-log-config=static \
--with-pcre=yes \
--with-included-apr \
--enable-pie \
--enable-http \
--enable-proxy \
--enable-deflate \
--enable-headers \
--enable-rewrite \
--enable-expires \
--enable-proxy-fcgi \
--enable-proxy-http \
--enable-mime-magic \
--enable-slotmem-shm \
--enable-proxy-balancer
"

# comment: --enable-shared-mods=all \	# modules can be dynamically loaded when it is started. This means, we can add further modules to our Apache install when we like
# comment: --with-mpm=prefork \		# php suggest this for production env, =worker & =prefork all generates apxs, who generates apxs2?
./configure \
--prefix=$target \
--with-mpm=prefork \
--enable-shared-mods=all \
$conf_httpd

#--enable-layout=Debian \
#--enable-so \
#--enable-suexec=shared \
#--enable-log-config=static \
#--enable-logio=static \
#--enable-pie \
#--enable-proxy \

[ "$?" -eq 0 ] && make && make install 

if [ "$?" -eq 0 ] ; then
	cp $target/etc/apache2/httpd.conf{,.bak}
	sed -i -e "s/^Listen 80/Listen 8070/" $target/etc/apache2/httpd.conf
	sed -i -e "s/^#\(.*LoadModule.*slotmem_shm_module.*\)/\1/" $target/etc/apache2/httpd.conf
	ln -s $target/usr/sbin/apachectl $target/usr/sbin/httpd
else
	echo "ERROR: compile/install failed!"
fi

target_link=${target%-*}
[ ! -e "$target_link" ] && ln -s $target/ $target_link
