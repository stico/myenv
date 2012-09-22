#!/bin/bash

taskDesc[1]='Gather file list and in all notes'
taskCmd[1]=$MY_DOC'/DCB/Collection/Script/CreateFileList_MergeNote.sh'

echo -e '\n****************************** System Info ******************************'
echo -e '* Local IP:\t'`ipconfig | grep "IPv4 Address" | sed -e "s/.*:\s*//"`
echo -e '* Hostname:\t'`hostname`
echo -e '*************************************************************************'

# Ask for user selection
echo "" # just a blank line
for index1 in 1 
do
	echo -e "[${index1}] ${taskDesc[index1]}"
done

echo -e "\nPlease select a task to perform:"
#read -t 5 user_selection
read user_selection

# Perform the task
for index2 in ${user_selection}
do
	echo -e "\nStart Performing Task: "${taskDesc[index2]}
	bash ${taskCmd[index2]}
done

