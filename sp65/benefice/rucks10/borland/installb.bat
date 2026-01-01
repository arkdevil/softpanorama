@echo off
REM use /B for mono video systems, as in INSTALL /b
cls
echo RUCKUS 1.0d Install for Borland C/C++ Compilers
echo.
echo To install RUCKUS, the library files must first be extracted and built.
echo Two install runs are made: one for RUCKUS-DAC and RUCKUS-MIDI. These
echo files are for large- or huge-model use only, and only needed by
echo Borland C/C++ compilers when using these memory models. For medium-
echo model use, the standard library files should be used.
echo.
echo The library files created are similar to the standard files except
echo that the filename end with an L: RUCKDAC.LIB is RUCKDACL.LIB, and
echo RUCKMIDI.LIB is RUCKMIDL.LIB.
echo.
pause
instruck RUCKDACL %1
if errorlevel==1 goto nogo
instruck RUCKMIDL %1
if errorlevel==1 goto nogo
echo.
echo Installation was a success. Refer to the documentation under Appendix C.
echo for further installation procedures."
echo.
goto endit
:nogo
echo.
echo Installation failed to complete. 
:endit

