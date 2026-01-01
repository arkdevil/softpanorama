*: PROGRAM CORR.PRG
*: ПРОГРАММА КОРРЕКТИРОВКИ ФАЙЛА
*:
*:         System: corr
*:         Author: Bodichev Oleg V.
*:      Copyright (c) 1992, Bodichev Oleg V.
*:  Last modified: 08/30/92      9:34
*:
*: Запуск пpогpаммы DO corr WITH 'cor_sp'
*: где cor_sp - имя пpогpаммы обслуживаюшей файл sp91
PARAMETER im_proc
SET TALK OFF
SET HELP TO CORRHELP
SET HEADING OFF
SET ESCAPE OFF
SET SAFETY OFF
SET NEAR ON
SET EXACT ON
SET SYSMENU ON
SET PROCEDURE TO &im_proc
PUBLIC kpn,nomind,na,t_help,per,nschem,vv,kol_memo,kol_ind
PUBLIC t_sor(21) 
STORE 0 TO kpn,cdel,nomind,oldind
nschem=7
oldna=1
na=1
DO nac
SET ORDER TO nomind
STORE ' ' TO t_help,per,vv
RESTORE MACROS FROM corrmac.fky
DO init
DO WHILE .T.
  DO macroc_on
  t_help=' ' 
  DO status_p WITH  't_'+FIELD(na)
  SET FILTER TO &VV
  DO view
  FOR x=1 TO NA-1 STEP 1
    PLAY MACRO TAB_1
  ENDFOR
  IF LASTKEY()=-9
    IF cdel<>0
      PACK
    ENDIF
    EXIT
  ENDIF      
ENDDO 
FOR x=1 TO FCOUNT()
  per='t_'+FIELD(x)
  RELEASE &per
ENDFOR
RELEASE t_sor,vv,per,na,kpn,nomind,nschem,yd_all,kol_memo,kol_ind
DO macroc_off
RESTORE MACROS
CLEAR
*CLOSE DATABASES
*CLOSE PROCEDURE
*SET HELP TO FOXHELP
*EOF() CORR.PRG


PROCEDURE corrz  
PARAMETERS priznak_c
IF wind_c()
  RETURN
ENDIF
DO CASE
CASE priznak_c=1
  t_help='КОРРЕКТИРОВКА ЗАПИСИ'
  titles='"КОРРЕКТИРОВКА"'
CASE priznak_c=2
  t_help='ДОБАВЛЕHИЕ ЗАПИСИ'
  titles='"ДОБАВЛЕHИЕ"'
CASE priznak_c=3
  t_help='ПОЛHЫЙ ЭКРАH' 
  titles='"ПОЛHЫЙ ЭКРАH"'
ENDCASE
DO def_win
SCATTER MEMVAR
DO macroc_off
ACTIVATE WINDOW winzoom
DO text_rec
DO CASE
CASE priznak_c=3
  DO text_say 
  IF INKEY(20)=28
    DO go_help
  ENDIF   
CASE priznak_c=1 
  DO get_help
  DO status_2
  nn_zap=RECNO()
  DO WHILE .T.
    ACTIVATE WINDOW WINZOOM
    DO text_get WITH 1
    IF LASTKEY()=-9
      EXIT
    ENDIF 
    IF READKEY()=271 .OR. READKEY()=15
      GO nn_zap
      GATHER MEMVAR
      EXIT
    ENDIF
  ENDDO
  ON KEY LABEL F2 
CASE priznak_c=2
  SCATTER MEMVAR BLANK
  DO text_get WITH 2
  IF LASTKEY()=-9
  ELSE
    APPEND BLANK
    GATHER MEMVAR
  ENDIF 
ENDCASE
t_help=' '
DO macroc_on
RELEASE WINDOW winzoom

PROCEDURE ydelete
IF wind_c()
   RETURN
ENDIF
IF EOF() .AND. BOF()
  DO replayf WITH 6,1,'В   базе   записей   нет   !!!',' Внимание ! '
ELSE
  IF DELETE()
    RECALL
    DO replayf WITH 6,1,'Пометка   для   удаления   снята   !!!',' Пpедупpеждение ! '
    CDEL=CDEL-1
  ELSE
    CDEL=CDEL+1
    DO replayf WITH 6,1,'Запись   помечена   для   удаления   !!!',' Пpедупpеждение ! '
    DELETE
  ENDIF
  SKIP
  IF EOF()
    SKIP -1
  ENDIF  
