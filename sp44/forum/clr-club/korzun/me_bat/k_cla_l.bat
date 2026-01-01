@echo off
: ****** Трансляция CLARION из MULTI-EDIT 01.06.90 16:49   *******
IF EXIST MEERR.TMP ERASE MEERR.TMP >NUL
IF EXIST %2*.ERR  ERASE %2*.ERR >NUL
:*          + листинг ******************
ccmp %1.cla YES /b
IF NOT EXIST %2*.ERR GOTO EXIT
FOR %%F IN (%2*.ERR) DO TYPE %%F >> MEERR.TMP
:EXIT
