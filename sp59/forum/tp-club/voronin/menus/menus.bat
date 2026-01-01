@echo off
cls
echo.
echo.
echo       Пример  использования  программы  MENUS  для
echo       введения в командный файл вертикального меню.

menus 20 7 v menus_pr.dat
if errorlevel 12 goto i12
if errorlevel 11 goto i11
if errorlevel 10 goto i10
if errorlevel 9  goto i9
if errorlevel 8  goto i8
if errorlevel 7  goto i7
if errorlevel 6  goto i6
if errorlevel 5  goto i5
if errorlevel 4  goto i4
if errorlevel 3  goto i3
if errorlevel 2  goto i2
if errorlevel 1  goto i1
if errorlevel 0  goto i0

:i1
    echo Вы выбрали элемент меню с кодом 1
    goto final
:i2
    echo Вы выбрали элемент меню с кодом 2
    goto final
:i3
    echo Вы выбрали элемент меню с кодом 3
    goto final
:i4
    echo Вы выбрали элемент меню с кодом 4
    goto final
:i5
    echo Вы выбрали элемент меню с кодом 5
    goto final
:i6
    echo Вы выбрали элемент меню с кодом 6
    goto final
:i7
    echo Вы выбрали элемент меню с кодом 7
    goto final
:i8
    echo Вы выбрали элемент меню с кодом 8
    goto final
:i9
    echo Вы выбрали элемент меню с кодом 9
    goto final
:i10
    echo Вы выбрали элемент меню с кодом 10
    goto final
:i11
    echo Вы выбрали элемент меню с кодом 11
    goto final
:i12
    echo Вы выбрали элемент "Выход в ДОС"
    goto final
:i0
    echo Вы вышли из меню по клавише ESC
    goto final
:final
pause >nul
cls
echo.
echo.
echo       Пример  использования  программы  MENUS  для
echo      введения в командный файл горизонтального меню.
menus 4 10 h menus_pr.dat *
if errorlevel 12 goto j12
if errorlevel 11 goto j11
if errorlevel 10 goto j10
if errorlevel 9  goto j9
if errorlevel 8  goto j8
if errorlevel 7  goto j7
if errorlevel 6  goto j6
if errorlevel 5  goto j5
if errorlevel 4  goto j4
if errorlevel 3  goto j3
if errorlevel 2  goto j2
if errorlevel 1  goto j1
if errorlevel 0  goto j0

:j1
    echo Вы выбрали элемент меню с кодом 1
    goto exit
:j2
    echo Вы выбрали элемент меню с кодом 2
    goto exit
:j3
    echo Вы выбрали элемент меню с кодом 3
    goto exit
:j4
    echo Вы выбрали элемент меню с кодом 4
    goto exit
:j5
    echo Вы выбрали элемент меню с кодом 5
    goto exit
:j6
    echo Вы выбрали элемент меню с кодом 6
    goto exit
:j7
    echo Вы выбрали элемент меню с кодом 7
    goto exit
:j8
    echo Вы выбрали элемент меню с кодом 8
    goto exit
:j9
    echo Вы выбрали элемент меню с кодом 9
    goto exit
:j10
    echo Вы выбрали элемент меню с кодом 10
    goto exit
:j11
    echo Вы выбрали элемент меню с кодом 11
    goto exit
:j12
    echo Вы выбрали элемент "Выход в ДОС"
    goto final
:j0
    echo Вы вышли из меню по клавише ESC
    goto exit
:exit
