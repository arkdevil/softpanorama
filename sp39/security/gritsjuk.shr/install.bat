@echo off
@mkdir c:\anextpro
@copy  anextv2b.bin c:\anextpro
@copy  acsxmscf.exe c:\anextpro
@copy  finaldat.exe c:\anextpro
@copy  mysetLAS.exe c:\anextpro
@Copy  *.doc	    c:\anextpro
@copy  readme.!!!   c:\anextpro
@copy  *.hlp	    c:\anextpro
ansetup
@ask "Do you want change your master boot record (Yes/No)?", yn
@if errorlevel 3 goto quit
@if errorlevel 2 goto quit
setmsbr.exe
@echo *
@echo ATTENTION!!! You must change your AUTOEXEC.BAT and CONFIG.SYS
@ECHO read doc file for more information  
:quit
@ASK "Do you want change your AUTOEXEC.BAT and CONFIG.SYS (Yes/No) ", yn
@if errorlevel 2 goto quit1
@copy autoexec.add+c:\autoexec.bat c:\autoexec.anx
@copy	c:\config.sys + config.add c:\config.anx
@ren	c:\config.sys config.old
@ren	c:\config.anx config.sys
@ren	c:\autoexec.bat autoexec.old
@ren	c:\autoexec.anx autoexec.bat
@echo    *
@echo	You old Autoexec and Config was renamed with extention OLD
 
:quit1
echo *
echo ANEXTPRO installed sucsesfully

