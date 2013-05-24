#!/bin/bash

targetPath=$MY_DOC'/DCB/Software/dev'
targetFile=$targetPath/dev_Backup_Prefixed_AZ_`date "+%Y-%m-%d_%H-%M-%S"`.zip
 
# echo "--> move the previous version to ECB"
# ecbPath='/cygdrive/e/Documents/ECB/dev'
# mv $targetPath/${targetFilePrefix}_*zip $ecbPath

echo "--> Begin to pack dir/file in $MY_DEV whose name has prefix A_, to file: $targetFile"

# packup files
cd $MY_DEV
pwd
startTime=`date`
echo "--> Task start at:    $startTime"

zip -rqy $targetFile a_* z_* -x@${MY_ENV}/script_backupDev_exclude.lst

echo "--> Task finished at: `date`"
