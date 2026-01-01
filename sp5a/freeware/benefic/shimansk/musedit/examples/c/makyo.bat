cl /c play.c
cl /c yo.c
link play+yo,yo,nul,..\..\lib\music;
del *.obj
yo