#!/bin/bash
# shellcheck disable=2155,1090

################################################################################
# Install myenv
################################################################################
# $MY_ENV/myenv_init.sh for auto setup

################################################################################
# Source Dependencies
################################################################################
# Deprecated: single line self source
#source ${HOME}/.myenv/myenv_func.sh || source ./myenv_func.sh || eval "$(wget -q -O - "https://raw.github.com/stico/myenv/master/.myenv/myenv_func.sh")" || exit 1
#source $HOME/.myenv/myenv_lib.sh || source ./myenv_lib.sh || eval "$(wget -q -O - "https://raw.github.com/stico/myenv/master/.myenv/myenv_lib.sh")" || exit 1
# To simplify, just try myenv_lib.sh in myenv
MYENV_LIB_PATH="${HOME}/.myenv/myenv_lib.sh"
[ -f "${MYENV_LIB_PATH}" ] && source "${MYENV_LIB_PATH}"

################################################################################
# Constants
################################################################################
# Path
[ -z "$ZBOX" ]			&& ZBOX=$HOME/.zbox
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
[ -z "$MY_ROOTS_NOTE" ]		&& MY_ROOTS_NOTE=("$MY_DCC" "$MY_DCO" "$MY_DCD")
[ -z "$MY_ROOTS_CODE" ]		&& MY_ROOTS_CODE=("$MY_FCS/oumisc/oumisc-git" "$MY_FCS/ourepo/ourepo-git")
[ -z "$MY_NOTIFY_MAIL" ]	&& MY_NOTIFY_MAIL=focits@gmail.com

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
[ -z "$MY_JUMP_HOST" ]		&& MY_JUMP_HOST=dw
[ -z "$MY_JUMP_TRANSFER" ]	&& MY_JUMP_TRANSFER="~/amp/__transfer__"	# do NOT use $MY_ENV here
}

# Config
LOCATE_USE_FIND='true'		# seems tuned find is always a good choice (faster than mlocate on both osx/ubuntu). Ref: performance@locate
LOCATE_USE_MLOCATE='false'	# BUT also note the limit of the func_locate_via_find, which usually enough

################################################################################
# Functions
################################################################################
# shellcheck disable=2009
func_validate_user_proc() {
	func_param_check 1 "$@"

	ps -ef | grep "$1" | grep -v grep > /dev/null && return 0
	return 1
}

func_validate_user_name() {
	func_param_check 1 "$@"
	
	[ "$(whoami)" != "$*" ] && echo "ERROR: username is not $* !" && exit 1
}

func_validate_user_exist() {
	func_param_check 1 "$@"
	
	( ! grep -q "^$*:" /etc/passwd ) && echo "ERROR: user '$*' not exist!" && exit 1
}

func_validate_available_port() {
	func_param_check 1 "$@"
	
	[ "$(netstat -an | grep -c "$1" 2>/dev/null)" = "1" ] && func_die "ERROR: port $1 has been used!"
}

