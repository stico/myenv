
source=$MY_DOC/DCB/SoftwareConf/SecureCRT/Config/Sessions
target=$MY_ENV/list/hosts.lst


if [[ -e $source ]] ; then
	echo -e "Generating list file (by SecureCRT session file).\nSource: $source \nTarget: $target"
else
	echo -e "\nError: $source not exists, pls check! Exit..." 
	exit 1
fi


echo "" > $target
for file_name in `ls $source`
do
	
	session_file=${source}/${file_name}
	[[ -d ${session_file} ]] && echo "Skipping dir: $session_file" && continue
	[[ "${file_name}" = "__FolderData__.ini" || "${file_name}" = "Default.ini" ]] && echo "Skipping: Default.ini/__FolderData__.ini" && continue

	hostname=`sed -n 's/S:"Hostname"=\(.*\)/\1/p' ${session_file}`

	echo -e "${hostname}\t\t${file_name%%.ini}" >> $target
done

