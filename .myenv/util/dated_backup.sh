#!/bin/bash

Usage="Usage: bash dated_backup <single_file_or_dir>"
if [[ $# -lt 1 ]]; then echo "$Usage"; exit 1; fi

# path might have blank
srcPath="$*"
fileName=$(basename $srcPath)
targetFile=`date "+%Y-%m-%d_%H-%M-%S"`_`uname -n`_"$fileName"
bakPath=("$MY_DOC/DCB/Google Drive/VERSION_BACKUP")
success="success"

# if path is a directory, zip it first
if [[ -d "$srcPath" ]]; then
	# need update the var to packed ones
	targetFile=$targetFile.zip 
	packFile=$MY_TMP/$targetFile
	echo -e "INFO\tCreating zip file for backup: $packFile"
	zip -rq "$packFile" "$srcPath"
	srcPath="$packFile"
fi

for path in "${bakPath[@]}"
do
	# seems the -w detection not correct for samba storage
	#if [ ! -w "$path" ]; then
	#	echo -e "WARN\tNot have write permission to $path" 
	#	continue
	#fi

	if [ -e "$path" ]; then
		echo -e "INFO\tBackup to path: $path" 
		[ $(cp "$srcPath" "$path/$targetFile") ] && echo -e "INFO\t`ls -lh \"$path/$targetFile\"`"
		copied=$success
	else
		echo -e "WARN\tPath not exist: $path" 
	fi
done


[[ -e $packFile ]] && echo -e "INFO\tDeleting tmp zip file: $packFile" && rm "$packFile"

[[ $copied != $success ]] && echo -e "\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n! Failed to do any backup, pls check it !\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
