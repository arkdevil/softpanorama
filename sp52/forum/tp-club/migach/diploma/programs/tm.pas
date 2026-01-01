
            {-------------------------------------------------}
            {      Программа Test Models ( TM ) V 1.0         }
            {      Моделирование цифровых электронных         }
            {                 схем                            }
            {-------------------------------------------------}
            { Язык программирования : Turbo Pascal V 6.0      }
            {-------------------------------------------------}
            { Дата создания : 07/03/1992                      }
            { Дата последних изменений : 08/04/1992           }
            {-------------------------------------------------}
            { Демонстрационная программа пакетов моделирования}
            {          цифровых электронных схем              }
            {-------------------------------------------------}
            {  (c) 1992 Ярослав Мигач                         }
            {-------------------------------------------------}

PROGRAM TestModels;

USES Crt, Dos, GModel, CModel, KeyModel, BLModel, SLModel;

VAR
   Power  : PowerModelPtr;
   Ground : GroundModelPtr;
   Key    : SimpleKeyPtr;
   ElAND1 : Logic_2AND_NOTPtr;
   ElAND2 : Logic_2AND_NOTPtr;
   ElNOT1 : Logic_NotPtr;
   ElNOT2 : Logic_NotPtr;
   ElNOT3 : Logic_NotPtr;

   Model : ARRAY [ 1..8 ] OF BaseModelPtr;

   SingExit : BOOLEAN;

   Graphic : ARRAY [ 1..5 ] OF STRING [ 50 ];

   Timer : WORD;

{----------------------------------------------------------}

PROCEDURE ShowList;

          { Отображение подсказки }

PROCEDURE Ls ( Mess : STRING );

BEGIN
     WRITELN ( Mess )

END; { Procedure Ls }

VAR
   Index, Hlp : BYTE;

BEGIN
     GOTOXY ( 1, 1 );
     TEXTCOLOR ( LIGHTMAGENTA );
Ls ( '           Демонстрационная программа пакета моделирования' );
Ls ( '                  цифровых электронных схем' );

     GOTOXY ( 1, 12 );
     TEXTCOLOR ( LIGHTBLUE );

Ls ( '      КН1      И1    ┌──────────────────────────────┐    И2       ');
Ls ( '     ══╤══   ┌────┐  │                              │   ┌────┐    ');
Ls ( '  ┌───   ────┤  & │  │  НЕ1       НЕ2        НЕ3    └───┤  & │ вых');
Ls ( '  │          │    №──┤ ┌────┐    ┌────┐     ┌────┐      │    №────');
Ls ( '  │      ┌───┤    │  │ │    │    │    │     │    │   ┌──┤    │    ');
Ls ( ' ═╧═     │   └────┘  └─┤    №────┤    №─────┤    №───┘  └────┘    ');
Ls ( '         │             │    │    │    │     │    │                ');
Ls ( '         │             └────┘    └────┘     └────┘                ');
Ls ( '          +3.0                                                    ');

     TEXTCOLOR ( WHITE );
Ls ( '' );
Ls ( '      "1" - Включить,  "0" - Выключить,   ESC - Выход  ' );
Ls ( '' );
     TEXTCOLOR ( MAGENTA );
Ls ( '              (c) 1992  Ярослав Мигач' );


     TEXTCOLOR ( WHITE );
     GOTOXY ( 26, 4 );
     WRITE ( '   U  вых' );
     FOR Index := 5 TO 10 DO
         BEGIN
              GOTOXY ( 26, Index );
              WRITE ( ' │ ' )
         END;
    GOTOXY ( 26, 11 );
    WRITE ( ' └' );
    FOR Index := 1 TO 50 DO
        WRITE ( '─' );
    WRITE ( ' t' );

    FOR Index := 1 TO 5 DO
        BEGIN
             Graphic [ Index ] := '';
             FOR Hlp := 1 TO 50 DO
                 Graphic [ Index ] := Graphic [ Index ] + ' '
        END;

END; { procedure ShowList }

{----------------------------------------------------------}

PROCEDURE ShowResult;

          { Отображение текущего результата моделирования }
