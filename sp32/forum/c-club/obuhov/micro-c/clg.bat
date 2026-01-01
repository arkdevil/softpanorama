echo off
rem === compile, link and go for infile test.c ===
micro-c1.com %1.c %1.asm
masm.exe %1.asm,%1.obj,Nul.lst,nul.crf
link.exe %1.obj,%1.exe,Nul.lst,,;
exe2com.com %1.exe %1.com
del %1.asm
del %1.obj
del %1.exe
cls
%1.com test.c
     