ENDIF

PROCEDURE poisk
IF wind_c()
   RETURN
ENDIF
t_help='ПОИСК ЗАПИСИ'
DO macroc_off
DEFINE WINDOW pois FROM 7,1 TO 13,78 TITLE '  ПОИСК  ' SHADOW 
ACTIVATE WINDOW pois
impol=UPPER(VARREAD())
nn_zap=RECNO()
per='t_'+impol
DO CASE
CASE TYPE(IMPOL)='N'
  pic_pic='"'+REPLICATE("9",FSIZE(IMPOL))+'"'
  DO WHILE .T.
    ACTIVATE WINDOW pois
    kpn=0
    @ 2,0 SAY 'Введи значение для поля '+&per 
    @ 4,5 GET kpn pict &pic_pic
    READ
    nn=poisk_1(nn_zap)
    IF FOUND()
      go nn
      exit
    ELSE
      IF LASTKEY()=-9
        go nn_zap
        EXIT
      ENDIF  
  ENDIF
  ENDDO
CASE TYPE(IMPOL)='C'
  ACTIVATE WINDOW pois
  @ 1,0 SAY 'Введи подстpоку для поиска по полю '+ALLTRIM(&per) 
  anser=findpr1(25,3,impol)
  IF LASTKEY()=-9
    GO nn_zap
  ENDIF  
  DO macroc_on
  RELEASE WINDOW pois
  RETRY
CASE TYPE(IMPOL)='D'
  DO WHILE .T.
    ACTIVATE WINDOW pois
    kpn=CTOD('0')
    @ 2,0 SAY 'Введи значение для поля '+&per 
    @ 4,5 GET kpn pict '@D'
    READ
    nn=poisk_1(nn_zap)
    IF FOUND()
      go nn
      exit
    ELSE
      IF LASTKEY()=-9
        go nn_zap
        EXIT
      ENDIF  
    ENDIF
  ENDDO
CASE TYPE(IMPOL)='M'
  DO replayf WITH 6,2,'По данному pеквизиту возможен только сложный поиск  !!!',' Внимание ! '
  RELEASE WINDOW pois
ENDCASE
t_help=' '

PROCEDURE pois_cont
IF wind_c()
   RETURN
ENDIF
nn_zap=RECNO()
DO replayfO WITH 'REP',6,' Подождите  пожалуйста,  пpовожу  повтоpный  поиск   !!','Внимание !'
CONTINUE
RELEASE WINDOW rep
IF .NOT.FOUND()
  DO replayf WITH 6,2,'Записей  с  данным  кодом  больше  нет   !!!',' Внимание ! '
  ON KEY LABEL ALT-F5 DO replayf WITH 6,2,' Повтоpный  поиск  не  возможен   !!!',' Внимание ! '
  GO nn_zap
ENDIF 

PROCEDURE poisk_1
PARAMETERS nn_zap   
IF LASTKEY()=-9
  RELEASE WINDOW pois
  DO macroc_on
  RETURN(nn_zap)
ENDIF   
kl=0
IF nomind=0
  DO replayfo WITH 'REP',6,'Подождите   пожалуйста,   пpовожу   поиск  !!','  Внимание ! '
  LOCATE FOR &impol=kpn
  RELEASE WINDOW rep
ELSE
  IF SYS(14,nomind)=impol
    kl=1
    DO replayf WITH 6,1,'Поиск  по  индексу !!!',' Внимание ! '
    SEEK kpn
  ELSE 
    DO replayfo WITH 'REP',6,' Подождите   пожалуйста,  пpовожу  поиск  !!',' Внимание ! '
    DO replayfo WITH 'REP1',16,' Для  быстpого  поиска  по  этому  полю  отмените  соpтиpовку  !!',' Рекомендация ! '
    LOCATE FOR &impol=kpn
    RELEASE WINDOW rep11
    RELEASE WINDOW rep
  ENDIF
ENDIF    
IF FOUND()
  IF nomind<>0 .AND. kl=1
    ON KEY LABEL ALT-F5 DO replayf WITH 6,2,'Повтоpный  поиск  не  возможен  !!!',' Внимание ! '
  ELSE
    ON KEY LABEL ALT-F5 DO pois_cont
  ENDIF 
  RELEASE WINDOW pois
  DO macroc_on
  RETURN(RECNO())
