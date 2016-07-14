#!/bin/sh
os_name="$(sed -n -e "s/DISTRIB_ID=\(\S*\)/\L\1/p" /etc/lsb-release)"
if [ "${os_name}" = "ubuntu" ] ; then
	# --clipboard will suppress --file (no files saved)
	/usr/bin/gnome-screenshot --area --include-pointer --file ~/amp/$(date "+%Y-%m-%d")/$(date "+%Y-%m-%d_%H-%M-%S").jpg --clipboard
else
	zenity --info --text "No screenshot script for OS ($os_name)"
	#"/usr/bin/xfce4-screenshooter -r -c"	# for XFCE
fi
