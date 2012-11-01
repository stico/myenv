@ECHO off

FOR /f "delims=" %%G in ('C:\Program_Files_2\A_A_Script-Basic\Common\GetWinVersion.bat') Do (SET _version=%%G) 
IF "%_version%"=="XP" goto SUB_XP
IF "%_version%"=="VISTA" goto SUB_VISTA
IF "%_version%"=="WIN7" goto SUB_WIN7

ECHO Nothing executed, check script error !
GOTO:EOF

:SUB_XP
ECHO Init XP specific ENV
ECHO -- Init env "HOME"
IF "%HOME%"=="" ( 
	ECHO ---- Setting HOME to D:\
	setx HOME D:\
) ELSE (
	ECHO ---- HOME already set to %HOME%, skip ...
)
GOTO SUB_COMMON

:SUB_VISTA
ECHO Init VISTA specific ENV
GOTO SUB_COMMON

:SUB_WIN7
ECHO Init WIN7 specific ENV
GOTO SUB_COMMON

:SUB_COMMON
ECHO Init COMMON ENV
ECHO ENV init finished
GOTO:EOF
