#!/bin/bash

# Var
vim_source=/tmp/vim_src_hg
vim_target=~/program/vim_73_compile
mak_file=${vim_source}/src/Make_mvc.mak

# Prepare
sudo apt-get build-dep vim
sudo apt-get install -y libncurses5-dev
# note: seems libncursesw5-dev not work
# more: libgtk2.0-dev libx11-dev xorg-dev
# more? exuberant-ctags rake python-dev git-core wget sed ack-grep 
mkdir -p $vim_source; cd $vim_source 
[ -e $vim_source/.hg ] && hg pull && hg update || hg clone https://vim.googlecode.com/hg/ .
[ ! -e ${mak_file}.bak ] && cp ${mak_file} ${mak_file}.bak

# Compile
make distclean		# for configure 
make clean		# for build
# CFLAGS to avoid the -g flag. 
#CFLAGS="-O2" LDFLAGS="-static" ./configure \		# cause "no terminal library found"
#env CFLAGS="-O2" LDFLAGS="-static" ./configure \	# cause "no terminal library found"
# TODO: how to make link the vim statically?
./configure \
--prefix=$vim_target \
--with-features=huge \
--enable-pythoninterp \
--enable-rubyinterp \
--enable-multibyte \
--enable-gui=gtk2 \
--enable-fontset \
--enable-xim
#more: --enable-perlinterp --enable-python3interp --enable-tclinterp --enable-rubyinterp

sed -i 's/^RUBY_VER = .*/RUBY_VER = 19/'		$mak_file
sed -i 's/^RUBY_VER_LONG = .*/RUBY_VER_LONG = 1.9/'	$mak_file

#make -j 3	# use 3 cpu core to compile
make install

# record the compile options
cp $MY_ENV/init/`basename $0` $vim_target 
