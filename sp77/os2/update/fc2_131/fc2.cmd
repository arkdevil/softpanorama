rem @echo off
set tmpdir=c:
if not "%TMP%" == "" set tmpdir=%TMP%

fc.exe /x %tmpdir%\fcdir.cmd
call %tmpdir%\fcdir.cmd
