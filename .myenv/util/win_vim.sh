#!/bin/bash

vimBin=${MY_PRO}/A_Text_Vim_7.2_PA-Basic/App/vim/vim72/gVim

[ ! -n "$1" ] && echo '-!> At least set the 1st parameter, which indicating the file to edit' && exit

if [[ $(echo $1 | grep -c "^/cygdrive/") == 1 ]] ; then
	cygpath -w $1
	winPath=`cygpath -w $1`
	shift
fi

${vimBin} $winPath $* &
