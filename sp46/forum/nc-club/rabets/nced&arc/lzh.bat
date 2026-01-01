rem  V.S.Rabets 04-04-91
LHA a /x /a1 /r1 /l1 /@1 %1 %2 %3 %4 %5 %6 %7 %8 %9
@if errorlevel 1 echo 	[1;5mError[0m
@if errorlevel 3 echo [7m Rename %TMP%LHtmp)2(.LZH to %1 [0m
@if errorlevel 1 pause
@if not errorlevel 1 echo [1m  OK![0m
