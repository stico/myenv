@ECHO OFF
REM the .sh must use full path, and must use ' around %1, incase there are blanks
REM bash %MY_ENV_UTIL%\dated_delete.sh %1

REM After lots try, this the way to support chinese and blank in path
%MY_PRO%\A_System_Cygwin\bin\cygpath -u %1 | bash -c 'read -e target; source ${HOME}/.myenv/env_func_bash; func_delete_dated "${target}"'

