@echo off
IF ERRORLEVEL 1 goto err
echo This is a sample 704 k batch file (%0).
echo Use it as a template to create your own batch files to start
echo oversize DOS sessions and then execute a batch file.
echo .
echo Note the use of percent COMSPEC percent.
echo .
echo 704k of memory has been added, %COMSPEC% will now be run.
echo Be sure to examine the PIF file name %0, but ".PIF",
echo to see how to setup the command and optional parameter lines.
goto ok
:err
echo The oversize memory has failed to allocate
:ok
rem the ISWIN command is a workaround to fix a false error message 
rem from being displayed.
iswin
%COMSPEC%

