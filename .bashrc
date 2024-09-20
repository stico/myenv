#!/bin/bash
# shellcheck disable=1090,1091

# NOTE: many tool (e.g. unison) can not accept .bashrc have output in remote style 

# Pre-Check
#[ -z "$PS1" ] && return		# (moved to ~/.bash_profile, since return only valid in function. If not running interactively, just return

# Variables
MACPORTS_PATH="/opt/local"
HOMEBREW_PATH="/opt/homebrew"
COMPLETION="/etc/bash_completion"
HOST_NAME="$(hostname -s)"

# Misc
stty -ixon			# avoid ^s/^q to frozen/unfrozen terminal (so vim could also use those keys)
stty -ixoff
shopt -s histappend
shopt -s histreedit
shopt -s checkwinsize

# Step 1: set PATH for OSX/{macports,homebrew} to use correct tool
if uname -s | grep -iq darwin ; then
	# note, need use the man dir, since lapmac3 (use homebrew) also have dir: /usr/local/bin 
	if [ -d "${MACPORTS_PATH}/man" ] ; then		
		export PATH="${MACPORTS_PATH}/bin:${MACPORTS_PATH}/sbin:${MACPORTS_PATH}/libexec/gnubin/:${PATH}:"	
	elif [ -d "${HOMEBREW_PATH}" ] ; then
		export PATH="${HOMEBREW_PATH}/bin:${HOMEBREW_PATH}/sbin:${HOMEBREW_PATH}/opt/coreutils/libexec/gnubin:${PATH}:"	
	fi
fi

# Step 2: dircolors, must after PATH setting to compitable with OSX (macports or homebrew: libexec/gnubin/dircolors)
# TODO: "set -x" show the cmd runs in sub-shell, is it really work?
if [[ -f "${HOME}/.dir_colors" ]] ; then
	SHELL="/bin/bash" eval "$(dircolors -b ~/.dir_colors)"
else
	SHELL="/bin/bash" eval "$(dircolors -b /etc/DIR_COLORS)"		
fi

# Step 3: completion, sys and self-define cmd
# NOTE: unison remote style can NOT accept .bashrc have output
source "${COMPLETION}" >/dev/null 2>&1
source "${MACPORTS_PATH}/${COMPLETION}" >/dev/null 2>&1
source "${HOMEBREW_PATH}/etc/profile.d/bash_completion.sh" >/dev/null 2>&1
complete -F _known_hosts scpx sshx ssht

# Step 4: Source env (zb before me, since zb/me_lib.sh might out of sync)
source "${HOME}/.zbox/zbox_func.sh" >/dev/null 2>&1
source "${HOME}/.myenv/myenv_func.sh" >/dev/null 2>&1
source "${HOME}/.myenv/conf/env/env.sh" >/dev/null 2>&1
source "${HOME}/.myenv/conf/bash/bashrc.${HOST_NAME}" >/dev/null 2>&1
source "${HOME}/.myenv/conf/bash/bashrc.$(cat /var/lib/dbus/machine-id 2> /dev/null)" >/dev/null 2>&1
#source "${HOME}/.myenv/conf/addi/local_bashrc" >/dev/null 2>&1

# Step 5: source dist tag env for internal and production machine 
func_is_personal_machine || func_dist_source_env 

# Step 6: Tool update
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"				# make less more friendly for non-text input files, see lesspipe(1)
source /etc/infinality-settings.sh >/dev/null 2>&1					# infinality font rendering config

# Step 7: Settings for diff machine type
if func_is_personal_machine ; then
	umask 077									# only set this for personal machie
	func_ssh_agent_init &> /dev/null						# Init ssh agent

	if [[ "${HOST_NAME}" = lapmac2 ]] ; then
		export PS1="\[\e[32m\]\w\$\[\e[0m\]"					# Green line with $ in same line
		#export PS1="\[\e[32m\]\u@\h \[\e[32m\]\w\$\[\e[0m\]"			# Green line with $ in same line
	else
		export PS1="\[\e[36m\]\w\$\[\e[0m\]"					# Cyan
	fi
