
rem  WaitProgram to ask if RPRINTER should be loaded
naskrprn
if errorlevel 1 goto skip

rem  Load Rprinter for this workstation
cd\net
ipx
netx
rprinter triton_pserver 1
cd\
:skip

path c:\;c:\@@UTL;c:\dos;
prompt $p$g
m
