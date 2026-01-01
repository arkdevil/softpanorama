@echo off
echo off
echo        --- Thunderbyte Anti-Virus installation batch program ---
echo.

rem     * Make sure that we can find the utilities in the current directory
if not exist TBSCAN.EXE goto error1

rem     * Find out if we are upgrading a previous version in the current dir
if exist TBSTART.BAT goto pathexists

rem     * Make sure that the user specified a destination path
if %1X==X goto error2

rem     * Make sure the target path exists or can be created
if exist %1\nul goto pathexists
md %1
if not exist %1\nul goto error3
:pathexists

rem     * Make sure user did not type something like 'C:' :-)
if exist %1\CONFIG.SYS goto error5

echo Please read the License.Doc file. By using the TBAV package you
echo agree with our license agreement. You can print the License.Doc
echo file by typing the following command on the DOS command line:
echo    Copy License.Doc Lpt1
echo Press Ctrl-C to abort this installation batch file, or
pause

echo.
echo This installation batch file of the shareware version of TBAV
echo is not the same as the full featured installation program of the
echo commercial version of TBAV. (The main reason for the omission of
echo the installation program is to save disk space and to minimize
echo download time). Therefore the installation procedure might
echo differ from the procedure described in the manual.
echo.

rem     * If TbScanX is active, de-activate it.
if not exist SCANX goto notres
if exist %1\tbscanx.exe %1\tbscanx /off

:notres
rem     * Copy the TBAV utilities if necessary
if exist dummy.tst del dummy.tst >nul
if exist %1\dummy.tst del %1\dummy.tst >nul
echo TEST >%1\dummy.tst
if exist dummy.tst goto filesexists
if not exist %1\dummy.tst goto error4
echo TbSetup will now delete the Anti-Vir.Dat file of a previous
echo TBAV version if it exists in directory %1
pause
rem     * If Anti-Vir.Dat already exists and is hidden, delete it...
tbsetup %1 remove
cls
echo Copying files. Please wait...
copy addendum.doc %1 >nul
copy agents.doc %1 >nul
copy anti-vir.dat %1 >nul
copy appnotes.doc %1 >nul
copy esass.pgp %1 >nul
copy file_id.diz %1 >nul
copy install.bat %1 >nul
copy license.doc %1 >nul
copy makeresc.bat %1 >nul
copy no_vsum.doc %1 >nul
copy register.exe %1 >nul
copy report.doc %1 >nul
copy security.doc %1 >nul
copy tbav.doc %1 >nul
copy tbav.exe %1 >nul
copy tbav.lng %1 >nul
copy tbav.msg %1 >nul
copy tbcheck.exe %1 >nul
copy tbclean.exe %1 >nul
copy tbdel.com %1 >nul
copy tbdisk.exe %1 >nul
copy tbdriver.exe %1 >nul
copy tbdriver.lng %1 >nul
copy tbfile.exe %1 >nul
copy tbgensig.exe %1 >nul
copy tbkey.exe %1 >nul
copy tblog.exe %1 >nul
copy tbmem.exe %1 >nul
copy tbscan.eci %1 >nul
copy tbscan.exe %1 >nul
copy tbscan.lng %1 >nul
copy tbscan.sig %1 >nul
copy tbscanx.exe %1 >nul
copy tbsetup.dat %1 >nul
copy tbsetup.exe %1 >nul
copy tbutil.exe %1 >nul
copy tbutil.lng %1 >nul
copy veldman.pgp %1 >nul
copy tbav.faq %1 >nul
copy tbmon.com %1 >nul
copy whatsnew.* %1 >nul
if %_4ver%x==x copy descript.ion %1 >nul

:filesexists
del %1\dummy.tst >nul
if not exist %1\docs.exe goto nopack
%1\docs -o %1
del %1\docs.exe >nul
:nopack