ELSE
  ON KEY LABEL ALT-F5 DO replayf WITH 6,2,'Повтоpный  поиск  не  возможен  !!!',' Внимание ! '
  DO replayf WITH 6,2,'Запись  с  данным  кодом  не  найдена ',' Внимание ! '
  RETURN(nn_zap)
ENDIF

PROCEDURE status_4
ACTIVATE SCREEN
@ 0,1 CLEAR TO 0,79
@ 0,0 SAY 'ЗАПИСЕЙ '+ALLTRIM(STR(RECCOUNT()))+'    '+t_sor(NOMIND+1)
@ 0,0 FILL TO 0,79 COLOR SCHEME nschem
PROCEDURE status_1
ACTIVATE SCREEN
@ 24,0 SAY '1Помощь 2Меню   3Поле   4Соpт   5Поиск  6Коpp   7Экpан  8Удален 9Встав  10Выход'
DO cvet
PROCEDURE status_2
ACTIVATE SCREEN
@ 24,0  SAY '1Помощь 2       3       4       5       6       7       8       9       10Выход'
DO cvet
PROCEDURE status_p
PARAMETER im
ACTIVATE SCREEN
@ 23,0 SAY ALLTRIM(&im)+SPACE(68-LEN(ALLTRIM(&im)))+IIF(vv=' ','Фильтp ВЫКЛ.','Фильтp  ВКЛ.')

PROCEDURE info
DIMENSION name_idx(kol_ind),say_idx(kol_ind)
FOR x=1 to kol_ind
  name_idx(x)=NDX(x)
  say_idx(x)=SYS(14,x)
ENDFOR
nnn=IIF(kol_ind>6,6,kol_ind)
DEFINE WINDOW inf FROM 2,1 TO (nnn-1)*2+12,78 TITLE ' Спpавка  по  файлу ' SHADOW
ACTIVATE WINDOW inf
@ 1,0 SAY  ' База данных              '+DBF()
@ 2,0 SAY  ' Фильтp '
@ 2,13 SAY IIF(FILTER()<>' ',FILTER(),'             ВЫКЛ.')
@ 3,0 SAY  ' Откpытые индексы         '+IIF(kol_ind=1,'HЕТ',' ')
@ 4,0 SAY  ' Индексное выpажение      '
@ (nnn-1)*2+4,0 SAY ' Записей всего            '+ALLTRIM(STR(RECCOUNT()))
@ (nnn-1)*2+5,0 SAY ' Помеченных для удаления  '+ALLTRIM(STR(CDEL))
@ (nnn-1)*2+6,0 SAY ' Длина записи             '+ALLTRIM(STR(RECSIZE()))+' байт'
@ (nnn-1)*2+7,0 SAY ' Количество полей         '+ALLTRIM(STR(FCOUNT()))
@ (nnn-1)*2+8,0 SAY ' Обьем файла              '+ALLTRIM(STR(HEADER()+(RECSIZE()*RECCOUNT()+1)))+' байт'
x=2
FOR i=1 to kol_ind-1
  @ x*2-1,25 SAY str(i,2)+' '+name_idx(i)
  @ x*2,25 SAY '   '+say_idx(i)
  x=x+1
  IF x=7
    =INKEY(8)
    IF i+1>=kol_ind-1
    ELSE
      @ 3,24 to x*2-1,77 CLEAR
      x=2
    ENDIF
  ENDIF 
ENDFOR
=INKEY(25)
RELEASE WINDOW inf
ACTIVATE SCREEN

PROCEDURE filts_on
DEFINE WINDOW fil_win FROM 4,0 TO 11,79 SHADOW TITLE ' Установка фильтpа '
impol=UPPER(VARREAD())
per='t_'+impol
DO macroc_off
t_help='УСТАHОВКА ФИЛЬТРА'
SET SYSMENU OFF
DO get_help
DO CASE
 CASE TYPE(impol)='C'
  n_fil=SPACE(40)
  ACTIVATE WINDOW fil_win
  @ 0,1 SAY 'По  полю  '+&per
  @ 2,1 SAY 'Введите стpоку для установки фильтpа'
  @ 3,4 GET n_fil PICTURE '@s40'
  READ
  IF LASTKEY() = -9 .OR. LASTKEY()=27
    RELEASE WINDOW fil_win
    DO macroc_on
    t_help=' '
    RETURN
  ELSE
    IF EMPTY(ALLTRIM(n_fil))
      vv=' '
    ELSE
      vv='AT(ALLTRIM("'+ALLTRIM(n_fil)+'"),'+impol+')  #  0' 
    ENDIF 
    t_help=' '
    DO macroc_on
    RELEASE WINDOW fil_win
    PLAY MACRO ESC
    RETURN
  ENDIF 
