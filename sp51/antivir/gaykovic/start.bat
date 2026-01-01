@echo off
rem =============================================================
rem          Batch file to start G&K antiviral system
rem =============================================================
main c:\g&k\exe\v.dat c:\g&k\exe\logrec.dat
if errorlevel 11 goto MemErr
if errorlevel 10 goto MemStart
if errorlevel 9  goto NotFound
if errorlevel 8  goto BadFagName
if errorlevel 7  goto Res
if errorlevel 6  goto MemBase
if errorlevel 5  goto DiskBase
if errorlevel 4  goto NoBase
if errorlevel 2  goto BadDos
if errorlevel 1  goto DRDOS
goto Quit
:MemErr
echo         ERROR : Memory error
goto Quit
:MemStart
echo         ERROR : Not enough memory to start Virus Elominator
goto Quit
:NotFound
echo         ERROR : Can't find Virus Eliminator
goto Quit
:BadFagName
echo         ERROR : Bad Virus Eliminator Name
goto Quit
:Res
echo         ERROR : G&K is already resident
goto Quit
:MemBase
echo         ERROR : Not enough memory to load Virus Database
goto Quit
:NoBAse
echo         ERROR : Can't find Virus Database
goto Quit
:DiskBase
echo         ERROR : I/O Error during reading Virus Database
goto Quit
:BadDos
echo         ERROR : Incorrect DOS version
goto Quit
:DRDOS
echo         ERROR : DR-DOS is installed. MS-DOS needed !
:Quit
