echo off
rem === compile and link ===
micro-c1.com %1.c %1.asm
masm.exe %1.asm,%1.obj,Nul.lst,nul.crf
link.exe %1.obj,%1.exe,Nul.lst,,;
exe2com1.com %1.exe %1.com
del %1.obj
del %1.exe
del %1.asm
     
