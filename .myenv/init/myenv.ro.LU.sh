#!/bin/bash

# Command: rm /tmp/myenv.ro.LU.sh ; wget -O /tmp/myenv.ro.LU.sh -q https://raw.github.com/stico/myenv/master/.myenv/init/myenv.ro.LU.sh && bash /tmp/myenv.ro.LU.sh 

git_myenv_name=myenv
git_myenv_addr=https://github.com/stico/myenv.git
#git_myenv_addr=git@github.com:stico/myenv.git		# need priviledge

function init_git {
	
	# Check if already exist
	(command -v git &> /dev/null) && echo "INFO: git already exist, skip init git" && return 0 
	[ -e ~/dev/git ] && echo "INFO: git already exist, skip init git" && return 0

	# Try install by system
	(sudo -n ls &> /dev/null) && sudo apt-get install -y git tree zip unzip subversion > /dev/null && return 0

	# Try compile
	git_tar="git-1.8.4.3.tar.gz"
	git_name="${git_tar%%.tar.gz}"
	git_url="https://git-core.googlecode.com/files/${git_tar}"
	git_target="~/dev/${git_name}"

	cd ~ && rm -rf "$git_tar" "$git_name" && wget "$git_url" && tar zxvf "$git_tar" && cd "$git_name"
	[ "$?" -ne "0" ] && echo "ERROR: failed to get git source" && exit 1

	mkdir -p "$git_target"
	./configure --prefix="$git_target"
	make
	make install

	ln -s ~/dev/${git_target} ~/dev/git
}

function init_env_with_git {
	echo "INFO: git command exist, use git way"

	tmp_init_dir=/tmp/myenv_init/`date "+%Y%m%d_%H%M%S"`
	mkdir -p $tmp_init_dir
	cd $tmp_init_dir
	( command -v git &> /dev/null ) && git="git" || git="~/dev/git/bin/git"

	$git clone $git_myenv_addr
	[ ! -e $tmp_init_dir/$git_myenv_name/.git ] && echo "ERROR: failed to init myenv, pls check!" && exit 1

	mv $tmp_init_dir/$git_myenv_name/* ~
	mv $tmp_init_dir/$git_myenv_name/.* ~
	#rm -rf ~/$git_myenv_name/

	cd ~
	$git remote add github $git_myenv_addr
	echo "INFO: myenv init success (git way)!"
}

# Deprecated: difficult to update system
function init_env_without_git {
	echo "Git not found, init myenv will not able to update, continue (N) [Y/N]?"
	read -e continue
	[ "$continue" != "Y" -a "$continue" != "y" ] && echo "Give up myenv init!" && return 1
	
	dir_name=myenv-master
	pkg_name=master.zip
	pkg_url=http://github.com/stico/myenv/archive/$pkg_name

	tmp_init_dir=/tmp/myenv_init/`date "+%Y%m%d_%H%M%S"`
	mkdir -p $tmp_init_dir
	cd $tmp_init_dir

	echo "downloading $pkg_url" && wget -q $pkg_url
	unzip $pkg_name
	[ ! -e $tmp_init_dir/$git_myenv_name/.myenv ] && echo "ERROR: failed to init myenv, pls check!" && exit 1

	mv -f $tmp_init_dir/$dir_name/* ~
	mv -f $tmp_init_dir/$dir_name/.* ~
	echo "INFO: myenv init success (unzip way)!"
}

[ -e ~/.git ] && echo "~/.git already exist, will not init (RO), pls check!" && exit 0

init_git
init_env_with_git
