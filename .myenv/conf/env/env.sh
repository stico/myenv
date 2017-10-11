#!/bin/bash

# DESC: gen bash alias and env variables

# Variable
base="$HOME/.myenv/conf/env"
secu_base="$HOME/.myenv/secu/"
genShPath="$HOME/.myenv/zgen/lu_bash"
genEnvVar=$genShPath/envVarAll
genEnvAlias=$genShPath/envAliasAll

# Check
! [ -e "${base}" ] && echo "ERROR: ${base} NOT exist, can NOT init alias/var" && exit 1
pushd "${base}" &> /dev/null

# Prepare
mkdir -p "${genShPath}" &> /dev/null
rm "${genShPath}"/* &> /dev/null

# Assemble
if [[ "$(uname -s)" == CYGWIN* ]] || [[ "$(uname -s)" == MINGW* ]] ; then
	# winVer=`cmd /C win_ver.bat`			# works in cygwin/bash, not in GIT/bash
	envVarSrc=(env_var env_var_win_cyg env_var_win)
	envAliasSrc=(env_alias env_alias_local ${secu_base}/env_alias_secu env_alias_win)
elif [[ "$(uname -s)" == Darwin* ]] ; then 
	envVarSrc=(env_var env_var_lu env_var_osx)
	envAliasSrc=(env_alias env_alias_local ${secu_base}/env_alias_secu env_alias_lu env_alias_osx)
else
	envVarSrc=(env_var_lu env_var)
	envAliasSrc=(env_alias env_alias_local ${secu_base}/env_alias_secu env_alias_lu)
fi
[[ -e $HOME/.myenv/secu/env_var_secu ]] && envVarSrc+=(secu/env_var_secu)
[[ -e $HOME/.myenv/secu/env_alias_secu ]] && envAliasSrc+=(secu/env_alias_secu)

# Gen env
for envFile in "${envVarSrc[@]}"
do
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
	    -e 's/^/export /' "$envFile" >> "$genEnvVar"
done
sed -i -e "0,/:\${PATH}/s///" "$genEnvVar"	# need PATH be clean, so first assignment should clean

# Gen alias
for aliasFile in "${envAliasSrc[@]}"
do
	[ -e "$aliasFile" ] || continue

	# shellcheck disable=2016
	sed -e '/^\s*#/d' \
	    -e '/^\s*$/d' \
	    -e 's/\([^A-Za-z0-9_]\)%/\1${/g' \
	    -e 's/%\([^A-Za-z0-9_]\)/}\1/g' \
	    -e 's/%\s*$/}/' \
	    -e 's/\t\t*/=/' \
	    -e 's/#/\//g' \
	    -e 's/^/alias /' "$aliasFile" >> "$genEnvAlias"
done

# seems need new line in the end
echo -e "\n" >> "$genEnvVar"
echo -e "\n" >> "$genEnvAlias"

. "$genEnvVar"
. "$genEnvAlias"

popd &> /dev/null
