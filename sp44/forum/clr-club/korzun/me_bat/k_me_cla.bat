@echo off
SET LIB=d:\CLARION
SET OBJ=d:\CLARION
: SET 87=Y                                - если есть сопроцессор
: edos %GO% %2 %3 %4 %5 %6 %7 %8 %9       - если есть EDOS
%GO% %2 %3 %4 %5 %6 %7 %8 %9
