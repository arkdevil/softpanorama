@echo off
set GO=%1
if "%1"=="" set GO=clarion
SET LIB=d:\CLARION
SET OBJ=d:\CLARION
:Cls
:Echo Евгений Георгиевич!
:Echo -------------------
:Echo.
:Echo Ку-Ку
:Echo.
:Echo С наилучшими пожеланиями!
:Echo.
:Echo (От меня)
:pause > Nul
: SET 87=Y                                - если есть сопроцессор
: edos %GO% %2 %3 %4 %5 %6 %7 %8 %9       - если есть EDOS
%GO% %2 %3 %4 %5 %6 %7 %8 %9
