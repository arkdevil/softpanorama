echo off

IF not exist %1.prg goto err
  clipper %1 /a/m/n/i..
  rtlink  fi %1 lib ..\ctk.lib
  del %1.obj
  %1
  goto eoj
:ERR
  echo .
  echo Usage:  RUN source_file_without_extention
  echo .
:EOJ
