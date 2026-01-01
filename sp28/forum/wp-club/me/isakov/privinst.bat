@echo off
echo .
echo Приватная установка ПОЛЕЗНЫХ_ДОПОЛНЕНИЙ без изменения настройки

if .%1. == .. goto c1
if .%2. == .. goto c1
  goto c11
:c1
  echo  PRIVINST C:\ME  D:\USERS\MYDIR
  echo - Нужно указать полные пути к Multi-Edit и к своему рабочему каталогу
  goto Quit
:c11

if exist %1\MeMac.EXE goto c12
  echo Нет компилятора %1\MeMac.EXE  Проверьте PATH
  goto Quit
:c12

if exist %1\ME.EXE goto c14
  echo Нет самого редактора %1\ME.EXE Проверьте PATH
  goto Quit
:c14

if exist %2\quickref.!hl goto c2
  if not exist %2\quickref.hlp goto c2
    ren %2\quickref.hlp quickref.!hl
    echo %2\QuickRef.HLP  переименован в  %2\QuickRef.!HL
:c2

copy quickref.hlp %2 > nul

if exist %2\startup.!ma goto c21
  if not exist %2\startup.mac goto c21
    ren %2\startup.mac startup.!ma
    echo %2\Startup.MAC  переименован в  %2\Startup.!MA
:c21

%1\memac -p%2 startup2.src
if errorlevel 1 goto err

%1\memac -p%1 keypad
if errorlevel 1 goto err

%1\memac -p%1 extens
if errorlevel 1 goto err

echo .
echo ПОЛЕЗНЫЕ_ДОПОЛНЕНИЯ будут работать только из каталога %2\
echo Для отмены дополнений удалите файлы:
echo         %2\Startup.MAC
echo         %2\QuickRef.HLP
goto Quit

:err
  echo .
  echo Установка не завершена, были ошибки!!
:Quit