func_validate_cmd_exist() {
	func_param_check 1 "$@"

	( ! command -v "$1" &> /dev/null) && echo "ERROR: command '$1' not found (in PATH)" && exit 1
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

func_filter_comments() {
	func_param_check 1 "$@"

	sed -e "/^\s*#/d;/^\s*$/d" "$@"
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
	if [ "${MY_OS_NAME}" = "${OS_OSX}" ] ; then
		echo "${fullpath}" | tr -d '\n' | pbcopy
		echo "${fullpath}"
		return
	else
		# clipit: use -p or xclip to put in primary
		echo "${fullpath}" | tr -d '\n' | clipit -c &> /dev/null
		echo "${fullpath}" 
		return
	fi
}

func_to_clipboard() {
	# read from stdin
	#func_param_check 1 "$@"

	# put data into clipboard, each line as an entry
	while read -r line ; do echo "$line"
		if [ "${MY_OS_NAME}" = "${OS_OSX}" ] ; then
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
		for note_file in ${d}/note/*.txt ; do
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
		for dd in ${d}/* ; do
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
		for note_file in ${d}/note/*.txt ; do
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
		echo "WARN: content for selection is blank!" 1>&2
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

func_log() {
	local usage="Usage: ${FUNCNAME[0]} <level> <prefix> <log_path> <str>" 
	func_param_check 4 "$@"

	local level="$1"
	local prefix="$2"
	local log_path="$3"
	shift; shift; shift

	[ ! -e "$log_path" ] && mkdir -p "$(dirname "$log_path")" && touch "$log_path"

	echo "$(func_dati) $level [$prefix] $*" >> "$log_path"
}

func_log_info() {
	local usage="Usage: ${FUNCNAME[0]} <prefix> <log_path> <str>" 
	func_param_check 3 "$@"

	func_log "INFO" "$@"
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
	if [ "${MY_OS_NAME}" = "${OS_OSX}" ] ; then
		# pre condition: '+clientserver', 
		# -g mean use GUI version
		# directly use "vim -g" behaves wired (mess up terminal)
		#LD_LIBRARY_PATH="" /Users/ouyangzhu/.zbox/ins/macvim/macvim-git/MacVim.app/Contents/MacOS/Vim -g --servername SINGLE_VIM --remote-tab "$@"
		/Users/ouyangzhu/.zbox/ins/macvim/macvim-git/MacVim.app/Contents/MacOS/Vim -g --servername SINGLE_VIM --remote-tab "$@"
		return 0
	else	
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
	fi

	# Terminal mode: prefer vim if available, otherwise vi
	if [ -z "$DISPLAY" ] ; then
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
	locate -i --regex "${pattern}" | while read -r line; do
		case "${type}" in
			FILE)	[ -f "${line}" ] && echo "${line}" && return 0 ;;
			DIR)	[ -d "${line}" ] && echo "${line}" && return 0 ;;
			*)	echo "ERROR: func_locate_via_locate need a TYPE parameter! 1>&2"
		esac
	done
}

func_clean_less() {
	func_clean_cat "$@" | less
}

func_clean_grep() {
	local usage="Usage: ${FUNCNAME[0]} <grep_str> <file_path>" 
	func_param_check 2 "$@"
	
	local grep_str="${1}"
	shift
	func_clean_cat "$@" | grep "${grep_str}"
}

# some cmd like cless/cgrep are support via alias
func_clean_cat() {
	local usage="Usage: ${FUNCNAME[0]} <file_path>" 
	func_param_check 1 "$@"
	
	func_is_filetype_text "${1}" || func_die "ERROR: ${1} is NOT text file"
	sed -e '/^\s*$/d;
		/^\s*\(#\|"\|\/\/\)/d' "$@"
}

func_vi() {
	# shortcut - open a new one
	[ -z "$*" ] && func_vi_conditional && return 0

	# shortcut - only one parameter
	[ $# -eq 1 ] && [ -e "${1}" ] && func_vi_conditional "${1}" && return 0			# file exist
	[ $# -eq 1 ] && [[ "${1}" == *.* ]] && func_vi_conditional "${1}" && return 0		# in form of x.y like abc.txt

	# shortcut - only one tag, and exist
	local base="$(func_tag_value "${1}")"
	if [ $# -eq 1 ] ; then
		[ ! -e "${base}" ] && func_die "ERROR: ${base} not exist!"
		func_vi_conditional "${base}" && return 0 
	fi

	# Version 2, use locate 
	[ -d "$base" ] && shift || base="./"
	[ "$(stat -c "%d:%i" ${base})" == "$(stat -c "%d:%i" /)" ] && func_die "ERROR: base should NOT be root (/)"
	[ "$(stat -c "%d:%i" ${base})" == "$(stat -c "%d:%i" "${HOME}")" ] && func_die "ERROR: base should NOT be \$HOME dir"
	func_vi_conditional "$(func_locate "FILE" "${base}" "$@")"

	# Version 1, old .fl_me.txt
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

func_is_personal_machine() {
	#grep -q "^bash_prompt_color=green" "${SRC_BASH_HOSTNAME}" "${SRC_BASH_MACHINEID}" &> /dev/null 
	[ "${bash_prompt_color:-NONONO}" == "green" ] && return 0 || return 1
}

func_is_internal_machine() {
	func_ip_list | grep -q '[^0-9\.]\(172\.\|192\.\|fc00::\|fe80::\)' 
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

	# show vcs status: NOT show if jump from sub dir, BUT show for $HOME since most dir are its sub dir
	# change: the sub dir rule seems confusing, especially when there is symbolic links, or oumisc in zbox 
	#if [[ "${OLDPWD##$PWD}" = "${OLDPWD}" ]] || [[ "$PWD" = "$HOME" ]]; then
		[ -e ".hg" ] && command -v hg &> /dev/null && hg status
		[ -e ".svn" ] && command -v svn &> /dev/null && svn status
		[ -e ".git" ] && command -v git &> /dev/null && git status
	#fi

	# status code always success, otherwise func_cd_tag NOT work
	:
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
		func_notify_mail "ERROR: [MYENV Notify] cronlog has ERROR ($(hostname))!" "$errors"
	else
		echo "INFO: No err found in ${log}, not notificaton needed"
	fi
}

func_collect_statistics() {
	# MNT: stats of collect, to help reduce the file size

	local f 
	local base=$MY_ENV_ZGEN/collection

	for f in ${base}/* ; do
		echo "${f}"
		# TODO

		# use function in pipe
		#export -f func_param_check
		#export -f func_is_filetype_text
		#cat myenv_filelist.txt | xargs -n 1 -I{} bash -c 'func_is_filetype_text {} && wc -l {}' | sort -n | tee /tmp/2
	done
}

func_collect_myenv() {
	# extract alone as "func_grep_myenv" need update file list frequently
	# NOTE: myenv_content/myenv_filelist might duplicate with caller

	local myenv_content=${MY_ENV_ZGEN}/collection/myenv_content.txt
	local myenv_filelist=${MY_ENV_ZGEN}/collection/myenv_filelist.txt
	local myenv_git="$("cd" "$HOME" && git ls-files | sed -e "s+^+$HOME/+")"
	local myenv_addi="$(eval "$(sed -e "/^\s*$/d;/^\s*#/d;" "$MY_ENV_CONF/addi/myenv" | xargs -I{}  echo echo {} )")"

	[ -e "${myenv_filelist}" ] && func_delete_dated "${myenv_filelist}"
	[ -e "${myenv_content}" ] && [ "${1}" = "true" ] && func_delete_dated "${myenv_content}"

	for f in ${myenv_git} ${myenv_addi} ; do
		#[ ! -e "$f" ] && echo "WARN: file inexist: ${f}" && continue

		[ ! -e "$f" ] && continue
		echo "${f}" >> "${myenv_filelist}"

		[ "${1}" = "with_content" ] || continue
		func_is_filetype_text "${f}" || continue
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
		for f in $d/note/* ; do  
			local filename=${f##*/} 
			local dirname="${d}/note"
			local fullpath="${d}/note/${f#${dirname}}"

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
	if [ "${MY_OS_NAME}" = "${OS_OSX}" ] ; then
		mdfind -name NOTE | sed -e '/txt$/!d;/NOTE/!d;/\/amp\//d' >> "${miscnote_filelist}"
	else
		locate --regex "(/A_NOTE.*.txt|--NOTE.*txt)$" | sed -e "/\/amp\//d" >> "${miscnote_filelist}"
	fi
	while read -r line ; do
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
	"${code_filelist}" | while read -r line ; do
		func_is_filetype_text "${line}" || continue
		echo -e "\n\n@${line}\n"  >> "${code_content}"
		sed -e "s///" "${line}" >> "${code_content}"
	done
	echo "INFO: >> $(wc -l "${code_content}") lines"

	echo "INFO: collecting mydoc filelist"
	local mydoc_filelist=${base}/mydoc_filelist.txt
	#for d in DCB  DCC  DCD  DCM DCO  ECB  ECE  ECH  ECS  ECZ  FCS  FCZ ; do	# v1, deprecated
	#for d in DCB  DCC  DCD  DCM DCO  ECB  ECE  ECH  ECZ  ECS ; do			# v2, deprecated, put ECS in the end
	for d in DCB DCC DCD DCH DCM DCO DCS DCZ FCS ; do				# v3, compacted docs
		# shellcheck disable=2015
		( [ "${MY_OS_NAME}" = "${OS_OSX}" ]			\
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
		-e "/open.yy.com_trunk\//d" `# match prefix`		\
		-e "/\.\(gif\|jpg\|png\|tif\)$/Id" `# for DCM`		>> "${mydoc_filelist}"

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
		#-e "/\/appstore.yy.com_trunk\/framework\//d"		\
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
	find "$PWD" -name pom.xml | while read -r line ; do
		local d=$(dirname "$line")
		echo "INFO: cd $d && mvn clean"
		"cd" "$d" && mvn clean >> "$log" 2>&1
	done
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
	find "$src_path" -maxdepth 1 -type d | while read -r dir ; do 
		[ -n "$dir" ] && [ -e "$dir/.svn" ] && svn export "$dir/"  "$tmp_path/$(basename "$dir")"
	done

	# backup
	func_backup_dated "$tmp_path"
	[ -e "$tmp_path" ] && rm -rf "$tmp_path"
}

func_svn_update() { 
	[ -n "$1" ] && src_path="$1" || src_path="."

	# current dir is already project
	[ -e $src_path/.svn ] && svn update $src_path && return 0
	
	# projects are in subdir
	find $src_path -maxdepth 1 -type d | while read -r dir ; do 
		# suppress blank line and external file in output: svn update $dir/ | sed "/[Ee]xternal \(item into\|at revision\)/d;/^\s*$/d"
		[ -n "$dir" ] && [ -e "$dir/.svn" ] && svn update "$dir/" 
	done
	func_locate_updatedb
}

func_svn_status() { 
	svn status | sed -e '/^\s*$/d;/\s*X\s\+/d;/Performing status on external item at /d'
}

func_git_pull() { 
	git pull origin master && git status
	func_locate_updatedb
}

func_git_status() { 
	git status 	
}

func_git_commit_push() { 
	[ -n "$*" ] && comment="$*" || comment="update from $(hostname)"

	# git add -A: in git 2.0, will add those even not in current dir (which is what we want), just wait the 2.0
	git pull origin master			&&
	git add -A				&&
	git commit -a -m "$comment" 		&&
	git push origin				&&
	git status
	func_git_commit_check | sort
}

func_git_commit_check() { 
	for base in "$HOME" "$HOME/.zbox" "$HOME/Documents/FCS/oumisc/oumisc-git" "$HOME/.vim/bundle/vim-oumg" ; do 
		pushd "$base" &> /dev/null 
		git status | grep -q "nothing to commit, working directory clean"	\
		&& echo "NOT need update: $base"					\
		|| echo "NEED update: $base" 
		popd &> /dev/null 
	done
}

func_unison_fs_lapmac_all() {
	local mount_path="/Volumes/Untitled"

	# only works: 1) on osx, 2) in interactive mode
	[ "${MY_OS_NAME}" = "${OS_OSX}" ] || func_die "ERROR: this function only works on OSX"
	echo $- | grep -q "i" || func_die "ERROR: this function only works in interactive mode"

	# TODO: use 'diskutil list' to correctly find disk
	# try to find disk automatically (use the latest diskXs1, X > 0). NOTE: seems the --ignore "disk0s1" NOT really work
	local disk_path
	local disk_status="$(df -h)"
	local disk_candidates="$("ls" -t /dev/disk*s1 --ignore "disk0s1")"
	for disk_path in ${disk_candidates} ; do
		if echo "${disk_status}" | grep -q "${disk_path}" ; then
			echo "INFO: ${disk_path} alread mounted, try next"
			disk_path=""
		else
			echo "INFO: found! ${disk_path} is available"
			break
		fi
	done
	[ -z "${disk_path}" ] && echo "ERROR: can NOT find diskXs1 for mounting" && return 1

	# if path not empty AND not writable, need eject first (TODO: make the eject automatically?)
	func_is_dir_not_empty "${mount_path}" && [ ! -w "${mount_path}" ] && echo "ERROR: disk already mount in RO mode, pls eject first!" && return 1

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
			echo "ERROR: seems failed to mount disk, you may need to **RESTART** mac/osx!" 
			return 1
		fi
	fi

	unison fs_lapmac_all

	local answer
	echo "Do you want to umount disk? [Y/n]"
	read -r -e answer
	echo "${answer}" | grep -q "[nN]" || sudo umount "${mount_path}"
}

func_ssh_agent_init() {
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

func_scp_host_to_ip() {
	local usage="Usage: ${FUNCNAME[0]} [addr]" 
	func_param_check 1 "$@"

	func_str_not_contains "${1}" ":" && echo "${1}" && return 0

	echo "$(func_ip_of_host "${1%:*}"):${1#*:}"
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
	ssh ${ssh_via_jump_opts} "${MY_JUMP_HOST}" "ssh -p ${MY_PROD_PORT} ${ip_addr} $*"			# V1, simple version
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
		echo "WARN: NO dist_hosts could be found, NO distribution!"
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
	echo "WARN: not implemented yet!"
	# IPA: International Phonetic Alphabet (IPA), tells pronunciation of words
	# TODO: google api, IPA extraction: http://www.google.com/dictionary/json?callback=dict_api.callbacks.id100&q=example&sl=en&tl=en
}

func_translate_youdao() { 
	echo "WARN: not implemented yet!"
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
	echo -e "$*\t$res_simple\n\t$res_raw" >> "${MY_DCO}/english/translate/translate_history_$(hostname)"
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
	echo -e "$*\n\t$res_raw" >> "${MY_DCO}/english/translate/translate_history_$(hostname)"
}

func_delete_dated() { 
	local usage="Usage: ${FUNCNAME[0]} <path> <path> ..." 
	func_param_check 1 "$@" 

	local targetDir=$MY_TMP/delete/$(func_date)
	[ -e "${targetDir}" ] || mkdir -p "${targetDir}"

	local t_name=""
	for t in "$@" ; do
		[ ! -e "${t}" ] && echo "WARN: ${t} inexist, will NOT perform dated delete!" && continue

		t_name=$(basename "${t}")
		if [[ ${t_name} == .* ]] ; then 
			# make the dot start file visualable
			mv "${t}" "${targetDir}/dot_${t_name}_$(func_time)"
		else
			mv "${t}" "${targetDir}/${t_name}_$(func_time)"
		fi
	done
}

func_backup_myenv() { 
	local tmpDir="$(mktemp -d)"
	local packFile="${tmpDir}/myenv_backup.zip"
	local fileList=${MY_ENV_ZGEN}/collection/myenv_filelist.txt

	echo "INFO: create zip file based on filelist: ${fileList}"

	# excludes: locate related db, ar.../fp... files in unison
	zip -rq "${packFile}" -x "*/zgen/mlocate.db" -x "*/zgen/gnulocatedb" -x "*/.unison/[fa][pr][0-9a-z]*" -@ < "${fileList}" || func_die "ERROR: failed to zip files into ${packFile}"

	echo "INFO: bakcup command output, add to the backup zip"
	mkdir -p "${tmpDir}"
	df -h					> "${tmpDir}/cmd_output_df_h.txt"
	find ~ -maxdepth 1 -type l -ls		> "${tmpDir}/cmd_output_links_in_home.txt"
	find / -maxdepth 1 -type l -ls		> "${tmpDir}/cmd_output_links_in_root.txt"
	find ~/.zbox/ -maxdepth 1 -type l -ls	> "${tmpDir}/cmd_output_links_in_zbox.txt"
	\cd ${HOME} && git remote -v		>> "${tmpDir}/cmd_output_git_remote_info.txt"
	\cd ${HOME}/.zbox && git remote -v	>> "${tmpDir}/cmd_output_git_remote_info.txt"
	zip -rjq "${packFile}" "${tmpDir}"/*.txt

	func_backup_dated "${packFile}"
}

func_backup_dated() {
	local usage="Usage: ${FUNCNAME[0]} <source> <addi_bak_path>\n\tCurrently only support backup up single target (file/dir)." 
	func_param_check 1 "$@"

	local target target_path host_name
	local source="$(readlink -f "$1")"
	local source_name="$(basename "${source}")"
	local dcb_dated_backup="$MY_DCB/dbackup/latest"
	
	# backup path
	if func_is_personal_machine && [ -d "${dcb_dated_backup}" ]; then
		host_name="$(hostname)" 
		target_path="${dcb_dated_backup}"
	elif [ -d "${MY_ENV_DIST}" ] ; then
		host_name="$(func_ip_single)"
		tags="$(func_dist_tags)"
		target_path="${MY_ENV_DIST}/$(func_select_line "${tags}")/backup"
	else
		func_die "ERROR: can NOT decide where to backup!"
	fi

	# prepare and check
	mkdir -p "${target_path}"
	func_validate_path_exist "${source}" 

	# backup
	if [ -d "${source}" ] ; then
		target="${target_path}/$(func_dati)_${host_name}_${source_name}.zip"
		zip -r "${target}" "${source}"
	else
		target="${target_path}/$(func_dati)_${host_name}_${source_name}"
		cp -r "${source}" "${target}" 
	fi

	# addition backup
	[ -n "${2}" ] && cp -r "${target}" "${2}"

	# show
	"ls" -lh "${target}"
	[ -n "${2}" ] && "ls" -lh "${2}/$(basename "${target}")"
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
	#filename="$(basename ${file})"
	[ ! -e "${file}" ] && echo "ERROR: $file not exist!" && return 1

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
		echo "ERROR: can not run file $file !"
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
	for f in $base/todo_* ; do
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
	[ "$(echo "${target_file}" | wc -l)" -eq 1 ] && xdg-open "${target_file}" || echo "WARN: more than one file with suffix: ${file_suffix}, pls open manually!"
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
	func_monitor_fs "${watch_path}" | while read -r event ; do

		echo "INFO: $(func_dati): target updatd, event: ${event}"
		func_kill_self_and_descendants "${is_sudo_used}" "${pid}" || return 1

		# run command and record pid
		lastpid="${pid}"
		func_run_cmds_in_bg "${@}"
		pid=$!
		echo "${pid}" > "${pid_file}"

		# shellcheck disable=2009
		#echo "INFO: run cmd, lastpid=${lastpid} ($(ps -ef | grep -v grep | grep -q "[[:space:]]${lastpid}[[:space:]]" && echo "FAILED to kill!" || echo "killed")), curent pid=${pid}"
		echo "INFO: run cmd, lastpid=${lastpid} ($(func_is_pid_or_its_child_running "${lastpid}" && echo "FAILED to kill!" || echo "killed")), curent pid=${pid}"
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
	[ -n "${2}" ] && echo "ERROR: NOT support specify <path> yet!" && return 1

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
	[ -z "${port}" ] && echo "ERROR: failed to find idle port!" && return 1
	[ -f "${pid_file}" ] && func_is_running "${pid_file}" && echo "ERROR: rsync_tmp already running, pls check!" && return 1
	func_is_int_in_range "${ttl}" 10 2592000 || func_die "ERROR: TTL value NOT in ranage 10~2592000 (10s ~ 30days), NOT allowed!"

	# Run
	echo "INFO: run rsync server, cmd: rsync --daemon --port ${port} --config ${conf}"
	rsync --daemon --port "${port}" --config "${conf}"
	echo "INFO: run tmp rsync server, port: ${port}, base: ${base}, pid: $(cat ${pid_file} 2>/dev/null), log: ${log_file}"
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
	func_is_running "${pid_file}" && func_techo info "${name} backup already running, skip!" && exit 0
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
		func_techo error "backup ${name} (pid ${rsync_pid}) FAILED, pls check!" | tee -a "${log_file}" 
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
	func_contains_blank_str "${mount_path}" && func_die "ERROR: critical config NOT set, pls check (mount_path)"

	# umount
	if [ "${MY_OS_NAME}" = "${OS_OSX}" ] ; then
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
	func_contains_blank_str "${mount_path}" "${samba_path}" && func_die "ERROR: critical config NOT set, pls check (mount_path/samba_path)"

	# check
	mount_path="$(readlink -f "${mount_path}")"
	func_samba_is_mounted "${mount_path}" && echo "INFO: already mounted, at: ${mount_path}"

	# mount
	[ -d "${mount_path}" ] || mkdir -p "${mount_path}"
	if [ "${MY_OS_NAME}" = "${OS_OSX}" ] ; then
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

func_update_book_name() {
	local usage="USAGE: ${FUNCNAME[0]} <match_str> <target_str>" 
	local desc="Desc: rename books according to parameter" 
	func_param_check 2 "$@"

	local f
	for f in $(ls | grep "${1}.*\(pdf\|epub\|azw3\|mobi\)") ; do
		echo -e "${f}" "\t->\t" "${2}.${f##*.}"
		mv "${f}" "${2}.${f##*.}"
	done
	ls -l
}

func_export_script() {
	local usage="USAGE: ${FUNCNAME[0]} <function_name> <target_script>" 
	local desc="Desc: export a runnable script of <function_name> into <target_script>" 
	func_param_check 1 "$@"

	# TODO: support global VAR export

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
		type "${c}" | sed -e '1d' >> "${target}"
		fdone+=("${c}")
		ftodo=("${ftodo[@]:1}")
		func_decho "processing: ${c}, DONE: ${fdone[*]}, TODO: ${ftodo[*]}"

		# Recursive
		for f in $(type "${c}" | grep -o "func_[[:alnum:]_]*" | sort -u) ; do
			count=$(( count + 1 ))

			func_array_contans "${f}" "${fdone[@]}" "${ftodo[@]}" && continue
			ftodo+=("${f}")
			func_decho "found: ${f}"
		done
	done

	# Post process
	if [[ "${eresult}" = "success" ]] ; then
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
		echo "ERROR: export failed!"
	fi
}
