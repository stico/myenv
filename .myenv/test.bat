@ECHO OFF


For /f "tokens=* delims=" %%V in ('script_getWinVersion.bat') Do (set WinVersion=%%V)
echo "Current win version is: %WinVersion%"

IF "%WinVersion:~0,2%"=="XP" SET CmdSetX=setx 
IF "%WinVersion:~0,4%"=="WIN7" SET CmdSetX="C:\Program Files\Support Tools\SETX" 
ECHO Setting setx path: %CmdSetX% 


pause
