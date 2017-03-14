#!/bin/bash

# NOTE: many tool (e.g. unison) can not accept .bashrc have output in remote style 

# Pre-Check
[ -z "$PS1" ] && return		# If not running interactively, just return

# Variables
MACPORTS="/opt/local"
COMPLETION="/etc/bash_completion"
SRC_ZBOX_FUNC=${HOME}/.zbox/zbox_func.sh
SRC_BASH_COMMON=${HOME}/.myenv/conf/bash/bashrc.common
SRC_BASH_HOSTNAME=${HOME}/.myenv/conf/bash/bashrc.$(hostname)
SRC_BASH_MACHINEID=${HOME}/.myenv/conf/bash/bashrc.z.mid.$(cat /var/lib/dbus/machine-id 2> /dev/null)

# Misc
umask 077
stty -ixon			# avoid ^s/^q to frozen/unfrozen terminal (so vim could also use those keys)
stty -ixoff
shopt -s histappend
shopt -s histreedit
shopt -s checkwinsize
SHELL="/bin/bash" [ -f ~/.dir_colors ] && eval `dircolors -b ~/.dir_colors` || eval `dircolors -b /etc/DIR_COLORS`
uname -s | grep -iq darwin && [ -d "${MACPORTS}" ] && export PATH="${MACPORTS}:${MACPORTS}/bin:${MACPORTS}/libexec/gnubin/:${PATH}:"	# OSX: macports path must be in the front 

# Completion
[ -f "${COMPLETION}" ] && source "${COMPLETION}"
[ -f "${MACPORTS}/${COMPLETION}" ] && source "${MACPORTS}/${COMPLETION}"
complete -F _known_hosts scpx sshx ssht

# Source files
[ -e "${SRC_ZBOX_FUNC}" ] && source "${SRC_ZBOX_FUNC}"
[ -e "${SRC_BASH_COMMON}" ] && source "${SRC_BASH_COMMON}"
[ -e "${SRC_BASH_HOSTNAME}" ] && source "${SRC_BASH_HOSTNAME}"
[ -e "${SRC_BASH_MACHINEID}" ] && source "${SRC_BASH_MACHINEID}"

# Tool update
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"			# make less more friendly for non-text input files, see lesspipe(1)
[ -e /etc/infinality-settings.sh ] && . /etc/infinality-settings.sh		# infinality font rendering config

# Settings for diff machine type
if `cat ${SRC_BASH_HOSTNAME} ${SRC_BASH_MACHINEID} 2>/dev/null | grep -q "^bash_prompt_color=green" &> /dev/null` ; then
	func_ssh_agent_init							# Init ssh agent
	export PS1="\[\e[32m\]\u@\h \[\e[32m\]\w\$\[\e[0m\]"			# Green line with $ in same line
elif func_ip | grep -q '[^0-9\.]\(172\.\|192\.\|fc00::\|fe80::\)' ; then 
	func_ssh_agent_init							# Init ssh agent
	#export PS1="\[\e[34m\]\u@\h \[\e[34m\]\w\$\[\e[0m\]"			# Blue line with $ in same line
	export PS1="\[\e[34m\]\u@$(hostname -I|sed "s/ .*//"):\w\$\[\e[0m\]"	# Blue line with $ in same line, prompt as scp address
else 
	#export PS1="\[\e[31m\]\u@\h \[\e[31m\]\w\[\e[0m\]\n\$"			# Red line with $ in next line
	export PS1="\[\e[31m\]\u@$(hostname -I|sed "s/ .*//"):\w\n\$\[\e[0m\]"	# Red line with $ in next line, prompt as scp address
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
