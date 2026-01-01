@Echo off
if %1A==A goto Usage
if %1==* goto Mask
if %1==*.lzh goto Mask
goto Single
:Mask
if exist *.lzh goto MaskYeah
echo %1 -- files cannot be found.

echo %1 -- files cannot be found. >>!lzh2rar.!!!
goto Exit
:MaskYeah
if exist *. ren *. *.$e$ 
ren *.lzh *.
for %%f in (*.) do call lzh2rar %%f
if exist *.$e$ ren *.$e$ *.
goto Quit
:Single
echo 
LZH2RAR v0.02 (c) AS, RAR Support              Free!

if exist %1.lzh goto Ok
if exist %1 goto Ok
goto ErrFNF
:Ok
if exist %1.rar goto ErrRARe
mkdir $for-lzh
if not exist %1.lzh goto NoExt
ren %1.lzh *.
:NoExt
lha x %1. $for-lzh\
if errorlevel 1 goto ErrExtr
if not exist *.* goto ErrExtr
cd $for-lzh
rar m -r -s -std ..\%1.rar
if errorlevel 1 goto ErrRAR
cd ..
rd $for-lzh
echo 
%1.LZH -} %1.RAR repack successfully completed.
if exist %1. erase %1.
Goto Quit
:ErrExtr
ren %1 *.lzh
rd $FOR-LZH
echo 
%1.lZH -- File cannot be unpacked because errors!

echo %1.LZH -- File cannot be unpacked because errors! >>!lzh2rar.!!!
echo 
  (NOTE, NO EXTENSION PLEASE!!!)

Goto Quit
:ErrRARe
echo 
%1.RAR -- File already exists. Cannot be repacked!

echo %1.RAR -- File already exists. Cannot be repacked! >>!lzh2rar.!!!
goto Quit
:ErrRAR
cd ..
ren %1 *.lzh
rd $FOR-LZH
echo 
%1.LZH -- File cannot be repacked!

echo %1.LZH -- File cannot be repacked! >>!lzh2rar.!!!
echo 
  (NOTE, NO EXTENSION PLEASE!!!)

Goto Exit
:ErrFNF
echo 
%1 -- File not found!

echo %1 -- File not found! >>!lzh2rar.!!!
Goto Quit
:Usage
echo 
LZH2RAR v0.02 (c) AS, RAR Support              Free!

echo   Usage: lzh2rar {lzharch}
echo 
(Note, no extension please!)

:Exit
if exist *.$e$ ren *.$e$ *.
exit
:Quit