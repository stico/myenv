#!/bin/bash

# DESC: use better dircolors, 
#	1st: use latest solarized if available, 
#	2nd: otherwise use the basic one (an old copy of /etc/DIR_COLORS with few update)

target=~/.dir_colors
base=$MY_ENV_CONF/colors
basic="${base}/dircolors-basic/dir_colors"
solarized=${base}/dircolors-solarized
solarized_ansi="${solarized}/dircolors.ansi-universal"

[ ! -e "${base}" ] && echo "ERROR: ${base} not exist, pls check!" && exit

cd "${solarized}"
if [ -e "${solarized}/.git" ] ; then
	echo "INFO: Updateing git repo: $solarized"
	git pull
else
	echo "INFO: Init (Cloning) git repo: $solarized"
	git clone git://github.com/seebi/dircolors-solarized.git
fi

if [ -f "${solarized_ansi}" ] ; then
	mv "${target}" "${target}.bak.$(date "+%Y-%m-%d_%H-%M-%S")"
	cp "${solarized_ansi}" "${target}"
	echo "INFO: color setting copied, source: ${solarized_ansi}, target: $target"
else
	cp "${basic}" "${target}"
	echo "Warn: failed to fetch solarize dircolors, use basic one, source: ${basic}, target: $target"
fi
