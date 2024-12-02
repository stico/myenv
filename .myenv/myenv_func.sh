#!/bin/bash
# shellcheck disable=2155,1090,2034

################################################################################
# Install myenv
################################################################################
# $MY_ENV/myenv_init_self.sh for auto setup

################################################################################
# Source Dependencies
################################################################################
# Deprecated: single line self source
#source ${HOME}/.myenv/myenv_func.sh || source ./myenv_func.sh || eval "$(wget -q -O - "https://raw.github.com/stico/myenv/master/.myenv/myenv_func.sh")" || exit 1
#source $HOME/.myenv/myenv_lib.sh || source ./myenv_lib.sh || eval "$(wget -q -O - "https://raw.github.com/stico/myenv/master/.myenv/myenv_lib.sh")" || exit 1
# To simplify, just try myenv_lib.sh in myenv
MYENV_LIB_PATH="${HOME}/.myenv/myenv_lib.sh"
MYENV_SECU_PATH="${HOME}/.myenv/myenv_secu.sh"
[ -f "${MYENV_LIB_PATH}" ] && source "${MYENV_LIB_PATH}"
[ -f "${MYENV_SECU_PATH}" ] && source "${MYENV_SECU_PATH}"

DBACKUP_EX_FILENAME=".db.exclude"
DBACKUP_RESULT_STR="DBACKUP_RESULT:"
DBACKUP_BASE_DCB="${HOME}/Documents/DCB/dbackup/latest"

DUP_CONFIG="${MY_ENV}/secu/personal/dup/"
DUP_LIST_MD5="${DUP_CONFIG}/list_md5"
DUP_SKIP_MD5="${DUP_CONFIG}/skip_md5"
DUP_SKIP_PATH="${DUP_CONFIG}/skip_path"

################################################################################
# Constants
################################################################################
# Path				# NOTE: find system related env def here: $HOME/.myenv/conf/env/env_var
[ -z "$MY_DOC" ]		&& MY_DOC=$HOME/Documents
[ -z "$MY_TMP" ]		&& MY_TMP=$HOME/amp
[ -z "$MY_ENV" ]		&& MY_ENV=$HOME/.myenv
[ -z "$MY_ENV_CONF" ]		&& MY_ENV_CONF=$MY_ENV/conf
[ -z "$MY_ENV_DIST" ]		&& MY_ENV_DIST=$MY_ENV/dist
[ -z "$MY_ENV_ZGEN" ]		&& MY_ENV_ZGEN=$MY_ENV/zgen
[ -z "$MY_TAGS_NOTE" ]		&& MY_TAGS_NOTE=$MY_ENV/zgen/tags_note
[ -z "$MY_TAGS_CODE" ]		&& MY_TAGS_CODE=$MY_ENV/zgen/tags_code
[ -z "$MY_TAGS_ADDI" ]		&& MY_TAGS_ADDI=$MY_ENV/conf/addi/tags
[ -z "$MY_TAGS_LOCAL" ]		&& MY_TAGS_LOCAL=$MY_ENV/conf/addi/tags_local
[ -z "$MY_ROOTS_CODE" ]		&& MY_ROOTS_CODE=("$OUMISC" "$OUREPO")
[ -z "$MY_NOTIFY_MAIL" ]	&& MY_NOTIFY_MAIL=focits@gmail.com

if [ -z "$MY_ROOTS_NOTE" ] && [[ "$(hostname -s)" = lapmac2 ]] ; then
	MY_ROOTS_NOTE=("$MY_DCC" "$MY_DCD")
else
	MY_ROOTS_NOTE=("$MY_DCC" "$MY_DCO" "$MY_DCD")
fi

# OS
[ -z "$MY_OS_VER" ]		&& MY_OS_VER="$(func_os_ver)"
[ -z "$MY_OS_LEN" ]		&& MY_OS_LEN="$(func_os_len)"
[ -z "$MY_OS_NAME" ]		&& MY_OS_NAME="$(func_os_name)"

# Const of DW
# shellcheck disable=2088
{
[ -z "$MY_DIST_BAK" ]		&& MY_DIST_BAK="~/.myenv/dist/backup"
[ -z "$MY_DIST_BASE" ]		&& MY_DIST_BASE="~/.myenv/dist"			# diff with $MY_ENV_DIST, no expansion here
[ -z "$MY_PROD_PORT" ]		&& MY_PROD_PORT=32200
[ -z "$MY_JUMP_HOST" ]		&& MY_JUMP_HOST=jump
[ -z "$MY_JUMP_TRANSFER" ]	&& MY_JUMP_TRANSFER="~/amp/__transfer__"	# do NOT use $MY_ENV here
}

# Config
LOCATE_USE_FIND='true'		# seems tuned find is always a good choice (faster than mlocate on both osx/ubuntu). Ref: performance@locate
LOCATE_USE_MLOCATE='false'	# BUT also note the limit of the func_locate_via_find, which usually enough

################################################################################
# Functions
################################################################################
func_validate_user_name() {
	func_param_check 1 "$@"
	[ "$(whoami)" != "$*" ] && echo "ERROR: username is not $* " && exit 1
}

func_validate_user_exist() {
	func_param_check 1 "$@"
	( ! grep -q "^$*:" /etc/passwd ) && echo "ERROR: user '$*' not exist" && exit 1
}

func_validate_available_port() {
	func_param_check 1 "$@"
	[ "$(netstat -an | grep -c "$1" 2>/dev/null)" = "1" ] && func_die "ERROR: port $1 has been used!"
}

func_filter_inexist_files() {
	func_param_check 1 "$@"
	local file
	local result=()
	for file in "$@" ; do
		[ -f "${file}" ] || continue
		result+=("${file}")
	done
	echo "${result[@]}"
}

func_tag_value_raw() {
	if func_is_personal_machine ; then
		sed -n -e "s+^${1}=++p" "${MY_TAGS_ADDI}" "${MY_TAGS_LOCAL}" "${MY_TAGS_NOTE}" "${MY_TAGS_CODE}" 2>/dev/null | head -1
	else
		sed -n -e "s+^${1}=++p" "${MY_TAGS_ADDI}" "${MY_TAGS_LOCAL}" 2>/dev/null | head -1
	fi
}

func_tag_value() {
	# NO translation
	[ -z "$*" ] && return 1				# empty parameter, empty output
	[ "$*" = "." ] && echo "$*" && return 0		# probably path, translate will also cause problem
	[ "$*" = ".." ] && echo "$*" && return 0	# probably path, translate will also cause problem
	[[ "$*" = */* ]] && echo "$*" && return 0	# contain no-tag char

	local raw="$(func_tag_value_raw "${1}")"
	[ -z "$raw" ] && echo "$1" && return 0		# not a tag, return itself
	func_eval "$raw"				# eval
}

func_eval() {
	func_param_check 1 "$@"

	# eval if contains var or cmd, otherwise return itself
	if echo "$*" | grep -q '`\|$' &> /dev/null ;then
		eval echo "$*" 
	else
		echo "$*"
	fi
}

func_grep_myenv() {
	func_param_check 1 "$@"

	func_collect_myenv "no_content"
	xargs -d'\n' -a "${MY_ENV_ZGEN}/collection/myenv_filelist.txt" grep --color -d skip -I -i "$@" 2>&1

	# TODO: grep other exclude files
	# TODO: grep all files in .myenv, but skip zgen?
	grep --color -d skip -I -i "$@" "${HOME}/.ssh/config" "${MY_ENV}/myenv_secu.sh" 2>&1

	#cat $MY_ENV_ZGEN/collection/myenv_filelist.txt		| \
	#xargs -d'\n' grep -d skip -I -i "$@" 2>&1		| \
	## use relative path which is shorter
	# sed -e "s+^${base}+.+"				| \
	## re-color result. More: grep -oE ".{0,20}$search.{0,20}", to shorter the result
	#grep --color "$@"
}

func_fullpath() {
	local path="${PWD}"
	if [ $# -ne 0 ] ; then
		path="${1}"
	fi

	local fullpath="$(readlink -f "${path}")"

	if func_is_personal_machine ; then
		if func_is_os_osx ; then
			echo "${fullpath}" | tr -d '\n' | pbcopy
			echo "${fullpath}"
			return
		else
			if func_is_cmd_exist clipit ; then
				# clipit: use -p or xclip to put in primary
				echo "${fullpath}" | tr -d '\n' | clipit -c &> /dev/null
			fi
			echo "${fullpath}" 
			return
		fi
	else
		echo "$(func_ip_list | sed -e 's/.*\s\+//;/^10\./d;/^\s*$/d' | head -1):${fullpath}"
	fi
}

func_to_clipboard() {
	# read from stdin

	# put data into clipboard, each line as an entry
	while IFS= read -r line || [[ -n "${line}" ]]; do 
		echo "$line"
		if func_is_os_osx ; then
			echo "${line}" | tr -d '\n' | pbcopy
		else
			echo "${line}" | tr -d '\n' | clipit -c &> /dev/null
			echo "${line}"
		fi
		# osx need wait some time, 0.2 seems too short, why? 
		sleep 0.5
	done
	#done < <(echo "$*")
}

func_std_gen_tags() {
	local d dd note_file note_filename
	rm "${MY_TAGS_NOTE}"
	for d in "${MY_ROOTS_NOTE[@]}" ; do
		[ ! -e "${d}/note" ] && func_die "ERROR: ${d}/note not exist!"
		for note_file in "${d}"/note/*.txt ; do
			[[ -e "$note_file" ]] || continue
			local note_filename="${note_file##*/}"
			local topic_linkpath="${d}/${note_filename%.txt}/${note_filename}"
			if [ -e "${topic_linkpath}" ] ; then
				echo "${note_filename%.txt}=${topic_linkpath}" >> "${MY_TAGS_NOTE}"
			else
				echo "${note_filename%.txt}=${note_file}" >> "${MY_TAGS_NOTE}"
			fi
		done
	done

	rm "${MY_TAGS_CODE}"
	for d in "${MY_ROOTS_CODE[@]}" ; do
		[[ -e "$d" ]] || continue
		for dd in "${d}"/* ; do
			[[ -e "$dd" ]] || continue
			echo "${dd##*/}=${dd}" >> "${MY_TAGS_CODE}"
		done
	done
	echo "INFO: standarize of tags generation, done"
}

func_std_gen_links() {
	# STD 1: if there is dir and note have same name, there should be a link
	local d note_file
	for d in "${MY_ROOTS_NOTE[@]}" ; do
		[ ! -e "${d}/note" ] && func_die "ERROR: ${d}/note not exist!"
		for note_file in "${d}"/note/*.txt ; do
			[[ -e "$note_file" ]] || continue
			local note_filename="${note_file##*/}"
			local topic_basepath="${d}/${note_filename%.txt}"
			if [ -d "${topic_basepath}" ] && [ ! -f "${topic_basepath}/${note_filename}" ] ; then
				pushd "${topic_basepath}" &> /dev/null
				ln -s "../note/${note_filename}" .
				popd &> /dev/null
			fi
		done
	done
	echo "INFO: standarize of links generation, done"
}

func_std_standarize() {
	func_std_gen_links
	func_std_gen_tags
}

# shellcheck disable=2155
func_select_line() {
	# NOTE: bash script "select i in mon tue wed exit # $i will be the selected str", good for quick interactive
	local usage="Usage: ${FUNCNAME[0]} <content>" 
	func_param_check 1 "$@"

	local content="${1}"
	
	# content empty
	if func_is_str_blank "${content}" ; then
		echo "WARN: content for selection is blank" 1>&2
		return
	fi

	# single line
	local lines="$(echo "${content}" | wc -l)"	
	(( lines == 1 )) && echo "${content}" && return
	
	# ask for selection
	local selection="$(( lines + 1 ))"
	while (( selection <= 0 )) || (( selection > lines )) ; do
		func_head 20 "${content}" | cat -n | sed -e "s/\s\+\([0-9]\+\).*/& \1/"	1>&2
		echo "MULTIPLE CANDIDATES, PLS SELECT ONE:"				1>&2
		read -r -e selection
	done
	echo "${content}" | sed -n -e "${selection}p"
}

func_diff_localtolapmac2() {
	! [[ "$(hostname -s)" = lapmac3 ]] && echo "ERROR: current host is NOT lapmac3, pls check!" && return
	func_param_check 1 "$@"

	local local_path remote_path
	if [[ "$#" = 1 ]] ; then
		local_path="${1}"
		remote_path="${1}"
	else
		local_path="${1}"
		remote_path="${2}"
	fi

	local remote_cmd="cat '${remote_path}'"
	diff "${local_path}" <(ssh lapmac2 "${remote_cmd}")
	
}

func_vi_conditional() {
	# cygwin env: win style path + background job
	if [ "${MY_OS_NAME}" = "${OS_CYGWIN}" ] ; then
		target_origin="${!#}"
		parameters=( "${@:1:$(($#-1))}" )
		[ -z "$target_origin" ] && target_cyg="" || target_cyg=$(cygpath -w "$target_origin")
		( \\gvim "${parameters[@]}" "$target_cyg" & ) &> /dev/null
		return 0
	fi

	# GUI env: use gvim/macvim (gui)
	# NOTE 1: use window title "SINGLE_VIM" to identify
	# NOTE 2: seems in ubuntu gui, not need "&" to make it background job
	# NOTE 3: python in zbox will set env "LD_LIBRARY_PATH" which makes Vim+YouCompleteMe not works
	# NOTE 5: why? seems direct use "vim" will NOT trigger "vim" alias, I suppose this happens and cause infinite loop, BUT it is not!
	local macvim_path="$HOME/.zbox/ins/macvim/macvim-git/MacVim.app/Contents/MacOS/mvim"
	if func_is_os_osx ; then
		# pre condition: '+clientserver', "-g": use GUI version
		# directly use "vim -g" behaves wired (mess up terminal)
		#LD_LIBRARY_PATH="" /Users/ouyangzhu/.zbox/ins/macvim/macvim-git/MacVim.app/Contents/MacOS/Vim -g --servername SINGLE_VIM --remote-tab "$@"
		if [ -e "${macvim_path}" ] ; then
			"${macvim_path}" -g --servername SINGLE_VIM --remote-tab "$@"
		elif func_is_cmd_exist gvim ; then
			gvim -g --servername SINGLE_VIM --remote-tab "$@"
		fi

		# Seems osx mojave not need this any more
		# # Need wait for the 1st time. (Why open 2 vim for the 1st time) 
		# ps -ef | grep -v grep | grep "vim.*--servername SINGLE_VIM" &> /dev/null || sleep 2
		# open -a MacVim
		return 0

	elif [ -z "$DISPLAY" ] ; then
		# Terminal mode: prefer vim if available, otherwise vi
		if func_is_cmd_exist vim ; then
			"vim" "$@"
		else
			"vi" "$@"
		fi
		return 0

	elif func_is_cmd_exist gvim ; then
		# otherwise prefer gvim
		if LD_LIBRARY_PATH="" gvim --version | grep -q '+clientserver' ; then
			LD_LIBRARY_PATH="" gvim --servername SINGLE_VIM --remote-tab "$@"
		else
			LD_LIBRARY_PATH="" gvim "$@"
		fi

		if [ -e /usr/bin/wmctrl ] ; then
			# why? if not sleep after init (1st time), will open 2 files, currently 1s is enough
			/usr/bin/wmctrl -l | grep -q 'SINGLE_VIM' || sleep 1
			/usr/bin/wmctrl -a 'SINGLE_VIM'
		fi
		return 0
	else	
		if func_is_cmd_exist vim ; then
			"vim" "$@"
		else
			"vi" "$@"
		fi
		return 0
	fi
}

func_load_virtualenvwrapper() {
	echo "INFO: loading virtual env (Virtualenvwrapper) for Python"

	[ -z "${PYTHON_HOME}" ] && func_die "ERROR: env PYTHON_HOME not set"
	mkdir -p "${HOME}/amp/workspace/virtualenv" &> /dev/null

	export VIRTUALENVWRAPPER_PYTHON=${PYTHON_HOME}/bin/python
	export PS1="(VirtualEnv) ${PS1}"
	export WORKON_HOME=${HOME}/.virtualenvs
	export PROJECT_HOME=${HOME}/amp/workspace/virtualenv
	export VIRTUALENVWRAPPER_VIRTUALENV=${PYTHON_HOME}/bin/virtualenv
	export VIRTUALENVWRAPPER_VIRTUALENV_ARGS='--no-site-packages'
	export PIP_VIRTUALENV_BASE=${WORKON_HOME}
	export PIP_RESPECT_VIRTUALENV=true
	source "${PYTHON_HOME}/bin/virtualenvwrapper.sh"
}

func_load_rvm() {
	echo "INFO: loading Ruby Version Manager, note the 'cd' cmd will be hijacked"

	[ -z "$RVM_HOME" ] && export RVM_HOME=$HOME/.rvm && export PATH="$PATH:$RVM_HOME/bin"

	# step 1: rvm hacks command "cd", record it before myenv loads func_cd_tag
	local init_src="$RVM_HOME/scripts/rvm"
	source "${init_src}" || func_die "ERROR: failed to source ${init_src} !"
	[ "$(type -t cd)" = "function" ] && eval "function func_rvm_cd $(type cd | tail -n +3)"

	# step 2: rvm need update path to use specific ruby version, this should invoke after myenv set PATH var
	local ver="$("$RVM_HOME/bin/rvm" list | sed -n -e "s/^=.*ruby-\([^ ]*\)\s*\[.*/\1/p" | head -1)"
	local ver_gemset="ruby-${ver}@global"
	if [ -n "${ver}" ] ; then
		echo "INFO: use version ${ver_gemset}"
		rvm use "${ver_gemset}" --default || func_die "ERROR: can not find any usable version"
		#$RVM_HOME/bin/rvm use "ruby-${ver}@global" --default	# why not work? just prefixed with $RVM_HOME/bin
	fi

	# step 3: update PS1
	export PS1="(RVM) ${PS1}"
}

func_locate_updatedb() {
	[ "${LOCATE_USE_FIND}" = "true" ] && return 0
	echo "INFO: update locate db"
	sudo updatedb
}

func_locate() {
	local usage="Usage: ${FUNCNAME[0]} [type] [base] [items...]" 
	func_param_check 3 "$@"

	if [ "${LOCATE_USE_FIND}" = "true" ] ; then
		func_locate_via_find "$@"
	elif [ "${LOCATE_USE_MLOCATE}" = "true" ] ; then
		func_locate_via_locate "$@"
	fi
}

func_locate_via_find() {
	local usage="Usage: ${FUNCNAME[0]} <type> <base> <search_items...>" 
	func_param_check 3 "$@"

	# IMPORTANT: maxdepth which dramatically improved response time

	# variables
	local maxdepth=$#			# collect here, so effectively = param_count + 2
	local find_type_raw="${1}"
	local base="$(readlink -f "${2}")"	# important: use the formal path
	shift; shift;
	local search_raw="$*"

	# check 
	func_validate_path_exist "${base}"	# NOTE, tag should be translated before use this funciton
	[ -z "${search_raw}" ] && func_die "ERROR: <search_items> must NOT be empty, abort!"

	# prepare
	local find_type
	case "${find_type_raw}" in
		FILE)	find_type=f ;;
		DIR)	find_type=d ;;
		*)	func_die "ERROR: parameter <type> must be either FILE or DIR" 1>&2
	esac
	#local search=$(echo "${search_raw}" | sed -e '/^$/q;s/ \|^/.*\/.*/g;s/$/[^\/]*/')	# version 1: works
	local search="${base}/.*${search_raw// /.*}.*"						# version 2: works. More precise: prefix with base. Less strict: no / between <search_items>

	targets="$(find -P "$base" -maxdepth "${maxdepth}" -iregex "$search" -xtype ${find_type} | sed -e "/^$/d")"			# 1st, try not follow links
	[ -z "$targets" ] && targets="$(find -L "$base" -maxdepth "${maxdepth}" -iregex "$search" -type ${find_type} | sed -e "/^$/d")"	# 2nd, try follow links 
	[ -z "$targets" ] && return 1													# 3rd, just return error

	# use the shortest result
	echo "$targets" | awk '{ print length, $0 }' | sort -n | cut -d" " -f2- | head -1
}

