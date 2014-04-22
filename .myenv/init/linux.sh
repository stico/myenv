#!/bin/bash

# One line cmd
# V1: curl https://raw.github.com/stico/myenv/master/.myenv/init/linux.sh | bash
# V2: rm /tmp/linux.sh ; wget -O /tmp/linux.sh -q https://raw.github.com/stico/myenv/master/.myenv/init/linux.sh && bash /tmp/linux.sh 
# V3: ( bash linux.sh & ) ; sleep 1 ; tail -f /tmp/init_linux/$(ls /tmp/init_linux | tail -1)/init.log

# TODO: standarize func_init_soft_xxx to $MY_ENV/tool

# Variable
tmp_init_dir=/tmp/init_linux/`date "+%Y%m%d_%H%M%S"`
tmp_init_log=${tmp_init_dir}/init.log

# Source & Prepare
umask 077
mkdir -p ${tmp_init_dir}
source ${HOME}/.myenv/myenv_func.sh || eval "$(wget -q -O - "https://raw.github.com/stico/myenv/master/.myenv/myenv_func.sh")" || exit 1

# Function
function func_pre_check() {
	func_log_echo "${tmp_init_log}" "INFO: pre condition check"

	# Check username
	[ "$(whoami)" != "ouyangzhu" ] && func_log_die "${tmp_init_log}" "ERROR: username must be 'ouyangzhu'!" 

	# Check platform
	[ $(uname -s | grep -c CYGWIN) -eq 1 ] && os_cygwin="true" || os_cygwin="false"
	[ $(uname -s | grep -c MINGW) -eq 1 ] && os_mingw="true" || os_mingw="false"
	[ "$os_cygwin" = "true" -o "$os_mingw" = "true" ] && func_log_die "${tmp_init_log}" "ERROR: can not run init on CYGWIN or MINGW platform!"

	# Check important existence
	func_validate_path_exist /ext
	func_validate_path_exist /ext/Documents		# TODO: is it really necessary?

	# Check owner of /ext
	local expect_owner="ouyangzhu:ouyangzhu"
	local real_owner=`ls -l / | sed -e "/->/d" | grep ext | awk '{print $3":"$4}'`
	[ "${real_owner}" != "${expect_owner}" ] && func_log_die "${tmp_init_log}" "ERROR: owner of path '/ext/' must be ${expect_owner}"

}

function func_init_dirs() {
	func_log_echo "${tmp_init_log}" "INFO: pre condition check"

	mkdir -p ~/amp/{download,delete}
}

function func_init_link() {
	func_param_check 2 "${FUNCNAME} <target_path> <source_path>" "$@"
	local target_path="$1"
	local source_path="$2"

	# check existence
	[ ! -e ${source_path} ] && func_log_echo "${tmp_init_log}" "WARN: ${source_path} NOT exist, skip" && return 0
	[ -h "${target_path}" ] && func_log_echo "${tmp_init_log}" "INFO: ${target_path} (link) already exist, skip" && return 0

	# if target is an empty dir, will replace it
	[ -d "${target_path}" ] && (( `ls ${target_path} 2> /dev/null | wc -l` == 0 )) && rmdir "${target_path}"

	func_log_echo "${tmp_init_log}" "INFO: creating link ${target_path} --> ${source_path}"
	ln -s "${source_path}" "${target_path}"
}

function func_init_links() {
	func_log_echo "${tmp_init_log}" "INFO: init links"

	func_init_link ${HOME}/.m2              /ext/Documents/FCS/maven/m2_repo
	func_init_link ${HOME}/Documents        /ext/Documents
}

function func_init_myenv() {
	func_log_echo "${tmp_init_log}" "INFO: init myenv"
	[ -e "${HOME}/.myenv" -a -e "{HOME}/.ssh" ] && func_log_echo "${tmp_init_log}" "INFO: ~/.myenv already exist, skip" && return 0

	if [ -e "${MY_ENV}/init/myenv.sh" ] ; then
		bash "${MY_ENV}/init/myenv.sh" 
	else
		local myenv_tmp=${tmp_init_dir}/myenv.sh
		local myenv_url=https://raw.github.com/stico/myenv/master/.myenv/init/myenv.sh
		wget -O ${myenv_tmp} -q ${myenv_url}		|| func_log_die "${tmp_init_log}" "ERROR: failed to download ${myenv_url}"
		[ -s "${myenv_tmp}" ] && bash ${myenv_tmp}	|| func_log_die "${tmp_init_log}" "ERROR: failed to init myenv!"
	fi
}

