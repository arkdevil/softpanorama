@ECHO OFF
clipper wtest
IF NOT ERRORLEVEL 0 GOTO EXIT
tlink /x/n/d wtest,,,d:\clipper\extend+d:\clipper\clipper
DEL wtest.obj
:EXIT


