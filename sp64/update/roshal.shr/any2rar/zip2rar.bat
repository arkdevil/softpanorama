@Echo off
if %1A==A goto Usage
if %1==* goto Mask
if %1==*.zip goto Mask
goto Single
:Mask
if exist *.zip goto MaskYeah
echo %1 -- files cannot be found.

echo %1 -- files cannot be found. >>!zip2rar.!!!
goto Exit
:MaskYeah
if exist *. ren * *.$e$ 
ren *.zip *.
for %%f in (*.) do call zip2rar %%f
if exist *.$e$ ren *.$e$ *.
goto Quit
:Single
echo 
ZIP2RAR v0.02 (c) AS, RAR Support              Free!

if exist %1.zip goto Ok
if exist %1 goto Ok
goto ErrFNF
:Ok
if exist %1.rar goto ErrRARe
mkdir $for-zip
if exist %1.zip goto WExt
goto NoExt
:WExt
ren %1.zip *.
:NoExt
pkunzip -d %1. $for-zip
if errorlevel 1 goto ErrExtr
if not exist *.* goto ErrExtr
cd $for-zip
rar m -r -s -std ..\%1.rar
if errorlevel 1 goto ErrRAR
cd ..
rd $for-zip
echo 
%1.ZIP -} %1.RAR repack successfully completed.
if exist %1. erase %1.
Goto Quit
:ErrExtr
ren %1 *.zip
rd $FOR-zip
echo 
%1.ZIP -- File cannot be unpacked because errors!

echo %1.ZIP -- File cannot be unpacked because errors! >>!zip2rar.!!!
echo 
  (NOTE, NO EXTENSION PLEASE!!!)

Goto Quit
:ErrRARe
echo 
%1.RAR -- File already exists. Cannot be repacked!

echo %1.RAR -- File already exists. Cannot be repacked! >>!zip2rar.!!!
goto Quit
:ErrRAR
cd ..
ren %1 *.zip
rd $FOR-zip
echo 
%1.ZIP -- File cannot be repacked!

echo %1.ZIP -- File cannot be repacked! >>!zip2rar.!!!
echo 
  (NOTE, NO EXTENSION PLEASE!!!)

Goto Exit
:ErrFNF
echo 
%1 -- File not found!

echo %1 -- File not found! >>!zip2rar.!!!
Goto Quit
:Usage
echo 
ZIP2RAR v0.02 (c) AS, RAR Support              Free!

echo   Usage: zip2rar {ziparch}
echo 
(Note, no extension please!)

:Exit
if exist *.$e$ ren *.$e$ *.
exit
:Quit