rem     * DOS has no interactive batch file commands,
rem     * so we create a special program to solve that!
rem     * the 'garbage' in the echo command is program code
rem     * to read a key into an errorlevel, the program code
rem     * will be copied into an executable file.
echo ÍˆàÏ´LÍ! >%1\ask.com

echo.
echo TbSetup will now generate or update the Anti-Vir.Dat file
echo of the directory %1
pause
rem     * create or update the Anti-Vir.Dat records of the TBAV utilities
%1\TBSETUP %1

cls
rem     * do not overwrite an existing TBAV setup.
if exist %1\TBSTART.BAT goto upgrade

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
if not errorlevel 1 goto nosetup

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
echo TbSetup will now process your drives to generate the Anti-Vir.Dat files.
pause
rem     * process the rest of the machine, but do not touch existing information!
%1\TbSetup NewOnly AllDrives

:tbdriver
cls
echo.
echo The TBAV package contains some utilities that can be installed in the memory
echo of your PC. Do you want to add them to your AUTOEXEC.BAT file? (Y/n)
%1\ask
if not errorlevel 1 goto autoscan
rem     * create a TBSTART.BAT file in the TBAV directory.
echo %1\TbDriver >>%1\TBSTART.BAT

echo.
echo TBSCANX is a memory resident virus scanner.
echo Do you want to install it? (Y/n)
%1\ask
if not errorlevel 1 goto tbcheck
rem     * add the TbScanX statement to the TBSTART.BAT file.
echo %1\TbScanX EMS XMS >>%1\TBSTART.BAT

:tbcheck
echo.
echo TBCHECK is a memory resident integrity checker.
echo Do you want to install it? (Y/n)
%1\ask
if not errorlevel 1 goto tbmem
rem     * add the TbCheck statement to the TBSTART.BAT file.
echo %1\TbCheck noavok=ab >>%1\TBSTART.BAT

:tbmem
echo.
echo TBMEM is a resident memory guard.
echo Do you want to install it? (Y/n)
%1\ask
if not errorlevel 1 goto tbfile
rem     * add the TbMem statement to the TBSTART.BAT file.
echo %1\TbMem >>%1\TBSTART.BAT

:tbfile
echo.
echo TBFILE is a resident file guard.
echo Do you want to install it? (Y/n)
%1\ask
if not errorlevel 1 goto autoscan
rem     * add the TbFile statement to the TBSTART.BAT file.
echo %1\TbFile >>%1\TBSTART.BAT

:autoscan
echo.
echo Do you want the system to be scanned automatically for viruses every day? (Y/n)
%1\ask
if not errorlevel 1 goto addcall
rem     * add the TbScan statement to the TBSTART.BAT file.
echo %1\TbScan Once AllDrives >>%1\TBSTART.BAT

:addcall
if exist C:\TEMP.BAT del C:\TEMP.BAT >nul
echo call %1\TBSTART.BAT >C:\TEMP.BAT
copy /a C:\TEMP.BAT + C:\AUTOEXEC.BAT C:\TEMP2.BAT >nul
copy C:\TEMP2.BAT C:\AUTOEXEC.BAT >nul
del C:\TEMP.BAT >nul
del C:\TEMP2.BAT >nul

:ready
echo.
echo Do you want to scan your drives now? (Y/n)
%1\ask
if not errorlevel 1 goto starttbav
%1\TbScan AllDrives

:starttbav
cls
:nosetup
echo.
echo It is highly recommended to print the TBAV user manual.
echo You can do this with the following DOS command:
echo    Copy TBAV.DOC Lpt1
echo.
echo If you are upgrading from previous TBAV versions, it is recommended
echo to print the WHATSNEW files and the Addendum.Doc.
echo You can do this with the following DOS command:
echo    Copy WHATSNEW.* Lpt1
echo    Copy ADDENDUM.DOC Lpt1
echo.
echo The menu program TBAV.EXE can be used to read the documentation files.
echo Do you want to start TBAV now? (Y/n)
%1\ask
if not errorlevel 1 goto flush
%1\TBAV
goto end

