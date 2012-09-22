#!/bin/bash

fileList=.fl_files.txt
grepResult=.grep_result.txt

[ ! -n "$1" ] && echo '-!> Must set the 1st parameter, which indicating the file extension' && exit
[ ! -n "$2" ] && echo '-!> Must set the 2nd parameter, which indicating the searching string' && exit

if [ ! -e ./$fileList ] 
then
	echo "File list $fileList not exist, firstly create it..."
	find . -type f > $fileList
fi

# 1) can not use alias in xargs (at least not easy)
# 2) -I means not match binary file
# 3) $suffix must surround by ", otherwise will interpreted by shell
if [ $1 == "-" ] 
then 
	suffix=""
	shift
	search="$*"

# TODO: delete those lines after a while
#	sed -e "/\/.svn\//d" $fileList	| \
#	sed -e "/\/.git\//d"		| \
#	sed -e "/\/.metadata\//d"	| \
#	sed -e "/\/.class$\//d"		| \
#	sed -e "/\/.jar$\//d"		| \
#	# the target is mvn, but might cause miss-hit!
#	sed -e "/\/target\//d"		| \
#	# remove the .fi_files itself
#	sed -e "/$fileList$/d"		| \
#	# -I is not match binary files
#	xargs grep -I -i "$*"		| tee $grepResult	|	grep --color -i "$*"
else
	suffix=".$1"
	shift
	search="$*"

# TODO: delete those lines after a while
#	grep $suffix'$' $fileList	| \
#	# the target is mvn, but might cause miss-hit!
#	sed -e "/\/target\//d"		| \
#	# remove the .fi_files itself
#	sed -e "/$fileList$/d"		| \
#	# -I is not match binary files
#	xargs grep -I -i "$*"		| tee $grepResult	|	grep --color -i "$*"
fi

# Step: prepare, we treat path in search text as .
search=${search//\\/.}
# Step: get files we want
grep $suffix'$' $fileList	| \
# Step: remove files not need to grep (for "grepfile")
sed -e "/\/.svn\//d" 		| \
sed -e "/\/.hg\//d" 		| \
sed -e "/\/.git\//d"		| \
sed -e "/\/.lnk\//d"		| \
sed -e "/\/.metadata\//d"	| \
sed -e "/\/.class$\//d"		| \
sed -e "/.grep_result.txt/d"	| \
sed -e "/\/.jar$\//d"		| \
# Step: special removal, the target is mvn, but might cause miss-hit!
sed -e "/\/target\//d"		| \
# Step: remove the .fi_files itself
sed -e "/$fileList$/d"		| \
# Step: grep result, -I is not match binary files
xargs --delimiter="\n" grep -I -i "$search"	| tee $grepResult	|	grep --color -i "$search"