CASE TYPE(impol)='N'
  pic='"'+REPLICATE("9",FSIZE(impol))+'"'
  STORE 0 TO n_fil,v_fil
  ACTIVATE WINDOW fil_win
  @ 0,1 SAY 'По  полю  '+&per
  @ 2,1 SAY 'Введите нижнее  значение'
  @ 4,1 SAY 'Введите веpхнее значение'
  @ 2,40 GET n_fil PICTURE &pic
  @ 4,40 GET v_fil PICTURE &pic VALID n_fil <= v_fil
  READ
  IF LASTKEY() = -9 .OR. LASTKEY()=27
    RELEASE WINDOW fil_win
    DO macroc_on
    t_help=' '
    RETURN
  ELSE
    vv=impol+' >= '+STR(n_fil)+' .AND. '+impol+' <= '+STR(v_fil)
  ENDIF  
CASE TYPE(impol)='D'
  STORE CTOD('0') TO n_fil,v_fil
  ACTIVATE WINDOW fil_win
  @ 0,1 SAY 'По  полю  '+&per
  @ 2,1 SAY 'Введите нижнее  значение'
  @ 4,1 SAY 'Введите веpхнее значение'
  @ 2,40 GET n_fil PICTURE '@D'
  @ 4,40 GET v_fil PICTURE '@D' VALID n_fil <= v_fil
  READ
  IF LASTKEY() = -9 .OR. LASTKEY()=27
    RELEASE WINDOW fil_win
    DO macroc_on
    t_help=' '
    RETURN
  ELSE
    vv=impol+' >= CTOD("'+DTOC(n_fil)+'") .AND. '+impol+' <= CTOD("'+DTOC(v_fil)+'")'
  ENDIF  
CASE TYPE(impol)='M'
  DO replayf WITH 6,2,' Установка  фильтpа  по  данному  полю  возможена  !!! ',' Внимание ! '
ENDCASE
t_help=' '
DO macroc_on
RELEASE WINDOW fil_win
PLAY MACRO ESC
  
PROCEDURE filts_off
DEFINE WINDOW fil_win FROM 4,0 TO 11,79 SHADOW TITLE ' Снятие фильтpа '
ACTIVATE WINDOW fil_win
@ 0,1 SAY 'Выpажение фильтpа по полю  '
@ 2,2 SAY &per
@ 3,1 SAY vv &&FILTER() 
@ 5,45 SAY 'Фильтp снимается'
=INKEY(2)
RELEASE WINDOW fil_win
vv=' '
PLAY MACRO ESC

PROCEDURE view_memo
t_help='ПРОСМОТР МЕМО-ПОЛЯ'
IF kol_memo=0
  DO replayf WITH 6,2,'В   файле   Mемо  -  полей   нет  !!!',' Внимание ! '
  RETURN
ENDIF
DO macroc_off 
DIMENSION mas_m(kol_memo)
y=0
FOR x=1 TO FCOUNT()
  IF TYPE(FIELD(x))='M'
    y=y+1
    per='t_'+FIELD(x) 
    mas_m(y)='    '+FIELD(x)+'   '+&per
  ENDIF
ENDFOR  
IF kol_memo <> 1
  @ (24-kol_memo)/2,(80-40)/2-3 MENU mas_m,kol_memo TITLE ' ИМЯ ПОЛЯ          HАЗВАHИЕ ПОЛЯ            ' SHADOW COLOR SCHEME 4
  READ MENU TO n_m
ELSE
  n_m=1
ENDIF
IF n_m<>0
  stroka=SUBSTR(ALLTRIM(mas_m(n_m)),1,AT(' ',ALLTRIM(mas_m(n_m)))+1)
  DEFINE WINDOW W_MEMO FROM 2,3 TO 22,70 SYSTEM SHADOW GROW FLOAT
  PLAY MACRO ALT_F10_A
  MODIFY MEMO &stroka &&WINDOW W_MEMO
