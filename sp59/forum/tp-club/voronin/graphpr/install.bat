@echo off
cls
echo.
echo.
echo.
echo.
echo.
echo              [33;44;1m╔════════════════════════════════════════════════════╗[33;44;0m
echo              [33;44;1m║                                                    ║[33;44;0m▒▒
echo              [33;44;1m║                ИНСТАЛЛЯЦИЯ ПРОГРАММЫ               ║[33;44;0m▒▒
echo              [33;44;1m║                                                    ║[33;44;0m▒▒
echo              [33;44;1m║                    G R A P H P R                   ║[33;44;0m▒▒
echo              [33;44;1m║                                                    ║[33;44;0m▒▒
echo              [33;44;1m║                                                    ║[33;44;0m▒▒
echo              [33;44;1m║                                                    ║[33;44;0m▒▒
echo              [33;44;1m║                                                    ║[33;44;0m▒▒
echo              [33;44;1m║                                                    ║[33;44;0m▒▒
echo              [33;44;1m║                                                    ║[33;44;0m▒▒
echo              [33;44;1m╚════════════════════════════════════════════════════╝[33;44;0m▒▒
echo                ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
menus 21 13 h menus.dat
if errorlevel=4  goto  I4
if errorlevel=3  goto  I3
if errorlevel=2  goto  I2
if errorlevel=1  goto  I1
goto end
:i1
c:
cd c:\.
md graphpr > nul
cd graphpr
copy a:\graphpr\graphpri.arj *.*  >nul
copy a:\graphpr\arj.exe *.*  >nul
arj x -d graphpri.arj >nul
tpc /b /$D- /$L- graphpr.pas   >nul
tpc /b /$D- /$L- expander.pas  >nul
tpc /b /$D- /$L- pslview.pas   >nul
tpc /b /$D- /$L- sintez.pas    >nul
tpc /b /$D- /$L- recod.pas     >nul
goto end
:i2
d:
cd d:\.
md graphpr > nul
cd graphpr
copy a:\graphpr\graphpri.arj *.*  >nul
copy a:\graphpr\arj.exe *.*  >nul
arj x -d graphpri.arj >nul
tpc /b /$D- /$L- graphpr.pas   >nul
tpc /b /$D- /$L- expander.pas  >nul
tpc /b /$D- /$L- pslview.pas   >nul
tpc /b /$D- /$L- sintez.pas    >nul
tpc /b /$D- /$L- recod.pas     >nul
goto end
:i3
e:
cd e:\.
md graphpr > nul
cd graphpr
copy a:\graphpr\graphpri.arj *.*  >nul
copy a:\graphpr\arj.exe *.*  >nul
arj x -d graphpri.arj >nul
tpc /b /$D- /$L- graphpr.pas   >nul
tpc /b /$D- /$L- expander.pas  >nul
tpc /b /$D- /$L- pslview.pas   >nul
tpc /b /$D- /$L- sintez.pas    >nul
tpc /b /$D- /$L- recod.pas     >nul
goto end
:i4
f:
cd f:\.
md graphpr > nul
cd graphpr
copy a:\graphpr\graphpri.arj *.*  >nul
copy a:\graphpr\arj.exe *.*  >nul
arj x -d graphpri.arj >nul
tpc /b /$D- /$L- graphpr.pas   >nul
tpc /b /$D- /$L- expander.pas  >nul
tpc /b /$D- /$L- pslview.pas   >nul
tpc /b /$D- /$L- sintez.pas    >nul
tpc /b /$D- /$L- recod.pas     >nul
goto end
:end
