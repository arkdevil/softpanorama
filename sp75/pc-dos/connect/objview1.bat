@echo off
wdisasm.exe %1 > d:\objview.tmp
wpview d:\objview.tmp
del d:\objview.tmp
