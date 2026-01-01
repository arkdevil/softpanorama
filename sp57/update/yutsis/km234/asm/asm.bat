@echo off
if .%1==. goto err
tasm %1
if not errorlevel 1  tlink /x %1
if not errorlevel 1  exe2bin %1
if not errorlevel 1  del %1.exe
del %1.obj
goto q
:err
echo:
echo Использование:  "asm <asm-файл_без_расширения>"
:q
echo: