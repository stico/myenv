#!/bin/bash

ver=7.4
base=$MY_DOC/ECS/lfs/$ver
sources_dir=$base/sources
sources_md5sums=$base/sources-md5sums
sources_wget_list=$base/sources-wget-list


# safe check
[ -e $base ] && echo "ERROR: $base already exist!" && exit 1
[ ! -e $(dirname $base) ] && echo "ERROR: $(dirname $base) not exist!" && exit 1
[ ! -w $(dirname $base) ] && echo "ERROR: $(dirname $base) has no wrirte permission" && exit 1

# init dir and download packages
[ ! -e $base ] && mkdir -p $base $sources_dir
wget http://www.linuxfromscratch.org/lfs/downloads/${ver}/LFS-BOOK-7.4.pdf
wget http://www.linuxfromscratch.org/lfs/downloads/${ver}/LFS-BOOK-7.4.tar.bz2
wget http://www.linuxfromscratch.org/lfs/downloads/${ver}/LFS-BOOK-7.4-NOCHUNKS.html
wget http://www.linuxfromscratch.org/lfs/downloads/${ver}/md5sums -O $sources_md5sums
wget http://www.linuxfromscratch.org/lfs/downloads/${ver}/wget-list -O $sources_wget_list
wget http://www.linuxfromscratch.org/lfs/downloads/${ver}/lfs-bootscripts-20130821.tar.bz2
wget -i $sources_wget_list -P $sources_dir
cp $sources_md5sums $sources_dir
cd $sources_dir
md5sum -c $(basename $sources_md5sums) | grep -v OK && echo "ERROR: md5 check failed!" && exit 1


