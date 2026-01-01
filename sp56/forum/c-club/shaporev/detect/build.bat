call makelib n
call makelib f

tcc -mt -A- -G- -K -M- -N- -O -Z -a- -d -f- -k- -p- -r -u -v- -y- -w detect.c console.c detectn.lib
exe2bin detect.exe detect.com
del detect.exe

pkzip a detect.zip detect?.lib detect.com detect.c console.c detect.h console.h detect.txt
zip2exe -j detect.zip
del detect.zip
