@echo off
REM  ------- k_tco_me.bat К.Е.Г. 13.12/89 02:57pm  для трансляции из ME -------------
rem   TCC-Трансляция ФАЙЛА В б-ку c:\kkk\tco\kkk.lib (по умолчанию)
REM Параметры:
REM %1 - Имя файла без пути и расширения (он будет и ЕХЕ )
REM %2 - --""-- с Полным путем и расширением
REM %3 - Имя библиотеки и полный путь к ней
rem * TCC-Трансляция ФАЙЛА В б-ку c:\kkk\tco\kkk.lib (по умолчанию)
REM echo off  --------------------------------------------------------------
what ye
set k_drive=%what%
what y
if "%what%" == "\" set k_path=%k_drive%:%what%
if not "%what%" == "\" set k_path=%k_drive%:%what%\

tcc -c %2 >%k_path%meerr.tmp
if errorlevel 1 goto err

if exist %3 goto yeslib
TLIB c:\kkk\tco\kkk.lib /c +- c:\kkk\tco\%1 ,%k_path%listlib
goto noerr

:yeslib
TLIB %3 /c +- c:\kkk\tco\%1 ,%k_path%listlib
goto noerr

:err
:REM ** Были "ужасные" ошибки,шлепнем их ВСЕ
@be beep
type %k_path%meerr.tmp
@be beep
@beep /R3 /N15

:noerr
:REM .OBJ больше не нужен - удаляем
if exist c:\kkk\tco\%1.obj del c:\kkk\tco\%1.obj >nul
%k_drive%:
cd %what%