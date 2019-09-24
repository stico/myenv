#!/bin/bash

# Usage
#       rm /tmp/myenv_init_all.sh ; wget -O /tmp/myenv_init_all.sh -q https://raw.github.com/stico/myenv/master/.myenv/myenv_init_all.sh && bash /tmp/myenv_init_all.sh

# Design
#	# Guideline
#		Repeatable: status check
#       	Compatible: test, production, personal, 
#       	Platform: linux, osx
#	# Detail
#		every function: 1) do its own status check, 2) will not stop other functions
#		

# TODO
#	split into small pieces like myenv.sh?
#	run func_collect_all
#	how to?: production env of dw, usually should not install via apt-get?
#	into myenv: 
#		func_pipe_filter rename to func_filter_keymsg
#		complain_non_interactive 
#			NOT works as expect: $bash xxx.sh could accept input
#		remove ">>" in echo (link creation)
#	IS_DESKTOP=false as default value
#	use or into zbox?: init_git_via_make
#	func_init_manual_needed need update

# Deprecated
#	func_pre_check

# Config
IS_DESKTOP=true
REUSE_DOWNLOADED_SOURCE=true
DATED_BACKUP_PATH="${HOME}/Documents/DCB/DatedBackup"

# Variable
tmp_base="/tmp/_me_init_"
init_dir="${tmp_base}/$(date "+%m%d_%H%M%S")"
init_log="${init_dir}/init.log"

# Prepare
umask 077
mkdir -p "${init_dir}"
cd "${init_dir}"

# Steps
# shellcheck disable=2155
func_source_lib() {
	local lib=myenv_lib.sh 
	local func=myenv_func.sh 
	local me_home=${HOME}/.myenv
	echo "INFO: --STEP-- source ${lib} and ${func}"

	if [[ -f ./${lib} && -f ./${func} ]] ; then
		echo "INFO: use files in current dir: $PWD"
		source ./${lib}
		source ./${func}
		return 0
	fi

	if [[ -f ${me_home}/${lib} && -f ${me_home}/${func} ]] ; then
		echo "INFO: use files in myenv dir: ${me_home}"
		source "${me_home}/${lib}"
		source "${me_home}/${func}"
		return 0
	fi

	if [[ "${REUSE_DOWNLOADED_SOURCE}" = true ]] ; then
		local lib_latest="$(find "${tmp_base}/" -name "${lib}" | tail -1)"
		local func_latest="$(find "${tmp_base}/" -name "${func}" | tail -1)"
		if [[ -n "${lib_latest}" && -n "${func_latest}" ]] ; then 
			echo "INFO: use latest downloaded files: ${lib_latest}, ${func_latest}"
			source "${lib_latest}"
			source "${func_latest}"
			return 0
		fi
	fi

	local lib_dl=${init_dir}/${lib}
	local func_dl=${init_dir}/${func}
	echo "INFO: try to downloaded from github"
	wget -q -O "${lib_dl}" "https://raw.github.com/stico/myenv/master/.myenv/myenv_lib.sh"
	wget -q -O "${func_dl}" "https://raw.github.com/stico/myenv/master/.myenv/myenv_func.sh"
	if [[ -f "${lib_dl}" && -f "${func_dl}" ]] ; then
		echo "INFO: use files downloaded from github (in ${init_dir})"
		source "${lib_dl}"
		source "${func_dl}"
		return 0
	fi

	echo "SUMMARY: failed to import source ${lib} and ${func}, lots step will fail!!!"
}

func_init_dirs() {
	echo "INFO: --STEP-- init basic dirs and links"

	mkdir -p ~/amp/delete
	mkdir -p ~/amp/download

	func_link_init "${HOME}/Documents" /ext/Documents
	func_link_init "${HOME}/.m2" /ext/Documents/FCS/maven/m2_repo

	[ -e ~/amp/downloads ] || func_link_init ~/amp/download ~/Downloads
	
	[ -e "${HOME}/Documents/DCC" ] || echo "SUMMARY: seems no personal ~/Documents linked"
}

