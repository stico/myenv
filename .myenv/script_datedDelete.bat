@ECHO OFF
REM the .sh must use full path, and must use ' around %1, incase there are blanks
bash %MY_ENV%\script_datedDelete.sh %1
