@ECHO OFF

ECHO Writing Reg Entries for dated_backup/delete
REM No need to delete as used /f, the \"%%1\" is very important, which could handle blank in path
reg add HKEY_CLASSES_ROOT\*\shell\DBackup\command /f /t REG_EXPAND_SZ /ve /d "%%MY_ENV_UTIL%%\dated_backup.bat \"%%1\""
reg add HKEY_CLASSES_ROOT\Directory\shell\DBackup\command /f /t REG_EXPAND_SZ /ve /d "%%MY_ENV_UTIL%%\dated_backup.bat \"%%1\""
reg add HKEY_CLASSES_ROOT\*\shell\DDelete\command /f /t REG_EXPAND_SZ /ve /d "%%MY_ENV_UTIL%%\dated_delete.bat \"%%1\""
reg add HKEY_CLASSES_ROOT\Directory\shell\DDelete\command /f /t REG_EXPAND_SZ /ve /d "%%MY_ENV_UTIL%%\dated_delete.bat \"%%1\""

PAUSE


REM ------------------------------- Deprecated ------------------------------- 
REM reg delete HKEY_CLASSES_ROOT\*\shell\VersionBackup\command /f
REM reg delete HKEY_CLASSES_ROOT\*\shell\VersionBackup /f
REM reg delete HKEY_CLASSES_ROOT\Directory\shell\VersionBackup\command /f
REM reg delete HKEY_CLASSES_ROOT\Directory\shell\VersionBackup /f
REM C:\WINDOWS\system32\reg add HKEY_CLASSES_ROOT\*\shell\VersionBackup\command /f /t REG_EXPAND_SZ /ve /d "%%MY_ENV%%\script_backupWithVersion.bat \"%%1\""
REM C:\WINDOWS\system32\reg add HKEY_CLASSES_ROOT\Directory\shell\VersionBackup\command /f /t REG_EXPAND_SZ /ve /d "%%MY_ENV%%\script_backupWithVersion.bat \"%%1\""
REM reg add HKEY_CLASSES_ROOT\*\shell\VersionBackup\command /f /t REG_EXPAND_SZ /ve /d "%%MY_ENV%%\script_backupWithVersion.bat \"%%1\""
REM reg add HKEY_CLASSES_ROOT\Directory\shell\VersionBackup\command /f /t REG_EXPAND_SZ /ve /d "%%MY_ENV%%\script_backupWithVersion.bat \"%%1\""
REM reg add HKEY_CLASSES_ROOT\*\shell\DatedDelete\command /f /t REG_EXPAND_SZ /ve /d "%%MY_ENV%%\script_datedDelete.bat \"%%1\""
REM reg add HKEY_CLASSES_ROOT\Directory\shell\DatedDelete\command /f /t REG_EXPAND_SZ /ve /d "%%MY_ENV%%\script_datedDelete.bat \"%%1\""
