#!/bin/bash
# not really work yet

foxit_reader='/home/ouyangzhu/program/A_Text_PDF_FoxitReader_5.0.1_PA-Basic/FoxitReaderPortable.exe'
root_drive='Z:\'
launch_param=''
for file in $@
do
	file=`readlink -f $file`
	# format path under wine (Z:\ is the root in wine)
	param="${root_drive}$(echo "$file" | sed 's/\//\\/g')"
	launch_param="$launch_param $param"
	# if the file path is not full path, we should expand it
	# if [ ! `echo $file | grep ^/` ]; then
	#     file="$(pwd)/$file"
	# fi

done
# run foxit reader in the background
wine $foxit_reader $launch_param &
