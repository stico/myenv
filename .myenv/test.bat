@ECHO OFF


For /f "tokens=* delims=" %%V in ('script_getWinVersion.bat') Do (set WinVersion=%%V)
echo "Current win version is: %WinVersion%"



pause