elif func_is_internal_machine ; then 
	func_ssh_agent_init &> /dev/null						# Init ssh agent
	LOCAL_IP=$(func_ip_list | sed -e 's/.*\s\+//;/^10\./d;/^\s*$/d' | head -1)	# alternative (NOT work on ubuntu 9.04): $(hostname -I|sed "s/ .*//")
	#export PS1="\[\e[34m\]\u@\h \[\e[34m\]\w\$\[\e[0m\]"				# Blue line with $ in same line
	#export PS1="\[\e[34m\]\u@${LOCAL_IP}:\w\$\[\e[0m\]"				# Blue line with $ in same line, prompt as scp address
	#export PS1="\[\e[34m\]${LOCAL_IP}:\w\$\[\e[0m\]"				# Blue line with $ in same line, prompt as scp address without username
	export PS1="\[\e[34m\]\H:\w\$\[\e[0m\]"						# Blue line with $ in same line, with full hostname
else 
	LOCAL_IP=$(func_ip_list | sed -e 's/.*\s\+//;/^10\./d;/^\s*$/d' | head -1)	# alternative (NOT work on ubuntu 9.04): $(hostname -I|sed "s/ .*//")
	#export PS1="\[\e[31m\]\u@\h \[\e[31m\]\w\[\e[0m\]\n\$"				# Red line with $ in next line
	#export PS1="\[\e[31m\]\u@${LOCAL_IP}:\w\n\$\[\e[0m\]"				# Red line with $ in next line, prompt as scp address
	export PS1="\[\e[31m\]${LOCAL_IP}:\w\n\$\[\e[0m\]"				# Red line with $ in next line, prompt as scp address without username
fi

################################################################################
# Deprecated
################################################################################

# CYGWIN/MINGW related
#[ $(uname -s | grep -c MINGW) -eq 1 ]  && os_mingw="true"  || os_mingw="false"
#[ $(uname -s | grep -c CYGWIN) -eq 1 ] && os_cygwin="true" || os_cygwin="false"
#[ "$os_cygwin" = "true" -o "$os_mingw" = "true" ] && umask 000 || umask 077
#[ "$os_cygwin" = "false" -a -f /etc/bash_completion ] && source /etc/bash_completion 	# very slow in cygwin, run it first, init/bash.sh need turn off some completion on cygwin
#if [ "$os_cygwin" = "false" ] ; then
#	# Green line with $ in same line
#	export PS1="\[\e[32m\]\u@\h \[\e[32m\]\w\$\[\e[0m\]"
#fi

# OSX related
# for login shell we not want this variable set, but osx need this
#uname | grep -q Darwin || export DISPLAY=
#[ $(uname -s | grep -c Darwin) -eq 1 ] && os_osx="true"    || os_osx="false"
#if [ "$os_osx" = "true" ] ; then
#	# NOTE: since myenv depends on GNU utilities, so NEED set PATH at beginning, even the PATH will be overwrite by later script
#	# Macports Path
#	macports_path="/opt/local"
#	[ -e $macports_path ] && export PATH=$macports_path:$macports_path/bin:$macports_path/libexec/gnubin/:$PATH:
#
#	# Fink Path
#	#fink_cu_path="/sw/lib/coreutils/bin"
#	#test -r /sw/bin/init.sh && . /sw/bin/init.sh	# will add "/sw/bin:/sw/sbin:"
#	#[ -e $fink_cu_path ] && export PATH=$PATH:$fink_cu_path || echo "WARN: missing basic commands, try 'sudo apt-get install coreutils' (via fink)"
#fi

# MISC
#[ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ] && debian_chroot=$(cat /etc/debian_chroot)	# set variable identifying the chroot you work in (used in the prompt below)

################################################################################
# Below are not added manually, clean them up!
################################################################################
