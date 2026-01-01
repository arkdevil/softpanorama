@echo off
REM  ------- k_tc_me.bat К.Е.Г. 12.12/89 02:57pm  для трансляции из ME -------------
rem   TCC-Трансляция ФАЙЛА В .EXE исп б-ку c:\kkk\tco\kkk.lib (по умолчанию)
REM Параметры:
REM %1 - Имя файла без пути и расширения (он будет и ЕХЕ )
REM %2 - --""-- с Полным путем и расширением
REM %3 - Имя библиотеки и полный путь к ней
rem * TCC-Трансляция ФАЙЛА В .EXE исп б-ку c:\kkk\tco\kkk.lib (по умолчанию)
REM echo off  --------------------------------------------------------------
what ye
set k_drive=%what%
what y
if "%what%" == "\" set k_path=%k_drive%:%what%
if not "%what%" == "\" set k_path=%k_drive%:%what%\
if exist %3 goto yeslib

tcc -e%1 %2 c:\kkk\tco\kkk.lib  >%k_path%meerr.tmp
goto anal

:yeslib
tcc -e%1 %2 %3 >%k_path%meerr.tmp

:anal
if not errorlevel 1 goto noerr

:REM ** Были "ужасные" ошибки,шлепнем их ВСЕ
@be beep
type %k_path%meerr.tmp
@be beep
@be beep /D1 /R2 /N2

:noerr
:REM .OBJ больше не нужен - удаляем
if exist c:\kkk\tco\%1.obj del c:\kkk\tco\%1.obj >nul
%k_drive%:
cd %what%