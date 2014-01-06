#!/bin/bash

source ${HOME}/.myenv/myenv_func.sh || eval "$(wget -q -O - "https://raw.github.com/stico/myenv/master/.myenv/myenv_func.sh")" || exit 1

# Variable
keyconf_xfce_target=~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml
keyconf_xfce_source=$MY_ENV/conf/xfce/xfce4-keyboard-shortcuts.xml

# Dependencies
#sudo apt-get install -y tk xbindkeys-config		# for GUI dialogs, not really necessary
sudo apt-get install -y wmctrl tk xbindkeys xclip xdotool

func_bak_file $keyconf_xfce_target
mv -f $keyconf_xfce_target /tmp/
cp $keyconf_xfce_source $keyconf_xfce_target


echo "Need logout for XFCE keyboard settings to take effect, logout (N) [Y/N]?"
read -e continue                                                                                           
[ "$continue" != "Y" -a "$continue" != "y" ] && echo "Give up, pls logout and login later" && exit 1
( command -v xfce4-session-logout &> /dev/null ) && xfce4-session-logout --logout
( command -v gnome-session-quit &> /dev/null ) && gnome-session-quit
