#!/bin/bash

# TODO: seems cygwin init is very slow
# NOTE: unison remote style can not accept .bashrc have output

# set flags
[ $(uname -s | grep -c CYGWIN) -eq 1 ] && os_cygwin="true" || os_cygwin="false"
[ $(uname -s | grep -c MINGW) -eq 1 ]  && os_mingw="true"  || os_mingw="false"
[ $(uname -s | grep -c Darwin) -eq 1 ] && os_osx="true"    || os_osx="false"

# os specific
[ "$os_cygwin" = "true" -o "$os_mingw" = "true" ] && umask 000 || umask 077
[ "$os_cygwin" = "false" -a -f /etc/bash_completion ] && source /etc/bash_completion 	# very slow in cygwin, run it first, init/bash.sh need turn off some completion on cygwin
if [ "$os_osx" = "true" ] ; then
	# NOTE: since myenv depends on GNU utilities, so NEED set PATH at beginning, even the PATH will be overwrite by later script
	# Macports Path
	macports_path="/opt/local"
	[ -e $macports_path ] && export PATH=$macports_path:$macports_path/bin:$macports_path/libexec/gnubin/:$PATH:

	# Fink Path
	#fink_cu_path="/sw/lib/coreutils/bin"
	#test -r /sw/bin/init.sh && . /sw/bin/init.sh	# will add "/sw/bin:/sw/sbin:"
	#[ -e $fink_cu_path ] && export PATH=$PATH:$fink_cu_path || echo "WARN: missing basic commands, try 'sudo apt-get install coreutils' (via fink)"
fi

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# init basic env
SHELL="/bin/bash" [ -f ~/.dir_colors ] && eval `dircolors -b ~/.dir_colors` || eval `dircolors -b /etc/DIR_COLORS`

# for login shell we not want this variable set, but osx need this
#uname | grep -q Darwin || export DISPLAY=

# Init myenv, including common functions
bash_init=$HOME/.myenv/init/bash.sh
bash_local=$HOME/.myenv/init/bashrc.$(hostname)
bash_local_2=$HOME/.myenv/init/bashrc.$(cat /var/lib/dbus/machine-id 2> /dev/null)
[ -e $bash_init ] && source $bash_init
[ -e $bash_local ] && source $bash_local
[ -e $bash_local_2 ] && source $bash_local_2

# Init ssh agent
func_ssh_agent_init

stty -ixon		# avoid ^s/^q to frozen/unfrozen terminal (so vim could also use those keys)
stty -ixoff

shopt -s checkwinsize	# check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
shopt -s histappend	# append to the history file, don't overwrite it
shopt -s histreedit	# puts a failed history substitution back on the command line for re-editing
#shopt -s histverify	# (caution to use it, since most system not use it, train yourself that way) puts the command to be executed after a substitution on command line as if you had typed it

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"					# make less more friendly for non-text input files, see lesspipe(1)
[ -e /etc/infinality-settings.sh ] && . /etc/infinality-settings.sh				# infinality font rendering config
[ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ] && debian_chroot=$(cat /etc/debian_chroot)	# set variable identifying the chroot you work in (used in the prompt below)

# platform depended operation
if [ "$os_cygwin" = "false" ] ; then
	complete -F _known_hosts scpx
	complete -F _known_hosts sshx
	complete -F _known_hosts ssht
	# Auto complete (2013-09-9, LM15 need use ssh <tab> to "init" _ssh, otherwise not work, why?)
	#complete -o default -o nospace -F _scp scpx			# not work in ubuntu 13.04 unless firstly use ssh <tab> "trigger" it first
	#complete -o default -o nospace -F _ssh sshx
	#complete -o default -o nospace -F _ssh ssht
	#`complete | grep -q " dd$"` && complete -r dd			# Check before remove, since alias conflict with /bin/dd, disable /bin/dd complete. 
	#complete -r vi vim gvim unzip					# vi complete seems very annoying (shows help of gawk!) on cygwin # seems fix in cygwin 1.17

	# set diff prompt for internal machine and external machine 
	internetIpCount=$(func_ip | grep -v -c '^\(172\.\|192\.\|10\.\|127.0.0.1\|fc00::\|fe80::\|::1\)')
	if `grep -q "^bash_prompt_color=green" $HOME/.myenv/init/bashrc.$(hostname) &> /dev/null` ; then
		export PS1="\[\e[32m\]\u@\h \[\e[32m\]\w\$\[\e[0m\]"				# Green line with $ in same line
	elif [ "$internetIpCount" -ge 1 ] ; then 
		#export PS1="\[\e[31m\]\u@\h \[\e[31m\]\w\[\e[0m\]\n\$"				# Red line with $ in next line
		export PS1="\[\e[31m\]\u@$(hostname -I | sed "s/ .*//"):\w\n\$\[\e[0m\]"	# Red line with $ in next line, prompt as scp address
	else 
		#export PS1="\[\e[34m\]\u@\h \[\e[34m\]\w\$\[\e[0m\]"				# Blue line with $ in same line
		export PS1="\[\e[34m\]\u@$(hostname -I | sed "s/ .*//"):\w\$\[\e[0m\]"		# Blue line with $ in same line, prompt as scp address
	fi
else
	# Green line with $ in same line
	export PS1="\[\e[32m\]\u@\h \[\e[32m\]\w\$\[\e[0m\]"
fi

################################################################################
# Deprecated
################################################################################

################################################################################
# Below are not added manually, clean them up!
################################################################################
