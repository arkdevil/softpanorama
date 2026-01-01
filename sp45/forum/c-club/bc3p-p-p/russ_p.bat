@echo off
echo Сейчас мы научим Ваш Borland C++ 3.0 понимать русскую букву "р"!
echo:
echo                    Нажмите любую клавишу...
echo:
pause >nul
if exist tcconfig.tc goto ok1
  echo Не найден конфигурационный файл TCCONFIG.TC!
  goto error
:ok1
if exist temc.exe goto ok2
  echo Не найден компилятор макросов TEMC.EXE!
  goto error
:ok2
if exist russ_p.tem goto ok3
  echo Не найден файл RUSS_P.TEM!
  goto error
:ok3
if exist bc.com goto ok4
  echo Не найдена программка BC.COM!
  goto error
:ok4
if exist bc.exe goto ok5
  echo Не найден файл BC.EXE!
  goto error
:ok5

temc russ_p.tem tcconfig.tc

echo:
echo Теперь, чтобы Ваш Borland C++ работал нормально, он должен загружаться
echo программой BC.COM. Поэтому не запускайте его как BC.EXE - набирайте просто: BC
echo:
pause >nul
goto exit
  
:error
echo:
echo В текущей директории должны находиться файлы:
echo    BC.EXE      (среда Borland C++ 3.0)
echo    TCCONFIG.TC (ее конфигурационный файл)
echo    TEMC.EXE    (компилятор макросов Turbo Editor'а)
echo    RUSS_P.TEM
echo    BC.COM 
:exit
