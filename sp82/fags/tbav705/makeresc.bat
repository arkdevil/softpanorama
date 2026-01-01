@echo off
echo off
if %1X==X goto help1
if not exist %1\Command.Com goto help2
if exist TbScan.Exe goto tbavdir
cd \tbav
if not exist TbScan.Exe goto help3
:tbavdir
echo Copying TBAV utilities to drive %1, please wait...
Copy TBAV.Exe %1 >nul
Copy TBAV.Lng %1 >nul
if exist TBAV.KEY Copy TBAV.KEY %1 >nul
Copy TbScan.Exe %1 >nul
Copy TbScan.Eci %1 >nul
Copy TbScan.Lng %1 >nul
Copy TbScan.Sig %1 >nul
Copy TbDriver.Exe %1 >nul
Copy TbDriver.Lng %1 >nul
Copy TbCheck.Exe %1 >nul
Copy TbClean.Exe %1 >nul
Copy TbUtil.Exe %1 >nul
Copy TbUtil.Lng %1 >nul

TbUtil store %1\TbUtil.Dat

Echo Files=20 >%1\Config.Sys
Echo Buffers=20 >>%1\Config.Sys
If exist TbDriver.Exe Echo Device=TbDriver.Exe >>%1\Config.Sys
If exist TbCheck.Exe Echo Device=TbCheck.Exe FullCRC >>%1\Config.Sys

Echo @echo off >%1\AutoExec.Bat
Echo echo off >>%1\AutoExec.Bat
Echo PATH=A:\ >>%1\AutoExec.Bat
If exist TBAV.EXE Echo TBAV >>%1\AutoExec.Bat
Echo Cls >>%1\AutoExec.Bat
Echo Echo WARNING!!! >>%1\AutoExec.Bat
Echo Echo If you suspect a virus, do NOT execute anything from the hard disk! >>%1\AutoExec.Bat

Echo The rescue diskette is almost ready!
Echo TbSetup will now generate the Anti-Vir.Dat file for drive %1
Pause
TbSetup %1

CLS
Echo The rescue diskette is now ready.
Echo If you need to copy other utilities to the disk, you can do so now.
Echo If you do so, do not forget to run TbSetup %1 when ready.
Echo.
Echo MAKE SURE THE DISK IN DRIVE %1 IS WRITE PROTECTED!

goto end

:help1
Echo Please specify the drive which contains the rescue diskette!
goto end

:help2
Echo The disk in drive %1 should be bootable. You can make the disk
Echo bootable by using the command: SYS %1
goto end

:help3
Echo Can not locate the TBAV utilities.
Echo Please make the directory that contains the TBAV utilities the
Echo current directory!

:end
