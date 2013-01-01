#!/bin/bash

[ -z $VIM_CONF ] && echo 'ERROR: env $VIM_CONF not set, pls check!' && exit

declare -A plugin_addr
plugin_addr["vim-colors-solarized"]="git://github.com/altercation/vim-colors-solarized.git"
plugin_addr["vim-surround"]="git://github.com/tpope/vim-surround.git"
plugin_addr["vim-pathogen"]="git://github.com/tpope/vim-pathogen.git"
plugin_addr["vim-repeat"]="git://github.com/tpope/vim-repeat.git"

# update plugins
for plugin in "${!plugin_addr[@]}" ; do
	if [ -e $VIM_CONF/bundle/$plugin/.git ] ; then
		echo "Updateing plugin: $plugin"
		cd $VIM_CONF/bundle/$plugin
		git pull
	else
		echo "Init (Cloning) plugin: $plugin"
		cd $VIM_CONF/bundle
		git clone ${plugin_addr[$plugin]} 
	fi
done

# update pathogen
echo "Updating pathogen by copy"
[ -e $VIM_CONF/autoload ] && mv $VIM_CONF/autoload /tmp/
cp -R $VIM_CONF/bundle/vim-pathogen/autoload/ $VIM_CONF/