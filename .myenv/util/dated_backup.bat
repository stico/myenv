@ECHO OFF
REM the .sh must use full path, and must use ' around %1, incase there are blanks
bash %MY_ENV%\utilities\dated_backup.sh %1
PAUSE
