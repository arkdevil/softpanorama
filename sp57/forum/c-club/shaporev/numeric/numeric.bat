tasm /ml /d__NEAR__ *.asm
tcc -mt -f87 -1- -G- -N- -O -Z -a- -d -k- -p- -r -u -v- -y- -w -c *.c
tcc -mt -f87 -1- -G- -N- -O -Z -a- -d -k- -p- -r -u -v- -y- -w -enumeric *.obj consolet.lib
if exist numeric.exe lzexe numeric.exe
