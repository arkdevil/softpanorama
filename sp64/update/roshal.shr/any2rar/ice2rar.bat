@Echo off
if %1A==A goto Usage
if %1==* goto Mask
if %1==*.ice goto Mask
goto Single
:Mask
if exist *.ice goto MaskYeah
echo %1 -- files cannot be found.

echo %1 -- files cannot be found. >>!ice2rar.!!!
goto Exit
:MaskYeah
if exist *. ren *. *.$e$
ren *.ice *.
for %%f in (*.) do call ice2rar %%f
if exist *.$e$ ren *.$e$ *.
goto Quit
:Single
echo 
ICE2RAR v0.02 (c) AS, RAR Support              Free!

if exist %1.ice goto Ok
if exist %1 goto Ok
goto ErrFNF
:Ok
if exist %1.rar goto ErrRarE
mkdir $for-ice
if exist %1.ice goto WExt
goto NoExt
:WExt
ren %1.ice *.
:NoExt
lha x %1. $for-ice\
if errorlevel 1 goto ErrExtr
if not exist *.* goto ErrExtr
cd $for-ice
rar m -r -s -std ..\%1.rar
if errorlevel 1 goto ErrRAR
cd ..
rd $for-ice
echo 
%1.ICE -} %1.RAR repack successfully completed.
if exist %1. erase %1.
Goto Quit
:ErrExtr
ren %1 *.ice
rd $FOR-ICE
echo 
%1.ICE -- File cannot be unpacked because errors!

echo %1.ICE -- File cannot be unpacked because errors! >>!ice2rar.!!!
echo 
  (NOTE, NO EXTENSION PLEASE!!!)

Goto Quit
:ErrRARe
echo 
%1.RAR -- File already exists. Cannot be repacked!

echo %1.RAR -- File already exists. Cannot be repacked! >>!ice2rar.!!!
goto Quit
:ErrRAR
cd ..
ren %1 *.ice
rd $FOR-ICE
echo 
%1.ICE -- File cannot be repacked!

echo %1.ICE -- File cannot be repacked! >>!ice2rar.!!!
echo 
  (NOTE, NO EXTENSION PLEASE!!!)

Goto Exit
:ErrFNF
echo 
%1 -- File not found!

echo %1 -- File not found! >>!ice2rar.!!!
Goto Quit
:Usage
echo 
ICE2RAR v0.02 (c) AS, RAR Support              Free!

echo   Usage: ice2rar {icearch}
echo 
(Note, no extension please!)

:Exit
if exist *.$e$ ren *.$e$ *.
exit
:Quit