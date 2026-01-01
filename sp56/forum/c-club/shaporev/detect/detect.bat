@echo off
if not exist detectn.lib call makelib n

tcc -mt -A- -G- -K -M- -N- -O -Z -a- -d -f- -k- -p- -r -u -v- -y- -w detect.c console.c detectn.lib
exe2bin detect.exe detect.com
rem del detect.exe