# shellcheck disable=2155,2010
func_init_git_via_make() {
	# TODO: the compile version need update
	# TODO: extract to another function?
	echo "WARN: the compile version of git is old, will NOT continue, pls solve it manually!"

	# Try compile
	local git_tar="git-1.8.5.tar.gz"
	local git_name="${git_tar%%.tar.gz}"
	#git_url="https://git-core.googlecode.com/files/${git_tar}"	# usable, but not fast
	local git_url="https://www.kernel.org/pub/software/scm/git/${git_tar}"
	local git_target_path="${HOME}/dev/${git_name}"
	local git_target_link="${HOME}/dev/git"

	# Download source
	cd /tmp && rm -rf "$git_tar" "$git_name" && wget "$git_url" && tar zxvf "$git_tar" && cd "$git_name"
	[ "$?" -ne "0" ] && echo "ERROR: failed to get git source" && exit 1

	# Compile - prepare options
	# Note 1: not really need gettext (cause git could only use in English)
	# Note 2: not really need tcl_tk (cause git could only use command line)
	# Note 3: zlib1g-dev is a must
	local option_make="NO_GETTEXT=1 NO_TCLTK=1"
	local option_configure=""
	if ( ! dpkg -l | grep -q zlib1g-dev ) ; then
		cd /tmp
		sudo apt-get install -y dpkg-dev	# some env need this to compile
		apt-get source zlib1g-dev
		local zlib_name="$(ls | grep zlib-)"
		[ ! -e "/tmp/$zlib_name" ] && echo "ERROR: failed to download source of zlib1g-dev" && exit 1
		cd "/tmp/$zlib_name"
		./configure --prefix="$HOME/dev/$zlib_name" && make && make install
		local option_configure="$option_configure --with-zlib=$HOME/dev/$zlib_name "
		[ ! -e "$HOME/dev/$zlib_name" ] && echo "ERROR: failed to install dependency zlib1g-dev" && exit 1
	fi
	if ( ! dpkg -l | grep -q openssl ) ; then
		cd /tmp
		apt-get source openssl
		local openssl_name=$(ls | grep openssl-)
		[ ! -e "/tmp/$openssl_name" ] && echo "ERROR: failed to download source of openssl" && exit 1
		cd "/tmp/$openssl_name"
		./configure --prefix="$HOME/dev/$openssl_name" && make && make install
		local option_configure="$option_configure --with-openssl=$HOME/dev/$openssl_name "
		[ ! -e "$HOME/dev/$openssl_name" ] && echo "ERROR: failed to install dependency openssl" && exit 1
	fi
	if ( ! dpkg -l | grep -q libcurl4-gnutls-dev ) ; then
		cd /tmp
		apt-get source libcurl4-gnutls-dev
		local curl_name=$(ls | grep curl-)
		[ ! -e "/tmp/$curl_name" ] && echo "ERROR: failed to download source of libcurl4-gnutls-dev" && exit 1
		cd "/tmp/$curl_name"

		if ( ! dpkg -l | grep -q openssl ) ; then
			./configure --prefix="$HOME/dev/$curl_name" --with-ssl="$HOME/dev/$openssl_name"  && make && make install
		else
			./configure --prefix="$HOME/dev/$curl_name" --with-ssl && make && make install
		fi

		local option_configure="$option_configure --with-curl=$HOME/dev/$curl_name "
		[ ! -e "$HOME/dev/$curl_name" ] && echo "ERROR: failed to install dependency libcurl4-gnutls-dev" && exit 1
	fi
	echo "INFO: option_make=$option_make"
	echo "INFO: option_configure=$option_configure"

	# Compile
	rm -rf "$git_target_path" "$git_target_link"
	mkdir -p "$git_target_path"
	cd /tmp/"$git_name"
	#./configure --prefix="$git_target_path" --without-tcltk && make && make install
	#./configure --prefix=$HOME/dev/git-1.8.4.3 --with-zlib=$HOME/dev/zlib && make NO_GETTEXT=1 NO_TCLTK=1 install
	./configure --prefix="$git_target_path" "$option_configure" && make "$option_make" install

	ln -s "$git_target_path" "$git_target_link"
}

