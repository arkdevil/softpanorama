;
;               MiKrOB&Tirmite
;   Кофигурационный файл к антивирусной программе
;                  L e c a r
;
;             без копирайтов 1992,93
;

Registered Yes

Owner MiKrOB&Turmite

CheckAllDrives Yes

CheckAllFiles Yes

Cure Yes

ExpandFiles Yes

EraseExpanded Yes

PathExpand c:\lswap

BeginDescriptor
;   Packer    Extract              Names                 Move                 Offset, Mark
;   ============================================================================================
;   LHARC     LHARC e -c %1 %2     *.com                 LHARC a -m %1 %2    2,-lh1-
    LHA       LHA e /m1nc          *.com *.exe *.sys     LHA a /m1nt         2D02 6C03 6804 2D02 6C03 6804 ;2,-lh
    PKZIP     PKUNZIP -o           *.com *.exe *.sys     PKZIP -ex -o -a     5000 4B01 5000 4B01 5000 4B01 ;0,PK
;   PAK       PAK e %1 %2 *.PKT    *.com                 PAK a %1 %2         0,#261
;   ZOO       ZOO -e %1 %2 *.PKT   *.com                 ZOO -a %1 %2        5A00 4F01 4F01 5A00 4F01 4F01 ;0,ZOO
    ARJ       ARJ e -y -c -i -jr   *.com *.exe *.sys     ARJ a -y -c -e -i   6000 EA01 6000 EA01 6000 EA01 ;0,#96#234
;   PKARC     PKXARC %1 %2 *.PKT   *.com                 PKARC a %1 %2
    PKLITE    PKLITE -x            -o                    PKLITE -a -o        B800 BA03 0506 3B09 730D 730D  
EndDescriptor

;                 БЕЗ УМОЛЧАНИЙ
;