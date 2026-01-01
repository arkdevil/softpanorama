@echo off
pmklogo
cls
echo Following picture is situation before installing 35sec floppy accelerator
pause
35old
mode co80
echo And next one is situation after installation of 35sec floppy accelerator
echo.
echo Note, that buffers are in XMS, so communication between DOS and floppy
echo   image is *really* fast. 
echo.
echo Also note, that read/write operations are done completely on background.
echo.
pause
35help
mode co80
