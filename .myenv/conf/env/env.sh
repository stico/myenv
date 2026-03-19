#!/bin/bash
# shellcheck disable=1090,2164

# DESC: gen bash alias and env variables

# Variable
base="${HOME}/.myenv/conf/env"
penv="${HOME}/.myenv/secu/personal/env"
var_secu="${penv}/var_secu"
alias_secu="${penv}/alias_secu"
alias_local="${HOME}/.myenv/conf/addi/alias_local"
zgen_base="${HOME}/.myenv/zgen/lu_bash"
zgen_var_all="${zgen_base}/envVarAll"
zgen_var_path="${zgen_base}/envVarPath"
zgen_var_others="${zgen_base}/envVarOthers"
zgen_alias_all="${zgen_base}/envAliasAll"

# Check
! [ -e "${base}" ] && echo "ERROR: ${base} NOT exist, can NOT init alias/var" && exit 1
pushd "${base}" &> /dev/null

# Prepare, CMD_SED is prepared in ~/.bashrc
mkdir -p "${zgen_base}" &> /dev/null
rm "${zgen_base}"/* &> /dev/null
[ -z "${CMD_SED}" ] && CMD_SED="sed"

# Assemble
if [[ "$(uname -s)" == CYGWIN* ]] || [[ "$(uname -s)" == MINGW* ]] ; then
	envVarSrc=("${var_secu}" env_var env_var_win_cyg env_var_win)
	envAliasSrc=("${alias_secu}" env_alias "${alias_local}" env_alias_win)
elif [[ "$(uname -s)" == Darwin* ]] ; then 
	envVarSrc=("${var_secu}" env_var env_var_lu env_var_osx)
	envAliasSrc=("${alias_secu}" env_alias "${alias_local}" env_alias_lu env_alias_osx)
else
	envVarSrc=("${var_secu}" env_var env_var_lu)
	envAliasSrc=("${alias_secu}" env_alias "${alias_local}" env_alias_lu)
fi

# Gen env
for env_file in "${envVarSrc[@]}" ; do
	[ -e "$env_file" ] || continue

	# shellcheck disable=2016
	"${CMD_SED}" -e '/^[[:space:]]*#/d' \
	    -e '/^[[:space:]]*$/d' \
	    -e 's/%HOME%/${HOME}#/g' \
	    -e 's/\([^A-Za-z0-9_]\)%/\1${/g' \
	    -e 's/%\([^A-Za-z0-9_]\)/}\1/g' \
	    -e 's/%[[:space:]]*$/}/' \
	    -e 's/\t\t*/=/' \
	    -e 's/#/\//g' \
	    -e 's/[[:space:]]*$//' \
	    -e 's/^/export /' "$env_file" >> "$zgen_var_all"
done

# Gen var PATH. TODO: 有些检查是不是这里做比较好: 1) 路径要以"/"结尾，否则有些系统(如OSX)不会作为路径来搜索。2) 重复路径处理。
# 注: 用 func_combine_lines 来合并行时，有"${}"的行都消失了，在命令行下用这个函数则工作正常，只好用其它方式处理。暂时不清楚原因。
#"${CMD_SED}" -e '/PATH=/!d;s/^.*PATH=//;' "$zgen_var_all" | func_shrink_dup_lines | func_combine_lines -s ':' -n 888  | sed -e 's/^/export PATH=${PATH}:/' >> "$zgen_var_path"
"${CMD_SED}" -e '/PATH=/!d;s/^.*PATH=//;s/$/:/;' "$zgen_var_all" | tr -d '\n' | sed -e 's/^/export PATH=${PATH}:/;s/:$//;' >> "$zgen_var_path"

# Gen var others
"${CMD_SED}" -e "/PATH=/d" "$zgen_var_all" >> "$zgen_var_others"

# Gen alias
for alias_file in "${envAliasSrc[@]}" ; do
	[ -e "$alias_file" ] || continue

	"${CMD_SED}" -e '/^[[:space:]]*#/d' \
	    -e '/^[[:space:]]*$/d' \
	    -e 's/\([^A-Za-z0-9_]\)%/\1${/g' \
	    -e 's/%\([^A-Za-z0-9_]\)/}\1/g' \
	    -e 's/%[[:space:]]*$/}/' \
	    -e 's/\t\t*/=/' \
	    -e 's/#/\//g' \
	    -e 's/^/alias /' "$alias_file" >> "$zgen_alias_all"
done

# seems need new line in the end
echo -e "\n" >> "$zgen_var_path"
echo -e "\n" >> "$zgen_var_others"
echo -e "\n" >> "$zgen_alias_all"
source "$zgen_var_path"
source "$zgen_var_others"
source "$zgen_alias_all"

popd &> /dev/null
