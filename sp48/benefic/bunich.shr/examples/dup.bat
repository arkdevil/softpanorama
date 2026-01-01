@echo off
echo y | del c:\w\*.*
echo Поставьте ИСХОДНУЮ дискету на %1: и нажмите ENTER...
pause
xcopy %1:\*.* c:\w\ /s
echo Поставьте ВЫХОДНУЮ дискету на %1: и нажмите ENTER...
pause
xcopy c:\w\*.* %1: /s
