@echo off
:MAIN
shift
if "%0" == "" goto END
if not exist %0.* goto NO_FILES
if exist %0.sqz goto SQZ
if exist %0.arj goto ARJ
if exist %0.lzh goto LHA
if exist %0.zip goto ZIP
if exist %0.arc goto ARC
echo Unknown archive type (%0.???)!
echo Knows about SQZ/ARJ/LHA/ZIP/ARC
goto END
:SQZ
sqz x %0 /z01 %0\
if errorlevel 1 goto END
goto MAIN
:ARJ
arj x -p1 -e1 -u -y -jl %0
if errorlevel 1 goto END
goto MAIN
:LHA
lha x -m1 %0 *.*
if errorlevel 1 goto END
goto MAIN
:ZIP
pkunzip -d -n %0 *.* %0\
if errorlevel 1 goto END
goto MAIN
:ARC
md %0
pkxarc /x %0 *.* %0\
if errorlevel 1 goto END
goto MAIN
:NO_FILES
echo Couldn't find file (%0.*)
goto MAIN
:END
