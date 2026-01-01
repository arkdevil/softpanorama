@echo off
tdump -oiTHEADR -oiPUBDEF -oiEXTDEF -oiSEGDEF %1 > d:\objview.tmp
wpview d:\objview.tmp
del d:\objview.tmp
