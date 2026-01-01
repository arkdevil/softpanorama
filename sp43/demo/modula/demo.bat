@echo off
rem Для полной демонстрации необходимо наличие следующих модулей :
rem часть 1
rem MPDEMO.EXE
rem MPDEMO.F16
rem MPDEMO.F14
rem MPDEMO.F8
rem MPDEMO.TRP
rem MPDEMO.LIT
rem MPDEMO.PCC
rem часть 2
rem DEMOLWS.EXE
rem MPDEMO.F8
echo  Демонстационная веpсия  Modula Plus Tools 2.0  Сopyright (C) 1991.
echo  часть 1 (основная)
echo  "Основные возможности пакета."
mpdemo.exe
cls
echo  Демонстационная веpсия  Modula Plus Tools 2.0  Сopyright (C) 1991.
echo  часть 2 (дополнительная)
echo  "Возможности модуля MpLWS"
demolws.exe
@echo on
