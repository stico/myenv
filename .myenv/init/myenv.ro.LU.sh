#!/bin/bash

git_myenv_name=myenv
#git_myenv_addr=https://github.com/stico/myenv.git
git_myenv_addr=git@github.com:stico/myenv.git

sudo apt-get install -y git subversion
sudo apt-get install -y tree zip unzip

function init_with_git {
	echo "INFO: git command exist, use git way"

	cd ~
	if [ -e ~/.git ] ; then
		echo "INFO: myenv repository already exist, just update it"
		git pull
	else
		git clone $git_myenv_addr
		mv ~/$git_myenv_name/* ~
		mv ~/$git_myenv_name/.* ~
		rm -rf ~/$git_myenv_name/
		cd ~
		git remote add github $git_myenv_addr
	fi
	echo "INFO: myenv init success, invoke a new shell for you!"
}

function init_without_git {
	echo "Git not found, init myenv will not able to update, continue (N) [Y/N]?"
	read -e continue
	[ "$continue" != "Y" -a "$continue" != "y" ] && echo "Give up myenv init!" && return 1
	
	tmp_dir=/tmp/myenv_tmp_init
	dir_name=myenv-master
	pkg_name=master.zip

	rm -rf $tmp_dir
	mkdir -p $tmp_dir
	cd $tmp_dir
	wget http://github.com/stico/myenv/archive/$pkg_name
	unzip $pkg_name
	mv -f $tmp_dir/$dir_name/* ~
	mv -f $tmp_dir/$dir_name/.* ~
	echo "INFO: myenv init success, invoke a new shell for you!"
}

(command -v git &> /dev/null) && init_with_git || init_without_git
