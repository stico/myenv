
source=$HOME/.git
target=$MY_ENV/list/myenv.lst


if [[ -e $source ]] ; then
	echo -e "Generating list file.\nSource: $source \nTarget: $target"
else
	echo -e "\nError: $source not exists, pls check! Exit..." 
	exit 1
fi


cd $HOME
git ls-files > $target
cd -


# from .gitignore
# source=$HOME/.gitignore 
#sed -e "/^\s*$/d;		\
#	/^\s*#/d;		\
#	/\/\*/d;		\
#	/.fl_files.txt/d;	\
#	/.grep_result.txt/d;	\
#	/gVim.exe.stackdump/d;	\
#	s/^!//;			\
#	s/^/\$HOME/;" $source 	| sort > $target
