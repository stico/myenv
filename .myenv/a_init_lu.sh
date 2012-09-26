#!/bin/sh

# make it simple, we works under the .myenv dir
cd $HOME/.myenv

# var 
genShPath=gen_lu_sh
genEnvVar=$genShPath/envVarAll
genEnvAlias=$genShPath/envAliasAll
genEnvFunc=$genShPath/envFuncAll

# need to ensure the HOME var end with a "/"
[[ ${HOME} =~ "*/" ]] || export HOME="${HOME}/" 

# check if it is bash on windows
if [[ `uname -s` == CYGWIN* ]] || [[ `uname -s` == MINGW* ]] ; then
	# winVer=`cmd /C script_getWinVersion.bat`	# this line works in cygwin/bash, not work in GIT/bash
	envVarSrc=(env_var env_var_win_common)
	envFuncSrc=(env_func_lu_sh)
	envAliasSrc=(env_alias script_a_secure/env_alias_secure env_alias_lu_sh env_alias_win)

	# vi complete seems very annoying (shows help of gawk!) on cygwin
	complete -r vi vim gvim unzip
else
	envVarSrc=(env_var env_var_lu env_var_lu_sh)
	envFuncSrc=(env_func_lu_sh)
	envAliasSrc=(env_alias script_a_secure/env_alias_secure env_alias_lu_sh)
fi

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
	    -e 's/\s\+#.*$//' \
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

cd -
