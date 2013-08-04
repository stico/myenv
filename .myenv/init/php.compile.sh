#!/bin/bash

version=5.5.1
source_dir=/tmp/php-${version}
source_pkg=$HOME/Documents/ECS/php/php-${version}_src.tar.gz
[ ! -e "$source_pkg" ] && echo "$source_pkg not exist, pls check!" && exit 1

[ -e "$source_dir" ] && mv -f ${source_dir}{,.del}
tar zxvf $source_pkg -C /tmp
[ ! -e "$source_dir" ] && echo "$source_pkg not exist, pls check!" && exit 1

cd $source_dir
./configure --enable-opcache --prefix=$HOME/dev/php-${version}
#--with-mysqli=/your/path/to/mysql_config \
#--with-apxs2=/usr/local/apache2/bin/apxs \
#--with-jpeg-dir=/path/to/jpeglib \
#--with-tiff-dir=/path/to.tiffdir \
#--with-zlib-dir=/path/to/zlib \
#--with-imap=/path/to/imapcclient \
#--with-gd
make
make install
