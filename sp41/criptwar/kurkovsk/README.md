```
			CHIVIEW - ChiWriter viewer
В этой директории :

#STNDRUS EFT     1848  ─┐
LINEDRAW EFT     1848  ─┼─  Несколько фонтов ChiWriter'а
RUSSITAL EFT     1848  ─┼─  в качестве демонстрации типа фонта
STANDARD EFT     2552  ─┘
CHIVIEW  FNT      925  ───  Мой собственный файл описания фонтов
WHATDEMO         1692  ───  В чем отличия Демо-версии и условия поставки
DOC_ENG  CHI    11699  ─┬─  Документация на английском
DOC_ENG  TXT     8809  ─┘
DOC_RUS  CHI    12195  ─┬─  Документация на русском
DOC_RUS  TXT     8924  ─┘
CHIVIEW  PCK    61330  ───  Зашифрованный архив
DEMO     CHI      822  ───  Маленький демонстрационный документ
CHIVDEMO EXE    28848  ───  Демонстрационная версия программы
PACK     EXE    26378  ───  Архиватор PACK
    READ ME            ───  Этот файл


                               * * *

The chiview.pck archive uses vigenere (repeated key) cipher, key
length is 11 characters (from Kasiski's test).
The plain text attack is based on the fact that DOS EXE's file
has fixed header:

 -2 - -1 ST (guessed from header_size high byte and init_ip)
 0-1     MZ (identical for all 3 exe files)
 2-3     lastpage (calculated from known unpacked sizes: 96, 488, 320)
 4-5     pages (calculated from known unpacked sizes: 105, 29, 28)
 6-7     reloc (high byte assumed 0, was true for install.exe and color.exe)
 8-9     header_size (high byte assumed 0)
 10-11   minalloc
 12-13   maxalloc
 14-15   init_ss
 16-17   init_sp
 18-19   checksum
 20-21   init_ip
 22-23   init_cs
 24-25   reloc_off
 26-27   overlay_num

 chiview.exe:  AC ^ FF = 53     AB ^ FF = 54
               12 ^ 4D = 5F     68 ^ 5A = 32  0-1   MZ
               58 ^ 60 = 38     39 ^ 0  = 39  2-3   lastpage
               5F ^ 69 = 36     37 ^ 0  = 37  4-5   pages
               09 ^ 3D = 34     36 ^ 3  = 35  6-7   reloc
               BF ^ D1 = 6E end 53 ^ 0  = 53  8-9   header_size
               F3 ^ A7 = 54     4C ^ 13 = 5F  10-11 minalloc

 key:
  ST_28967?5n - plain text attack
  ST_2896745n - brute force

               S  T _  2  8  9  6  7  ?  5  n   S  T  _  2  8  9  6  7  ?  5  n
 Name         -2 -1 0  1  2  3  4  5  6  7  8   9  10 11 12 13 14 15 16 17 18 19
 -------------------------------------------------------------------------------
 chiview.exe  AC AB 12 68 58 39 5F 37 09 36 BF  53 F3 4C 95 8B E4 09 B3 3B C5 91
 install.exe  AC AB 12 68 D0 38 2B 37 FF 35 2E  53 4D 5F CD C7 51 2D C8 37 D3 6E
 color.exe    AC 5B 12 68 78 38 2A 37 A4 35 48  53 36 5E CD 38 C7 06 33 34 3D 6E
```
