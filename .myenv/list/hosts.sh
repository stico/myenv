#!/bin/bash

usage="$0 [gen/update]\n\tgen\t\twill just gen hosts list,\n\tupdate\t\twill gen and update /etc/hosts"
[ $# -lt 1 ] && echo -e $usage && exit 1

target_sys=$LOC_HOSTS 
target_list=$MY_ENV_SECU/hosts.lst
securecrt_config=$MY_DOC/DCB/SoftwareConf/SecureCRT/Config/Sessions
line_begin='########## myenv host append begin (DO NOT update this line) ##########'
line_end='########## myenv host append end (DO NOT update this line) ##########'

[ ! "$1" = "gen" ] && [ ! "$1" = "update" ] && echo "ERROR: invalid option, only gen/update allowed" && exit 1
[ ! -e "$securecrt_config" ] && echo -e "Error: $securecrt_config not exists, pls check!" && exit 1

echo -e "Generating list file (by SecureCRT session file).\n\tSource: $securecrt_config \n\tTarget: $target_list"
> $target_list
for session_file in $(find $securecrt_config -type f | sed "/\/zdep\//d;/__FolderData__.ini/d;/Default.ini/d;")
do
	[ ! -f ${session_file} ] && echo "ERROR: $session_file is not a file" && continue

	jumped_ip=`sed -n 's/S:"Shell Command"=\([\d\.]*\)/\1/p;' ${session_file} | sed -e 's/\d013//;s/ssh\|-p\|32200\| //g;'`
	direct_ip=`sed -n 's/S:"Hostname"=\([\d\.]*\)/\1/p;' ${session_file} | sed -e 's/\d013//;'`
	[ ${#jumped_ip} -ge 7 ] && real_ip=$jumped_ip || real_ip=$direct_ip

	file_name=$(basename $session_file)
	echo -e "${real_ip}\t\t${file_name%%.ini}" >> $target_list
done

# Check if need update system's host
[ "$1" = "update" ] && echo -e "Updating host list file.\n\tSource: ${target_list}\n\target: $target_sys" || exit 0
[ ! -e "$target_list" -o ! -e "$target_sys" ] && echo "Error: $target_list or $target_sys not exists!" && exit 1
source ${HOME}/.myenv/myenv_func.sh || eval "$(wget -q -O - "https://raw.github.com/stico/myenv/master/.myenv/myenv_func.sh")" || exit 1
func_duplicate_dated $target_sys || func_die "ERROR: backup file failed!"

sudo sh -c "sed -i -e \"/$line_begin/,/$line_end/d\" $target_sys"
sudo sh -c "echo \"\n\n\n\n${line_begin}\" >> $target_sys"
sudo sh -c "sed -e \"/^\s*$/d\" $target_list >> $target_sys"
sudo sh -c "echo \"${line_end}\" >> $target_sys"
