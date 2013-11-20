#!/bin/bash

# Command: rm /tmp/myenv.ro.LU.sh ; wget -O /tmp/myenv.ro.LU.sh -q https://raw.github.com/stico/myenv/master/.myenv/init/myenv.ro.LU.sh && bash /tmp/myenv.ro.LU.sh 

git_myenv_name=myenv
git_myenv_addr=https://github.com/stico/myenv.git
#git_myenv_addr=git@github.com:stico/myenv.git		# need priviledge

function init_git {
	
	# Check if already exist
	(command -v git &> /dev/null) && echo "INFO: git already exist, skip init git" && return 0 
	[ -e ${HOME}/dev/git ] && echo "INFO: git already exist, skip init git" && return 0

	# Try install by system
	# Note 1: the git install command should be separate, seems its fail will make other package not continue
	(sudo -n ls &> /dev/null) && sudo apt-get update 
	(sudo -n ls &> /dev/null) && sudo apt-get install -y libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev build-essential tree zip unzip subversion 
	(sudo -n ls &> /dev/null) && sudo apt-get install -y git && return 0

	# Try compile
	git_tar="git-1.8.4.3.tar.gz"
	git_name="${git_tar%%.tar.gz}"
	#git_url="https://git-core.googlecode.com/files/${git_tar}"
	git_url="https://www.kernel.org/pub/software/scm/git/${git_tar}"
	git_target_path="${HOME}/dev/${git_name}"
	git_target_link="${HOME}/dev/git"

	# Download source
	cd /tmp && rm -rf "$git_tar" "$git_name" && wget "$git_url" && tar zxvf "$git_tar" && cd "$git_name"
	[ "$?" -ne "0" ] && echo "ERROR: failed to get git source" && exit 1

	# Compile - prepare options
	# Note 1: not really need gettext (cause git could only use in English)
	# Note 2: not really need tcl_tk (cause git could only use command line)
	# Note 3: zlib1g-dev is a must
	option_make="NO_GETTEXT=1 NO_TCLTK=1"
	option_configure=""
	if dpkg -l | grep -q zlib1g-dev ; then
		cd /tmp
		apt-get source zlib1g-dev
		zlib_name=$(ls | grep zlib-)
		[ ! -e "/tmp/$zlib_name" ] && echo "ERROR: failed to install dependency zlib1g-dev" && exit 1
		cd /tmp/$zlib_name
		./configure --prefix=$HOME/dev/$zlib_name && make && make install
		option_configure="$option_configure --with-zlib=$HOME/dev/$zlib_name "
	fi

	# Compile
	rm -rf "$git_target_path" "$git_target_link"
	mkdir -p "$git_target_path"
	cd /tmp/"$git_name"
	#./configure --prefix="$git_target_path" --without-tcltk && make && make install
	#./configure --prefix=$HOME/dev/git-1.8.4.3 --with-zlib=$HOME/dev/zlib && make NO_GETTEXT=1 NO_TCLTK=1 install
	./configure --prefix="$git_target_path" $option_configure && make $option_make install

	ln -s "$git_target_path" "$git_target_link"
}

function init_env_with_git {
	echo "INFO: git command exist, use git way"

	tmp_init_dir=/tmp/myenv_init/`date "+%Y%m%d_%H%M%S"`
	mkdir -p $tmp_init_dir
	cd $tmp_init_dir
	( command -v git &> /dev/null ) && git="git" || git="${HOME}/dev/git/bin/git"

	$git clone $git_myenv_addr
	[ ! -e $tmp_init_dir/$git_myenv_name/.git ] && echo "ERROR: failed to init myenv, pls check!" && exit 1

	mv $tmp_init_dir/$git_myenv_name/* ${HOME}
	mv $tmp_init_dir/$git_myenv_name/.* ${HOME}
	#rm -rf ${HOME}/$git_myenv_name/

	cd ${HOME}
	$git remote add github $git_myenv_addr
	echo "INFO: myenv init success (git way)!"
}

# Deprecated: difficult to update system
function init_env_without_git {
	echo "Git not found, init myenv will not able to update, continue (N) [Y/N]?"
	read -e continue
	[ "$continue" != "Y" -a "$continue" != "y" ] && echo "Give up myenv init!" && return 1
	
	dir_name=myenv-master
	pkg_name=master.zip
	pkg_url=http://github.com/stico/myenv/archive/$pkg_name

	tmp_init_dir=/tmp/myenv_init/`date "+%Y%m%d_%H%M%S"`
	mkdir -p $tmp_init_dir
	cd $tmp_init_dir

	echo "downloading $pkg_url" && wget -q $pkg_url
	unzip $pkg_name
	[ ! -e $tmp_init_dir/$git_myenv_name/.myenv ] && echo "ERROR: failed to init myenv, pls check!" && exit 1

	mv -f $tmp_init_dir/$dir_name/* ${HOME}
	mv -f $tmp_init_dir/$dir_name/.* ${HOME}
	echo "INFO: myenv init success (unzip way)!"
}

[ -e ${HOME}/.git ] && echo "${HOME}/.git already exist, will not init (RO), pls check!" && exit 0

init_git
init_env_with_git
