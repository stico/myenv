#!/bin/bash

ver=redis-2.6.3
tmp=/tmp/${ver}
target=~/dev/${ver}

[ -d ${target} ] && echo "ERROR: ${target} already exist!" && exit 1

[ -d ${tmp} ] && rm -rf ${tmp}
[ -d ${tmp}.tar.gz ] && rm -rf ${tmp}.tar.gz

wget http://redis.googlecode.com/files/${ver}.tar.gz
tar xzvf ${tmp}.tar.gz -C /tmp
cd ${tmp}
make
mv ${tmp} ${target}

# then use redis-server/redis-cli under src dir
