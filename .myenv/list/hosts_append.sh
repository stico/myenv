
source=$MY_ENV_SECU/hosts.lst
target=$LOC_HOSTS 
line_begin='########## myenv host append begin (DO NOT update this line) ##########'
line_end='########## myenv host append end (DO NOT update this line) ##########'

if [[ -e $source && -e $target ]] ; then
	echo -e "Updating host list file.\nSource: $source \nTarget: $target"
else
	echo -e "\nError: $source or $target not exists, pls check! Exit..." 
	exit 1
fi

sed -i -e "/$line_begin/,/$line_end/d" $target
echo -e "\n\n\n\n${line_begin}" >> $target
sed -e "/^\s*$/d" $source >> $target
echo -e "${line_end}" >> $target