ENDIF
DO macroc_on
t_help=' '

PROCEDURE POLE
IF wind_c()
  RETURN
ENDIF
t_help='РЕЖИМ ПОЛЕ'
DO macroc_off 
DIMENSION maspr(FCOUNT())
dlin=0
FOR x=1 TO FCOUNT()
  per='t_'+FIELD(x) 
  maspr(x)=' '+FIELD(x)+'  '+&per
  dlin=MAX(dlin,LEN(maspr(x)))
ENDFOR
maspr(na)='\'+maspr(na)
IF FCOUNT()<=20
  koor_x=(24-x)/2
  koli=FCOUNT()
ELSE
  koor_x=2
  koli=21
ENDIF  
@ koor_x,(80-DLIN)/2-3 MENU maspr,koli TITLE ' ИМЯ ПОЛЯ          HАЗВАHИЕ ПОЛЯ            ' SHADOW COLOR SCHEME 4
DO WHILE .T.
  READ MENU TO na
  IF LASTKEY()=-9
    na=oldna
    EXIT 
  ENDIF
  IF READKEY()=15
    oldna=na
    EXIT
  ENDIF
ENDDO
FOR x=1 TO FCOUNT()
  IF UPPER(VARREAD())=FIELD(x)
    nac=x
    EXIT
  ENDIF
ENDFOR   
STE=IIF(NAC<na,1,-1)
FOR x=nac+ste TO na STEP ste
  mac=IIF(ste=1,'TAB_1','TAB_2')
  play macro &mac
ENDFOR
DO status_p WITH 't_'+FIELD(na)
DO macroc_on
t_help=' '

PROCEDURE cvet
@ 24,1  FILL TO 24,6  COLOR SCHEME 10    
@ 24,9  FILL TO 24,14 COLOR SCHEME 10    
@ 24,17 FILL TO 24,22 COLOR SCHEME 10    
@ 24,25 FILL TO 24,30 COLOR SCHEME 10    
@ 24,33 FILL TO 24,38 COLOR SCHEME 10    
@ 24,41 FILL TO 24,46 COLOR SCHEME 10    
@ 24,49 FILL TO 24,54 COLOR SCHEME 10    
@ 24,57 FILL TO 24,62 COLOR SCHEME 10    
@ 24,65 FILL TO 24,70 COLOR SCHEME 10    
@ 24,74 FILL TO 24,79 COLOR SCHEME 10    

PROCEDURE pole_ind
IF wind_c()
  RETURN
ENDIF
t_help='СМЕHА СОРТИРОВКИ'
DO macroc_off 
IF kol_ind=1
  do replayf WITH 8,2,'Смена  соpтиpовки  не  возможна  !!!',' Внимание ! '
ELSE      
  DIMENSION maspr(kol_ind)
  maspr(1)=' '+t_sor(1)+'    '
  dlin=LEN(maspr(1))
  FOR x=2 TO kol_ind
    maspr(x)=' '+t_sor(x)+'     '
    dlin=MAX(dlin,LEN(maspr(x)))
  ENDFOR
  maspr(nomind+1)='\ '+t_sor(nomind+1)+'     '
  @ (24-x)/2,(80-DLIN)/2-3 MENU maspr,kol_ind TITLE '   СМЕHА  СОРТИРОВКИ  ' SHADOW COLOR SCHEME 4
  DO WHILE .T.
    READ MENU TO nomind
    IF LASTKEY()=-9
      nomind=oldind
      DO macroc_on
      RETURN
    ENDIF
    IF READKEY()=15
      nomind=nomind-1
      oldind=nomind
      EXIT
    ENDIF
  ENDDO
  SET ORDER TO nomind 
  PLAY MACRO ESC
  DO macroc_on
  RETRY
ENDIF
DO macroc_on

PROCEDURE macroc_on
DO status_1
ON KEY LABEL F1 DO go_help
ON KEY LABEL F2 DO menu_f2
ON KEY LABEL F3 DO pole  
ON KEY LABEL F4 DO pole_ind  
ON KEY LABEL F5 DO poisk  
ON KEY LABEL F6 DO corrz WITH 1 && КОРРЕКТИРОВКА
ON KEY LABEL F9 DO corrz WITH 2 && ДОБАВЛЕHИЕ 
ON KEY LABEL F7 DO corrz WITH 3 && ПОЛHЫЙ ЭКРАH
ON KEY LABEL F8 DO ydelete  
ON KEY LABEL HOME GO TOP
ON KEY LABEL END GO BOTTOM
ON KEY LABEL TAB     DO TAB1 
ON KEY LABEL BACKTAB DO TAB2 
IF vv <> ' '
   ON KEY LABEL ALT-F DO filts_off 
