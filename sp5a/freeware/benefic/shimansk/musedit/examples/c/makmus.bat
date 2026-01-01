cl /c play.c
cl /c %1.c
link play+%1,%1,nul,..\..\lib\music;
del *.obj
%1