#!/bin/bash

# source ${HOME}/.myenv/myenv_func.sh || eval "$(wget -q -O - "https://raw.github.com/stico/myenv/master/.myenv/myenv_func.sh")" || exit 1

[ -z "$ZBOX" ]			&& ZBOX=$HOME/.zbox
[ -z "$MY_DOC" ]		&& MY_DOC=$HOME/Documents
[ -z "$MY_TMP" ]		&& MY_TMP=$HOME/amp
[ -z "$MY_ENV" ]		&& MY_ENV=$HOME/.myenv
[ -z "$RVM_HOME" ]		&& RVM_HOME=$HOME/.rvm
[ -z "$MY_ENV_ZGEN" ]		&& MY_ENV_ZGEN=$MY_ENV/zgen
[ -z "$MY_ENV_LIST" ]		&& MY_ENV_LIST=$MY_ENV/list
[ -z "$MY_ENV_LOG" ]		&& MY_ENV_LOG=$MY_ENV/zgen/log
[ -z "$PYTHON_HOME" ]		&& PYTHON_HOME=$MY_DEV/python
[ -z "$MY_CODE_MISC" ]		&& MY_CODE_MISC=$MY_DEV/code_misc
[ -z "$DOT_CACHE_DL" ]		&& DOT_CACHE_DL=.dl_me.txt
[ -z "$DOT_CACHE_FL" ]		&& DOT_CACHE_FL=.fl_me.txt
[ -z "$DOT_CACHE_GREP" ]	&& DOT_CACHE_GREP=.grep_me.txt

[ -z "$ME_TAGS_ADDI" ]		&& ME_TAGS_ADDI=$MY_ENV/list/tags_addi
[ -z "$ME_NOTE_TAGS" ]		&& ME_NOTE_TAGS=$MY_ENV/zgen/tags_note
[ -z "$ME_CODE_TAGS" ]		&& ME_CODE_TAGS=$MY_ENV/zgen/tags_code
[ -z "$ME_NOTE_ROOTS" ]		&& ME_NOTE_ROOTS=($MY_DCC/note $MY_DCO/note $MY_DCD/project/note)
[ -z "$ME_CODE_ROOTS" ]		&& ME_CODE_ROOTS=($ZBOX/src/oumisc/oumisc-git)

source $HOME/.myenv/myenv_lib.sh || eval "$(wget -q -O - "https://raw.github.com/stico/myenv/master/.myenv/myenv_lib.sh")" || exit 1

function func_validate_exist() {
	# TODO: deprecate this wrapper
	func_validate_path_exist "$@"
}
function func_validate_inexist() {
	# TODO: deprecate this wrapper
	func_validate_path_inexist "$@"
}

function func_validate_user_proc() {
	func_param_check 1 "USAGE: $FUNCNAME <proc_info>" "$@"

	ps -ef | grep "$1" | grep -v grep > /dev/null && return 0
	return 1
}

function func_validate_user_name() {
	func_param_check 1 "USAGE: $FUNCNAME <username>" "$@"
	
	[ "`whoami`" != "$*" ] && echo "ERROR: username is not $* !" && exit 1
}

function func_validate_user_exist() {
	func_param_check 1 "USAGE: $FUNCNAME <username>" "$@"
	
	( ! grep -q "^$*:" /etc/passwd ) && echo "ERROR: user '$*' not exist!" && exit 1
}

function func_validate_available_port() {
	func_param_check 1 "USAGE: $FUNCNAME <port>" "$@"
	
	[ "$(netstat -an | grep -c "$1" 2>/dev/null)" = "1" ] && func_die "ERROR: port $1 has been used!"
}

function func_validate_cmd_exist() {
	func_param_check 1 "USAGE: $FUNCNAME <command>" "$@"

	( ! command -v "$1" &> /dev/null) && echo "ERROR: command '$1' not found (in PATH)" && exit 1
}

function func_validate_file_type_text() {
	func_param_check 1 "USAGE: $FUNCNAME <file>" "$@"

	# TODO: effeciency need improve!

	real_file=$(eval echo "$*")
	file "$real_file" | grep -q text
}

function func_filter_comments() {
	func_param_check 1 "USAGE: $FUNCNAME <file> ..." "$@"

	sed -e "/^\s*#/d;/^\s*$/d" "$@"
}

function func_cleanup_dotcache() {
	func_param_check 1 "USAGE: $FUNCNAME <path> ..." "$@"

	#TODO: also cleanup dir above it?

	for p in "$@" ; do
		[ -e "$p/$DOT_CACHE_DL" ] && rm "$p/$DOT_CACHE_DL" 
		[ -e "$p/$DOT_CACHE_FL" ] && rm "$p/$DOT_CACHE_FL" 
		[ -e "$p/$DOT_CACHE_GREP" ] && rm "$p/$DOT_CACHE_GREP" 
	done
}

function func_tag_value_raw() {
	sed -n -e "s+^${1}=++p" "${ME_TAGS_ADDI}" "${ME_NOTE_TAGS}" "${ME_CODE_TAGS}" | head -1
}

function func_tag_value() {
	[ -z "$*" ] && return 1						# NO translation, empty parameter, empty output
	[ "$*" = "." -o "$*" = ".." ] && echo $* && return 0		# NO translation, probably path, translate will also cause problem
	[ $(echo "$*" | grep -c "/\| ") -ge 1 ] && echo $* && return 0	# NO translation, contain no-tag char

	tag_value_raw="$(func_tag_value_raw ${1})"
	[ -z "$tag_value_raw" ] && echo $1 && return 0			# not a tag, return itself
	func_eval $tag_value_raw					# eval
}

function func_eval() {
	func_param_check 1 "USAGE: $FUNCNAME <tag>" "$@"

	# eval if contains var or cmd, otherwise return itself
	echo "$*" | grep -q '`\|$' &> /dev/null && eval echo $* || echo $*
}

function func_eval_path() {
	func_param_check 2 "Usage: $FUNCNAME <result_var_name> <pathstr>" "$@"

	# need use variable to "return" result
	result_var_name=$1
	eval $result_var_name=""
	shift
	pathstr="$*"

	# eval path, check empty value
	[ -n "$pathstr" ] && candidate=`func_tag_value $pathstr`
	[ -z "$candidate" ] && echo -e "WARN: candiate is empty: $pathstr !" && return 1

	# Try $HOME as base (myenv backup need this for git listed files)
	[ -e "$HOME/$candidate" ] && eval $result_var_name="$HOME/$candidate" && return 0
	[ -e "$candidate" ] && eval $result_var_name="$candidate" && return 0
}

function func_std_gen_tags() {
	local d dd note_file note_filename

	func_delete_dated "${ME_NOTE_TAGS}"
	for d in ${ME_NOTE_ROOTS[@]} ; do
		for note_file in ${d}/*.txt ; do
			local note_filename="${note_file##*/}"
			local note_linkpath="${d}/../${note_filename%.txt}/${note_filename}"
			if [ -e "${note_linkpath}" ] ; then
				echo "${note_filename%.txt}=${note_linkpath}" >> "${ME_NOTE_TAGS}"
			else
				echo "${note_filename%.txt}=${note_file}" >> "${ME_NOTE_TAGS}"
			fi
		done
		#for note_file in $(find "${d}/.." -maxdepth 3 -regex ".*/\(.*\)/\1.txt") ; do
		#	local note_filename="${note_file##*/}"
		#	echo "${note_filename%.txt}=${note_file}" >> "${ME_NOTE_TAGS}"
		#done
	done

	func_delete_dated "${ME_CODE_TAGS}"
	for d in ${ME_CODE_ROOTS[@]} ; do
		for dd in ${d}/* ; do
			echo "${dd##*/}=${dd}" >> "${ME_CODE_TAGS}"
		done
	done
}

function func_std_gen_links() {
	# STD 1: if there is dir and note have same name, there should be a link
	local d note_file
	for d in ${ME_NOTE_ROOTS[@]} ; do
		for note_file in ${d}/* ; do
			local note_filename="${note_file##*/}"
			local note_basepath="${d}/../${note_filename%.txt}"
			if [ -d "${note_basepath}" ] && [ ! -f "${note_basepath}/${note_filename}" ] ; then
				\cd "${note_basepath}" &> /dev/null
				ln -s "../note/${note_filename}" .
				\cd - &> /dev/null
			fi
		done
	done
}

function func_std_standarize() {
	func_std_gen_links
	func_std_gen_tags
}

