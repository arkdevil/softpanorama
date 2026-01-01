echo off
if not exist SCROLL.OBS goto ERROR_NOOBJ

if not exist %1cs.lib goto NOSMALLLIB
echo Patching small library...
copy SCROLL.OBS SCROLL.OBJ
tlib %1cs.lib +- SCROLL.OBJ
del SCROLL.OBJ
if errorlevel 1 goto ERROR_NOTLIB
goto MEDIUM
:NOSMALLLIB
echo Cannot find CS.LIB to patch small library.

:MEDIUM
if not exist %1cm.lib goto NOMEDLIB
echo Patching medium library...
copy SCROLL.OBM SCROLL.OBJ
tlib %1cm.lib +- SCROLL.OBJ
del SCROLL.OBJ
goto COMPACT
:NOMEDLIB
echo Cannot find CM.LIB to patch medium library.

:COMPACT
if not exist %1cc.lib goto NOCOMPACTLIB
echo Patching compact library...
copy SCROLL.OBC SCROLL.OBJ
tlib %1cc.lib +- SCROLL.OBJ
del SCROLL.OBJ
goto LARGE
:NOCOMPACTLIB
echo Cannot find CC.LIB to patch compact library.

:LARGE
if not exist %1cl.lib goto NOLARGELIB
echo Patching large library...
copy SCROLL.OBL SCROLL.OBJ
tlib %1cl.lib +- SCROLL.OBJ
del SCROLL.OBJ
goto HUGE
:NOLARGELIB
echo Cannot find CL.LIB to patch large library.

:HUGE
if not exist %1ch.lib goto NOHUGELIB
echo Patching huge library...
copy SCROLL.OBH SCROLL.OBJ
tlib %1ch.lib +- SCROLL.OBJ
del SCROLL.OBJ
goto DONE
:NOHUGELIB
echo Cannot find CH.LIB to patch huge library.
goto DONE

:ERROR_NOOBJ
echo The patch object module SCROLL is not in the current directory.
echo Cannot patch libraries.
goto DONE

:ERROR_NOTLIB
echo A problem was encountered executing TLIB.  Either the Turbo Librarian
echo cannot be located along your DOS path, or an error occurred.  Consult
echo your Turbo C++ Users Guide for more information on why TLIB might not
echo be operating correctly.

:DONE
echo Done.
