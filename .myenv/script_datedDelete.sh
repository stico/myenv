#!/bin/bash

[[ ! -n $1 ]] && echo '-!> Must set the 1st parameter, which indicating the file to be delete. Exiting ...' && exit
[[ ! -e $MY_TMP ]] && echo '-!> Must set the env variable of $MY_TMP, and the path must exist. Exiting ...' && exit

# the path might have blank, so use $*, and embrace with "" (many place used this)
targetDir=$MY_TMP/`date "+%Y-%m-%d"`

[[ ! -e $targetDir ]] && mkdir $targetDir
mv "$@" $targetDir
