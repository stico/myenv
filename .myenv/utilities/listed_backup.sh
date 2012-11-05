

Usage="bash listed_backup <tag> <fl_files>"
if [[ $# -lt 2 ]]; then
	echo "$Usage"
	exit 1;
fi

target_name=`date "+%Y-%m-%d_%H-%M-%S"`_$1
target_tmp=$MY_TMP/$target_name
bak_path=("$MY_DOC/DCB/Google Drive/VERSION_BACKUP" "$HOME/ampext/download")
mkdir -p $target_tmp
shift
source=$*
success="success"

for fl in $source ; do 

	[[ ! -e $fl ]] && echo -e "Warning: file list ($fl) not exist, pls check!"

	for file in `sed -e "/^\s*$/d;/^\s*#/d;" $fl` ; do

		if [[ -e $HOME/$file ]] ; then
			#echo -e "File under home:\t$file"
			cp --parents -R $HOME/$file $target_tmp
		elif [[ -e $(eval "echo -e $file") ]] ; then
			#echo -e "File in env var:\t$file"
			cp --parents -R $(eval "echo -e $file") $target_tmp
		else
			echo -e "Warning: can not handle object ($file), probably not exist!"
		fi
	done
done

echo "Creating backup package: ${target_tmp}.zip"
cd $MY_TMP	# so the path in .zip won't be dirty
zip -rq ${target_name}.zip $target_name
cd -

for path in "${bak_path[@]}"
do
	if [[ -e "$path" ]]; then
		echo "Backup to path: $path" 
		cp ${target_tmp}.zip "$path/"
		copied=$success
	else
		echo "Path not exist: $path" 
	fi
done

if [[ $copied != $success ]]; then 
	echo -e "\n"
	echo -e "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo -e "! Failed to do any backup, pls check it !"
	echo -e "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
fi

#rm -rf $target_tmp ${target_tmp}.zip
