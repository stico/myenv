@Echo off

Setlocal
For /f "tokens=2 delims=[]" %%G in ('ver') Do (set _version=%%G) 
For /f "tokens=2,3,4 delims=. " %%G in ('echo %_version%') Do (set _major=%%G& set _minor=%%H& set _build=%%I) 

REM Echo Major version: %_major%  Minor Version: %_minor%.%_build%
if "%_major%"=="5" goto sub5
if "%_major%"=="6" goto sub6

Echo unsupported version
goto:eof

:sub5
::Winxp or 2003
if "%_minor%"=="2" goto sub_2003
REM Echo Windows XP [%PROCESSOR_ARCHITECTURE%]
Echo XP
goto:eof

:sub_2003
REM Echo Windows 2003 or XP 64 bit [%PROCESSOR_ARCHITECTURE%]
goto:eof

:sub6
if "%_minor%"=="1" goto sub7
REM Echo Windows Vista or Windows 2008 [%PROCESSOR_ARCHITECTURE%]
Echo VISTA
goto:eof

:sub7
REM Echo Windows 7 or Windows 2008 R2 [%PROCESSOR_ARCHITECTURE%]
Echo WIN7
goto:eof