VAR
   UStr, KeyStr : STRING [ 30 ];
   Sing : BOOLEAN;
   CurrentState : InformLm;
   Index : BYTE;
   U : REAL;
   Hlp : LONGINT;

BEGIN
     {= Отображение численных результатов моделирования =}

     IF ( Key^.GetStateSwitch ( 1 ) ) THEN
         KeyStr := 'КН1 - Включено  ON   '
     ELSE
         KeyStr := 'КН1 - Выключено  OFF  ';
     TEXTCOLOR ( LIGHTGREEN );
     GOTOXY ( 1, 5 );
     WRITE ( KeyStr );

     ElAND1^.GetStateLm ( 3, CurrentState );
     STR ( CurrentState.U : 5 : 2, UStr );
     UStr := 'Выход схемы  И1- ' + UStr + '  ';
     TEXTCOLOR ( LIGHTRED );
     GOTOXY ( 1, 6 );
     WRITE ( UStr );

     ElAND2^.GetStateLm ( 3, CurrentState );
     STR ( CurrentState.U : 5 : 2, UStr );
     UStr := 'Выход схемы  И2- ' + UStr + '  ';
     U := CurrentState.U;
     TEXTCOLOR ( LIGHTRED );
     GOTOXY ( 1, 7 );
     WRITE ( UStr );

     ElNOT1^.GetStateLm ( 2, CurrentState );
     STR ( CurrentState.U : 5 : 2, UStr );
     UStr := 'Выход схемы  НЕ1- ' + UStr + '  ';
     TEXTCOLOR ( YELLOW );
     GOTOXY ( 1, 8 );
     WRITE ( UStr );

     ElNOT2^.GetStateLm ( 2, CurrentState );
     STR ( CurrentState.U : 5 : 2, UStr );
     UStr := 'Выход схемы  НЕ2- ' + UStr + '  ';
     TEXTCOLOR ( YELLOW );
     GOTOXY ( 1, 9 );
     WRITE ( UStr );

     ElNOT3^.GetStateLm ( 2, CurrentState );
     STR ( CurrentState.U : 5 : 2, UStr );
     UStr := 'Выход схемы  НЕ3- ' + UStr + '  ';
     TEXTCOLOR ( YELLOW );
     GOTOXY ( 1, 10 );
     WRITE ( UStr );

     {= Отображение графика выходного напряжения =}

     IF ( ( Timer MOD 2 ) = 0 ) THEN  { Масштабирование оси времени }
        BEGIN
             FOR Index := 1 TO 5 DO
                 BEGIN
                      MOVE ( Graphic [ Index ] [ 1 ],
                                 Graphic [ Index ] [ 2 ], 49 );
                      Graphic [ index ] [ 1 ] := ' '
                  END;
             TEXTCOLOR ( GREEN );
             Hlp := ROUND ( U + 1.5 );
             IF ( ( Hlp >= 1 ) AND ( Hlp < 6 ) ) THEN
                Graphic [ Hlp ] [ 1 ] := '*';
             FOR Index := 1 TO 5 DO
                 BEGIN
                      GOTOXY ( 28, 11 - Index );
                      WRITE ( Graphic [ Index ] )
                 END;
        END;

     TEXTCOLOR ( LIGHTGRAY )

END; { procedure ShowResult }

{----------------------------------------------------------}

PROCEDURE InitSystem;

          { Инициализация ситемы моделирования }
VAR
   Err : BYTE;

PROCEDURE ErrConnect ( Num : BYTE );

BEGIN
     IF ( Err = 0 ) THEN
        EXIT;
     CLRSCR;
     WRITELN ( 'Ошибка соединения  # ', Err, ' Соединение - ', Num );
     HALT ( 1 );

END; { procedure ErrConnect }

