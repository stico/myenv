#!/bin/csh

# need to ensure the HOME var end with a "/"
[[ ${HOME} =~ "*/" ]] || export HOME="${HOME}/" 

# have no idea in which path this will be sourced, so need define the path
cd $HOME/.myenv

set genCshPath=gen_lu_csh

set genEnvVar=$genCshPath/envVarAll
set genEnvAlias=$genCshPath/envAliasAll
set envVarSrc=(env_var env_var_lu)
set envAliasSrc=(env_alias secure/env_alias_secure env_alias_lu_csh)

# hard for csh to read files line by line, so we need tmp files
if( ! -e $genCshPath ) then
	mkdir -p $genCshPath
endif
rm $genCshPath/*

# gen env var
foreach envFile ($envVarSrc)
	sed -e '/^\s*#/d;/^\s*$/d;s/\(\W\)%/\1${/g;s/%\(\W\|$\)/}\1/g;s/\s\+/ /;s/#/\//g;s/\s*$//;s/^PATH.*/&:${PATH}/;s/^/setenv /' $envFile >> $genEnvVar
end

# gen env alias
foreach envFile ($envAliasSrc)
	sed -e '/^\s*#/d;/^\s*$/d;s/\(\W\)%/\1${/g;s/%\(\W\|$\)/}\1/g;s/\s\+/ /;s/#/\//g;s/^/alias /' $envFile >> $genEnvAlias
end

source $genEnvVar
source $genEnvAlias

cd -
