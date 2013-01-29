@ECHO OFF

REM log record, in case need some rollback
ECHO Start to set env, before setting record: PATH=%PATH% >> zgen\win_gen.log

SET envVarCommon=%HOME%\.myenv\env_var
SET envVarWinCommon=%HOME%\.myenv\env_var_win

REM In a control env, prefer to use a blank init PATH var. In a non-control env, prefer to reserve old PATH
REM SET newPathEnv=%PATH%
SET newPathEnv=

REM Set platform specific stuff
For /f "tokens=* delims=" %%V in ('%HOME%\.myenv\util\win_ver.bat') Do (set WinVersion=%%V)
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

REM use both setx and set, since setx not effects current session
ECHO Setting PATH with value=%newPathEnv% (note, if want set on system level, use /M on VISTA or -M on XP)
%CmdSetX% PATH "%newPathEnv%"
set PATH="%newPathEnv%"

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

