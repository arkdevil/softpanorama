echo off
rem === compile and link ===
masm %1.asm,%1.obj,Nul.lst,nul.crf /T /B63
link %1.obj,%1.exe,Nul.lst,,;
exe2com.com %1.exe
     