function func_init_sudoer() {
	func_log_echo "${tmp_init_log}" "INFO: update /etc/sudoers"
	sudo grep "sudo.*NOPASSWD:" /etc/sudoers &> /dev/null && func_log_echo "${tmp_init_log}" "INFO: /etc/sudoers already updated, skip" && return 0

	func_bak_file /etc/sudoers
	sudo sed -i '/%sudo/s/(ALL:ALL)/NOPASSWD:/' /etc/sudoers
}

function func_init_apt_config() {
	local src_files=( /etc/apt/sources.list /etc/apt/sources.list.d/official-package-repositories.list )
	func_log_echo "${tmp_init_log}" "INFO: apt config update, files: ${src_files}"

	# Update source mirror for speed
	local need_update="no"
	local mirror_addr=mirrors.163.com		# another candidate (in China, also 163's): http://ubuntu.cn99.com/ubuntu
	for src_file in "${src_files[@]}"; do 
		grep "${mirror_addr}" "${src_file}" &> /dev/null && func_log_echo "${tmp_init_log}" "INFO: ${src_file} already updated, skip" && continue
		( ! sudo grep "^[^#]*ubuntu.com" "${src_file}" ) &> /dev/null && func_log_echo "${tmp_init_log}" "INFO: ${src_file} NOT need updated, skip" && continue

		func_bak_file "${src_file}" 
		func_log_echo "${tmp_init_log}" "INFO: update ${src_file} with mirror: ${mirror_addr}"
		#sudo sed -i -e "/ubuntu.com/p;s/[^\/]*\.ubuntu\.com/${mirror_addr}/" ${src_file}	# reserve original source
		sudo sed -i -e "s/[^\/]*\.ubuntu\.com/${mirror_addr}/" ${src_file}			# replace original source
		need_update="yes"
	done
	[ ${need_update} = "yes" ] && sudo apt-get update
}

function func_init_apt_distupgrade() {
	func_log_echo "${tmp_init_log}" "INFO: apt dist-upgrade"

	local apt_upgrade_stamp=/tmp/apt-upgrade-success-stamp
	[ ! -e $apt_upgrade_stamp ] && touch -t 197101020304 $apt_upgrade_stamp

	local last_stamp=$(( `date +%s` - `stat -c %Y ${apt_upgrade_stamp}` ))
	if [ -e $apt_upgrade_stamp ] && (( $last_stamp > 86400 )) ; then
		func_log_echo "${tmp_init_log}" "INFO: execute 'supdo apt-get -y dist-upgrade'"
		sudo apt-get -y dist-upgrade &>> $tmp_init_log && touch $apt_upgrade_stamp
	else
		func_log_echo "${tmp_init_log}" "INFO: last update was ${last_stamp} seconds ago, skip..."
	fi
}

function func_init_apt_install_basic() {
	func_log_echo "${tmp_init_log}" "INFO: install basic softwares"

	sudo apt-get install -y dkms				&>> $tmp_init_log	# Dynamic Kernel Module Support
	sudo apt-get install -y aptitude			&>> $tmp_init_log
	sudo apt-get install -y autossh w3m			&>> $tmp_init_log	# dev tools
	sudo apt-get install -y expect unison 			&>> $tmp_init_log
	sudo apt-get install -y linux-headers-`uname -r`	&>> $tmp_init_log	# some soft compile need this
	sudo apt-get install -y git subversion mercurial	&>> $tmp_init_log	# dev tools
	sudo apt-get install -y zip unzip p7zip p7zip-rar	&>> $tmp_init_log
	sudo apt-get install -y openssh-server samba curl	&>> $tmp_init_log
	sudo apt-get install -y build-essential make gcc cmake	&>> $tmp_init_log	# build tools

	#sudo apt-get install -y tmux autossh w3m		&>> $tmp_init_log	# dev tools
	#sudo apt-get install -y debconf-utils			&>> $tmp_init_log	# help auto select when install software (like mysql, wine, etc)
}

function func_init_font() {
	func_log_echo "${tmp_init_log}" "INFO: try to init font"

	local font_sys=/usr/share/fonts/fontfiles
	local font_xhei=${font_sys}/XHei.TTC
	local font_msyhmono=${font_sys}/MSYHMONO.ttf
	local font_home=/ext/Documents/DCB/SoftwareConf/Font/
	[ ! -d "${font_home}" ] && func_log_echo "${tmp_init_log}" "WARN: ${font_home} not exist, can not init font!" && return 1
	[ -e "${font_xhei}" -a -e "${font_msyhmono}" ] && func_log_echo "${tmp_init_log}" "INFO: font already exist, skip" && return 0

	sudo mkdir -p ${font_sys}
	sudo cp ${font_home}/XHei.TTC ${font_home}/MSYHMONO.ttf ${font_sys}		# xhei for vim 
	sudo chmod -R 755 ${font_sys}
	fc-cache -fv >> ${tmp_init_log}							# update fonts 
}

