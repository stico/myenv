#!/bin/bash

redis_url=http://download.redis.io/redis-stable.tar.gz
redis_dir1=/tmp/redis-stable 

# Download
cd /tmp
rm -rf $redis_dir1 redis-stable.tar.gz
wget $redis_url
[ -e redis-stable.tar.gz ] && tar zxvf redis-stable.tar.gz 
[ ! -d "$redis_dir1" ] && echo "ERROR: failed to download or extract redis" && exit 1

# Move to dev, update name with version
redis_ver=`sed -n -e 's/-\+\[ Redis\s*\([0-9.]*\).*/\1/p' redis-stable/00-RELEASENOTES | head -1`
[ -z "$redis_ver" ] && echo "ERROR: failed to get redis version" && exit 1
redis_dir2=~/dev/redis-${redis_ver}
[ -e "$redis_dir2" ] && echo "ERROR: $redis_dir2 already exist" && exit 1
mv $redis_dir1 $redis_dir2

# Make
cd $redis_dir2
make
mkdir bin
echo "INFO: Moving executables into bin dir"
find src -iregex 'src/redis-[^.]*' -exec cp {} bin \;
echo "INFO: Redis setup success!"
