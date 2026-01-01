echo off
Rem usage: delta file version
Rem E.g.,  delta hdiff 110
Rem        expects hdiff.scc, hdiff.c; makes hdiff.110
if x%1 == x goto usage
if x%2 == x goto usage
hdiff -e %1.scc %1.c %1.%2
echo Delta file %1.%2 made
goto exit
:usage
echo usage: delta file version
:exit