:upgrade
echo.
if exist %1\UserSig.Dat %1\TbGenSig
rem     * Delete all stuff we don't support anymore
echo Install.Bat will delete some obsolete files from previous TBAV
echo versions which are not supported anymore.
echo.
if exist %1\TbScan.Com del %1\TbScan.Com >nul
if exist %1\TbScan.Msg del %1\TbScan.Msg >nul
if exist %1\VirScan.Dat del %1\VirScan.Dat >nul
if exist %1\AddnSigs.Dat del %1\AddnSigs.Dat >nul
if exist %1\ComprSca.* del %1\ComprSca.* >nul
if exist %1\*.AVR del %1\*.AVR >nul
if exist %1\MTE.Doc del %1\MTE.Doc >nul
if exist %1\Washburn.Doc del %1\Washburn.Doc >nul
if exist %1\TbScanX.Com del %1\TbScanX.Com >nul
if exist %1\TbRescue.* del %1\TbRescue.* >nul
if exist %1\TBAV.CFG del %1\TBAV.CFG >nul
if exist %1\TbShell.* del %1\TbShell.* >nul
if exist %1\register.exe ren %1\register.exe reg.exe >nul
if exist %1\register.txt ren %1\register.txt reg.txt >nul
if exist %1\register.* del %1\register.* >nul
if exist %1\reg.exe ren %1\reg.exe register.exe >nul
if exist %1\reg.txt ren %1\reg.txt register.txt >nul
if exist %1\TbGarble.* del %1\TbGarble.* >nul
if exist %1\GetBoot.* del %1\GetBoot.* >nul
if exist %1\Intro.Doc del %1\Intro.Doc >nul
if exist %1\TbSetup.Doc del %1\TbSetup.Doc >nul
if exist %1\TbUtil.Doc del %1\TbUtil.Doc >nul
if exist %1\TbScan.Doc del %1\TbScan.Doc >nul
if exist %1\TbClean.Doc del %1\TbClean.Doc >nul
if exist %1\StackMan.Doc del %1\StackMan.Doc >nul
if exist %1\TbGensig.Doc del %1\TbGensig.Doc >nul
if exist %1\TbDriver.Doc del %1\TbDriver.Doc >nul
if exist %1\TbScanX.Doc del %1\TbScanX.Doc >nul
if exist %1\TbCheck.Doc del %1\TbCheck.Doc >nul
if exist %1\TbMem.Doc del %1\TbMem.Doc >nul
if exist %1\TbFile.Doc del %1\TbFile.Doc >nul
if exist %1\TbDisk.Doc del %1\TbDisk.Doc >nul
if exist %1\TbDel.Doc del %1\TbDel.Doc >nul
if exist %1\Upgrade.Bat del %1\Upgrade.Bat >nul
if exist %1\TBAV.ICO del %1\TBAV.ICO >nul
if exist %1\TBAV.PIF del %1\TBAV.PIF >nul
echo All obsolete TBAV files have been removed.
echo.
if not exist %1\StackMan.Exe goto ready
echo Note: StackMan.Exe is not necessary anymore to solve TBAV problems.
echo StackMan is therefor no longer supplied with the shareware TBAV package.
echo If you do not use StackMan, you can delete it from the TBAV directory.
goto ready

:error1
echo Error: Invalid program invocation!
echo.
echo Make sure that you invoke INSTALL.BAT in the directory where the
echo TBAV utilities can be found!
echo.
echo Example: if the TBAV utilities can be found on drive A:, you should type:
echo A: [enter]
echo INSTALL [path] [enter]
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

:flush
echo.
echo If you have a disk cache installed, wait a few seconds to allow the
echo cache to flush the buffers, and reboot...

:end
if exist %1\ask.com del %1\ask.com >nul

