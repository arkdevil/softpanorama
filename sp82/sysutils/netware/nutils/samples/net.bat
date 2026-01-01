@echo off
cls
c:
cd \net
ipx

ndosver
if errorlevel 5 goto DOS5
if errorlevel 4 goto DOS4

rem  Default to DOS 3.x
nxmsmem
if errorlevel 7  xmsnet3.exe
if not errorlevel 7 net3.exe
goto CONT

:DOS4
nxmsmem
if errorlevel 7  xmsnet4.exe
if not errorlevel 7 net4.exe
goto CONT

:DOS5
net5.exe
goto CONT

:CONT
cd\
echo .
if exist f:*.*         goto DRIVEF
if exist f:\public\*.* goto DRIVEF

:ERROR
echo .
echo    It was not possible to load the network drivers.
echo    Please reboot this work station to reset all drivers.
echo    If this problem persists then please call xxx-xxxx to
echo    report that you had problems logging onto the network.
echo .
goto EXIT

:DRIVEF
echo    Remember to keep your passwords secure.  Do not distribute.
echo    If a different Server denies you access then you must type
echo    Server/Loginname  at the Login prompt.  ei:   VENUS/SMITH
echo .
echo .
f:
login %1
goto EXIT

:EXIT
