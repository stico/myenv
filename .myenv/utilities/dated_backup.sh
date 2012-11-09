#!/bin/bash

[[ ! -n $1 ]] && echo '-!> Must set the 1st parameter, which indicating the file to be backup. Exiting ...' && exit

# the path might have blank, so use $*, and embrace with "" (many place used this)
srcPath="$*"
fileName=$(basename $srcPath)
targetFile=`date "+%Y-%m-%d_%H-%M-%S"`_`uname -n`_"$fileName"
#bakPath=("$MY_SDC_Base/VersionBackup" "$MY_LUH_Base/VersionBackup" "$MY_DOC/ECB/OnlineStorage/VersionBackup" "$MY_NET_Base/VersionBackup" )
bakPath=("$MY_DOC/DCB/Google Drive/VERSION_BACKUP" "$HOME/ampext/download")
success="success"

# if path is a directory, zip it first
if [[ -d "$srcPath" ]]; then
	# need update the var to packed ones
	targetFile=$targetFile.zip 
	packFile=$MY_TMP/$targetFile
	echo "Creating tmp zip file for backup: $packFile"
	zip -rq "$packFile" "$srcPath"
	srcPath="$packFile"
fi

for path in "${bakPath[@]}"
do
	if [[ -e "$path" ]]; then
		echo "Backup to path: $path" 
		cp "$srcPath" "$path/$targetFile"
		ls -lh "$path/$targetFile"
		copied=$success
	else
		echo "Path not exist: $path" 
	fi
done


[[ -e $packFile ]] && echo "Deleting tmp zip file: $packFile" && rm "$packFile"

[[ $copied != $success ]] && echo -e "\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n! Failed to do any backup, pls check it !\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
