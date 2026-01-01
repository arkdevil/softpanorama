@echo off
path c:\sys\antivir;d:\
mb W=CurDir(pr)
aidstest /f/q/a38 %W%\*.*
if %1.==.    scan . /NOMEM /SUB
if %1.==mem. scan . /SUB
rem mb W=CurDir(d)
rem anti-dir %W%
set W=
Rem c:\bat\setpath
