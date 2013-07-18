#!/bin/bash

# INFO: target path must be fixed, otherwise vim can not load files in runtime

# Pre-check
(! command -v ruby &> /dev/null) && echo "ERROR: Seems no ruby installed, pls check!" && exit 1
(! command -v python &> /dev/null) && echo "ERROR: Seems no python installed, pls check!" && exit 1
[ ! -e $MY_ENV/env_func_bash ] && echo "ERROR: $MY_ENV/env_func_bash not exist, pls check!" && exit 1

# Prepare - Var
vim_source=/tmp/vim_src_hg
mak_file=${vim_source}/src/Make_mvc.mak
source $MY_ENV/env_func_bash 
sys_info=`func_sys_info_os_name``func_sys_info_os_ver`_`func_sys_info_os_len`

# Prepare - dependencies
sudo apt-get build-dep vim
sudo apt-get install -y libgtk2.0-dev libx11-dev xorg-dev	# for linuxmint (otherwise reports not GUI support and no gvim created)
								# more: libgtk2.0-dev libx11-dev xorg-dev
								# more? exuberant-ctags rake python-dev git-core wget sed ack-grep 

# Hg src
mkdir -p $vim_source; cd $vim_source 
[ -e $vim_source/.hg ] && hg pull && hg update || hg clone https://vim.googlecode.com/hg/ .

# Get version
vim_ver=`sed -n -e '/^[vV]im\|^\s\|^$/!q;s/\s*Version \(\S*\)\..*/\1/p' $vim_source/Contents`
vim_target=~/program/vim-${vim_ver}_`date "+%Y%m%d"`_${sys_info}

# Configure
make distclean		# for configure 
make clean		# for build

								#CFLAGS="-O2" LDFLAGS="-static" ./configure \			# CFLAGS to avoid the -g flag. Failed: cause "no terminal library found", install libncurses5-dev/libncursesw5-dev not works since already installed
								#env CFLAGS="-O2" LDFLAGS="-static" ./configure \		# CFLAGS to avoid the -g flag. Failed: cause "no terminal library found", install libncurses5-dev/libncursesw5-dev not works since already installed
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

[ ! -e ${mak_file}.bak ] && cp ${mak_file} ${mak_file}.bak
sed -i 's/^RUBY_VER = .*/RUBY_VER = 20/' $mak_file
sed -i 's/^RUBY_VER_LONG = .*/RUBY_VER_LONG = 2.0/' $mak_file

# Make
make -j 2	# use 2 cpu core to compile
make install

# Record the compile options
cp $MY_ENV/init/`basename $0` $vim_target 

# TODO: 2013-06-12: why the compiled vim start mode is REPLACE?
