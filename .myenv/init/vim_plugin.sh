#!/bin/bash

[ -z $VIM_CONF ] && echo 'ERROR: env $VIM_CONF not set, pls check!' && exit

# Plugin List
declare -A plugin_addr
plugin_addr["vim-colors-solarized"]="git://github.com/altercation/vim-colors-solarized.git"
#plugin_addr["quickfix-reflector.vim"]="git://github.com/stefandtw/quickfix-reflector.vim"	# oumg is enough, since only need qf lust update, NOT location list
#plugin_addr["YouCompleteMe"]="https://github.com/Valloric/YouCompleteMe.git"			# might need re-compile for big updates, see ~YouCompleteMe@vim
plugin_addr["nerdcommenter"]="https://github.com/scrooloose/nerdcommenter.git"
plugin_addr["vim-autoformat"]="https://github.com/Chiel92/vim-autoformat.git" 
plugin_addr["vim-characterize"]="https://github.com/tpope/vim-characterize"
plugin_addr["delimitMate"]="https://github.com/Raimondi/delimitMate.git"
plugin_addr["syntastic"]="https://github.com/scrooloose/syntastic.git"
plugin_addr["vim-surround"]="git://github.com/tpope/vim-surround.git"
plugin_addr["vim-pathogen"]="git://github.com/tpope/vim-pathogen.git"
plugin_addr["nerdtree"]="https://github.com/scrooloose/nerdtree.git"
plugin_addr["vim-easytags"]="https://github.com/xolox/vim-easytags"
plugin_addr["vim-repeat"]="git://github.com/tpope/vim-repeat.git"
plugin_addr["vim-oumg"]="https://github.com/stico/vim-oumg.git"
plugin_addr["tabular"]="git://github.com/godlygeek/tabular.git"
plugin_addr["vim-sleuth"]="https://github.com/tpope/vim-sleuth"
plugin_addr["ctrlp.vim"]="git://github.com/kien/ctrlp.vim.git"
plugin_addr["vim-misc"]="https://github.com/xolox/vim-misc"					# vim-easytags need this

# Plugin List String
plugin_candidates=""
for plugin in "${!plugin_addr[@]}" ; do
	plugin_candidates="$plugin_candidates $plugin"
done
[ -n "$*" ] && plugin_names=$* ||  plugin_names=$plugin_candidates

# Init env
[ -e "$VIM_CONF/bundle" ] || mkdir -p "$VIM_CONF/bundle"
[ -e "$VIM_CONF/autoload" ] || mkdir -p "$VIM_CONF/autoload"

# Init or Update Plugins
for plugin in $plugin_names ; do
	[ -z ${plugin_addr[$plugin]} ] && echo "ERROR: $plugin not exist in plugin candidates list ($plugin_candidates), pls check!" && continue

	if [ -e $VIM_CONF/bundle/$plugin/.git ] ; then
		echo "Updateing plugin: $plugin"
		\cd $VIM_CONF/bundle/$plugin
		git pull
	else
		echo "Init (Cloning) plugin: $plugin"
		\cd $VIM_CONF/bundle
		git clone ${plugin_addr[$plugin]} 
	fi
done

# update pathogen
echo "Updating pathogen by copy"
[ -e $VIM_CONF/autoload ] && mv $VIM_CONF/autoload /tmp/autoload_bak_`date "+%Y%m%d_%H%M%S"`
cp -R $VIM_CONF/bundle/vim-pathogen/autoload/ $VIM_CONF/

# other notes
echo "=== NOTE: conque (ver 2.3, Sep 2011) is installed manaully (http://code.google.com/p/conque/). Note, there is offcial version on github (https://github.com/vim-scripts/Conque-Shell), but seems not update enough (even the source is also very old) "
