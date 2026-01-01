@echo off
REM use /B for mono video systems, as in INSTALL /b
cls
echo RUCKUS 1.0d Install
echo.
echo To install RUCKUS, the library files must first be extracted and built.
echo Two install runs are made: one each for RUCKUS-DAC and RUCKUS-MIDI.
echo.
pause
instruck RUCKDAC %1
if errorlevel==1 goto nogo
instruck RUCKMIDI %1
if errorlevel==1 goto nogo
echo.
echo Installation was a success. Refer to the documentation under Appendix C.
echo for further installation procedures. Borland C/C++ users _must_ use the
echo additional library files/install in the BORLAND.ZIP archive. See the
echo README file in BORLAND.ZIP for more information.
echo.
goto endit
:nogo
echo.
echo Installation failed to complete. 
:endit

