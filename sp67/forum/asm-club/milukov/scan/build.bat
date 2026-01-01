tasm /q view.asm
tlink /x view.obj
exe2bin view.exe view.sys
@del view.exe > nul
@del view.obj > nul
tasm /q 256.asm
tlink /t/x 256.obj
@del 256.obj > nul