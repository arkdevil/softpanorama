rem  V.S.Rabets 04-04-91
LHA s /x1 /@1 %1
@if errorlevel 1 echo 	[1;5mError[0m
@if errorlevel 1 pause
@if not errorlevel 1 echo [1m  OK![0m
