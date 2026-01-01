@echo off
menu 5 10 $1F $1E $4F $71 "Menu Test" "Item # 1" "Item # 2" "Item # 3"
if errorlevel 3 goto i3
if errorlevel 2 goto i2
if errorlevel 1 goto i1
echo You don't choose any item!
goto exit
:i1
echo You choose Item 1
goto exit
:i2
echo You choose Item 2
goto exit
:i3
echo You choose Item 3
:exit
 
