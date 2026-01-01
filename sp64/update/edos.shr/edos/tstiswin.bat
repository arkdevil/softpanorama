iswin
if errorlevel 3 goto iswin

@goto nowin	

:iswin

@echo  This is windows 3.xx
@goto ok
:nowin

@echo  This is NOT windows 3.xx

:ok
