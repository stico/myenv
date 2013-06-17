#!/bin/bash

source=$MY_ENV_SECU/hosts.lst
target=$LOC_HOSTS 
line_begin='########## myenv host append begin (DO NOT update this line) ##########'
line_end='########## myenv host append end (DO NOT update this line) ##########'

[ ! -e "$source" -o ! -e "$target" ] && echo "Error: $source or $target not exists, try 'sudo -E xxx'" && exit 1
[ ! -w $target ] && echo "ERROR: must use sudo to update $target" && exit 1

echo -e "Updating host list file.Source: $source Target: $target"
sed -i -e "/$line_begin/,/$line_end/d" $target
echo -e "\n\n\n\n${line_begin}" >> $target
sed -e "/^\s*$/d" $source >> $target
echo -e "${line_end}" >> $target
