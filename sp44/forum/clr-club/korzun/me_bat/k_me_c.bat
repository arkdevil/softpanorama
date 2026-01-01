:@echo off
echo ****** K_ME_C.BAT Запуск программы %3  v.m.  04.07.90 10:27 *******
@IF EXIST MEERR.TMP ERASE MEERR.TMP >NUL
%3 >MEERR.TMP
@IF EXIST MEERR.TMP TYPE MEERR.TMP
@IF not EXIST MEERR.TMP goto exit
echo " ****** Результат -- в MEERR.TMP  **"
:EXIT