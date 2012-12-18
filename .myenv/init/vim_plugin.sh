#!/bin/bash

[ -z $VIM_CONF ] && echo 'ERROR: env $VIM_CONF not set, pls check!' && exit

cd $VIM_CONF/bundle
name=vim-colors-solarized
if [ -e $name ] ; then
	echo "Updateing plugin: $name"
	cd $name
	git pull
else
	echo "Init (Cloning) plugin: $name"
	git clone git://github.com/altercation/vim-colors-solarized.git
fi
