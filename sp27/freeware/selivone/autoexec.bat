echo off
prompt $p$g
cd dos
cd uni
call uni
cd..
timer/s
echo goto start
subst e: c:\tc\ee
subst f: c:\tc\ff
echo fastopen c:=100
rem anti4us2
cpf_136
dosedit
:start
c:\dos\colo
if errorlevel 11 goto f19
if errorlevel 10 goto acco
if errorlevel 9 goto periscope
if errorlevel 8 goto rally
if errorlevel 7 goto stat
if errorlevel 6 goto multi_edit
if errorlevel 5 goto help
if errorlevel 4 goto tc_
if errorlevel 3 goto masm_
if errorlevel 2 goto turbo_deb
if errorlevel 1 goto nc_hu
if errorlevel 0 goto exeunt
:f19
c:
cd\tc
echo manana
com\manana.exe
goto start
:acco
c:
cd\zortech
call run.bat
goto start
:periscope
c:
cd\peri
set ps=c:\peri
path=c:\peri
cls
echo clearnmi.com
ps/V:10/K/H
cd\a
pause
mach3.exe
\nc\nc
goto start
:rally
c:
path=c:\td
\nc\nc
path=c:
goto start
:stat
echo Уважаемый товаpищ, Вы будете pаботать с системой стат.талоны
echo d:
echo cd\
echo f:
echo cd\
echo d:
echo cd\
echo copy f:nett.bat
echo e:
echo cd\
echo call d:\nett.bat
c:
cd\tc
oo\vixen
echo com\manana
goto start
:multi_edit
echo Уважаемый товаpищ, Вы будете pаботать с системой  Multi - Edit    
c:
cd\me
me
goto start
:help
c:
cd\asm
help
goto start
:tc_
c:
\dos\mode bw80
cd\tc
tc
goto start
:masm_
c:
cd\asm
nc
goto start
:turbo_deb
path=c:\tp5
echo now will be turbo debugger
c:
\dos\mode bw80
cd \tc
path=c:\td;c:\tc\oo;c:\tc\cc
td -ds oo\vixen.exe
path=c:
goto start
:nc_hu
c:\nc\nc
goto start
:exeunt
ECHO c:\dos\dosedit
c:\dos\ram
echo cd\peri
:full
echo Farewell, your art is dear for me !
ECHO sy