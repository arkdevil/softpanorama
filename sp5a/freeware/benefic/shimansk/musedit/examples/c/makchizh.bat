cl /c play.c
cl /c chizh.c
link play+chizh,chizh,nul,..\..\lib\music;
del *.obj
chizh