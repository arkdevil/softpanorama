:freewin 1,2,3,4,5,6,7,8,9,0

:COM '    И Н С Т Р У К Ц И Я   П О   TBASE

'-------------------------------------------------------------------------
:TEXT

  Инструкция=tbase.scr
  !ПОИСК =tbf tbdoc
  *РЕЗУЛЬТАТ =tbfind

:START
  load Инструкция
  find ▓

'--------------------------------------------------------------------------
:label Инструкция,SETUP
 setup
 Back

:label Инструкция,RIS
 use ris\ris

:label Инструкция,TODAY1
 use today\today1

:label Инструкция,BOOK
 use BOOk\book

:label Инструкция,NOTE
 use note\note

:label Инструкция,DOCLEX
 use lexdoc\lexdoc

:label Инструкция,PERS
use PERS\PERS

:label Инструкция,INTER
use INTER\INTER

:label Инструкция,BIBL
use BIBL\BIBL 

:label Инструкция,Искать
 execi TBF tbdoc 

:label Инструкция,Смотреть
use TBFIND

:label Инструкция,*
 golab
