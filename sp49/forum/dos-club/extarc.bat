@echo off
echo EXTARC batch file. Version 3.11 (c) Computale Studio 1991, 92
rem --------------------------------------------------------------------
rem          Пакетный файл для распаковки архивов ZIP,LZH,ARJ,ICE,ARC.
rem            Вызов : extarc ext file
rem               ext  - расширение файла { zip,lzh,arj,ice,arc }
rem      		   (маленькими латинскими буквами!!!)
rem               file - имя архива без расширения
rem
rem     ВНИМАНИЕ!!! Для нормальной работы необходимо:
rem		     a) наличие разархиваторов lha,pkunzip,pkxarc,arj;
rem                  b) наличие сервисной утилиты whatnew;
rem --------------------------------------------------------------------
whatnew d
set tmp= %what%:
if %what% == A goto d1
if %what% == B goto d1
set tmp=..\
goto hd
:d1
whatnew c "Enter drive letter for extracting (Enter - Drive E) :  "
rem
if NOT %what%  == ~ goto Ch
set what=E
:Ch
echo Extracting on Drive %what%
%what%:
:hd
md %2
cd %2
goto %1
:zip 
pkunzip -d %tmp%%2 
GOTO QUIT
:lzh
lha x %tmp%%2 *.* 
goto quit
:arc
pkxarc -x %tmp%%2 
goto quit
:arj
arj x -y %tmp%%2 
goto quit
:ice
lha x %tmp%%2.ice *.* 
:quit
