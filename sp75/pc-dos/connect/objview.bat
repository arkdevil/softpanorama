@echo off
rem wdisasm.exe %1 > d:\objview.tmp
rem tsda %1 > d:\objview.tmp
objtoasm %1 > %temp%\objview.tmp
wpview %temp%\objview.tmp
del %temp%\objview.tmp
