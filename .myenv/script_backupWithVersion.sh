#!/bin/bash

[[ ! -n $1 ]] && echo '-!> Must set the 1st parameter, which indicating the file to be backup. Exiting ...' && exit
[[ ! -e $MY_DOC ]] && echo '-!> Must set the env variable of $MY_DOC, and the path must exist. Exiting ...' && exit

# the path might have blank, so use $*, and embrace with "" (many place used this)
srcPath="$*"
fileName=${srcPath##*\\}
targetFile=`date "+%Y-%m-%d_%H-%M-%S"`_"$fileName"
#bakPath=("$MY_SDC_Base/VersionBackup" "$MY_LUH_Base/VersionBackup" "$MY_DOC/ECB/OnlineStorage/VersionBackup" "$MY_NET_Base/VersionBackup" )
bakPath=( "$MY_DOC/DCB/Google Drive/VERSION_BACKUP" )
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

# backup file to candidate place (if exist)
for path in "${bakPath[@]}"
do
	echo "Backup to path: $path" 
	if [[ -e "$path" ]]; then
		cp "$srcPath" "$path/$targetFile"
		ls -lh "$path/$targetFile"
		copied=$success
	else
		echo "Path not exist: $path" 
	fi
done

# remove the tmp zip file if exist
if [[ -e "$packFile" ]]; then
	echo "Deleting tmp zip file: $packFile"
	rm "$packFile"
fi

# this should never happen, as always should success in $MY_DOC/ECB ...
if [[ $copied != $success ]]; then 
	echo -e "\n"
	echo -e "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo -e "! Failed to do any backup, pls check it !"
	echo -e "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
fi
