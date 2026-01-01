@echo off
itpu /cs /w+ %1 %TEMP%\$$temp$$.
stype %TEMP%\$$temp$$
del %TEMP%\$$temp$$
exit:
rem done.
