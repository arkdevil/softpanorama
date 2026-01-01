echo      Принтер EPSON FX-800
@echo     Принтер EPSON FX-800 > pretmp.tmp
@echo 1 - подчеркивание >> pretmp.tmp
@echo 2 - отменить  подчеркивание >> pretmp.tmp
@echo 3 - высокий шрифт >> pretmp.tmp
@echo 4 - отменить высокий шрифт >> pretmp.tmp
@echo 5 - ужиренение одного слова >> pretmp.tmp
@echo 6 - нижний индекс >> pretmp.tmp
@echo 7 - отменить индекс >> pretmp.tmp
prpage %1 h72 L120 v n z p1-1 p2-0 p3w1 p4w0 p5E p.F p6S1 p7T p*pretmp.tmp %2 %3 %4 %5 %6 %7 %8 %9
del pretmp.tmp
