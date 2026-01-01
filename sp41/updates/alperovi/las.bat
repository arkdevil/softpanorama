@echo off
rem Принтер:  Hewlett Packard LaserJet IIP
what Y
set qq0=%WHAT%
what YE
set qq1=prpage %1
set qq2=v fprn z d2 n %2 %3 %4 %5 %6 %7 %8 %9
ask "Вариант печати 123456789abcdefg:",123456789abcdefg 
if errorlevel 16 goto pg
if errorlevel 15 goto pf
if errorlevel 14 goto pe
if errorlevel 13 goto pd
if errorlevel 12 goto pc
if errorlevel 11 goto pb
if errorlevel 10 goto pa
if errorlevel 9 goto p9
if errorlevel 8 goto p8
if errorlevel 7 goto p7
if errorlevel 6 goto p6
if errorlevel 5 goto p5
if errorlevel 4 goto p4
if errorlevel 3 goto p3
if errorlevel 2 goto p2
if errorlevel 1 goto p1
:p1
%qq1% x7 h64 l100 p!(1004X p.&l0O p.&k10H p.&l8C %qq2%
goto ex1
:p2
%qq1% x7 h102 l120 p!(1006X p.&l0O p.&k6H p.&l5C %qq2%
goto ex1
:p3
%qq1% x7 h64 l80 p!(1009X p.&l0O p.&k10H p.&l8C %qq2%
goto ex1
:p4
%qq1% x7 h85 l100 p!(1008X p.&l0O p.&k10H p.&l6C %qq2%
goto ex1
:p5
%qq1% x7 h58 l160-10 p!(1010X p.&l1O p.&k8H p.&l6C %qq2%
goto ex1
:p6
%qq1% x7 h58 l140-10 p!(1003X p.&l1O p.&k9H p.&l6C %qq2%
goto ex1
:p7
%qq1% x7 h85 l100 p!(1011X p.&l0O p.&k8H p.&l6C %qq2%
goto ex1
:p8
%qq1% x7 h116 l318-1-4 p!(1013X p.&l1O p.&k4H p.&l3C %qq2%
goto ex1
:p9
%qq1% x10 h171 l240-9-3 p!(1013X p.&l0O p.&k4H p.&l3C %qq2%
goto ex1
:pa
%qq1% h102 l164-1 p!(1014X p.&l0O p.&k6H p.&l5C %qq2%
goto ex1
:pb
%qq1% x7 h64 l80 p!(1008X p.&l0O p.&k10H p.&l8C %qq2%
goto ex1
:pc
%qq1% x10 h102 l120 p!(1014X p.&l0O p.&k6H p.&l5C %qq2%
goto ex1
:pd
%qq1% x14 h102 l143-1 p!(1006X p.&l0O p.&k6H p.&l5C %qq2%
goto ex1
:pe
%qq1% h70 l235-1-3 p!(1006X p.&l1O p.&k6H p.&l5C %qq2%
goto ex1
:pf
%qq1% x7 h58 l140-10 p!(1008X p.&l1O p.&k9H p.&l6C %qq2%
goto ex1
:pg
%qq1% x4 h43 l130 p!(1004X p.&l1O p.&k10H p.&l8C %qq2% d1
goto ex1
:ex1
%WHAT%:
cd %QQ0%
