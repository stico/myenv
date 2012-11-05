
src=$HOME/.gitignore 
target=$MY_ENV/fl_myenv.list

echo "Generating $target from $src file"

sed -e "/^\s*$/d;		\
	/^\s*#/d;		\
	/\/\*/d;		\
	/.fl_files.txt/d;	\
	/.grep_result.txt/d;	\
	/gVim.exe.stackdump/d;	\
	s/^!//;		\
	s/^/\$HOME/;"	$src > $target
