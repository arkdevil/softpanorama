rem This batch file does an errorlevel check for VirusScan.  It will
rem not install the product unless all checks are passed.  If an
rem error is encounterred during the scan, it will be reported.

cls
@echo off
echo.
echo Now SCANNING your memory and your local drives before INSTALLING,
echo please wait...
echo.

SCAN /ADL /NOBREAK

if errorlevel 100 goto error100
if errorlevel 19 goto error19
if errorlevel 18 goto error18
if errorlevel 17 goto error17
if errorlevel 16 goto error16
if errorlevel 15 goto error15
if errorlevel 14 goto error14
if errorlevel 13 goto error13
if errorlevel 12 goto error12
if errorlevel 11 goto error11
if errorlevel 10 goto error10
if errorlevel 9 goto error9
if errorlevel 8 goto error8
if errorlevel 7 goto error7
if errorlevel 6 goto error6
if errorlevel 5 goto error5
if errorlevel 4 goto error4
if errorlevel 3 goto error3
if errorlevel 2 goto error2
if errorlevel 1 goto error1
if errorlevel 0 goto install

echo.
echo An error occurred during installation.  Please contact
echo McAfee Associates Technical Support for assistance.
goto end

:install
if exist inst.exe goto DiskOk
goto install
:DiskOk
inst
goto end

:error100
echo.
echo ***  WARNING  ***                 ***  OPERATING SYSTEM ERROR  ***
echo ***  ERROR # 100
echo.
echo Operating system error; Scan adds 100 to the original error number.
echo Please contact McAfee Associates Technical Support for assistance.
pause
goto end

:error19
echo.
echo ***  WARNING  ***                               ***  RESERVED  ***
echo ***  ERROR # 19
echo.
echo Please contact McAfee Associates Technical Support for assistance.
pause
goto end

:error18
echo.
echo ***  WARNING  ***                             ***  FILE ERROR  ***
echo ***  ERROR # 18
echo.
echo A validated file has been modified (/CF or /CV options).
echo Please refer to your documentation or contact McAfee Associates
echo Technical Support for assistance.
pause
goto end

:error17
echo.
echo ***  WARNING  ***                          ***  COMMAND ERROR  ***
echo *** ERROR # 17
echo.
echo No drive, directory or file was specified; nothing to scan.
echo Please refer to your documentation or contact McAfee Associates
echo Technical Support for assistance.
pause
goto end

:error16
echo.
echo ***  WARNING  ***                           ***  ACCESS ERROR  ***
echo ***  ERROR # 16
echo.
echo An error occurred while accessing a specified drive or file.
echo Please refer to your documentation or contact McAfee Associates
echo Technical Support for assistance.
pause
goto end

:error15
echo.
echo ***  WARNING  ***                      ***  SELF-CHECK FAILED  ***
echo ***  ERROR # 15
echo.
echo VirusScan self-check failed.  It may be infected or damaged.
echo Please refer to your documentation or contact McAfee Associates
echo Technical Support for assistance.
pause
goto end

:error14
echo.
echo ***  WARNING  ***                        ***  DATA FILE ERROR  ***
echo ***  ERROR # 14
echo.
echo The SCAN.DAT file is out of date; upgrade VirusScan data files.
echo Please refer to your documentation or contact McAfee Associates
echo Technical Support for assistance.
pause
goto end

:error13
echo.
echo ***  WARNING  ***                            ***  VIRUS FOUND  ***
echo ***  ERROR # 13
echo.
echo One or more viruses was found in the master boot record, boot
echo sector, or file(s).
echo Please refer to your documentation or contact McAfee Associates
echo Technical Support for assistance.
pause
goto end

:error12
echo.
echo ***  WARNING  ***                            ***  VIRUS FOUND  ***
echo ***  ERROR # 12
echo.
echo An error occurred while attempting to remove a virus, such as no
echo CLEAN.DAT file found, or VirusScan was unable to remove the virus.
echo Please refer to your documentation or contact McAfee Associates
echo Technical Support for assistance.
pause
goto end

:error11
echo.
echo ***  WARNING  ***                           *** PROGRAM ERROR  *** 
echo *** ERROR # 11
echo.
echo An internal program communication error occurred.
echo Please refer to your documentation or contact McAfee Associates
echo Technical Support for assistance.
pause
goto end

:error10
echo.
echo ***  WARNING  ***                            ***  VIRUS FOUND  ***
echo ***  ERROR # 10
echo.
echo A virus was found in memory.  You must clean the virus from your
echo system before installing.
echo Please refer to your documentation or contact McAfee Associates
echo Technical Support for assistance.
pause
goto end

:error9
echo.
echo ***  WARNING  ***                           ***  OPTION ERROR  ***                        
echo ***  ERROR # 9
echo.
echo Incompatible or unrecognized option(s) or option arguments(s) were
echo specified in the command line.
echo Please refer to your documentation or contact McAfee Associates
echo Technical Support for assistance.
pause
goto end

:error8
echo.
echo ***  WARNING  ***                     ***  MISSING FILE ERROR  ***
echo ***  ERROR # 8
echo.
echo A file required to run VirusScan, such as SCAN.DAT, is missing.
echo Please refer to your documentation or contact McAfee Associates
echo Technical Support for assistance.
pause
goto end

:error7
echo.
echo ***  WARNING  ***                     ***  MESSAGE FILE ERROR  ***
echo ***  ERROR # 7
echo.
echo An error occurred in accessing an internatinal message file 
echo (MCAFEE.MSG).
echo Please refer to your documentation or contact McAfee Associates
echo Technical Support for assistance.
pause
goto end

:error6
echo.
echo ***  WARNING  ***                          ***  PROGRAM ERROR  ***
echo *** ERROR # 6
echo.
echo An internal program system error occurred.
echo Please refer to your documentation or contact McAfee Associates
echo Technical Support for assistance.
pause
goto end

:error5
echo.
echo ***  WARNING  ***              ***  INSUFFICIENT MEMORY ERROR  ***
echo ***  ERROR # 5
echo.
echo Insufficient memory to load program or complete operation.
echo Please refer to your documentation or contact McAfee Associates
echo Technical Support for assistance.
pause
goto end

:error4
echo.
echo ***  WARNING  ***                     ***  DAMAGED FILE ERROR  ***
echo *** ERROR # 4
echo.
echo An error occurred while accessing the file created with the /AF
echo option.  The file has been damaged.
echo Please refer to your documentation or contact McAfee Associates
echo Technical Support for assistance.
pause
goto end

:error3
echo.
echo ***  WARNING  ***                      ***  DISK ACCESS ERROR  ***
echo *** ERROR # 3
echo.
echo An error occurred while accessing a disk (reading or writing).
echo Please refer to your documentation or contact McAfee Associates
echo Technical Support for assistance.
pause
goto end

:error2
echo.
echo ***  WARNING  ***                     ***  CORRUPT FILE ERROR  ***
echo ***  ERROR # 2
echo.
echo A VirusScan database (*.DAT) file is corrupted.
echo Please refer to your documentation or contact McAfee Associates
echo Technical Support for assistance.
pause
goto end

:error1
echo.
echo ***  WARNING  ***                      ***  FILE ACCESS ERROR  ***
echo ***  ERROR # 1
echo.
echo An error occurred while accessing a file (reading or writing).
echo Please refer to your documentation or contact McAfee Associates
echo Technical Support for assistance.
pause

:end

