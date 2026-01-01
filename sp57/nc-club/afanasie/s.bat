me sp.asm
tasm sp.asm
if errorlevel 1 goto exit
tlink /t sp.obj
afd "mo a on "L sp.com
:exit