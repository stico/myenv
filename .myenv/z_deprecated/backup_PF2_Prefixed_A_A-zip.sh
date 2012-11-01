#!/bin/bash

targetPath=$MY_DOC'/DCB/Software/program'
targetFileName=program_Backup_Prefixed_A_A_`date "+%Y-%m-%d_%H-%M-%S"`.zip
targetFile=$targetPath/$targetFileName
 
echo "--> Begin to pack dir/file in $MY_PRO whose name has prefix A_A_, to file: $targetFile"

# packup files
cd $MY_PRO
startTime=`date`
zip -r -y $targetFile A_A_*

ls -l $targetPath

echo "--> Task start at:    $startTime"
echo "--> Task finished at: `date`"
