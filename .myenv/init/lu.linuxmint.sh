#!/bin/bash

# Command: rm /tmp/lu.linuxmint.sh ; wget -O /tmp/lu.linuxmint.sh -q https://raw.github.com/stico/myenv/master/.myenv/init/lu.linuxmint.sh && bash /tmp/lu.linuxmint.sh 
# Verified: LM 13 (2013-04-16), but updated after that
# Verified: LM 15 (2013-07-16), only not found smbfs to install

#TODO: all > /dev/null to log file instead, "tee -a" will be useful
#TODO: investigate ubuntu tweak
#TODO: investigate MyUnity

# Common Variable
tmp_init_dir=/tmp/os_init/`date "+%Y%m%d_%H%M%S"`

# Functions
function func_pre_check {
	# use exit here!

	[ ! -e /ext/ ] && echo "ERROR: /ext not exist, pls check!" && exit 1
	[ "`whoami`" != "ouyangzhu" ] && echo "ERROR: username is not ouyangzhu, pls check!" && exit 1
}

function func_init_dir {
	sudo chown -R ouyangzhu:ouyangzhu /ext/ 

	mkdir -p $tmp_init_dir
	mkdir -p /ext/home_data/Documents
	mkdir -p ~/amp/download ~/amp/backup ~/amp/delete
	
	home_doc=$HOME/Documents
	[ ! -h $home_doc ] && rmdir $home_doc &> /dev/null && ln -s /ext/home_data/Documents $home_doc
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

#function func_init_link_doc {
#	home_doc_path="$HOME/Documents"
#	echo ">>> INIT `date "+%H:%M:%S"`: setup links $home_doc_path"
#
#	[ -e $home_doc_path -a -h $home_doc_path ] && echo "$home_doc_path link already exist, skip" && return 0
#	(( `ls $home_doc_path 2>/dev/null | wc -l` != 0 )) && echo "$home_doc_path is not empty, pls check!" && return 0
#
#	[ -d $home_doc_path ] && rmdir $home_doc_path
#	ext_doc_path=`find /ext/ -maxdepth 3 -type d -name "Documents"`
#	(( `echo $ext_doc_path | wc -l` == 1 ))	|| echo "Failed to find Documents dir in /ext, skip!" || return 1
#	ln -s $ext_doc_path $home_doc_path
#}
#
#function func_init_link_dev {
#	home_dev_path="$HOME/dev"
#	echo ">>> INIT `date "+%H:%M:%S"`: setup links $home_dev_path"
#
#	[ -e $home_dev_path -a -h $home_dev_path ] && echo "$home_dev_path link already exist, skip" && return 0
#	(( `ls $home_dev_path 2>/dev/null | wc -l` != 0 )) && echo "$home_dev_path is not empty, pls check!" && return 0
#
#	ext_doc_path=`find /ext/ -maxdepth 3 -type d -name "Documents"`
#	(( `echo $ext_doc_path | wc -l` == 1 ))	|| echo "Failed to find Documents dir in /ext, skip!" || return 1
#	ln -s $ext_doc_path/os_spec_lu/dev $home_dev_path
#}
#
#function func_init_link_pro {
#	home_pro_path="$HOME/program"
#	echo ">>> INIT `date "+%H:%M:%S"`: setup links $home_pro_path"
#
#	[ -e $home_pro_path -a -h $home_pro_path ] && echo "$home_pro_path link already exist, skip" && return 0
#	(( `ls $home_pro_path 2>/dev/null | wc -l` != 0 )) && echo "$home_pro_path is not empty, pls check!" && return 0
#
#	ext_doc_path=`find /ext/ -maxdepth 3 -type d -name "Documents"`
#	(( `echo $ext_doc_path | wc -l` == 1 ))	|| echo "Failed to find Documents dir in /ext, skip!" || return 1
#	ln -s $ext_doc_path/os_spec_lu/program $home_pro_path
#}

function func_init_link {
	target_path="$HOME/$1"
	echo ">>> INIT `date "+%H:%M:%S"`: setup link $target_path"

	[ -e $target_path -a -h $target_path ] && echo "$target_path link already exist, skip" && return 0
	(( `ls $target_path 2>/dev/null | wc -l` != 0 )) && echo "$target_path is not empty, pls check!" && return 0

	ext_doc_path=`find /ext/ -maxdepth 3 -type d -name "Documents"`
	[ ! -e "$ext_doc_path" ] && echo "Failed to find Documents dir in /ext, skip!" && return 1

	[ -n "$2" ] && sub_path=/$2
	ln -s ${ext_doc_path}${sub_path} $target_path
}

function func_init_myenv_rw {
	echo ">>> INIT `date "+%H:%M:%S"`: update myenv, support read and write"

	myenv_init_rw=$tmp_init_dir/myenv.rw.LU.sh
	myenv_init_rw_url=https://raw.github.com/stico/myenv/master/.myenv/init/myenv.rw.LU.sh 

	[ ! -e "$myenv_init_rw" ] && echo "downloading $myenv_init_rw_url" && wget -O $myenv_init_rw -q $myenv_init_rw_url
	[ ! -e "$myenv_init_rw" ] && echo "$myenv_init_rw not found, init myenv failed!" && return 1
	bash $myenv_init_rw $tmp_init_dir
}

function func_init_soft_manual_needed {
	echo "Now need install soft with manual op (like accept agreement), continue (N) [Y/N]?"
	read -e continue                                                                                           
	[ "$continue" != "Y" -a "$continue" != "y" ] && echo "Give up, pls install those soft manually later!" && return 1
}

function func_init_soft_gui {
	# TODO - to learn
		#func_add_apt_repo ppa:tualatrix/ppa					# ubuntu tweak stable
		#sudo apt-get install -y ubuntu-tweak			> /dev/null	# not test yet
	# TODO - (2013-05) auto key is conflict with terminator, try manually
		#sudo apt-get install -y autokey autokey gitk wmctrl 	> /dev/null
	# TODO - should update config together!
		#sudo apt-get install -y doublecmd-gtk byobu

	[ -z "$DISPLAY" ] && echo ">>> INIT `date "+%H:%M:%S"`: seems non-gui os, will not install soft works in gui" && return 0

	echo ">>> INIT `date "+%H:%M:%S"`: install software that works in gui"
	
	sudo apt-get install -y xrdp rdesktop			> /dev/null	# xrdp: supports windows native remote desktop connection. rdesktop: use to connect to remote desktop (including windows)
	sudo apt-get install -y ibus-table-wubi			> /dev/null	# sudo vi /usr/share/ibus-table/engine/table.py (set "self._chinese_mode = 2", them set hotkey and select input method in ibus preference)
	sudo apt-get install -y vlc byobu			> /dev/null	# byobu is a better tmux

	# Virtualbox
	sudo apt-get install -y virtualbox-nonfree
	sudo apt-get install -y virtualbox-guest-additions-iso
	sudo usermod -a -G vboxusers ouyangzhu			# for functions like USB to work correctly

	# Terminator
	terminator_conf=~/.config/terminator
	terminator_conf_me=$MY_ENV/conf/terminator
	[ -e $terminator_conf_me -a ! -e $terminator_conf ] && ln -s $terminator_conf_me $terminator_conf
	sudo apt-get install -y terminator			> /dev/null	# dev tools
	
	# Chrome
	if (( $(dpkg -l | grep -c "google.*chrome") <= 0 )) ; then
		chrome_url='https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb'
		chrome_tmp=/tmp/${chrome_url##*/} 

		[ $(netstat -an | grep ":1984.*LISTEN" | wc -l) -ge 1 ] && export http_proxy="127.0.0.1:1984" && export https_proxy="127.0.0.1:1984"

		sudo apt-get install -y libnspr4-0d libcurl3	> /dev/null	# for chrome 
		rm -f $chrome_tmp
		wget ${chrome_url} -O $chrome_tmp 
		[ -e $chrome_tmp ] && sudo dpkg -i $chrome_tmp		# will show error on ubuntu desktop 12.04
		[ -e $chrome_tmp ] && [ "$?" -ne 0 ] && sudo apt-get -f install			# if error happen, this will force to install
	fi
}

function func_add_apt_repo {
	apt_repo=$1

	# all added ppa could be found in /etc/apt/sources.list.d/ 
	[ $(ls /etc/apt/sources.list.d/ | grep -c ${apt_repo##*:}) -ge 1 ] && echo "INFO: $apt_repo already added, skip" && return 0

	sudo add-apt-repository -y $apt_repo			&> /dev/null
}

function func_init_apt_update_ppa {
	echo ">>> INIT `date "+%H:%M:%S"`: add ppa for latest software"

	sudo apt-get install -y python-software-properties	> /dev/null	# for cmd add-apt-repository 
	sudo apt-get install -y software-properties-common	> /dev/null	# for cmd add-apt-repository 

	func_add_apt_repo ppa:gnome-terminator
	func_add_apt_repo ppa:alexx2000/doublecmd				# double commander
	func_add_apt_repo ppa:byobu/ppa						# byobu
}

function func_init_soft_termial {
	echo ">>> INIT `date "+%H:%M:%S"`: install software, usable in terminal"

	sudo apt-get install -y expect unison openssh-server 	> /dev/null	# basic tools
	sudo apt-get install -y build-essential make gcc cmake	> /dev/null	# build tools
	sudo apt-get install -y samba smbfs			> /dev/null	# samba
	sudo apt-get install -y git subversion mercurial	> /dev/null	# dev tools
	sudo apt-get install -y tmux autossh w3m		> /dev/null	# dev tools
	sudo apt-get install -y debconf-utils			> /dev/null	# help auto select when install software (like mysql, wine, etc)
}

function func_init_soft_basic {
	echo ">>> INIT `date "+%H:%M:%S"`: install basic softwares, aptitude/zip/unzip/linux-headers, etc"

	sudo apt-get -y dist-upgrade				> /dev/null

	sudo apt-get install -y dkms
	sudo apt-get install -y aptitude			> /dev/null
	sudo apt-get install -y openssh-server			> /dev/null
	sudo apt-get install -y zip unzip			> /dev/null
	sudo apt-get install -y linux-headers-`uname -r`	> /dev/null	# some soft compile need this

	#(! command -v aptitude &> /dev/null) && echo "install aptitude failed, pls check!" && exit 1
}

function func_config_gnome_keying {
	# without this, will get error like "WARNING: gnome-keyring:: couldn't connect to: /tmp/keyring-WtN6AD/pkcs11: No such file or directory"
	dt_type=XFCE
	gnome_keying_desktop=/etc/xdg/autostart/gnome-keyring-pkcs11.desktop
	[ ! -e ${gnome_keying_desktop}.bak ] && sudo cp ${gnome_keying_desktop}{,.bak}
	if [ $(grep -c "OnlyShowIn=.*${dt_type}" $gnome_keying_desktop) -lt 1 ] ; then 
		sudo sed -i -e "s/^\(OnlyShowIn=\)\(.*\)/\1${dt_type};\2/" $gnome_keying_desktop 
	else 
		echo "INFO: $gnome_keying_desktop already contains $dt_type, ignore"
	fi
}

# Init - pre conditions
func_pre_check 

# Init - basic
func_init_dir
func_init_sudoer
func_init_apt_update_src
func_init_apt_update_ppa
func_init_apt_update_list
func_init_soft_basic

# Init - myenv
func_init_link dev os_spec_lu/dev
func_init_link program os_spec_lu/program 
#func_init_link_doc
#func_init_link_dev
#func_init_link_pro
func_init_myenv_rw

# Init - soft
func_init_soft_gui
func_init_soft_termial

# Init - config
func_config_gnome_keying

# Last - manual stuff
func_init_soft_manual_needed

exit

################################################################################
(logout and login)
################################################################################

# Variables
apt_source=/etc/apt/sources.list

# Installations
sys_info=`func_sys_info`

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
#sudo apt-get install -y virtualbox
#sudo apt-get install -y vim-gnome
