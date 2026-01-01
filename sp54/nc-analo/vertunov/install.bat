@echo off
cls
echo ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
echo ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                                                ▓▓▓▓▓▓▓▓▓▓▓▓▓▓░
echo ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓       SHORT 1.20  installation procedure       ▓▓▓▓▓▓▓▓▓▓▓▓▓▓░
echo ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                                                ▓▓▓▓▓▓▓▓▓▓▓▓▓▓░
echo ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓           (C) 1992 Rambling Software           ▓▓▓▓▓▓▓▓▓▓▓▓▓▓░
echo ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                                                ▓▓▓▓▓▓▓▓▓▓▓▓▓▓░
echo ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░
echo  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
echo ───────────────────────────────────────────────────────────────────────────────
if (%1) == () goto Instr
:Install
md %1%2
echo Main files...
copy >nul pcs.exe %1%2
copy >nul pcs.hlp %1%2
copy >nul calc.exe %1%2
echo Examples...
copy >nul pcs.mnu %1%2
copy >nul pcs.ext %1%2
copy >nul pcs.viw %1%2
md %1%2\menu
copy >nul *.mnu %1%2\menu
echo Some doc files...
copy >nul readme %1%2
copy >nul menu.txt %1%2
copy >nul ext.txt %1%2
cd %1%2
%1
echo Installation completed.
echo For automatic start of SHORT you may append to your AUTOEXEC.BAT
echo the following line:
echo 	%1%2\PCS  [Return]
echo To run the SHORT, type:
echo 	PCS  [Return]
echo ───────────────────────────────────────────────────────────────────────────────
goto Exit
:Instr
echo               I n s t a l l a t i o n    i n s t r u c t i o n s
echo ───────────────────────────────────────────────────────────────────────────────
echo   To install SHORT 1.20 to your system insert distributive disk in drive A 
echo and type following:
echo  
echo 	A:  [Return]
echo 	install  d:  path  [Return]
echo  
echo d: - drive to install to,  path - path to install to.
echo  
echo For example:  INSTALL  C:  \SHORT [Return]  (Note space between drive and path)
echo ───────────────────────────────────────────────────────────────────────────────
:Exit
