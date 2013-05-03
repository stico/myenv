#!/bin/bash
# (2013-05-02) could compile terminal version (vim), but failed to compile GUI version (gvim)

# Var
log_prefix=log_vim_compile
vim_source=/cygdrive/e/amp/vim_source/vim
vim_target=/cygdrive/e/program/vim_73_compile

# Init and Check 
[ ! -e $vim_source ] && echo "ERROR: $vim_source not exist, pls check!" && exit 1
[ ! -e /bin/apt-cyg ] && curl http://apt-cyg.googlecode.com/svn/trunk/apt-cyg > /bin/ && chmod +x /bin/apt-cyg
[ ! -e /etc/pango ] && mkdir /etc/pango
[ -e $vim_target ] && rm -rf $vim_target

# perform
cd $vim_source
apt-cyg install \
	--cache /local_pkg \
	--mirror http://mirrors.163.com/cygwin/ \
	gcc4 \
	mingw-gcc mingw64-i686-gcc \
	pkg-config libncurses-devel \
	gtk2.0 libgtk2.0-devel libgtk2.0_0 \
	glib2.0 libglib2.0-devel libglib2.0_0 \
	pango1.0 libpango1.0-devel libpango1.0_0 atk1.0 \
	libatk1.0-devel libatk1.0_0 git2.0-atk-bridge \
	pixman libpixman1_0 libpixman1-devel \
	libX11 libX11_6 libX11-devel \
	libXt libXt-devel libXt6 \
	libXtst libXtst-devel libXtst6 \
	libXpm libXpm4 libXpm-noX libXpm-noX_4 libXpm-devel libXpm-noX-devel sxpm \
	cairo libcairo2 libcairo-devel &> ${log_prefix}_apt-cyg.log 
make clean &> ${log_prefix}_make_clean.log
./configure --prefix=$vim_target --with-features=huge --enable-gui=gtk2 \
	--enable-fontset --enable-multibyte --enable-xim \
	--enable-pythoninterp --enable-rubyinterp 2>&1 > ${log_prefix}_configure.log 
make &> ${log_prefix}_make.log 
make install &> ${log_prefix}_make_install.log
