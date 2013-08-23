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

cd $source
make clean

./configure --prefix=$target
[ "$?" -eq 0 ] && make && make install 
