*  Example of Semuonov Leonid
clear
text
                ДАННАЯ ПРОГРАММА ДЕМОНСТРИРУЕТ :

1. SLMENU.PRG - Как сделать меню для DBASE3+,CLIPPER И FOXBASE одновременно,
                всего лишь заполнив легкозапоминающимся способом
                одну маленькую базу данных(в данном примере - PRMENU.DBF) !
     Примечание 1: Если используете CLIPPER, то удалите из текста 
                   строки с "CURS_" .
     Примечание 2: Oсобенно рекомендуется для программисток (юЮю) !

2. SHADOW.BIN - Прозрачная тень        (для DBASE3+ и FOXBASE) 
3. CURS_OFF.BIN - Курсор OFF           (для DBASE3+ и FOXBASE)
4. CURS_ON.BIN - Курсор ON             (для DBASE3+ и FOXBASE)
5. CURS_TON.BIN -  Звук для SLMENU.PRG (для DBASE3+ и FOXBASE)
endtext
wait

LOAD SHADOW.BIN                     && Тень
LOAD CURS_OFF.BIN                   && Курсор OFF
LOAD CURS_ON.BIN                    && Курсор ON
LOAD CURS_TON.BIN                   && Звук для SLMENU.PRG
   do while .T.
   do cls
      vid   = '             '
      fname = 'prmenu.dbf'          && Файл для описания меню
      do SLMENU with fname, vid     && Подпpогамма для pеализации меню
      @ 20,10 say 'vid = '+ vid	    && Возвращаемое значение параметра VID
      wait	
      * SHADOW.PRG - пример "прозрачной" тени, цвет которой можно подобрать,
      * запустив программу DEMO_ATR.PRG	
      * R0,C0, R1,C1 - координаты тени ; ATR - цвет тени
      R0 = 3
      C0 = 4
      R1 = 20
      C1 = 70
      ATR= 7 	
      call SHADOW with (chr(1)+chr(R0)+chr(C0)+chr(R1)+chr(C1)+chr(ATR) ) 
      wait
      do CLS        	            && Очистка экрана 
      do DEMO_ATR	
         do case
            case vid = '      ВЫХОД       '
                 return
         endcase
   enddo
return
