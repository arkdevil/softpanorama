set talk off
restore from R_FOX               && Считать кодировочные таблицы,необходимые
restore from R_FOX_IC additive   && для работы с индексами.
use DICT index DICT
set order to                && Просмотреть записи в физическом порядке
= Inform(1)
browse
set order to tag NoIgnCase  && Просмотреть записи, упорядоченные по ал-
= Inform(2)                 && фавиту с чувствительостью к регистру
browse
set order to tag IgnCase    && Просмотреть записи, упорядоченные по ал-
= Inform(3)                 && фавиту без чувствительности к регистру.
browse
= Inform(4)                 && Закончить демонстрационный пример
quit

FUNCTION Inform
PARAMETERS Mode
PRIVATE Message,Choice
do case
   case Mode == 1
       Message = "  Сейчас вы увидите файл DICT.DBF с записями, расположенными "+;
                 " в порядке их добавления.  Индексный файл  DICT.CDX отключен "+;
                 " командой SET ORDER TO."
   case Mode == 2
       Message = "  Сейчас записи файла будут представлены в алфавитном поряд- "+;
                 " ке с чувствительностью к регистру.  Выражением, по которому "+;
                 " упорядочен файл, является :                                 "+;
                 "        SYS( 15, R_FOX, WORD )                               "
   case Mode == 3
       Message = "  Сейчас записи файла будут представлены в алфавитном поряд- "+;
                 " ке без  чувствительности к регистру.  Индексным  выражением "+;
                 " является :                                                  "+;
                 "    SYS( 15, R_FOX_IC, WORD )"
   case Mode == 4
       Message = "  Демонстрационный пример закончен.  Для более полного озна- "+;
                 " комления с набором инструментальных средств R_FOX KIT обра- "+;
                 " титесь к документации (файл RFOX_DOC.TXT)."
endcase
if ! wexist("wnInform")
    define window wnInform from srows()/2-4,08 to srows()/2+3,70 double shadow ;
                           color W+/RB,W+/BG,W+/RB,GR/RB,W+/RB,W+/BG,W+/RB,W/N,W+/RB,N/RB
endif
activate window wnInform
@ 0,0 say Message
Choice = 1
if Mode == 4
    @ 05,26 say "[Закончить]"
    @ 05,26 get Choice function "*IT" size 1,11,0
else
    @ 05,18 say "[Продолжить]  [Закончить ]"
    @ 05,18 get Choice function "*IHT ;" size 1,12,2
endif
read cycle
if Choice == 2
    quit
endif    
deactivate window wnInform
return