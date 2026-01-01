@echo off
rem  V.S. Rabets  14-03-91
ARJ x -y -- %1
@if errorlevel 1 echo 	[1;5mError[0m
@if errorlevel 1 pause
@if not errorlevel 1 echo [1m  OK![0m
