#!/bin/bash

#TOOD: update sudoer file
#TOOD: if Doc link made, will exlt

#TODO: investigate ubuntu tweak
#TODO: investigate MyUnity

# Common Variable
tmp_init_dir=/tmp/os_init/`date "+%Y%m%d_%H%M%S"`

# Common Init
mkdir -p $tmp_init_dir

# Functions
function func_init_dir {
	mkdir -p ~/amp/download ~/amp/backup ~/amp/delete
}

function func_init_sudoer {
	echo ">>> INIT `date "+%H:%M:%S"`: update /etc/sudoers password setting"

	sudoers=/etc/sudoers
	sudoers_bak=${sudoers}.bak
	[ -e $sudoers_bak ] && echo "$sudoers_bak already exist, skip" && return 0

	sudo cp $sudoers $sudoers_bak
	sudo sed -i '/%sudo/s/(ALL:ALL)/NOPASSWD:/' $sudoers
}

function func_init_apt_update_src {
	apt_source_list=/etc/apt/sources.list
	apt_source_list_bak=${apt_source_list}.bak

	echo ">>> INIT `date "+%H:%M:%S"`: update $apt_source_list"
	
	[ -e $apt_source_list_bak ] && echo "$apt_source_list_bak already exist, skip" && return 0
	sudo cp $apt_source_list $apt_source_list_bak
	sudo sed -i -e "/ubuntu.com/p;s/[^\/]*\.ubuntu\.com/mirrors.163.com/" $apt_source_list
}

function func_init_apt_update_list {
	# TODO: if ppa updated, this need be forced, how to?

	echo ">>> INIT `date "+%H:%M:%S"`: apt update software list"

	apt_update_stamp=/var/lib/apt/periodic/update-success-stamp
	apt_update_stamp2=/tmp/update-success-stamp

	[ ! -e $apt_update_stamp2 ] && touch -t 197101020304 $apt_update_stamp2
	last_update=$(( `date +%s` - `stat -c %Y $apt_update_stamp` ))
	last_update2=$(( `date +%s` - `stat -c %Y $apt_update_stamp2` ))

	[ -e $apt_update_stamp ] && (( $last_update > 86400 ))				&& \
	[ -e $apt_update_stamp2 ] && (( $last_update2 > 86400 ))			&& \
	echo "updating apt source list..."						&& \
	sudo apt-get update -qq && touch $apt_update_stamp2				|| \
	echo "last update was ${last_update}/${last_update2} seconds ago, skip..."
}

function func_init_link_doc {
	home_doc_path="$HOME/Documents"
	echo ">>> INIT `date "+%H:%M:%S"`: setup links $home_doc_path"

	[ -e $home_doc_path -a -h $home_doc_path ] && echo "$home_doc_path link already exist, skip" && return 0
	(( `ls $home_doc_path 2>/dev/null | wc -l` != 0 )) && echo "$home_doc_path is not empty, pls check!" && return 0

	[ -d $home_doc_path ] && rmdir $home_doc_path
	ext_doc_path=`find /ext/ -maxdepth 3 -type d -name "Documents"`
	(( `echo $ext_doc_path | wc -l` == 1 ))	|| echo "Failed to find Documents dir in /ext, exit!" && exit 1
	ln -s $ext_doc_path $home_doc_path
}

function func_init_link_dev {
	home_dev_path="$HOME/dev"
	echo ">>> INIT `date "+%H:%M:%S"`: setup links $home_dev_path"

	[ -e $home_dev_path -a -h $home_dev_path ] && echo "dev link already exist, skip" && return 0

	ext_doc_path=`find /ext/ -maxdepth 3 -type d -name "Documents"`
	ln -s $ext_doc_path/os_spec_lu/dev $home_dev_path
}

function func_init_link_pro {
	home_pro_path="$HOME/program"
	echo ">>> INIT `date "+%H:%M:%S"`: setup links $home_pro_path"

	[ -e $home_pro_path -a -h $home_pro_path ] && echo "$home_pro_path link already exist, skip" && return 0

	ext_doc_path=`find /ext/ -maxdepth 3 -type d -name "Documents"`
	ln -s $ext_doc_path/os_spec_lu/program $home_pro_path
}

function func_init_myenv_rw {
	echo ">>> INIT `date "+%H:%M:%S"`: update myenv, support read and write"

	myenv_init_rw=$tmp_init_dir/myenv.rw.LU.sh
	myenv_init_rw_url=https://raw.github.com/stico/myenv/master/.myenv/init/myenv.rw.LU.sh 

	[ ! -e "$myenv_init_rw" ] && echo "downloading $myenv_init_rw_url" && wget -O $myenv_init_rw -q $myenv_init_rw_url
	[ ! -e "$myenv_init_rw" ] && echo "$myenv_init_rw not found, init myenv failed!" && exit 1
	bash $myenv_init_rw $tmp_init_dir
}

