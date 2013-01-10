#!/bin/bash

vimBin=${MY_PRO}/A_Text_Vim_7.2_PA-Basic/App/vim/vim72/gVim

[ ! -n "$1" ] && echo '-!> At least set the 1st parameter, which indicating the file to edit' && exit

if [ $(echo $1 | grep -c "^/") -eq 1 ] ; then
	winPath=`cygpath -w $1`
	shift
fi

#echo "INFO: invoking ${vimBin} $winPath $* &"
${vimBin} $winPath $* &
