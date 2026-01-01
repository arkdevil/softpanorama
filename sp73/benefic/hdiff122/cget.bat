echo off
Rem usage: cget file,version
Rem E.g.,  cget hdiff 110
Rem        expects hdiff.scc, hdiff.110; makes hdiff.c
if x%1 == x goto usage
if x%2 == x goto usage
hed %1.scc %1.%2 %1.c
echo %1.c Ver %2 made
goto exit
:usage
echo usage: cget file version
:exit
