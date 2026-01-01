@cls
@if not exist edos.386 goto notok
@echo This batch file will delete the files that were installed by
@echo EDOS Setup.
@echo Press any key to continue, Ctrl+C to abort
@pause > NUL:
@echo ARE YOU ABSOLUTELY sure? Press any key to continue, Ctrl+C to abort
@pause > NUL:
del dos704k.bat
del dos736k.bat
del dos704k.pif
del dos736k.pif
del ..\iswin.com
del ..\edosexit.com
del ..\clipboar.com
del ..\edosbli.exe

@echo Now, by hand, you should delete the files in this directory
@echo and then delete the directory. The sample commands look like this:
@echo del *.*
@echo cd ..
@echo rd edos
@echo Press any key to continue, Ctrl+C to abort
@pause > NUL:
@cls
@echo del *.*
@echo cd ..
@echo rd edos
goto ok
:notok
@echo This does not appear to be the windows\edos subdirectory
@echo Be sure to change directory to the Windows\edos subdirectory
:ok
