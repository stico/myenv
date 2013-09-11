#!/bin/bash

# Command: rm /tmp/lu.linuxmint.sh ; wget -O /tmp/lu.linuxmint.sh -q https://raw.github.com/stico/myenv/master/.myenv/init/lu.linuxmint.sh && bash /tmp/lu.linuxmint.sh 
# Verified: LM 13 (2013-04-16), but updated after that
# Verified: LM 15 (2013-07-16), only not found smbfs to install

#TODO: all >> $tmp_init_log to log file instead, "tee -a" will be useful
#TODO: investigate ubuntu tweak
#TODO: investigate MyUnity

# Common Variable
tmp_init_dir=/tmp/os_init/`date "+%Y%m%d_%H%M%S"`
tmp_init_log=/tmp/os_init/`date "+%Y%m%d_%H%M%S"`/init.log

# Functions - Util
function func_dati {
	date "+%Y-%m-%d_%H-%M-%S"
}

function func_bak_file {
	usage="Usage: $FUNCNAME [filename]"
	[ $# -lt 1 ] && echo $usage && return 1

	[ ! -e "${1}" ] && echo "ERROR: $1 not exist" && exit 1
	[ -d "${1}" ] && echo "ERROR: $1 is a directory" && exit 1
	
	target=${1}.bak_$(func_dati)
	[ -w "$(dirname ${1})" ] && cp "$1" $target || sudo cp "$1" $target 
}

function func_bak_file_virgin {
	usage="Usage: $FUNCNAME [filename]"
	[ $# -lt 1 ] && echo $usage && return 1

	sudo ls ${1}.bak* &> /dev/null && echo "backup already exist for ${1}, skip" && return 1
	func_bak_file ${1}
}

# Functions - Action
function func_pre_check {
	echo ">>> INIT `date "+%H:%M:%S"`: pre condition check"

	# use exit here!
	[ ! -e /ext/ ] && echo "ERROR: /ext not exist, pls check!" && exit 1
	[ "`whoami`" != "ouyangzhu" ] && echo "ERROR: username is not ouyangzhu, pls check!" && exit 1
}

function func_init_dir_temp {
	mkdir -p $tmp_init_dir
}

function func_init_dir_home {
	echo ">>> INIT `date "+%H:%M:%S"`: init basic directories"

	# Ensure /ext owner
	expect_owner=ouyangzhu:ouyangzhu
	real_owner=`ls -l / | sed -e "/->/d" | grep ext | awk '{print $3":"$4}'`
	[ "$real_owner" != "$expect_owner" ] && sudo chown -R $expect_owner /ext/ 

	home_data=$HOME/data
	home_doc=$HOME/Documents
	ext_home_data=/ext/home_data/data
	ext_home_doc=/ext/home_data/Documents

	mkdir -p $ext_home_doc $ext_home_data
	mkdir -p ~/amp/download ~/amp/backup ~/amp/delete
	
	[ ! -e "$ext_home_doc" ] && echo "ERROR: $ext_home_doc not exist!" && exit 1
	[ ! -e "$ext_home_data" ] && echo "ERROR: $ext_home_data not exist!" && exit 1
	[ ! -h "$home_doc" ] && rmdir $home_doc &>> $tmp_init_log && ln -s $ext_home_doc $home_doc
	[ ! -h "$home_data" ] && rmdir $home_data &>> $tmp_init_log && ln -s $ext_home_data $home_doc
}

function func_init_sudoer {
	echo ">>> INIT `date "+%H:%M:%S"`: update /etc/sudoers password setting"

	sudoers=/etc/sudoers
	func_bak_file_virgin ${sudoers} || return 0

	sudo sed -i '/%sudo/s/(ALL:ALL)/NOPASSWD:/' $sudoers
}

function func_init_config_xfce_app {
	echo ">>> INIT `date "+%H:%M:%S"`: update XFCE applications config"

	source_path=~/.myenv/conf/xfce/applications/
	target_path=~/.local/share/applications/
	func_bak_file_virgin ${target_path}/defaults.list || return 0
	mv -f ${target_path}/defaults.list /tmp/
	cp $source_path/* $target_path/* >> $tmp_init_log
}

function func_init_config_xfce_wm {
	echo ">>> INIT `date "+%H:%M:%S"`: update XFCE config"

	target_path=~/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml
	func_bak_file_virgin ${target_path} || return 0

	sed -i -e '/workspace_count/s/value="."/value="1"/' $target_path
}

function func_init_config_xfce_key {
	echo ">>> INIT `date "+%H:%M:%S"`: update XFCE key config"

	source_path=~/.myenv/conf/xfce/xfce4-keyboard-shortcuts.xml
	target_path=~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml
	func_bak_file_virgin ${target_path} || return 0
	mv -f $target_path /tmp/
	cp $source_path $target_path >> $tmp_init_log
	
	# without this, the Tab key not work in xrdp connection
	#sed -i -e 's/Tab.*switch_window_key/Tab" type="empty/' $config_keys 
}

function func_init_config_xfce_keyring {
	# without this, will get error like "WARNING: gnome-keyring:: couldn't connect to: /tmp/keyring-WtN6AD/pkcs11: No such file or directory"
	dt_type=XFCE
	gnome_keying_desktop=/etc/xdg/autostart/gnome-keyring-pkcs11.desktop
	func_bak_file_virgin ${gnome_keying_desktop} || return 0

	if [ $(grep -c "OnlyShowIn=.*${dt_type}" $gnome_keying_desktop) -lt 1 ] ; then 
		sudo sed -i -e "s/^\(OnlyShowIn=\)\(.*\)/\1${dt_type};\2/" $gnome_keying_desktop 
	else 
		echo "INFO: $gnome_keying_desktop already contains $dt_type, ignore"
	fi
}

function func_init_config_xfce {
	func_init_config_xfce_wm
	func_init_config_xfce_app
	func_init_config_xfce_key
	func_init_config_xfce_keyring

	echo " NOTE: update XFCE shortscuts need restart to take effect!"
}

function func_init_apt_update_src {
	src_files=( /etc/apt/sources.list /etc/apt/sources.list.d/official-package-repositories.list )

	for src_file in "${src_files[@]}"; do 
		echo ">>> INIT `date "+%H:%M:%S"`: update $src_file"
		func_bak_file_virgin $src_file || return 0
		sudo sed -i -e "/ubuntu.com/p;s/[^\/]*\.ubuntu\.com/mirrors.163.com/" $src_file
	done
}

function func_init_apt_upgrade {
	echo ">>> INIT `date "+%H:%M:%S"`: apt upgrade"

	apt_upgrade_stamp=/tmp/apt-upgrade-success-stamp
	[ ! -e $apt_upgrade_stamp ] && touch -t 197101020304 $apt_upgrade_stamp

	last_stamp=$(( `date +%s` - `stat -c %Y $apt_upgrade_stamp` ))

	[ -e $apt_update_stamp ] && (( $last_stamp > 86400 ))				&& \
	sudo apt-get -y dist-upgrade >> $tmp_init_log && touch $apt_update_stamp	|| \
	echo "last update was ${last_stamp} seconds ago, skip..."
}

function func_init_apt_update_list {
	# TODO: if ppa updated, this need be forced, how to?
	echo ">>> INIT `date "+%H:%M:%S"`: apt update software list"

	apt_update_stamp=/tmp/apt-update-success-stamp
	[ ! -e $apt_update_stamp ] && touch -t 197101020304 $apt_update_stamp

	last_stamp=$(( `date +%s` - `stat -c %Y $apt_update_stamp` ))

	[ -e $apt_update_stamp ] && (( $last_stamp > 86400 ))				&& \
	echo "updating apt source list..."						&& \
	sudo apt-get update -qq >> $tmp_init_log && touch $apt_update_stamp		|| \
	echo "last update was ${last_stamp} seconds ago, skip..."
}

function func_init_link {
	target_path="$HOME/$1"
	echo ">>> INIT `date "+%H:%M:%S"`: setup link $target_path"

	[ -e $target_path -a -h $target_path ] && echo "$target_path link already exist, skip" && return 0
	(( `ls $target_path 2>> $tmp_init_log | wc -l` != 0 )) && echo "$target_path is not empty, pls check!" && return 0

	ext_doc_path=`find /ext/ -maxdepth 3 -type d -name "Documents"`
	[ ! -e "$ext_doc_path" ] && echo "Failed to find Documents dir in /ext, skip!" && return 1

	[ -n "$2" ] && sub_path=/$2
	ln -s ${ext_doc_path}${sub_path} $target_path
}

function func_init_myenv_rw {
	echo ">>> INIT `date "+%H:%M:%S"`: update myenv, support read and write"

	[ -e "$MY_ENV/init/myenv.rw.LU.sh" ] && echo "$MY_ENV/init/myenv.rw.LU.sh already exist, skip" && return 0

	myenv_init_rw=$tmp_init_dir/myenv.rw.LU.sh
	myenv_init_rw_url=https://raw.github.com/stico/myenv/master/.myenv/init/myenv.rw.LU.sh 

	[ ! -e "$myenv_init_rw" ] && echo "downloading $myenv_init_rw_url" && wget -O $myenv_init_rw -q $myenv_init_rw_url
	[ ! -e "$myenv_init_rw" ] && echo "$myenv_init_rw not found, init myenv failed!" && return 1
	bash $myenv_init_rw $tmp_init_dir
}

function func_init_soft_manual_infinality {
	echo ">>> INIT `date "+%H:%M:%S"`: install infinality which improve font rendering, need some mannal check, pls install it manually"

	setting_file=/etc/infinality-settings.sh
	[ -e "$setting_file" ] && echo "$setting_file already exist" && return 0

	# Note 1: this is for better font rendering, seems really better
	# Note 2: (On linuxmint 15 XFCE), after this need startx manually, following cmd after apt-get install is doing this
	#         Also make sure this line is in .bashrc: [ -e /etc/infinality-settings.sh ] && . /etc/infinality-settings.sh
	sudo add-apt-repository -y ppa:no1wantdthisname/ppa
	sudo apt-get update
	sudo apt-get upgrade
	sudo apt-get install fontconfig-infinality
	sudo mv /etc/profile.d/infinality-settings.sh $setting_file
	sudo chmod a+rx /etc/infinality-settings.sh

	echo "Need logout to take effect, logout (N) [Y/N]?"
	read -e continue                                                                                           
	[ "$continue" != "Y" -a "$continue" != "y" ] && echo "Give up, pls logout and login later" && return 1
	( command -v xfce4-session-logout &> /dev/null ) && xfce4-session-logout --logout
	( command -v gnome-session-quit &> /dev/null ) && gnome-session-quit
	# what command for kde?
} 

function func_init_soft_manual_needed {
	echo ">>> INIT `date "+%H:%M:%S"`: Following steps need manual op (like set password, accept agreement), continue (N) [Y/N]?"
	read -e continue                                                                                           
	[ "$continue" != "Y" -a "$continue" != "y" ] && echo "Give up, pls install those soft manually later!" && return 1

	echo " add a backup user, remember to change its password which already have record!"
	(( `grep -c "^ouyangzhu2:" /etc/passwd` >= 1 )) && sudo useradd -m -s /bin/bash -g sudo ouyangzhu2 && sudo passwd ouyangzhu2

	func_init_soft_manual_infinality

	# Need comfirm the dialog
	#sudo apt-get install -y --force-yes ttf-mscorefonts-installer
}

function func_init_soft_gui {
	# TODO - to learn
		#func_add_apt_repo ppa:tualatrix/ppa					# ubuntu tweak stable
		#sudo apt-get install -y ubuntu-tweak			>> $tmp_init_log	# not test yet
	# TODO - (2013-05) auto key is conflict with terminator, try manually
		#sudo apt-get install -y autokey autokey gitk wmctrl 	>> $tmp_init_log
	# TODO - should update config together!
		#sudo apt-get install -y doublecmd-gtk byobu

	# TODO ! this not works, caused a ubuntu server version installed gui stuff
	[ -z "$DISPLAY" ] && echo ">>> INIT `date "+%H:%M:%S"`: seems non-gui os, will not install soft works in gui" && return 0

	echo ">>> INIT `date "+%H:%M:%S"`: install software that works in gui"
	
	sudo apt-get install -y xrdp rdesktop			>> $tmp_init_log	# xrdp: supports windows native remote desktop connection. rdesktop: use to connect to remote desktop (including windows)
	sudo apt-get install -y vlc byobu			>> $tmp_init_log	# byobu is a better tmux
	sudo apt-get install -y bum             		>> $tmp_init_log	# boot-up-manager
	sudo apt-get install -y arandr             		>> $tmp_init_log	# set the screen layout, e.g for dual screen

	# For LM 15, for logitech usb headset, use "PulseAudio Volume Control" to control the device
	sudo apt-get install -y pulseaudio pulseaudio-utils	>> $tmp_init_log
	sudo apt-get install -y pavucontrol			>> $tmp_init_log

	# Chinese Input Method - Fcitx
	sudo apt-get install -y fcitx-table-wbpy		>> $tmp_init_log

	# Fonts
	font_sys=/usr/share/fonts/fontfiles
	font_home=/ext/home_data/Documents/DCB/SoftwareConf/Font/
	if [ -d "$font_home" ] ; then
		sudo mkdir -p $font_sys	&> /dev/null
		[ ! -e "$font_sys/XHei.TTC" ] && sudo cp $font_home/XHei.TTC $font_sys		# for vim 
		[ ! -e "$font_sys/MSYHMONO.ttf" ] && sudo cp $font_home/MSYHMONO.ttf $font_sys
		sudo chmod -R 755 $font_sys
		fc-cache -fv					>> $tmp_init_log		# update fonts 
	fi

	# Chinese Input Method - Ibus
	# Still need: manual part: 1) add to autostart, use the /usr/bin/ibus-daemon. 2) set hotkey and in ibus preference 3) select input method in ibus preference
	ibus_table=/usr/share/ibus-table/engine/table.py
	sudo apt-get install -y ibus-table-wubi			>> $tmp_init_log	
	func_bak_file_virgin $ibus_table && sudo sed -i -e '/self._chinese_mode.*=.*get_value.*/,/))/{s/self._chinese_mode.*=.*/self._chinese_mode = 2/;/self._chinese_mode.*=.*/!d;}' $ibus_table

	# Virtualbox, the command will reinstall+install virtualbox, need to avoid
	if ( ! command -v virtualbox &> /dev/null ) ; then
		sudo apt-get install -y virtualbox-nonfree
		sudo apt-get install -y virtualbox-guest-additions-iso
		sudo usermod -a -G vboxusers ouyangzhu			# for functions like USB to work correctly
	fi

	# clipit
	sudo apt-get install -y clipit				>> $tmp_init_log
	[ ! -e ~/.config/clipit ] && ln -s ~/.myenv/conf/clipit ~/.config/clipit

	# Terminator
	terminator_conf=~/.config/terminator
	terminator_conf_me=$MY_ENV/conf/terminator
	[ -e $terminator_conf_me -a ! -e $terminator_conf ] && ln -s $terminator_conf_me $terminator_conf
	sudo apt-get install -y terminator			>> $tmp_init_log	# dev tools
	
	# Chrome
	if (( $(dpkg -l | grep -c "google.*chrome") <= 0 )) ; then
		chrome_url='https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb'
		chrome_tmp=/tmp/${chrome_url##*/} 
		chrome_local=`find ~/Documents/ECS/chrome -name "*chrome*deb" -type f | tail -1`

		# try to use proxy 
		[ $(netstat -an | grep ":1984.*LISTEN" | wc -l) -ge 1 ] && export http_proxy="127.0.0.1:1984" && export https_proxy="127.0.0.1:1984"

		# install dependency
		sudo apt-get install -y libnspr4-0d libcurl3	>> $tmp_init_log	# for chrome 

		# download
		rm -f $chrome_tmp
		wget ${chrome_url} -O $chrome_tmp 
		chrome_tmp_size=`ls -l $chrome_tmp | cut -d" " -f5`

		# download version first, otherwise local version
		if [ -e "$chrome_tmp" ] && [ "$chrome_tmp_size" -ne 0 ] ; then
			sudo dpkg -i $chrome_tmp			# will show error on ubuntu desktop 12.04
			[ "$?" -ne 0 ] && sudo apt-get -f install	# if error happen, this will force to install
		elif [ -e "$chrome_local" ] ; then
			sudo dpkg -i $chrome_local
			[ "$?" -ne 0 ] && sudo apt-get -f install	# if error happen, this will force to install
		else
			echo "ERROR: failed to install chrome!"
		fi
	fi
}

function func_add_apt_repo {
	apt_repo=$1

	# all added ppa could be found in /etc/apt/sources.list.d/ 
	[ $(ls /etc/apt/sources.list.d/ | grep -c ${apt_repo##*:}) -ge 1 ] && echo "INFO: $apt_repo already added, skip" && return 0

	sudo add-apt-repository -y $apt_repo			&>> $tmp_init_log
}

function func_init_apt_update_ppa {
	echo ">>> INIT `date "+%H:%M:%S"`: add ppa for latest software"

	sudo apt-get install -y python-software-properties	>> $tmp_init_log	# for cmd add-apt-repository 
	sudo apt-get install -y software-properties-common	>> $tmp_init_log	# for cmd add-apt-repository 

	func_add_apt_repo ppa:gnome-terminator
	func_add_apt_repo ppa:alexx2000/doublecmd				# double commander
	func_add_apt_repo ppa:byobu/ppa						# byobu
}

function func_init_soft_termial {
	echo ">>> INIT `date "+%H:%M:%S"`: install software, usable in terminal"

	sudo apt-get install -y expect unison openssh-server 	>> $tmp_init_log	# basic tools
	sudo apt-get install -y build-essential make gcc cmake	>> $tmp_init_log	# build tools
	sudo apt-get install -y samba				>> $tmp_init_log	# samba
	sudo apt-get install -y git subversion mercurial	>> $tmp_init_log	# dev tools
	sudo apt-get install -y tmux autossh w3m		>> $tmp_init_log	# dev tools
	sudo apt-get install -y debconf-utils			>> $tmp_init_log	# help auto select when install software (like mysql, wine, etc)
}

function func_init_soft_basic {
	echo ">>> INIT `date "+%H:%M:%S"`: install basic softwares, aptitude/zip/unzip/linux-headers, etc"

	func_init_apt_upgrade
	sudo apt-get install -y dkms				>> $tmp_init_log
	sudo apt-get install -y aptitude			>> $tmp_init_log
	sudo apt-get install -y openssh-server			>> $tmp_init_log
	sudo apt-get install -y zip unzip curl			>> $tmp_init_log
	sudo apt-get install -y linux-headers-`uname -r`	>> $tmp_init_log	# some soft compile need this

	#(! command -v aptitude &>> $tmp_init_log) && echo "install aptitude failed, pls check!" && exit 1
}

# tmp test
#return 0

# Init - pre conditions
func_pre_check 

# Init - basic
func_init_sudoer
func_init_dir_temp
func_init_dir_home				# ony for /ext/home_data init
func_init_apt_update_src
func_init_apt_update_ppa
func_init_apt_update_list
func_init_soft_basic

# Init - myenv
func_init_link dev os_spec_lu/dev		# ony for /ext/home_data init
func_init_link .m2 os_spec_lu/m2_repo		# ony for /ext/home_data init
func_init_link program os_spec_lu/program 	# ony for /ext/home_data init
#func_init_link_doc
#func_init_link_dev
#func_init_link_pro
func_init_myenv_rw

# Init - soft
func_init_soft_gui				# only for gui
func_init_soft_termial

# Init - config
func_init_config_xfce				# only for linuxmint XFCE version

# Last - manual stuff
func_init_soft_manual_needed

echo "All logs goes to $tmp_init_log"

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


#function func_init_link_doc {
#	home_doc_path="$HOME/Documents"
#	echo ">>> INIT `date "+%H:%M:%S"`: setup links $home_doc_path"
#
#	[ -e $home_doc_path -a -h $home_doc_path ] && echo "$home_doc_path link already exist, skip" && return 0
#	(( `ls $home_doc_path 2> $tmp_init_log | wc -l` != 0 )) && echo "$home_doc_path is not empty, pls check!" && return 0
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
#	(( `ls $home_dev_path 2>> $tmp_init_log | wc -l` != 0 )) && echo "$home_dev_path is not empty, pls check!" && return 0
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
#	(( `ls $home_pro_path 2>> $tmp_init_log | wc -l` != 0 )) && echo "$home_pro_path is not empty, pls check!" && return 0
#
#	ext_doc_path=`find /ext/ -maxdepth 3 -type d -name "Documents"`
#	(( `echo $ext_doc_path | wc -l` == 1 ))	|| echo "Failed to find Documents dir in /ext, skip!" || return 1
#	ln -s $ext_doc_path/os_spec_lu/program $home_pro_path
#}
