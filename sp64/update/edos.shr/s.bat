@echo off
cls
echo.
echo.

echo The self extracting unpack of EDOS is complete.
echo In order to install edos, you must be running Windows
testunpk
if ERRORLEVEL 3 goto winx

echo Since Windows is not running start it now: Win/3  A: or B:\SETUP
goto ok
:winx
echo Since Windows is running, exit this DOS session and,
echo From the File/RUN menu item run "A: or B:\SETUP
echo.

:ok
echo Use A: or B: but not both, example: A:\SETUP.

Pause

