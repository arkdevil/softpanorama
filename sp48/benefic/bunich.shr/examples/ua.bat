@echo off
if %1.==. goto :Missing
  mb F=FILE(FindPfx %1)
  if "%F%"=="" goto :NotFound
  mb EXT=ext(%F%)
  mb W=StrPos( "[%EXT%]", "[ARJ][LZH][ICE][ARC][PAK][ZIP]" )
  if Not "%W%"=="0" goto :%EXT%
  Echo UA: invalid extension in %F%
  goto :End
:ARJ
  arj x %F% %2 %3 %4
  goto :Fin
:LZH
:ICE
  lha x %F% %2 %3 %4
  goto :Fin
:PAK
:ARC
  pak x %F% %2 %3 %4
  goto :Fin
:ZIP
  pkunzip -d %F% %2 %3 %4
:Fin
  Set W=
  Set EXT=
  Set F=
  goto :End
:Missing
  Echo UA: archive name missing
  goto :End
:NotFound
  Echo UA: not found %1
:End