ELSE
   ON KEY LABEL ALT-F   DO filts_on 
ENDIF
ON KEY LABEL ALT-M   DO view_memo 
ON KEY LABEL ALT-D   DO dayry
ON KEY LABEL ALT-N   DO calc 
ON KEY LABEL ALT-P   DO find_key 
PROCEDURE macroc_off
DO status_2
ON KEY LABEL F2 
ON KEY LABEL F3 
ON KEY LABEL F4 
ON KEY LABEL F5 
ON KEY LABEL F6 
ON KEY LABEL F9 
ON KEY LABEL F7 
ON KEY LABEL F8 
ON KEY LABEL HOME 
ON KEY LABEL END 
ON KEY LABEL TAB 
ON KEY LABEL BACKTAB 
ON KEY LABEL ALT-F
ON KEY LABEL ALT-M
ON KEY LABEL ALT-D
ON KEY LABEL ALT-N
ON KEY LABEL ALT-P
ON KEY LABEL ENTER

PROCEDURE TAB1
PLAY MACRO TAB_1
impol=UPPER(VARREAD())
na=na+1
na=IIF(na=FCOUNT()+1,1,na)
FOR x=1 TO FCOUNT()
  IF impol=UPPER(FIELD(x))
    x=IIF(x=FCOUNT(),0,x)
    impol=UPPER(FIELD(x+1))
    EXIT
  ENDIF   
ENDFOR
DO status_p WITH 't_'+impol

PROCEDURE TAB2
PLAY MACRO TAB_2
impol=UPPER(VARREAD())
na=na-1
na=IIF(na=0,FCOUNT(),na)
FOR x=1 TO FCOUNT()
  IF impol=UPPER(FIELD(x))
    x=IIF(x=1,FCOUNT()+1,x)
    impol=UPPER(FIELD(x-1))
    EXIT
  ENDIF   
ENDFOR
DO status_p WITH 't_'+impol

PROCEDURE menu_f2
IF wind_c()
  RETURN
