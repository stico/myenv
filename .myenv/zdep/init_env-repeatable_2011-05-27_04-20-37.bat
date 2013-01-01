@ECHO off

SET HOME_XP=D:\
SET HOME_VISTA=C:\Users\ezhuouy
SET ANT_HOME=C:\dev\ant-1.7.0
SET JAVA_HOME=C:\dev\jdk1.6.0_16
SET JAVA_PATH=%JAVA_HOME%\bin
REM SET JAVA_PATH_ToSet=^%JAVA_HOME^%\bin


ECHO Detecting system type ...
FOR /f "delims=" %%G in ('C:\Program_Files_2\A_A_Script-Basic\Common\GetWinVersion.bat') Do (SET _version=%%G) 
IF "%_version%"=="XP" goto SUB_XP
IF "%_version%"=="VISTA" goto SUB_VISTA
IF "%_version%"=="WIN7" goto SUB_WIN7
ECHO Nothing executed, check script error !
GOTO:EOF


:SUB_XP
ECHO Init XP specific ENV
SET HOME=%HOME_XP%
GOTO SUB_COMMON

:SUB_VISTA
ECHO Init VISTA specific ENV
CALL:FUNC_SET_ENV "TEST"
ECHO back from FUNC
ECHO %HOME_VISTA%
GOTO SUB_COMMON

:SUB_WIN7
ECHO Init WIN7 specific ENV
GOTO SUB_COMMON

:SUB_COMMON
ECHO Init COMMON ENV

ECHO %HOME% | %SYSTEMROOT%\system32\find "%HOME%" > nul
IF ERRORLEVEL 1 (
	ECHO ---- Setting HOME to %HOME%
	setx HOME %HOME%
) ELSE (
	ECHO ---- HOME already set to %HOME%, skip ...
)

ECHO %PATH% | %SYSTEMROOT%\system32\find "%JAVA_PATH%" > nul
IF ERRORLEVEL 1 (
	ECHO ---- Setting JAVA_HOME to %JAVA_PATH%
) ELSE (
	ECHO ---- JDK already set, skip ...
)
ECHO ENV init finished
PAUSE
GOTO:EOF

:FUNC_SET_ENV
ECHO in FUNC
GOTO:EOF
