#!/bin/bash

# prepare the backup dir name
[[ -z $HOME ]] && echo "Env var \$HOME must be set before restore!" && exit
[[ $(echo $PWD | grep -c -x $HOME) == 1 ]] && echo "Current dir should not be \$HOME!" && exit
[[ ! -e .myenv ]] && echo "Current dir should be an extracted myenv bak!" && exit
[[ ! -e .myenv/script_myenv.lst ]] && echo "Can not find the script_myenv.lst, restore failed!" && exit


# Variables
bakDir=z_bak_`date "+%Y-%m-%d_%H-%M-%S"`
bakList=$HOME/.myenv/script_myenv.lst
# restore must use the one under current dir!
restoreList=.myenv/script_myenv.lst
tagSuffixStr="__TAG_SUFFIX__"
tagSuffixPattern="[[:space:]]*"$tagSuffixStr


# Backup old stuff
if [ -e $bakList ]
then
	echo "Backup old env files to $bakDir"
	mkdir $bakDir
	while read line ; do
		if [[ $line = *$tagSuffixStr* ]] ; then
			srcFile=${line%%$tagSuffixPattern}
			echo -e "\tKeep not touched: $srcFile"
		else
			echo -e "\tBackup file: $line"
			eval mv $HOME/$line $bakDir
			if [ $? != 0 ]
			then
				# in case (which happens on win) some dir have permission problem
				eval cp -R $HOME/$line $bakDir
			fi
		fi
	done < ${bakList}
else
	echo "Seems this is the 1st time init, skipping backup old files"
fi


# change privilege, might have a complain, which is ok
# sudo chmod 700 -R *
# chmod 700 -R *


# mv new files to $HOME
echo "Restore env files to from current dir"
while read line ; do
	if [[ $line = *$tagSuffixStr* ]] ; then
		srcFile=${line%%$tagSuffixPattern}
		echo -e "\tKeep not touched: $srcFile"
	else
		echo -e "\tRestore file: $line"
		eval cp -R $line $HOME/
	fi
done < ${restoreList}

echo "Restore finished"
ls -lhtr $HOME/.bashrc $HOME/.backupMyenv.bat

