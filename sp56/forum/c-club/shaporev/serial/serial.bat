tasm /ml /d__NEAR__ keyserv.asm
tcc -mt -1- -O -Z -a- -d -f- -K -M- -N- -k- -p- -r -u -v- -y- -w -eserial *.c keyserv.obj consolet.lib
if exist serial.exe exe2bin serial.exe serial.com
if exist serial.com del serial.exe
