@Echo off
  echo   ╔═══════════════════════════════════════════════════════╗
  echo   ║ Демонстрационный пример возможностей системы MacroBat ║
  echo   ║                                                       ║
  echo   ║   Если у Вас проблемы с экранным выводом, поставьте   ║
  echo   ║        в строке 32 файла DEMO.BAT режим /BIOS         ║
  echo   ╚═══════════════════════════════════════════════════════╝

  MB W=DOS(GetVers)
  if Not "%W%"=="" goto :OK
  echo Извините, в этой ДОС MacroBat не работает
  goto :Fin
:OK
  MB Sound
  MB FIO=GetStr( " Как Ваша фамилия? " )
  MB FIO=Upper( "%FIO%" )

Rem -- выделим последнюю букву фамилии
  MB W=Sub( -1, 1, "%FIO%" )
  MB W=StrPos ( "%W%", АЯ )

Rem -- если последняя буква фамилии: "А" или "Я", считаем, что это женщина
  If "%W%"=="0" goto :Male
  Set FIO=госпожа %FIO%
  goto :RunProc
:Male
  Set FIO=господин %FIO%
:RunProc
  Set W=

Rem -- А вот так запускается процедура MacroBat (DEMO.MB)
  MB /M demo %1
  Set FIO=
:Fin
