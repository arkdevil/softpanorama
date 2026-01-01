@echo off
Set W=%1
If '%W%'=='' Set W=A
echo Поставьте ИСХОДНУЮ дискету на %W%: и нажмите ENTER...
pause
c:\sys\drivers\PU_COPFD %W%: c:\w\diskimg %2 %3 %4
echo Поставьте ВЫХОДНУЮ дискету на %W%: и нажмите ENTER...
pause
c:\sys\drivers\PU_COPFD c:\w\diskimg %W%: %2 %3 %4
del c:\w\diskimg/p
set W=
