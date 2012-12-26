#!/bin/bash

base=$MY_CONF/dircolors_solarized
[ ! -e $base ] && echo "ERROR: $base not exist, pls check!" && exit

cd $base
if [ -e $base/.git ] ; then
	echo "Updateing git repo: $base"
	git pull
else
	echo "Init (Cloning) git repo: $base"
	git clone git://github.com/seebi/dircolors-solarized.git
fi

target=~/.dir_colors
rm $target
cp $base/dircolors.ansi-universal $target
echo "color setting copied, source: $base/dircolors.ansi-universal, target: $target"

if [ -z `readlink -e $target` ] ; then
	cp $MY_CONF/dircolors_basic/dir_colors $target
	echo "Warn: seems setup dir color failed, will copy basic one, source: $base/dircolors.ansi-universal, target: $target"
fi
