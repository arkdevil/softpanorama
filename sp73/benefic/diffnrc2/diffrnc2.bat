echo off
cls
if "%1" == "" goto error
if not exist %1 goto error
if not exist %2 goto error
qsortl <%1 >primary
qsortl <%2 >secondry
basica diffrnc2
echo 
goto end
:error
echo 
echo Correct syntax is:
echo 
echo             DIFFRNC2 file1 file2
echo 
echo where file1 is the list of files available to upload, and
echo       file2 is the file listing of a BBS to check.
echo 
:end

