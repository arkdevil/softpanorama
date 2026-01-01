@ECHO OFF
ECHO             WINPROOF HARD DISK INSTALLATION INSTRUCTIONS
ECHO Make a new directory for WinProof and switch to it.  Example:
ECHO MKDIR WINPROOF
ECHO CD WINPROOF
ECHO Then type the command A:INSTALL if you are installing from drive A: or
ECHO B:INSTALL B: if you are installing from drive B:.
ECHO You will need 850K bytes free on your hard disk.
ECHO ╔═══════════════════════════════════════════════════════╗
ECHO ║ DID YOU MAKE A SUBDIRECTORY AND MADE IT YOUR DEFAULT? ║
ECHO ╚═══════════════════════════════════════════════════════╝
ECHO Press Control-C to stop installation.
pause
IF exist WINPRO.EXE goto ndrive
IF %1. == . goto NDEFDRV
If not exist %1\nul goto NEEDARG
IF not exist %1WINPRO.EXE goto NEEDARG
%1WINPRO.EXE /e.
IF not exist WINPROOF.tut goto ERROR
goto COPYDONE
:NDEFDRV
If not exist a:\nul goto NEEDARG
IF not exist a:WINPRO.EXE goto NEEDARG
a:WINPRO.EXE /e.
IF not exist WINPROOF.tut goto ERROR
:COPYDONE
If not errorlevel 0 goto ERROR
more < WINPROOF.doc
ECHO Installation is complete.
goto done
:ndrive
ECHO You cannot install WinProof while your default drive is the same as
ECHO the installation drive.  Please switch to the drive and subdirectory
ECHO you want to install WinProof to.
goto fail
:ERROR
echo One or more of the WinProof files failed to copy. Check if there is
echo 850K bytes avaliable on your hard disk.  Also check if the drive
echo is not write protected.  Then, restart this installation.
goto fail
:NEEDARG
ECHO The installation disk was not correctly specified.  If you are not
ECHO installing from drive A:, you need to supply the drive letter to
ECHO the INSTALL command.  If you are installing from drive B:, issue the
ECHO command B:INSTALL B: (Make sure to include B: after INSTALL.)
:fail
ECHO   ╔═════════════════════════════════════════════════════╗
echo   ║  WinProof has not been installed, please try again. ║
ECHO   ╚═════════════════════════════════════════════════════╝
:done