function func_select_line() {
	func_param_check 3 "Usage: $FUNCNAME <result_var_name> <shortest|userselect> <lines>" "$@"

	# need use variable to "return" result
	result_var_name=$1
	eval $result_var_name=""
	shift

	# empty parameter, empty output
	[ -z "$*" ] && return 1
	
	# direct return for shortest
	select_type=$1
	shift
	[ "shortest" = "$select_type" ] && eval $result_var_name=`echo "$*" | awk '{ print length, $0 }' | sort -n | cut -d" " -f2- | head -1` && return 0

	targets_lines=$(echo "$*" | wc -l)
	[ $targets_lines -eq 1 ] && eval $result_var_name="$*" && return 0

	func_head 20 "$*" | cat -n | sed -e "s/\s\+\([0-9]\+\).*/& \1/"
	echo "NOT SINGLE CANDIDATES, PLS SELECT ONE:"
	read -e selection
	user_selection=`echo "$*" | sed -n -e "${selection}p"`
	eval $result_var_name=$user_selection
}

function func_log() {
	func_param_check 4 "Usage: $FUNCNAME <level> <prefix> <log_path> <str>" "$@"

	local level="$1"
	local prefix="$2"
	local log_path="$3"
	shift; shift; shift

	[ ! -e "$log_path" ] && mkdir -p $(dirname $log_path) && touch "$log_path"

	echo "$(func_dati) $level [$prefix] $@" >> "$log_path"
}

function func_log_info {
	func_param_check 3 "Usage: $FUNCNAME <prefix> <log_path> <str>" "$@"

	func_log "INFO" "$@"
}

function func_find_type_dotcache {
	# NOTE: must keep interface consistency with func_find_type
	func_param_check 3 "Usage: $FUNCNAME [find_type (f,file;d,dir)] [base] [pattern]" "$@"

	find_type=$1
	base=$2
	shift;shift

	if [ "$find_type" = "d" ] ; then
		#func_gen_list d $base $list_file || return 1
		list_file="$base/$DOT_CACHE_DL" 
		func_gen_filedirlist "$base" $list_file -type d || return 1
	else
		#func_gen_list f $base $list_file || return 1
		list_file="$base/$DOT_CACHE_FL" 
		func_gen_filedirlist "$base" $list_file -type f || return 1
	fi

	search=`echo "$*" | sed -e '/^$/q;s/ \|^/.*\/.*/g;s/\$/[^\/]*/'`
	targets=`cat $list_file | sed -e "/^$/d" | grep -i "$search"`

	echo "$targets"
}

function func_find_type {
	# NOTE: must keep interface consistency with func_find_type_dotcache
	func_param_check 3 "Usage: $FUNCNAME [find_type (f,file;d,dir)] [base] [pattern]" "$@"

	find_type=$1
	base=$2
	shift;shift

	search=`echo "$*" | sed -e '/^$/q;s/ \|^/.*\/.*/g;s/\$/[^\/]*/'`
	targets=`find -P "$base" -iregex "$search" -xtype $find_type | sed -e "/^$/d"`				# 1st try, not follow links
	[ -z "$targets" ] && targets=`find -L "$base" -iregex "$search" -type $find_type | sed -e "/^$/d"`	# not found, follow links maybe works
	[ -z "$targets" ] && return 1										# not found, return

	echo "$targets"
}

function func_find_dotcache {
	# NOTE: must keep interface consistency with func_find
	func_param_check 4 "Usage: $FUNCNAME [result_var_name] [find_type (f,file;d,dir)] [base] [pattern]" "$@"

	# need use variable to "return" result
	result_var_name=$1
	find_type=$2
	shift;shift
	eval $result_var_name=""

	#targets=`func_find_type $find_type $*`			# (2013-05-23) works, non cache version	
	targets=$(func_find_type_dotcache $find_type $*)
	[ $? -ne 0 ] && return 1

	func_select_line $result_var_name shortest "$targets"
}

function func_find {
	# NOTE: must keep interface consistency with func_find_dotcache
	func_param_check 4 "Usage: $FUNCNAME [result_var_name] [find_type (f,file;d,dir)] [base] [pattern]" "$@"

	# need use variable to "return" result
	result_var_name=$1
	find_type=$2
	shift;shift
	eval $result_var_name=""

	targets=`func_find_type $find_type $*`
	func_select_line $result_var_name shortest "$targets"
}

