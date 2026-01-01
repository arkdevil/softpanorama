rem  V.S. Rabets  14-03-91
LHA x /a /i1 /l1 %1
@if errorlevel 1 echo 	[1;5mError[0m
@if errorlevel 1 pause
@if not errorlevel 1 echo [1m  OK![0m
