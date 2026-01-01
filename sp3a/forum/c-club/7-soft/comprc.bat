@echo off
if %1.==. goto Format
if not exist %1\bin\tcc.exe goto Format
%1\bin\tcc.exe -I%1\include -C -O -Z -D -mc -v -y -k rc.c rcst.c
if errorlevel goto Exit
%1\bin\tlink.exe /x /l /d /v rc.obj rcst.obj rcc0c.obj %1\lib\cc.lib
goto Exit
:Format
echo Parameter must be a turbo directory.
echo Example:  COMPRC D:\TC
goto Exit
:Exit
