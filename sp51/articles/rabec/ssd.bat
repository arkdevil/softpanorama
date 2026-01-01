@echo off
if .%2.==.. %0 %1 G:\
echo SSD - Speed SpeeDisk,  edition 12-11-92.   (C) V.S. Rabets, 1992.
echo.
for %%f in ( A: a: B: b: C: c: D: d: E: e: F: f: G: g: H: h: ) do if .%%f.==.%1. goto Continue
echo Неверно задан диск.
goto END

:Continue
%1
cd \

FA SD.ini       /clear
FA Adinf═?═.░░░ /clear
FA Image.?a?    /clear
FA !DirRoom     /clear

del      %2Adinf═?═.░░░
copy /b    Adinf═?═.░░░ %2
if exist %2Adinf═?═.░░░ del Adinf═?═.░░░
del           Image.?a?
del        treeinfo.ncd

for %%f in ( C: c: ) do if %%f==%1  !DirRoom %1 /p 60
for %%f in ( D: d: ) do if %%f==%1  !DirRoom %1 /p 120
for %%f in ( E: e: ) do if %%f==%1  !DirRoom %1 /p 200
for %%f in ( F: f: ) do if %%f==%1  !DirRoom %1 /p 90

SpeeDisk %1

copy /b %2Adinf═?═.░░░ %1
FA SD.ini       /HID+
FA Adinf═?═.░░░ /HID+ /R+
FA !DirRoom     /HID+

Image %1

:END
