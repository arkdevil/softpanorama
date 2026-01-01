@echo off
rem : updatedb.bat - update fastfind database
rem : Copyright (C) 1990 by Thorsten Ohl, td12@ddagsi3.bitnet

set drives=c:/ d:/ e:/
set codes=c:\scripts\find.codes

rem : Change slashes to spaces for proper alphabetization (directories first!).
echo Creating comprehensive list of files for %drives% ...
find %drives% | sed "s!/! !" | sort | sed "s! !/!" > files.srt

rem : sort needs the `-S1000' option since the lines are very short (2 chars)
echo Calculating bigrams ...
bigram < files.srt | sort -S1000 | awk -f uniq-c | sort +0.1nr | awk "NR<=128{printf($2)}" >bigrams.srt

echo Generating the codes in %codes% ...
code bigrams.srt < files.srt > %codes%

echo Cleaning up ...
rm  files.srt bigrams.srt
set drives=
set codes=

echo Done.


