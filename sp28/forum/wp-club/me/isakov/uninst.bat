@echo off
echo .
echo Отмена установки ПОЛЕЗНЫХ_ДОПОЛНЕНИЙ

if not .%1. == .. goto c1
  echo  UNINST C:\ME  - нужно указать полный путь к каталогу Multi_Edit
  goto Quit
:c1
if not exist %1\init.mac goto BadPath

echo Очень жаль, что Вам не понравилось
echo .

if not exist %1\quickref.!hl goto c2
  if exist %1\quickref.hlp del %1\quickref.hlp
  ren %1\quickref.!hl  quickref.hlp
  goto c22
:c2
  echo Нет старой копии файла %1\quickref.hlp
:c22

if not exist %1\keymap.!ME goto c3
  if exist %1\keymap.ME del %1\keymap.ME
  ren %1\keymap.!ME  keymap.ME
  goto c33
:c3
  echo Нет старой копии файла %1\KeyMap.ME
:c33

if not exist %1\Init.!SR goto c4
  if exist %1\Init.SRC del %1\Init.SRC
  ren %1\Init.!SR  Init.SRC
  goto c44
:c4
  echo Нет старой копии файла %1\Init.SRC
:c44

if not exist %1\Init.!MA goto c5
  if exist %1\Init.MAC del %1\Init.MAC
  ren %1\Init.!MA  Init.MAC
  goto c55
:c5
  echo Нет старой копии файла %1\Init.MAC
:c55

if not exist %1\KeyPad.!MA goto c6
  if exist %1\KeyPad.MAC del %1\KeyPad.MAC
  ren %1\KeyPad.!MA  KeyPad.MAC
  goto c66
:c6
  echo Нет старой копии файла %1\KeyPad.MAC
:c66

if exist %1\Startup.MAC del %1\Startup.MAC
if not exist %1\Startup.!MA goto c7
  ren %1\Startup.!MA  Startup.MAC
  goto c77
:c7
  echo Нет старой копии файла %1\Startup.MAC
:c77

if not exist %1\Extens.!MA goto c8
  if exist %1\Extens.MAC del %1\Extens.MAC
  ren %1\Extens.!MA  Extens.MAC
  goto c88
:c8
  echo Нет старой копии файла %1\Extens.MAC
:c88
  goto Quit

:BadPath
  echo %1\*.mac - Проверьте как Вы указали путь

:Quit