function func_init_soft_gui {
	[ -z "$DISPLAY" ] && echo ">>> INIT `date "+%H:%M:%S"`: seems non-gui os, will not install soft works in gui" && return 0

	echo ">>> INIT `date "+%H:%M:%S"`: install software that works in gui"
	
	sudo apt-get install -y vlc rdesktop				> /dev/null

	#TODO - should update config together!
	#sudo apt-get install -y doublecmd-gtk byobu
}

function func_init_soft_ppa {
	echo ">>> INIT `date "+%H:%M:%S"`: add ppa for latest software"

	sudo add-apt-repository -y ppa:gnome-terminator			> /dev/null	# terminator
}

function func_init_soft_termial {
	echo ">>> INIT `date "+%H:%M:%S"`: install software, usable in terminal"

	sudo apt-get install -y zip unzip expect unison openssh-server 	> /dev/null	# basic tools
	sudo apt-get install -y aptitude				> /dev/null	# basic tools
	sudo apt-get install -y build-essential make gcc cmake		> /dev/null	# build tools
	sudo apt-get install -y samba smbfs				> /dev/null	# samba
	sudo apt-get install -y python-software-properties		> /dev/null	# for cmd add-apt-repository 
	sudo apt-get install -y software-properties-common		> /dev/null	# for cmd add-apt-repository 
	sudo apt-get install -y git subversion mercurial		> /dev/null	# dev tools
	sudo apt-get install -y tmux terminator autossh w3m		> /dev/null	# dev tools
	sudo apt-get install -y debconf-utils				> /dev/null	# help auto select when install software (like mysql, wine, etc)
	sudo apt-get install -y linux-headers-`uname -r` > /dev/null	> /dev/null	# some soft compile need this

}

function func_init_soft_basic {
	echo ">>> INIT `date "+%H:%M:%S"`: install basic softwares, aptitude/zip/unzip/linux-headers, etc"

	sudo apt-get install -y aptitude > /dev/null
	sudo apt-get install -y zip unzip > /dev/null
	sudo apt-get install -y linux-headers-`uname -r` > /dev/null	# some soft compile need this

	#(! command -v aptitude &> /dev/null) && echo "install aptitude failed, pls check!" && exit 1
}


# Init - basic
func_init_dir
func_init_sudoer
func_init_soft_ppa
func_init_soft_basic
func_init_apt_update_src
func_init_apt_update_list

# Init - myenv
func_init_link_doc
func_init_link_dev
func_init_link_pro
func_init_myenv_rw

# Init - soft
func_init_soft_gui
func_init_soft_termial

exit


# Variables
chrome_stable='https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb'
apt_source=/etc/apt/sources.list

# Pre-condition/pre-work
[ ! -e ~/.myenv/env_func_bash ] && echo "ERROR: .myenv not exist !" && exit 1
(( $(grep -c "http://cn" $apt_source) < 1 )) && echo "ERROR: $apt_source are using non 'http://cn' sources!" && exit 1
. ~/.myenv/env_func_bash


# Installations
sys_info=`func_sys_info`

if [ $(echo "$sys_info" | grep -ic "ubuntu.*desktop") == 1 ] ; then
	echo "INFO: installing software for ubuntu (desktop)"

	sudo add-apt-repository -y ppa:alexx2000/doublecmd		# double commander
	sudo add-apt-repository -y ppa:tualatrix/ppa			# ubuntu tweak stable
	sudo add-apt-repository -y ppa:ubuntu-wine/ppa			# wine1.5
	sudo add-apt-repository -y ppa:byobu/ppa			# byobu
	#sudo apt-get update						# should update since added ppa, disable in debug mode, as just need run it once manually

	sudo apt-get install -y xrdp					# OS with X, xrdp supports windows native remote desktop connection
	sudo apt-get install -y ibus-table-wubi				# sudo vi /usr/share/ibus-table/engine/table.py (set "self._chinese_mode = 2", them set hotkey and select input method in ibus preference)
	sudo apt-get install -y vim-gnome
	sudo apt-get install -y ubuntu-tweak autokey gitk wmctrl 

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

# Deprecated
#sudo add-apt-repository -y ppa:videolan/stable-daily		# vlc, could use official
#sudo apt-get install -y virtualbox vim-gnome
