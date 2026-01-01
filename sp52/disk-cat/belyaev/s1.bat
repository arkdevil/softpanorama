rem    Пример BAT-файла для "настройки" программы ARCH_S
rem    на поиск файлов в архиве, расположенном в файлах
rem          E:\DISK_1\BDISK001 ... BDISK060
rem
rem    по команде S1 .pas будут найдены все файлы с расширением PAS
rem  
c:\tools\arch_s e:\disk_1\bdisk 1 60 %1>%2 con
