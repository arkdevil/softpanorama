@cls
@if not exist edos.386 goto notok
@echo This batch file will delete the old files from a previous
@echo version of EDOS.
@echo Press any key to continue, Ctrl+C to abort
@pause > NUL:
del ..\dos704k.bat
del ..\dos736k.bat
del ..\dos704k.pif
del ..\dos736k.pif
del ..\edostemp.com
del ..\edoslib.exe
del ..\edos.ini

goto ok
:notok
@echo This does not appear to be the windows\edos subdirectory
@echo Be sure to change directory to the Windows\edos subdirectory
:ok
