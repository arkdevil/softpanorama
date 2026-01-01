@echo off
if "%1"=="" goto help
if "%1"=="/?" goto help
set d=@
if "%1"=="A:" set d=A
if "%1"=="B:" set d=B
if "%1"=="A" set d=A
if "%1"=="B" set d=B
if "%1"=="a:" set d=A
if "%1"=="b:" set d=B
if "%1"=="a" set d=A
if "%1"=="b" set d=B
if "%d%"=="@" goto help
35mon /A%d%4 /R%d%4 /!
goto end
:help
echo.
echo Mount - utility for 35sec 
echo   1995 Pavel Machek
echo.
echo Syntax:
echo MOUNT [A:|B:]
echo.
echo   Starts caching of selected drive.
echo.
:end
