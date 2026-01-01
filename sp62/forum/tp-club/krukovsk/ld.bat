rem MiKrOB&Turmite представляют:
rem  Lecar
rem
rem Lecar debugger

tpc /v lecar
tdstrip -s lecar.exe
rem pklite lecar.exe
copy /b lecar.exe+lecar.tds+picture.res lec.exe
td -ds lec.exe
