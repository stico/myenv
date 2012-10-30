@ECHO OFF

REM log record, in case need some rollback
ECHO Start to set env, before setting record: PATH=%PATH% >> gen_log\log-win.txt

SET envVarCommon=%HOME%\.myenv\env_var
SET envVarWinCommon=%HOME%\.myenv\env_var_win_common
SET envAliasCommon=%HOME%\.myenv\env_alias
SET envAliasSecure=%HOME%\.myenv\secure\env_alias_secure 
SET envAliasWin=%HOME%\.myenv\env_alias_win
SET genAliasPath=%HOME%\.myenv\gen_win_alias
REM In a control env, prefer to use a blank init PATH var. In a non-control env, prefer to reserve old PATH
REM SET newPathEnv=%PATH%
SET newPathEnv=

REM Set platform specific stuff
For /f "tokens=* delims=" %%V in ('script_getWinVersion.bat') Do (set WinVersion=%%V)
ECHO Current win version is: %WinVersion%. 
IF "%WinVersion%"=="WIN7-64bit" SET envVarWinWordLength=%HOME%\.myenv\env_var_win_64bit
IF "%WinVersion%"=="WIN7-32bit" SET envVarWinWordLength=%HOME%\.myenv\env_var_win_32bit
ECHO Using platform var: %envVarWinWordLength%
IF "%WinVersion:~0,2%"=="XP" SET CmdSetX="C:\Program Files\Support Tools\SETX" 
IF "%WinVersion:~0,4%"=="WIN7" SET CmdSetX=setx
ECHO Setting setx path: %CmdSetX% 

REM Init ENV Var, PATH is special which only should set once
REM the eol=# makes lines with # will be ignored, batch also auto ignore blank line
FOR /f "tokens=* eol=# delims=;" %%k in (%envVarCommon% %envVarWinWordLength% %envVarWinCommon%) do (
	CALL:FUNC_SET_ENV  %%k 
)
ECHO Setting PATH with value=%newPathEnv% (note, if want set on system level, use /M on VISTA or -M on XP)
%CmdSetX% PATH "%newPathEnv%"


REM Init Alias, use .bat in PATH as win not really have alias
REM Maybe could backup the generated files instead of del
DEL /F /Q %genAliasPath%\*
CD %genAliasPath%
FOR /f "tokens=* eol=# delims=;" %%k in (%envAliasCommon% %envAliasSecure% %envAliasWin%) do (
	CALL:FUNC_SET_ALIAS  %%k 
)

ECHO Writing Reg Entries for VersionBackup and DatedDelete
REM No need to delete as used /f, the \"%1\" is very important, which could handle blank in path
REM reg delete HKEY_CLASSES_ROOT\*\shell\VersionBackup\command /f
REM reg delete HKEY_CLASSES_ROOT\*\shell\VersionBackup /f
REM reg delete HKEY_CLASSES_ROOT\Directory\shell\VersionBackup\command /f
REM reg delete HKEY_CLASSES_ROOT\Directory\shell\VersionBackup /f
REM C:\WINDOWS\system32\reg add HKEY_CLASSES_ROOT\*\shell\VersionBackup\command /f /t REG_EXPAND_SZ /ve /d "%%MY_ENV%%\script_backupWithVersion.bat \"%%1\""
REM C:\WINDOWS\system32\reg add HKEY_CLASSES_ROOT\Directory\shell\VersionBackup\command /f /t REG_EXPAND_SZ /ve /d "%%MY_ENV%%\script_backupWithVersion.bat \"%%1\""
reg add HKEY_CLASSES_ROOT\*\shell\VersionBackup\command /f /t REG_EXPAND_SZ /ve /d "%%MY_ENV%%\script_backupWithVersion.bat \"%%1\""
reg add HKEY_CLASSES_ROOT\Directory\shell\VersionBackup\command /f /t REG_EXPAND_SZ /ve /d "%%MY_ENV%%\script_backupWithVersion.bat \"%%1\""
reg add HKEY_CLASSES_ROOT\*\shell\DatedDelete\command /f /t REG_EXPAND_SZ /ve /d "%%MY_ENV%%\script_datedDelete.bat \"%%1\""
reg add HKEY_CLASSES_ROOT\Directory\shell\DatedDelete\command /f /t REG_EXPAND_SZ /ve /d "%%MY_ENV%%\script_datedDelete.bat \"%%1\""

ECHO Updating file association
%MY_ENV%\script_fileAssoc-repeatable.bat

PAUSE
GOTO:EOF


:FUNC_SET_ENV
	SET key=%~1
	SET valueTmp=%~2
	SET value=%valueTmp:#=\%

	IF "%key%"=="" GOTO:EOF
	IF "%value%"=="" GOTO:EOF

	IF %key%.==PATH. (
		CALL:FUNC_SET_ENV_PATH %value%
	) ELSE (
		REM IF DEFINED %key% echo %KEY% Var Already Defined 

		ECHO Setting variable with key=%key%, value=%value%
		%CmdSetX% %key% "%value%"

		REM set the local variable as setx will effect in next cmd but subsequencial definition might need it
		SET %key%=%value%
	)
GOTO:EOF

:FUNC_SET_ENV_PATH
	REM seems not really works for all path: SET test=%~$PATH:1
	REM but following way works ...
	ECHO %newPathEnv% | %SYSTEMROOT%\system32\find "%1" > nul
	IF ERRORLEVEL 1 (
		ECHO Appending PATH with value=%value%
		SET newPathEnv=%value%;%newPathEnv%
	) ELSE ( 
		ECHO PATH already contains %value%
	)
GOTO:EOF

:FUNC_SET_ALIAS
	SET key=%~1
	SET valueTmp1=%~2
	SET value=%valueTmp1:#=\%

	IF "%key%"=="" GOTO:EOF
	IF "%value%"=="" GOTO:EOF

	ECHO @ECHO OFF > %key%.bat
	IF "%value:~0,3%"=="cd " ( 
		CALL:FUNC_SET_ALIAS_CD %key% %value% 
	) ELSE (
		ECHO Create alias for %key% with: %value%
		REM %%* to pass in reminded arguments
		ECHO %value% %%* >> %key%.bat
	)
GOTO:EOF

REM need special treat as the root driver must correct
:FUNC_SET_ALIAS_CD
	ECHO Create alias for %key% with: %value%

	SET key=%1
	SET valueTmp=%~2
	SET driver=%~d2
	SET value=%value:cd =%

	IF "%value:~1,1%"==":" ( 
		ECHO %driver% >> %key%.bat
	)
	ECHO cd %value% >> %key%.bat
GOTO:EOF
