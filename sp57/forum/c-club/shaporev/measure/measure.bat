tasm /ml /d__NEAR__ *.asm
tcc -mt -1- -G- -M- -N- -O -Z -a- -d -f -k- -p- -r -u -v- -y- -w -w-pro -c *.c
tcc -mt -1- -G- -M- -N- -O -Z -a- -d -f -k- -p- -r -u -v- -y- -w -w-pro -emeasure *.obj consolet.lib
if exist measure.exe lzexe measure.exe
