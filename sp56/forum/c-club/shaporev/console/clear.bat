@echo off
if exist *.bak del *.bak
if exist *.tmp del *.tmp 
if exist *.obj del *.obj 
if exist *.exe del *.exe
if exist *.map del *.map
if exist *.lib del *.lib
if exist *.ctl del *.ctl
if exist *.lst del *.lst
if exist *.$?? del *.$??
