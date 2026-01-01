tasm /ml /d__NEAR__ *.asm
tcc -mt -1- -O -Z -a- -d -f- -K -M- -N- -k- -p- -r -u -v- -y- -w -c *.c
tcc -mt -1- -O -Z -a- -d -f- -K -M- -N- -k- -p- -r -u -v- -y- -w -edetect *.obj detectn.lib consolet.lib
if exist detect.exe exe2bin detect.exe detect.com
if exist detect.com del detect.exe
