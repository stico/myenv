#!/bin/bash

# Functions
func_init_zbox_via_apt() {		
	echo "INFO: --INIT-- init zbox from github via git"

	[ -d "${HOME}/.zbox/.git" ] && echo "INFO: ${HOME}/.zbox/.git already exist, skip" && return 0
	func_vcs_update git "git://github.com/ouyzhu/zbox.git" "${HOME}/.zbox"
}

func_init_myenv_local() {
	echo "INFO: --INIT-- init myenv files for local usage"

	# NOTE: not need to check myenv here, since source lib already did

	# local dir
	mkdir "${MY_ENV_SECU}"
	mkdir "${MY_ENV_ZGEN}/collection"

	# local bashrc
	local local_bashrc="${MY_ENV_CONF}/bash/bashrc.$(hostname)"
	if [ ! -e "${local_bashrc}" ] ; then
		touch "${local_bashrc}"
		echo "INFO: pls add local stuff (e.g. 'zbox use') in: ${local_bashrc}"
	fi
	
	# gen std tags
	func_std_standarize
}

func_init_apt_install_single() {
	if func_is_cmd_exist "${1}" ; then
		echo "INFO: ${2} already installed"
		return 0
	fi

	shift
	sudo apt-get install -y "$@" && echo "INFO: install ${2} success" || echo "WARN: install ${2} failed!"	
}

func_init_apt_update() {	
	echo "INFO: --INIT-- apt-get update"

	func_complain_sudo_not_auto && return 1
	sudo apt-get update
}

func_init_apt_distupgrade() {

	# NOTE: seems the time check is unnecessary, the cmd is very fast in ubuntu 16.04

	echo "INFO: --INIT-- apt-get dist-upgrade"
	func_complain_sudo_not_auto && return 1

	# Check if long enough to run again. NOTE: this file should NOT in ${init_dir}, as need across diff init
	local apt_upgrade_stamp="/tmp/_me_init_/apt-dist-upgrade-success-stamp"
	[ ! -e "${apt_upgrade_stamp}" ] && touch -t 197101020304 "${apt_upgrade_stamp}"
	local last_stamp=$(( $(date +%s) - $(stat -c %Y "${apt_upgrade_stamp}") ))
	(( ${last_stamp:=12345678} < 259200 ))							\
	&& echo "INFO: updated ${last_stamp} seconds ago (< 3 days), skip..." && return 0	\
	|| echo "INFO: updated ${last_stamp} seconds ago (> 3 days), update again " 

	# NOTE on dist-upgrade: 
	# install available updates for current Ubuntu release,
	# also intelligently handles changing dependencies with new versions of packages

	# Run in unattended way, works on 16.04
	# FROM: http://stackoverflow.com/questions/40748363/virtual-machine-apt-get-grub-issue/40751712 
	# 1) Check if the package being installed specifies by default that the new configuration file should be installed - if that is the case, then the new configuration file will be installed and overwrite the old one.
	# 2) If the package being installed does not specify by default that the new configuration file should be installed, then the old configuration file would be kept - that is very useful, specially when you customized the installation of that package.
	DEBIAN_FRONTEND=noninteractive sudo apt-get -y 		\
	-o DPkg::options::="--force-confdef" 			\
	-o DPkg::options::="--force-confold" dist-upgrade 	\
	&& touch "${apt_upgrade_stamp}"
}

