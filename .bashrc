#!/bin/bash

umask 077

# enable completion (let it run first, as init/lu.sh need turn off some completion on cygwin)
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# init myenv
. $HOME/.myenv/init/lu.sh

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

# to avoid ^s/^q to frozen/unfrozen the terminal (so vim could also use ^q for blockwise edit)
stty -ixon
stty -ixoff
#stty stop ''


########################## Below are just copied from example file ########################## 

# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi
