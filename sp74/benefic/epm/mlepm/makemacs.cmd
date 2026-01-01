@echo off
setlocal
@if .%1 == . goto all
:loop
ETPM %1 /v || echo Error compiling %1
@shift
@if .%1 == . goto end
@goto loop
:all
ETPM MLHILITE /v || echo Error compiling MLHilite
ETPM MLHOOK   /v || echo Error compiling MLHook
ETPM MLTOOLS  /v || echo Error compiling MLTools
ETPM CMODE    /v || echo Error compiling Cmode
ETPM EMODE    /v || echo Error compiling Emode
ETPM LISTMODE /v || echo Error compiling Listmode
ETPM PMODE    /v || echo Error compiling Pmode
ETPM RCMODE   /v || echo Error compiling RCmode
ETPM REXXMODE /v || echo Error compiling REXXmode
ETPM MATCHKEY /v || echo Error compiling Matchkey
:end
endlocal
