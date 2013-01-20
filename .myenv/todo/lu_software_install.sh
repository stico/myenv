#!/bin/bash

#TODO: learn how to use launchpad
#TODO: compare tmux and terminator, http://os.51cto.com/art/201109/288565.htm
#TODO: investigate ubuntu tweak
#TODO: investigate MyUnity
#TODO: C-A-x to show hide terminal

work_dir=/tmp/os_init_work_dir
echo "Start os init with work dir $work_dir"

# todo - manual? - update apt source to cn
# todo - manual? - visudo, use NOPASSWD
# todo - how to reserve gnome terminal settings

# todo - manual? - init myenv
# cd /tmp/????
# git clone git://github.com/stico/myenv.git
# mv (how to avoid . and .. files)

# todo - redirect output to place for logging

# add ppa source 
#sudo add-apt-repository ppa:tualatrix/ppa			# ubuntu tweak stable
#sudo add-apt-repository ppa:gnome-terminator			# terminator

# install - common
sudo apt-get update
sudo apt-get install -y zip unzip expect unison			# Common, basic tools
sudo apt-get install -y openssh-server samba smbfs
sudo apt-get install -y build-essential make gcc cmake		# Common, build tools
sudo apt-get install -y git subversion mercurial		# Common, dev tools
sudo apt-get install -y tmux terminator autossh

sudo apt-get install -y xrdp virtualbox	vim-gnome 		# OS with X, xrdp supports windows native remote desktop connection
sudo apt-get install -y linux-headers-`uname -r`		# for what?

# install based on ubuntu desktop
# todo check os version
# todo check if chrome installed
# sudo apt-get -y install ibus-table-wubi			# sudo vi /usr/share/ibus-table/engine/table.py (set "self._chinese_mode = 2", them set hotkey and select input method in ibus preference)
# sudo apt-get -y install ubuntu-tweak
# sudo apt-get -y install gitk
# sudo apt-get -y install libnspr4-0d libcurl3			# for chrome
# chrome_stable="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
# cd $work_dir
# wget $chrome_stable
# sudo dpkg -i google-chrome-stable_current_amd64.deb		# will show error on ubuntu desktop 12.04
# if [ "$?" -ne 0 ] ; then sudo apt-get -f install; fi		# if error happen, this will force to install

# Autokey
#if grep -q 'Autokey' <(echo `gsettings get com.canonical.Unity.Panel systray-whitelist`); then 
#	echo "'Autokey' exists in Unity panel whitelist. Nothing to do here." ; 
#else  
#	echo "Adding 'Autokey' to Unity panel whitelist." ; 
#	gsettings set com.canonical.Unity.Panel systray-whitelist "`echo \`gsettings get com.canonical.Unity.Panel systray-whitelist | tr -d ]\`,\'Autokey\']`";  
#fi


# Deprecated
# sudo apt-get -y install wmctrl
