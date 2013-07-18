#!/bin/bash

# TODO: seems cygwin init is very slow

# set flags
[ $(uname -s | grep -c CYGWIN) -eq 1 ] && os_cygwin="true" || os_cygwin="false"
[ $(uname -s | grep -c MINGW) -eq 1 ] && os_mingw="true" || os_mingw="false"

# init basic env
[ "$os_cygwin" = "true" -o "$os_mingw" = "true" ] && umask 000 || umask 077
[ "$os_cygwin" = "false" -a -f /etc/bash_completion ] && source /etc/bash_completion 	# very slow in cygwin, run it first, init/bash.sh need turn off some completion on cygwin
SHELL="/bin/bash" [ -f ~/.dir_colors ] && eval `dircolors -b ~/.dir_colors` || eval `dircolors -b /etc/DIR_COLORS`

# platform depended operation
if [ "$os_cygwin" = "false" ] ; then

	# init auto complete
	complete -o nospace -F _scp scpx
	complete -F _ssh sshx
	`complete | grep -q " dd$"` && complete -r dd			# Check before remove, since alias conflict with /bin/dd, disable /bin/dd complete. 
	#complete -r vi vim gvim unzip	# vi complete seems very annoying (shows help of gawk!) on cygwin # seems fix in cygwin 1.17

	# set diff prompt for internal machine and external machine 
	internetIpCount=$(/sbin/ifconfig | sed -n -e '/inet addr/s/.*inet addr:\([.0-9]*\).*/\1/p' | grep -v -c '\(172\.\|192\.\|10\.\|127.0.0.1\)')
	if [ $internetIpCount -ge 1 ] ; then 
		export PS1="\[\e[31m\]\u@\h \[\e[31m\]\w\[\e[0m\]\n\$"
	else 
		export PS1="\[\e[32m\]\u@\h \[\e[33m\]\w\$\[\e[0m\]"
	fi
else
	export PS1="\[\e[32m\]\u@\h \[\e[33m\]\w\$\[\e[0m\]"
fi

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Init rvm step 1: rvm hacks command "cd", record it before myenv loads func_cd 
[ -e /home/ouyangzhu/.rvm/scripts/rvm ] && source /home/ouyangzhu/.rvm/scripts/rvm
[ "$(type -t cd)" = "function" ] && eval "function func_rvm_cd $(type cd | tail -n +3)"

# Init myenv
source $HOME/.myenv/init/bash.sh
[ -e $HOME/.bashrc_local ] && source $HOME/.bashrc_local

# Init rvm step 2: rvm need update path to use specific ruby version, this should invoke after myenv set PATH var
# The unison remote style can not accept .bashrc have output
#rvm use ruby-1.9.3-p327@global --default
rvm use ruby-1.9.3-p327@global --default &> /dev/null

# call functions
func_ssh_agent_init

stty -ixon		# avoid ^s/^q to frozen/unfrozen terminal (so vim could also use those keys)
stty -ixoff

shopt -s checkwinsize	# check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
shopt -s histappend	# append to the history file, don't overwrite it
shopt -s histreedit	# puts a failed history substitution back on the command line for re-editing
#shopt -s histverify	# (caution to use it, since most system not use it, train yourself that way) puts the command to be executed after a substitution on command line as if you had typed it


########################## Below are just copied from example file

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

################################################################################
# Deprecated
################################################################################

################################################################################
# Below are not added manually, clean them up!
################################################################################
source ~/.rvm/scripts/rvm

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
source ~/.rvm/scripts/rvm
source ~/.rvm/scripts/rvm
source ~/.rvm/scripts/rvm
