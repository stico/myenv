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
zgen_alias_all="${zgen_base}/envAliasAll"

# Check
! [ -e "${base}" ] && echo "ERROR: ${base} NOT exist, can NOT init alias/var" && exit 1
pushd "${base}" &> /dev/null

# Prepare
mkdir -p "${zgen_base}" &> /dev/null
rm "${zgen_base}"/* &> /dev/null

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
	sed -e '/^\s*#/d' \
	    -e '/^\s*$/d' \
	    -e 's/%HOME%/${HOME}#/g' \
	    -e 's/\([^A-Za-z0-9_]\)%/\1${/g' \
	    -e 's/%\([^A-Za-z0-9_]\)/}\1/g' \
	    -e 's/%\s*$/}/' \
	    -e 's/\t\t*/=/' \
	    -e 's/#/\//g' \
	    -e 's/\s*$//' \
	    -e 's/^PATH.*/&:${PATH}/' \
	    -e 's/^/export /' "$env_file" >> "$zgen_var_all"
done
sed -i -e "0,/:\${PATH}/s///" "$zgen_var_all"	# need PATH be clean, so first assignment should clean

# Gen alias
for alias_file in "${envAliasSrc[@]}" ; do
	[ -e "$alias_file" ] || continue

	sed -e '/^\s*#/d' \
	    -e '/^\s*$/d' \
	    -e 's/\([^A-Za-z0-9_]\)%/\1${/g' \
	    -e 's/%\([^A-Za-z0-9_]\)/}\1/g' \
	    -e 's/%\s*$/}/' \
	    -e 's/\t\t*/=/' \
	    -e 's/#/\//g' \
	    -e 's/^/alias /' "$alias_file" >> "$zgen_alias_all"
done

# seems need new line in the end
echo -e "\n" >> "$zgen_var_all"
echo -e "\n" >> "$zgen_alias_all"
source "$zgen_var_all"
source "$zgen_alias_all"

popd &> /dev/null
