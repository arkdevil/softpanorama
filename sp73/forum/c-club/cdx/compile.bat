@echo off

if exist cdx.obj del cdx.obj >nul
if exist cdx.exe del cdx.exe >nul
if exist cdx.com del cdx.com >nul

if .%1 == .6  goto msc6
if .%1 == .5  goto msc5
if .%1 == .t  goto turboc2
if .%1 == .T  goto turboc2
if .%1 == .t+ goto tcpp1
if .%1 == .T+ goto tcpp1
if .%1 == .+  goto bc2

echo .
echo .      To compile CDX.C -- use one of the following commands:
echo .
echo .                  For Compiler      Use this command
echo .                ----------------  -----------------------------
echo .                MSC 6.0           COMPILE 6
echo .                MSC 5.1           COMPILE 5
echo .                Turbo C 2.0       COMPILE t
echo .                Turbo C++ 1.0     COMPILE t+ parm1 parm2 ...
echo .                Borland C++ 2.0   COMPILE +  parm1 parm2 ...
echo .
echo .      Note: To tell the compilers where the include files and
echo .            link libraries for TC++ 1.0 and BC++ 2.0 are,
echo .            use the parm1, parm2 ...
echo .
echo .            Example: compile + -Ic:\bc\include -Lc:\bc\lib
echo .                     compile t+ -Id:\tc\include -Ld:\tc\lib
goto end

:msc6
cl -AT -Gs -Os cdx.c /link /NOE
del cdx.obj
goto end

:msc5
cl -AS -D_MSC_VER=510 -Gs -Os cdx.c /link /NOE
del cdx.obj
goto end

:turboc2
tcc -mt -G -O -Z cdx.c
exe2bin cdx.exe cdx.com
del cdx.obj
del cdx.exe
goto end

:tcpp1
tcc -mt -lt -G -O -Z %2 %3 %4 %5 %6 %7 %8 %9 cdx.c
del cdx.obj
goto end

:bc2
bcc -mt -lt -G -O -Z %2 %3 %4 %5 %6 %7 %8 %9 cdx.c
del cdx.obj
goto end

:end
