#!/bin/bash

targetPath=$MY_DOC'/DCB/Software/program'
targetFileName=program_Backup_Prefixed_`date "+%Y-%m-%d_%H-%M-%S"`.zip
targetFile=$targetPath/$targetFileName

echo "--> Begin to pack dirs in $MY_PRO whose name has prefix A_ / Z_, to file: $targetFile"

# move the previous version to ECB, the 2 makes it not include the _A_A files
# ecbPath=$MY_DOC'/ECB/program'
# mv ${targetPath}/* $ecbPath

# packup files
cd $MY_PRO
echo "--> Task start at:    `date`"

zip -qry $targetFile A_* Z_* -x@${MY_ENV}/script_backupProgram_exclude.lst

ls -lhtr $targetPath

echo "--> Task finished at: `date`"
