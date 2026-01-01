@echo off
rem Турбо Си 2.5. 
c:\tc\tcc -c+ -mt -1 -Ic:\tc\include -Lf:\c\lib -N- -G- -K- -O -Z -a- -d -f- -r -u -v- -w -y- kalah.c
c:\tc\tlink /x /Tdc /Lc:\tc\lib /n /d /t /P /ye /yx /C c0t kalah,kalah.com,,cs
