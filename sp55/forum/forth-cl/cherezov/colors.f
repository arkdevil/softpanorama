( Компилирую расширения Форта из файла COLORS.F ...)
( Вывод перенаправлен ) TO> NUL

( Copyright (c) 1992 Черезов А.Ю.)
( 236011 Калининград, ул.Батальная, 83-64)

: RGB ( C, N -> ) ( записать цвет C в регистр палитры N )
  SWAP [ HEX ] 100 * + BX ! 1000 AX ! 10 INTR
;
DECIMAL
: COLOR ( C -> ) ( устанавливает физический цвет C )
(  математическому цвету 7 - этим цветом печатают функции DOS )
  7 RGB
;
: EGA? [ HEX ] ( -> F ) ( проверяет, подключен ли EGA )
  0040.0087 S@ 00FF AND 0= NOT
;
: Цвет
  EGA? IF 13 COLOR THEN
;
: НеЦвет
  EGA? IF 7 COLOR THEN
;
: CAPS ( = CAPSLOCK без признака IMMEDIATE )
  [COMPILE] CAPSLOCK
;

( Реализация служебных слов DUMP, .0 , >PRT , PTYPE           )
DECIMAL
: .0
  >R 0 SWAP <# #S #> R> OVER - 0 MAX DUP
    IF 0 DO 48 EMIT LOOP
    ELSE DROP THEN TYPE
;
: >PRT
  DUP BL U< IF DROP 46 THEN
;
: PTYPE
  0 DO DUP C@ >PRT EMIT 1+ LOOP DROP
;
: DUMP    ( адрес, количество -> )
  7 + 8 U/ 0 DO
    CR BASE @ SWAP 16 BASE ! DUP 4 .0 SPACE
    SPACE DUP 8 0
      DO DUP C@ 2 .0 SPACE 1+
      LOOP SWAP 8  PTYPE
  SWAP BASE ! LOOP DROP
;


DECIMAL
: C" ( компилирует код первого символа следующего слова как литерал )
  BL WORD 1+ C@ [COMPILE] LITERAL