function func_init_soft_ibus() { 
	# DEPRECATED: use fcitx instead
	# Chinese Input Method - Ibus. Still need: manual part: 1) add to autostart, use the /usr/bin/ibus-daemon. 2) set hotkey and in ibus preference 3) select input method in ibus preference
	ibus_table=/usr/share/ibus-table/engine/table.py
	sudo apt-get install -y ibus-table-wubi
	func_bak_file $ibus_table && sudo sed -i -e '/self._chinese_mode.*=.*get_value.*/,/))/{s/self._chinese_mode.*=.*/self._chinese_mode = 2/;/self._chinese_mode.*=.*/!d;}' $ibus_table
}

function func_init_soft_terminator() { 
	func_log_echo "${tmp_init_log}" "INFO: try to install soft terminator"
	command -v terminator &> /dev/null && func_log_echo "${tmp_init_log}" "INFO: alredy installed, skip" && return 0

	sudo apt-get install -y terminator
	mv ~/.config/terminator{,.bak.$(func_dati)}
	ln -s $MY_ENV/conf/terminator ~/.config/terminator
}

function func_init_soft_clipit() { 
	func_log_echo "${tmp_init_log}" "INFO: try to install soft clipit"
	command -v clipit &> /dev/null && func_log_echo "${tmp_init_log}" "INFO: alredy installed, skip" && return 0

	sudo apt-get install -y clipit
	mv ~/.config/clipit{,.bak.$(func_dati)}
	ln -s $MY_ENV/conf/clipit ~/.config/clipit
}
	
function func_init_soft_virtualbox() { 
	func_log_echo "${tmp_init_log}" "INFO: try to install soft virtualbox"
	[ -e /usr/bin/virtualbox ] && func_log_echo "${tmp_init_log}" "INFO: alredy installed, skip" && return 0

	if ( grep "DISTRIB_ID=Ubuntu" /etc/lsb-release ) && ( grep "DISTRIB_CODENAME=saucy" /etc/lsb-release ) ; then
		wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- | sudo apt-key add -
		sudo sh -c 'echo "deb http://download.virtualbox.org/virtualbox/debian saucy contrib" >> /etc/apt/sources.list.d/virtualbox.list'
		sudo apt-get update
		sudo apt-get install virtualbox-4.2		# (2014-03: can NOT use usb in ver 4.3, even after install extension pack. V4.2 works and not need extension pack)
	elif ( grep -i "DISTRIB_ID=LinuxMint" /etc/lsb-release ) && ( grep "DISTRIB_CODENAME=saucy" /etc/lsb-release ) ; then
		sudo apt-get install -y virtualbox-nonfree
		sudo apt-get install -y virtualbox-guest-additions-iso
		# for functions like USB to work correctly
		sudo usermod -a -G vboxusers ouyangzhu
	else
		func_log_echo "${tmp_init_log}" "WARN: failed to install virtualbox"
	fi
}

function func_init_soft_chrome() {
	func_log_echo "${tmp_init_log}" "INFO: try to install soft chrome (apt-get way)"
	command -v google-chrome           &> /dev/null && func_log_echo "${tmp_init_log}" "INFO: alredy installed, skip" && return 0
	dpkg -l | grep -i "google.*chrome" &> /dev/null && func_log_echo "${tmp_init_log}" "INFO: alredy installed, skip" && return 0

	wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
	sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
	sudo apt-get update
	sudo apt-get install -y google-chrome-stable
}

