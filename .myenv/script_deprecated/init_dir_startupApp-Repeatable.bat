@echo off

REM variables
IF %1.==. (echo Error! Must set 1st parameter as target startup path. & GOTO END )
IF NOT EXIST %1 (echo Error! The %1 not exist, please check the path. & GOTO END )

REM Copy Others
copy C:\Program_Files_2\A_System_ClipX_1.0.3.8_Official-Basic\clipx.exe %1
copy C:\Program_Files_2\A_System_FindAndRunRobot_2.77.02_Official-Basic\FindAndRunRobot.exe  %1

REM Copy AHK Files
copy C:\Program_Files_2\Z_Configuration_AutoHotkey-Basic\Script\AltTab.ahk  %1
copy C:\Program_Files_2\Z_Configuration_AutoHotkey-Basic\Script\AutoCorrect.ahk  %1
copy C:\Program_Files_2\Z_Configuration_AutoHotkey-Basic\Script\MyHotString.ahk  %1
copy C:\Program_Files_2\Z_Configuration_AutoHotkey-Basic\Script\MySettings.ahk  %1

PAUSE

:END
