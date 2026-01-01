*******************************
*File: WTEST.PRG
*Author:U.Rodionoff
*Пример небольшой програмки с использованием оконных функций

* Системные переменные
* Цвета
PRIVATE SysMesCol,SysWBdCol,SysWTxCol,SysWHdCol,SysMLoCol,SysMHiCol,SysMUnCol

SysMesCol="N/W"     && сообщения
SysWBdCol="N/GR"    && pамки окон
SysWTxCol="N/GR"    && текст в окнах
SysWHdCol="N/GR"    && заголовки окон
SysMLoCol="N/W"     && опции меню
SysMHiCol="GR+/N"   && выбоp меню
SysMUnCol="N/W"     && невыбранные опции

* Режимы  окон
PUBLIC WnExpand, WnShrink, WnShadow, WnBorder, WnBackgr

WnExpand=.t.          && Раскpытие окон
WnShrink=.t.          && Закрытие окон
WnShadow=.t.          && Тени у окон
WnBorder= "┌─╥║╝═╘│"  && Рамки окон
WnBackgr="▒"          && Символ-заполнитель
WnSound=.T.           && Сигналы при раскрытии/свертке

SET PROC TO _message
SET PROC TO _ynbox
SET PROC TO _wexpand
SET PROC TO _wshrink
SET PROC TO _wshadow
SET PROC TO _maxrc
SET PROC TO _waitbox
SET PROC TO _xmenu
TEXT
**********************************************************************
*
*  Демонстрация использования оконных функций для CLIPPER:
*        YNBOX(), MESSAGE(), WAITBOX(), XMENU()
*
*  Для особо нервных : форматизация диска CLIPPER'ом без привлечения
*  функций на других языках не возможна.
*
***********************************************************************

ENDTEXT
PRIVATE exit,i,j,axmenu[3]
axmenu[1]='Форматировать винчестер'
axmenu[2]='Не форматировать винчестер'
axmenu[3]='Выход (не рекомендуется)'

exit=.F.

DO While .NOT.exit
  i=XMENU(-1,-1,axmenu,'Сделайте выбор')
  If i=3
    exit=.t.
  ElseIf i=2
    If  YNBOX(-1,-1,"Не форматировать винчестер?",'Вы уверены?!')
      MESSAGE("Поздно...")
      DO format
    Else
      DO format
    EndIF
  Else
    MESSAGE('Как хотите')
    DO format
  EndIF
EndDO
MESSAGE('Или что-то вроде этого')

proc format
   PRIVATE j,savscr
   SAVE SCREEN TO savscr
   WnSound=.F.
   For j=1 to 20
     waitbox(j,j*2,'Форматизация...')
     waitbox(j,63-(j*2),'Форматизация...')
   Next
   WnSound=.T.
   MESSAGE("Готово дело")
   REST SCREEN FROM savscr
return
*** End of _MENUCL.PRG *******
