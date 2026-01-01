@echo off
rem This batch file will initialize file sample.exe in drive A: with
rem next serial no...
cls
rem Place createsn.exe and appendsn.exe (and searchsn.exe, if desired) in your
rem path or specify full pathname when they are called, below.
rem The next line increments serialno.dat on source drive by one...
createsn
echo.
rem The following assumes your next disk to be initialized is in drive A:...
echo About to copy serialno.dat to A:...
pause
cls
copy serialno.dat a:\
a:
cd \
rem The executable to be serialized is assumed to already exist in A:\...
appendsn sample.exe
echo.
rem If using Norton's FD.EXE (FileDate) util., unrem/modify the next 2 lines...
rem fd sample.exe /t00:00
rem fd serialno.dat /t00:00
rem You may also simply delete serialno.dat from the diskette, if desired.
rem If you wish to search/verify the .exe for the serialization, unrem the
rem next line:
rem searchsn sample.exe
echo.
echo Returning to C:...
pause 
c:
echo.
echo Done.
echo.