func_init_zbox_via_apt() {		
	echo "INFO: --STEP-- init zbox from github via git"

	[ -d ~/.zbox/.git ] && echo "INFO: ~/.zbox/.git already exist, skip" && return 0

	local repo_name=zbox
	local repo_addr=git://github.com/ouyzhu/zbox.git
	func_vcs_update git "${repo_addr}" ~/.zbox
}

func_init_myenv_unison() {
	echo "INFO: --STEP-- init myenv unison sync info from local datedbckup archive"

	# check
	local target=~/.unison
	func_complain_path_not_exist ${target} && return 1
	func_complain_path_not_exist ${DATED_BACKUP_PATH} && return 1
	\ls ${target}/ar* &> /dev/null && echo "INFO: unison sync info already exist, skip" && return 0

	# Find the backup. IMPORTANT: the host name must match, which is diff in func_init_myenv_secure()
	local zip_pattern="*_$(hostname)*_myenv_*.zip"
	local zip_path=`find ${DATED_BACKUP_PATH} -name "${zip_pattern}" | sort | tail -1`
	func_complain_path_not_exist "${zip_path:-${zip_pattern}}" && return 1

	# Extract the backup
	local zip_filename=${zip_path##*/}
	local extract_path=${init_dir}/${zip_filename%.zip}
	[ -e "${extract_path}" ] && echo "INFO: extraction exist, reuse it" || func_uncompress ${zip_path} ${extract_path}

	# Find and copy
	local unison_bak=`find $extract_path -name ".unison" -type d | tail -1`
	\ls $unison_bak/fp* &> /dev/null && \ls $unison_bak/ar* &> /dev/null \
	&& echo "INFO: no unison sync info in backup" && return 0
	[ -e "$unison_bak" ] && cp -rf $unison_bak/{ar,fp}* ${target}
}

func_init_myenv_local() {
	echo "INFO: --STEP-- init myenv files for local usage"

	local local_bashrc="${HOME}/.myenv/conf/bash/bashrc.$(hostname)"
	if [ ! -e "${local_bashrc}" ] ; then
		touch "${local_bashrc}"
		echo "INFO: pls add local stuff (e.g. zbox) in: ${local_bashrc}"
	fi
}

func_init_myenv_secure() {
	# TODO: use a var in head for better compatibility?
	# TODO: restore other secure/config files: ~/.netrc, ~/.config/terminator/config -> /Users/ouyangzhu/.myenv/conf/terminator/config
	echo "INFO: --STEP-- init myenv secure info from local datedbckup archive"

	# check
	func_complain_path_not_exist ${DATED_BACKUP_PATH} && return 1
	[ -e ~/.ssh/config -o -e ~/.myenv/secu ] && echo "INFO: ~/.ssh/config or ~/.myenv/secu already exist, skip" && return 0

	# rmdir if dir is empty
	[ -d ~/.ssh ] && [ ! "$(ls -A ~/.ssh)" ] && rmdir ~/.ssh
	[ -d ~/.myenv/secu ] && [ ! "$(ls -A ~/.myenv/secu)" ] && rmdir ~/.myenv/secu

	# Find the backup. IMPORTANT: use latest and ignore hostname, which is diff in func_init_myenv_unison()
	local zip_path=`find ${DATED_BACKUP_PATH} -name "*_myenv_*.zip" | sort | tail -1`
	func_complain_path_not_exist "${zip_path}" && return 1

	# Extract the backup
	local zip_filename=${zip_path##*/}
	local extract_path=${init_dir}/${zip_filename%.zip}
	[ -e "${extract_path}" ] && echo "INFO: extraction exist, reuse it" || func_uncompress ${zip_path} ${extract_path}

	# Find and copy
	local ssh_bak=`find $extract_path -name ".ssh" -type d | tail -1`
	local secu_bak=`find $extract_path -name "secu" -type d | tail -1`
	local smbcr_bak=`find $extract_path -name ".smbcredentials" -type d | tail -1`
	mkdir -p ~/.ssh ~/.myenv/secu ~/.smbcredentials
	[ -e "$ssh_bak" ] && cp -rf $ssh_bak/* ~/.ssh/ 
	[ -e "$secu_bak" ] && cp -rf $secu_bak/* ~/.myenv/secu/ 
	[ -e "$smbcr_bak" ] && cp -rf $smbcr_bak/* ~/.smbcredentials/
}

func_init_zbox_writable(){
	echo "INFO: --STEP-- try to update zbox git to writable mode"

	func_init_git_repo_writable ~/.zbox ouyzhu@gmail.com "ouyzhu_github:ouyzhu/zbox.git"
}

func_init_myenv_collection(){	
	echo "INFO: --STEP-- try collect notes (func_std_standarize)"
	
	[ -e "${HOME}/.myenv/zgen/collection/all_content.txt" ] && echo "INFO: collection already exist, skip" && return 0

	func_std_standarize
}

func_init_myenv_writable(){
	echo "INFO: --STEP-- try to update myenv git to writable mode"

	func_init_git_repo_writable ${HOME} ouyzhu@gmail.com "stico_github:stico/myenv.git"
}

func_init_git_repo_writable() {
	local usage="Usage: ${FUNCNAME} <repo_path> <repo_mail> <repo_writable_addr>"
	local desc="Desc: update git to use certification, so repo becomes writable" 
	func_param_check 2 "${desc} \n ${usage} \n" "$@"

	local repo_dir="${1}"
	local repo_mail="${2}"
	local repo_addr="${3}"

	# check, git cmd already checked in func_init_myenv()
	func_complain_path_not_exist ${repo_dir}/.git "WARN: ${repo_dir}/.git NOT exist, check if repo path correct" && return 1
	func_complain_path_not_exist ~/.ssh/${repo_addr%%:*} "WARN: ~/.ssh/${repo_addr%%:*} NOT exist, repo still in readonly mode!" && return 1

	\cd ${repo_dir} &> /dev/null
	if (! \git remote -v | \grep -q "${repo_addr}") ; then
		echo "INFO: update git config info (origin, mail, set-upstream, etc)"
		\git remote rm origin
		\git remote add origin "${repo_addr}"
		\git push --set-upstream origin master
		\git config --global user.email "${repo_mail}"
		\git config --global user.name "${repo_mail%%@*}"
	else
		echo "INFO: repo already in writable mode"
	fi
	\cd - &> /dev/null
}

# Deprecated
func_pre_check() {
	echo "INFO: --STEP-- pre condition check (username, platform, doc path, etc)"

	# Check username
	[ "$(whoami)" != "ouyangzhu" ] && echo "WARN: username might wrong, which is: $(whoami) !" 

	# Check important existence
	func_complain_path_not_exist /ext/Documents "WARN: /ext/Documents not exist, some private info can NOT be init"

	# check user privilege
	func_complain_sudo_unusable "some cmd might fail" && return 1

	# Check platform
	uname -s | grep -q "MINGW\|CYGWIN " && func_die "ERROR: can NOT run init on CYGWIN or MINGW platform!"
}

func_is_sudo_need_password() {
	# TODO: merge with func_complain_privilege_not_sudoer ???

	# check if user need input password for sudo, return 0 if need input password, otherwise return 1
	# true is a cmd, -n for check in safe way (will not prompt for password)
	sudo -n true 2>/dev/null && return 1 || return 0
}

func_complain_sudo_unusable() {
	local msg="skip ${1}, since sudo need password in non-interactive mode"

	if func_is_sudo_need_password && func_is_non_interactive ; then 
		echo "WARN: ${msg}"
		echo "SUMMARY: ${msg}"
		return 0
	fi
	return 1
}

func_init_sudoer() {
	echo "INFO: --STEP-- update /etc/sudoers, use NOPASSWD way"

	func_complain_sudo_unusable "can NOT check/update /etc/sudoers file" && return 1

	# check if already performed
	if sudo grep "sudo.*NOPASSWD:" /etc/sudoers &> /dev/null ; then
		echo "INFO: /etc/sudoers already updated, skip"
		return 0
	fi

	func_duplicate_dated /etc/sudoers
	sudo sed -i '/%sudo/s/(ALL:ALL)/NOPASSWD:/' /etc/sudoers
}

func_init_apt_update() {	
	echo "INFO: --STEP-- apt-get update"

	func_complain_sudo_unusable && return 1

	sudo apt-get update
}

func_init_apt_distupgrade() {
	# TODO: seems the time check is unnecessary, the cmd is very fast in ubuntu 16.04
	echo "INFO: --STEP-- apt-get dist-upgrade"

	func_complain_sudo_unusable && return 1

	# Check if long enough to run again. NOTE: this file should NOT in ${init_dir}, as need across diff init
	local apt_upgrade_stamp=${tmp_base}/apt-dist-upgrade-success-stamp
	[ ! -e $apt_upgrade_stamp ] && touch -t 197101020304 $apt_upgrade_stamp
	local last_stamp=$(( $(date +%s) - $(stat -c %Y ${apt_upgrade_stamp}) ))
	(( ${last_stamp:=12345678} < 259200 ))							\
	&& echo "INFO: updated ${last_stamp} seconds ago (< 3 days), skip..." && return 0	\
	|| echo "INFO: updated ${last_stamp} seconds ago (> 3 days), update again " 

	# NOTE on dist-upgrade: 
	# install available updates for current Ubuntu release
	# in addition to performing the function of upgrade, 
	# also intelligently handles changing dependencies with new versions of packages

	# Run in unattended way, works on 16.04
	# FROM: http://stackoverflow.com/questions/40748363/virtual-machine-apt-get-grub-issue/40751712 
	# 1) Check if the package being installed specifies by default that the new configuration file should be installed - if that is the case, then the new configuration file will be installed and overwrite the old one.
	# 2) If the package being installed does not specify by default that the new configuration file should be installed, then the old configuration file would be kept - that is very useful, specially when you customized the installation of that package.
	DEBIAN_FRONTEND=noninteractive sudo apt-get -y 		\
	-o DPkg::options::="--force-confdef" 			\
	-o DPkg::options::="--force-confold" dist-upgrade 	\
	&& touch $apt_upgrade_stamp
}

func_init_apt_install_lib() {
	echo "INFO: --STEP-- install library for other software intall/compile via apt-get"

	func_complain_sudo_unusable && return 1

	# usually for soft compile/install
	sudo apt-get install -y apt-utils
	sudo apt-get install -y linux-headers-`uname -r`	
	sudo apt-get install -y build-essential build-essential 
	sudo apt-get install -y libcurl4-gnutls-dev libexpat1-dev gettext libz-dev openssl libssl-dev
}

func_init_apt_install_basic() {
	echo "INFO: --STEP-- install basic softwares via apt-get"

	func_complain_sudo_unusable && return 1

	func_init_apt_install_single git git 
	func_init_apt_install_single gcc gcc 
	func_init_apt_install_single zip zip 
	func_init_apt_install_single make make 
	func_init_apt_install_single dkms dkms			# Dynamic Kernel Module Support
	func_init_apt_install_single tree tree
	func_init_apt_install_single curl curl	
	func_init_apt_install_single samba samba 
	func_init_apt_install_single cmake cmake
	func_init_apt_install_single unzip unzip 
	func_init_apt_install_single unrar unrar 
	func_init_apt_install_single expect expect
	func_init_apt_install_single unison unison
	func_init_apt_install_single svn subversion 
	func_init_apt_install_single aptitude aptitude
	func_init_apt_install_single ssh openssh-server 
	func_init_apt_install_single p7zip 7zip p7zip-rar
	func_init_apt_install_single debconf debconf-utils	# help auto select when install software (like mysql, wine, etc)
	func_init_apt_install_single bsdmainutils bsdmainutils

	# deprecated
	#func_init_apt_install_single w3m w3m
	#func_init_apt_install_single autossh autossh
	#sudo apt-get install -y tmux autossh w3m		# dev tools
	#func_init_apt_install_single hg mercurial
}

func_init_apt_install_single() {
	if func_is_cmd_exist "${1}" ; then
		echo "INFO: ${2} already installed"
		return 0
	fi

	shift
	sudo apt-get install -y "$@" && echo "INFO: install ${2} success" || echo "WARN: install ${2} failed!"	
}

func_init_desktop_soft() {
	echo "INFO: --STEP-- install software for desktop"

	[[ "${IS_DESKTOP}" = false ]] && echo "INFO: skip this step, as config IS_DESKTOP is false" && return 0 

	# in other functions
	func_init_desktop_font		
	func_init_desktop_clipit
	func_init_desktop_chrome	
	func_init_desktop_terminator

	# install one by one
	func_init_apt_install_single vlc vlc
	func_init_apt_install_single xrdp xrdp
	func_init_apt_install_single xclip xclip
	func_init_apt_install_single arandr arandr
	func_init_apt_install_single wmctrl wmctrl 
	func_init_apt_install_single xdotool xdotool
	func_init_apt_install_single rdesktop rdesktop
	func_init_apt_install_single xbindkeys xbindkeys 

	sudo apt-get install -y indicator-multiload

	# virtualbox need more step
	apt-key list | grep -q virtualbox || wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- | sudo apt-key add -
	echo virtualbox-ext-pack virtualbox-ext-pack/license select true | sudo debconf-set-selections
	func_init_apt_install_single virtualbox virtualbox virtualbox-guest-additions-iso virtualbox-ext-pack
	sudo usermod -a -G vboxusers $(whoami)

	# code formatters, see ~auto-format@vim
	func_init_apt_install_single tidy tidy 
	func_init_apt_install_single astyle astyle 
	func_init_apt_install_single python-autopep8 python-autopep8	

	# deprecated
	#sudo apt-get install -y fcitx-table-wbpy
}

func_init_desktop_terminator() { 
	echo "INFO: --STEP-- try to install soft terminator"

	[[ "${IS_DESKTOP}" = false ]] && echo "INFO: skip this step, as config IS_DESKTOP is false" && return 0 
	command -v terminator &> /dev/null && echo "INFO: alredy installed, skip" && return 0
	func_complain_sudo_unusable "can NOT install basic softwares via apt-get" && return 1

	sudo apt-get install -y terminator
	local conf=~/.config/terminator
	[ -e "${conf}" ] && func_duplicate_dated "${conf}"
	ln -s ${HOME}/.myenv/conf/terminator "${conf}"
}

# Deprecated
func_init_desktop_virtualbox() { 
	echo "INFO: --STEP-- try to install soft virtualbox"

	[[ "${IS_DESKTOP}" = false ]] && echo "INFO: skip this step, as config IS_DESKTOP is false" && return 0 
	[ -e /usr/bin/virtualbox ] && echo "INFO: alredy installed, skip" && return 0

	if ( grep "DISTRIB_ID=Ubuntu" /etc/lsb-release ) ; then
		# (2014-03: can NOT use usb in ver 4.3, even after install extension pack. V4.2 works and not need extension pack)
		wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- | sudo apt-key add -
		sudo sh -c 'echo "deb http://download.virtualbox.org/virtualbox/debian saucy contrib" >> /etc/apt/sources.list.d/virtualbox.list'
		sudo apt-get install virtualbox
	elif ( grep -i "DISTRIB_ID=LinuxMint" /etc/lsb-release ) ; then
		sudo apt-get install -y virtualbox-nonfree
		sudo apt-get install -y virtualbox-guest-additions-iso
		# for functions like USB to work correctly
		sudo usermod -a -G vboxusers $(whoami)
	else
		echo "WARN: failed to install virtualbox"
	fi
}

func_init_desktop_chrome() {
	echo "INFO: --STEP-- try to install soft chrome (apt-get way)"

	[[ "${IS_DESKTOP}" = false ]] && echo "INFO: skip this step, as config IS_DESKTOP is false" && return 0 
	command -v google-chrome           &> /dev/null && echo "INFO: alredy installed, skip" && return 0
	dpkg -l | grep -i "google.*chrome" &> /dev/null && echo "INFO: alredy installed, skip" && return 0

	wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
	if [ ! -e /etc/apt/sources.list.d/google-chrome.list ] ; then
		sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
		sudo chmod 664 /etc/apt/sources.list.d/google-chrome.list
	fi
	sudo apt-get install -y --allow-unauthenticated google-chrome-stable

	# from web, seems works for ubuntu 16.04
	#wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	#sudo dpkg -i --force-depends google-chrome-stable_current_amd64.deb
}

func_init_desktop_clipit() { 
	echo "INFO: --STEP-- try to install soft clipit"

	[[ "${IS_DESKTOP}" = false ]] && echo "INFO: skip this step, as config IS_DESKTOP is false" && return 0 
	command -v clipit &> /dev/null && echo "INFO: alredy installed, skip" && return 0

	sudo apt-get install -y clipit

	local conf=~/.config/clipit
	[ -e "${conf}" ] && mv func_duplicate_dated "${conf}"
	ln -s ${HOME}/.myenv/conf/clipit "${conf}"
}

func_init_desktop_font() {
	echo "INFO: --STEP-- try to init font"
	[[ "${IS_DESKTOP}" = false ]] && echo "INFO: skip this step, as config IS_DESKTOP is false" && return 0 

	local font_sys=/usr/share/fonts/fontfiles
	local font_xhei=${font_sys}/XHei.TTC
	local font_msyhmono=${font_sys}/MSYHMONO.ttf
	local font_home=/ext/Documents/DCC/font/repo/

	func_complain_sudo_unusable && return 1
	func_complain_path_not_exist ${font_home} && return 1

	[ -e "${font_xhei}" -a -e "${font_msyhmono}" ] && echo "INFO: font already exist, skip" && return 0

	sudo mkdir -p ${font_sys}
	sudo cp ${font_home}/XHei.TTC ${font_home}/MSYHMONO.ttf ${font_sys}		# xhei for vim 
	sudo chmod -R 755 ${font_sys}
	fc-cache -fv >> ${tmp_init_log}							# update fonts 
}
 
func_init_desktop_xfce() {
	echo "INFO: DE specific init for XFCE"
	( ! dpkg -l | grep -i "xfce" &> /dev/null ) && echo "INFO: skip since not XFCE desktop" && return 0

	# TODO: how to check?

	echo ">>> INIT `date "+%H:%M:%S"`: update XFCE applications config"
	source_path=~/.myenv/conf/xfce/applications/
	target_path=~/.local/share/applications/
	func_duplicate_dated ${target_path}/defaults.list || return 0
	mv -f ${target_path}/defaults.list /tmp/
	cp $source_path/* $target_path/* >> $tmp_init_log

	echo ">>> INIT `date "+%H:%M:%S"`: update XFCE config"
	target_path=~/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml
	func_duplicate_dated ${target_path} || return 0
	sed -i -e '/workspace_count/s/value="."/value="1"/' $target_path

	echo ">>> INIT `date "+%H:%M:%S"`: update XFCE key config"
	source_path=~/.myenv/conf/xfce/xfce4-keyboard-shortcuts.xml
	target_path=~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml
	func_duplicate_dated ${target_path} || return 0
	mv -f $target_path /tmp/
	cp $source_path $target_path >> $tmp_init_log
	# without this, the Tab key not work in xrdp connection
	#sed -i -e 's/Tab.*switch_window_key/Tab" type="empty/' $config_keys 

	echo ">>> INIT `date "+%H:%M:%S"`: update XFCE keying config"
	# without this, will get error like "WARNING: gnome-keyring:: couldn't connect to: /tmp/keyring-WtN6AD/pkcs11: No such file or directory"
	dt_type=XFCE
	gnome_keying_desktop=/etc/xdg/autostart/gnome-keyring-pkcs11.desktop
	func_duplicate_dated ${gnome_keying_desktop} || return 0
	if [ $(grep -c "OnlyShowIn=.*${dt_type}" $gnome_keying_desktop) -lt 1 ] ; then 
		sudo sed -i -e "s/^\(OnlyShowIn=\)\(.*\)/\1${dt_type};\2/" $gnome_keying_desktop 
	else 
		echo "INFO: $gnome_keying_desktop already contains $dt_type, ignore"
	fi
}

func_init_manual_needed() {
	return 0

	echo "INFO: Following steps need manual op (like set password, accept agreement), continue (N) [Y/N]?"
	read -e continue                                                                                           
	[ "$continue" != "Y" -a "$continue" != "y" ] && echo "Give up, pls install those soft manually later!" && return 1

	echo "INFO: add a backup user, remember to change its password which already have record!"
	( ! grep "^ouyangzhu2:" /etc/passwd &> /dev/null ) && sudo useradd -m -s /bin/bash -g sudo ouyangzhu2 && sudo passwd ouyangzhu2

	#TODO: test it on ubuntu 13.10
	#func_init_manual_infinality

	# TODO: make sure this in unattended way, otherwise dist-upgrade will ask for agreement. Test the solution
	# NOT work on 16.04 yet: http://askubuntu.com/questions/766491/failure-to-download-extra-data-files-with-ttf-mscorefonts-installer-on-ubuntu
	# Need comfirm the dialog, seems deprecated the package "msttcorefonts"
	echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections
	echo ttf-mscorefonts-installer msttcorefonts/present-mscorefonts-eula note | sudo debconf-set-selections
	sudo apt-get install -y --force-yes ttf-mscorefonts-installer
}

func_init_myenv() {
	curl -sk 'https://raw.githubusercontent.com/stico/myenv/master/.myenv/myenv_init.sh' | bash
}

# Init. NOTE: the sequence is important!
echo "INFO: init start, log in tmp dir: ${init_log}"
func_source_lib			# func_pipe_filter NOT work here
func_init_sudoer		| func_pipe_filter "${init_log}"	# seq front since need fail fast
func_init_dirs			| func_pipe_filter "${init_log}"
func_init_apt_update		| func_pipe_filter "${init_log}"	
func_init_apt_distupgrade	| func_pipe_filter "${init_log}"	
func_init_apt_install_lib	| func_pipe_filter "${init_log}"
func_init_apt_install_basic	| func_pipe_filter "${init_log}"
func_init_zbox_via_apt		| func_pipe_filter "${init_log}"
func_init_myenv			| func_pipe_filter "${init_log}"
func_init_myenv_local		| func_pipe_filter "${init_log}"
func_init_myenv_secure		| func_pipe_filter "${init_log}"
func_init_myenv_unison		| func_pipe_filter "${init_log}"
func_init_myenv_writable	| func_pipe_filter "${init_log}"
func_init_myenv_collection	| func_pipe_filter "${init_log}"
func_init_zbox_writable		| func_pipe_filter "${init_log}"
#func_init_desktop_soft		| func_pipe_filter "${init_log}"	# TODO: old, need update, and how to AUTO skip for server env?
#func_init_desktop_xfce		| func_pipe_filter "${init_log}"	# deprecated

echo "INFO: ---------------- SUMMARY ----------------"
sed -n -e "s/^SUMMARY://p" "${init_log}" | cat -n
