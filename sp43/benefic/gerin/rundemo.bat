@echo off
echo.
echo  Starting BookMaker V2.0 Demo
echo.
if exist book.ini Ren book.ini book.old > nul
copy book.dem book.ini > nul
book
del book.ini > nul
if Exist book.old ren book.old book.ini > nul
