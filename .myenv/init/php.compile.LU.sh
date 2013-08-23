#!/bin/bash
# (2013-08-22) work with php-5.5.2

name=php-5.5.2
source=/tmp/$name
target=$HOME/dev/$name
source_pkg=$HOME/Documents/ECS/php/${name}.tar.gz
apache_apxs=$HOME/dev/httpd/usr/bin/apxs

# Prepare
libpcre_path=/usr/lib/libpcre.a
if [ ! -f "$libpcre_path" ]; then
	[ -f "/usr/lib/i386-linux-gnu/libpcre.a" ] && sudo ln -s /usr/lib/i386-linux-gnu/libpcre.a "$libpcre_path"
	[ -f "/usr/lib/x86_64-linux-gnu/libpcre.a" ] && sudo ln -s /usr/lib/x86_64-linux-gnu/libpcre.a "$libpcre_path"
fi
[ -e "$source" ] && rm -rf $source
tar zxvf $source_pkg -C /tmp
#sudo apt-get install apache2-threaded-dev apache2-mpm-prefork apache2-prefork-dev
#apache_apxs=/usr/local/apache2/bin/apxs
#sudo apt-get install mysql-server libmysqlclient-dev 
#sudo apt-get install libsqlite3-dev sqlite3 
sudo apt-get install -y build-essential libcurl4-openssl-dev libreadline-dev libzip-dev libxslt1-dev libfreetype6-dev
sudo apt-get install -y libicu-dev libmcrypt-dev libmhash-dev libpcre3-dev libjpeg-dev libpng12-dev libbz2-dev libxpm-dev

# Check
[ ! -e "$source" ] && echo "ERROR: $source not exist!" && exit 1
[ -e "$target" ] && echo "ERROR: $target already exist!" && exit 1
[ ! -e "$apache_apxs" ] && echo "ERROR: $apache_apxs already exist!" && exit 1


# Compile - Prepare
cd $source
make clean
[ ! -f "$SRC/configure" ] && ./buildconf --force

# Compile - Options

#--with-fpm-user=www-data \
#--with-fpm-group=www-data
conf_fpm="--enable-fpm \
"

#--disable-rpath \
#--enable-ftp
#--enable-exif
#--enable-calendar
#--with-tiff-dir=/path/to.tiffdir \
#--with-imap=/path/to/imapcclient \
#--with-layout=GNU \
#--with-snmp=/usr
#--with-pspell
#--with-tidy=/usr
#--with-xmlrpc
#--with-xsl=/usr
#--with-pear \
#--with-mysql-sock=/var/run/mysqld/mysqld.sock \
#--with-icu-dir=/usr \
#--with-xpm-dir=/usr \
#--with-jpeg-dir=/usr \
#--with-openssl-dir=/usr/bin \
#--with-freetype-dir=/usr \
#--with-png-dir=shared,/usr \
#--with-iconv-dir=/usr \
#--with-zlib-dir=/usr \
#--with-sqlite3=/usr \
#--with-pdo-sqlite=/usr \
conf="--enable-mbstring \
--disable-cgi \
--enable-cli \
--enable-zip \
--enable-soap \
--enable-phar \
--enable-intl \
--enable-posix \
--enable-pcntl \
--enable-opcache \
--enable-mbregex \
--enable-sockets \
--enable-sysvmsg \
--enable-sysvsem \
--enable-sysvshm \
--enable-inline-optimization \
--with-gd \
--with-bz2 \
--with-curl \
--with-zlib \
--with-mhash \
--with-mcrypt \
--with-openssl \
--with-gettext \
--with-readline \
--with-regex=php \
--with-pcre-regex \
--with-mysqli=mysqlnd \
--with-pdo-mysql=mysqlnd \
--with-apxs2=$apache_apxs \
--with-config-file-path=$target \
--with-config-file-scan-dir=$target/conf.d \
"
#--sysconfdir=/etc \
#--localstatedir=/var \
./configure \
--config-cache \
--prefix=$target \
--sbindir=$target \
--sysconfdir=$target \
--mandir=$target/share/man \
$conf \
$conf_fpm
[ "$?" -eq 0 ] && make && make install || echo "ERROR: compile/install failed!"

# Last - make dirs
[ -e "$target" ] && mkdir -p "$target/conf.d" &> /dev/null
[ -e "$target" ] && mkdir -p "$target/share/man" &> /dev/null
[ -e "$target" ] && cp $source/php.ini-* $target && ln -s $target/php.ini-production $target/php.ini

exit

EXTENSION_DIR="$HOME/php/share/modules" # all shared modules will be installed in ~/php/share/modules phpize binary will configure it accordingly
export EXTENSION_DIR
PEAR_INSTALLDIR="$HOME/php/share/pear" # pear package directory
export PEAR_INSTALLDIR
