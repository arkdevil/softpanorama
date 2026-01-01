@echo off
tdump %1 > d:\objview.tmp
wpview d:\objview.tmp
del d:\objview.tmp
