rem  V.S.Rabets 13-03-91
lhArc a /a /r %1 %2 %3 %4 %5 %6 %7 %8 %9
@if errorlevel 1 echo 	[1;5mError[0m
@if errorlevel 1 pause
@if not errorlevel 1 echo [1m  OK![0m
