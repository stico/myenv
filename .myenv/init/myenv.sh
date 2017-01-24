#!/bin/bash

# One line cmd
# V1 (2017-01): works
# V1: rm /tmp/myenv.sh ; wget -O /tmp/myenv.sh -q https://raw.github.com/stico/myenv/master/.myenv/init/myenv.sh && bash /tmp/myenv.sh 
# V2 (2017-01): NOT work any more, gets nothing 
# V2: curl https://raw.github.com/stico/myenv/master/.myenv/init/myenv.sh | bash

# Variable, TODO: shorten the names
tmp_init_dir=/tmp/init_myenv/`date "+%Y%m%d_%H%M%S"`
tmp_init_log=${tmp_init_dir}/init.log

# Source & Prepare
umask 077
mkdir -p ${tmp_init_dir}
cd ${tmp_init_dir}

func_source_lib(){
	local func=myenv_func.sh 

	echo "INFO: source ${func} (which also source lib functions)"
	if [ -f ./${func} ] ; then
		source ./${func}
	elif [ -f ${HOME}/.myenv/${func} ] ; then
		source ${HOME}/.myenv/${func}
	else
		wget -q -O ./myenv_lib.sh "https://raw.github.com/stico/myenv/master/.myenv/myenv_lib.sh"
		wget -q -O ./myenv_func.sh "https://raw.github.com/stico/myenv/master/.myenv/myenv_func.sh"
		source ./myenv_func.sh
	fi
}

func_init_git() {
	# Check if already exist
	func_is_cmd_exist git && echo "INFO: cmd git already exist, skip init git" && return 0 

	# Try install by system
	# Note 0: check if user have sudo priviledge
	# Note 1: the git install command should be separate, seems its fail will make other package not continue
	(sudo -n ls &> /dev/null) && sudo apt-get update 
	(sudo -n ls &> /dev/null) && sudo apt-get install -y libcurl4-gnutls-dev libexpat1-dev gettext libz-dev openssl libssl-dev build-essential tree zip unzip subversion 
	(sudo -n ls &> /dev/null) && sudo apt-get install -y git && return 0

	# TODO: the compile version need update
	# TODO: extract to another function?
	echo "WARN: the compile version of git is old, will NOT continue, pls solve it manually!"
	exit

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

function func_init_myenv {
	local git_myenv_name=myenv
	local git_myenv_addr=git://github.com/stico/myenv.git
	#local git_myenv_addr=https://github.com/stico/myenv.git	# not work when libcurl not support https
	#local git_myenv_addr=git@github.com:stico/myenv.git		# need priviledge

	[ -e ${HOME}/.git ] && echo "INFO: ${HOME}/.git already exist, skip init myenv" && return 0

	cd ${tmp_init_dir}
	( command -v git &> /dev/null ) && local git="git" || local git="${HOME}/dev/git/bin/git"

	$git clone $git_myenv_addr
	[ ! -e ${tmp_init_dir}/$git_myenv_name/.git ] && echo "ERROR: failed to init myenv, pls check!" && exit 1

	mv ${tmp_init_dir}/$git_myenv_name/* ${HOME}
	mv ${tmp_init_dir}/$git_myenv_name/.* ${HOME}

	cd ${HOME}
	$git config --global user.email "stico@163.com"
	$git config --global user.name "stico"
	$git config --global push.default simple
	echo "INFO: myenv init success (git way)!"
}

function func_init_myenv_secure {
	# Pre check 
	local datedbackup=${HOME}/Documents/DCB/DatedBackup
	[ -e ~/.ssh/config -o -e ~/.myenv/secu -o -e ~/.myenv/secure ] && echo "INFO: ~/.{ssh,myenv}/{secu,secure} already exist, skip init myenv secure" && return 0
	[ ! -e ${datedbackup} ] && echo "INFO: ${datedbackup} not exist, skip init myenv secure" && return 0

	# Find the backup
	local myenv_full_bak=`find ${datedbackup} -name "*_myenv_*.zip" | tail -1`
	[ ! -e "$myenv_full_bak" ] && echo "ERROR: $myenv_full_bak not exist, pls check!" && exit 1

	# Extract .ssh, secu, secure
	local tmp1=${myenv_full_bak%.zip}
	local myenv_full_bak_name=${tmp1##*/}
	rm -rf $tmp_init_dir/$myenv_full_bak_name 

	#TODO: use unzip instead!!!
	(command -v unzip &> /dev/null) && echo "INFO: install unzip to uncompress backup file" && sudo apt-get install unzip
	\cd $tmp_init_dir/$myenv_full_bak_name 
	unzip $myenv_full_bak 
	\cd -

	# Find and copy
	local ssh_bak=`find $tmp_init_dir -name ".ssh" -type d | tail -1`
	local secu_bak=`find $tmp_init_dir -name "secu" -type d | tail -1`
	local smbcr_bak=`find $tmp_init_dir -name ".smbcredentials" -type d | tail -1`
	mkdir -p ~/.ssh ~/.myenv/secu
	[ -e "$ssh_bak" ] && cp -rf $ssh_bak/* ~/.ssh/ 
	[ -e "$secu_bak" ] && cp -rf $secu_bak/* ~/.myenv/secu/ 
	[ -e "$smbcr_bak" ] && cp -rf $secu_bak/* ~/

	# Re-check
	[ ! -e ~/.ssh ] && echo "ERROR: restore ~/.ssh failed! pls check!" 
	[ ! -e ~/.myenv/secu -a ! -e ~/.myenv/scure ] && echo "ERROR: restore ~/.myenv/{secu,secure} failed! pls check!" 

	# Update origin remote
	cd ~
	git remote rm origin
	git remote add origin "stico_github:stico/myenv.git"
	git config --global user.name stico
	git config --global user.email ouyzhu@gmail.com
	git push --set-upstream origin master
}

func_pre_check() {
	echo "INFO: pre condition check (username, platform, doc path, etc)"

	# Check username
	[ "$(whoami)" != "ouyangzhu" ] && func_stop "ERROR: username must be 'ouyangzhu'!" 

	# Check platform
	uname -s | grep -q "MINGW\|CYGWIN " && func_stop "ERROR: can NOT run init on CYGWIN or MINGW platform!"

	# Check important existence
	func_validate_path_exist /ext /ext/Documents

	# Check owner of /ext
	func_validate_path_owner /ext "ouyangzhu:ouyangzhu"
}

# Init. NOTE: the sequence is important!
func_pre_check		| func_pipe_filter "${tmp_init_log}"
func_source_lib		| func_pipe_filter "${tmp_init_log}"
func_init_git
func_init_myenv
func_init_myenv_secure
