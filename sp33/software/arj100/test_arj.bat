REM TEST_ARJ.BAT
REM This batch file tests ARJ on all your disk files by archiving them to
REM multiple volumes.  To save space, the volumes are deleted immediately.
REM Usage:  TEST_ARJ [work_directory\]
REM Be sure to include the trailing \ character if you specify a directory.
REM
ARJ a %1arjvol c:\*.* -r -jt -y "-vasdel %1arjvol.*"