function func_init_soft_chrome_deb() {
	func_log_echo "${tmp_init_log}" "INFO: try to install soft chrome (.deb way)"
	command -v google-chrome           &> /dev/null && func_log_echo "${tmp_init_log}" "INFO: alredy installed, skip" && return 0
	dpkg -l | grep -i "google.*chrome" &> /dev/null && func_log_echo "${tmp_init_log}" "INFO: alredy installed, skip" && return 0

	local chrome_url='https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb'
	local chrome_local=${HOME}/Documents/ECS/chrome/google-chrome-stable_current_amd64.deb
	local chrome_local_bak=${chrome_local}.bak.$(func_dati)

	# download, try to use proxy 
	[ $(netstat -an | grep ":1984.*LISTEN" | wc -l) -ge 1 ] && export http_proxy="127.0.0.1:1984" && export https_proxy="127.0.0.1:1984"
	wget ${chrome_url} -O ${chrome_local} 

	# install, download version first, otherwise local version
	sudo apt-get install -y libnspr4-0d libcurl3					# install dependency
	if [ -s "$chrome_local" ] ; then
		sudo dpkg -i $chrome_local						# will show error on ubuntu desktop 12.04
		[ "$?" -ne 0 ] && sudo apt-get -f install				# if error happen, this will force to install
	elif [ -s "$chrome_local_bak" ] ; then
		sudo dpkg -i $chrome_local_bak
		[ "$?" -ne 0 ] && sudo apt-get -f install				# if error happen, this will force to install
	else
		func_log_echo "${tmp_init_log}" "WARN: failed to install chrome!"
	fi
}

function func_init_os_common() {
	func_log_echo "${tmp_init_log}" "INFO: OS specific init for common part"
	( ! grep "DISTRIB_CODENAME=\(saucy\|olivia\)" /etc/lsb-release ) && func_log_echo "${tmp_init_log}" "INFO: skip since version not matched" && return 0

	sudo apt-get install -y vlc xclip			&>> $tmp_init_log
	sudo apt-get install -y fcitx-table-wbpy		&>> $tmp_init_log	# Chinese Input Method - Fcitx
	sudo apt-get install -y xbindkeys wmctrl xdotool	&>> $tmp_init_log

	func_init_font						&>> $tmp_init_log
	func_init_soft_clipit					&>> $tmp_init_log
	func_init_soft_chrome					&>> $tmp_init_log
	func_init_soft_virtualbox				&>> $tmp_init_log
	func_init_soft_terminator				&>> $tmp_init_log
}

function func_init_os_ubuntu1310() {
	func_log_echo "${tmp_init_log}" "INFO: OS specific init for ubuntu 13.10"

	sudo apt-get install -y ubuntu-restricted-extras	&>> $tmp_init_log	# for rhythmbox to play mp3
	sudo apt-get install -y compizconfig-settings-manager	&>> $tmp_init_log	# for unity settings, use cmd "ccsm" to invoke it

	( ! grep "DISTRIB_ID=Ubuntu" /etc/lsb-release ) &&				\
	( ! grep "DISTRIB_CODENAME=saucy" /etc/lsb-release ) &&				\
	func_log_echo "${tmp_init_log}" "INFO: skip, since version not matched" &&	\
	return 0
}

function func_init_os_linuxmint15() {
	func_log_echo "${tmp_init_log}" "INFO: OS specific init for linuxmint 15"
	( ! grep "DISTRIB_CODENAME=olivia" /etc/lsb-release ) && func_log_echo "${tmp_init_log}" "INFO: skip since version not matched" && return 0

	sudo apt-get install -y arandr				&>> $tmp_init_log	# set the screen layout, e.g for dual screen
	sudo apt-get install -y pulseaudio pulseaudio-utils	&>> $tmp_init_log	# For logitech usb headset, use "PulseAudio Volume Control" to control the device
	sudo apt-get install -y pavucontrol			&>> $tmp_init_log
	sudo apt-get install -y xrdp rdesktop			&>> $tmp_init_log	# xrdp: supports windows native remote desktop connection. rdesktop: use to connect to remote desktop (including windows)
	#sudo apt-get install -y byobu bum			&>> $tmp_init_log	# bum (boot-up-manager), byobu is a better tmux
	#sudo apt-get install -y wine1.7 winetricks		&>> $tmp_init_log	# better installation in $MY_ENV/tools
}

