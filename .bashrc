#!/bin/bash

if [[ `uname -s` == CYGWIN* ]] || [[ `uname -s` == MINGW* ]] ; then
	umask 000
else
	umask 077
fi

# enable completion (let it run first, as init/lu.sh need turn off some completion on cygwin)
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# init myenv
. $HOME/.myenv/init/lu.sh
rbvenvload

# init auto complete
complete -o nospace -F _scp scpx
complete -F _ssh sshx

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# the dircolors need this env to work
export SHELL="/bin/bash"

# Enable colors for ls, etc.  Prefer ~/.dir_colors #64489 
if [[ -f ~/.dir_colors ]]; then 
        eval `dircolors -b ~/.dir_colors` 
else 
        eval `dircolors -b /etc/DIR_COLORS` 
fi 

stty -ixon		# avoid ^s/^q to frozen/unfrozen terminal (so vim could also use those keys)
stty -ixoff

shopt -s checkwinsize	# check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
shopt -s histappend	# append to the history file, don't overwrite it
shopt -s histreedit	# puts a failed history substitution back on the command line for re-editing
#shopt -s histverify	# (caution to use it, since most system not use it, train yourself that way) puts the command to be executed after a substitution on command line as if you had typed it


########################## Below are just copied from example file ########################## 

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

PATH=$PATH:$HOME//.rvm/bin # Add RVM to PATH for scripting
