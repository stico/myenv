#!/bin/bash

Usage="Usage: bash listed_backup <tag> <files_of_filelist>"
if [[ $# -lt 2 ]]; then echo "$Usage"; exit 1; fi

target_tmp=$MY_TMP/$1
mkdir -p $target_tmp
shift
source=$*

echo -e "INFO\tCopying listed files to: ${target_tmp}"
for fl in $source ; do 

	[[ ! -e $fl ]] && echo -e "WARN\tfile list ($fl) not exist, pls check!"

	sed -e "/^\s*$/d;/^\s*#/d;" $fl | while read line; do
		#echo -e "INFO\tStart to handle $line"
		if [ -n "$HOME/$line" -a -e "$HOME/$line" ] ; then
			#echo -e "INFO\tline is a path:\t$line"
			cp --parents -R "$HOME/$line" $target_tmp/
		elif [ -e "$(eval $line)" ] ; then
			#echo -e "INFO\tline is a path after eval:\t$line"
			cp --parents -R "$(eval $line)" $target_tmp/
		else
			echo -e "WARN\tcan not handle object ($line), probably not exist!"
		fi
	done

	#for file in `sed -e "/^\s*$/d;/^\s*#/d;" $fl` ; do
	#	echo -e "INFO\tStart to handle $file"
	#	if [[ -e $HOME/$file ]] ; then
	#		echo -e "INFO\tFile under home:\t$file"
	#		cp --parents -R $HOME/$file $target_tmp/
	#	elif [[ -e "$(eval '$file')" ]] ; then
	#		echo -e "INFO\tFile in env var:\t$file"
	#		cp --parents -R "$(eval '$file')" $target_tmp/
	#	else
	#		echo -e "WARN\tcan not handle object ($file), probably not exist!"
	#	fi
	#done
done

cd `dirname $target_tmp`
bash $MY_ENV_UTIL/dated_backup.sh `basename $target_tmp`

echo -e "INFO\tDeleting tmp dir: $target_tmp"
rm -rf $target_tmp 