function func_vi_conditional {
	if [ $(func_sys_info | grep -c "^cygwin") = 0 ] ; then				# non-cygwin env: original path style + front job. 

		# use simple version
		if [ -z "$DISPLAY" ] ;then
			if (command -v vim &> /dev/null) ; then
				\vim "$@"
				return 0
			else
				\vi "$@"
				return 0
			fi
			return 0
		fi

		# NOTE 1: use GUI version with SIGNLE_VIM
		# NOTE 2: seems in ubuntu gui, not need "&" to make it background job
		# NOTE 3: python in zbox will set env "LD_LIBRARY_PATH" which makes Vim+YouCompleteMe not works
		# why? seems direct use "vim" will NOT trigger "vim" alias, I suppose this happens and cause infinite loop, BUT it is not!
		LD_LIBRARY_PATH="" gvim --version | grep -q '+clientserver' && LD_LIBRARY_PATH="" gvim --servername SINGLE_VIM --remote-tab "$@" || LD_LIBRARY_PATH="" gvim "$@"
		[ -e /usr/bin/wmctrl ] && /usr/bin/wmctrl -a 'SINGLE_VIM'
	else
		# cygwin env: win style path + background job
		parameters=${@:1:$(($#-1))}
		target_origin=${@:$#}

		[ -z "$target_origin" ] && target_cyg="" || target_cyg=`cygpath -w "$target_origin"`
		( \\gvim $parameters $target_cyg & ) &> /dev/null
	fi
}

function func_load_virtualenvwrapper {
	echo "INFO: loading virtual env (Virtualenvwrapper) for Python"

	[ -z "${PYTHON_HOME}" ] && func_die "ERROR: env PYTHON_HOME not set"
	mkdir -p ${HOME}/amp/workspace/virtualenv &> /dev/null

	export VIRTUALENVWRAPPER_PYTHON=${PYTHON_HOME}/bin/python
	export PS1="(VirtualEnv) ${PS1}"
	export WORKON_HOME=${HOME}/.virtualenvs
	export PROJECT_HOME=${HOME}/amp/workspace/virtualenv
	export VIRTUALENVWRAPPER_VIRTUALENV=${PYTHON_HOME}/bin/virtualenv
	export VIRTUALENVWRAPPER_VIRTUALENV_ARGS='--no-site-packages'
	export PIP_VIRTUALENV_BASE=${WORKON_HOME}
	export PIP_RESPECT_VIRTUALENV=true
	source ${PYTHON_HOME}/bin/virtualenvwrapper.sh
}

function func_load_rvm {
	echo "INFO: loading Ruby Version Manager, note the 'cd' cmd will be hijacked"

	# step 1: rvm hacks command "cd", record it before myenv loads func_cd_tag
	local init_src="$RVM_HOME/scripts/rvm"
	[ -e "${init_src}" ] && source "${init_src}" || func_die "ERROR: failed to source ${init_src} !"
	[ "$(type -t cd)" = "function" ] && eval "function func_rvm_cd $(type cd | tail -n +3)"

	# step 2: rvm need update path to use specific ruby version, this should invoke after myenv set PATH var
	local use_ver="$($RVM_HOME/bin/rvm list | sed -n -e "s/^=.*ruby-\([^ ]*\)\s*\[.*/\1/p" | head -1)"
	[ -n "${use_ver}" ] && echo "INFO: use version ruby-${use_ver}@global" && rvm use "ruby-${use_ver}@global" --default || func_die "ERROR: can not find any usable version"
	#$RVM_HOME/bin/rvm use "ruby-${use_ver}@global" --default	# why not work? just prefixed with $RVM_HOME/bin

	# step 3: update PS1
	export PS1="(RVM) ${PS1}"
}

function func_vi {
	# shortcut - open a new one
	[ -z "$*" ] && func_vi_conditional && return 0

	# shortcut - only one parameter, and exist
	[ $# -eq 1 ] && [ -e "${1}" ] && func_vi_conditional "${1}" && return 0

	# shortcut - only one tag, and exist
	tag_eval="`func_tag_value $1`"
	[ $# -eq 1 ] && func_vi_conditional "$tag_eval" && return 0

	# set base, evaluated tag or just ./
	[ "$tag_eval" != "$1" ] && base="$tag_eval" && shift || base="./"

	# Find target, if cache version return error, try no-cache version
	func_find_dotcache result_target f $base $* || func_find result_target f $base $*

	# use original paramters if no target found
	[ -n "$result_target" ] && func_vi_conditional "$base/$result_target" || func_vi_conditional "$@"
}

function func_cd_tag {
	# Shortcut
	[ -z "$*" ]     && func_cd_ls    && return 0	# home
	[ "-"  = "$*" ] && func_cd_ls -  && return 0	# last dir
	[ ".." = "$*" ] && func_cd_ls .. && return 0	# parent dir
	[ "."  = "$*" ] && func_cd_ls .  && return 0	# current dir

	# exist in current dir
	[ $# -eq 1 ] && [ -d "${1}" ] && func_cd_ls "${1}" && return 0

	# Try tag eval, use its dir if it is a file
	local base="$(func_tag_value ${1})"
	[ -f "${base}" ] && base="$(dirname ${base})"

	# Single tag, just cd to there
	if [ $# -eq 1 ] ; then
		[ ! -d "${base}" ] && func_cry "ERROR: ${base} not exist!"
		func_cd_ls "${base}" && return 0 
	fi

	# Search: 1) use current dir if base inexist 2) Find target, firstly cached version, otherwise no-cache version
	[ -d "${base}" ] && shift || base="./"
	func_find_dotcache result_target d $base $* || func_find result_target d $base $*
	func_cd_ls "${base}/${result_target}"
}

function func_cd_ls() {
	# Old rvm support
	# (2013-06-12) seems not checking and using func_rvm_cd could also source rvm, why?
	#[ "$(type -t func_rvm_cd)" = "function" -a -e "$*/.rvmrc" ] && func_rvm_cd .
	#[ "$(type -t func_rvm_cd)" = "function" -a -e "$*/.rvmrc" ] && func_rvm_cd "$*" && return 0

	[ -z "$*" ] && \cd || \cd "$*"
	#\ls -lhF --color=auto
	\ls -hF --color=auto
}

function func_ls { 
	# TODO: seem using "../paygat" will fail, possbile to make it work?

	# shortcut - home
	[ -z "$*" -o "-" = "$*" ] && func_ls_conditional "$*" && return 0

	# shortcut - only one parameter, and exist
	tag_eval="`func_tag_value $1`"
	[ $# -eq 1 ] && [ -d $tag_eval ] && func_ls_conditional $tag_eval && return 0

	# FOR_DEV: w | !source /home/ouyangzhu/.myenv/env_func_bash; func_ls dev

	# TODO: how to distiguish ll/ls/lla etc
	# TODO: Avoid Filename_Expansion
	# TODO: For Cmd History: ls the cmd output dir?

	# Translate tag
	base="./"
	if [[ -n "`func_tag_text_value $1`" ]] ;then 
		base="`func_tag_value $1`/"
		shift
	fi
	pathPattern=`echo "$*" | sed -e '/^$/q;s/ /*\//g;s/$/*/'`

	echo ------------------------------------"$base/$pathPattern"
	ls -lhtrF --color=auto $base/$pathPattern

	# Tmp Cmd
	#search=`echo "$*" | sed -e '/^$/q;s/ \|^\|$/.*/g'`
	#[[ -n $search ]] && search="-iregex $search"
	#find $base $search 
}

function func_head_cmd() {
	func_param_check 2 "Usage: $FUNCNAME [show_lines] [cmd]" "$@"

	show_lines=$1
	shift

	cmd_result=`eval "$*"`
	func_head $show_lines "$cmd_result"
}

function func_gen_filedirlist() {
	# TODO: make a conversion of $type+l_me.txt ?
	#[ "`realpath $base`" = "`realpath $HOME`" ] && echo yes || echo no
	func_param_check 3 "Usage: $FUNCNAME [base] [listfile] [find_options]" "$@"

	base=$1
	listfile=$2
	shift;shift
	find_options="$*"

	# for better compatibility, always: 1) use relative path (./) or path start with variable
	tag_value_raw="$(func_tag_value_raw ${base})"
	if [ -n "$tag_value_raw" ]; then
		base=$(func_eval $tag_value_raw)
		base_raw=$tag_value_raw
	else
		base=$base
		base_raw="."
	fi

	[ -e "$listfile" ] && return 0
	[ ! -e "$base" ] && echo "ERROR: $base not exist" && return 1
	[ ! -w "$(dirname $listfile)" ] && echo "ERROR: $(dirname $listfile) not exist or not writable" && return 1

	echo "$listfile not exist, create it..." 1>&2
	func_cd $base &> /dev/null
	[ -w ./ ] && find -L ./ $find_options | sed -e "s+^./+${base_raw}/+" > $listfile || echo "ERROR: no write permisson for $PWD!"
	\cd - &> /dev/null
}

function func_gen_list {
	# Deprecated: use func_tag_value_raw !
	# TODO: make a conversion of $type+l_me.txt ?
	#[ "`realpath $base`" = "`realpath $HOME`" ] && echo yes || echo no
	func_param_check 3 "Usage: $FUNCNAME [find_type (f,file;d,dir)] [base] [listfile]" "$@"

	find_type=$1
	base=$2
	listfile=$3
	[ -e "$base/$listfile" ] && return 0
	[ ! -w "$base" ] && return 1

	# make the path relative to the base, for better compitability
	echo "$base/$listfile not exist, create it..." 1>&2
	func_cd $base &> /dev/null
	[ -w ./ ] && find -L ./ -type $find_type > $listfile || echo "ERROR: no write permisson for $PWD!"
	\cd - &> /dev/null
}

function func_gen_list_f_me_git_only { 
	src_git=$HOME/.git
	src_add=$MY_ENV/list/myenv_fl_add.lst
	target=$MY_ENV/zgen/myenv_fl_git1.lst
	target_small=$MY_ENV/zgen/myenv_fl_git2.lst

	[ ! -e $src_git -o ! -e $src_add ] && echo -e "ERROR: ${src_git} or ${src_add} not exists!" && exit 1

	echo -e "INFO: Generating git file list to: $target"
	func_cd $HOME 
	git ls-files > $target
	\cd - &> /dev/null

	echo -e "INFO: Generating git compact file list to: $target_small"
	sed -e "s/\/.*//;" $target | sort -u > $target_small
}

function func_gen_list_f_me { 
	filelist_all=$MY_ENV/$DOT_CACHE_FL
	filelist_git=$MY_ENV/zgen/myenv_fl_git1.lst
	src_add=$MY_ENV/list/myenv_fl_add.lst

	[ -e $filelist_all ] && return 0

	echo -e "INFO: Generating full file list to: $filelist_all"
	[ ! -e $filelist_git ] && func_gen_list_f_me_git_only

	sed -e "s/^/..\//" $filelist_git > $filelist_all
	sed -e "/^\s*$/d;/^\s*#/d;" $src_add | while read line; do
		func_eval_path candidate $line
		[ -f "$candidate" ] && echo "$candidate" >> $filelist_all 
		[ -d "$candidate" ] && find "$candidate" -type f >> $filelist_all 
	done
}

function deprecated_func_gen_grep_pattern_str {
	# Deprecated: passing array between functions is painful!
	
	func_param_check 2 "Usage: $FUNCNAME [result_var_name] [patterns]" "$@"

	# need use variable to "return" result
	result_var_name="$1"
	eval $result_var_name=""
	shift
	patterns=$*

	result_pattern_str='\\\('
	for pattern in ${patterns[@]}
	do
		#pattern=${pattern/./\\\\.}'\\\|'
		result_pattern_str=${result_pattern_str}${pattern}
	done
	result_pattern_str=${result_pattern_str%%\\\\\\\|}'\\\)'

	eval $result_var_name=$result_pattern_str
}

function func_collect_files {
	func_param_check 4 "Usage: $FUNCNAME [target_base] [source_bases] [include_patterns] [exclude_patterns]" "$@"

	# TODO: make it optional: backup original file feature

	local target_base="${1}"
	local source_bases="${2}"
	local include_patterns="${3}"
	local exclude_patterns="${4}"
	local target_collection_fl=${target_base}/collection_fl.txt
	local target_collection_content=${target_base}/collection_content.txt
	local target_original_files=/tmp/original_files_$(basename $target_base)

	# create patterns for grep cmd
	include_pattern_str="$(echo ${include_patterns} | sed -e "s/\s/\|/g")"
	exclude_pattern_str="$(echo ${exclude_patterns} | sed -e "s/\s/\|/g")"

	echo "INFO: cleanup old target, path: ${target_base}"
	[ -e "${target_base}" ] && rm -rf "${target_base}"

	echo "INFO: generate target file lists for tags: ${source_bases}"
	mkdir -p "${target_base}"
	pushd "${target_base}"
	for tag in ${source_bases} ; do
		#func_gen_filedirlist $tag $target_base/fl_${tag}.txt -type f
		func_gen_filedirlist $tag $target_base/fl_${tag}.txt -maxdepth 5 -type f
		egrep -i "$include_pattern_str" fl_${tag}.txt | egrep -v -i "$exclude_pattern_str" >> ${target_collection_fl}
	done

	local count=0
	mkdir $target_original_files
	echo "INFO: collect and backup original file"
	while read line
	do
		source_path="$(func_eval "$line")"
		func_validate_file_type_text "$source_path" || continue					# won't collect non-text file
		[ -d "$source_path" ] && echo -e "INFO: skipping dir: $line" && continue

		target_file=$(echo "$source_path" | sed -e 's+/\|:+@+g;s+\$\| \|\(\|\)\|（\|）\|&++g')	# avoid name confliction
		cp "$source_path" "$target_original_files/$target_file" 

		echo -e "\n\n@$line\n\n"	>> ${target_collection_content}
		sed -e "s///" "$source_path"	>> ${target_collection_content}
		
		#count=$(($count + 1)) && [ $(($count % 100)) -eq 0 ] && echo "INFO: collected $count files"
		count=$(($count + 1)) && (($count%100==0)) && echo "INFO: collected $count files"
	done < ${target_collection_fl}
	echo "INFO: collected $count files"

	echo "INFO: append all file lists in collection content"
	echo -e "\n\n>>> File list of ${source_bases[@]} \n\n" >> ${target_collection_content}
	cat fl_*.txt >> ${target_collection_content}

	echo "INFO: backup collected original files"
	func_backup_dated "$target_original_files" 
	rm -rf "$target_original_files"

	func_cleanup_dotcache $MY_ENV $MY_ENV_ZGEN
	\cd - > /dev/null
	popd
}

function func_collect_code {
	target_base=$MY_ENV/zgen/collection_code
	source_bases=(dw ourepo oumisc)

	# Note, used "ERE (Extended Regex) to avoid passing "\" around)
	include_patterns=(.bat$ .sh$ .csh$ .groovy$ .cpp$ .c$ .py$ .erb$ .rb$ .sql$ .ruby$ .java$ .html$ .htm$ .jsp$ .js$ .css$ .php$ .ps$ .md$ .markdown$ .xml$)
	exclude_patterns=(/crashreport /componentsrv /education /client-update-server_branch1 /docs/ /doc/ .doc$ .min.js$ .compressed.js$ /.git/ /target/ /vendor/ /plugins/ /jslib/ /easyui/ /ckeditor/ /operamasks-ui/ /jquery[-.a-zA-Z0-9]*/ jquery[-.a-zA-Z0-9]*.[jc]ss?$ bootstrap[-.a-zA-Z0-9]*.[jc]ss?$)	

	func_collect_files $target_base $source_bases $include_patterns $exclude_patterns
}

function func_collect_note_outline() {
	local fl=$MY_ENV/zgen/collection_note/collection_fl.txt
	local ol=$MY_ENV/zgen/collection_note/collection_outline.txt
	[ ! -e "${fl}" ] && func_die "ERROR: $fl NOT exist for collect_note_outline"

	echo "INFO: generating outline of notes"
	while read line
	do
		[[ "${line}" != *.txt ]] && continue				# Only gather note outline
		local f="$(func_eval "${line}")"
		echo "@${f}" >> "${ol}"
		grep "^\t*[-a-z0-9_\.][-a-z0-9_\.]*[\t ]*$" "${f}" >> "${ol}"	# same pattern in NoteOutline@~/.vimrc
	done < ${fl}
}

function func_collect_note_stdnote() {
	local count=0 
	local sn=$MY_ENV/zgen/collection_note/collection_stdnote.txt

	echo "INFO: collecting stdnote names"
	for d in ${ME_NOTE_ROOTS[@]} ; do
		for f in $d/* ; do  
			ff=${f##*/} 
			printf "%-25s" ${ff%.txt} >> "${sn}"
			count=$(($count+1)) && (($count%4==0)) && printf "\n" >> "${sn}"
		done
	done
	printf "\n\n\n" >> "${sn}"
}

function func_collect_note {
	# TODO: if want collect .bat file, update (blank and encoding type) $MY_DOC/DCC/OS_Win/Useful MS-DOS batch files and tricks/SCANZ.BAT

	local target_base=$MY_ENV/zgen/collection_note
	local source_bases="dcd dco dcc dcb   me   ecb ece ech ecs ecz"			# Not included DCM, put DCD first

	# Note, used "ERE (Extended Regex) to avoid passing "\" around)
	local include_patterns="/note/.*.txt A_NOTE --NOTE-- --NOTED-- .bash$ .sh$"
	local exclude_patterns=".rtf$ .lnk$ DCB/DatedBackup/ DCD/mail/ A_NOTE_Copy.txt"
	
	func_std_standarize
	func_collect_files "${target_base}" "${source_bases}" "${include_patterns}" "${exclude_patterns}"
	func_collect_note_stdnote
	func_collect_note_outline

	mv $target_base/collection_content.txt{,.bak}
	cat $MY_ENV/zgen/collection_note/collection_stdnote.txt	>> $target_base/collection_content.txt
	cat $MY_ENV/list/collection_note_quick_link		>> $target_base/collection_content.txt
	cat $MY_ENV/zgen/collection_note/collection_outline.txt	>> $target_base/collection_content.txt
	cat $target_base/collection_content.txt.bak		>> $target_base/collection_content.txt
}

function func_repeat {
	func_param_check 3 "Usage: $FUNCNAME <interval> <times> <cmd>" "$@"

	count=1
	times="$2"
	interval="$1"
	shift;shift

	#for count in $(eval echo {1..$times}) ; do	# when times value big, will slow or not work
	while (($count < $times)); do
		eval "$@" 
		((count++))
		sleep $interval
		echo -e "\n\n------------------------- Count: $count / $times -------------------------\n\n"
	done
}

function func_grep_cmd {
	func_param_check 2 "Usage: $FUNCNAME <search_str> <cmd>" "$@"

	search_str=$1
	shift
	eval "$@" | grep -i "$search_str"
}

function func_grep_dotcache {

	# TODO
	# - seems can not support grepfile "aaa\|bbb"
	# - seems can not add more options
	func_param_check 3 "Usage: $FUNCNAME [base] [suffix] [search]*" "$@"

	base=$1
	file_suffix=`[ "$2" = "ALL" ] && echo "" || echo ".$2"`
	shift;shift

	#func_gen_list f $base $DOT_CACHE_FL || func_die "ERROR: failed to gen $base/$DOT_CACHE_FL"
	func_gen_filedirlist "$base" "$base/$DOT_CACHE_FL" -type f || func_die "ERROR: failed to gen $base/$DOT_CACHE_FL"


	# Get search string and options
		# Case need handle
		# no options, just search string
		# "-" or " -" in search string
		# multiple options with values

		# Option 1
		# TODO: can not support multiple option, like " -a a -b b"
		# TODO: option is whole string if no option there
		#parameters="$*"
		#options=${parameters/#* -/ -}
		#search=${parameters/% -*/}

		# Option 2
		# TODO: can not support multiple option, like " -a a -b b", since sed not support non-greedy regex
		# TODO: how to avoid " -" in quoted string, since " or ' is not there after pipe
		options=`echo "$*" | sed -e '/ -/!d;s/^.* -/ -/'`					# first " -" not in " or '
		search=`[ -z "$options" ] && echo "$*" || echo "$*" | sed -e "s/$options//;"`		# remove all options, $options empty will cause sed have error

	# we treat path in search text as .
	search=${search//\\/.}							# make the path sep compatible
	search=${search//\//.}							# make the sed (tput) coloring works

	# Jump to base, since the DOT_CACHE_FL is using relative path
	func_cd $base
	grep $suffix'$' $DOT_CACHE_FL	| \
	# Step: remove files not need to grep (for "grepfile")
	sed -e "/\/.svn\//d" 		| \
	sed -e "/\/.hg\//d" 		| \
	sed -e "/\/.git\//d"		| \
	sed -e "/\/.lnk\//d"		| \
	sed -e "/\/.metadata\//d"	| \
	sed -e "/\/.class$\//d"		| \
	sed -e "/$DOT_CACHE_DL/d"	| \
	sed -e "/$DOT_CACHE_FL/d"	| \
	sed -e "/$DOT_CACHE_GREP/d"	| \
	sed -e "/\/.jar$\//d"		| \
	# Step: special removal, the target is mvn, but might cause miss-hit!
	sed -e "/\/target\//d"		| \
	# Step: remove the fileist itself
	sed -e "/$DOT_CACHE_FL$/d"	| \
	# Step: grep result, -I: ignore binary, -oE & .{0.20}: only matched part and 20 char around
	xargs --delimiter="\n" grep -d skip -I -i $options -oE ".{0,20}$search.{0,20}" | \
	# store result for later ref
	tee $DOT_CACHE_GREP		| \
	# re-color the result, since pipe swiped color even using "--color" in grep
	sed -e "s/$search/$(tput setaf 1)&$(tput sgr0)/I"

	# Jump back
	\cd -
}

function func_grep_myenv {
	func_param_check 1 "Usage: $FUNCNAME [search]*" "$@"

	func_gen_list_f_me
	func_grep_dotcache $MY_ENV ALL "$*"
}

function func_head {
	func_param_check 2 "Usage: $FUNCNAME [show_lines] [text]" "$@"

	show_lines=$1
	shift

	total_lines=$(echo "$*" | wc -l)
	echo "$*" | sed -n -e "1,${show_lines}p;${show_lines}s/.*/( ...... WARN: more lines suppressed, $total_lines total ...... )/p"
}

function func_ip {
	if [ $(func_sys_info | grep -c "^cygwin") = 0 ] ; then
		# non-cygwin env: ifconfig
		/sbin/ifconfig | sed -n -e '/inet addr/s/.*inet6* addr:\s*\([.:a-z0-9]*\).*/\1/p'	# IPv4
		/sbin/ifconfig | sed -n -e '/inet6* addr/s/.*inet6* addr:\s*\([.:a-z0-9]*\).*/\1/p'	# IPv4 & IPv6
	else
		# seem directly pipe the output of ipconfig is very slow
		raw_data=$(ipconfig) ; echo "$raw_data" | sed -n -e "/IPv[4] Address/s/^[^:]*: //p"	# IPv4
		raw_data=$(ipconfig) ; echo "$raw_data" | sed -n -e "/IPv[46] Address/s/^[^:]*: //p"	# IPv4 & IPv6
		#ipconfig | sed -n -e '/inet addr/s/.*inet addr:\([.0-9]*\).*/\1/p'
	fi
}

function func_show_resp { 
	func_param_check 1 "Usage: $FUNCNAME [url]" "$@"

	echo "sending request to: $1"
	wget --timeout=2 --tries=1 -O - 2>&1 "$1"	\
	| sed -e '/'${1//\//.}'/d'			\
	| sed -e '/^Resolving/d'			\
	| sed -e '/^Length/d'				\
	| sed -e '/^Saving/d;/100%.*=.*s/d'		\
	| sed -e '/0K.*0.00.=0s/d'			\
	| sed -e '/^$/d'
}

function func_mvn_gen { 
	func_param_check 2 "Usage: $FUNCNAME [name] [type(war/jar)]" "$@"
	
	name=$1
	type=$2
	case "$type" in
	war)
		#mvn archetype:generate -DgroupId=com.test -DartifactId=$name -DarchetypeArtifactId=maven-archetype-webapp -DinteractiveMode=false
		mvn archetype:generate -DgroupId=com.test -DartifactId=$name -DarchetypeCatalog=local -DarchetypeGroupId=com.tpl.archetype -DarchetypeArtifactId=tpl-war-archetype -DarchetypeVersion=1.1-SNAPSHOT -DinteractiveMode=false
		mkdir -p $name/src/main/java
		;;
	jar)
		mvn archetype:generate -DgroupId=com.test -DartifactId=$name -DarchetypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false
		mkdir -p $name/src/main/resources
		;;
	*)
		echo "ERROR: type must be war/jar"
		exit 1
	esac
}

function func_svn_backup { 
	[ -n "$1" ] && src_path="$1" || src_path="."

	src_name=$(basename $(readlink -f $src_path))
	tmp_path=$MY_TMP/${src_name}_svn_export

	# current dir is already project
	[ -e ./.svn ] && svn export $src_path $tmp_path && return 0
	
	# projects are in subdir
	mkdir -p $tmp_path
	for dir in $(find $src_path -maxdepth 1 -type d) ; do 
		[ -n "$dir" ] && [ -e $dir/.svn ] && svn export $dir/  $tmp_path/$(basename $dir)
	done

	# backup
	func_backup_dated $tmp_path
	[ -e "$tmp_path" ] && rm -rf $tmp_path
}

function func_svn_update { 
	[ -n "$1" ] && src_path="$1" || src_path="."

	# current dir is already project
	[ -e $src_path/.svn ] && svn update $src_path && func_cleanup_dotcache $src_path && return 0
	
	# projects are in subdir
	for dir in $(find $src_path -maxdepth 1 -type d) ; do 
		# suppress blank line and external file in output: svn update $dir/ | sed "/[Ee]xternal \(item into\|at revision\)/d;/^\s*$/d"
		[ -n "$dir" ] && [ -e $dir/.svn ] && svn update $dir/ && func_cleanup_dotcache $dir
	done
	func_cleanup_dotcache $src_path 
}

function func_git_pull { 
	git pull origin master && git status
	func_cleanup_dotcache $PWD
}

function func_git_status { 
	git status 	
}

function func_git_commit_push { 
	[ -n "$*" ] && comment="$*" || comment="update from $(hostname)"

	# git add -A: in git 2.0, will add those even not in current dir (which is what we want), just wait the 2.0
	git pull origin master			&&
	git add -A				&&
	git commit -a -m "$comment" 		&&
	git push origin				&&
	git status 				&&
	func_gen_list_f_me

	func_cleanup_dotcache $PWD
}


function func_ssh_agent_init {
	# do nothing if already set
	# The unison remote style can not accept .bashrc have output
	#[ -n "$SSH_AUTH_SOCK" ] && echo "INFO: ssh agent already exist: $SSH_AUTH_SOCK" && return 0

	local cmd="ssh-agent -s"
	local env_tmp=~/.ssh/ssh_agent_env_tmp
	local auth_sock="$([ -e "${env_tmp}" ] && grep -o "SSH_AUTH_SOCK=[^;]*" "${env_tmp}" | sed -e "s/SSH_AUTH_SOCK=//" 2> /dev/null)"

	# reuse if already started. NOTE, the SSH_AUTH_SOCK file and the Process must all exist!
	[ -e "${auth_sock}" ] && . "${env_tmp}" &> /dev/null && func_validate_user_proc "${SSH_AGENT_PID}.*ssh-agent" && return 0

	# otherwise start a new one
	echo -e "INFO: Initialising new SSH agent...\n"
	${cmd} | sed "s/^echo/#echo/" > "${env_tmp}"
	chmod 600 "${env_tmp}"
	. "${env_tmp}" > /dev/null
	ssh-add ~/.ssh/ouyangzhu_duowan
}

function func_ssh_with_jump {
	func_param_check 1 "Usage: $FUNCNAME [target]" "$@"

	ip_addr=`getent hosts $1 | sed "s/\s\+.*$//"`
	[[ -z $ip_addr ]] && ip_addr=$1

	port=32200
	jump_machine=dw
	
	shift
	ssh -t $jump_machine "ssh -p $port $ip_addr $@"

	# TODO: check the $1, if it is a ip, should not parse as unique_name
	# TODO: add function for run cmd on multiple host
	# Demo: func_ssh_with_jump 222.88.95.197 
}

function func_scp_with_jump {
	func_param_check 2 "Usage: $FUNCNAME [source] [target]" "$@"

	PORT=32200
	JUMP_MACHINE=dw

	source=$1
	sourceName=$(basename $source)
	tmpTransferName=tmp_transfer_`func_dati`_${sourceName}
	target=$2
	targetDir=$(dirname ${target##*:})
	targetCmd="mkdir -p $targetDir"
	targetAddr=${target%%:*}

	if [[ $(echo $1 | grep -c ":") == 1 ]] 
	then
		echo "Downloading ..."

		# download content to jump machine
		ssh $JUMP_MACHINE "scp -r -P $PORT $source ~/$tmpTransferName"

		# create dir and download content to local machine 
		$targetCmd
		[[ -d $target ]] && targetFullName=$target/$sourceName
		scp -r -P $PORT ouyangzhu@$JUMP_MACHINE:~/$tmpTransferName $targetFullName
	else
		echo "Uploading ..."

		# upload content to jump machine
		scp -r -P $PORT $source ouyangzhu@$JUMP_MACHINE:~/$tmpTransferName

		# create dir and upload content to target machine in jump machine
		ssh $JUMP_MACHINE "ssh -p $PORT $targetAddr $targetCmd"
		# TODO: support rename in target (see above)
		ssh $JUMP_MACHINE "scp -r -P $PORT ~/$tmpTransferName $target"
	fi

	# delete tmp file in jump machine
	ssh $JUMP_MACHINE "rm -rf ~/$tmpTransferName"

	# Note: seems using ProxyCommand is a better way (not totally work yet), see ~/.ssh/config for more detail

	# Improve: the file name was changed to tmp_xxx
	# Improve: support unique_name (need translate, since the jump machine didn't set the hosts)
	# Improve: support file name with wildcard
	# Improve: cache the file based on MD5?
	# Improve: support all senario 
	#	L > R	I	cmd on L(src=L-Path		target=J-Host-Tmp)		II: cmd on J(src=J-Tmp	target=R-Host-Path)
	#	R > L	II	cmd on J(src=R-Host-Path	target=J-Tmp)			II: cmd on L(src=L-Path	target=J-Host-Tmp)
	#	R1 > R2	III	cmd on J(src=R1-Host-Path	target=J-Tmp)			II: cmd on J(src=J-Tmp	target=R2-Host-Tmp)
	#
	#	rule for scp exe location		J if $1 contains :, otherwise L
	#	rule for scp exe stage 1 src		directly use
	#	rule for scp exe stage 1 target		J-Tmp if $1 contains :, otherwise J-Host-Tmp
	#	rule for scp exe stage 2 src		J-Tmp if $2 contains :, otherwise directly use
	#	rule for scp exe stage 2 target		directly use if $2 contains :, otherwuse J-Host-Tmp
	#
	#	and mkdir?

	# Demo: 
		#func_scp_with_jump ~/amp/test ouyangzhu@222.134.66.106:~/test
		#func_scp_with_jump ~/amp/test/t1 ouyangzhu@222.134.66.106:~/test1
		#func_scp_with_jump ~/amp/test ouyangzhu@222.134.66.106:~/test2/test
		#func_scp_with_jump ouyangzhu@222.134.66.106:~/test/t1 ~/amp/2012-11-01/test1
		#func_scp_with_jump ouyangzhu@222.134.66.106:~/test ~/amp/2012-11-01/test
}

function func_terminator { 
	if [ $(func_sys_info | grep -c "^cygwin") = 0 ] ; then
		# non-cygwin env: original program
		terminator --title SINGLE_TERMINATOR $*
	else
		startxwin &> /dev/null	# just ensure X server started
		raw_data=$(ipconfig)
		local_ip=`echo "$raw_data" | sed -n -e "/IPv[4] Address/s/^[^:]*: //p" | head -1`
		# both --maximise/--fullscreen are not really work
		ssh workvm "DISPLAY=$local_ip:0.0 terminator --geometry=1910x1010+0+0 --title Gnome-Terminator&> /dev/null &" &> /dev/null
	fi
}

function func_sys_net {
	usage="Usage: $FUNCNAME [interface] [interval], interfaces: "$(ifconfig | sed '/^\s\+/d;/^\s*$/d;s/\s\+.*//;/lo/d;') 
	func_param_check 1 $usage "$@"

	interface=$1
	sleep_time=${2-2}
	rx_before=$(ifconfig $interface | sed -n -e "s/^.*RX bytes:\([0-9]*\).*/\1/p")
	tx_before=$(ifconfig $interface | sed -n -e "s/^.*TX bytes:\([0-9]*\).*/\1/p")
	while : ; do
		sleep $sleep_time
		rx_after=$(ifconfig $interface | sed -n -e "s/^.*RX bytes:\([0-9]*\).*/\1/p")
		tx_after=$(ifconfig $interface | sed -n -e "s/^.*TX bytes:\([0-9]*\).*/\1/p")
		rx_result=$(( (rx_after-rx_before)*8/$sleep_time ))
		tx_result=$(( (tx_after-tx_before)*8/$sleep_time ))
		echo -e "$(date "+%Y-%m-%d %H:%M:%S") IN: ${rx_result}/$(( ${rx_result}/1000 )) bps/kbps,\tOUT: ${tx_result}/$(( ${tx_result}/1000 )) bps/kbps"

		rx_before=$rx_after
		tx_before=$tx_after
	done
}

function func_sys_info_os_len {
	(command -v uname &> /dev/null) && uname_info=`uname -a` || uname_info="cmd_uname_not_exist"

	# Note, cygwin is usually 32bit
	if [ $(echo $uname_info | grep -ic "x86_64") -eq 1 ] ; then		echo "64bit"
	elif [ $(echo $uname_info | grep -ic "i[3-6]86") -eq 1 ] ; then		echo "32bit"
	else									echo "unknown"
	fi
}

function func_sys_info_os_ver {
	if [ -e /etc/lsb-release ] ; then					sed -n -e "s/DISTRIB_RELEASE=\(\S*\)/\1/p" /etc/lsb-release
	elif [ "$os_name" = "cygwin" ] ; then					uname -r | sed -e "s/(.*//"
	else									echo "unknown"
	fi
}

function func_sys_info_os_type {
	if [ "$os_name" = "ubuntu" ] && (command -v dpkg &> /dev/null) ; then 
		if (dpkg -l ubuntu-desktop &> /dev/null) ; then			echo "desktop"
		else								echo "server"
		fi
	elif [ "$os_name" = "cygwin" -o "$os_name" = "mingw" ] ; then		echo "desktop"
	elif [ "$os_name" = "linuxmint" ] ; then				echo "desktop"
	else									echo "unknown"
	fi
}

function func_sys_info_os_name {
	(command -v uname &> /dev/null) && uname_info=`uname -a` || uname_info="cmd_uname_not_exist"

	if [ -e /etc/lsb-release ] ; then					sed -n -e "s/DISTRIB_ID=\(\S*\)/\L\1/p" /etc/lsb-release
	elif [ $(echo $uname_info | grep -ic "cygwin") -eq 1 ] ; then		echo "cygwin"
	elif [ $(echo $uname_info | grep -ic "mingw") -eq 1 ] ; then		echo "mingw"
	else									echo "unknown"
	fi
}

function func_sys_info { 
	# format: <os_name>          		_<os_ver>  _<os_len>     _<os_type>               _<hostname>	_<addInfo>
	# exampe: ubuntu/linuxmint/cygwin/win	_12.04     _64bit/32bit  _desktop/server/win7/xp  _workvm	_precise

	os_name=`func_sys_info_os_name`

	# use cache if cached, need os_name to distiguish cygwin/mingw
	[ -n "$MY_ENV_ZGEN" ] && [ -e "$MY_ENV_ZGEN" ] && cache_file=$MY_ENV_ZGEN/sys_info_${os_name} || cache_file=/tmp/sys_info_${os_name}
	[ -e $cache_file ] && cat $cache_file && return

	os_ver=`func_sys_info_os_ver`
	os_len=`func_sys_info_os_len`
	os_type=`func_sys_info_os_type`

	# addInfo
	if [ "$os_name" = "ubuntu" ] ; then					addInfo=`sed -n -e "s/DISTRIB_CODENAME=\(\S*\)/\L\1/p" /etc/lsb-release`
	fi
	############################################################## (not include in output yet)
	# cpu_type 
	cpu_type="unknown"

	# cpu_len 
	# if [ $(grep -c "flags.* lm " /proc/cpuinfo) -ge 1 ] ; then # lm (long bit), deprecated
	if [ $(getconf -a | grep -c "LONG_BIT\s*64") -eq 1 ] ; then		cpu_len=64bit
	elif [ $(getconf -a | grep -c "LONG_BIT\s*32") -eq 1 ] ; then		cpu_len=32bit
	else									cpu_len="unknown"
	fi
	############################################################## (not include in output yet)

	result="${os_name}_${os_ver}_${os_len}_${os_type}_$(hostname)_${addInfo}" 
	echo -e "${result%_}" > $cache_file
	cat $cache_file

	# TODO: put this func to another file, pre load as basic functions
}

function func_translate { 
	# check history
	history_txt=$(grep "^$*[[:blank:]]" -i -A 1 --no-filename $MY_ENV/list/translate_history_*)
	[ -n "$history_txt" ] && echo "$history_txt" && return 0

	func_translate_google "$@" || func_translate_microsoft "$@"
}

function func_translate_IPA_google { 
	echo "WARN: not implemented yet!"
	# IPA: International Phonetic Alphabet (IPA), tells pronunciation of words
	# TODO: google api, IPA extraction: http://www.google.com/dictionary/json?callback=dict_api.callbacks.id100&q=example&sl=en&tl=en
}

function func_translate_google { 
	func_param_check 1 "Usage: $FUNCNAME [words]" "$@" 

	# might useful fields: ie=UTF-8&oe=UTF-8
	if [ $( echo $* | grep -c "[a-z]") -ge 1 ] ; 
	then	data="hl=en&tsel=0&ssel=0&client=t&sc=1&multires=1&otf=2&text=$*&tl=zh-CN&sl=en"	# en > cn
	else	data="hl=en&tsel=0&ssel=0&client=t&sc=1&multires=1&otf=2&text=$*&tl=en&sl=zh-CN"	# cn > en	# why become cn > cn !!??
	fi

	res_raw=`curl -e "http://translate.google.cn/?"							\
		-H 'User-Agent':'Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:11.0) Gecko/20100101 Firefox/11.0'	\
		-H 'Accept':'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'			\
		-s "http://translate.google.cn/translate_a/t"							\
		-d "$data"`
	[ -z "$res_raw" ] && return 1

	res_simple=`echo $res_raw | awk -F"," '{printf "%s\n", $1}' | awk -F"\"" '{print $2}'`
	echo $res_simple
	echo $res_raw
	echo -e "$*\t$res_simple\n\t$res_raw" >> $MY_ENV/list/translate_history_$(hostname)
}

function func_translate_microsoft { 
	func_param_check 1 "Usage: $FUNCNAME [words]" "$@" 

	access_token_tmp=/tmp/ms_translation_api_access_token
	access_token_compare=/tmp/ms_translation_api_access_token_compare

	access_token_uri="https://datamarket.accesscontrol.windows.net/v2/OAuth2-13"
	# parameters below are applied from https://datamarket.azure.com
	post_content="grant_type=client_credentials&client_id=ouyzhu&client_secret=0yAn46ClllxZk4CuY2tGkjo9Sl&scope=http://api.microsofttranslator.com"
	translate_uri_cn2en="http://api.microsofttranslator.com/v2/Http.svc/Translate?from=zh-CHS&to=en&text="
	translate_uri_en2cn="http://api.microsofttranslator.com/v2/Http.svc/Translate?from=en&to=zh-CHS&text="

	# Check if valid access token exist
	if [ ! -e "$access_token_tmp" ] || (( $(date +%s) > $(tail -1 $access_token_tmp) )) ; then
		echo "INFO: requesting ms translate api token"
		curl -s --data $post_content $access_token_uri > $access_token_tmp || return 1

		expire_on=$(sed -e 's/.*ExpiresOn=\([^&]*\)&.*/\1/' $access_token_tmp)
		echo -e "\n$expire_on" >> $access_token_tmp

		#expire_in=$(sed -e 's/.*"expires_in":"\([^"]*\)".*/\1/' $access_token_tmp)
		#touch -d "$expire_in seconds" $access_token_tmp
	fi
	access_token=$(head -1 "$access_token_tmp" | sed -e 's/.*"access_token":"\([^"]*\)".*/\1/')

	# Translate, both '-H "ContentType: text/plain"' and '&contentType=text%2Fplain' NOT work (always get xml)
	if [ $( echo $* | grep -c "[a-z]") -ge 1 ] ; 
	then res_raw=$(curl -s -H "ContentType: text/plain" -H "Authorization: Bearer $access_token" "${translate_uri_en2cn}$*")
	else res_raw=$(curl -s -H "ContentType: text/plain" -H "Authorization: Bearer $access_token" "${translate_uri_en2cn}$*")
	fi
	[ -z "$res_raw" ] && return 1

	echo $res_raw
	echo -e "$*\n\t$res_raw" >> $MY_ENV/list/translate_history_$(hostname)
}

function func_delete_dated { 
	func_param_check 1 "Usage: $FUNCNAME <path> <path> ..." "$@" 

	# the path might have blank, so use $*, and embrace with "" (many place used this)
	targetDir=$MY_TMP/`func_date`

	[[ ! -e $targetDir ]] && mkdir $targetDir
	mv "$@" $targetDir &> /dev/null
}

function func_backup_dated { 
	func_param_check 1 "Usage: $FUNCNAME <path>" "$@" 
	[ $# -ge 2 ] && func_die "ERROR: only one path/parameter supported"

	srcPath="$1"
	fileName=$(basename "$srcPath")
	targetFile=`func_dati`_`uname -n`_"$fileName"
	bakPath=("$MY_DOC/DCB/DatedBackup" "$HOME/amp/backup")

	# if path is a directory, zip it first
	if [ -d "$srcPath" ]; then
		# need update the var to packed ones
		targetFile=$targetFile.zip 
		packFile=$MY_TMP/$targetFile
		echo -e "INFO: Creating zip file for backup: $packFile"
		zip -rq "$packFile" "$srcPath"
		srcPath="$packFile"
	fi

	for path in "${bakPath[@]}"
	do
		if [ -e "$path" ]; then
			cp "$srcPath" "$path/$targetFile"
			[ -e "$path/$targetFile" ] && echo -e "INFO: backup success: `ls -lh \"$path/$targetFile\"`" 
			copied=$success
		else
			echo -e "WARN: backup failed, path not exist ($path)" 
		fi
	done

	[ -e "${packFile}" ] && echo -e "INFO: Deleting tmp zip file: $packFile" && rm "$packFile"
	[[ $copied != $success ]] && echo -e "\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n! Failed to do any backup!\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
}

function func_backup_listed { 
	# TODO: merge with dated_backup?
	# source ~/.myenv/env_func_bash ; func_backup_listed myenv_full $MY_ENV/zgen/myenv_fl_git2.lst $MY_ENV/list/myenv_fl_add.lst

	func_param_check 2 "Usage: $FUNCNAME <tag> <filelists>*" "$@" 

	tmp_dir=$MY_TMP/$1
	[ -e "$tmp_dir" ] && rm -rf $tmp_dir
	mkdir -p $tmp_dir
	shift
	source=$*

	for fl in $source ; do 
		[ ! -e $fl ] && echo -e "WARN: file list ($fl) not exist!" && continue
		sub_name=`basename ${fl}`
		sub_dir=$tmp_dir/${sub_name%%.*}
		mkdir $sub_dir

		# TODO duplicated code block - start - evalfl1
		sed -e "/^\s*$/d;/^\s*#/d;" $fl | while read line; do
			# eval path, check empty value
			[ -n "$line" ] && candidate=`func_eval $line` || continue
			[ -z "$candidate" ] && echo -e "WARN: candiate is empty: $line !" && continue

			# Try $HOME as base (myenv backup need this for git listed files)
			[ -e "$HOME/$candidate" ] && cp --no-preserve=all -R "$HOME/$candidate" $sub_dir && continue
			[ -e "$candidate" ] && cp --no-preserve=all -R "$candidate" $sub_dir || continue
		done
		# TODO duplicated code block - end - evalfl1

		# dirty check 1, for myenv bak, change its ACL, otherwise can not open/delete that dir
		dirty_dir=fstab.d
		[ -e $sub_dir/$dirty_dir ] && 					\
			getfacl $MY_TMP | setfacl -f - $sub_dir/$dirty_dir &&	\
			getfacl $MY_TMP | setfacl -f - $sub_dir/$dirty_dir/*

		# dirty check 2, for myenv bak, not want the .unison log file 
		[ -e $sub_dir/.unison ] && find $sub_dir/.unison/ -type f | grep -v ".*.prf" | xargs rm &> /dev/null
	done

	func_backup_dated $tmp_dir
	[ -e "$tmp_dir" ] && rm -rf $tmp_dir

	#sed -e '/`\|\$/p;/^\s*$/d;/^\s*#/d;s/\/.*//;' $source | sort -u >> $tmp_dir/$DOT_CACHE_FL
	#awk '/^\s*$/{};/^\s*#/{};/`\|\$/{print $0;next;};/\//{gsub("\/.*","",$0);print $0};' $source | sort -u >> $tmp_dir/$DOT_CACHE_FL
	#awk '/^\s*$/{print "----"$0};/^\s*#/{print "----"$0};/`\|\$/{print $0;next;};' $source | sort -u >> $tmp_dir/$DOT_CACHE_FL

	#func_gen_list_f_me	
	#bash $MY_ENV/util/listed_backup.sh myenv_full $MY_ENV/zgen/myenv.lst $MY_ENV/list/myenv_add.lst
	#$MY_ENV/util/listed_backup.sh
}

#function func_run_file_c() {
#	local file="$(readlink -f ${1})"
#	local file_name="$(basename ${1})"
#	local target_dir="$(dirname ${file})/target"
#
#	func_mkdir_cd "${target_dir}" &> /dev/null	|| func_die "ERROR: failed to make or change dir: ${target_dir}"
#	cp -f "${file}" "${target_dir}"			|| func_die "ERROR: failed to copy file, FROM: ${file}, TO: ${target_dir}"
#
#	gcc -o "${file_name%.c}" "${file_name}"
#	./"${file_name%.c}"
#	rm "${target_dir}/${file_name}"
#	\cd - &> /dev/null
#}
#
#function func_run_file_java() {
#	local file="$(readlink -f ${1})"
#	local file_name="$(basename ${file})"
#	local target_dir="$(dirname ${file})/target"
#
#	func_mkdir_cd "${target_dir}" &> /dev/null	|| func_die "ERROR: failed to make or change dir: ${target_dir}"
#	cp -f "${file}" "${target_dir}"			|| func_die "ERROR: failed to copy file, FROM: ${file}, TO: ${target_dir}"
#
#	javac ${file_name}
#	java -cp . ${file_name%.java}
#	rm "${target_dir}/${file_name}"
#	\cd - &> /dev/null
#}

function func_run_file_compile() {
	local file="$(readlink -f ${1})"
	local file_name="$(basename ${file})"
	local target_dir="$(dirname ${file})/target"

	func_mkdir_cd "${target_dir}" &> /dev/null	|| func_die "ERROR: failed to make or change dir: ${target_dir}"
	cp -f "${file}" "${target_dir}"			|| func_die "ERROR: failed to copy file, FROM: ${file}, TO: ${target_dir}"

	${2}
	${3}
	#rm "${target_dir}/${file_name}"
	\cd - &> /dev/null
}

function func_run_file() {
	func_param_check 1 "Usage: $FUNCNAME <file>" "$@" 
	
	file="${1}"
	filename="$(basename ${file})"
	[ ! -e "$file" ] && echo "ERROR: $file not exist!" && return 1

	#if [[ "$file" = *.c ]] ; then		func_run_file_c $file
	#elif [[ "$file" = *.java ]] ; then	func_run_file_java $file
	if [[ "$file" = *.c ]] ; then		func_run_file_compile $file "gcc ${filename} -o ${filename%.*}" "./${filename%.*}"
	elif [[ "$file" = *.java ]] ; then	func_run_file_compile $file "javac ${filename}"                 "java -cp . ${filename%.*}"
	elif [[ "$file" = *.rb ]] ; then	ruby $file
	elif [[ "$file" = *.sh ]] ; then	bash $file
	elif [[ "$file" = *.py ]] ; then	python $file
	elif [[ "$file" = *.php ]] ; then	php $file
	elif [[ "$file" = *.bat ]] ; then	cmd $file
	elif [[ "$file" = *.exe ]] ; then	cmd $file
	elif [[ "$file" = *.groovy ]] ; then	groovy $file
	elif [[ "$file" = *.ps1 ]] ; then	/cygdrive/c/Windows/system32/WindowsPowerShell/v1.0/powershell.exe -ExecutionPolicy RemoteSigned -File ${file//\\/\/}
	else
		echo "ERROR: can not run file $file !"
	fi
}

function func_ctrl_me {
	func_param_check 2 "Usage: $FUNCNAME <target> <action>" "$@" 

	name=$1
	action=$2
	parent=${name%%_*}
	script=/data/${parent}/${name}/bin/${action}.sh

	[ ! -e "$script" ] && func_die "ERROR: $script not exist"
	$script 
}

function func_mount_iso {
	func_param_check 2 "Usage: $FUNCNAME <target_path> <iso_path>" "$@" 

	#mount -t iso9660 -o ro,loop,noauto /your/texlive2012.iso /mnt
	sudo mount -t iso9660 -o ro,loop,noauto $2 $1
}
 
function func_build_prepare_source {
	func_param_check 3 "Usage: $FUNCNAME <source_base> <local_addr> <remote_addr>" "$@" 

	# remote first
	[ -n "$3" ] && func_build_prepare_source_remote "$1" "$3" || func_build_prepare_source_local "$1" "$2"
}

function func_build_prepare_source_remote {
	func_param_check 2 "Usage: $FUNCNAME <source_base> <remote_addr>" "$@" 

	# TODO: func_download to download?
	case "$*" in
		*/hg/*)		func_build_prepare_source_remote_hg "$@" ;;
		*/git/*)	func_build_prepare_source_remote_git "$@" ;;
		*)		echo "ERROR: unable to handle build address: $*" ;;
	esac
}

function func_build_prepare_source_remote_hg {
	func_param_check 2 "Usage: $FUNCNAME <source_base> <remote_addr>" "$@" 

	# Naming rule: /tmp/source_base_vim, will get ~/dev/code_misc/vim_-HG-
	source_base_name=$(basename ${1})
	source_base_remote=$MY_CODE_MISC/"${source_base_name##*_}"_-HG-

	mkdir -p $MY_CODE_MISC
	[ -e "$source_base_remote" ] && hg pull && hg update || hg clone "$2" "$source_base_remote"
	rm -rf "$1" ; ln -s "$source_base_remote" "$1"
}

function func_build_prepare_source_remote_git {
	func_param_check 1 "Usage: $FUNCNAME <remote_addr>" "$@" 

	# Naming rule: /tmp/source_base_vim, will get ~/dev/code_misc/vim_-GIT-
	source_base_name=$(basename ${1})
	source_base_remote=$MY_CODE_MISC/"${source_base_name##*_}"_-GIT-

	mkdir -p $MY_CODE_MISC
	[ -e "$source_base_remote" ] && git pull || git clone "$2" "$source_base_remote"
	rm -rf "$1" ; ln -s "$source_base_remote" "$1"
}

function func_build_prepare_source_remote_download {
	func_param_check 1 "Usage: $FUNCNAME <remote_addr>" "$@" 
	echo "ERROR: not implement yet"
}

function func_build_prepare_source_local {
	func_param_check 1 "Usage: $FUNCNAME <local_addr>" "$@" 
	echo "ERROR: not implement yet"
}

function func_mytask_all {
	local base=$MY_ENV_ZGEN/mytask
	local log=$base/a.log
	func_log_info $FUNCNAME $log "start"

	# find all files to execute
	for f in $base/todo_* ; do
		func_log_info $FUNCNAME $log "found $f"
		IFS="_" read -ra fa <<< "$f"
		func_mytask_${fa[1]}_run "$f"
	done

	#Name, zgen/mytask, func_mytask_mail_add/run

	# Req: one time task
	# Req: repeat task
	# Req: fix time repeat task

	#Design
	#	- Single crontab trigger (so no contend), 10s, (TODO: crontab line > run As ouyangzhu)
	#	- Async execution: add task file (parameter in file), then func_mytask_<topic>_run

	#Converstion
	#	File Name	<status>		_<topic>	_<identity>
	#			temp/fail/todo/done	mail		(unique)

	#	File Content	(use bash associate array)
	#			mt_time_deadline	func_dati, no execution after this time
	#			mt_time_win_start	func_dati, time window for start task
	#			mt_time_win_stop	func_dati, time window for stop task 
	#			mt_time_last_run	func_dati, 
	#			mt_history		(execution status, could be multiple, better with time)

	#	Func Name	func_mytask_run				run all task
	#			func_mytask_<topic>_add <filename>	add <topic> task
	#			func_mytask_<topic>_run <filename>	run <topic> task

	#func_mytask_all
	#    Parse file (todo: bash, how to splite str)
	#    Select sub func(todo: bash, how to read param)
	#    ! Log to zgen/mytask/a.log

	#func_mytask_mail_run
	#	source file
	#	calculate next exe time: mt_time_last_run + repeat_interval
	#	check start/expire time
	#	run

	#func_mytask_mail_add
}

function func_mytask_mail_run() {
	func_param_check 1 "Usage: $FUNCNAME <file>" "$@" 

	local log=$base/a.log
	func_log_info $FUNCNAME $log "execute file $f"

	source "$f"
	echo ${mytask[mt_time_deadline]}
	echo ${mytask[mt_time_win_start]}
	echo ${mytask[mt_time_win_stop]}
	echo ${mytask[mt_time_last_run]}
	echo ${mytask[mt_history]}
}

function func_tool_ins() {
	func_param_check 1 "USAGE: $FUNCNAME <tool-name> <version>" "$@"

	local ins_files="$MY_ENV/tool/${1}/init/ins"
	[ -n "${2}" ] && ins_files="${ins_files} ${ins_files}-${2}"
	eval $(func_tool_gen_vars ${ins_files})

	case "${ins_tool}" in
		apt)	func_tool_ins_apt "$@"					;;
		*)	func_die "ERROR: can NOT handle ins_tool: ${ins_tool}"	;;
	esac
}

function func_tool_ins_apt() {
	func_param_check 1 "USAGE: $FUNCNAME <tool-name> <version>" "$@"

	local ins_files="$MY_ENV/tool/${1}/init/ins"
	[ -n "${2}" ] && ins_files="${ins_files} ${ins_files}-${2}"
	eval $(func_tool_gen_vars ${ins_files})
	
	[ -n "${ins_apt_repo}" ] && func_apt_add_repo "${ins_apt_repo}"
	sudo apt-get update
	[ -n "${ins_apt_install}" ] && sudo apt-get install -y "${ins_apt_install}"
}

function func_tool_gen_vars() {
	local desc="Desc: 1) generate variable list for functions to source. 2) all variables are prefixed with 'local'"
	func_param_check 1 "${desc}" "$@"
	
	cat "$@" 2> /dev/null |\
	sed -e 	"/^\s*#/d;
		/^\s*$/d;
		s/^\([^=[:blank:]]*\)[[:blank:]]*=[[:blank:]]*/\1=/;
		s/^/local /"
}

function func_apt_add_repo() {
	func_param_check 1 "USAGE: $FUNCNAME <repo-name>" "$@"

	apt_repo_name="${1}"
	apt_source_name="$(echo ${apt_repo_name} | sed -e 's/.*://;s/\//-/')"

	if [ $(ls /etc/apt/sources.list.d/ | grep -c ${apt_source_name}) -ge 1 ] ; then
		echo "INFO: ${apt_repo_name} (${apt_source_name}) already added, skip"
		return 0
	fi

	sudo add-apt-repository -y "${apt_repo_name}" &> /dev/null
}
