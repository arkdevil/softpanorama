@echo off
echo V.S. Rabets  14-03-91
if .%1.==.%2.zip. pkUnzip -d -JHSR %1
if .%1.==.%2.lzh. LHA x /a /i1 /l1 %1
if .%1.==.%2.arj. ARJ x -y -- %1
if .%1.==.%2.ice. lhArc x /r /m %1
if .%1.==.%2.arc. unPack %1
if .%1.==.%2.pak. Pak e /Path %1
if errorlevel 1 echo 	[1;5mError[0m
if errorlevel 1 pause
for %%e in(zip lzh arj ice arc pak) do if .%1.==.%2.%%e. goto Quit
nloff
if .%2.==..  D:\EDIT\LEX\lex %1
if .%2.==..  goto Quit
if not exist %2  D:\EDIT\LEX\lex %1
if     exist %2 if     %1.==%2.  D:\EDIT\LEX\lex %1
if     exist %2 if not %1.==%2.  D:\EDIT\LEX\lex %1 %2 %3 %4 %5 %6 %7 %8 %9
:Quit
if not errorlevel 1 echo [1m  OK![0m
