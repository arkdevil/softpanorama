@echo off
tcc -c -r- -Z- -ms squeeze.c
tcc -c -ms unsqu.c
tcc -ms sq.c squeeze.obj unsqu.obj
