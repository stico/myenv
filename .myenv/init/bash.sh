#!/bin/bash

# make it simple, we works under the .myenv dir
cd $HOME/.myenv

# var 
genShPath=zgen/lu_bash
genEnvVar=$genShPath/envVarAll
genEnvAlias=$genShPath/envAliasAll
genEnvFunc=$genShPath/envFuncAll

# need to ensure the HOME var end with a "/"
[[ $(echo $HOME | grep -c "/$") == 0 ]] && export HOME="${HOME}/"

# check if it is bash on windows
if [[ `uname -s` == CYGWIN* ]] || [[ `uname -s` == MINGW* ]] ; then
	# winVer=`cmd /C win_ver.bat`			# works in cygwin/bash, not in GIT/bash
	envVarSrc=(env_var_win_cyg env_var_win env_var_bash env_var)
	envFuncSrc=(env_func_bash)
	envAliasSrc=(env_alias env_alias_win)
else
	envVarSrc=(env_var_lu env_var_bash env_var)
	envFuncSrc=(env_func_bash)
	envAliasSrc=(env_alias env_alias_lu)
fi
[[ -e $HOME/.myenv/secu/env_alias_secu ]] && envAliasSrc+=(secu/env_alias_secu)

# even could directly set env, still better have file record left to trace
if [ ! -e $genShPath ] ; then
	mkdir -p $genShPath
fi
rm $genShPath/*

# gen env var
for envFile in "${envVarSrc[@]}"
do
	sed -e '/^\s*#/d' \
	    -e '/^\s*$/d' \
	    -e 's/%HOME%/${HOME}/g' \
	    -e 's/\([^A-Za-z0-9_]\)%/\1${/g' \
	    -e 's/%\([^A-Za-z0-9_]\)/}\1/g' \
	    -e 's/%\s*$/}/' \
	    -e 's/\t\t*/=/' \
	    -e 's/#/\//g' \
	    -e 's/\s*$//' \
	    -e 's/^PATH.*/&:${PATH}/' \
	    -e 's/^/export /' $envFile >> $genEnvVar
done
# need PATH be clean, so first assignment should clean
sed -i -e "0,/:\${PATH}/s///" $genEnvVar

# gen env alias
for aliasFile in "${envAliasSrc[@]}"
do
	sed -e '/^\s*#/d' \
	    -e '/^\s*$/d' \
	    -e 's/\([^A-Za-z0-9_]\)%/\1${/g' \
	    -e 's/%\([^A-Za-z0-9_]\)/}\1/g' \
	    -e 's/%\s*$/}/' \
	    -e 's/\t\t*/=/' \
	    -e 's/#/\//g' \
	    -e 's/^/alias /' $aliasFile >> $genEnvAlias
done

# gen env function
for funcFile in "${envFuncSrc[@]}"
do
	cat $funcFile >> $genEnvFunc
done

# seems need new line in the end
echo -e "\n" >> $genEnvVar
echo -e "\n" >> $genEnvFunc
echo -e "\n" >> $genEnvAlias

. $genEnvVar
. $genEnvFunc
. $genEnvAlias

cd $HOME