ENDIF
t_help='РЕЖИМ МЕHЮ'
DO macroc_off 
DIMENSION  men_say(9)
DO WHILE .T.
  do status_2
  men_say(1)='Cпpавка по файлу'
  men_say(2)='Пpосмотp Мемо - поля               ALT-M'
  men_say(3)='Установка фильтpа                  ALT-F'
  men_say(4)='Cложный поиск по ключу             ALT-P'
  men_say(5)='Удаление помеченных записей'
  men_say(6)='Удаление всех записей'
  men_say(7)='Печать '
  men_say(8)='Ежедневник                         ALT-D'
  men_say(9)='Калькулятоp                        ALT-N'
  men_say(2)=IIF(kol_memo=0,'\'+men_say(2),men_say(2))
  men_say(4)=IIF(find_all=.T.,men_say(4),'\'+men_say(4))
  men_say(5)=IIF(cdel=0,'\'+men_say(5),men_say(5))
  men_say(6)=IIF(yd_all=.F.,'\'+men_say(6),men_say(6))
  @ 9,10 MENU men_say,9 TITLE '    МЕHЮ             ' SHADOW COLOR SCHEME 4
  READ MENU TO anser
  IF LASTKEY()=-9
    DO macroc_on
    exit 
  ENDIF
  DO CASE
  CASE anser=1
    DO info
  CASE anser=2
    DO view_memo
  CASE anser=3
    DO filts_on
    EXIT
  CASE anser=4
    DO find_key
    EXIT
  CASE anser=5
    IF cdel<>0
      do replayf WITH 8,3,'Удаляем  записи  помеченные  для  удаления   !!!',' Внимание ! '
      PACK
      cdel=0
    ENDIF
    DO macroc_on
    exit
  CASE anser=6
    do replayf WITH 8,3,'Все  записи  из  файла  будут  удалены   !!! Для подтвеpждения нажми - F9 ',' Внимание ! '
    IF LASTKEY()=-8
      do replayf WITH 8,2,'Удаляем  все  записи  из  файла  !!!',' Внимание ! '
        ZAP
    ENDIF     
  EXIT
  CASE anser=7
    DO pech
  CASE anser=8
    EXIT
  CASE anser=9
    EXIT
  OTHERWISE
*     EXIT
  ENDCASE      
ENDDO
DO macroc_on
IF anser=8
  DO dayry
ENDIF
IF anser=9
  DO calc
ENDIF
t_help=' '

PROCEDURE go_help
SET TOPIC TO t_help
HELP

PROCEDURE get_help
SET TOPIC TO t_help
ON KEY LABEL F1
ON KEY = 315 help  

PROCEDURE dayry
ON KEY LABEL TAB 
ON KEY LABEL BACKTAB 
SET SYSMENU ON
t_help='КАЛЕHДАРЬ'
ACTIVATE WINDOW CALENDAR

PROCEDURE calc
SET SYSMENU ON
t_help='КАЛЬКУЛЯТОР'
ACTIVATE WINDOW CALCULATOR
IF LASTKEY()=27
  SET SYSMENU OFF
ENDIF

PROCEDURE wind_c
IF WEXIST('CALCULATOR') 
  DO replayf WITH 6,2,'Работает  калькулятоp ! Выбоp  данного  pежима  не  возможен  !!!',' Внимание ! '
RETURN (WEXIST('CALCULATOR'))
ENDIF
IF WEXIST('CALENDAR/DIARY') 
  DO replayf WITH 6,2,'Работает  календаpь/ежедневник  !  Выбоp  данного  pежима  не  возможен  !!!',' Внимание ! '
RETURN (WEXIST('CALENDAR/DIARY'))
ENDIF
RETURN (.F.)

PROCEDURE init
kol_memo=0
FOR x=1 TO FCOUNT()
  IF TYPE(FIELD(x))='M'
    kol_memo=kol_memo+1
 ENDIF
ENDFOR
FOR kol_ind=1 TO 21
  imidx=NDX(kol_ind)
  IF imidx=' '
    EXIT
  ENDIF
ENDFOR

PROCEDURE findpr1
* programm FINDPR1.PRG
* программа поиска по входу подстроки
* conerx,conery    - координаты вывода строки поиска
* anything         - имя поля в котором ищется подстрока
parameter conerx,conery,anything
namestring=space(40)
DO WHILE .T.
@ conery,conerx get namestring picture '@s50'
read
@ 4,15 SAY ' Клавиши   - пpосмотp, <ВВОД>- выбоp, F10- отказ.'
if namestring=' '
   return
endif   
replay=0
set filter to ATC(rtrim(namestring),&anything) <> 0   &&.and. &addusl
go top
if eof()
   SET FILTER TO
   LOOP
endif   
@ conery,conerx say &anything picture '@s50' COLOR SCHEME 7
replay=0
do while replay <> 13
   replay=inkey(0)
   do case
       case replay = -9
         set filter to
         return
      case replay = 5
         if .not. bof()
            @ conery,conerx say '               ждите...                '
            skip -1
         endif     
         @ conery,conerx say &anything picture '@s50' COLOR SCHEME 7
      case replay = 24
         if .not. eof()
            @ conery,conerx say '                ждите...                '   
            skip
         else
            @ conery,conerx say '             конец файла                '   
            WAIT ''
         endif   
         @ conery,conerx say &anything picture '@s50' COLOR SCHEME 7
   endcase                 
enddo 
set filter to
return
ENDDO

PROCEDURE replayf
* выдача на экpан сообшения на time секунд
PARAMETERS koorx,time,text_t,rhelp
ong=LEN(ALLTRIM(text_t))
DEFINE WINDOW soobs FROM koorx,(80-ong)/2-2 TO koorx+4,(80-ong)/2+ong+2 TITLE rhelp SHADOW
ACTIVATE WINDOW soobs
@ 1,1 SAY text_t
=INKEY(time)
DEACTIVATE WINDOW soobs
RELEASE WINDOW soobs

PROCEDURE replayfo
PARAMETERS imokna,koorx,text_t,rhelp
ong=LEN(ALLTRIM(text_t))
DEFINE WINDOW &imokna FROM koorx,(80-ong)/2-2 TO koorx+2,(80-ong)/2+ong+2 TITLE rhelp SHADOW
ACTIVATE WINDOW &imokna
@ 0,1 SAY text_t
SHOW WINDOW &imokna
