#!/bin/bash

# TODO: is tar have option to only tar the dir without the leading path?

# prepare the backup dir name
[[ -z $CUR_OS ]] && echo "Env var \$CUR_OS must be set before backup!" && exit
[[ ! -e $MY_TMP ]] && mkdir $MY_TMP

cd $MY_TMP
backupSuffix=$CUR_OS-`hostname`
# seems hostname on XP (DeepIn SP3) will return some unprintable char
backupSuffix2=`echo $backupSuffix | sed -e "s/[^[:print:]]//g"`
backupDir=backup_`date "+%Y-%m-%d_%H-%M-%S"`_$backupSuffix2
backupFile=$backupDir.zip
backupList=$MY_ENV/script_backupMyenv.lst
tagSuffixStr="__TAG_SUFFIX__"
tagSuffixPattern="[[:space:]]*"$tagSuffixStr


echo "--> Create tmp dir and backup stuffs"
mkdir $backupDir
while read line ; do
	if [[ $line = *$tagSuffixStr* ]] ; then
		srcFile=${line%%$tagSuffixPattern}
		srcFileName=${srcFile##*\/}
		destFileName=${srcFileName}_${backupSuffix2}
		eval cp -R $srcFile $backupDir/$destFileName
	else
		eval cp -R $line $backupDir
	fi
done < ${backupList}

echo "--> Create package and clean up tmp directory"
zip -rq $backupFile $backupDir

# backup
echo "Current os is $CUR_OS"
if [ "$CUR_OS" == "$CUR_OS_LU" ] ; then
	uploadHost=EV88AE1DAC71FB.eapac.ericsson.se
	uploadPort=2525
	uploadUser=Documents
	uploadPass=DocumentsPass
	uploadPath_History=myenv/history
	uploadPath_Latest=myenv
	fileName_Latest=latest.zip

	echo "Deleting file $uploadHost:$uploadPort/$uploadPath_Latest/$fileName_Latest"
	script_ftpAuto.sh $uploadHost $uploadPort $uploadUser $uploadPass $uploadPath_Latest "delete $fileName_Latest"

	echo "Coping backup file $backupFile to $uploadHost:$uploadPort/$uploadPath_History"
	script_ftpAuto.sh $uploadHost $uploadPort $uploadUser $uploadPass $uploadPath_History "put $backupFile"

	echo "Coping backup file $backupFile to $uploadHost:$uploadPort/$uploadPath_Latest/$fileName_Latest"
	script_ftpAuto.sh $uploadHost $uploadPort $uploadUser $uploadPass $uploadPath_Latest "put $backupFile $fileName_Latest"

elif [ "$CUR_OS" == "$CUR_OS_WIN" ] ; then
	backupPath_History=$MY_DOC/DCB/Software/myenv/history
	backupPath_Latest=$MY_DOC/DCB/Software/myenv
	fileName_Latest=latest.zip
	[[ ! -e $backupPath_History ]] && echo "-!> Dir $backupPath_History not exist, can not do backup, exit..." && exit

	echo "Deleting file $backupPath_Latest/$fileName_Latest"
	rm  $backupPath_Latest/$fileName_Latest

	echo "Coping backup file $backupFile to $backupPath_History"
	cp $backupFile $backupPath_History

	echo "Coping backup file $backupFile to $backupPath_Latest/$fileName_Latest"
	cp $backupFile $backupPath_Latest/$fileName_Latest

	echo "ls -lhtr $backupPath_History"
	ls -lhtr $backupPath_History
else
	echo "Can not identify os type, pls set the env var!"
fi

# cleanup
rm -Rf $backupDir
rm -f $backupFile