function func_init_de_xfce() {
	func_log_echo "${tmp_init_log}" "INFO: DE specific init for XFCE"
	( ! dpkg -l | grep -i "xfce" &> /dev/null ) && func_log_echo "${tmp_init_log}" "INFO: skip since version not matched" && return 0

	# TODO: how to check?

	echo ">>> INIT `date "+%H:%M:%S"`: update XFCE applications config"
	source_path=~/.myenv/conf/xfce/applications/
	target_path=~/.local/share/applications/
	func_bak_file ${target_path}/defaults.list || return 0
	mv -f ${target_path}/defaults.list /tmp/
	cp $source_path/* $target_path/* >> $tmp_init_log

	echo ">>> INIT `date "+%H:%M:%S"`: update XFCE config"
	target_path=~/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml
	func_bak_file ${target_path} || return 0
	sed -i -e '/workspace_count/s/value="."/value="1"/' $target_path

	echo ">>> INIT `date "+%H:%M:%S"`: update XFCE key config"
	source_path=~/.myenv/conf/xfce/xfce4-keyboard-shortcuts.xml
	target_path=~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml
	func_bak_file ${target_path} || return 0
	mv -f $target_path /tmp/
	cp $source_path $target_path >> $tmp_init_log
	# without this, the Tab key not work in xrdp connection
	#sed -i -e 's/Tab.*switch_window_key/Tab" type="empty/' $config_keys 

	echo ">>> INIT `date "+%H:%M:%S"`: update XFCE keying config"
	# without this, will get error like "WARNING: gnome-keyring:: couldn't connect to: /tmp/keyring-WtN6AD/pkcs11: No such file or directory"
	dt_type=XFCE
	gnome_keying_desktop=/etc/xdg/autostart/gnome-keyring-pkcs11.desktop
	func_bak_file ${gnome_keying_desktop} || return 0
	if [ $(grep -c "OnlyShowIn=.*${dt_type}" $gnome_keying_desktop) -lt 1 ] ; then 
		sudo sed -i -e "s/^\(OnlyShowIn=\)\(.*\)/\1${dt_type};\2/" $gnome_keying_desktop 
	else 
		echo "INFO: $gnome_keying_desktop already contains $dt_type, ignore"
	fi
}

function func_init_manual_infinality {
	func_log_echo "${tmp_init_log}" "INFO: install infinality which improve font rendering, need some mannal check, pls install it manually"

	local setting_file=/etc/infinality-settings.sh
	[ -e "${setting_file}" ] && func_log_echo "${tmp_init_log}" "INFO: ${setting_file} already exist, skip" && return 0

	# Note 1: this is for better font rendering, seems really better
	# Note 2: (On linuxmint 15 XFCE), after this need startx manually, following cmd after apt-get install is doing this
	#         Also make sure this line is in .bashrc: [ -e /etc/infinality-settings.sh ] && . /etc/infinality-settings.sh
	sudo add-apt-repository -y ppa:no1wantdthisname/ppa
	sudo apt-get update
	#sudo apt-get upgrade		# this works on LM15
	sudo apt-get dist-upgrade	# this not tested yet
	sudo apt-get install fontconfig-infinality
	sudo mv /etc/profile.d/infinality-settings.sh ${setting_file}
	sudo chmod a+rx /etc/infinality-settings.sh

	echo "Need logout to take effect, logout (N) [Y/N]?"
	read -e continue                                                                                           
	[ "$continue" != "Y" -a "$continue" != "y" ] && echo "Give up, pls logout and login later" && return 1
	( command -v xfce4-session-logout &> /dev/null ) && xfce4-session-logout --logout
	( command -v gnome-session-quit &> /dev/null ) && gnome-session-quit
	# what command for kde?
} 

function func_init_manual_needed() {
	func_log_echo "${tmp_init_log}" "INFO: Following steps need manual op (like set password, accept agreement), continue (N) [Y/N]?"
	read -e continue                                                                                           
	[ "$continue" != "Y" -a "$continue" != "y" ] && func_log_echo "${tmp_init_log}" "Give up, pls install those soft manually later!" && return 1

	func_log_echo "${tmp_init_log}" "INFO: add a backup user, remember to change its password which already have record!"
	( ! grep "^ouyangzhu2:" /etc/passwd &> /dev/null ) && sudo useradd -m -s /bin/bash -g sudo ouyangzhu2 && sudo passwd ouyangzhu2

	#TODO: test it on ubuntu 13.10
	#func_init_manual_infinality

	# Need comfirm the dialog, seems deprecated the package "msttcorefonts"
	#sudo apt-get install -y --force-yes ttf-mscorefonts-installer
}

# Action
func_pre_check
func_init_dirs
func_init_sudoer	# 1st time need manual input, so make it happens earlier 
func_init_links
func_init_myenv

# Action - apt
#func_init_apt_config	# seems changed too much stuff (in ubuntu 13.10)
func_init_apt_distupgrade
func_init_apt_install_basic

# Action - OS spect
func_init_os_common
func_init_os_ubuntu1310
func_init_os_linuxmint15

# Action - DE spect
func_init_de_xfce

# Action - Manual
func_init_manual_needed 

echo "All logs goes to $tmp_init_log"
