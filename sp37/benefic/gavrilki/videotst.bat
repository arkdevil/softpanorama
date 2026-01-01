echo off
rem Простейший тест видеорежимов на VGA для драйвера VGAEGA_K.COM
set ega=
ega /check
if errorlevel 2 set ega=1
setvmd 0
tbl
setvmd 1
tbl
setvmd 2
tbl
setvmd 3
tbl
setvmd 4
tbl
setvmd 5
tbl
setvmd 6
tbl
setvmd 7
tbl
setvmd d
tbl
setvmd e
tbl
if %ega%==1 goto vga1
setvmd f
 tbl
:vga1
setvmd 10
tbl
if %ega%==1 goto end
setvmd 11
tbl
setvmd 12
tbl
setvmd 13
tbl
:end
rem Конец теста
