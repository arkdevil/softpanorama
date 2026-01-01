@echo off
menu 5 5 1E171F0E "Test Menu"  "  Item 1  " "  Item 2  " "  Item 3 "
if errorlevel 255 goto error
if errorlevel 3   goto c3
if errorlevel 2   goto c2
if errorlevel 1   goto c1
echo No choise !
goto end
:error
echo Invalid parameter !
goto end
:c3
echo You choose item 3
goto end
:c2
echo You choose item 2
goto end
:c1
echo You choose item 1
:end

