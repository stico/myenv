@ECHO OFF

REM log record, in case need some rollback
ECHO Start to set env, before setting record: PATH=%PATH% >> z_log\log-win.txt

SET envVarCommon=%CD%\env_var
SET envVarWinCommon=%CD%\env_var_win_common
SET envAliasCommon=%CD%\env_alias
SET envAliasSecure=%CD%\script_a_secure\env_alias_secure 
SET envAliasWin=%CD%\env_alias_win
SET genAliasPath=%CD%\gen_win_alias
REM In a control env, prefer to use a blank init PATH var. In a non-control env, prefer to reserve old PATH
REM SET newPathEnv=%PATH%
SET newPathEnv=

REM Init ENV Var, PATH is special which only should set once
REM the eol=# makes lines with # will be ignored, batch also auto ignore blank line
FOR /f "tokens=* eol=# delims=;" %%k in (%envVarCommon% %envVarWinCommon%) do (
	CALL:FUNC_SET_ENV  %%k 
)
ECHO Setting PATH with value=%newPathEnv% (note, if want set on system level, use /M on VISTA or -M on XP)
"C:\Program Files\Support Tools\SETX" PATH "%newPathEnv%"


REM Init Alias, use .bat in PATH as win not really have alias
REM Maybe could backup the generated files instead of del
DEL /F /Q %genAliasPath%\*
CD %genAliasPath%
FOR /f "tokens=* eol=# delims=;" %%k in (%envAliasCommon% %envAliasSecure% %envAliasWin%) do (
	CALL:FUNC_SET_ALIAS  %%k 
)

ECHO Writing Reg Entries for VersionBackup
REM No need to delete as used /f, the \"%1\" is very important, which could handle blank in path
REM reg delete HKEY_CLASSES_ROOT\*\shell\VersionBackup\command /f
REM reg delete HKEY_CLASSES_ROOT\*\shell\VersionBackup /f
REM reg delete HKEY_CLASSES_ROOT\Directory\shell\VersionBackup\command /f
REM reg delete HKEY_CLASSES_ROOT\Directory\shell\VersionBackup /f
C:\WINDOWS\system32\reg add HKEY_CLASSES_ROOT\*\shell\VersionBackup\command /f /t REG_EXPAND_SZ /ve /d "%%MY_ENV%%\script_backupWithVersion.bat \"%%1\""
C:\WINDOWS\system32\reg add HKEY_CLASSES_ROOT\Directory\shell\VersionBackup\command /f /t REG_EXPAND_SZ /ve /d "%%MY_ENV%%\script_backupWithVersion.bat \"%%1\""

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
		"C:\Program Files\Support Tools\SETX" %key% %value%

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
	IF "%key:~0,2%"=="cd" ( 
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