BEGIN

     {= Инициализация обьектов =}

     NEW ( Power, Init ( 3.0 ) );
     NEW ( Ground, Init );
     NEW ( Key, Init );
     NEW ( ElAND1, Init ( 3.0, 0.1, 0.5, 1.5, 0.3, 15, 1, 10.0 ) );
     NEW ( ElAND2, Init ( 3.0, 0.1, 0.5, 1.5, 0.3, 15, 1, 10.0 ) );
     NEW ( ElNOT1, Init ( 3.0, 0.1, 0.5, 1.5, 0.3, 10, 1, 10.0 ) );
     NEW ( ElNOT2, Init ( 3.0, 0.1, 0.5, 1.5, 0.3, 10, 1, 10.0 ) );
     NEW ( ElNOT3, Init ( 3.0, 0.1, 0.5, 1.5, 0.3, 10, 1, 10.0 ) );

     {= Карта соединений =}

     ConnectModels ( 1, Ground, 1, Key, Err );
     ErrConnect ( 1 );

     ConnectModels ( 2, Key, 1, ElAND1, Err );
     ErrConnect ( 2 );

     ConnectModels ( 1, Power, 2, ElAND1, Err );
     ErrConnect ( 3 );

     ConnectModels ( 3, ElAND1, 1, ElAND2, Err );
     ErrConnect ( 4 );

     ConnectModels ( 3, ElAND1, 1, ElNOT1, Err );
     ErrConnect ( 4 );

     ConnectModels ( 2, ElNOT1, 1, ElNOT2, Err );
     ErrConnect ( 5 );

     ConnectModels ( 2, ElNOT2, 1, ElNOT3, Err );
     ErrConnect ( 6 );

     ConnectModels ( 2, ElNOT3, 2, ElAND2, Err );
     ErrConnect ( 7 );


     {= Сборка массива моделей =}

     Model [ 1 ] := Power;
     Model [ 2 ] := Ground;
     Model [ 3 ] := Key;
     Model [ 4 ] := ElAnd1;
     Model [ 5 ] := ElAnd2;
     Model [ 6 ] := ElNot1;
     Model [ 7 ] := ElNot2;
     Model [ 8 ] := ElNot3

END; { procedure InitSystem }

{----------------------------------------------------------}

PROCEDURE SetKeys;

          { Процедура управления моделью }
VAR
   Ch : CHAR;

BEGIN
     IF ( NOT KEYPRESSED ) THEN
        EXIT;
     Ch := READKEY;
     IF ( KEYPRESSED ) THEN
        Ch := READKEY;
     IF ( Ch = #27 ) THEN
        BEGIN
             SingExit := TRUE;
             EXIT
        END;
     IF ( Ch = '1' ) THEN
        BEGIN
             Key^.SetSwitch ( 1 );
             EXIT
        END;
     IF ( Ch = '0' ) THEN
        BEGIN
             Key^.DoneSwitch ( 1 );
             EXIT;
        END;
     SOUND ( 800 );
     DELAY ( 500 );
     NOSOUND

END; { procedure SetKeys }

{----------------------------------------------------------}

PROCEDURE Run;

          { Запуск модели }
VAR
   Index : BYTE;

BEGIN
     FOR Index := 1 TO 8 DO
         Model [ Index ]^.RunModel;
     SetKeys;
     ShowResult

END; { procedure Run }

{----------------------------------------------------------}

PROCEDURE SetStart;

          { Предстартовые установки }
VAR
   Index : BYTE;

BEGIN
     FOR Index := 1 TO 8 DO
         Model [ Index ]^.SetStart

END; { procedure SetStart }

{----------------------------------------------------------}

PROCEDURE Done;

          { Уничтожение модели }
VAR
   Index : BYTE;

BEGIN
     FOR Index := 1 TO 8 DO
         DISPOSE ( Model [ Index ], Done )

END; { procedure Done }

{----------------------------------------------------------}

BEGIN
     RANDOMIZE;
     WINDOW ( 1, 1, 80, 25 );
     CLRSCR;
     ShowList;
     SingExit := FALSE;
     Timer := 1;
     InitSystem;
     SetStart;
     REPEAT
           Run;
           INC ( Timer );
           DELAY ( 100 )
     UNTIL ( SingExit );
     Done;
     GOTOXY ( 1, 25 )

END. { Program TestModels }

