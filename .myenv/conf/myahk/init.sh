#!/bin/bash

# Variable
func_common=$MY_ENV/env_func_bash
keyconf_xfce_target=~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml
keyconf_xfce_source=$MY_ENV/conf/xfce/xfce4-keyboard-shortcuts.xml

# Pre-Check
[ ! -e $func_common ] && echo "ERROR: $func_common not exist!" && exit 1

# Dependencies
#sudo apt-get install -y tk xbindkeys-config		# for GUI dialogs, not really necessary
sudo apt-get install -y tk xbindkeys

source $func_common
func_bak_file $keyconf_xfce_target
rm $keyconf_xfce_target
cp $keyconf_xfce_source $keyconf_xfce_target


echo "Need logout to take effect, logout (N) [Y/N]?"
read -e continue                                                                                           
[ "$continue" != "Y" -a "$continue" != "y" ] && echo "Give up, pls logout and login later" && return 1
( command -v xfce4-session-logout &> /dev/null ) && xfce4-session-logout --logout
( command -v gnome-session-quit &> /dev/null ) && gnome-session-quit
