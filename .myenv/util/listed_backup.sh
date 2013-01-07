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

	for file in `sed -e "/^\s*$/d;/^\s*#/d;" $fl` ; do

		if [[ -e $HOME/$file ]] ; then
			#echo -e "File under home:\t$file"
			cp --parents -R $HOME/$file $target_tmp/
		elif [[ -e $(eval "$file") ]] ; then
			#echo -e "File in env var:\t$file"
			cp --parents -R $(eval "$file") $target_tmp/
		else
			echo -e "WARN\tcan not handle object ($file), probably not exist!"
		fi
	done
done

cd `dirname $target_tmp`
bash $MY_ENV_UTIL/dated_backup.sh `basename $target_tmp`

echo -e "INFO\tDeleting tmp dir: $target_tmp"
rm -rf $target_tmp 