func_locate_via_locate() {
	local usage="Usage: ${FUNCNAME[0]} [type] [base] [items...]" 
	func_param_check 3 "$@"

	local type="${1}"
	local base="$(readlink -f "${2}")"	# important: use the formal path
	shift; shift
	local pattern="$(echo "${base}/ $* " | sed -e "s/\s/.*/g")"
	locate -i --regex "${pattern}" | while IFS= read -r line; do
		case "${type}" in
			FILE)	[ -f "${line}" ] && echo "${line}" && return 0 ;;
			DIR)	[ -d "${line}" ] && echo "${line}" && return 0 ;;
			*)	echo "ERROR: func_locate_via_locate need a TYPE parameter" 1>&2
		esac
	done
}

func_clean_less() {
	cat "$@" | func_del_blank_and_hash_lines | less
}

func_clean_grep() {
	local usage="Usage: ${FUNCNAME[0]} <grep_str> <file_path>" 
	func_param_check 2 "$@"
	
	local grep_str="${1}"
	shift

	# grep in pipe end, to reserve highlights of match part
	if [[ "$#" -eq 1 ]] ; then
		cat "$@" | func_del_blank_and_hash_lines | grep "${grep_str}"
	else
		# need heading filename for multiple file grep
		grep '' "$@" | func_del_blank_and_hash_lines | grep "${grep_str}"
	fi
}

# keep here just for backward compitability, should use func inside directly
func_clean_cat() {
	func_del_blank_and_hash_lines "$@"
}

func_vi() {
	# shortcut - open a new one
	[ -z "$*" ] && func_vi_conditional && return 0

	local base="$(func_tag_value "${1}")"

	# 1 param: priority: file exist > tag exist > normal
	if [ $# -eq 1 ] ; then
		[ -e "${1}" ] && func_vi_conditional "${1}" && return 0
		[ -e "${base}" ] && func_vi_conditional "${base}" && return 0
		func_vi_conditional "${1}"
		return 0
	fi

	# 2+ param: v2: use locate 
	[ -d "$base" ] && shift || base="./"
	[ "$(stat -c "%d:%i" ${base})" == "$(stat -c "%d:%i" /)" ] && func_die "ERROR: base should NOT be root (/)"
	[ "$(stat -c "%d:%i" ${base})" == "$(stat -c "%d:%i" "${HOME}")" ] && func_die "ERROR: base should NOT be \$HOME dir"
	func_vi_conditional "$(func_locate "FILE" "${base}" "$@")"

	# 2+ param: v1: old .fl_me.txt
	# Find target, if cache version return error, try no-cache version
	# func_find_dotcache result_target f $base $* || func_find result_target f $base $*
	#[ -n "$result_target" ] && func_vi_conditional "$base/$result_target" || func_vi_conditional "$@"
}

func_cd_tag() {

	# 1) shortcuts
	[ -z "$*" ]     && func_cd_smart    && return 0			# home
	[ "-"  = "$*" ] && func_cd_smart -  && return 0			# last dir
	[ "."  = "$*" ] && func_cd_smart .  && return 0			# current dir
	[ ".." = "$*" ] && func_cd_smart .. && return 0			# parent dir, note even current dir is a link in parent dir, cmd 'cd' will handle correctly

	# 2) single & relative path, including ./xxx format and ../xxx (if current dir in parent dir is NOT a link)
	[ $# -eq 1 ] && [ -d "${1}" ] && func_cd_smart "${1}" && return 0

	# 3) single & relative path of ../xxx, but current dir in parent dir IS a link, need to re-assemble the path
	if [ $# -eq 1 ] && [[ ${1} = ../* ]] ; then
		local relative_parent="$(dirname "${PWD}")/${1#..}"	# NOTE: "${PWD})/${1}" NOT works
		if [ -d "${relative_parent}" ] ; then
			func_cd_smart "${relative_parent}" 
			return 0
		fi
	fi
	
	# 4) try tag eval, use its dir if it is a file
	local base="$(func_tag_value "${1}")"
	[ -f "${base}" ] && base="$(dirname "${base}")"

	# 4.1) direct cd for single tag
	if [ $# -eq 1 ] ; then
		func_cd_smart "${base}" 
		return 0 
	fi

	# 4.2) find target. Version 2, use func_locate
	[ -d "${base}" ] && shift || base="./"
	func_cd_smart "$(func_locate "DIR" "${base}" "$@")"

	# x) find target. Version 1, old .dl_me.txt: 1) use current dir if base inexist 2) Find target, firstly cached version, otherwise no-cache version
	#[ -d "${base}" ] && shift || base="./"
	#func_find_dotcache result_target d $base $* || func_find result_target d $base $*
	#func_cd_smart "${base}/${result_target}"
}

func_best_hostname() {
	local usage="Usage: ${FUNCNAME[0]}" 
	local desc="Desc: try to get a more meaning fullname of host"
	
	local ip hostname used bakname useless usefull

	# case 1: always use hostname
	hostname="$(hostname -s)" 
	used="/baiduvm/awsvm/myvm/azvm/"
	if func_is_os_osx || func_is_personal_machine ; then	# check if personal (assume osx also yes)
		echo "${hostname}"
		return
	fi
	if [[ "${hostname}" = lapmac* ]] || [[ "${hostname}" = workpc* ]] ; then	# might have number to match
		echo "${hostname}"
		return
	fi
	if [[ "${used}" = */${hostname}/* ]] ; then					# used 
		echo "${hostname}"
		return
	fi

	# case 2: use bakname
	useless="/ubuntu/to-add-more/"
	ip="$(func_ip_single)"
	[ -n "${ip}" ] && bakname="${ip}" || bakname="canNotFindAnySuitableHostname"
	
	# TODO: simplify to directly use bakname?
	if [[ "${useless}" = */${hostname}/* ]] ; then
		echo "$(bakname)"
		return
	fi
	echo "${bakname}"
}

func_is_personal_machine() {
	#grep -q "^bash_prompt_color=green" "${SRC_BASH_HOSTNAME}" "${SRC_BASH_MACHINEID}" &> /dev/null 
	[ "${bash_prompt_color:-NONONO}" == "green" ] && return 0 || return 1

	# can NOT use this, otherwise test.16 will have same prompt as lapmac2
	#[ -e "$HOME/.ssh/stico_github" ] && return 0
}

func_is_internal_machine() {
	func_ip_list | grep -q '[^0-9\.]\(10\.\|172\.\|192\.\|fc00::\|fe80::\)' 
}

func_cd_smart() {
	# Old rvm support
	# (2013-06-12) seems not checking and using func_rvm_cd could also source rvm, why?
	#[ "$(type -t func_rvm_cd)" = "function" -a -e "$*/.rvmrc" ] && func_rvm_cd .
	#[ "$(type -t func_rvm_cd)" = "function" -a -e "$*/.rvmrc" ] && func_rvm_cd "$*" && return 0

	# perform cd
	if [ -z "$*" ] ; then
		"cd" || return 1		# return if failed, following steps are unecessary then
	else
		"cd" "$*" || return 1		# return if failed, following steps are unecessary then
	fi

	# ls based on env
	local opts="-hF --color=auto" 
	func_is_personal_machine || opts="-ltrhF --color=auto"

	# shellcheck disable=2086
	"ls" ${opts}

	# status code always success, otherwise func_cd_tag NOT work
	:

	# Deprecated - NO svn status

		# show vcs status: NOT show if jump from sub dir, BUT show for $HOME since most dir are its sub dir
		# change: the sub dir rule seems confusing, especially when there is symbolic links, or oumisc in zbox 
		#if [[ "${OLDPWD##$PWD}" = "${OLDPWD}" ]] || [[ "$PWD" = "$HOME" ]]; then
		#fi

		# There are some dir mount via samba, use svn status makes it wait too long
		#if [[ "${PWD##*/}" == "dev-res-guide" ]] ; then
		#	:
		#	# svn status cost lots time for dev-res-guide, so skip
		#else	
		#	[ -e ".hg" ] && command -v hg &> /dev/null && hg status
		#	[ -e ".svn" ] && command -v svn &> /dev/null && svn status
		#	[ -e ".git" ] && command -v git &> /dev/null && git status
		#fi
}

func_head_cmd() {
	local usage="Usage: ${FUNCNAME[0]} [show_lines] [cmd]" 
	func_param_check 2 "$@"

	local show_lines=$1
	shift

	local cmd_result=$(eval "$*")
	func_head "$show_lines" "$cmd_result"
}

func_notify_mail() {
	local usage="Usage: ${FUNCNAME[0]} [title] [content]" 
	func_param_check 2 "$@"

	local title="${1}"
	shift
	echo "$*" | mutt -s "$title" ${MY_NOTIFY_MAIL}
}

func_check_cronlog() {
	local log=/home/ouyangzhu/.myenv/zgen/cron.log 
	local errors="$(grep -i "error" "${log}")"

	if [ -n "${errors}" ] ; then
		echo "ERROR: Found error message in ${log}, sending notifications"
		func_notify_mail "ERROR: [MYENV Notify] cronlog has ERROR ($(hostname -s))!" "$errors"
	else
		echo "INFO: No err found in ${log}, not notificaton needed"
	fi
}

func_collect_statistics() {
	# MNT: stats of collect, to help reduce the file size

	local f 
	local base=$MY_ENV_ZGEN/collection

	for f in "${base}"/* ; do
		[[ -e "$f" ]] || continue
		echo "${f}"
		# TODO

		# use function in pipe
		#export -f func_param_check
		#export -f func_is_file_type_text
		#cat myenv_filelist.txt | xargs -n 1 -I{} bash -c 'func_is_file_type_text {} && wc -l {}' | sort -n | tee /tmp/2
	done
}

func_collect_myenv() {
	# extract alone as "func_grep_myenv" need update file list frequently
	# NOTE: myenv_content/myenv_filelist might duplicate with caller

	local base=${MY_ENV_ZGEN}/collection
	local myenv_content=${base}/myenv_content.txt
	local myenv_filelist=${base}/myenv_filelist.txt
	local myenv_git="$("cd" "$HOME" && git ls-files | sed -e "s+^+$HOME/+")"
	local myenv_addi="$(eval "$(sed -e "/^\s*$/d;/^\s*#/d;" "$MY_ENV_CONF/addi/myenv" | xargs -I{}  echo echo {} )")"

	[ -e "${base}" ] || mkdir -p "${base}"
	[ -e "${myenv_filelist}" ] && func_delete_dated "${myenv_filelist}"
	[ -e "${myenv_content}" ] && [ "${1}" = "true" ] && func_delete_dated "${myenv_content}"

	for f in ${myenv_git} ${myenv_addi} ; do
		#[ ! -e "$f" ] && echo "WARN: file inexist: ${f}" && continue

		[ ! -e "$f" ] && continue
		echo "${f}" >> "${myenv_filelist}"

		[ "${1}" = "with_content" ] || continue
		func_is_file_type_text "${f}" || continue
		echo -e "\n\n@${f}\n"  >> "${myenv_content}"
		sed -e "s///" "${f}" >> "${myenv_content}"
	done
}

# shellcheck disable=2016,2129
func_collect_all() {
	# Tips: find encoding error files: grep "^@/" code_content.txt | sed -e 's/^@/file -e soft "/;s/$/"/' | bash | tee /tmp/1 | grep -v "\(ASCII text\|UTF-8 Unicode\)"

	# TODO: too much file in FCS, 7w lines in 2015-09

	# vars
	local f d line
	local base=$MY_ENV_ZGEN/collection
	[ -d "${base}" ] || mkdir -p "${base}" 

	# IMPORTANT: do NOT remove the ${base} dir, otherwise might confusing in debug: 
	#	- cd into ${base} and then run func_collect_all(), 
	#	- then ${base} has been deleted, you are now actually in ~/amp/delete/xxxx-xx-xx
	#	- you always check the old file!
	#	- EVER WORSE: the pwd command seem NOT showing the correct current path ! (this happens as least on osx)
	echo "INFO: clean old collection and updatedb (if need)"
	func_delete_dated "${base}"/*
	func_locate_updatedb

	echo "INFO: collecting stdnote and gen quicklist"
	local count=0
	local stdnote_content=${base}/stdnote_content.txt
	local stdnote_outline=${base}/stdnote_outline.txt
	local stdnote_filelist=${base}/stdnote_filelist.txt
	local stdnote_quicklist=${base}/stdnote_quicklist.txt
	for d in "${MY_ROOTS_NOTE[@]}" ; do
		for f in "${d}"/note/* ; do  
			[[ -e "$f" ]] || continue
			local filename=${f##*/} 
			local dirname="${d}/note"
			local fullpath="${d}/note/${f#"${dirname}"}"

			echo "${fullpath}"							>> "${stdnote_filelist}"

			echo -e "\n\n@${fullpath}\n"						>> "${stdnote_content}"
			sed -e "s///" "${f}"							>> "${stdnote_content}"
			
			printf "%-26s" "${filename%.txt}"					>> "${stdnote_quicklist}"
			count=$(( count + 1 )) && (( count % 4 == 0 )) && printf "\n"		>> "${stdnote_quicklist}"

			echo -e "\n\n@${fullpath}\n"						>> "${stdnote_outline}"
			grep "^[[:space:]]*[-_\.[:alnum:]]\+[[:space:]]*$" "${fullpath}"	>> "${stdnote_outline}"
		done
	done
	echo "INFO: >> $(wc -l "${stdnote_outline}") lines"

	echo "INFO: collecting miscnote"
	local miscnote_content=${base}/miscnote_content.txt
	local miscnote_filelist=${base}/miscnote_filelist.txt
	if func_is_os_osx ; then
		mdfind -name NOTE | sed -e '/txt$/!d;/NOTE/!d;/\/amp\//d' >> "${miscnote_filelist}"
	else
		locate --regex "(/A_NOTE.*.txt|--NOTE.*txt)$" | sed -e "/\/amp\//d" >> "${miscnote_filelist}"
	fi
	while IFS= read -r line || [[ -n "${line}" ]] ; do
		echo -e "\n\n@${line}\n"  >> "${miscnote_content}"
		sed -e "s///" "${line}" >> "${miscnote_content}"
	done < "${miscnote_filelist}"
	echo "INFO: >> $(wc -l "${miscnote_content}") lines"

	echo "INFO: collecting myenv"
	local myenv_content=${base}/myenv_content.txt
	local myenv_filelist=${base}/myenv_filelist.txt
	func_collect_myenv "with_content"
	echo "INFO: >> $(wc -l "${myenv_content}") lines"

	echo "INFO: collecting code"
	local code_content=${base}/code_content.txt
	local code_filelist=${base}/code_filelist.txt
	for d in "${MY_ROOTS_CODE[@]}" ; do
		pushd "${d}" &> /dev/null
		git ls-files | sed -e "s+^+${d}/+" >> "${code_filelist}"
		popd &> /dev/null
	done
	echo "INFO: >> $(wc -l "${code_filelist}") files"

	# NOTE: no blank line allowed (sed will complain)
	sed								\
	`# file types`							\
	-e "/\.jmx$/d"				`# jmeter file`		\
	-e "/\.xsd$/d"							\
	-e "/\.wsdl$/d"							\
	`# filename with version info`					\
	-e "/\(bootstrap\|echars\)[-_\\.[:alnum:]]*\.\(css\|js\)/d"	\
	-e "/\(highcharts\|jquery\)[-_\\.[:alnum:]]*\.\(css\|js\)/d"	\
	-e "/\(leap\|[Mm]arkdown\)[-_\\.[:alnum:]]*\.\(css\|js\)/d"	\
	-e "/\(reveal\|style\)[-_\\.[:alnum:]]*\.\(css\|js\)/d"		\
	-e "/\(stomp\|sockjs\)[-_\\.[:alnum:]]*\.\(css\|js\)/d"		\
	-e "/\(zoom\)[-_\\.[:alnum:]]*\.\(css\|js\)/d"			\
	`# project resource files`					\
	-e "/\/cs-base\/.*.\(html\|css\|js\)/d"				\
	-e "/\/service-center\/.*.\(html\|css\|js\)/d"			\
	`# speicific paths`						\
	-e "/\/zbase\/sql\//d"						\
	-e "/\/thrift\/gen\//d"						\
	-e "/\/note\/dc[cdo]/d"			`# already in stdnote`	\
	-e "/\/sysop_fed_lib\//d"		`# libs, useless`	\
	-e "/\/css\/\(print\|theme\)\//d"				\
	-e "/\/js\/prettify\//d"					\
	-e "/\/main\/js\/node_modules\//d"				\
	-e "/\/main\/resources\/static\//d"				\
	-e "/\/main\/webapp\/plugins\//d"				\
	-e "/\/main\/webapp\/css\/skins\//d"				\
	-e "/\/src\/org\/csapi\/www\/\(wsdl\|schema\)\//d"		\
	`# speicific files`						\
	-e "/\/yyembed-server-data\/pindaoblacklist.thrift/d"		\
	-e "/Test_Record.txt/d;/SIG_Messaging.xml/d"			\
	-e "/sinfo\/src\/main\/webapp\/js\/app.js/d"			\
	-e "/jserverlib\/tmp_jdd\/converter.jade/d"			\
	-e "/java_std_ppt\/java_std_ppt.html/d"				\
	-e "/note\/zmp\/schedule_history.txt/d"				\
	-e "/resources\/sql\/test-data.sql/d"				\
	-e "/dump1.out/d;/struts-tags.tld/d"				\
	-e "/webapp\/css\/AdminLTE.css/d"				\
	`# misc`							\
	-e "/Stub.java/d"						\
	-e "/\/ant\/.*\/reports\//d"					\
	-e "/\/html\/ref_html.*.htm/d"					\
	-e "/\/template_war_spring\/.*\/blueprint\//d"			\
	"${code_filelist}" | while IFS= read -r line || [[ -n "${line}" ]] ; do
		func_is_file_type_text "${line}" || continue
		echo -e "\n\n@${line}\n"  >> "${code_content}"
		sed -e "s///" "${line}" >> "${code_content}"
	done
	echo "INFO: >> $(wc -l "${code_content}") lines"

	echo "INFO: collecting mydoc filelist"
	local mydoc_filelist=${base}/mydoc_filelist.txt
	#for d in DCB  DCC  DCD  DCM DCO  ECB  ECE  ECH  ECS  ECZ  FCS  FCZ ; do	# v1, deprecated
	#for d in DCB  DCC  DCD  DCM DCO  ECB  ECE  ECH  ECZ  ECS ; do			# v2, deprecated, put ECS in the end
	for d in DCB DCC DCD DCH DCM DCO DCS FCS ; do					# v3, compacted docs
		# shellcheck disable=2015
		# TODO: use func_pipe_remove_lines instead
		( func_is_os_osx					\
		&& find "${MY_DOC}/${d}" -type f			\
		|| locate "$(readlink -f "${MY_DOC}/${d}")" )		\
		| sed							\
		-e "/\/DCD\/mail\//d"					\
		-e "/\/sysop_fed_lib\//d"				\
		-e "/\/js\/prettify\//d"				\
		-e "/\/Contact\/osx_contacts\//d"			\
		-e "/\/css\/\(print\|theme\)\//d"			\
		-e "/\/main\/js\/node_modules\//d"			\
		-e "/\/main\/resources\/static\//d"			\
		-e "/\/main\/webapp\/plugins\//d"			\
		-e "/\/main\/webapp\/css\/skins\//d"			\
		-e "/\/\.\(git\|svn\|hg\|idea\)\//d"			\
		-e "/\/DCS\/[^\/]*\/[^\/]*\//d" `# only 2 sub layer`	\
		-e "/\/FCS\/[^\/]*\/[^\/]*\//d" `# only 2 sub layer`	\
		-e "/\/target\//d" `# maven project target`		\
		-e "/\.\(gif\|jpg\|jpeg\|svg\|webp\|bmp\|png\|tiff\|tif\|heic\|aae\|mp4\|mov\|m4a\)$/Id" `# for DCM`	>> "${mydoc_filelist}"


		#-e "/\/zbase-yyworld\//d" `# have client_zbase`	\
		#-e "/\/vendor\/ZF2\//d"				\
		#-e "/\/framework\/i18n\//d"				\
		#-e "/\/extjs\/resources\//d"				\
		#-e "/\/FCS\/vim\/vim-hg\//d"				\
		#-e "/\/FCS\/maven\/m2_repo\//d"			\
		#-e "/\/FCS\/eclipse\/plugins\//d"			\
		#-e "/\/vendor\/zendframework\//d"			\
		#-e "/\/xiage_trunk\/static\/image\//d"			\
		#-e "/\/xiage_trunk\/source\/class\//d"			\
		#-e "/\/xiage_trunk\/source\/plugin\//d"		\
		#-e "/\/xiage_trunk\/static\/image\//d"			\
		#-e "/\/xiage_trunk\/source\/class\//d"			\
		#-e "/\/xiage_trunk\/source\/plugin\//d"		\
		#| sed -e "/\/\(\.git\|\.svn\|\.hg\|target\)\//d;" | wc -l
	done
	echo "INFO: >> $(wc -l "${mydoc_filelist}") lines"

	echo "INFO: collecting all"
	local all_content=${base}/all_content.txt
	cat "${stdnote_quicklist}"	"${stdnote_outline}"							>> "${all_content}"
	cat "${stdnote_content}"	"${miscnote_content}"	"${myenv_content}"	"${code_content}"	>> "${all_content}"
	#cat "${stdnote_content}"	"${miscnote_content}"	"${myenv_content}"				>> "${all_content}"
	cat "${stdnote_filelist}"	"${miscnote_filelist}"	"${myenv_filelist}"	"${code_filelist}"	>> "${all_content}"
	cat "${mydoc_filelist}"											>> "${all_content}"

	echo "INFO: shorten file path"
	sed -i -e 's+^\(@*\)/home/ouyangzhu/.myenv/+\1$MY_ENV/+' "${all_content}"
	sed -i -e 's+^\(@*\)\(/ext\|/home/ouyangzhu\)/Documents/\([DEF]C.\)/+\1$MY_\3/+' "${all_content}"
	sed -i -e 's+^\(@*\)/home/ouyangzhu/+\1$HOME/+' "${all_content}"

	#echo "INFO: add extra quicklink at the beginning"
	#sed -i -e "1i${code_content}\n" "${all_content}"
}

func_repeat() {
	local usage="Usage: ${FUNCNAME[0]} <interval> <times> <cmd>" 
	func_param_check 3 "$@"

	count=1
	times="$2"
	interval="$1"
	shift;shift

	#for count in $(eval echo {1..$times}) ; do	# when times value big, will slow or not work
	while (( count <  times )); do
		eval "$@" 
		((count++))
		sleep "$interval"
		echo -e "\n\n------------------------- Count: $count / $times -------------------------\n\n"
	done
}

func_mgrep() {
	local usage="Usage: ${FUNCNAME[0]} <search_file> <string> <string> ..." 
	func_param_check 2 "$@"

	# TODO: NOT really useful, unless do thesee: 1) support multiple file like grep (extract file list). 2) grep pattern/string one by one
	local f="${1}"
	shift
	grep "$@" "${f}"
}

func_grep_cmd() {
	local usage="Usage: ${FUNCNAME[0]} <search_str> <cmd>" 
	func_param_check 2 "$@"

	search_str=$1
	shift
	eval "$@" | grep -i "$search_str"
}

func_head() {
	local usage="Usage: ${FUNCNAME[0]} [show_lines] [text]" 
	func_param_check 2 "$@"

	show_lines=$1
	shift

	total_lines=$(echo "$*" | wc -l)
	echo "$*" | sed -n -e "1,${show_lines}p;${show_lines}s/.*/( ...... WARN: more lines suppressed, $total_lines total ...... )/p"
}

func_mvn_clean() { 
	local log=$(mktemp)

	pushd . &> /dev/null
	echo "INFO: start to do 'mvn clean', check log at: $log"
	while IFS= read -r -d '' line ; do
		local d=$(dirname "$line")
		echo "INFO: cd $d && mvn clean"
		"cd" "$d" && mvn clean >> "$log" 2>&1
	done < <(find "$PWD" -name pom.xml -print0)
	popd &> /dev/null
}

func_mvn_run() { 
	local usage="Usage: ${FUNCNAME[0]} [class]" 

	# search candidates
	if [ -n "${1}" ] ; then
		# based on param, support (part of) filename, classname, path, etc
		local candidates="$(find src/{main,test}/java -iregex ".*${1}.*" 2> /dev/null | sed -e '/\.java$/!d')"
	else
		# otherwise find all java file, exclude "test" dir to shorten the result
		local candidates="$(find src/main/java -name "*.java" 2> /dev/null )"
	fi

	# select candidate
	if [ "$(echo "${candidates}" | wc -l)" = "1" ] ; then
		mvn_run_file="${candidates}"
	else
		mvn_run_file="$(func_select_line "${candidates}")"
	fi

	# execute
	mvn_run_class="$(echo "${mvn_run_file}" | sed -e "s+src/main/java/++;s+/+.+g;s+.java$++")"
	func_mvn_run_class "${mvn_run_class}" | sed -e "/^\[INFO\] /d;/^\[WARNING\] Warning: killAfter is now deprecated/d"
}

func_mvn_run_class() { 
	local usage="Usage: ${FUNCNAME[0]} [class]" 
	func_param_check 1 "$@"

	[ -z "${1}" ] && func_die "ERROR: not classname to run!"
	[ ! -f pom.xml ] || [ ! -d src/main/java ] && func_die "ERROR: pom.xml or src/main/java NOT exist, seems not a maven project!"

	echo "INFO: run command: mvn clean compile exec:java -Dexec.mainClass=${1}"
	mvn clean compile exec:java -Dexec.mainClass="${1}"
}

func_mvn_gen() { 
	local usage="Usage: ${FUNCNAME[0]} [pkg(war/jar/oujar/ouwar/csmm/cswar)] [name]" 
	func_param_check 2 "$@"

	local cmd=""
	case "${1}" in
	#mvn archetype:generate -DgroupId=com.test -DartifactId=$name -DarchetypeArtifactId=maven-archetype-webapp -DinteractiveMode=false
	jar)	cmd="mvn archetype:generate    -DgroupId=com.test    -DartifactId=${2}                                               -DarchetypeArtifactId=maven-archetype-quickstart                             -DinteractiveMode=false                          ";;
	war)	cmd="mvn archetype:generate    -DgroupId=com.test    -DartifactId=${2} -DarchetypeGroupId=com.tpl.archetype          -DarchetypeArtifactId=tpl-war-archetype      -DarchetypeVersion=1.1-SNAPSHOT -DinteractiveMode=false -DarchetypeCatalog=local ";;
	oujar)	cmd="mvn archetype:generate -o -DgroupId=com.oumisc  -DartifactId=${2} -DarchetypeGroupId=com.oumisc.maven.archetype -DarchetypeArtifactId=archetype-oujar-simple -DarchetypeVersion=1.0-SNAPSHOT -DinteractiveMode=false -DarchetypeCatalog=local ";;
	ouwar)	cmd="mvn archetype:generate -o -DgroupId=com.oumisc  -DartifactId=${2} -DarchetypeGroupId=com.oumisc.maven.archetype -DarchetypeArtifactId=archetype-ouwar-simple -DarchetypeVersion=1.0-SNAPSHOT -DinteractiveMode=false -DarchetypeCatalog=local ";;
	csmm)	cmd="mvn archetype:generate -U -DgroupId=com.yy.${2} -DartifactId=${2} -DarchetypeGroupId=com.yy.maven.archetype     -DarchetypeArtifactId=cs-std-mm-archetype    -DarchetypeVersion=1.0-SNAPSHOT -DinteractiveMode=false -DarchetypeRepository=http://jrepo2.yypm.com/nexus/content/repositories/snapshots/ ";;
	cswar)	cmd="mvn archetype:generate -U -DgroupId=com.yy.${2} -DartifactId=${2} -DarchetypeGroupId=com.yy.maven.archetype     -DarchetypeArtifactId=cs-std-war-archetype   -DarchetypeVersion=1.0-SNAPSHOT -DinteractiveMode=false -DarchetypeRepository=http://jrepo2.yypm.com/nexus/content/repositories/snapshots/ ";;
	*)
		echo "ERROR: pkg type must be war/jar/oujar/ouwar"
		exit 1
	esac

	echo "INFO: run mvn cmd: $cmd"
	$cmd
	mkdir -p "${2}/src/main/java" 
}

