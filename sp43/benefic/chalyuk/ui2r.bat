@echo off
rem  -------------------------------------------------------------------------
rem
rem    Bat - файл для запуска UI PROGRAMER 2 с возможностью работы
rem    с русскими буквами
rem
rem NOTE: Используется SUPER MACS: Macro Processor 5.05
rem                    Copyright (c) 1987 by TurboPower Software
rem
rem       Файлы smacs.exe и ui2-rus.mac должны находится в том каталоге,
rem       из которого производится запуск UI PROGRAMER 2
rem
rem  -------------------------------------------------------------------------
smacs UI2-RUS.MAC
ui %1 %2 %3 %4 %5 %6 %7
smacs -u