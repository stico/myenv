@ECHO OFF
REM Problem: still crashing, still can not correctly handle |,||,^

SET envAliasCommon=%HOME%\.myenv\env_alias
SET envAliasSecu=%HOME%\.myenv\secu\env_alias_secu 
SET envAliasWin=%HOME%\.myenv\env_alias_win
SET genAliasPath=%HOME%\.myenv\zgen\win_alias

REM Init Alias, use .bat in PATH as win not really have alias. NOTE, goto the root driveer first!
CALL:FUNC_CHANGE_DRIVER %genAliasPath%
DEL /F /Q %genAliasPath%\*
MD %genAliasPath%
CD %genAliasPath%

FOR /f "tokens=* eol=# delims=;" %%k in (%envAliasCommon% %envAliasSecu% %envAliasWin%) do (
	echo "00000000000000000000000%%k"
	CALL:FUNC_SET_ALIAS %%k 
)
PAUSE
GOTO:EOF

:FUNC_SET_ALIAS
	ECHO "99999999999999999999999%*"
	SET aliasKey=%~1
	ECHO "=======================%aliasKey%"
	IF "%aliasKey%"=="" GOTO:EOF
	IF "%~2"=="" GOTO:EOF

	REM Filter contents
	SET valueTmp1=%2

	ECHO "11111111111111111111111%valueTmp1%"
	SET valueTmp2=%valueTmp1:|=^|%
	ECHO "22222222222222222222222%valueTmp2%"
	SET valueTmp3=%valueTmp2:&=^&%
	ECHO "33333333333333333333333%valueTmp3%"
	SET valueTmp4=%valueTmp3:#=\%
	ECHO "44444444444444444444444%valueTmp4%"

	CALL:FUNC_SET_ALIAS_Real %1 %valueTmp4%
GOTO:EOF

:FUNC_SET_ALIAS_Real
	SET aliasValue=%~2
	ECHO "-----------------------%aliasValue%"
	IF "%aliasValue%"=="" GOTO:EOF

	ECHO @ECHO OFF > %aliasKey%.bat
	IF "%aliasValue:~0,3%"=="cd " ( 
		CALL:FUNC_SET_ALIAS_CD %aliasKey% %aliasValue% 
	) ELSE (
		ECHO Create alias for %aliasKey% with: %aliasValue%
		REM %%* to pass in reminded arguments
		ECHO %aliasValue% %%* >> %aliasKey%.bat
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

:FUNC_CHANGE_DRIVER
	%~d1
GOTO:EOF

PAUSE