func_svn_backup() { 
	[ -n "$1" ] && src_path="$1" || src_path="."

	local src_name=$(basename "$(readlink -f "$src_path")")
	local tmp_path=$MY_TMP/${src_name}_svn_export

	# current dir is already project
	[ -e ./.svn ] && svn export "$src_path" "$tmp_path" && return 0
	
	# projects are in subdir
	mkdir -p "$tmp_path"
	while IFS= read -r -d '' dir ; do 
		[ -n "$dir" ] && [ -e "$dir/.svn" ] && svn export "$dir/"  "$tmp_path/$(basename "$dir")"
	done < <(find "$src_path" -maxdepth 1 -type d -print0)

	# backup
	func_backup_dated "$tmp_path"
	[ -e "$tmp_path" ] && rm -rf "$tmp_path"
}

func_svn_update() { 
	local p="${1:-.}"

	# current dir is already project
	[ -e "${p}/.svn" ] && func_svn_update_single && return 0
	
	# projects are in subdir
	while IFS= read -r -d '' dir ; do 
		# suppress blank line and external file in output: svn update $dir/ | sed "/[Ee]xternal \(item into\|at revision\)/d;/^\s*$/d"
		[ -n "${dir}" ] && [ -e "${dir}/.svn" ] && func_svn_update_single "${dir}" 
	done < <(find "${p}" -maxdepth 1 -type d -print0)
	func_locate_updatedb
}

func_svn_status() { 
	local p="${1:-.}"

	# current dir is already project
	[ -e "${p}/.svn" ] && func_svn_status_single && return 0
	
	# projects are in subdir
	while IFS= read -r -d '' dir ; do 
		[ -n "${dir}" ] && [ -e "${dir}/.svn" ] && func_svn_status_single "${dir}" 
	done < <(find "${p}" -maxdepth 1 -type d -print0 )
}

func_svn_update_single() { 
	svn update "${1:-.}"
}

func_svn_status_single() { 
	svn status "${1:-.}" | sed -e '/^\s*$/d;/\s*X\s\+/d;/Performing status on external item at /d'
}

func_git_pull() { 
	git pull origin master && git status
	func_locate_updatedb
}

func_git_status() { 
	git status 	
}

func_git_commit_push() { 

	[ -n "$*" ] && comment="$*" || comment="update from $(hostname -s)"

	# git add -A: in git 2.0, will add those even not in current dir (which is what we want), just wait the 2.0
	git pull origin master			&&
	git add -A				&&
	git commit -a -m "$comment" 		&&
	git push origin				&&
	git status
	func_git_commit_check | sort
}

func_git_commit_check() { 
	# TODO: check if myenv_lib and zbox_lib is same inode
	for base in "$HOME" "$HOME/.zbox" "$HOME/Documents/FCS/oumisc/oumisc-git" "$HOME/.vim/bundle/vim-oumg" ; do 
		pushd "$base" &> /dev/null || continue
		git status | grep -q "nothing to commit, .* clean"	\
		&& echo "NOT need update: $base"			\
		|| echo "NEED update: $base" 
		popd &> /dev/null || continue
	done
}

func_unison_fs_run() {
	local hn profile_path
	hn="$(hostname -s)"
	profile_path="$HOME/.unison/fs_$(hostname -s)_all.prf"

	if [[ "${hn}" == "lapmac2" ]] ; then
		echo "WARN: should only run on lapmac3"
		return
	fi

	if [[ "${hn}" == "lapmac3" ]] ; then
		func_complain_path_not_exist "${profile_path}" "ERROR: can NOT find profile for hostname: ${profile_path}"
		func_backup_myenv_today
		unison -ui text "${profile_path##*/}"
		return
	fi

	echo "ERROR: can NOT match hostname (${hn}), pls check!"
}

func_unison_cs_run() {
	local hn="$(hostname -s)"
	if [[ "${hn}" == "lapmac2" ]] ; then
		func_unison_cs_run_on_lapmac2
		return
	fi
	if [[ "${hn}" == "lapmac3" ]] ; then
		func_unison_cs_run_on_lapmac3
		return
	fi
	echo "ERROR: can NOT match hostname (${hn}), pls check!"
}

func_unison_cs_run_on_lapmac2() {
	local profile_path="$HOME/.unison/cs_workpcII_lapmac2_all.prf"

	func_complain_path_not_exist "${profile_path}" "ERROR: can NOT find profile for hostname: ${profile_path}"

	echo "Start to run with profile: ${profile_path##*/}"
	# macports version of unison on lapmac2 need "-ui text"
	unison -ui text "${profile_path##*/}"
}

func_unison_cs_run_on_lapmac3() {
	local profile_path="$HOME/.unison/cs_lapmac2to3_run_on_3_all.prf"

	func_complain_path_not_exist "${profile_path}" "ERROR: can NOT find profile for hostname: ${profile_path}"

	echo "Start to run with profile: ${profile_path##*/}"
	unison "${profile_path##*/}"
}

# seems deprecated
func_unison_fs_lapmac_all() {
	local mount_path="/Volumes/Untitled"

	# only works: 1) on osx, 2) in interactive mode
	func_is_os_osx || func_die "ERROR: this function only works on OSX"
	echo $- | grep -q "i" || func_die "ERROR: this function only works in interactive mode"

	# TODO: use 'diskutil list' to correctly find disk
	# try to find disk automatically (use the latest diskXs1, X > 0). NOTE: seems the --ignore "disk0s1" NOT really work
	local disk_path
	local disk_status="$(df -h)"
	local disk_candidates="$("ls" -t /dev/disk*s1 --ignore "disk0s1")"
	for disk_path in ${disk_candidates} ; do
		if echo "${disk_status}" | grep -q "${disk_path}" ; then
			echo "INFO: ${disk_path} already mounted, try next"
			disk_path=""
		else
			echo "INFO: found: ${disk_path} is available"
			break
		fi
	done
	[ -z "${disk_path}" ] && echo "ERROR: can NOT find diskXs1 for mounting" && return 1

	# if path not empty AND not writable, need eject first (TODO: make the eject automatically?)
	func_is_dir_not_empty "${mount_path}" && [ ! -w "${mount_path}" ] && echo "ERROR: disk already mount in RO mode, pls eject first" && return 1

	# if target inexist, try to mount the disk
	if [ ! -e "${mount_path}/backup/DCB" ] ; then
		func_complain_cmd_not_exist unison && return 1
		func_complain_cmd_not_exist ntfs-3g && return 1
		func_complain_path_not_exist "${disk_path}" "ERROR: ${disk_path} inexist, seems disk NOT attached to computer!" && return 1

		echo "INFO: try to mount ${disk_path} to ${mount_path}, need about 5 seconds"
		[ -e "${mount_path}" ] || mkdir "${mount_path}"
		sudo ntfs-3g "${disk_path}" "${mount_path}"
		sleep 3

		if func_is_dir_empty "${mount_path}" || [ ! -w "${mount_path}" ] ; then
			echo "ERROR: seems failed to mount disk, you may need to **RESTART** mac/osx" 
			return 1
		fi
	fi

	unison fs_lapmac_all

	func_ask_yes_or_no "Do you want to umount disk? [y/n]" || return
	sudo umount "${mount_path}"
}

func_ssh_agent_init() {
	local usage="Usage: ${FUNCNAME[0]}" 
	local desc="Desc: start ssh agent, skip if already started" 
	local note="NOTE: this func used in .bashrc, which migth block desktop version login / unison remote style, etc. So NO output, NO error"

	# reuse if already started. NOTE, the SSH_AUTH_SOCK file and the Process must all exist!
	local env_tmp="${HOME}/.ssh/ssh_agent_env_tmp"
	[[ -e "${env_tmp}" ]] && source "${env_tmp}" &> /dev/null 
	[[ -e "${SSH_AUTH_SOCK}" ]] && func_is_pid_running "${SSH_AGENT_PID}" && return 0

	# start a new one
	ssh-agent -s | sed "s/^echo/#echo/" > "${env_tmp}"
	chmod 600 "${env_tmp}" &> /dev/null
	source "${env_tmp}"    &> /dev/null

	# add cert
	local cert="${HOME}/.ssh/ouyangzhu_duowan"
	if [[ -e "${cert}" ]] ; then
		ssh-add "${cert}" &> /dev/null
	fi
}

func_ssh_cmd_via_jump() {
	local ssh_via_jump_opts=""
	func_ssh_via_jump "$@"
}

func_ssh_term_via_jump() {
	local ssh_via_jump_opts="-t"
	func_ssh_via_jump "$@"
}

# shellcheck disable=2155,2029
func_ssh_via_jump() {
	local usage="Usage: ${FUNCNAME[0]} <target>" 
	func_param_check 1 "$@"

	local ip_addr="$(func_ip_of_host "${1}")"
	func_is_str_blank "${ip_addr}" && func_die "ERROR: can NOT get ip address for: ${1}"
	shift

	local ssh_via_jump_opts="${ssh_via_jump_opts:-"-t"}"
	ssh ${ssh_via_jump_opts} "${MY_JUMP_HOST}" "ssh -p ${MY_PROD_PORT} ${ip_addr} $*"
}

func_dist_source_env() {
	[ -d "${MY_ENV_DIST}" ] || return

	local tags="$(func_dist_tags)"
	func_is_str_blank "${tags}" && return

	local tag tag_env
	for tag in ${tags} ; do
		tag_env="${MY_ENV_DIST}/${tag}/script/env.sh" 
		[ -f "${tag_env}" ] && source "${tag_env}"
	done
}

func_dist_tags() {
	[ -d "${MY_ENV_DIST}" ] || return

	# dirs are tags, except "backup"
	"ls" "${MY_ENV_DIST}" --ignore "backup"
}

