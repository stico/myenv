#!/bin/bash
# shellcheck disable=1090

# NOTE: many tool (e.g. unison) can not accept .bashrc have output in remote style 

# Pre-Check
[ -z "$PS1" ] && return		# If not running interactively, just return

# Variables
MACPORTS="/opt/local"
COMPLETION="/etc/bash_completion"
SRC_ZBOX_FUNC=${HOME}/.zbox/zbox_func.sh
SRC_BASH_ENV=${HOME}/.myenv/conf/env/env.sh
SRC_BASH_FUNC=${HOME}/.myenv/myenv_func.sh
SRC_BASH_LOCAL=${HOME}/.myenv/conf/bash/bashrc.local
SRC_BASH_HOSTNAME=${HOME}/.myenv/conf/bash/bashrc.$(hostname)
SRC_BASH_MACHINEID=${HOME}/.myenv/conf/bash/bashrc.z.mid.$(cat /var/lib/dbus/machine-id 2> /dev/null)

# Misc
stty -ixon			# avoid ^s/^q to frozen/unfrozen terminal (so vim could also use those keys)
stty -ixoff
shopt -s histappend
shopt -s histreedit
shopt -s checkwinsize
uname -s | grep -iq darwin && [ -d "${MACPORTS}" ] && export PATH="${MACPORTS}:${MACPORTS}/bin:${MACPORTS}/libexec/gnubin/:${PATH}:"	# OSX: macports path must be in the front 

# shellcheck disable=2015
SHELL="/bin/bash" [ -f ~/.dir_colors ] && eval "$(dircolors -b ~/.dir_colors)" || eval "$(dircolors -b /etc/DIR_COLORS)"		# must after PATH setting to compitable with OSX (/opt/local/libexec/gnubin//dircolors)

# Completion
[ -f "${COMPLETION}" ] && source "${COMPLETION}"
[ -f "${MACPORTS}/${COMPLETION}" ] && source "${MACPORTS}/${COMPLETION}"
complete -F _known_hosts scpx sshx ssht

# Source files
[ -e "${SRC_BASH_ENV}" ] && source "${SRC_BASH_ENV}"
[ -e "${SRC_ZBOX_FUNC}" ] && source "${SRC_ZBOX_FUNC}"
[ -e "${SRC_BASH_FUNC}" ] && source "${SRC_BASH_FUNC}"
[ -e "${SRC_BASH_HOSTNAME}" ] && source "${SRC_BASH_HOSTNAME}"
[ -e "${SRC_BASH_MACHINEID}" ] && source "${SRC_BASH_MACHINEID}"

# source dist tag env for internal and production machine 
func_is_personal_machine || func_dist_source_env 

# Tool update
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"				# make less more friendly for non-text input files, see lesspipe(1)
# shellcheck disable=1091
[ -e /etc/infinality-settings.sh ] && source /etc/infinality-settings.sh		# infinality font rendering config

# Settings for diff machine type
if func_is_personal_machine ; then
	umask 077									# only set this for personal machie
	func_ssh_agent_init								# Init ssh agent
	export PS1="\[\e[32m\]\u@\h \[\e[32m\]\w\$\[\e[0m\]"				# Green line with $ in same line
elif func_is_internal_machine ; then 
	func_ssh_agent_init								# Init ssh agent
	LOCAL_IP=$(func_ip_list | sed -e 's/.*\s\+//;/^10\./d;/^\s*$/d' | head -1)	# alternative (NOT work on ubuntu 9.04): $(hostname -I|sed "s/ .*//")
	#export PS1="\[\e[34m\]\u@\h \[\e[34m\]\w\$\[\e[0m\]"				# Blue line with $ in same line
	export PS1="\[\e[34m\]\u@${LOCAL_IP}:\w\$\[\e[0m\]"				# Blue line with $ in same line, prompt as scp address
else 
	LOCAL_IP=$(func_ip_list | sed -e 's/.*\s\+//;/^10\./d;/^\s*$/d' | head -1)	# alternative (NOT work on ubuntu 9.04): $(hostname -I|sed "s/ .*//")
	#export PS1="\[\e[31m\]\u@\h \[\e[31m\]\w\[\e[0m\]\n\$"				# Red line with $ in next line
	export PS1="\[\e[31m\]\u@${LOCAL_IP}:\w\n\$\[\e[0m\]"				# Red line with $ in next line, prompt as scp address
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
