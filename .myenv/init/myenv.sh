#!/bin/bash

# Usage
#       V1 (2017-01): works
#       V1: rm /tmp/myenv.sh ; wget -O /tmp/myenv.sh -q https://raw.github.com/stico/myenv/master/.myenv/init/myenv.sh && bash /tmp/myenv.sh 
#       V2 (2017-01): NOT work any more, gets nothing 
#       V2: curl https://raw.github.com/stico/myenv/master/.myenv/init/myenv.sh | bash

# Design
#       Repeatable: status check
#       Compatible: personal env, test env, public env

# Config
DATED_BACKUP_PATH=${HOME}/Documents/DCB/DatedBackup

# Variable & Prepare, TODO: shorten the names
tmp_tag="_me_init_"
tmp_init_dir=/tmp/${tmp_tag}/`date "+%m%d_%H%M%S"`
tmp_init_log=${tmp_init_dir}/init.log
umask 077
mkdir -p ${tmp_init_dir}
cd ${tmp_init_dir}

# Steps
func_source_lib() {
	local func=myenv_func.sh 
	echo "INFO: --STEP-- source ${func} (which also source lib functions)"

	if [ -f ./${func} ] ; then
		echo "INFO: use ${func} in current dir: $PWD"
		source ./${func}
	elif [ -f ${HOME}/.myenv/${func} ] ; then
		echo "INFO: use ${func} in myenv dir: ${HOME}/.myenv"
		source ${HOME}/.myenv/${func}
	else
		echo "INFO: download ${func} from github to tmp dir: ${tmp_init_dir}"
		wget -q -O ${tmp_init_dir}/myenv_lib.sh "https://raw.github.com/stico/myenv/master/.myenv/myenv_lib.sh"
		wget -q -O ${tmp_init_dir}/myenv_func.sh "https://raw.github.com/stico/myenv/master/.myenv/myenv_func.sh"
		\cd ${tmp_init_dir}
		source ${func}
		\cd -
	fi
}

func_init_dirs() {
	echo "INFO: --STEP-- init basic dirs and links"

	mkdir -p ~/amp/delete

	func_link_init ${HOME}/Documents /ext/Documents
	func_link_init ${HOME}/.m2 /ext/Documents/FCS/maven/m2_repo

	[ -e ~/Downloads ] && func_link_init ~/amp/download ~/Downloads
}

func_init_git_via_apt() {
	echo "INFO: --STEP-- init git command"

	# check
	func_is_cmd_exist git && echo "INFO: cmd git already exist, skip init git" && return 0 
	func_complain_privilege_not_sudoer "WARN: NO sudo privilege, will skip install git via apt-get" && return 1

	# Note 0: check if user have sudo privilege
	# Note 1: the git install command should be separate, seems its fail will make other package not continue
	echo "INFO: install git via apt-get"
	sudo apt-get update 
	sudo apt-get install -y libcurl4-gnutls-dev libexpat1-dev gettext libz-dev openssl libssl-dev build-essential tree zip unzip subversion 
	sudo apt-get install -y git && func_is_cmd_exist git || echo "ERROR: failed to install git via apt-get" && return 1 
}

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
		local zlib_name=$(ls | grep zlib-)
		[ ! -e "/tmp/$zlib_name" ] && echo "ERROR: failed to download source of zlib1g-dev" && exit 1
		cd /tmp/$zlib_name
		./configure --prefix=$HOME/dev/$zlib_name && make && make install
		local option_configure="$option_configure --with-zlib=$HOME/dev/$zlib_name "
		[ ! -e "$HOME/dev/$zlib_name" ] && echo "ERROR: failed to install dependency zlib1g-dev" && exit 1
	fi
	if ( ! dpkg -l | grep -q openssl ) ; then
		cd /tmp
		apt-get source openssl
		local openssl_name=$(ls | grep openssl-)
		[ ! -e "/tmp/$openssl_name" ] && echo "ERROR: failed to download source of openssl" && exit 1
		cd /tmp/$openssl_name
		./configure --prefix=$HOME/dev/$openssl_name && make && make install
		local option_configure="$option_configure --with-openssl=$HOME/dev/$openssl_name "
		[ ! -e "$HOME/dev/$openssl_name" ] && echo "ERROR: failed to install dependency openssl" && exit 1
	fi
	if ( ! dpkg -l | grep -q libcurl4-gnutls-dev ) ; then
		cd /tmp
		apt-get source libcurl4-gnutls-dev
		local curl_name=$(ls | grep curl-)
		[ ! -e "/tmp/$curl_name" ] && echo "ERROR: failed to download source of libcurl4-gnutls-dev" && exit 1
		cd /tmp/$curl_name

		if ( ! dpkg -l | grep -q openssl ) ; then
			./configure --prefix=$HOME/dev/$curl_name --with-ssl=$HOME/dev/$openssl_name  && make && make install
		else
			./configure --prefix=$HOME/dev/$curl_name --with-ssl && make && make install
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
	./configure --prefix="$git_target_path" $option_configure && make $option_make install

	ln -s "$git_target_path" "$git_target_link"
}

