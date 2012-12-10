#!/bin/bash

# this file is used by login shell
# so only show things you want to see in login, and other thiings in .bashrc
if [ -f ~/.bashrc ]; then
   source ~/.bashrc
fi

# following is for key auth
#SSHAGENT=/usr/bin/ssh-agent
#SSHAGENTARGS="-s"
#if [ -z "$SSH_AUTH_SOCK" -a -x "$SSHAGENT" ]; then
#	eval `$SSHAGENT $SSHAGENTARGS`
#	trap "kill $SSH_AGENT_PID" 0
#fi

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME//.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
