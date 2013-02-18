#!/bin/bash

apt_update_stamp=/var/lib/apt/periodic/update-success-stamp
apt_update_ago=$(( `date +%s` - `stat -c %Y $apt_update_stamp` ))
git_myenv_name=myenv
git_myenv_addr=https://github.com/stico/myenv.git


[ -e $apt_update_stamp ] && (( $apt_update_ago > 86400 )) && sudo apt-get update || echo "INFO: last 'apt-get update' was $apt_update_ago seconds ago, skip this time"

command -v git || sudo apt-get install -y git
command -v git || sudo apt-get install -y tree

cd ~
if [ -e ~/.git ] ; then
	git pull
else
	git clone $git_myenv_addr
	mv ~/$git_myenv_name/* ~
	mv ~/$git_myenv_name/.* ~
	rm -rf ~/$git_myenv_name/
fi
echo "INFO: myenv init success, you need to re-login shell!"
