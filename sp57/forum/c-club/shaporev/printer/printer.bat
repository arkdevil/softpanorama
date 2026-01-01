tasm /ml /d__NEAR__ keyserv.asm
tcc -mt -1- -O -Z -a- -d -f- -K -M- -N- -k- -p- -r -u -v- -y- -w -eprinter *.c keyserv.obj consolet.lib
if exist printer.exe lzexe printer.exe