func_init_myenv() {
	echo "WARN: --STEP-- NOT implemented yet!!!"

	[ -e ${HOME}/.git ] && echo "INFO: ${HOME}/.git already exist, skip init myenv" && return 0
	func_init_myenv_via_git || func_init_myenv_via_http
}

func_init_myenv_via_http() {
	echo "WARN: --STEP-- NOT implemented yet!!!"
	echo "INFO: --STEP-- init myenv from github via http (ReadOnly)"
}

func_init_myenv_via_git() {
	echo "INFO: --STEP-- init myenv from github via git"

	local git_myenv_name=myenv
	local git_myenv_addr=git://github.com/stico/myenv.git
	#local git_myenv_addr=https://github.com/stico/myenv.git	# not work when libcurl not support https
	#local git_myenv_addr=git@github.com:stico/myenv.git		# need privilege

	[ -e ${HOME}/.git ] && echo "INFO: ${HOME}/.git already exist, skip init myenv" && return 0

	func_complain_cmd_not_exist git "ERROR: cmd git NOT exist, skip init myenv via git" && return 1

	\cd ${tmp_init_dir}
	\git clone $git_myenv_addr
	func_complain_path_not_exist ${tmp_init_dir}/${git_myenv_name}/.git "ERROR: fail to git clone from github" && return 1

	mv ${tmp_init_dir}/$git_myenv_name/* ${HOME}
	mv ${tmp_init_dir}/$git_myenv_name/.* ${HOME}

	\cd ${HOME}
	\git config --global user.email "stico@163.com"
	\git config --global user.name "stico"
	\git config --global push.default simple
	echo "INFO: myenv init success (git way)!"
	\cd -
}

func_init_myenv_unison() {
	echo "INFO: --STEP-- init myenv unison sync info from local datedbckup archive"

	# check
	local target=~/.unison
	func_complain_path_not_exist ${target} && return 1
	func_complain_path_not_exist ${DATED_BACKUP_PATH} && return 1
	\ls ${target}/ar* &> /dev/null && echo "INFO: unison sync info already exist, skip" && return 0

	# Find the backup. IMPORTANT: the host name must match, which is diff in func_init_myenv_secure()
	local zip_path=`find ${DATED_BACKUP_PATH} -name "*_$(hostname)*_myenv_*.zip" | sort | tail -1`
	func_complain_path_not_exist "${zip_path}" && return 1

	# Extract the backup
	local zip_filename=${zip_path##*/}
	local extract_path=${tmp_init_dir}/${zip_filename%.zip}
	[ -e "${extract_path}" ] && echo "INFO: extraction exist, reuse it" || func_uncompress ${zip_path} ${extract_path}

	# Find and copy
	local unison_bak=`find $extract_path -name ".unison" -type d | tail -1`
	\ls $unison_bak/fp* &> /dev/null && \ls $unison_bak/ar* &> /dev/null \
	&& echo "INFO: no unison sync info in backup" && return 0
	[ -e "$unison_bak" ] && cp -rf $unison_bak/{ar,fp}* ${target}
}

