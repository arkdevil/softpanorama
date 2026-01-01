@echo off
mem
pause
cls
echo - 
echo BOXSWITCH  OFF
BOXSWITCH OFF
echo BOXSWITCH  ON
BOXSWITCH  ON
echo XMS
xms
echo - 
echo EMS
ems
echo - 
echo PIF
pif
pause
cls
echo - 
echo EDOS
edos
pause
cls
echo ALARM 3  "This could be your custom message!"
alarm 3 "This could be your custom message!"
echo An ALARM for 3 seconds has been set
pause
cls
boxtime
echo  The timer is starting
pause
boxtime
echo The timer has been stopped
pause
cls
date /?
date
time
pause
echo Running CHKDSK, note that it runs without the /F option
chkdsk  c:
echo - 
echo NOW running CHKDSK /F, Note that this is SAFE, because EDOS
echo is running and it WILL PREVENT chkdsk from running.
pause
chkdsk /f
pause
ver
echo - 
echo BACKGROUND
background
echo - 
echo EXCLUSIVE
exclusive
echo - 
echo BACKGROUND off
background off
echo - 
echo BACKGROUND ON
background on
dosmem /v
dosmem 10
edosexit
IF ERRORLEVEL 1  echo ERROR From dosmem 10 command. Detected by edosexit.
echo Switching to Windows and Clearing screen
pause
cls
WIN

