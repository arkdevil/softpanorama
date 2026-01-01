@echo off
if not exist 002(s).com goto FORM1
if not exist tbg.exe goto FORM2
if not exist №.tbg goto FORM2
002(s).com 
tbg.exe
goto EXIT
:FORM1
echo Отсутствет файл  002(s).com 
goto EXIT
:FORM2
echo Отсутствует файл системы 
:EXIT
