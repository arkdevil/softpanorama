@echo off
  mb D=curdir()
:ASK
  mb W=GetCh(/U/,"Вы хотите удалить все дерево %D%? Ответьте Y или N:")
  If %W%.==N. goto :FIN
  If %W%.==Y. goto :ZAPTREE
  echo Ответ неверен!
  goto :ASK
:ZAPTREE
  zap %D% /s/a
  delete \treeinfo.ncd
:FIN
  Set D=
  Set W=
