#!/bin/bash

git_myenv_name=myenv
#git_myenv_addr=https://github.com/stico/myenv.git
git_myenv_addr=git@github.com:stico/myenv.git
tmp_init_dir=/tmp/os_init/`date "+%Y%m%d_%H%M%S"`
[ -n "$1" -a -d "$1" ] && tmp_init_dir=$1 
mkdir -p $tmp_init_dir

sudo aptitude install -y git subversion > /dev/null
sudo aptitude install -y tree zip unzip > /dev/null

function init_with_git {
	echo "INFO: git command exist, use git way"

	cd $tmp_init_dir
	git clone $git_myenv_addr
	mv $tmp_init_dir/$git_myenv_name/* ~
	mv $tmp_init_dir/$git_myenv_name/.* ~
	#rm -rf ~/$git_myenv_name/

	cd ~
	git remote add github $git_myenv_addr
	echo "INFO: myenv init success (git way), invoke a new shell for you!"
}

function init_without_git {
	echo "Git not found, init myenv will not able to update, continue (N) [Y/N]?"
	read -e continue
	[ "$continue" != "Y" -a "$continue" != "y" ] && echo "Give up myenv init!" && return 1
	
	dir_name=myenv-master
	pkg_name=master.zip
	pkg_url=http://github.com/stico/myenv/archive/$pkg_name

	cd $tmp_init_dir
	echo "downloading $pkg_url" && wget -q $pkg_url
	unzip $pkg_name
	mv -f $tmp_init_dir/$dir_name/* ~
	mv -f $tmp_init_dir/$dir_name/.* ~
	echo "INFO: myenv init success (unzip way), invoke a new shell for you!"
}

[ -e ~/.git ] && echo "myenv repository already exist, skip..." && exit 0
(command -v git &> /dev/null) && init_with_git || init_without_git
