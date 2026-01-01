tasm /q wap
if exist wap.obj del wap.bak
tlink /x/Twe wap ,,,, wap
rc wap.rc wap.exe