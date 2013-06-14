#!/bin/bash

# Var
wine_pro="$HOME/.wine/drive_c/Program Files"
sys_apps=$HOME/.local/share/applications
sys_default=$HOME/.local/share/applications/defaults.list
ext_doc_path=`find /ext/ -maxdepth 3 -type d -name "Documents"`

# Safe check, backup
(( `echo $ext_doc_path | wc -l` == 1 ))	|| echo "ERROR: Failed to find Documents dir in /ext, exit!" || exit 1
(! command -v wine &> /dev/null) && echo "ERROR: Install $wine_ver failed, pls check!" && exit 1
[ ! -e ${sys_default}.bak ] && cp ${sys_default}{,.bak}

function wine_app_init {
	# Var
	app_name=$1
	app_bin=$2
	app_dt_name=${app_name}.desktop
	app_dt=${MY_ENV}/conf/$app_name/${app_dt_name}
	app_dt_link=${sys_apps}/${app_dt_name}
	app_bin_link="$wine_pro/$app_name"

	# Init
	echo "INFO: initilizing wine app $app_name"
	[ ! -e $app_dt -o ! -e $app_bin ] && echo "ERROR: $app_dt or $app_bin not exist, pls check!" && return 1
	ln -fs $app_dt $app_dt_link
	ln -fs $app_bin "$app_bin_link"
	
	app_types=`sed -n -e "/^MimeType=/s/\(MimeType=\|;\)/ /gp" $app_dt`
	for app_type in $app_types ; do
		sed -i -e "s:${app_type}=.*:${app_type}=${app_dt_name}:" $sys_default
	done
}

wine_app_init foxit $ext_doc_path/os_spec_win/program/A_Text_PDF_FoxitReader_6.0.2
