@echo off
echo off
cls
echo        --- Thunderbyte Anti-Virus installation batch program ---
echo.

rem     * Make sure that we can find the utilities in the current directory
if not exist TBAV.EXE goto error1

rem     * Make sure that the user specified a destination path
if %1X==X goto error2

rem     * Make sure the target path exists or can be created
if exist %1\nul goto pathexists
md %1
if not exist %1\nul goto error3
:pathexists

rem     * Make sure user did not type something like 'C:' :-)
if exist %1\CONFIG.SYS goto error5

rem     * Copy the TBAV utilities if necessary
if exist dummy.tst del dummy.tst >nul
if exist %1\dummy.tst del %1\dummy.tst
echo TEST >%1\dummy.tst
if exist dummy.tst goto filesexist
if not exist %1\dummy.tst goto error4
echo Copying files. Please wait...
copy *.* %1 >nul
echo.
:filesexist
del %1\dummy.tst >nul

rem     * DOS has no interactive batch file commands,
rem     * so we create a special program to solve that!
rem     * the 'garbage' in the echo command is program code
rem     * to read a key into an errorlevel, we copy the program code
rem     * into something executable.
echo ÍˆàÏ´LÍ! >%1\ask.com

echo.
echo TbSetup will now generate or update the Anti-Vir.Dat file
echo of the directory %1
pause
rem     * create or update the Anti-Vir.Dat records of the TBAV utilities
%1\TBSETUP %1

cls
rem     * do not overwrite an existing TBAV setup.
if exist %1\TBSTART.BAT goto ready

echo.
echo The Thunderbyte Anti-Virus utilities have been copied to the destination
echo directory. It is recommended to read the documentation of TBAV thoroughly
echo and to make a customized setup. One of the advantages of the Thunderbyte
echo Anti-Virus utilities is flexibility and the possibility to configure
echo them to suit your needs in an optimal way.
echo.
echo This installation batch file helps you to setup the utilities in their
echo most standard and non-customized way.
echo Do you want to continue? (Y/n)
%1\ask
if not errorlevel 1 goto ready

rem     * make a backup of the AUTOEXEC.BAT file!
echo.
echo Backing up C:\AUTOEXEC.BAT to C:\AUTOEXEC.ORG...
copy c:\autoexec.bat c:\autoexec.org >nul

rem     * create a TBSTART.BAT file in the TBAV directory.
echo @echo off >%1\TBSTART.BAT
echo echo off >>%1\TBSTART.BAT

echo.
echo For easy access of the TBAV utilities it is recommended to put them
echo into your PATH environment variable.
echo Do you want to add %1 to your PATH statement? (Y/n)
%1\ask
if not errorlevel 1 goto dosetup
rem     * add the PATH statement to the end of the AUTOEXEC.BAT file.
echo PATH=%%PATH%%;%1 >>C:\AUTOEXEC.BAT

:dosetup
echo.
echo TbSetup will now process the C:\ drive to generate the Anti-Vir.Dat files.
echo You may need to repeat this process for other drives.
pause
rem     * process the rest of the machine, but do not touch existing information!
%1\TBSETUP newonly C:\

:tbdriver
cls
echo.
echo The TBAV package contains some utilities that can be installed in the memory
echo of your PC. Do you want to add them to your AUTOEXEC.BAT file? (Y/n)
%1\ask
if not errorlevel 1 goto autoscan
rem     * create a TBSTART.BAT file in the TBAV directory.
echo %1\tbdriver >>%1\TBSTART.BAT

if not exist %1\VIRSCAN.DAT goto tbcheck
echo.
echo TBSCANX is a memory resident virus scanner.
echo Do you want to install it? (Y/n)
%1\ask
if not errorlevel 1 goto tbcheck
rem     * add the TbScanX statement to the TBSTART.BAT file.
echo %1\tbscanx >>%1\TBSTART.BAT

:tbcheck
echo.
echo TBCHECK is a memory resident integrity checker.
echo Do you want to install it? (Y/n)
%1\ask
if not errorlevel 1 goto tbmem
rem     * add the TbCheck statement to the TBSTART.BAT file.
echo %1\tbcheck >>%1\TBSTART.BAT

:tbmem
echo.
echo TBMEM is a resident memory guard.
echo Do you want to install it? (Y/n)
%1\ask
if not errorlevel 1 goto tbfile
rem     * add the TbMem statement to the TBSTART.BAT file.
echo %1\tbmem >>%1\TBSTART.BAT

:tbfile
echo.
echo TBFILE is a resident file guard.
echo Do you want to install it? (Y/n)
%1\ask
if not errorlevel 1 goto autoscan
rem     * add the TbFile statement to the TBSTART.BAT file.
echo %1\tbfile >>%1\TBSTART.BAT

:autoscan
if not exist %1\VIRSCAN.DAT goto addcall
echo.
echo Do you want the system to be scanned automatically for viruses every day? (Y/n)
%1\ask
if not errorlevel 1 goto addcall
rem     * add the TbScan statement to the TBSTART.BAT file.
echo %1\tbscan once C:\ >>%1\TBSTART.BAT

:addcall
if exist C:\TEMP.BAT del C:\TEMP.BAT >nul
echo call %1\TBSTART.BAT >C:\TEMP.BAT
copy /a C:\TEMP.BAT + C:\AUTOEXEC.BAT C:\TEMP2.BAT >nul
copy C:\TEMP2.BAT C:\AUTOEXEC.BAT >nul
del C:\TEMP.BAT >nul
del C:\TEMP2.BAT >nul

:ready
if not exist %1\VIRSCAN.DAT goto novirscan
echo.
echo Do you want to scan the C:\ disk now? (Y/n)
%1\ask
if not errorlevel 1 goto starttbav
%1\tbscan C:\
goto starttbav

:novirscan
echo.
echo VIRSCAN.DAT has not been found on your system. This file is required if
echo you want to use TbScan or TbScanX. You can obtain a recent VIRSCAN.DAT
echo on most Thunderbyte support Bulletin Board Systems.

:starttbav
echo.
echo TbSetup has been used to setup disk C:\. If your system has additional
echo disk partitions, you have to use TBSETUP on your other disks as well.
echo Consult the documentation for more information!
echo.
echo The menu program TBAV.EXE can be used to read the documentation files.
echo Do you want to start TBAV now? (Y/n)
%1\ask
if not errorlevel 1 goto end
%1\TBAV
goto end

:error1
echo Error: Invalid program invocation!
echo.
echo Make sure that you invoke INSTALL.BAT in the directory where the
echo TBAV utilities can be found!
echo.
echo Example: if the TBAV utilities can be found on drive A:, you should type:
echo A: <enter>
echo INSTALL <path> <enter>
goto end

:error2
echo Error: No destination path specified!
echo.
echo You have to specify the destination path for the TBAV utilities!
echo Even if the utilities are already in the destination path.
echo.
echo Example:
echo If the TBAV utilities are or should be copied to C:\TBAV, please type:
echo INSTALL C:\TBAV
goto end

:error3
echo Error: Unable to creat destination directory %1
echo.
echo Make sure you enter an existing destination path or a path that can be created!
goto end

:error4
echo Error: Unable to copy files in directory %1
echo.
echo Disk full? Access denied?
goto end

:error5
echo Error: No target directory specified!
echo.
echo Make sure you enter a full destination path!
echo %1 is not sufficient!
echo.
echo Example:
echo If the TBAV utilities are or should be copied to C:\TBAV, please type:
echo INSTALL C:\TBAV
goto end

:end
if exist %1\ask.com del %1\ask.com >nul

