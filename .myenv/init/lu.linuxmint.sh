#!/bin/bash

#TODO: investigate ubuntu tweak
#TODO: investigate MyUnity


# Variables
chrome_stable='https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb'
apt_source=/etc/apt/sources.list

echo "############################################################ APT SRC UPDATE"
#TODO "NOT IMPL YET !"

echo "############################################################ APT-GET UPDATE"
apt_update_stamp=/var/lib/apt/periodic/update-success-stamp
apt_update_stamp2=/tmp/update-success-stamp
apt_update_ago=$(( `date +%s` - `stat -c %Y $apt_update_stamp` ))
apt_update_ago2=$(( `date +%s` - `stat -c %Y $apt_update_stamp2` ))
[ -e $apt_update_stamp ] && (( $apt_update_ago > 86400 ))				&&	\
[ -e $apt_update_stamp2 ] && (( $apt_update_ago2 > 86400 ))				&&	\
sudo apt-get update && touch $apt_update_stamp2						||	\
echo "INFO: last update was $apt_update_ago/$apt_update_ago2 seconds ago, skip..."

echo "############################################################ MK DOC LINK"
home_doc_path="$HOME/Documents"
(( `ls $home_doc_path 2>/dev/null | wc -l` != 0 ))	&& \
echo "$home_doc_path is not empty, exit!" && exit 1
[[ -e $home_doc_path ]] && rmdir $home_doc_path
ext_doc_path=`find /ext/ -maxdepth 3 -type d -name "Documents"`
(( `echo $ext_doc_path | wc -l` == 1 ))			&& \
ln -s $ext_doc_path $home_doc_path			|| \
echo "Failed to find Documents dir in /ext, exit!"

echo "############################################################ SETUP MYENV"
sudo apt-get -y install unzip
./myenv.rw.LU.sh

echo "############################################################ MK DEV/PROGRAM LINK"


echo "############################################################ INSTALL SOFT"
sudo apt-get -y install aptitude
ins_cmd=aptitude

exit


# Pre-condition/pre-work
[ ! -e ~/.myenv/env_func_bash ] && echo "ERROR: .myenv not exist !" && exit 1
(( $(grep -c "http://cn" $apt_source) < 1 )) && echo "ERROR: $apt_source are using non 'http://cn' sources!" && exit 1
. ~/.myenv/env_func_bash


# Installations
sys_info=`func_sys_info`
[ -e $apt_update_stamp ] && (( $apt_update_ago > 86400 )) && sudo apt-get update || echo "INFO: last 'apt-get update' was $apt_update_ago seconds ago, skip this time"
if [ $(echo "$sys_info" | grep -ic "ubuntu") == 1 ] ; then
	echo "INFO: installing software for ubuntu (common)"

	sudo apt-get install -y zip unzip expect unison openssh-server 	# basic tools
	sudo apt-get install -y build-essential make gcc cmake		# build tools
	sudo apt-get install -y samba smbfs				# samba
	sudo apt-get install -y python-software-properties		# for cmd add-apt-repository 
	sudo apt-get install -y software-properties-common		# for cmd add-apt-repository 
	sudo apt-get install -y git subversion mercurial		# dev tools
	sudo apt-get install -y tmux terminator autossh w3m		# dev tools
	sudo apt-get install -y debconf-utils				# help auto select when install software (like mysql, wine, etc)
	sudo apt-get install -y linux-headers-`uname -r`		# for what?
fi

if [ $(echo "$sys_info" | grep -ic "ubuntu.*desktop") == 1 ] ; then
	echo "INFO: installing software for ubuntu (desktop)"

	sudo add-apt-repository -y ppa:alexx2000/doublecmd		# double commander
	sudo add-apt-repository -y ppa:tualatrix/ppa			# ubuntu tweak stable
	sudo add-apt-repository -y ppa:ubuntu-wine/ppa			# wine1.5
	sudo add-apt-repository -y ppa:byobu/ppa			# byobu
	#sudo add-apt-repository -y ppa:videolan/stable-daily		# vlc, could use official
	#sudo apt-get update						# should update since added ppa, disable in debug mode, as just need run it once manually

	sudo apt-get install -y xrdp                                    # for win connect to LU, support connection from MS Remote Desktop Client(mstsc) or VNC Viewer (RealVNC)                                                             
	sudo apt-get install -y rdesktop                                # for LU connect to win
	sudo apt-get install -y ibus-table-wubi				# sudo vi /usr/share/ibus-table/engine/table.py (set "self._chinese_mode = 2", them set hotkey and select input method in ibus preference)
	sudo apt-get install -y virtualbox vim-gnome
	sudo apt-get install -y doublecmd-gtk byobu
	sudo apt-get install -y ubuntu-tweak vlc autokey gitk wmctrl 

	if (( $(dpkg -l | grep -c "google.*chrome") >= 1 )) ; then
		sudo apt-get install -y libnspr4-0d libcurl3		# for chrome 
		rm -f /tmp/${chrome_stable##*/} 
		wget ${chrome_stable} -O /tmp/${chrome_stable##*/}
		sudo dpkg -i /tmp/${chrome_stable##*/}			# will show error on ubuntu desktop 12.04
		if [ "$?" -ne 0 ] ; then sudo apt-get -f install; fi	# if error happen, this will force to install
	fi

	sudo apt-get install -y wine1.5					# TODO: this need maual work comfirm, learn the auto way from the mysql init script
fi

if [ $(echo "$sys_info" | grep -ic "ubuntu.*precise") == 1 ] ; then
	# simply add the PPA can not install the latest version
	wget https://launchpad.net/~cdekter/+archive/ppa/+files/autokey-common_0.90.4-0~precise_all.deb
	wget https://launchpad.net/~cdekter/+archive/ppa/+files/autokey-qt_0.90.4-0~precise_all.deb
	sudo apt-get remove autokey
	sudo apt-get install -y gdebi-core
	sudo gdebi --n autokey-qt_0.90.4-0~precise_all.deb autokey-common_0.90.4-0~precise_all.deb
	sudo apt-get install python-qt4-dbus
	sudo dpkg -i autokey-qt_0.90.4-0~precise_all.deb autokey-common_0.90.4-0~precise_all.deb 
fi

# Autokey, TODO: seems not necessary, check if this is really used
#if grep -q 'Autokey' <(echo `gsettings get com.canonical.Unity.Panel systray-whitelist`); then 
#	echo "'Autokey' exists in Unity panel whitelist. Nothing to do here." ; 
#else  
#	echo "Adding 'Autokey' to Unity panel whitelist." ; 
#	gsettings set com.canonical.Unity.Panel systray-whitelist "`echo \`gsettings get com.canonical.Unity.Panel systray-whitelist | tr -d ]\`,\'Autokey\']`";  
#fi