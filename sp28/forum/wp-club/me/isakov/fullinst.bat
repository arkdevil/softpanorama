@echo off
echo .
echo Полная установка ПОЛЕЗНЫХ_ДОПОЛНЕНИЙ с заменой предыдущей настройки

if not .%1. == .. goto c1
  echo  FULLINST C:\ME  - нужно указать полный путь к каталогу Multi_Edit
  goto Quit
:c1
  if exist %1\MeMac.EXE goto c2
    echo Нет компилятора %1\MeMac.EXE  Проверьте PATH
    goto Quit
  :c2

  if exist %1\ME.EXE goto c3
    echo Нет самого редактора %1\ME.EXE Проверьте PATH
    goto Quit
  :c3

  echo .
  echo Старые файлы будут переименованы в %1\*.!*
  echo Например  %1\Init.MAC == %1\Init.!MA
  echo .

  if exist %1\QuickRef.!HL goto c31
    if exist %1\QuickRef.HLP ren %1\QuickRef.HLP QuickRef.!HL
    if errorlevel 1 goto Fin
  :c31

  copy QuickRef.HLP %1\QuickRef.HLP > nul
  if errorlevel 1 goto Fin

  if exist %1\Init.!MA goto c32
    copy %1\Init.MAC %1\Init.!MA > nul
    if errorlevel 1 goto Fin
  :c32

  if exist %1\Init.!SR goto c33
    if exist %1\Init.SRC ren %1\Init.SRC Init.!SR
    if errorlevel 1 goto Fin
  :c33

  if exist %1\KeyMap.!ME goto c34
    if exist %1\KeyMap.ME ren %1\KeyMap.ME KeyMap.!ME
    if errorlevel 1 goto Fin
  :c34

  copy KeyMap.ME %1\KeyMap.ME > nul
  if errorlevel 1 goto Fin

  %1\memac AutoSet
  if not errorlevel 1 goto c4
    echo %1\memac Что-то тут не так!
    goto Fin
  :c4

  %1\me.exe
  if not errorlevel 1 goto c5
    echo %1\me.exe Что-то тут не так!
    del startup.mac
    goto Fin
  :c5

  del startup.mac
  if errorlevel 1 goto Fin

  if exist %1\Startup.!MA goto c6
    if exist %1\Startup.MAC ren %1\Startup.MAC Startup.!MA
    if errorlevel 1 goto Fin
  :c6

  %1\memac -p%1 Startup1
  if errorlevel 1 goto Fin

  if exist %1\KeyPad.!MA goto c62
    if exist %1\KeyPad.MAC ren %1\KeyPad.MAC KeyPad.!MA
    if errorlevel 1 goto Fin
  :c62

  %1\memac -p%1 keypad
  if errorlevel 1 goto Fin

  if exist %1\Extens.!MA goto c64
    if exist %1\Extens.MAC ren %1\Extens.MAC Extens.!MA
    if errorlevel 1 goto Fin
  :c64

  %1\memac -p%1 extens
  if errorlevel 1 goto Fin

  echo .
  echo Установка завершена. Теперь Вы можете использовать ПОЛЕЗНЫЕ_ДОПОЛНЕНИЯ
  echo Для отмены установки используйте UnInst.BAT
  echo .
  goto Quit

:Fin
  echo .
  echo Установка не завершена
  echo .

:Quit
