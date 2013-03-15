#!/bin/bash

apt_update_stamp=/var/lib/apt/periodic/update-success-stamp
apt_update_ago=$(( `date +%s` - `stat -c %Y $apt_update_stamp` ))
git_myenv_name=myenv
git_myenv_addr=https://github.com/stico/myenv.git


[ -e $apt_update_stamp ] && (( $apt_update_ago > 86400 )) && sudo apt-get update || echo "INFO: last 'apt-get update' was $apt_update_ago seconds ago, skip this time"

sudo apt-get install -y git subversion
sudo apt-get install -y tree zip unzip

function init_with_git {
	echo "INFO: git command exist, use git way"

	cd ~
	if [ -e ~/.git ] ; then
		echo "INFO: myenv repository alread exist, simple update it"
		git pull
	else
		git clone $git_myenv_addr
		mv ~/$git_myenv_name/* ~
		mv ~/$git_myenv_name/.* ~
		rm -rf ~/$git_myenv_name/
	fi
}

function init_without_git {
	echo "INFO: git command NOT exist, use zip way"
	
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
}

(command -v git &> /dev/null) && init_with_git || init_without_git
echo "INFO: myenv init success, you need to re-login shell!"