# shellcheck disable=2155,2086,2029
func_dist_sync() {
	# TODO: in real use, seems too heavy or complex, NOT good enough: 
	#	1) NOT easily to quickly understand what happend. 
	#	2) easy to make mistake, e.g. config file updated in /data/services, but NOT updated to ~/.myenv/dist/<tag>, which actually syncs the old files
	#	3) may lost some info, since used mv/cp, "diffstat" could help on this, but can NOT solve this
	#	4) (solved) in local host, when current dir is "config/script" dir, will easily confused since the path changed (to backup), but prompt still NOT
	#
	#	Candidates Solution
	#	A) use git on jump machine and sync via it
	#	B) use git bundle (single file): https://stackoverflow.com/questions/4860166/how-to-synchronize-two-git-repositories
	#
	# TODO: how to support internal machine as target? seem jump could connect to internal machine, but need sync pub key before connect

	local usage="Usage: ${FUNCNAME[0]} <tag> <source> <target_prefix> "
	read -r -d '' desc <<-'EOF'
		Functionality:
		    1. help to synchronise config/script across production machines via jump.
		    2. mean while help to backup in local machine

		Concept:
		    <tag>		the myenv tag system, help to easily locate the topic and config/script path
		    <source>		default is local, the host where is the latest config/script
		    <target_prefix>	default is <tag>, to identify those hosts to distribute (dist_hosts), 
		    dist_hosts		hosts starts with <target_prefix> in /etc/hosts

		Steps: 
		    1) if <source> provided, download <tag> from <source> then run step 2, otherwise directly run step 2
		    2) distribute <tag> to all dist_hosts, except <source> itself (if provided)

		Examples:
		    ${FUNCNAME[0]} hp-proxy					# distribute $MY_DCD/hp-proxy/{config,script} to ~dist_hosts start with 'hp-proxy'
		    ${FUNCNAME[0]} hp-proxy hp-proxy.web.76			# latest version is on "hp-proxy.web.76", distribute to other dist_hosts, and backup to local
		    ${FUNCNAME[0]} hp-proxy hp-proxy.web.76 localhost		# latest version is on "hp-proxy.web.76", just backup to localhost
		    ${FUNCNAME[0]} hp-proxy hp-proxy.web.76 hp-proxy.web	# as above, but dist_hosts might smaller, since <target_prefix> is more strict
		    ${FUNCNAME[0]} hp-proxy localhost hp-proxy.web		# when <source> is local, but need specify <target_prefix>, use 'localhost/127.0.0.1' as <source>
		EOF
	func_param_check 1 "$@"

	# Parameters
	local tag="${1}"
	local target_prefix="${3:-${tag}}"
	local source_ip="$(func_ip_of_host "${2:-__NOT_EXIST#HOST__}")"

	# Variable
	local dati="$(func_dati)"
	local jump_tmpdir="${MY_JUMP_TRANSFER}/${dati}"
	local tag_path_local="$(func_tag_value_raw "${tag}")"

	# Check
	[ -f "${tag_path_local}" ] && tag_path_local="${tag_path_local%/*}"
	[ -d "${tag_path_local}" ] || func_die "ERROR: local path (${tag_path_local}) for tag (${tag}) NOT exist!"
	[ -n "${2}" ] && [ -z "${source_ip}" ] && func_die "ERROR: failed to translate <source> (${2}) to ip address, abort!"

	# To Jump 
	if [ -z "${source_ip}" ] || [ "${source_ip}" = "127.0.0.1" ]; then
		# local to jump. NOTE: backup is NOT in sync list
		local upload_paths=()
		[ -d "${tag_path_local}/config" ] && upload_paths+=("${tag_path_local}/config") || echo "INFO: ${tag_path_local}/config NOT exist, skip"
		[ -d "${tag_path_local}/script" ] && upload_paths+=("${tag_path_local}/script") || echo "INFO: ${tag_path_local}/script NOT exist, skip"
		[ ${#upload_paths[@]} -eq 0 ] && func_die "ERROR: upload_paths for '${tag}' is empty, means nothing to distribute, abort!"

		echo "INFO: '${tag}' from localhost (${upload_paths[*]}) to jump machine (${jump_tmpdir})"
		func_scp_local_to_jump "${jump_tmpdir}" "${upload_paths[@]}" 
	else
		# remote to jump. NOTE: backup is also send to jump machine
		local tag_path="${MY_DIST_BASE}/${tag}"
		local source_full_addr="${source_ip}:${tag_path}"
		func_is_valid_ip "${source_ip}" || func_die "ERROR: source ip (${source_ip}) NOT valid, abort!"

		echo "INFO: '${tag}' from remote (${source_full_addr}) to jump machine (${jump_tmpdir})"
		func_scp_prod_to_jump "${source_full_addr}/*" "${jump_tmpdir}"

		# make a copy, in case overwrite next time, dist>tag>backup to dist>backup
		func_ssh_cmd_via_jump "${source_ip}" "cp -R ${tag_path} ${MY_DIST_BASE}/backup/${tag}_${dati}"

		# WHY: if prefixed with "mkdir -p xxx;" the "*" in mv cmd WILL NOT expand!
		#local tag_path_synced="${MY_DIST_BASE}/${tag}_synced"
		#func_ssh_cmd_via_jump "${source_ip}" "mv ${tag_path}/backup/* ${tag_path_synced} "					# works
		#func_ssh_cmd_via_jump "${source_ip}" "mkdir -p ${tag_path_synced} ; mv ${tag_path}/backup/* ${tag_path_synced}"	# not work: mv: cannot stat `/home/ouyangzhu/.myenv/dist/hp-proxy/backup/*': No such file or directory
	fi

	# Verify Jump
	local jump_tmpdir_contents="$(ssh "${MY_JUMP_HOST}" "ls ${jump_tmpdir}")"
	echo "INFO: verify jump tmpdir, gets content: "${jump_tmpdir_contents}
	[ -z "${jump_tmpdir_contents}" ] && func_die "ERROR: no content on jump tmpdir, abort!"

	# Translate target into ip list
	# TODO: currently only support use prefix as target
	#	1： support host in ip address format, which not need translate from /etc/hosts
	#	2： support target hosts mixed with host and ip
	local dist_hosts=""
	if [ "${target_prefix}" = "localhost" ] || [ "${target_prefix}" = "127.0.0.1" ]; then
		# to avoid grep /etc/hosts, since mights multiple result (e.g. IPv6 addr) or nothing, both are NOT wanted
		dist_hosts="127.0.0.1"
	else
		dist_hosts="$(grep "^[^#]*[[:blank:]]${target_prefix}" /etc/hosts | sed -e "/${source_ip:-__DIST-INEXIST#STR__}/d;s/\s.*//;" | sort -u)"
	fi

	# Distribute
	echo "INFO: distribute to hosts: "${dist_hosts}
	if func_is_str_blank "${dist_hosts}" ; then
		echo "WARN: NO dist_hosts could be found, NO distribution"
	else
		# NOTE 1: distribute.sh on jump machine, will skip addr "127.0.0.1"
		# NOTE 2: backup is NOT in the distribution list
		func_jump_distribute "${dati}" "${tag}" ${dist_hosts}	# NO quote on ${dist_hosts}, otherwise will cross multiple line
	fi

	# Backup to local
	local is_backup_to_local local_backup_path local_updated_path
	[ -n "${source_ip}" ] && ! func_is_local_addr "${source_ip}" && is_backup_to_local="true" || is_backup_to_local="false"
	if [ "${is_backup_to_local}" = "true" ] ; then
		local_backup_path="${tag_path_local}/backup/${dati}"
		echo "INFO: also backup to local: (${local_backup_path})"
		mkdir -p "${local_backup_path}"

		for content in ${jump_tmpdir_contents} ; do
			# there is only one backup in local machine, so, no move 
			[ "${content}" = "backup" ] && continue 

			local_updated_path="${local_updated_path} ${tag_path_local}/${content}"
			mv "${tag_path_local}/${content}" "${local_backup_path}"
		done
		scp -r -P "${MY_PROD_PORT}" "ouyangzhu@${MY_JUMP_HOST}:${jump_tmpdir}/*" "${tag_path_local}/"
	fi

	# Update current dir if need, since there is a "mv" action above
	local cdir="$(pwd)"
	if [[ "${local_updated_path}" =  *${cdir}* ]] ; then
		echo "INFO: 'refresh' current dir to the real/latest dir."
		"cd" "${cdir}" || echo "WARN: failed to cd to: ${cdir}"
	fi

	# cleanup jump machine
	func_jump_cleanup

	# show difference when backup to local
	if [ "${is_backup_to_local}" = "true" ] ; then
		for content in ${jump_tmpdir_contents} ; do
			[ "${content}" = "backup" ] && continue 
			echo "INFO: difference of: ${content}"
			diff "${tag_path_local}/${content}" "${local_backup_path}/${content}" | diffstat
		done
	fi
}

func_scp_host_to_ip() {
	local usage="Usage: ${FUNCNAME[0]} [addr]" 
	func_param_check 1 "$@"

	func_str_not_contains "${1}" ":" && echo "${1}" && return 0

	echo "$(func_ip_of_host "${1%:*}"):${1#*:}"
}

# shellcheck disable=2029
func_scp_jump_to_prod() {
	local usage="Usage: ${FUNCNAME[0]} <dir> <target1> <target2>"
	local desc="Desc: scp <dir> in jump machine, to multiple <target> dirs" 
	func_param_check 2 "$@"

	local jump_tmpdir="${1}"
	shift

	local target
	for target in "${@}" ; do
		ssh "${MY_JUMP_HOST}" "scp -r -P ${MY_PROD_PORT} ${jump_tmpdir}/* ${target}"
	done
}

# shellcheck disable=2029
func_scp_prod_to_jump() {
	local usage="Usage: ${FUNCNAME[0]} <prod_source> <jump_dir>"
	local desc="Desc: scp stuffs from production machine to jump machine" 
	func_param_check 2 "$@"

	# NOTE: only support one <prod_source>, in case too complicated. Enhance if really need
	local prod_source="${1}"
	local jump_tmpdir="${2}"
	#ssh "-t" "${MY_JUMP_HOST}" "mkdir -p ${jump_tmpdir}"
	#ssh "-t" "${MY_JUMP_HOST}" "scp -r -P ${MY_PROD_PORT} ${prod_source} ${jump_tmpdir}"
	ssh "${MY_JUMP_HOST}" "mkdir -p ${jump_tmpdir}; scp -r -P ${MY_PROD_PORT} ${prod_source} ${jump_tmpdir}"
}

# shellcheck disable=2029
func_scp_local_to_jump() {
	local usage="Usage: ${FUNCNAME[0]} <jump_dir> <path1> <path2> ..."
	local desc="Desc: scp stuffs from local machine to jump machine" 
	func_param_check 2 "$@"

	local jump_tmpdir="${1}"
	shift

	func_complain_path_not_exist "${@}"
	ssh "${MY_JUMP_HOST}" "mkdir -p ${jump_tmpdir}"
	scp -r -P "${MY_PROD_PORT}" "${@}" "ouyangzhu@${MY_JUMP_HOST}:${jump_tmpdir}/"
}

# shellcheck disable=2029
func_jump_distribute() {
	# NOTE: distribute.sh on jump machine, will skip addr "127.0.0.1"
	# NOTE: backup @ $MY_DCD/ops/jump/backup/, and also $MY_DCB/dbackup
	ssh "${MY_JUMP_HOST}" "bash ${MY_JUMP_TRANSFER}/distribute.sh $*"
}

# shellcheck disable=2029
func_jump_cleanup() {
	# cleanup, in case too much garbage
	# NOTE: backup @ $MY_DCD/ops/jump/backup/, and also $MY_DCB/dbackup
	ssh "${MY_JUMP_HOST}" "bash ${MY_JUMP_TRANSFER}/cleanup.sh"
}

# shellcheck disable=2155,2029
func_scp_via_jump() {
	local usage="Usage: ${FUNCNAME[0]} <source> <target> <jump_tmpdir>"
	local desc="Desc: scp via jump machine, from <source> to <target> dir, use <jump_tmpdir> if provided" 
	func_param_check 2 "$@"

	# TODO: support wildcard to transfer multiple file? like: scpx rysnc_tmp.* 58.215.52.71:~/secu

	local jump_tmpdir="${3:-${MY_JUMP_TRANSFER}/$(func_dati)}"

	local source=$(func_scp_host_to_ip "${1}")
	local sourceName=$(basename "${source}")
	local target=$(func_scp_host_to_ip "${2}")
	local targetName="${target##*:}"
	local targetAddr=${target%%:*}

	# Perform transfer
	if func_str_contains "${source}" ":" ; then
		[ -d "${target}" ] || func_die "ERROR: target MUST be a directory!"
		[ -e "${target}/${sourceName}" ] && func_die "ERROR: ${target}/${sourceName} already exist, NOT support override!"

		echo "INFO: start to download ..."
		func_scp_prod_to_jump "${source}" "${jump_tmpdir}"
		scp -r -P "${MY_PROD_PORT}" "ouyangzhu@${MY_JUMP_HOST}:${jump_tmpdir}/*" "${target}"
	else

		local target_exist="$(func_ssh_cmd_via_jump "${targetAddr}" "[ -d ${targetName}/${sourceName} ] 2>/dev/null && echo true || echo false")"
		#local target_exist="$(ssh "${MY_JUMP_HOST}" "ssh -p ${MY_PROD_PORT} ${targetAddr} '[ -d ${targetName}/${sourceName} ] 2>/dev/null && echo true || echo false'" 2>/dev/null)"
		[ "${target_exist}" = "true" ] && func_die "ERROR: ${targetName}/${sourceName} on target meachine (${targetAddr}) already exist!"
		
		echo "INFO: start to upload ..."
		func_scp_local_to_jump "${jump_tmpdir}" "${source}" 
		func_scp_jump_to_prod "${jump_tmpdir}" "${target}"
	fi

	# Cleanup
	func_jump_cleanup

	# Note: seems using ProxyCommand is a better way (not totally work yet), see ~/.ssh/config for more detail

	# Demo: 
	#func_scp_with_jump ~/amp/test ouyangzhu@222.134.66.106:~/test
	#func_scp_with_jump ~/amp/test/t1 ouyangzhu@222.134.66.106:~/test1
	#func_scp_with_jump ~/amp/test ouyangzhu@222.134.66.106:~/test2/test
	#func_scp_with_jump ouyangzhu@222.134.66.106:~/test/t1 ~/amp/2012-11-01/test1
	#func_scp_with_jump ouyangzhu@222.134.66.106:~/test ~/amp/2012-11-01/test
}

# awsvm@aws
func_mebackup_awsvm() {
	local usage="Usage: ${FUNCNAME[0]} run mebackup on awsvm and copy back" 

	echo "ERROR: TODO: not work yet, pls fix it (the func_backup_myenv.alone.sh path has changed)"
	return 1

	local fpath bakpath
	bakpath="$HOME/Documents/DCB/dbackup/latest/"

	if ! \cd "${bakpath}"; then
		echo "INFO: cd to dir ($bakpath) FAILED, pls check"
		return 1
	fi

	fpath="$(ssh awsvm 'bash "$HOME/.myenv/secu/awsvm/script/z/func_backup_myenv.alone.sh"' | grep _awsvm_myenv_backup.zip | cut -d" " -f10)"
	echo "INFO: remote backup generated, remote path: $fpath"

	func_scp_from_cloud_vm awsvm "$fpath"
	ls -l | tail -1
	\cd - &> /dev/null || echo "ERROR: failed to cd back to original dir" 
}

# azvm@microsoft / awsvm@aws
func_scp_from_cloud_vm() {
	local usage="Usage: ${FUNCNAME[0]} <vm_name> <file> \n scp file from <vm_name> to current dir." 
	func_param_check 1 "$@"

	scp "${1}:${2}" ./
	#scp -i "${HOME}/.ssh/ouyzhu_awsvm_hk.pem" "ubuntu@ec2-16-162-34-17.ap-east-1.compute.amazonaws.com:${1}" ./
}

# azvm@microsoft / awsvm@aws
func_scp_to_cloud_vm() {
	local usage="Usage: ${FUNCNAME[0]} <vm_name> <file> \n scp file to <vm_name>:~/Downloads/" 
	func_param_check 1 "$@"

	scp "${2}" "${1}:~/amp/download/"
	#scp -i "${HOME}/.ssh/ouyzhu_awsvm_hk.pem" "${1}" ubuntu@ec2-16-162-34-17.ap-east-1.compute.amazonaws.com:~/Downloads/
}

# shellcheck disable=2029
func_terminator() { 
	if [ "${MY_OS_NAME}" = "${OS_CYGWIN}" ] ; then
		# non-cygwin env: original program
		terminator --title SINGLE_TERMINATOR "$@"
	else
		startxwin &> /dev/null	# just ensure X server started
		local raw_data=$(ipconfig)
		local local_ip=$(echo "$raw_data" | sed -n -e "/IPv[4] Address/s/^[^:]*: //p" | head -1)
		# both --maximise/--fullscreen are not really work
		ssh workvm "DISPLAY=${local_ip}:0.0 terminator --geometry=1910x1010+0+0 --title Gnome-Terminator&> /dev/null &" &> /dev/null
	fi
}

func_sys_net() {
	usage="Usage: ${FUNCNAME[0]} [interface] [interval], interfaces: "$(ifconfig | sed '/^\s\+/d;/^\s*$/d;s/\s\+.*//;/lo/d;') 
	func_param_check 1 "$@"

	interface=$1
	sleep_time=${2-2}
	rx_before=$(ifconfig "$interface" | sed -n -e "s/^.*RX bytes:\([0-9]*\).*/\1/p")
	tx_before=$(ifconfig "$interface" | sed -n -e "s/^.*TX bytes:\([0-9]*\).*/\1/p")
	while : ; do
		sleep "$sleep_time"
		rx_after=$(ifconfig "$interface" | sed -n -e "s/^.*RX bytes:\([0-9]*\).*/\1/p")
		tx_after=$(ifconfig "$interface" | sed -n -e "s/^.*TX bytes:\([0-9]*\).*/\1/p")
		rx_result=$(( (rx_after-rx_before)*8/sleep_time ))
		tx_result=$(( (tx_after-tx_before)*8/sleep_time ))
		echo -e "$(date "+%Y-%m-%d %H:%M:%S") IN: ${rx_result}/$(( rx_result/1000 )) bps/kbps,\tOUT: ${tx_result}/$(( tx_result/1000 )) bps/kbps"

		rx_before=$rx_after
		tx_before=$tx_after
	done
}

func_translate() { 
	# check history
	history_txt=$(grep "^$*[[:blank:]]" -i -A 1 --no-filename "${MY_DCO}"/english/translate/translate_history_*)
	[ -n "$history_txt" ] && echo "$history_txt" && return 0

	func_translate_google "$@" || func_translate_microsoft "$@" || func_translate_youdao "$@"
}

func_translate_IPA_google() { 
	echo "WARN: not implemented yet"
	# IPA: International Phonetic Alphabet (IPA), tells pronunciation of words
	# TODO: google api, IPA extraction: http://www.google.com/dictionary/json?callback=dict_api.callbacks.id100&q=example&sl=en&tl=en
}

func_translate_youdao() { 
	echo "WARN: not implemented yet"
	# address	http://fanyi.youdao.com/openapi.do?keyfrom=wufeifei&key=716426270&type=data&doctype=json&version=1.1&q=
	# example 1	http://fanyi.youdao.com/openapi.do?keyfrom=wufeifei&key=716426270&type=data&doctype=json&version=1.1&q=test
	# example 2	http://fanyi.youdao.com/openapi.do?keyfrom=wufeifei&key=716426270&type=data&doctype=json&version=1.1&q=测试
}

func_translate_google() { 
	local usage="Usage: ${FUNCNAME[0]} [words]" 
	func_param_check 1 "$@" 

	# might useful fields: ie=UTF-8&oe=UTF-8
	if [ "$( echo "$*" | grep -c "[a-z]")" -ge 1 ] ; 
	then	data="hl=en&tsel=0&ssel=0&client=t&sc=1&multires=1&otf=2&text=$*&tl=zh-CN&sl=en"	# en > cn
	else	data="hl=en&tsel=0&ssel=0&client=t&sc=1&multires=1&otf=2&text=$*&tl=en&sl=zh-CN"	# cn > en	# why become cn > cn !!??
	fi

	res_raw="$(curl -e "http://translate.google.cn/?"								\
		-H 'User-Agent':'Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:11.0) Gecko/20100101 Firefox/11.0'	\
		-H 'Accept':'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'			\
		-s "http://translate.google.cn/translate_a/t"							\
		-d "$data")"
	[ -z "$res_raw" ] && return 1

	res_simple=$(echo "$res_raw" | awk -F"," '{printf "%s\n", $1}' | awk -F"\"" '{print $2}')
	echo "$res_simple"
	echo "$res_raw"
	echo -e "$*\t$res_simple\n\t$res_raw" >> "${MY_DCO}/english/translate/translate_history_$(hostname -s)"
}

func_translate_microsoft() { 
	local usage="Usage: ${FUNCNAME[0]} [words]" 
	func_param_check 1 "$@" 

	access_token_tmp=/tmp/ms_translation_api_access_token
	#access_token_compare=/tmp/ms_translation_api_access_token_compare

	access_token_uri="https://datamarket.accesscontrol.windows.net/v2/OAuth2-13"
	# parameters below are applied from https://datamarket.azure.com
	post_content="grant_type=client_credentials&client_id=ouyzhu&client_secret=0yAn46ClllxZk4CuY2tGkjo9Sl&scope=http://api.microsofttranslator.com"
	#translate_uri_cn2en="http://api.microsofttranslator.com/v2/Http.svc/Translate?from=zh-CHS&to=en&text="
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
	if [ "$( echo "$*" | grep -c "[a-z]")" -ge 1 ] ; 
	then res_raw=$(curl -s -H "ContentType: text/plain" -H "Authorization: Bearer $access_token" "${translate_uri_en2cn}$*")
	else res_raw=$(curl -s -H "ContentType: text/plain" -H "Authorization: Bearer $access_token" "${translate_uri_en2cn}$*")
	fi
	[ -z "$res_raw" ] && return 1

	echo "$res_raw"
	echo -e "$*\n\t$res_raw" >> "${MY_DCO}/english/translate/translate_history_$(hostname -s)"
}

func_delete_dated() { 
	local usage="Usage: ${FUNCNAME[0]} <path> <path> ..." 
	func_param_check 1 "$@" 

	local targetDir=$MY_TMP/delete/$(func_date)
	[ -e "${targetDir}" ] || mkdir -p "${targetDir}"

	local t_name=""
	for t in "$@" ; do
		[ ! -e "${t}" ] && echo "WARN: ${t} inexist, will NOT perform dated delete" && continue

		t_name=$(basename "${t}")
		if [[ ${t_name} == .* ]] ; then 
			# make the dot start file visualable
			mv "${t}" "${targetDir}/dot_${t_name}_$(func_time)"
		else
			mv "${t}" "${targetDir}/${t_name}_$(func_time)"
		fi
	done
}

func_backup_myenv_cmd_out() { 
	func_param_check 1 "$@"
	local vim_dir cmd_out_dir dircolors d
	cmd_out_dir="${1}"
	vim_dir="${HOME}/.vim/bundle"
	dircolors="${MY_ENV}/conf/colors/dircolors-solarized"

	echo "INFO: backup output of cmds (df, links, git remote, etc) "
	mkdir -p "${cmd_out_dir}"

	# disk & links
	df -h					> "${cmd_out_dir}/cmd_output_df_h.txt"
	find ~ -maxdepth 1 -type l -ls		> "${cmd_out_dir}/cmd_output_links_in_home.txt"
	find / -maxdepth 1 -type l -ls		> "${cmd_out_dir}/cmd_output_links_in_root.txt"
	find ~/.zbox/ -maxdepth 1 -type l -ls	> "${cmd_out_dir}/cmd_output_links_in_zbox.txt"

	# git remote
	pushd . &> /dev/null
	for d in "${HOME}" "${ZBOX}" "${OUREPO}" "${dircolors}" "${vim_dir}"/* ; do
		[ ! -d "${d}" ] && continue
		echo -e "\n${d}"			>> "${cmd_out_dir}/cmd_output_git_remote.txt"
		if \cd "${d}" ; then
			git remote -v			>> "${cmd_out_dir}/cmd_output_git_remote.txt"
		else
			echo "INFO: ${d} inexist, skip"	>> "${cmd_out_dir}/cmd_output_git_remote.txt"
		fi
	done
	popd &> /dev/null || return
}

func_backup_myenv_today() { 
	local desc="Desc: backup myenv if not, skip if already done today" 
	
	local last_bak_dati curr_bak_dati
	curr_bak_date="$(func_date)"
	last_bak_date="$(find "${DBACKUP_BASE_DCB}" -name "*$(hostname -s)_myenv_backup.zip" -printf "%f\n" | tail -1 | cut -b1-10)"

	if [[ "${curr_bak_date}" == "${last_bak_date}" ]] ; then 
		echo "INFO: myenv already backup today, skip"
		return
	fi

	func_backup_myenv
}

func_backup_myenv() { 
	local tmp_dir ex_fl ex_fl_tmp bak_fl myenv_fl tmp_str

	tmp_dir="$(mktemp -d)"
	cmd_out="${tmp_dir}/cmd_out"
	ex_fl="${tmp_dir}/myenv_exclude"
	bak_fl="${tmp_dir}/myenv_backup"
	myenv_fl=${MY_ENV_ZGEN}/collection/myenv_filelist.txt

	# collect myenv files
	func_collect_myenv "no_content"
	func_validate_path_exist "${myenv_fl}"
	func_backup_myenv_cmd_out "${cmd_out}"

	# prepare filelist
	for tmp_str in "${cmd_out}" "${ex_fl}" "${bak_fl}" ; do
		# not using cmd "basename", in case not in tmp_dir
		echo "${tmp_str#"${tmp_dir}/"}" >> "${bak_fl}"
	done
	cat "${myenv_fl}" >>  "${bak_fl}"

	# prepare exclude filelist
	ex_fl_tmp="$(func_backup_dated_gen_exclude_list "${MY_ENV}" "*/.unison/[fa][pr][0-9a-z]*")"
	mv "${ex_fl_tmp}" "${ex_fl}"

	! \cd "${tmp_dir}" && echo "ERROR: failed to cd to ${tmp_dir}, give up!" && return
	func_backup_dated_on_fl_PRIVATE "${bak_fl}" "${ex_fl}"
	\cd - &> /dev/null || echo "ERROR: failed to cd back to original dir" 
}

func_backup_dated_gen_exclude_list() {
	local usage="Usage: ${FUNCNAME[0]} <source> [more_patterns ...]" 
	local desc="Desc: Generate exclude list for func_backup_dated()" 
	func_param_check 1 "$@"

	local base ex_fl ex_file tmp_pattern
	ex_fl="$(mktemp)"

	# TODO: 有些情况未确认是否生效
	#	1) 输入($1)如果是全路径的情况。不过这个方式，脚本中目前只有 func_backup_myenv 用。当然，命令指定全路径也是会这样用的。
	#	2) $base有最后的/，如果路径已经有/ (不应该这样写)，'//'在路径中，是否仍旧有效? 

	# example	~/.myenv/.db.exclude	
	#		~/.vim/.db.exclude
	# pattern	func_backup_myenv 

	find "${1}" -type f -name "${DBACKUP_EX_FILENAME}" -print0 | while IFS= read -r -d $'\0' ex_file; do
		# for each exclude list: 1) add path prefix. 2) gather together
		base="${ex_file%"${DBACKUP_EX_FILENAME}"}"

		# 如果是*开头的，就不加base前缀，因为要匹配各级路径
		func_del_blank_and_hash_lines "${ex_file}" | sed -e "s+^\([^\*]\)+${base}\1+" >> "${ex_fl}"
	done

	# check if more pattern provided (which not need $base prefix)
	shift
	if [ $# -ge 1 ] ; then
		for tmp_pattern in "$@" ; do
			echo "${tmp_pattern}" >> "${ex_fl}" 
		done
	fi

	# always exclude
	grep -q ".DS_Store" "${ex_fl}" || echo "*/.DS_Store" >> "${ex_fl}" 

	echo "${ex_fl}"
}

func_backup_dated_sel_target_base() {
	local usage="Usage: ${FUNCNAME[0]}\n\tGenerate target base to store the backup file" 

	# dcb for personal computer
	local tags
	if [ -d "${DBACKUP_BASE_DCB}" ]; then
		echo "${DBACKUP_BASE_DCB}"
		return
	# if dirs(tags) in dist, ask for selection
	elif [ -d "${MY_ENV_DIST}" ] ; then
		tags="$(func_dist_tags)"
		if [ -n "${tags}" ] ; then
			# TODO: no need selection if only 1 tag?
			echo "${MY_ENV_DIST}/$(func_select_line "${tags}")/backup"
			return
		fi
	fi

	# otherwise always this path
	dbdir="${MY_TMP}/dbackup/"
	mkdir -p "${dbdir}" &> /dev/null
	echo "${dbdir}"
}

func_backup_dated() {
	# TODO: see BUG-1

	local usage="Usage: ${FUNCNAME[0]} <source>"
	local desc="Desc: Currently only support backup up single target (file/dir)." 
	func_param_check 1 "$@"

	local src_path src_basename tmp_base src_fl ex_fl src_dirname
	if [[ "${1}" == "./" ]] || [[ "${1}" == "." ]] ; then				# in case <source> is ".", we need its name
		src_path="$(readlink -f "${1}")"
	else
		src_path="${1}"
	fi
	src_basename="$(basename "${src_path%.zip}")"					# .zip will be added later (just a simple de-dup here)
	tmp_base="$(mktemp -d)" 
	src_fl="${tmp_base}/${src_basename}"

	# backup
	if [ -d "${src_path}" ] ; then
		# cd to base, makes path simpler in zip file. NOTE: will fail if NOT cd, not sure why (zip with filelist always use relative path?)
		src_dirname="$(dirname "${src_path}")"
		! \cd "${src_dirname}" && echo "ERROR: failed to cd ${src_dirname}" && return

		#find "${src_basename}" > "${src_fl}"					# WORKS. Also list empty dir and .* files
		find "${src_basename}" -print0 > "${src_fl}"				# WORKS. Also list empty dir and .* files
		ex_fl="$(func_backup_dated_gen_exclude_list "${src_basename}")"
		func_backup_dated_on_fl_PRIVATE  "${src_fl}" "${ex_fl}" "${src_basename}" 

		\cd - &> /dev/null || echo "ERROR: failed to cd back to original dir" 
	else
		# for single file, not need path in zip, and not need exlude filelist
		echo "${src_path}" > "${src_fl}"
		func_backup_dated_on_fl_PRIVATE  "${src_fl}"
	fi
}

func_backup_dated_on_fl_PRIVATE () {

	# 总体感觉搞复杂了，为了让mebackup和dbackup共用，不得不使用zip filelist方式。
	# 如果即mebackup用filelist方式(这样不用考虑FL在mac上超9000的问题)。dbackup用简单的zip -r，整体代码会简单些。

	local usage="Usage: ${FUNCNAME[0]} <file_list> <exclude_list>"
	local desc="Desc: backup files in list and exclude those listed" 
	func_param_check 1 "$@"

	# TODO: currently 1-round zip, `unzip -l` still works!

	# check and prepare
	func_validate_path_exist "${1}" 
	local tgt_path tgt_base src_fl src_name passwd_str cmd_opts 
	src_fl="${1}"
	src_name="$(basename "${src_fl%.zip}")"					# .zip will be added later (de-dup here)
	tgt_base="$(func_backup_dated_sel_target_base)"
	tgt_path="${tgt_base}/$(func_dati)_$(func_best_hostname)_${src_name}.zip"
	mkdir -p "${tgt_base}"

	# prepare password option if available
	cmd_opts="-r"
	if func_is_cmd_exist func_gen_zip_passwd ; then
		passwd_str="$(func_gen_zip_passwd "${tgt_path}")"
		if [ -n "${passwd_str}" ] ; then 
			# NO ' inside "". WRONG: "--password '${passwd_str}'"
			cmd_opts="${cmd_opts} --password ${passwd_str}"
		else
			echo "WARN: failed to gen password"
		fi
	fi

	# prepare exclude option if available
	local zip_cmd_log src_basename
	if [[ -n "${2}" ]] && [[ -s "${2}" ]] ; then
		# NO ' inside "". WRONG: x@'${ex_fl}'"				
		cmd_opts="${cmd_opts} -x@${2}" 
	fi
	zip_cmd_log="$(mktemp)"
	src_basename="${3}"

	# TRICK: output to stdout and capture zip_file path in ouput (into var)
	# { zip_file="$( func_backup_dated "${src_path}" | tee /dev/fd/3 | sed -n -e "/${DBACKUP_RESULT_STR}/s+^[^/]*/+/+p" )" } 3>&1
	func_backup_dated_zip_cmd "${cmd_opts}" "${src_fl}" "${tgt_path}" "${zip_cmd_log}" "${src_basename}"

	echo "INFO: log: ${zip_cmd_log}"
	echo "INFO: ${DBACKUP_RESULT_STR} $(find "${tgt_path}" -printf '%s\t%p\n' | numfmt --field=1 --to=si)"
}

func_backup_dated_zip_cmd() {
	# 用文件列表方式: 因为有些文件需要排除，用整体copy一份的方式效率会很低。
	# 把exclude fl直接从include fl里去掉，则命令中不需要exclude fl，但注意exclude fl是支持pattern的

	local src_fl_size 
	src_fl_size="$(func_file_size "${2}")"

	# mac上，文件列表的size超过9000，会报错，生成大小为0的zip文件。这种情况只能用v2 (它主要是不支持文件名中有\n)
	if (( src_fl_size < 9000 )) ; then
		func_backup_dated_zip_cmd_v1 "${1}" "${2}" "${3}" "${4}"
	else
		func_backup_dated_zip_cmd_v2 "${1}" "${2}" "${3}" "${4}" "${5}"
	fi
}

# 从STDIN输入文件列表。但mac上，文件列表的size超过9000，会报错，生成大小为0的zip文件。
func_backup_dated_zip_cmd_v1() {

	# "-@" Way	文件列表中的文件名是 '\0' 分隔
	#   -- Note 1	它的好处是兼容文件名里有回车符等(特殊字符的)情况。但它的问题是(至少mac上)，Filetest不能长(见 ~BUG-1 )
	#   -- Note 2	src_fl里如果用的是绝对路径，会失败，相对路径则没问题 (why?)。验证版本: (mac) Zip 3.0 (July 5th 2008), by Info-ZIP。
	#		--- TODO: 是不是检查一下路径，如果是绝对路径就告警一下?
	#   -- Ref 1	https://serverfault.com/questions/652892/create-zip-based-on-contents-of-a-file-list
	#		--- last answer said "-@ - <" will works on all plf, while `man zip` said simply -@ will NOT work on mac
	#   -- Ref 2	https://superuser.com/questions/575326/osx-selectively-zip-large-number-of-files-option-ok
	#		--- 因为zip是linux平台的，但linux和osx换行符不同 ( ~default@info )，若文件名中有这些特殊字符时，"-@" 会有问题。
	#		--- 这里使用了'\0'作为分隔符，所以没有这个问题
	#   -- BUG-1	要备份的目录下，有时会报错，备份的zip大小为0。一开始以为是: 如果有size为0的文件，就有问题，但后来发现不是的。
	#		--- (在lapmac2上) 生成的Filelist太大导致的问题。Filelist文件: size为9001时有问题，为9000时没问题。
	#		--- TODO 0	没有修复前，检查大小，直接报错
	#		--- TODO 1	用hard link方式是不是可以?
	#		--- TODO 2	APFS好像copy效率是十分高的，实际也可以用?

	# zip ${cmd_opts} -@ - < "${src_fl}" > "${tgt_path}" 2> "${zip_cmd_log}"
	# 命令中的 "-": (man zip) 当用它作为输出的文件名时，生成的zip文件内容会写到stdout，方便重定向压缩后的内容
	echo "INFO: func_backup_dated_zip_cmd_v1: zip ${1} -r -@ - <  ${2} > ${3} 2> ${4}" | tee -a "${4}"
	# shellcheck disable=2086 # cmd_opts must NOT embrace with "", since have spaces which need expansion
	zip ${1} -@ - < "${2}" > "${3}" 2>> "${4}"
}

# 用-i@方式，对文件列表长度没有限制，但这种情况不支持文件名中有\n的情况
func_backup_dated_zip_cmd_v2() {

	# check if file contains \n (0a) or \r (0d), which will cause some file failed to compress
	if hexdump "${2}" | grep -q ' \(0a\|0d\)' ; then
		echo "ERROR: filename contains <newline/carriage> (0x0a/0x0d), can NOT use func_backup_dated_zip_cmd_v2, pls check!"
		echo "ERROR: check cmd: hexdump ${2} | grep ' \(0a\|0d\)'"
		return 1
	fi

	# "-i@" Way: 文件不能用 '\0' 分隔
	local tmp_fl
	tmp_fl="$(mktemp)"
	< "${2}" tr '\0' '\n' > "${tmp_fl}"

	# 和func_backup_dated_zip_cmd_v1不同，v2这里要指定base。对于无法指定base的情况(如myenv的bak)，不能用它
	func_is_str_blank "${5}" && echo "ERROR: var src_basename MUST NOT empty for func_backup_dated_zip_cmd_v2" && return 1
	func_complain_path_inexist "${5}" && return 1

	echo "INFO: func_backup_dated_zip_cmd_v2: zip ${1} -r -i@${tmp_fl} ${3} ${5} &> ${4}" | tee -a "${4}"
	# shellcheck disable=2086 # cmd_opts must NOT embrace with "", since have spaces which need expansion
	zip ${1} -i@"${tmp_fl}" "${3}" "${5}" &>> "${4}"
}

func_run_file_c() {
	local usage="Usage: ${FUNCNAME[0]} <file>" 
	func_param_check 1 "$@" 

	local file="$(readlink -f "${1}")"
	local file_name="$(basename "${1}")"
	local target_dir="$(dirname "${file}")/target"
	local executable="${target_dir}/${file_name%.c}"

	func_mkdir_cd "${target_dir}" &> /dev/null	|| func_die "ERROR: failed to make or change dir: ${target_dir}"
	cp -f "${file}" "${target_dir}"			|| func_die "ERROR: failed to copy file, FROM: ${file}, TO: ${target_dir}"
	func_delete_dated "${executable}"

	gcc -g -o "${executable}" "${file_name}"
	${executable} 

	# TODO: not only handle the "segmentation fault" exit/status code, other code will still swallowed if run this function in subshell
	# "Segmentation fault" is NOT a stderr/stdout msg, instead, is it a exit/status code !!! Also note the status code offset (128) might vary in diff shell !!!
	if [ $? = $(( 128 + 11 )) ] ; then echo "Segmentation fault" 1>&2 ; fi		

	rm "${target_dir}/${file_name}"
	"cd" - &> /dev/null || echo "ERROR: failed to go back previous dir"
}

func_run_file_java() {
	local usage="Usage: ${FUNCNAME[0]} <file>" 
	func_param_check 1 "$@" 

	local file_relative="${1}"
	local file_absolute="$(readlink -f "${1}")"
	local subpath_class="$(grep "^package " "${file_absolute}" | sed -e "s/package//;s/\s\|;//g;s/\./\//g;" )"

	# simple java file without maven
	[ -z "${subpath_class}" ] && func_run_file_java_simple "${file_relative}" && return

	# java file in maven project
	local path_proj="${file_absolute%${subpath_class}*}/../../.."
	[ ! -d "${path_proj}" ] && func_die "ERROR: ${path_proj} NOT exist!"
	pushd "${path_proj}" &> /dev/null
	func_mvn_run "${file_relative}"
	popd &> /dev/null
}

func_run_file_java_simple() {
	local usage="Usage: ${FUNCNAME[0]} <file>" 
	func_param_check 1 "$@" 

	local file="$(readlink -f "${1}")"
	local dir_name="$(dirname "${file}")"
	local file_name="$(basename "${file}")"
	local target_dir="${dir_name}/target"

	local class_path="."
	[ -d "${dir_name}/lib" ] && local class_path="${class_path}:${dir_name}/lib/*"

	func_mkdir_cd "${target_dir}" &> /dev/null	|| func_die "ERROR: failed to make or change dir: ${target_dir}"
	cp -f "${file}" "${target_dir}"			|| func_die "ERROR: failed to copy file, FROM: ${file}, TO: ${target_dir}"
	func_delete_dated "${file_name/%.java/.class}" &> /dev/null

	javac -cp "${class_path}" "${file_name}"
	java  -cp "${class_path}" "${file_name%.java}"
	rm "${target_dir}/${file_name}"
	"cd" - &> /dev/null || echo "ERROR: failed to go back previous dir"
}

func_run_file() {
	local usage="Usage: ${FUNCNAME[0]} <file>" 
	func_param_check 1 "$@" 
	
	local file="${1}"
	func_complain_path_not_exist "${file}" && return 1 

	if [[ "$file" = *.c ]] ; then		(func_run_file_c "$file")	# use subshell, could make sure "stay in current dir" even used ^C, but subshell stderr seems lost (can NOT get msg like "Segmentation fault", also NOTE, the "Segmentation fault" msg is print by shell, not by the crashed app)
	#if [[ "$file" = *.c ]] ; then		func_run_file_c $file		# not using subshell, current dir might change to "target" when use ^C
	elif [[ "$file" = *.java ]] ; then	func_run_file_java "$file"
	elif [[ "$file" = *.js ]] ; then	node "$file"
	elif [[ "$file" = *.rb ]] ; then	ruby "$file"
	elif [[ "$file" = *.sh ]] ; then	bash "$file"
	elif [[ "$file" = *.py ]] ; then	python "$file"
	elif [[ "$file" = *.php ]] ; then	php "$file"
	elif [[ "$file" = *.bat ]] ; then	cmd "$file"
	elif [[ "$file" = *.exe ]] ; then	cmd "$file"
	elif [[ "$file" = *.groovy ]] ; then	groovy "$file"
	elif [[ "$file" = *.ps1 ]] ; then	/cygdrive/c/Windows/system32/WindowsPowerShell/v1.0/powershell.exe -ExecutionPolicy RemoteSigned -File "${file//\\/\/}"
	else
		echo "ERROR: can not run file $file"
	fi
}

func_run_file_format_output() {
	local usage="Usage: ${FUNCNAME[0]} <file>" 
	func_param_check 1 "$@" 

	func_run_file "${1}" | column -t -s "|"
}

func_ctrl_me() {
	local usage="Usage: ${FUNCNAME[0]} <target> <action>" 
	func_param_check 2 "$@" 

	name=$1
	action=$2
	parent=${name%%_*}
	script=/data/${parent}/${name}/bin/${action}.sh

	[ ! -e "$script" ] && func_die "ERROR: $script not exist"
	$script 
}

func_mount_iso() {
	local usage="Usage: ${FUNCNAME[0]} <target_path> <iso_path>" 
	func_param_check 2 "$@" 

	#mount -t iso9660 -o ro,loop,noauto /your/texlive2012.iso /mnt
	sudo mount -t iso9660 -o ro,loop,noauto "$2" "$1"
}
 
func_mytask_all() {
	local base=$MY_ENV_ZGEN/mytask
	local log=$base/a.log
	func_log_info "${FUNCNAME[0]}" "$log" "start"

	# find all files to execute
	for f in "$base"/todo_* ; do
		[[ -e "$f" ]] || continue
		func_log_info "${FUNCNAME[0]}" "$log" "found $f"
		IFS="_" read -ra fa <<< "$f"
		"func_mytask_${fa[1]}_run" "$f"
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

# shellcheck disable=2154
func_mytask_mail_run() {
	local usage="Usage: ${FUNCNAME[0]} <file>" 
	func_param_check 1 "$@" 

	local log=$base/a.log
	func_log_info "${FUNCNAME[0]}" "$log" "execute file $f"

	source "$f"
	echo "${mytask[mt_time_deadline]}"
	echo "${mytask[mt_time_win_start]}"
	echo "${mytask[mt_time_win_stop]}"
	echo "${mytask[mt_time_last_run]}"
	echo "${mytask[mt_history]}"
}

func_tool_gen_vars() {
	local desc="Desc: 1) generate variable list for functions to source. 2) all variables are prefixed with 'local'"
	func_param_check 1 "$@"
	
	cat "$@" 2> /dev/null |\
	sed -e 	"/^\s*#/d;
		/^\s*$/d;
		s/^\([^=[:blank:]]*\)[[:blank:]]*=[[:blank:]]*/\1=/;
		s/^/local /"
}

func_apt_add_repo() {
	local usage="USAGE: ${FUNCNAME[0]} <repo-name>" 
	func_param_check 1 "$@"

	apt_repo_name="${1}"
	apt_source_name="$(echo "${apt_repo_name}" | sed -e 's/.*://;s/\//-/')"

	if ls /etc/apt/sources.list.d/*"${apt_source_name}"* &> /dev/null ; then
		echo "INFO: ${apt_repo_name} (${apt_source_name}) already added, skip"
		return 0
	fi

	sudo add-apt-repository -y "${apt_repo_name}" &> /dev/null
}

func_find_big_files() {
	find . -type f -printf "%s\t%p\n" | sort -n | tail -"${1}"
}

func_find_space() {
	echo -e "INFO: 1st check"
	du -sh ~/amp				2>&1 | sed -e "/Permission denied/d"
	du -sh ~/.zbox				2>&1 | sed -e "/Permission denied/d"
	du -sh ~/.myenv				2>&1 | sed -e "/Permission denied/d"
	du -sh ~/.android			2>&1 | sed -e "/Permission denied/d"
	du -sh ~/.Genymobile			2>&1 | sed -e "/Permission denied/d"
	du -sh ~/.local/share/Trash		2>&1 | sed -e "/Permission denied/d"

	echo -e "\n\n\nINFO: 2nd check"
	du -sh /data				2>&1 | sed -e "/Permission denied/d"

	echo -e "\n\n\nINFO: 3rd check"
	du -sh ~/Documents/{D,E,F}C*		2>&1 | sed -e "/Permission denied/d"
}

func_op_compressed_file() {
	local usage="USAGE: ${FUNCNAME[0]} <file-suffix> <compressed-file>" 
	func_param_check 1 "$@"

	local file_suffix="${1}"
	local compressed_file="${2}"
	local target_dir="$(mktemp -d)"
	echo "${compressed_file}" 
	echo "${target_dir}" 
	func_uncompress "${compressed_file}" "${target_dir}" || func_die "ERROR: can NOT uncompress file: ${compressed_file}"
	echo 111111111111111
	cd "${target_dir}" || func_die "ERROR: failed to cd into ${target_dir}"
	echo 111111111111111
	local target_file="$(ls ./*"${file_suffix}")"
	echo 22222
	[ "$(echo "${target_file}" | wc -l)" -eq 1 ] && xdg-open "${target_file}" || echo "WARN: more than one file with suffix: ${file_suffix}, pls open manually"
	echo 33333
}

# shellcheck disable=2199
func_monitor_and_run() {
	local watch_path="${1}"
	shift

	# TODO: the cmd should run at beginning
	# TODO: record the last_pid, and kill it at beginning
	# TODO: how to kill the last process when Ctrl+C pressed > seemsm need use a standalone script and trap Ctrl+C
	
	# check target exist
	func_validate_path_exist "${watch_path}"

	# check if *last* cmd used "sudo"
	local is_sudo_used='false'
	[[ "${@: -1}" = sudo* ]] && is_sudo_used='true'

	# kill if last process still exist
	local lastpid event
	local pid_file="/tmp/_myenv_monitor_and_run_sudo-${is_sudo_used}_.pid"
	local pid="$(cat "${pid_file}" 2>/dev/null)"
	func_kill_self_and_descendants "${is_sudo_used}" "${pid}" || return 1

	# initial run
	lastpid="${pid}"
	func_run_cmds_in_bg "${@}"
	pid=$!
	echo "${pid}" > "${pid_file}"
	echo "INFO: start, pid: ${pid}, watch_path: ${watch_path}, is_sudo_used: ${is_sudo_used}, cmds: $*"

	# fswatch NEED: sudo port/apt-get install fswatch, or install latest git veriosn via zbox
	func_monitor_fs "${watch_path}" | while IFS= read -r event || [[ -n "${event}" ]] ; do

		echo "INFO: $(func_dati): target updatd, event: ${event}"
		func_kill_self_and_descendants "${is_sudo_used}" "${pid}" || return 1

		# run command and record pid
		lastpid="${pid}"
		func_run_cmds_in_bg "${@}"
		pid=$!
		echo "${pid}" > "${pid_file}"

		# shellcheck disable=2009
		#echo "INFO: run cmd, lastpid=${lastpid} ($(ps -ef | grep -v grep | grep -q "[[:space:]]${lastpid}[[:space:]]" && echo "FAILED to kill" || echo "killed")), curent pid=${pid}"
		echo "INFO: run cmd, lastpid=${lastpid} ($(func_is_pid_or_its_child_running "${lastpid}" && echo "FAILED to kill" || echo "killed")), curent pid=${pid}"
	done
}

func_run_cmds_in_bg() {
	local cmd
	for cmd in "$@" ; do
		eval "${cmd}" &
	done
}

func_monitor_fs() {
	# INSTALL, fswatch: see ~zbox for linux, for osx: sudo port install fswatch
	# INSTALL, inotifywait: sudo apt-get install inotify-tools
	# NOTE: fswatch not work on ubuntu 10.04, use inotifywait instead

	# default use fswatch, otherwise inotifywait
	if func_is_cmd_exist "fswatch" ; then
		fswatch --one-per-batch --recursive "${1}"

		# seems --directories is useless here
		#fswatch --one-per-batch --recursive --directories "${1}"

		# --format is incompatible with --one-per-batch
		# fswatch --format-time '%Y-%m-%d %H:%M:%S' --format "%t %p" --one-per-batch "${1}"

	elif func_is_cmd_exist "inotifywait" ; then
		# --monitor: mon without stop, --quiet: avoid the heading info to raise "false alarm", --event "close_write": seems this event is enough, too much event cause too much lines
		inotifywait --monitor --quiet --recursive --event "close_write" "${1}"

		# old cmd line
		#inotifywait -mr --timefmt '%Y-%m-%d %H:%M:%S' --format '%T %w %f' -e close_write "${watch_path}" | \
	else
		# output to stderr, in case cause "false alarm" to invoker
		echo "ERROR: both fswatch and inotifywait NOT exist, pls install them first" 1>&2
	fi
}

func_find_non_utf8_in_content() {
	local usage="USAGE: ${FUNCNAME[0]} <filelist>" 
	func_param_check 1 "$@"

	local tmp_filelist=$(mktemp)
	echo "INFO: grep filelist into: ${tmp_filelist}"
	grep '^@/\|^@\$' "${1}" | sed -e "s/^@//" > "${tmp_filelist}"

	local tmp_suspect=$(mktemp)
	echo "INFO: grep suspected files into: ${tmp_suspect}"

	# TODO: use func_pipe_remove_lines instead
	xargs -a "${tmp_filelist}" -n 1 -I {} file {} | sed -e '/ASCII text/d;/UTF-8 Unicode/d;/: empty *$/d;/XML document text/d' > "${tmp_suspect}"

	echo "INFO: suspected files are:"
	cat "${tmp_suspect}"
}

# shellcheck disable=2009
func_rsync_tmp_stop() {
	local usage="USAGE: ${FUNCNAME[0]} <TTL>" 
	local desc="Desc: stop rsync_tmp which started by func_rsync_tmp, if <TTL> (seconds) provided, set a scheduled kill job instead of kill immediately"

	local ttl="${1}"
	local conf_name="rsync_tmp.server.conf"
	local pid_file="/tmp/_myenv_rsync_tmp_.pid"
	local pid_num="$(cat "${pid_file}" 2>/dev/null)"

	func_is_positive_int "${pid_num}" || func_die "ERROR: pid_file (${pid_file}) NOT exist or no valid pid inside!"

	if [ -n "${ttl}" ] && func_is_positive_int "${1}" ; then
		func_is_int_in_range "${ttl}" 10 2592000 || func_die "ERROR: TTL value NOT in ranage 10~2592000 (10s ~ 30days), NOT allowed!"

		echo "INFO: schedule a job to kill rsync_tmp with pid=${pid_num} after ${ttl} seconds."
		bash -c "sleep ${ttl} && ps -ef | grep -q '${pid_num}.*rsync.*${conf_name}' && source ${MY_ENV}/myenv_func.sh && func_kill_self_and_descendants 'false' ${pid_num} && rm ${pid_file}" &
		return 0
	fi

	# otherwise kill immediately
	echo "INFO: kill rsync_tmp with pid=${pid_num}"
	ps -ef | grep -q "${pid_num}.*rsync.*${conf_name}" && func_kill_self_and_descendants 'false' "${pid_num}"
}

func_rsync_tmp() {
	local usage="USAGE: ${FUNCNAME[0]} <TTL> <path>" 
	local desc="Desc: start a temporary rsync server, shedule a kill job with <TTL> (seconds, default 3600s)"

	# TODO: support change path, which need to update file $MY_ENV/secu/rsync_tmp.server.conf
	[ -n "${2}" ] && echo "ERROR: NOT support specify <path> yet" && return 1

	# Arg/Var, NOTE: value of pid_file and conf name, also used in func_rsync_tmp_stop
	local ttl="${1:-3600}"
	local base="${2:-${HOME}/amp}"
	local port="$(func_find_idle_port 8888 8988)"
	local pid_file="/tmp/_myenv_rsync_tmp_.pid"
	local log_file="/tmp/_myenv_rsync_tmp_.log"
	local conf="${MY_ENV}/secu/rsync_tmp.server.conf"

	# Pre-check
	func_complain_cmd_not_exist rsync && return 1
	func_complain_path_not_exist "${base}" && return 1
	func_complain_path_not_exist "${conf}" && return 1
	[ -z "${port}" ] && echo "ERROR: failed to find idle port" && return 1
	[ -f "${pid_file}" ] && func_is_running "${pid_file}" && echo "ERROR: rsync_tmp already running, pls check" && return 1
	func_is_int_in_range "${ttl}" 10 2592000 || func_die "ERROR: TTL value NOT in ranage 10~2592000 (10s ~ 30days), NOT allowed!"

	# Run
	echo "INFO: run cmd: rsync --daemon --port ${port} --config ${conf}"
	rsync --daemon --port "${port}" --config "${conf}"

	# shellcheck disable=2181
	if [ "$?" -ne "0" ] ; then 
		echo "ERROR: rysnc startup failed, exit code: $?"
		return 1
	fi

	# info for user
	echo "INFO: rsync server info, port: ${port}, base: ${base}, pid: $(cat ${pid_file} 2>/dev/null), log: ${log_file}"
	echo "INFO: client side command examples"
	echo "  sync      rsync -avzP --port=${port} --password-file=\${MY_ENV}/secu/rsync_tmp.client.scr ..."
	echo "  list      rsync -avzP --port=${port} --password-file=\${MY_ENV}/secu/rsync_tmp.client.scr --list-only rsync_tmp@$(func_ip_single)::rsync_tmp/"
	echo "  upload    rsync -avzP --port=${port} --password-file=\${MY_ENV}/secu/rsync_tmp.client.scr <source> rsync_tmp@$(func_ip_single)::rsync_tmp/"
	echo "  download  rsync -avzP --port=${port} --password-file=\${MY_ENV}/secu/rsync_tmp.client.scr rsync_tmp@$(func_ip_single)::rsync_tmp/ <target>"
	echo " "

	# shedule a timed kill, if need
	if [ -n "${ttl}" ] && func_is_positive_int "${ttl}" ; then
		func_rsync_tmp_stop "${ttl}"
	fi
}

func_rsync_backup() {
	# Example used for jrepo2 rsync
	#	run cmd			func_export_script func_rsync_backup nexus_all.sh
	#	update nexus_all.sh	func_rsync_backup nexus_all /data/services/ "nexus_all@113.108.231.170::nexus_all/" 8730
	#	add crontab task	*/18 3-5 * * *	root	bash /data/services/nexus_all_rsync/nexus_all.sh >> /data/services/nexus_all_rsync/cron.log 2>&1

	local usage="Usage: ${FUNCNAME[0]} <name> <base> <rsync_addr> <port - optional>" 
	local desc="Desc: backup via rsync" 
	func_param_check 3 "$@"

	# Parameters
	local name="${1}"
	local base="${2%/}"
	local rsync_addr="${3}"
	local port="${4:-873}"

	# Variables
	local bak_path=${base}/${name}/
	local log_file=${base}/${name}_rsync/${name}.log
	local pid_file=${base}/${name}_rsync/${name}.pid
	local rsync_pass=${base}/${name}_rsync/${name}.pass

	# Validation and init
	[ -f "${rsync_pass}" ] || func_die "ERROR: ${rsync_pass} NOT exist, pls check!"
	func_is_running "${pid_file}" && func_techo info "${name} backup already running, skip" && exit 0
	[ -d "${bak_path}" ] || mkdir -p "${bak_path}" || func_die "ERROR: ${bak_path} NOT dir, pls check!"

	# Perform backup
	local rsync_pid
	func_techo info "start to backup ${name}" | tee -a "${log_file}" 
	func_techo info "cmd: nohup /usr/bin/rsync -avz --port=${port} --password-file=${rsync_pass} ${rsync_addr} ${bak_path}" | tee -a "${log_file}";
	nohup /usr/bin/rsync -avz --port="${port}" --password-file="${rsync_pass}" "${rsync_addr}" "${bak_path}" >> "${log_file}" 2>&1 &
	rsync_pid=$!
	echo "${rsync_pid}" > "${pid_file}"

	# Status followup
	func_techo info "rsync process id is: ${rsync_pid}"
	if wait "${rsync_pid}" ; then
		func_techo info "backup ${name} (pid ${rsync_pid}) success" | tee -a "${log_file}" 
	else
		func_techo error "backup ${name} (pid ${rsync_pid}) FAILED, pls check" | tee -a "${log_file}" 
	fi
}

func_samba_is_mounted() {
	local usage="USAGE: ${FUNCNAME[0]} <path>" 
	func_param_check 1 "$@"
	df | grep -q "${1}" &> /dev/null
}

func_samba_umount() {
	local usage="USAGE: ${FUNCNAME[0]} <config_file>" 
	func_param_check 1 "$@"

	# load config
	func_validate_path_exist "${1}"
	eval "$(func_gen_local_vars "${1}")"
	func_str_contains_blank "${mount_path}" && func_die "ERROR: critical config NOT set, pls check (mount_path)"

	# umount
	if func_is_os_osx ; then
		umount "${mount_path}"
	else
		func_die "ERROR: pls write code for current os: ${MY_OS_NAME}"
	fi

	# re-check
	if func_samba_is_mounted "${mount_path}" ; then
		echo "INFO: umount success"
	else
		func_die "WARN: mount failed, pls check"
	fi
}

# shellcheck disable=2154
func_samba_mount() {
	local usage="USAGE: ${FUNCNAME[0]} <config_file>" 
	func_param_check 1 "$@"

	# load config
	func_validate_path_exist "${1}"
	eval "$(func_gen_local_vars "${1}")"
	func_str_contains_blank "${mount_path}" "${samba_path}" && func_die "ERROR: critical config NOT set, pls check (mount_path/samba_path)"

	# check
	mount_path="$(readlink -f "${mount_path}")"
	func_samba_is_mounted "${mount_path}" && echo "INFO: already mounted, at: ${mount_path}"

	# mount
	[ -d "${mount_path}" ] || mkdir -p "${mount_path}"
	if func_is_os_osx ; then
		echo "INFO: cmd: mount_smbfs ${samba_path} ${mount_path}"
		mount_smbfs "${samba_path}" "${mount_path}"
	else
		func_die "ERROR: pls write code for current os: ${MY_OS_NAME}"
	fi

	# recheck
	func_samba_is_mounted "${mount_path}" || func_die "ERROR: mount failed! pls check"
	echo "INFO: mount success at: ${mount_path}"
	cd "${mount_path}" || echo "ERROR: failed to cd ${mount_path}"
}

func_ls_tmp() {
	if [[ -z "${TMPDIR}" ]] || [[ "${TMPDIR}" -ef "/tmp/" ]] ; then
		ls -lhtr /tmp/
		return 0
	fi

	# find cmd alternative
	# Explain: '-not -path' performs exclude matching. NOTE: there are 2 place of the $TMPDIR
	# find $TMPDIR -maxdepth 1 -not -path '*/.*' -not -path "$TMPDIR" -printf '%T@ %p\n'  | sort -n | tail

	# "${TMPDIR}" and "/tmp/" is different, need both ls
	local a b
	a="$(ls -htr "/tmp/" | tail)"
	b="$(ls -htr "${TMPDIR}" | tail)"
	echo "---------------- ${TMPDIR} ----------------"
	echo "$a"
	echo "-------------------------------------- /tmp/ --------------------------------------"
	echo "$b"

	return 0

	# 都不太好用
	#pr -2 -t <<-eof	# 长度不够，会覆盖，看不清
	column -c 20 <<-eof	# 勉强可以看，和上面的直接输出差不多
	FILE_IN_/TMP/: /tmp/
	$a

	FILE_IN_TMPDIR: ${TMPDIR}
	$b
	eof
}

func_update_book_name() {
	local usage="USAGE: ${FUNCNAME[0]} <match_str> <target_str>" 
	local desc="Desc: rename books according to parameter" 
	func_param_check 2 "$@"

	local f
	# update but NOT tested, should work
	#for f in $(ls | grep "${1}.*\(pdf\|epub\|azw3\|mobi\)") ; do
	for f in "${1}"*.pdf "${1}"*.epub "${1}"*.azw3 "${1}"*.mobi ; do
		[[ -e "$f" ]] || continue
		echo -e "${f}" "\t->\t" "${2}.${f##*.}"
		mv "${f}" "${2}.${f##*.}"
	done
	ls -l
}

func_mm_is_moov_in_head() {
	local usage="USAGE: ${FUNCNAME[0]} <target> ..." 
	local desc="Desc: check if moov in head part (1st frame will shows faster)<target>" 
	func_param_check 1 "$@"

	# NOTE: the "-T" is important!!!
	for f in "$@" ; do
		AtomicParsley "${f}" -T | sed -n 2p | grep -q "moov" && echo "${f}: yes, in header part" || echo "${f}: no, in tail part"
	done
}

# TODO: mv to myenv_lib > For_Script
func_export_script() {
	local usage="USAGE: ${FUNCNAME[0]} <function_name> <target_script>" 
	local desc="Desc: export a runnable script of <function_name> into <target_script>" 
	func_param_check 2 "$@"

	# TODO: 
	#	FAILED: func_export_script func_backup_myenv func_backup_myenv.alone.sh
	#	REASON: func_backup_myenv used eval inside (by sub call of func_collect_myenv), which cat $$LOC_HOSTS inside, and $LOC_HOSTS is empty !

	local fdone=()
	local ftodo=("${1}")
	local target="${2}"
	func_complain_path_exist "${target}" && return 1

	local c f count
	local max_count=1000
	local eresult="success"
	while func_is_array_not_empty "${ftodo[@]}" ; do
		# Safe check
		count=$(( count + 1 ))
		if (( count > max_count )) ; then
			echo "ERROR: too much loops (${count} > ${max_count}), quit to prevent infinite loop, pls check"
			eresult="fail"
			break
		fi

		# Export and record
		c=${ftodo[0]}
		func_complain_function_not_exist "${c}" && eresult="fail" && break

		echo "" >> "${target}"
		type "${c}" | sed -e '1d' >> "${target}"
		fdone+=("${c}")
		ftodo=("${ftodo[@]:1}")
		func_decho "processing: ${c}, DONE: ${fdone[*]}, TODO: ${ftodo[*]}"

		# Recursive
		for f in $(type "${c}" | grep -o "func_[[:alnum:]_]*" | sort -u) ; do
			count=$(( count + 1 ))

			func_array_contains "${f}" "${fdone[@]}" "${ftodo[@]}" && continue
			ftodo+=("${f}")
			func_decho "found: ${f}"
		done
	done

	# Post process
	if [[ "${eresult}" = "success" ]] ; then

		# Export MY_ENV_xxx VAR. TODO: 1) one time grep is NOT enough (the var assignment migth contain other var OR func_). 2) only grep myenv_func.sh might NOT enough
		local var_pattern var_strings
		var_pattern="$(grep -o "MY_[_A-Z]*" "${target}" | sort -u | sed -z 's/\n/\\|/g;s/^/\\(/;s/$/MY_ENV\\)=/;')"
		var_strings="$(grep "${var_pattern}" ~/.myenv/myenv_func.sh)"
		[ -n "${var_strings}" ] && echo "${var_strings}" | sed -i -e '1r /dev/stdin' "${target}"

		# Gen note
		sed -i -e "1i#!/bin/bash\\
		\n# Generated Info:\\
		#    By: $(whoami)\\
		#    Time: $(func_dati)\\
		#    Git rev: $("cd" "${HOME}" &>/dev/null && git rev-parse HEAD)\\
		#    Export cmd: ${FUNCNAME[0]} $*\\
		#    NOTE: this script is executable, as the last line is invoking function '${1}'\\
		" "${target}"
		echo "${1} \"\${@}\"" >> "${target}"
		echo "INFO: export success."
	else
		sed -i -e "1i#!/bin/bash\\
		\n# DO NOT USE THIS SCIRPT, as failure occurred during generation!						\\
		\nexit 1													\\
		\n# Generated at: $(func_dati), git rev: $("cd" "${HOME}" &> /dev/null && git rev-parse HEAD)			\\
		" "${target}"
		echo "ERROR: export failed"
	fi
}

func_dup_gather_try_bakpath_PRIVATE() {
	local usage="USAGE: ${FUNCNAME[0]} <filepath>" 
	local desc="Desc: if path is doc backup, try diff path for DTZ/TCZ/lap" 
	func_param_check 1 "$@"

	local tline1 tline2
	# NOTE: NO prefix chars for these 2 path !
	if [[ "${1}" = backup_unison/* ]] ; then 
		tline1="${1#backup_unison/}"
		tline2="${1/backup_unison/backup_rsync/}"
		[ -e "${tline1}" ] && echo "${tline1}" && return
		[ -e "${tline2}" ] && echo "${tline2}" && return
	fi

	if [[ "${1}" = backup_rsync/* ]] ; then
		tline1="${1#backup_rsync/}"
		tline2="${1/backup_rsync/backup_unison/}"
		[ -e "${tline1}" ] && echo "${tline1}" && return
		[ -e "${tline2}" ] && echo "${tline2}" && return
	fi

	echo "${1}"
}

func_dup_gather() {
	local usage="USAGE: ${FUNCNAME[0]} <filelist>" 
	local desc="Desc: gather files in <filelist> (use default list if not provided), preserve dir structure.\nNOTE: the filelist is output of func_dup_find"

	local DUP_CONFIG="${MY_ENV}/secu/personal/dup/"
	local DUP_DEL_LIST="${DUP_CONFIG}/del_list"

	local del_list
	if func_is_str_blank "${1}" ; then
		func_ask_yes_or_no "WARN: NO param (del_list) provided, use default list (${DUP_DEL_LIST})? (y/n)" \
		&& del_list="${DUP_DEL_LIST}"
	else
		del_list="${1}"
	fi
	func_validate_path_exist "${del_list}"
	
	# Process each file
	local line tpath tfile log dup_dir
	dup_dir="A_GATHER_DIR_$(func_dati)"
	log="${dup_dir}/A.log"
	mkdir "${dup_dir}"
	while IFS= read -r line || [[ -n "${line}" ]] ; do
		# normal case: file inexist. 
		if [ ! -e "${line}" ] ; then
			# for doc backup path, try alternative paths
			if [[ "${line}" = backup_unison/* ]] || [[ "${line}" = backup_rsync/* ]] ; then
				line="$(func_dup_gather_try_bakpath_PRIVATE "${line}")"
			fi
		fi
		[ ! -e "${line}" ] && echo "MV_SKIP: skip since inexist: ${line}" >> "${log}" && continue

		# move (preserve path structure)
		tpath="${dup_dir}/$(dirname "${line}")"
		[ -d "${tpath}" ] || mkdir -p "${tpath}"
		mv "$line" "${tpath}"

		# verify
		tfile="${tpath}/$(basename "${line}")"
		[ -e "${line}" ] && echo "MV_FAIL: failed to move, file still there: ${line}"       >> "${log}" && continue
		[ ! -e "${tfile}" ] && echo "MV_FAIL: failed to move, file NOT in target: ${tfile}" >> "${log}" && continue
		echo "MV_DONE: move file success: ${tfile}"                                         >> "${log}" && continue

	done < <(func_del_blank_and_hash_lines "${del_list}")

	echo "INFO: ==================================== SUMMARY ===================================="
	touch "${log}" # incase do nothing
	local fail="$(grep -c "MV_FAIL" "${log}")"
	local skip="$(grep -c "MV_SKIP" "${log}")"
	local success="$(grep -c "MV_DONE" "${log}")"
	echo "INFO: files moved to (size: $(du -sh "${dup_dir}" | cut -d' ' -f1) ): ${dup_dir}"
	echo "INFO: ${fail} fail, ${success} success, ${skip} skip, see detail: ${log}"
}

func_dup_find_gen_md5_PRIVATE() {
	# Skip symbolic link
	if [ -h "${1}" ] ; then 
		# TODO: NOT found such log, why?
		echo "DUP_SKIP_LINK: ${1}" >> "${dup_log}"
		return
	fi

	#UPDATE: logic moved to func_dup_find, which gen and filter filelist
	# # Skip path
	# #if echo "${1}" | grep -q -f "${dup_skip_path_patterns}" ; then
	# if echo "${1}" | func_grepf -q "${DUP_SKIP_PATH}" ; then
	# 	echo "DUP_SKIP_PATH: ${1}" >> "${dup_log}"
	# 	return
	# fi

	# Reuse md5 if possible. 
	# - To make better match: always remove "./" prefix, and remove "backup_rsync/backup_unison" if have
	# - always ignore empty file md5 (reuse this might cause delete by mistake): d41d8cd98f00b204e9800998ecf8427e
	local md5_out
	local sname="${1}" 
	[[ "${sname}" = ./* ]]             && sname="${sname#./}"
	[[ "${sname}" = backup_rsync/* ]]  && sname="${sname#backup_rsync/}"
	[[ "${sname}" = backup_unison/* ]] && sname="${sname#backup_unison/}"
	md5_out="$(grep -F "${sname}" "${DUP_LIST_MD5}" | grep -v d41d8cd98f00b204e9800998ecf8427e | head -1)"
	if [[ -n "${md5_out}" ]] ; then
		md5_out="${md5_out%% *} ${1}"
	else
		md5_out="$(md5sum "${1}")"
		echo "${md5_out}" >> "${list_md5_new}"
		echo "DUP_CALC_MD5: ${1}" >> "${dup_log}"
	fi

	# Skip md5, only match md5, might ingore more but also safe
	if grep -q "${md5_out%% *}" "${DUP_SKIP_MD5}" ; then
		echo "DUP_SKIP_MD5: ${md5_out}" >> "${dup_log}"
		return
	fi

	# Record md5
	echo "${md5_out}" >> "${list_md5_all}"
}

func_dup_gather_then_find() {
	# pass a empty str to avoid editor error report 
	func_dup_gather ""
	func_dup_find
}

# shellcheck disable=2120
func_dup_find() {
	# TOOL SCRIPT
	# - 01: split result file by lines of dup
	#	awk 'BEGIN{c=0;}/^$/{for(i=0;i<c;i++){print arr[i] >> c};print "" >> c; c=0};/.+/{arr[c++]=$0;}'
	# - 02: for skip_md5: select 1 line from each block
	#	cat -s del_list.to_merge2 | awk 'BEGIN{p=0;}/^$/ {p=0;};/.+/ {if(p==0) {print $0;p=1;}}' 

	local usage="USAGE: ${FUNCNAME[0]} <path> <path> <...>" 
	local desc="Desc: find duplicated files in paths (use md5)" 

	local dup_base="/tmp/dup_$(func_dati)"
	local list_md5_all="${dup_base}/list_md5.txt"
	local list_md5_new="${dup_base}/list_md5.new"
	local list_dup_count="${dup_base}/list_dup_count.txt"
	local list_dup_detail="${dup_base}/list_dup_detail.txt"
	local dup_log="${dup_base}/a.dup_log.txt"
	#local dup_skip_path_patterns="${dup_base}/dup_skip_path_patterns"

	# Pre-check
	if [[ ! -e "${DUP_SKIP_MD5}" ]] || [[ ! -e "${DUP_LIST_MD5}" ]] || [[ ! -e "${DUP_SKIP_PATH}" ]] ; then
		func_ask_yes_or_no "WARN: DUP CONFIG files NOT exist (WILL BE VERY SLOW), contiue (y/n)?" || return 1
	fi

	func_info "start to gen filelist at: ${dup_base}/"
	local p f fl_raw fl_use
	mkdir -p "${dup_base}"
	fl_raw="${dup_base}/filelist.raw"
	fl_use="${dup_base}/filelist.use"
	if [ $# -eq 0 ] ; then
		# WORKS (slower, output smaller): find ./ -type f ! -path '*/FCS/*' ! -path '*/FCZ/*' ! -path '*/DCD/mail/mail_*' ! -path '*/A_GATHER_DIR_20*'  
		find ./ -type f >> "${fl_raw}"
	else
		for p in "$@" ; do
			find "${p}" -type f >> "${fl_raw}"
		done
	fi
	func_del_pattern_lines_f "${DUP_SKIP_PATH}" "${fl_raw}" > "${fl_use}"

	func_info "start to gen md5/file pair"
	while IFS= read -r line || [[ -n "${line}" ]] ; do
		func_dup_find_gen_md5_PRIVATE "${line}"
	done < "${fl_use}"

	func_info "start to gen dup report"
	# seems use sort -k1 better? since awk can NOT easily handle the "2nd to last field", and merge files in single line is NOT easy to read
	# https://stackoverflow.com/questions/40134905/merge-values-for-same-key
	#awk -F, '{a[$1] = a[$1] FS $2} END{for (i in a) print i a[i]}' $file
	cut -d' ' -f1 "${list_md5_all}" | sort | uniq -c | sed -e '/^\s\+1\s\+/d' > "${list_dup_count}"

	local dup_count
	dup_count="$(func_file_line_count "${list_dup_count}")"
	if (( dup_count == 0 )) ; then
		func_info "no dup files found, check new md5 at: ${list_md5_new}"
		return 0
	fi

	local count md5
	while read -r count md5 || [[ -n "${count}" ]] ; do
		[[ "${count}" -eq 1 ]] && echo "ERROR: should NOT found count=1 md5 here" && continue
		grep "${md5}" "${list_md5_all}" >> "${list_dup_detail}"
		echo >> "${list_dup_detail}"
	done < "${list_dup_count}" 

	if [ -e "${list_dup_detail}" ] ; then
		func_info "found $(func_file_line_count "${list_dup_detail}") files"
		func_info "1) check new md5 at: ${list_md5_new}"
		func_info "2) check detail at: ${list_dup_detail}"
	else
		func_info "NO dup files found, check new md5 at: ${list_md5_new}"
	fi
}

func_dup_shrink_md5_list() {
	local hn
	hn="$(hostname -s)"
	if [[ "${hn}" = lapmac* ]] ; then
		func_dup_shrink_md5_list_lapmac
		return
	fi

	if [[ "${hn}" = laptp* ]] ; then
		# TODO: 
		#	for bdta
		#	for btca
		echo "WARN: NOT impl yet"
		return
	fi
}

func_dup_shrink_md5_list_lapmac() {
	func_validate_path_exist "${MY_DCB}" "${MY_DCC}" "${MY_DCD}" "${MY_DCM}" "${MY_DCO}" "${MY_FCS}" "${MY_FCZ}"

	local p todel sed_param
	new="${DUP_LIST_MD5}.new"
	todel="${DUP_LIST_MD5}.to.delete" 
	sed_param='s+ \./+ +;s/^[^ ]* \+//;s+backup_rsync/++;s+backup_unison/++;'
			     
	while IFS= read -r line || [[ -n "${line}" ]] ; do
		p="${MY_DOC}/${line}" 
		[[ -e "${p}" ]] || echo "${line}" >> "${todel}" 
	done < <(func_del_blank_and_hash_lines "${DUP_LIST_MD5}" | sed -e "${sed_param}")

	# remove skip files and remove inexist files
	func_del_pattern_lines_f "${DUP_SKIP_PATH}" "${DUP_LIST_MD5}" \
	| func_del_pattern_lines_f <(sed -e "${sed_param}" "${DUP_SKIP_MD5}" ) \
	| func_del_pattern_lines_f -F "${todel}" > "${new}" 

	echo "INFO: run this if want to use result, run command below:" 
	echo "    # ddelete ${DUP_LIST_MD5} ${todel}; mv ${new} ${DUP_LIST_MD5};"
	wc -l "${DUP_LIST_MD5}"
	wc -l "${new}"
}

func_gen_filelist_with_size(){
	local usage="USAGE: ${FUNCNAME[0]} <path> <output_path>" 
	local desc="Desc: gen file list with human readable size" 
	func_param_check 1 "$@"

	local src_path="${1}"
	local out_path="${2}"
	if [ -z "${out_path}" ] ; then
		local fpath="$(readlink -f "${src_path}")"
		local name="$(basename "${fpath}")"
		out_path="/tmp/fl_${name}_$(func_dati).txt"
	fi

	# V1, NOT work on UTF-8
	# TODO: file encoding break after numfmt cmd (UTF-8 -> Non-ISO extended-ASCII)
	#	cmd to prove: echo "8888 资格" | numfmt --to=si		# gets: "8.9K 资??"
	#find "${src_path}" -type f -printf '%s\t%P\n' | numfmt --field=1 --to=si --format="%-6f" > "${out_path}"

	# V2, work on UTF-8, cut file to 2 part, numfmt only handle the file size part
	# TODO: how to check cut/paste correct? 1. compare func_file_line_count 2. ???
	local tmpdir f_origin
	tmpdir="$(mktemp -d)"
	f_origin="${tmpdir}/a.size_file.by_find"
	f_1st_col="${tmpdir}/b.1st.column"
	f_2nd_col="${tmpdir}/c.2nd.column"
	f_1st_col_numfmt="${tmpdir}/d.1st.column.numfmt"
	find "${src_path}" -type f -printf '%s\t%P\n' > "${f_origin}"
	cut -f1  "${f_origin}" > "${f_1st_col}"
	cut -f2-  "${f_origin}" > "${f_2nd_col}"
	numfmt --field=1 --to=si --format="%-6f" < "${f_1st_col}" > "${f_1st_col_numfmt}"
	paste -d '\t' "${f_1st_col_numfmt}" "${f_2nd_col}" > "${out_path}"

	echo "INFO: filelist at: ${out_path} (size: $(func_file_size_human "${out_path}") )"
}

func_file_count_of_dir(){
	local usage="USAGE: ${FUNCNAME[0]} <path> <path>" 
	local desc="Desc: count files in dir" 
	
	local p count

	if [[ "$#" -eq 0 ]] ; then
		count="$(find ./ -type f | wc -l)"
		echo -e "${count}\t./"
		return
	fi

	for p in "$@" ; do
		[[ -f "${p}" ]] && continue
		[[ -h "${p}" ]] && echo -e "0\t(link) ${p}" && continue
		count="$(find "${p}" -type f | wc -l)"
		echo -e "${count}\t${p}"
	done
}

func_mydata_sync_v3(){
	# NOTE
	#	DISK
	#		DISK	VOL	FS	NOTE-1		NOTE-2
	#		----	----	----	----		----
	#		tcz	tcz	ExFAT	5T grey
	#		dtz	dtz	ExFAT	5T black
	#		dtb	dtb	HSF+	2T black	FS Detail: with long data line
	#		(3.5")	bdta	HSF+			FS Detail: MacOS entended (journaled) / case-insensitive / formatted by lapmac3 on 2024-07 
	#		(3.5")	btca	HSF+			FS Detail: MacOS entended (journaled) / case-insensitive / formatted by lapmac3 on 2024-07
	#		mhd500	mhd500		500G blue	(2024-07) all movie, not sync
	#
	#	FLOW
	#		doc	lapmac2 <-> lapmac3	-> DTZ (via unison)
	#						-> BDTA/tcz/btca (via rsync)
	#		misc	DTZ -> BDTA
	#			TCZ -> BTCA

	# Var
	local mnt_path tcz_path dtz_path btca_path bdta_path base tmp
	mnt_path="/Volumes"
	tcz_path="/tmp/tcz"
	btca_path="/tmp/btca"
	dtz_path="${mnt_path}/DTZ"
	bdta_path="${mnt_path}/bdta"

	# Pre-Check
	[[ "${HOSTNAME}" != lapmac* ]] && echo "ERROR: only runs on lapmac* !" && return

	# Clean up
	for base in "${tcz_path}" "${dtz_path}" "${btca_path}" "${bdta_path}" ; do
		func_mydata_clean_up "${base}"
	done

	# Sync - misc
	func_mydata_bi_sync "${tcz_path}" "${btca_path}" "h8"
	func_mydata_bi_sync "${dtz_path}" "${bdta_path}" "gigi zz dudu video"

	# Sync - doc
	if [[ "$(hostname -s)" == "lapmac2" ]] || [[ "$(hostname -s)" == "lapmac3" ]] ; then
		[[ -d "${dtz_path}/backup_unison" ]] && func_unison_fs_run
		func_mydata_sync_doc_rsync "${tcz_path}/backup_rsync"
		func_mydata_sync_doc_rsync "${bdta_path}/backup_rsync"
		func_mydata_sync_doc_rsync "${btca_path}/backup_rsync"
	fi

	# Sync - XXX_HIST & XXX_TODO (try possible combination, assume 1st update dtz)
	for tmp in "DCB_HIST" "DCJ_HIST" "DCM_HIST" "DCM_TODO" "DCS_HIST" ; do
		func_mydata_bi_sync "${dtz_path}/backup_unison/" "${bdta_path}/backup_rsync/" "${tmp}"
		func_mydata_bi_sync "${dtz_path}/backup_unison/" "${btca_path}/backup_rsync/" "${tmp}"
		func_mydata_bi_sync "${dtz_path}/backup_unison/" "${tcz_path}/backup_rsync/" "${tmp}"
		func_mydata_bi_sync "${btca_path}/backup_rsync/" "${tcz_path}/backup_rsync/" "${tmp}"
	done

	# Gen filelist
	if [[ "${1}" != "-nofl" ]] ; then
		for base in "${tcz_path}" "${dtz_path}" "${btca_path}" "${bdta_path}" ; do
			func_mydata_gen_fl "${base}"
		done
	fi
}

func_mydata_clean_up() {
	local f src tgt base trash line fl_del_alone fl_del_computer
	base="${1}"
	trash="${base}/alone/trash_for_clean_up"
	fl_del_computer="${HOME}/amp/data/mydata/fl_delete"

	[[ -d "${base}" ]] || return 0
	func_complain_path_not_exist "${fl_del_computer}" "INFO: skip, since fl_del not found." && return 0
	mkdir -p "${trash}"

	# 2 location: computer or locally on disk (${base}/alone/fl_delete/20*.txt)
	for f in "${fl_del_computer}"/20*.txt "${base}"/alone/fl_delete/20*.txt ; do
		echo "INFO: start to clean up ${base}, according to: ${f##*/}"
		while IFS= read -r line || [[ -n "${line}" ]] ; do
			src="${base}/${line}"
			tgt="${trash}/$(func_dati)_$(basename "${line}")"
			[[ -e "${src}" ]] || continue

			echo "INFO: --> mv ${src} ${tgt}"
			if func_str_contains "${src}" "*" ; then
				# $src need support wildcard, no quote
				# shellcheck disable=2086
				mv ${src} "${tgt}"
			else
				mv "${src}" "${tgt}"
			fi
		done < <(func_del_blank_and_hash_lines "${f}")
	done
}

func_mydata_dcm_hist_sync() {
	func_info "DCM_HIST RSYNC: ${1} --> ${2}"
	func_rsync_ask_then_run "${1}" "${2}" | sed -e 's/^/\t/;'
}

func_mydata_bi_sync() {
	func_param_check 3 "$@"
	func_is_str_blank "${3}" && func_die "NO sync list (sub dir) provided"

	local sync_item a b
	if [[ ! -e "${1}" ]] || [[ ! -e "${2}" ]] ; then
		func_info "SKIP: ${1} <-> ${2}"
		return
	fi
	
	for sync_item in ${3} ; do 
		# rsync cares the last "/", should be the same, better ending with "/"
		[[ "${1}/${sync_item}" = */ ]] && a="${1}/${sync_item}" || a="${1}/${sync_item}/" 
		[[ "${2}/${sync_item}" = */ ]] && b="${2}/${sync_item}" || b="${2}/${sync_item}/" 

		func_complain_path_not_exist "${a}" && continue
		func_complain_path_not_exist "${b}" && continue

		func_info "BI-RSYNC: ${a} <-> ${b}"
		func_rsync_ask_then_run "${a}" "${b}" | sed -e 's/^/\t/;'	# add leading tab to improve output readability
		func_rsync_ask_then_run "${b}" "${a}" | sed -e 's/^/\t/;'
	done
}

func_mydata_sync_doc_rsync() {
	local d target opts doc_ex_base src tgt
	doc_ex_base="${MY_DCC}/rsync/script/doc_bak"

	target="${1}"
	func_complain_path_not_exist "${target}" && return 1
	func_complain_path_not_exist "${doc_ex_base}" && return 1

	# NOT in list: XXX_HIST & DCM_TODO
	for d in DCB DCC DCD DCJ DCM DCO FCS FCZ ; do
		func_complain_path_not_exist "${MY_DOC}/${d}" && continue

		opts="--exclude-from=${doc_ex_base}/exclude_${d}.txt" 
		src="${MY_DOC}/${d}/"
		tgt="${target}/${d}/"

		# rsync cares the last "/", should be the same, better ending with "/"
		func_info "DOC-RSYNC: ${src} -> ${tgt}"
		func_rsync_ask_then_run "${src}" "${tgt}" "${opts}"
	done
}

func_mydata_gen_fl(){
	local base fl_file fl_record fl_latest specified_name base_name
	base="${1}"
	specified_name="${2}"
	fl_record="${base}/alone/fl_record"
	fl_latest="${HOME}/amp/data/mydata/fl_latest"

	func_info "gen filelist for: ${base}"
	func_complain_path_not_exist "${base}" && return

	base_name="$(basename "${base}")"
	fl_file="${fl_record}/fl_${specified_name:-${base_name}}_$(func_dati).txt"

	# gen filelist
	[[ -e "${fl_record}" ]] || mkdir -p "${fl_record}"
	func_gen_filelist_with_size "${base}" "${fl_file}"

	# remove useless lines
	sed -i -e "
		/\.\(Trashes\|fseventsd\|Spotlight-V100\)\//d;
		/\/FCS\//d;
		/\/DCD\/mail\//d;
		/\/DCC\/coding\/leetcode\//d;
		/\/DCM.*\.\(gif\|jpg\|jpeg\|svg\|webp\|bmp\|png\|tiff\|tif\|heic\|aae\|mp4\|mov\|m4a\)/Id;
		" "${fl_file}"

	cp "${fl_file}" "${fl_latest}"
}

################################################################################

func_mydata_out_filter_del() {

	# TODO: use func_pipe_remove_lines instead
	sed -e  '
		# ignore whole dir
		/FCZ\/backup_DCS\//d;

		# not all dbackup should ignore, so need 3 lines
		/deleting FCZ\/backup_dbackup\/$/d;
		/deleting FCZ\/backup_dbackup\/2020/d;
		/deleting FCZ\/backup_dbackup\/201[0-9]/d;
		'
}

func_mydata_rsync_del_detect() {
	local del_list="$(func_rsync_del_detect "$@" | func_mydata_out_filter_del)"

	if [ -z "${del_list}" ] ; then 
		func_techo INFO "nothing need to delete manually"
	else
		func_techo WARN "Might NEED TO DELETE MANUALLY IN ${2}"
		echo "${del_list}" 
	fi
}

func_mydata_print_summary() {
	local tmp_log_file="${1}"

	echo -e "\nINFO: ======== FILE NEED MANUAL DELETE ========"
	#grep '^deleting ' "${tmp_log_file}" | func_mydata_out_filter_del	# not need, since already filtered
	grep '^deleting ' "${tmp_log_file}" | func_mydata_out_filter_del

	echo -e "\nINFO: ======== ERROR/WARN NEED HANDLE ========"
	sed -n -e '/ ERROR: /Ip;/ WARN: /Ip;/^rsync: /p;/^rsync error: /p;' "${tmp_log_file}"

	echo -e "\nINFO: detail log: ${tmp_log_file}"
}

func_mydata_rsync_with_list() {
	local src_base="${1}"
	local tgt_base="${2}"
	local sync_list="${3}"

	! df | grep -q "${tgt_base}" && func_techo info "skip ${tgt_base}, since not mount" && return 1
	! df | grep -q "${src_base}" && func_techo info "skip ${src_base}, since not mount" && return 1

	for d in ${sync_list} ; do
		func_complain_path_not_exist "${src_base}/${d}/" && return 1
		func_complain_path_not_exist "${tgt_base}/${d}/" && return 1

		func_techo INFO       "rsync: ${src_base}/${d}/ -> ${tgt_base}/${d}/"
		func_rsync_simple            "${src_base}/${d}/"  "${tgt_base}/${d}/"
		func_mydata_rsync_del_detect "${src_base}/${d}/"  "${tgt_base}/${d}/" 
	done
}

func_mydata_sync_extra() {
	# alone is common extra dir

	# only for dir record
	local TCZ_EXTRA_LIST="backup_rsync" 
	local DTZ_EXTRA_LIST="backup_unison" 
}

func_mydata_sync_tcatotcz() {
	[ "${HOSTNAME}" == "lapmac2" ] && func_is_dir_not_empty "${TCA_BASE}" && func_techo WARN "${TCA_BASE} should NOT mount on lapmac2" && return 1

	local TCA_SYNC_LIST="h8/actor h8/magzine h8/zptp dudu/course dudu/tv video/tv" 
	func_mydata_rsync_with_list "${TCA_BASE}" "${TCZ_BASE}" "${TCA_SYNC_LIST}" 
}

func_mydata_sync_tcbtotcz() {
	[ "${HOSTNAME}" == "lapmac2" ] && func_is_dir_not_empty "${TCB_BASE}" && func_techo WARN "${TCB_BASE} should NOT mount on lapmac2" && return 1

	local TCB_SYNC_LIST="h8/t2hh h8/movieRtcb" 
	func_mydata_rsync_with_list "${TCB_BASE}" "${TCZ_BASE}" "${TCB_SYNC_LIST}" 
}

func_mydata_sync_dtatodtz() {
	local DTA_SYNC_LIST="dudu/xiaoxue dudu/chuzhong dudu/gaozhong dudu/english"
	func_mydata_rsync_with_list "${DTA_BASE}" "${DTZ_BASE}" "${DTA_SYNC_LIST}" 
}

func_mydata_sync_dtbtodtz() { 
	echo "TODO TODO TODO TODO TODO: DTB无法放这么多子目录，后面也装不下"
	return 1
	local DTB_SYNC_LIST="" 
	func_mydata_rsync_with_list "${DTB_BASE}" "${DTZ_BASE}" "${DTB_SYNC_LIST}" 
}

func_mydata_sync_dtztotcz() {
	local DTZ_SKIP_LIST="video/documentary"
	func_techo info "SKIP: ${DTZ_SKIP_LIST}"

	local DTZ_SYNC_LIST="gigi video/course dudu/audio dudu/book dudu/documentary dudu/knowledge dudu/movie zz/talk zz/computer zz/outing"
	func_mydata_rsync_with_list "${DTZ_BASE}" "${TCZ_BASE}" "${DTZ_SYNC_LIST}" 
}

func_mydata_sync_note() {
	echo "ERROR: this function is ONLY for notes"
	return 1
	# Chain:
	#	TCA/TCB > TCZ	# h8 / alone
	#	DTA/DTB > DTZ	# dudu/(k12: xx,cz,gz,en)
	#	DTZ > TCZ	# ???
}

func_mute() {
	osascript -e "set volume with output muted"

	# Unmute volume
	# osascript -e "set volume without output muted"

	# check mute status
	# osascript -e "output muted of (get volume settings)"
}

# THIS MUST IN THE END OF SCRIPT
MYENV_LOAD_TIME="$(func_dati)"	# use this to indicate the loading time of the script


# Deprecated
func_backup_dated_OLD_VERSION() {
	local usage="Usage: ${FUNCNAME[0]} <source>"
	local desc="Desc: Currently only support backup up single target (file/dir)." 
	func_param_check 1 "$@"

	# check and prepare
	func_validate_path_exist "${1}" 
	local src_name src_path tgt_path tgt_base ex_fl passwd_str cmd_passwd_part cmd_ex_part cmd_info
	src_path="$(readlink -f "$1")"
	src_name="$(basename "${src_path%.zip}")"				# .zip will be added later (de-dup here)
	tgt_base="$(func_backup_dated_sel_target_base)"
	tgt_path="${tgt_base}/$(func_dati)_$(func_best_hostname)_${src_name}.zip"
	mkdir -p "${tgt_base}"

	# prepare password if available
	if func_is_cmd_exist func_gen_zip_passwd ; then
		passwd_str="$(func_gen_zip_passwd "${tgt_path}")"
		if [ -n "${passwd_str}" ] ; then 
			# NO ' inside "". WRONG: "--password '${passwd_str}'"
			cmd_passwd_part="--password ${passwd_str}"
		else
			echo "WARN: failed to gen password"
		fi
	fi

	# backup
	if [ -d "${src_path}" ] ; then

		# prepare exclude filelist
		ex_fl="$(func_backup_dated_gen_exclude_list "${src_path}")"
		if [ -s  "${ex_fl}" ] ; then
			# NO ' inside "". WRONG: x@'${ex_fl}'"				
			cmd_ex_part="-x@${ex_fl}" 
		fi

		# shellcheck disable=2086 # cmd_passwd_part must NOT use ""
		zip -r "${tgt_path}" "${src_path}" "${cmd_ex_part}" ${cmd_passwd_part} -x .DS_Store
		cmd_info="${cmd_passwd_part} ${cmd_ex_part}"
	else
		# shellcheck disable=2086 # cmd_passwd_part must NOT use ""
		zip "${tgt_path}" "${src_path}" ${cmd_passwd_part} 
		cmd_info="${cmd_passwd_part}"
	fi

	# echo result
	func_is_str_blank "${cmd_info}" && echo "INFO: no password or exclude list used." || echo "INFO: cmd param: ${cmd_info}"
	echo "INFO: $(find "${tgt_path}" -printf '%s\t%p\n' | numfmt --field=1 --to=si)"
}

func_backup_myenv_OLD_VERSION() { 
	local tmpDir="$(mktemp -d)"
	local packFile="${tmpDir}/myenv_backup.zip"
	local fileList=${MY_ENV_ZGEN}/collection/myenv_filelist.txt

	echo "INFO: create zip file based on filelist: ${fileList}"
	func_collect_myenv "no_content"

	# excludes: locate related db, ar.../fp... files in unison, duplicate collection
	zip -r "${packFile}"					\
		-x "*/zgen/mlocate.db" 				\
		-x "*/zgen/gnulocatedb" 			\
		-x "*/.unison/[fa][pr][0-9a-z]*"		\
		-x "*/zgen/collection/all_content.txt"		\
		-x "*/zgen/collection/code_content.txt"		\
		-x "*/zgen/collection/stdnote_content.txt"	\
		-@ < "${fileList}" 2>&1				\
	| sed -e '/^updating: /d;/^[[:blank:]]*adding: /d'	\
	|| echo "WARN: failed to pack some file, pls check"

	if [ ! -e "${packFile}" ] ; then
		func_die "ERROR: failed to zip files into ${packFile}"
	fi

	echo "INFO: bakcup command output, add to the backup zip"
	mkdir -p "${tmpDir}"
	df -h					> "${tmpDir}/cmd_output_df_h.txt"
	find ~ -maxdepth 1 -type l -ls		> "${tmpDir}/cmd_output_links_in_home.txt"
	find / -maxdepth 1 -type l -ls		> "${tmpDir}/cmd_output_links_in_root.txt"
	find ~/.zbox/ -maxdepth 1 -type l -ls	> "${tmpDir}/cmd_output_links_in_zbox.txt"

	pushd . &> /dev/null
	echo -e "\n${HOME}"			>> "${tmpDir}/cmd_output_git_remote.txt"
	\cd "${HOME}" && git remote -v		>> "${tmpDir}/cmd_output_git_remote.txt"

	if [ -e "${ZBOX}" ] ; then
		echo -e "\n${ZBOX}"			>> "${tmpDir}/cmd_output_git_remote.txt"
		\cd "${ZBOX}" && git remote -v		>> "${tmpDir}/cmd_output_git_remote.txt"
	fi
	if [ -e "${OUMISC}" ] ; then
		echo -e "\n${OUMISC}"			>> "${tmpDir}/cmd_output_git_remote.txt"
		\cd "${OUMISC}" && git remote -v	>> "${tmpDir}/cmd_output_git_remote.txt"
	else
		echo "INFO: ${OUMISC} NOT exist, skip"
	fi
	if [ -e "${OUREPO}" ] ; then
		echo -e "\n${OUREPO}"			>> "${tmpDir}/cmd_output_git_remote.txt"
		\cd "${OUREPO}" && git remote -v	>> "${tmpDir}/cmd_output_git_remote.txt"
	else
		echo "INFO: ${OUREPO} NOT exist, skip"
	fi

	\cd "${HOME}/.vim/bundle" &> /dev/null || echo "ERROR: failed to cd: ${HOME}/.vim/bundle"
	for f in * ; do 
		[ ! -d "${f}" ] && continue
		echo -e "\n${f}"		>> "${tmpDir}/cmd_output_git_remote.txt"
		\cd "${HOME}/.vim/bundle/${f}"	&> /dev/null || echo "ERROR: failed to cd: ${HOME}/.vim/bundle/${f}"
		git remote -v			>> "${tmpDir}/cmd_output_git_remote.txt"
	done

	zip -rjq "${packFile}" "${tmpDir}"/*.txt
	## gen exclude cmd part
	#ex_fl="$(func_backup_dated_gen_exclude_list "${source}")"
	#if [ -s  "${ex_fl}" ] ; then
	#	#cmd_ex_part="-x@'${ex_fl}'"				# NO ' inside, otherwise will be part of password!
	#	cmd_ex_part="-x@${ex_fl}" 
	#fi
	## TODO: delete: zip -r "${target}" "${source}" "${cmd_ex_part}" ${cmd_passwd_part} -x .DS_Store

	# passwd will be used if available
	func_backup_dated "${packFile}"

	local final_zip_list="$(mktemp)"
	unzip -l "${packFile}" > "${final_zip_list}"
	echo "INFO: final pack file list: ${final_zip_list}"

	echo "INFO: delete tmp pack file"
	rm "${packFile}"
	popd &> /dev/null
}

#func_mydata_sync_v2(){
#
#	# NOTE_BDTA_1	2023-05 new lapmac2 (the 2019 16 inch) can NOT recognize the 3.5" disk
#	#		2024-01 use ~exfat-fuse@osx works
#
#	# TODO: filter/summary rysnc result: func_rsync_out_filter_dry_run@lib
#	# TODO: wsl can NOT show utf-8
#	# TODO: tca/tcb/dta(G2TG)/dtb(MHD500) can be used for other thing?
#
#	local mnt_path btca_path bdta_path btca_list bdta_list tcz_path dtz_path mhd500_path dcm_hist_base
#
#	if [[ "${HOSTNAME}" == "laptp" ]] ; then	# note: driver is in lowercase in wsl1
#		mnt_path="/mnt/"
#		btca_path="${mnt_path}/o"		# 3.5" disk
#		bdta_path="${mnt_path}/p"		# 3.5" disk
#		tcz_path="${mnt_path}/r"
#		dtz_path="${mnt_path}/s"
#		#mhd500_path 				# laptp not need this
#	fi
#
#	if [[ "${HOSTNAME}" == "lapmac2" ]] ; then
#		mnt_path="/Volumes"
#		tcz_path="/tmp/tcz"
#		btca_path="/tmp/btca"			# 3.5" disk
#		bdta_path="${mnt_path}/bdta"		# 3.5" disk (see ~NOTE_BDTA_1)
#		dtz_path="${mnt_path}/DTZ"
#		mhd500_path="${mnt_path}/MHD500"
#	fi
#
#	func_mydata_bi_sync "${btca_path}" "${tcz_path}" "h8 dudu-chuzhong dudu-gaozhong"
#	func_mydata_bi_sync "${bdta_path}" "${dtz_path}" "gigi zz dudu video"
#
#	# only lapmac2 need sync doc (see ~STATUS_A)
#	if [[ "${HOSTNAME}" == "lapmac2" ]] ; then
#		[[ -d "${dtz_path}/backup_unison" ]] && func_unison_fs_run
#		[[ -d "${tcz_path}/backup_rsync"  ]] && func_mydata_sync_doc_rsync "${tcz_path}/backup_rsync"
#		[[ -d "${btca_path}/backup_rsync" ]] && func_mydata_sync_doc_rsync "${btca_path}/backup_rsync"
#		[[ -d "${bdta_path}/backup_rsync" ]] && func_mydata_sync_doc_rsync "${bdta_path}/backup_rsync"
#	fi
#
#	# RULE: DCM_HIST changes should happen in "${dcm_hist_base}" first! 
#	dcm_hist_base="${bdta_path}/backup_rsync/DCM_HIST/"
#	if [[ -d "${dcm_hist_base}" ]] ; then
#		[[ -d "${dtz_path}/backup_unison/DCM_HIST/" ]] && func_mydata_dcm_hist_sync "${dcm_hist_base}" "${dtz_path}/backup_unison/DCM_HIST/"
#		[[ -d "${tcz_path}/backup_rsync/DCM_HIST/"  ]] && func_mydata_dcm_hist_sync "${dcm_hist_base}" "${tcz_path}/backup_rsync/DCM_HIST/"
#		[[ -d "${btca_path}/backup_rsync/DCM_HIST/" ]] && func_mydata_dcm_hist_sync "${dcm_hist_base}" "${btca_path}/backup_rsync/DCM_HIST/"
#	fi
#
#	[[ "${1}" != "-nofl" ]] && [[ -e "${btca_path}" ]] && func_mydata_gen_fl "${btca_path}" "btca"
#	[[ "${1}" != "-nofl" ]] && [[ -e "${bdta_path}" ]] && func_mydata_gen_fl "${bdta_path}" "bdta"
#}

