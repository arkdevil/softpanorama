@echo off

@ISWIN
@IF NOT ERRORLEVEL 3 goto nowin1
background ON
win
:nowin1

rem !!! change nmake to something that will take 20 to 100 seconds to complete
nmake

@IF ERRORLEVEL 1 GOTO LINK_FAILED 
@ISWIN
@IF ERRORLEVEL 3 ALARM 1 "Link and Compile Have Completed"

@GOTO OK

:LINK_FAILED
@ISWIN
@IF ERRORLEVEL 3 ALARM 1 "Link and compile failed"
:OK
