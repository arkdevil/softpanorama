@if !%1==! goto huh
@if !%1==!s goto sho
@if !%1==!z goto zip
@if !%1==!m goto msc
@if !%1==!b goto bcc
:huh
@echo doit s     Show read.me
@echo      z     Zip up this package into TR112.ZIP
@echo      m     Compile v1.11 with Microsoft C/C++ v7.00
@echo      b     Compile v1.11 with Borland C/C++ v2.0
@goto xit
:sho
@type read.me
@goto xit
:zip
pkzip -o tr112 read.me doit.bat file_id.diz tr100.c tr.c tr.doc v112.chg tr.exe
@goto xit
:msc
@rem This is v7.00 of Microsoft C/C++
cl /AS /W4 /Grsy /Oxaz /F 800 tr.c
@goto xit
:bcc
@rem This is v2.0 of Borland C/C++
bcc -ms -d -G -O -Z tr.c
:xit
@rem