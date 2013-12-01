#!/bin/bash

# TODO: add local install 
# TODO: how to make link the vim statically?
# TODO: 2013-06-12: why the compiled vim start mode is REPLACE?
# INFO: target path must be fixed, otherwise vim can not load files in runtime

# Load common function
common_func_env=~/.myenv/env_func_bash 
common_func_tmp=/tmp/env_func_bash 
common_func_url="https://raw.github.com/stico/myenv/master/.myenv/env_func_bash" 
cp -f "$common_func_env" "$common_func_tmp" || wget -O "$common_func_tmp" -q "$common_func_url" 
[ ! -e "$common_func_tmp" ] && echo "ERROR: $common_func_tmp not exist" && exit 1|| source "$common_func_tmp" 

# Prepare - Check pre-condition
func_param_check 1 "USAGE: $0 <remote|local>" "$@" 
func_validate_cmd_exist ruby
func_validate_cmd_exist python

# Prepare - source
source_base=/tmp/source_base_vim
# func_build_prepare_source $source_base vim_73_source-hg_2013-05-02.zip https://vim.googlecode.com/hg/
if [ "$1" = "remote" ] ; then
	source_makefile=${source_base}/src/Make_mvc.mak
	func_mkdir_cd "${source_base}"
	[ -e $source_base/.hg ] && hg pull && hg update || hg clone https://vim.googlecode.com/hg/ .
fi

# Prepare - dependencies
# more: libgtk2.0-dev libx11-dev xorg-dev
# more? exuberant-ctags rake git-core wget sed ack-grep 
sudo apt-get build-dep vim
sudo apt-get install -y libgtk2.0-dev libx11-dev xorg-dev	# for linuxmint (otherwise reports not GUI support and no gvim created)
sudo apt-get install -y python-dev libncurses5-dev libtinfo-dev 

# Variables
source_ver=`sed -n -e '/^[vV]im\|^\s\|^$/!q;s/\s*Version \(\S*\)\..*/\1/p' $source_base/Contents`
target_base=~/program/vim-${source_ver}_`date "+%Y%m%d"`_$(func_sys_info)

# Clean up
cd "$source_base" && make distclean && make clean

# Configure
#CFLAGS="-O2" LDFLAGS="-static" ./configure \			# CFLAGS to avoid the -g flag. Failed: cause "no terminal library found", install libncurses5-dev/libncursesw5-dev not works since already installed
#env CFLAGS="-O2" LDFLAGS="-static" ./configure \		# CFLAGS to avoid the -g flag. Failed: cause "no terminal library found", install libncurses5-dev/libncursesw5-dev not works since already installed
# more: --enable-perlinterp --enable-python3interp --enable-tclinterp --enable-rubyinterp
./configure \
--prefix=$target_base \
--with-features=huge \
--enable-pythoninterp \
--enable-rubyinterp \
--enable-multibyte \
--enable-gui=gtk2 \
--enable-fontset \
--enable-xim

[ ! -e ${source_makefile}.bak ] && cp ${source_makefile}{,.bak}
sed -i "s/^RUBY_VER = .*/RUBY_VER = 20/" $source_makefile
sed -i "s/^RUBY_VER_LONG = .*/RUBY_VER_LONG = 2.0/" $source_makefile

# Make
make -j 2	# use 2 cpu core to compile
make install

# Record the compile options
cp ~/.myenv/conf/vim/$(basename $0) $target_base 