; IMMEDIATE
: (")
  R> DUP COUNT + >R
;
: " ( компилирует строку со счетчиком, при исполнении ее адрес )
    ( будет положен на стек )
  STATE @ IF COMPILE (") C" " WORD ",
          ELSE C" " WORD PAD OVER C@ 1+ CMOVE PAD THEN
; IMMEDIATE
: (TLOAD")
  R> DUP COUNT + 1+ >R
  1+ 0 OPEN DUP INFILE ! 0 DUBLH STDIN ! 0 ADH
;
: TLOAD" ( перенаправить ввод на ввод из файла )
  STATE @ IF COMPILE (TLOAD") C" " WORD ", 0 C,
  ELSE TLOAD THEN
; IMMEDIATE
: INTERLOAD ( начать немедленную интерпретацию стандартного ввода )
  BEGIN QUERY INTERPRET STDIN @
  0= UNTIL
;
WARNING 0!
: ENDT. ( закончить ввод по TLOAD )
  ENDT. STDIN 0!
;
-1 WARNING !
: TOFILE
  TO>
;
: NEWF
  CX ! DX ! [ HEX ] 3C00 AX ! FDOS
  CY ABORT" Ошибка при создании файла" AX @
;
: NEWF:
  BL WORD COUNT OVER + 0! 20 NEWF
;
: (NEWFILE:)
  R> COUNT OVER + 1+ >R 20 NEWF
;
: NEWFILE: ( создать новый файл ) ( -> хендл )
  STATE @ IF COMPILE (NEWFILE:) BL WORD ", 0 C,
  ELSE NEWF: THEN
; IMMEDIATE
: (TOFILE:)
  R> COUNT OVER + 1+ >R 1 OPEN DUP
  OUTFILE ! 1 DUBLH STDOUT ! 1 ADH
;
: TOFILE: ( перенаправить стандартный вывод в файл )
  STATE @ IF COMPILE (TOFILE:) BL WORD ", 0 C,
          ELSE TOFILE THEN
; IMMEDIATE
: PREVIEW ( восстановить предыдущий стандартный вывод )
  STDOUT @ DUP 1 ADH CLOSEFILE OUTFILE @ CLOSEFILE
;
DECIMAL     
: CREATPARM ( создать блок параметров для выполнения программы )
  HERE BL WORD DUP ", 1+ 0 , 34 WORD DUP ",
  [ HEX ] 0D , HERE 0 , SWAP ,
  DS @ , 5C , DS @ , 6C , DS @ ,
;
: START ( выполнить программу - только для режима исполнения )
  CREATPARM EXECPRG NOT SWAP HERE - ALLOT ABORT" Ошибка EXEC"
;
: (START")
  R> COUNT OVER + 2+ COUNT + 2+ DUP E + >R
  EXECPRG NOT ABORT" Ошибка START"
;
: START" ( выполнить программу без параметров )
  STATE @ IF COMPILE (START") CREATPARM 2DROP DROP
          ELSE START THEN
; IMMEDIATE
: ("START")
  R@ COUNT OVER + 1+ 2+ ROT OVER ! 2+ DS @ OVER ! 4 -
  R> COUNT + F + >R
  EXECPRG NOT ABORT" Ошибка 'START"
;
: "START" ( выполнить программу с параметрами, заданными P" )
  COMPILE ("START")
  C" " WORD ", 0 C, 0 , 0 , 0 , 5C , DS @ , 6C , DS @ ,
; IMMEDIATE
: (P")
  R> DUP COUNT + 1+ >R
;
: P" ( компилирует строку параметров )
  STATE @ IF COMPILE (P") C" " WORD ", D C,
          ELSE C" " WORD PAD OVER C@ 1+ CMOVE PAD COUNT +
          D SWAP C! PAD THEN
; IMMEDIATE
DECIMAL
: WD ( запускает стандартный текстовый редактор )
  ( перед запуском обязательно задать параметры по P" )
  "START" C:\F\EDITORS\WD.EXE" ." WD OK"
;
: CM
  START" C:\COMMAND.COM  " ." CM OK"
;
: NC
  START" C:\E\NORTON\NC.EXE  " ." NC OK"
;
: SHELL
  START" C:\DOS\DOSSHELL.EXE  " ." SHELL OK"
;


( Определение слова EDIT )
: TOBLOCK ( N -> ) ( ввести 16 строк с клавиатуры )
    ( и перенести их в буфер как блок с номером N )
  BUFFER DUP B/BUF BL FILL
  16 0 DO QUERY
          TIB OVER I 64 * + #TIB @ CMOVE
       LOOP DROP
;
: EDIT ( N -> ) ( отредактировать блок [экран] с номером N )
  NEWFILE: TMP.TMP DROP
  TOFILE: TMP.TMP
  DUP LIST PREVIEW
  P" TMP.TMP" WD TLOAD" TMP.TMP" TOFILE: NUL
  TOBLOCK PREVIEW ENDT.
  UPDATE SAVE-BUFFERS #TIB 0! >IN 0!
;
( Слова для сохранения наработанной программы )      HEX
114 CONSTANT ANAME ( адрес имени виртуального файла )
: STFILE  ( устанавливает другой виртуальный файл, )
          ( имя которго идет следом во входном потоке )
  BL WORD COUNT ANAME SWAP CMOVE
;
: SAVE-SYSTEM ( -> ) ( сохранение наработанной программы )
  STFILE  ( имя .COM-файла берется из входного потока )
  HERE 100 - B/BUF / 2+ 0 DO
  I B/BUF * 100 + I BUFFER B/BUF CMOVE UPDATE
  SAVE-BUFFERS LOOP
  0 BLOCK ANAME + 100 - 9 + " DAT" COUNT ROT SWAP CMOVE
  UPDATE SAVE-BUFFERS
;

DECIMAL
( Векторное поле кода )

: TOCODE 5 - ! ;
: @EXECUTE @ EXECUTE ;
: QUAN ( создает переменную с двумя полями кода )
  0 CONSTANT ['] TOCODE HERE CFL ALLOT !CF ;
: VECT ( создает выполнимую переменную )
  QUAN ['] @EXECUTE (!CODE) ;
: TO ( присваевает значение переменным, созданным по QUAN и VECT )
    BL WORD FIND                                                
    ?DUP 0= ABORT" - ?"                                         
    0< STATE @ AND IF >BODY 2+ ,                                
                   ELSE >BODY 2+ EXECUTE                        
                   THEN                                         
; IMMEDIATE
( Слова для быстрой цветной печати на экране )
HEX

QUAN PAGESEG  QUAN CURSX  QUAN CURSY
B800 TO PAGESEG ( сегментный адрес экранного буфера в текстовом режиме )
( для MDA обычно B000 )
DECIMAL
: ACURS ( вычисление смещения в дисплейном буфере )
  PAGESEG CURSY 160 * CURSX +                                   
;                                                               
: (EM) ( вывод символа, минуя DOS и BIOS )
  ATR @ [ HEX ] 100 * + ACURS S!
  CURSX 2+ TO CURSX
;
DECIMAL
: (TY) ( вывод строки символов )
  ?DUP IF 0 DO DUP C@ (EM) 1+ LOOP DROP THEN
;
: INFO ( просмотр файла SP_INFO.HLP )
  ( файл должен заканчиваться символом  код 15 )
  TLOAD" SP_INFO.HLP"
  CAPS
  BEGIN 14 COLOR
     22 0 DO
        TIB C/L EXPECT CR
        SPAN @ TIB + 1- C@ 15 =
        IF ENDT. #TIB 0! >IN 0! -1 ABORT" : Конец текста" THEN
     LOOP Цвет
  ." Для продолжения нажмите любую клавишу ..., [C] - прервать"
    [ HEX ]
    (KEY) D EMIT 40 SPACES D EMIT
    DF AND C" CC =
     IF ENDT. НеЦвет CAPS #TIB 0! >IN 0! -1 ABORT" : Прерван" THEN
  0 UNTIL
;
HEX
QUAN HOME  QUAN END  QUAN POINTER  QUAN E_LEN  QUAN PEND
QUAN HOMEX QUAN HOMEY
( HOME - адрес начала строки символов )
( END  - адрес последнего возможного символа )
( POINTER - указатель на текущую позицию ввода )
( E-LEN - возможная длина строки )
( PEND - указатель на первый свободный байт после последнего )
(        введенного символа )
( HOMEX, HOMEY - экранные координаты первого символа вводимой строки )
: 1-! ( A -> ) ( уменьшение на 1 значения по адресу A )
  DUP @ 1- SWAP !
;
: 2*
  DUP +
;
: VIEW_E_LINE ( показать строку, вводимую по (EXPECT)
  HOMEX 2* TO CURSX  HOMEY TO CURSY  HOME E_LEN (TY)
;
: INEMIT ( вставка символа в строку, вводимую по (EXPECT)
  POINTER DUP END SWAP - POINTER 1+ SWAP CMOVE>
  PEND 1+ TO PEND  DUP POINTER C!  (EMIT)
  POINTER 1+ TO POINTER
  VIEW_E_LINE
;
: 9TYPE ( печать строки со счетчиком по функции 9 DOS )
  ( строка должна заканчиваться символом $ )
  COUNT DROP DX ! 900 AX ! FDOS
;
: GETCURS ( -> Y, X ) ( получить позицию аппаратного курсора )
  0040.0050 S@ 100 /MOD SWAP
;
: SETCURS ( Y, X -> ) ( установить курсор )
  SWAP 100 * + DX ! BX 0! 200 AX ! 10 INTR
;
( : MLEFT ( сдвинуть курсор влево )
(  " [1D$" 9TYPE)
( ;)
(: MRIGHT ( сдвинуть курсор вправо )
(  " [1C$" 9TYPE)
( ;)
: MLEFT
  GETCURS 1- SETCURS
;
: MRIGHT
  GETCURS 1+ SETCURS
;
: (EXPECT) ( A, +N -> ) ( адрес, количество )
  ( ввод строки символов длиной не более N, по адресу A )
  ( количество введенных символов помещается в переменную SPAN )
  SPAN 0! GETCURS TO HOMEX TO HOMEY TO E_LEN TO HOME
  HOME TO POINTER HOME TO PEND
  HOME E_LEN + 1- TO END
  HOME E_LEN BL FILL
  BEGIN SPAN @ E_LEN
  <> WHILE
  (KEY) CASE
( обработка <ENTER>,<BS>,<DEL>,<HOME>,<END>,<>,<вправо> )
1C0D OF EXIT ENDOF
 E08 OF POINTER HOME <> IF POINTER DUP 1- PEND POINTER - CMOVE
        POINTER 1- TO POINTER PEND 1- TO PEND BL PEND C!
        SPAN 1-! MLEFT VIEW_E_LINE THEN ENDOF
5300 OF POINTER PEND <> IF POINTER 1+ DUP 1- PEND POINTER - CMOVE
        PEND 1- TO PEND BL PEND C! SPAN 1-! VIEW_E_LINE THEN ENDOF
4700 OF HOME TO POINTER HOMEY HOMEX SETCURS ENDOF
4F00 OF PEND TO POINTER HOMEY PEND HOME - HOMEX + SETCURS ENDOF
4B00 OF POINTER HOME <> IF POINTER 1- TO POINTER MLEFT THEN ENDOF
4D00 OF POINTER PEND <> IF POINTER 1+ TO POINTER MRIGHT THEN ENDOF
     INEMIT SPAN 1+! 0 ENDCASE
  REPEAT
;
: INPUT ( Y, X, L, A -> AD) ( ввести строку символов )
  ( координаты, длина, атрибут -> адрес строки со счетчиком )
  ATR ! >R 2DUP 2* TO CURSX TO CURSY R@ 0 DO BL (EM) LOOP
  SETCURS PAD 80 + R> (EXPECT)
  SPAN @ PAD 7F + C! PAD 7F +
;
DECIMAL
: EXECARRAY  ( -> )
  ( используется в виде: EXECARRAY имя слово0 слово1 слово2 .. ; )
  ( при выполнении <N имя> будет выполнено N-е слово )
  CREATE SMUDGE ]
  DOES> SWAP 2* + @EXECUTE
;
VOCABULARY SPISOK
SPISOK DEFINITIONS
: Pred ( NFA -> NFA2 )
  ( получить NFA2 предыдущего слова по NFA текущего слова )
  NAME> 2- @
;
: First? ( NFA -> FLAG ) ( проверяет, является ли слово, заданное )
         ( своим NFA первым в списке )
  Pred DUP
  C@ 1 = SWAP 1+ C@ C" А =
  AND
;
: ContLatest ( -> NFA ) ( адрес поля имени слова, определенного в )
                        ( контексном списке последним )
  CONTEXT @ @
;
: ExecSpisok ( NFA -> NFA2 ) ( выполнить все слова заданного списка )
  ( после выполнения данного слова можно командами       )
  ( Pred ExecSpisok выполнить родительский список и т.д. )
  BEGIN
    DUP NAME> EXECUTE
    DUP Pred SWAP First?
  UNTIL
;
( VOCABULARY VOC1 VOC1 DEFINITIONS)
( : EX1 ." Один " ; : EX2 ." Два " ; : EX3 ." Три " ;)
( VOCABULARY VOC2 VOC2 DEFINITIONS)
( : EX11 ." оДин " ; : EX22 ." дВа " ;)
( VOC1 DEFINITIONS)
( : EX4 ." Четыре " ;)
( VOC2 DEFINITIONS)
( VOCABULARY VOC3 VOC3 DEFINITIONS)
( : EX111 ." одИн " ;)
( VOC2 DEFINITIONS VOCABULARY VOC21)
( : EXX ." дЕсять " ;)
( VOC3 DEFINITIONS)
( : RUNME LATEST PRED EXECSPISOK PRED EXECSPISOK PRED EXECSPISOK DROP ;)
: NoEx
  COUNT CR TYPE ."  - Не могу выполнить" CR
;
VECT NoExec  ' NoEx TO NoExec
: (ExecName:)
  R> DUP COUNT + >R FIND IF EXECUTE ELSE NoExec THEN
;
: ExecName: ( выполнить слово по имени )
  ( поиск осуществляется в момент выполнения, поэтому для )
  ( каждого контекста будет выполняться свое определение, т.е.)
  ( это слово для реализации классического "позднего связывания")
  ( для применения полиморфизма в ООП)
  ( Используется только в режиме компиляции, т.к. в режиме выполнения)
  ( слова могут выполняться и без ExecName:)
  COMPILE (ExecName:) BL WORD ",
  ( в момент компиляции существование слова не проверяется, т.к. оно )
  ( может появиться позже )
; IMMEDIATE
: :N ( -> ) ( используется в виде :N слово1 слово2 ... словоX ;N )
            ( внутри определений через двоеточие )
  ( компилирует вместо CFA слова его имя, в результате словарная )
  ( статья становится намного больше, но зато полученное слово )
  ( может выполнять разные действия в зависимости от контекста )
  ( можно каждую такую ссылку определять через EXECNAME:, полученная )
  ( словарная статья будет иметь тот же вид:  :N .. ;N применяется )
  ( только для большей наглядности и компактности исходных текстов )
  BEGIN
    COMPILE (ExecName:)
    BL WORD DUP ( T, T )
    COUNT 2 =   ( T, A, длина слова=2)
    SWAP DUP C@ C" ; =  ( T, длина слова=2, A, первая буква=';' )
    SWAP 1+ C@ C" N = ( T, длинаслова=2, перваябуква=';',втораябуква='N')
    AND AND NOT ( T, слово - не ';N')
  WHILE
    ",
  REPEAT DROP -2 ALLOT
; IMMEDIATE
PREVIEW
ENDT.
