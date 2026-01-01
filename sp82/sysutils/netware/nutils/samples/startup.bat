@echo off
cls
h:\public\robot\ncopynew h:\grp\mis\master\shell\net\net.bat c:\@@utl\net.bat
h:\public\autoexec\nlogevt b h:\public\robot\inbound\login.evt
h:\public\autoexec\nchkrprn check
h:\public\autoexec\nselprnj set

if "%AWActive%" == "Y" goto cont2

cls
echo Loading Futuris RightHandMan...
h:\rhm\rhm /r >nul
h:\rhm\rhm %name% /sE >nul

:cont2
cls
echo Loading NetMenu...
cd\public\netmenu
NETMENU
