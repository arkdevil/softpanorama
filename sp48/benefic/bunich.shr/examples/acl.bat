 @echo off
  mb N=File(Fname /dpn/,%1)
  if not %2.==*c. goto :ME_EXE
  c:\asm\tasm /m2 %N% > meerr.tmp
  if not errorlevel 1  tlink /t %N%,%N%,nul >> meerr.tmp
  goto :Del
:ME_EXE
  if not %2.==*e. goto :EXE
  c:\asm\tasm /m2 %N% > meerr.tmp
  if not errorlevel 1  tlink %N%,%N%,nul >> meerr.tmp
  goto :Del
:ME_Debug
  c:\asm\tasm /m2/zi %N% > meerr.tmp
  if not errorlevel 1  tlink %N%/v >> meerr.tmp
  goto :Del
:EXE
  if %2.==*d. goto :ME_Debug
  if not %2.==e. goto :Debug
  if %3.==. goto :EXE_Nolist
  c:\asm\tasm /l/c/m2 %N%,,%3
  if not errorlevel 1  tlink %N%,%N%,%3;
  goto :Del
:EXE_Nolist
  c:\asm\tasm /m2 %N%
  if not errorlevel 1  tlink %N%,%N%,nul;
  goto :Del
:Debug
  if not %2.==d. goto :COM
  c:\asm\tasm /m2/zi %N%
  if not errorlevel 1  tlink %N%/v
  goto :Del
:COM
  set W=%2
  if not %3.==. set W=%3
  if %W%.==. goto :COM_Nolist
:COM_List
  c:\asm\tasm /l/c/m2 %N%,,%W%
  if not errorlevel 1  tlink /t %N%,%N%,%W%
  goto :DelW
:COM_Nolist
  c:\asm\tasm /m2 %N%
  if not errorlevel 1  tlink /t %N%,%N%,nul
:DelW
  set W=
:Del
  if exist %N%.obj  del %N%.obj
  set N=
