@ECHO OFF

REM set key=cd ; abc
REM set key=updatecd               "cd E:\dev\code_work/update-server_trunk"
REM set key=updatecd               "cd E:\dev\code_work/update-server_trunk | sed -e '/^\s*$/d;/^\(Fetching\|Updated\) external/d;' ; cd -"
set key=updatesvnupdate		"cd %MY_CODE_WORK%/update-server_trunk ; svn update | sed -e '/^\s*$/d;/^Updated external/d;/^Fetching external/d;' ; cd -"
echo "------------%key%"

CALL:FUNC_SET_ALIAS  %key%

:FUNC_SET_ALIAS
	echo %1
	echo %2
	echo %*
GOTO:EOF

pause
