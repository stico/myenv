#!/bin/bash

# One line cmd
# V1: curl https://raw.github.com/stico/myenv/master/.myenv/init/linux.sh | bash
# V2: rm /tmp/linux.sh ; wget -O /tmp/linux.sh -q https://raw.github.com/stico/myenv/master/.myenv/init/linux.sh && bash /tmp/linux.sh 

# Variable
tmp_init_dir=/tmp/init_linux/`date "+%Y%m%d_%H%M%S"`
tmp_init_log=${tmp_init_dir}/init.log

# Source & Prepare
umask 077
source ${HOME}/.myenv/myenv_func.sh || eval "$(wget -q -O - "https://raw.github.com/stico/myenv/master/.myenv/myenv_func.sh")" || exit 1

# Function
function func_pre_check() {
	echo ">>> `date "+%H:%M:%S"`: pre condition check"

	# Check username
	[ "$(whoami)" != "ouyangzhu" ] && func_die "ERROR: username must be 'ouyangzhu'!" 

	# Check platform
	[ $(uname -s | grep -c CYGWIN) -eq 1 ] && os_cygwin="true" || os_cygwin="false"
	[ $(uname -s | grep -c MINGW) -eq 1 ] && os_mingw="true" || os_mingw="false"
	[ "$os_cygwin" = "true" -o "$os_mingw" = "true" ] && func_die "ERROR: can not run init on CYGWIN or MINGW platform!"

	# Check important existence
	func_validate_path_exist /ext
	func_validate_path_exist /ext/Documents		# TODO: is it really necessary?

	# Check owner of /ext
	local expect_owner="ouyangzhu:ouyangzhu"
	local real_owner=`ls -l / | sed -e "/->/d" | grep ext | awk '{print $3":"$4}'`
	[ "${real_owner}" != "${expect_owner}" ] && func_die "ERROR: owner of path '/ext/' must be ${expect_owner}"

}

function func_init_link() {
	func_param_check 2 "${FUNCNAME} <target_path> <source_path>" "$@"
	local target_path="$1"
	local source_path="$2"

	# check existence
	[ ! -e ${source_path} ] && echo "WARN: ${source_path} NOT exist, skip" && return 0
	[ -h "${target_path}" ] && echo "INFO: ${target_path} (link) already exist, skip" && return 0

	# if target is an empty dir, will replace it
	[ -d "${target_path}" ] && (( `ls ${target_path} 2> /dev/null | wc -l` == 0 )) && rmdir "${target_path}"

	echo "INFO: creating link ${target_path} --> ${source_path}"
	ln -s "${source_path}" "${target_path}"
}

function func_init_links() {
	echo ">>> `date "+%H:%M:%S"`: init links"
	func_init_link ${HOME}/.m2              /ext/Documents/os_spec_lu/m2_repo
	func_init_link ${HOME}/data             /ext/data
	func_init_link ${HOME}/program          /ext/Documents/os_spec_lu/program 	
	func_init_link ${HOME}/Documents        /ext/Documents
	func_init_link ${HOME}/dev/code_dw	/ext/Documents/os_spec_lu/dev/code_dw	
	func_init_link ${HOME}/dev/code_src	/ext/Documents/os_spec_lu/dev/code_src	
	func_init_link ${HOME}/dev/code_repo	/ext/Documents/os_spec_lu/dev/code_repo	
	func_init_link ${HOME}/dev/code_stage	/ext/Documents/os_spec_lu/dev/code_stage	
}

function func_init_myenv() {
	echo ">>> `date "+%H:%M:%S"`: init myenv"

	if [ -e "${HOME}/.myenv/init/myenv.sh" ] ; then 
		bash ${HOME}/.myenv/init/myenv.sh 
	else
		local myenv_tmp=${tmp_init_dir}/myenv.sh
		local myenv_url=https://raw.github.com/stico/myenv/master/.myenv/init/myenv.sh
		rm ${myenv_tmp}
		wget -O ${myenv_tmp} -q ${myenv_url} || func_die "ERROR: failed to download ${myenv_url}"
		[ -e "${myenv_tmp}" ] && bash ${myenv_tmp}
	fi
}

function func_init_sudoer() {
	echo ">>> `date "+%H:%M:%S"`: update /etc/sudoers"

	sudo grep "sudo.*NOPASSWD:" /etc/sudoers &> /dev/null && echo "INFO: /etc/sudoers already updated, skip" && return 0

	func_bak_file /etc/sudoers
	sudo sed -i '/%sudo/s/(ALL:ALL)/NOPASSWD:/' /etc/sudoers
}

function func_init_apt_config() {
	local src_files=( /etc/apt/sources.list /etc/apt/sources.list.d/official-package-repositories.list )
	echo ">>> `date "+%H:%M:%S"`: update ${src_files}"

	# Update source mirror for speed
	local mirror_addr=mirrors.163.com		# another candidate (in China, also 163's): http://ubuntu.cn99.com/ubuntu
	for src_file in "${src_files[@]}"; do 
		grep "${mirror_addr}" "${src_file}" &> /dev/null && echo "INFO: ${src_file} already updated, skip" && continue
		( ! grep "^[^#]*ubuntu.com" "${src_file}" ) &> /dev/null && echo "INFO: ${src_file} NOT need updated, skip" && continue

		func_bak_file "${src_file}" 
		echo "INFO: update ${src_file} with mirror: ${mirror_addr}"
		#sudo sed -i -e "/ubuntu.com/p;s/[^\/]*\.ubuntu\.com/${mirror_addr}/" ${src_file}	# reserve original source
		sudo sed -i -e "s/[^\/]*\.ubuntu\.com/${mirror_addr}/" ${src_file}			# replace original source
	done
}

# Action
func_pre_check
func_init_sudoer	# 1st time need manual input, so make it happens earlier 
func_init_links
func_init_myenv

# Action - apt
func_init_apt_config

# TO SORT
#mkdir -p ~/amp/{download,delete}
