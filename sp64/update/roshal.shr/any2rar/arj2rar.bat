@Echo off
if %1A==A goto Usage
if %1==* goto Mask
if %1==*.arj goto Mask
goto Single
:Mask
if exist *.arj goto MaskYeah
echo %1 -- files cannot be found.

echo %1 -- files cannot be found. >>!arj2rar.!!!
goto Exit
:MaskYeah
if exist *. ren *.$e$
ren *.arj *.
for %%f in (*.) do call arj2rar %%f
if exist *.$e$ ren *.$e$ *.
goto Quit
:Single
echo 
ARJ2RAR v0.02 (c) AS, RAR Support              Free!

if exist %1.arj goto Ok
if exist %1 goto Ok
goto ErrFNF
:Ok
if exist %1.rar goto ErrRARe
mkdir $for-arj
if exist %1.arj goto WExt
goto NoExt
:WExt
ren %1.arj *.
:NoExt
arj x -y -v -u %1. $for-arj
if errorlevel 1 goto ErrExtr
if not exist *.* goto ErrExtr
cd $for-arj
rar m -r -s -std ..\%1.rar
if errorlevel 1 goto ErrRAR
cd ..
rd $for-arj
echo 
%1.ARJ -} %1.RAR repack successfully completed.
if exist %1. erase %1.
Goto Quit
:ErrExtr
ren %1 *.arj
rd $FOR-ARJ
echo 
%1.ARJ -- File cannot be unpacked because errors!

echo %1.ARJ -- File cannot be unpacked because errors! >>!arj2rar.!!!
echo 
 (NOTE, NO EXTENSION PLEASE!!!)

Goto Quit
:ErrRARe
echo 
%1.RAR -- File already exists. Cannot be repacked!

echo %1.RAR -- File already exists. Cannot be repacked! >>!arj2rar.!!!
goto Quit
:ErrRAR
cd ..
ren %1 *.arj
rd $FOR-ARJ
echo 
%1.ARJ -- File cannot be repacked!

echo %1.ARJ -- File cannot be repacked! >>!arj2rar.!!!
echo 
  (NOTE, NO EXTENSION PLEASE!!!)

Goto Exit
:ErrFNF
echo 
%1 -- File not found!

echo %1 -- File not found! >>!arj2rar.!!!
Goto Quit
:Usage
echo 
ARJ2RAR v0.02 (c) AS, RAR Support              Free!

echo   Usage: arj2rar {arjarch}
echo 
(Note, no extension please!)

:Exit
if exist *.$e$ ren *.$e$ *.
exit
:Quit