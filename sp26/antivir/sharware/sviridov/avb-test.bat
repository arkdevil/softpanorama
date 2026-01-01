@Echo off
Avb Avb.dat>Nul
if errorlevel 5 goto L5
if errorlevel 4 goto L4
if errorlevel 3 goto L3
if errorlevel 2 goto L2
if errorlevel 1 goto L1
echo   Ваш винчестер в порядке
goto QU
:L5
echo   Изменен BOOT-сектор !!!
goto QU
:L4
echo   Изменен Partition Table !!!
goto QU
:L3
echo   Сбой винчестера !
goto QU
:L2
echo   AVB.DAT не найден или ошибка чтения AVB.DAT
goto QU
:L1
echo   Неверна версия BIOS. Повторите инсталляцию.
goto QU
:QU
