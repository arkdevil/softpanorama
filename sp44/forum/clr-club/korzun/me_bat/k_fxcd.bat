@echo off
REM  ------- k_fxcd.bat К.Е.Г. 12.12/89 02:57pm  для трансляции из ME -------------
REM   FOXCODE - Трансляция ФАЙЛА .GEN В .COD
REM Параметры:
REM %1 - Имя файла без пути и расширения (В нем (.log) протокол ошибок )
REM %2 - --""-- с Полным путем и расширением
REM echo off  --------------------------------------------------------------
what ye
set k_drive=%what%
what y
if "%what%" == "\" set k_path=%k_drive%:%what%
if not "%what%" == "\" set k_path=%k_drive%:%what%\

FOXCODE %2
if exist meerr.tmp  DEL meerr.tmp >NUL <c:\yes.dat
if exist  %k_path%%1.LOG REN %k_path%%1.LOG meerr.tmp >NUL

%k_drive%:
cd %what%