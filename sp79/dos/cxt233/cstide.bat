@echo off
rem Interface to Borland IDE
cst -rasp -cs -Cs -n %1
type cst.lst
