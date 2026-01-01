@Echo Off
Rem Создание саморазгружающегося архива
Set Path=c:\sys\arch;d:\
MB c:\bat\dat\sfx %1 %2 %3 %4 %5 %6 %7 %8 %9
Rem Восстановим переменную Path= (пакет SetPath.bat)
Rem c:\bat\SetPath
