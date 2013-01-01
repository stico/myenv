@echo off

REM Problem 1: not sure how reliable of the "value already exits" check, as not understand the code
REM Problem 2: the path value with or without "\" in the end might different (e.g. check might fail)

REM This script is used to set the environment variable, var name & value is necessary as input parameter

REM Parameter Check
IF "%1"=="" ( ECHO Error! must specify the 1st parameter as env var name. & GOTO END )
IF "%2"=="" ( ECHO Error! must specify the 2nd parameter as env var value. & GOTO END )

REM Check if already exist
SET result=%~dp$PATH:1 
SET spath=%1
IF "%result:~0,4%."=="%spath:~0,4%." ( ECHO Path already in environment variable, nothing added & GOTO END)


!!!! Must firstly check or remove, as this file need "repeatable"

REM add into env
ECHO Path not in environment variable, will set it.
REM ??????????????? use setx do the real set

:END