func_init_myenv_secure() {
	# TODO: use a var in head for better compatibility?
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
	local extract_path=${tmp_init_dir}/${zip_filename%.zip}
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

func_init_git_writable() {
	echo "INFO: --STEP-- try to update myenv git to writable mode"

	# check, git cmd already checked in func_init_myenv()
	local gname=stico_github
	func_complain_path_not_exist ~/.git "WARN: ~/.git not exist, myenv git still in readonly mode!" && return 1
	func_complain_path_not_exist ~/.ssh/${gname} "WARN: ~/.ssh/stico_github not exist, myenv git still in readonly mode!" && return 1

	\cd ${HOME}
	if (! \git remote -v | \grep -q ${gname}) ; then
		\git remote rm origin
		\git remote add origin "${gname}:stico/myenv.git"
		\git config --global user.name stico
		\git config --global user.email ouyzhu@gmail.com
		\git push --set-upstream origin master
	else
		echo "INFO: myenv already in writable mode"
	fi
	\cd -
}

func_pre_check() {
	echo "INFO: --STEP-- pre condition check (username, platform, doc path, etc)"

	# Check username
	[ "$(whoami)" != "ouyangzhu" ] && echo "WARN: username might wrong, which is: $(whoami) !" 

	# Check important existence
	func_complain_path_not_exist /ext/Documents "WARN: /ext/Documents not exist, some private info can NOT be init"

	# check user privilege
	func_complain_privilege_not_sudoer "WARN: current user NOT have sudo privilege, some cmd might fail"

	# Check platform
	uname -s | grep -q "MINGW\|CYGWIN " && func_stop "ERROR: can NOT run init on CYGWIN or MINGW platform!"
}

func_init_sudoer() {
	echo "INFO: --STEP-- update /etc/sudoers, use NOPASSWD way"

	# check current situation, -n will prevents sudo from prompting the user for a password, so check in "safe way"
	if ! sudo -n true 2>/dev/null && func_is_non_interactive ; then 
		echo "ERROR: CAN NOT continue in non-interactive mode without sudo granted (password input at least once)."
		exit 1
	fi

	# check if already performed
	if sudo grep "sudo.*NOPASSWD:" /etc/sudoers &> /dev/null ; then
		echo "INFO: /etc/sudoers already updated, skip"
		return 0
	fi

	func_duplicate_dated /etc/sudoers
	sudo sed -i '/%sudo/s/(ALL:ALL)/NOPASSWD:/' /etc/sudoers
}

func_init_apt_distupgrade() {
	# TODO: seems the time check is unnecessary, the cmd is very fast in ubuntu 16.04
	echo "INFO: --STEP-- apt dist-upgrade"

	# Check if long enough to run again. NOTE: this file should NOT in ${tmp_init_dir}, as need across diff init
	local apt_upgrade_stamp=/tmp/${tmp_tag}/apt-dist-upgrade-success-stamp
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

func_init_apt_install_basic() {
	echo "INFO: --STEP-- install basic softwares"

	sudo apt-get install -y dkms				# Dynamic Kernel Module Support
	sudo apt-get install -y aptitude			
	sudo apt-get install -y autossh w3m			# dev tools
	sudo apt-get install -y expect unison 			
	sudo apt-get install -y linux-headers-`uname -r`	# some soft compile need this
	sudo apt-get install -y git subversion mercurial	# dev tools
	sudo apt-get install -y openssh-server samba curl	
	sudo apt-get install -y build-essential make gcc cmake	# build tools
	sudo apt-get install -y zip unzip unrar p7zip p7zip-rar	

	#sudo apt-get install -y tmux autossh w3m		# dev tools
	#sudo apt-get install -y debconf-utils			# help auto select when install software (like mysql, wine, etc)
}

# Init. NOTE: the sequence is important!
echo "INFO: init start, log in tmp dir: ${tmp_init_log}"
func_source_lib			# func_pipe_filter NOT work here
func_init_sudoer		| func_pipe_filter "${tmp_init_log}"	# seq front since need fail fast
func_pre_check			| func_pipe_filter "${tmp_init_log}"
flocal last_stamp=unc_init_dirs			| func_pipe_filter "${tmp_init_log}"
func_init_git_via_apt		| func_pipe_filter "${tmp_init_log}"
func_init_myenv_via_git		| func_pipe_filter "${tmp_init_log}"
func_init_myenv_secure		| func_pipe_filter "${tmp_init_log}"
func_init_myenv_unison		| func_pipe_filter "${tmp_init_log}"
func_init_git_writable		| func_pipe_filter "${tmp_init_log}"
func_init_apt_distupgrade	| func_pipe_filter "${tmp_init_log}"	
func_init_apt_install_basic	| func_pipe_filter "${tmp_init_log}"
