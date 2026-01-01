
         {----------------------------------------------------}
         {        Программа "Хирургический стационар"         }
         {                  Static                            }
         {              Модуль Def V 1.2                      }
         {     Язык программирования Turbo Pascal  V 6.0      }
         {----------------------------------------------------}
         { Дата последних изменений :  15/10/1991             }
         {----------------------------------------------------}
         {   Модуль определений и низкоуровнево ввода         }
         {----------------------------------------------------}
         { (c) 1990-1991, Мигач Ярослав                       }
         {----------------------------------------------------}


UNIT Def;

{$IFDEF DEBUGDEF }
        {$D+,L+,R+,S+}
{$ELSE}
        {$D-,L-,R-,S-}
{$ENDIF}
{$F+,O+,A+,B-,I-}

INTERFACE

USES DOS, Crt;

TYPE
        { ===     Переменные     === }

     StandartString = String [ 79 ];

     TextScreen = ARRAY [ 1..25, 1..80 ] OF RECORD
                                                 ch : CHAR;
                                                 at : BYTE
                                            END;

        { === Процедуры и функции === }

     LoadFunction = FUNCTION : BYTE;

     ControlFunction = FUNCTION : BOOLEAN;

     KeyFunction = FUNCTION : CHAR;

     RealFunction = FUNCTION ( x : REAL ) : REAL;

     CheckEditFunc = FUNCTION ( VAR Stroka : StandartString ) : BOOLEAN;

     RunProcedure = PROCEDURE;

     HelpEditProc = PROCEDURE ( VAR Stroka : StandartString );

FUNCTION GetKey : CHAR;
FUNCTION SingKey : BOOLEAN;
PROCEDURE AnyKey;
PROCEDURE HideKey;
FUNCTION NulLoadFunction : BYTE;
FUNCTION NulControlFunction : BOOLEAN;
FUNCTION NulRealFunction ( x : REAL ) : REAL;
FUNCTION NulCheckEditFunc ( VAR Stroka : StandartString ) : BOOLEAN;
PROCEDURE NulRunProcedure;
PROCEDURE NulHelpEditProc ( VAR Stroka : StandartString );
FUNCTION NulKeyFunction : CHAR;
PROCEDURE SetNameText ( Name : StandartString );
PROCEDURE ReadText ( VAR Line : StandartString );
FUNCTION EofText : BOOLEAN;
PROCEDURE CloseText;
FUNCTION DefResult : BYTE;
PROCEDURE SetHeapMess ( HeapMess : StandartString );
PROCEDURE SetMakeDemonstration ( Name : StandartString );
PROCEDURE SetEmulation ( Name : StandartString );
PROCEDURE CloseDef;
PROCEDURE SetWait ( Wait : WORD );
PROCEDURE SetLeftButton ( Ch1, Ch2 : CHAR );
PROCEDURE SetRightButton ( Ch1, Ch2 : CHAR );
PROCEDURE SetMouseLeft ( Ch1, Ch2 : CHAR );
PROCEDURE SetMouseRight ( Ch1, Ch2 : CHAR );
PROCEDURE SetMouseUp ( Ch1, Ch2 : CHAR );
PROCEDURE SetMouseDown ( Ch1, Ch2 : CHAR );
PROCEDURE MouseOn;
PROCEDURE MouseOff;
PROCEDURE SetPassword ( Ps : BYTE );

IMPLEMENTATION

CONST
     MaxBuf = $1000;

VAR
   fl : FILE OF CHAR;
   Name_Fl : StandartString;
   ft : FILE;
   Error : BYTE;
   HMess, Help : StandartString;
   ControlDef : BYTE;
   DefWait : WORD;
   EofKey : BYTE;
   SingMouse : BOOLEAN;
   rg : REGISTERS;
   Ch1, Ch2 : CHAR;
   SingCh1, SingCh2 : BOOLEAN;
   Btl, Btr : BOOLEAN;
   RightButton : ARRAY [ 1..2 ] OF CHAR;
   LeftButton : ARRAY [ 1..2 ] OF CHAR;
   MouseLeft, MouseRight, MouseUp, MouseDown : ARRAY [ 1..2 ] OF CHAR;
   PasswordText : BYTE;
   Buffer : ARRAY [ 1..MaxBuf ] OF BYTE;
   IndBuf : WORD;
   SizeBuf : WORD;

{$I-}

{----------------------------------------------------------}

PROCEDURE SetNameText ( Name : StandartString );

BEGIN
     IF ( ControlDef IN [ 0, 1 ] ) THEN
        BEGIN
             ASSIGN ( ft, Name );
             RESET ( ft, 1 );
             Error := IORESULT
        END;
     EofKey := 0

END; { procedure SetNameText }

{----------------------------------------------------------}

FUNCTION NextChar : CHAR;

         { Получить символ из текстового файла }
BEGIN
     IF ( ( SizeBuf ) < IndBuf ) THEN
        BEGIN
             BLOCKREAD ( Ft, Buffer, MaxBuf, SizeBuf );
             Error := IORESULT;
             IF ( SizeBuf = 0 ) THEN
                BEGIN
                     EofKey := 1;
                     NextChar := ' ';
                     EXIT
                END;
             IndBuf := 1;
        END;
     NextChar := CHR ( Buffer [ IndBuf ] - PasswordText );
     INC ( IndBuf )

END; { function NextChar  }

{---------------------------------------------------------}

PROCEDURE GetLine ( VAR Line : STRING );

VAR
   Ch1, Ch2 : CHAR;
   HelpS : STRING;

BEGIN
     Line := '';
     IF ( EofKey <> 0 ) THEN
        EXIT;
     Ch2 := ' ';
     REPEAT
           Ch1 := Ch2;
           Ch2 := NextChar;
           IF ( ( Ch2 <> #$0D ) AND ( Ch2 <> #$0A ) ) THEN
              Line := Line + Ch2
     UNTIL ( ( ( Ch1 = #$0D ) AND ( Ch2 = #$0A ) ) OR ( EofKey <> 0 ) )

END; { procedure GetLine }

{----------------------------------------------------------}

PROCEDURE ReadText ( VAR Line : StandartString );

VAR
   index : BYTE;
   Ch : CHAR;

BEGIN
     IF ( ControlDef IN [ 0, 1 ] ) THEN
        BEGIN
             GetLine ( Line );
             IF ( ControlDef = 1 ) THEN
                BEGIN
                     FOR index := 1 TO LENGTH ( Line ) DO
                         BEGIN
                              WRITE ( Fl, Line [ index ] );
                              IF ( IORESULT <> 0 ) THEN
                                 BEGIN
                                      CLRSCR;
                                      TEXTCOLOR ( WHITE );
                                      TEXTBACKGROUND ( BLACK );
                                      WRITELN;
                                      WRITELN ( 'Ошибка записи',
                                                ' демонстрационного файла' );
                                      WRITELN;
                                      CLOSE ( Fl );
                                      CLOSE ( Ft );
                                      HALT ( 1 )
                                 END
                         END;
                     Ch := #0;
                     WRITE ( Fl, Ch );
                     IF ( IORESULT <> 0 ) THEN
                        BEGIN
                             CLRSCR;
                             TEXTCOLOR ( WHITE );
                             TEXTBACKGROUND ( BLACK );
                             WRITELN;
                             WRITELN ( 'Ошибка записи',
                                       ' демонстрационного файла' );
                             WRITELN;
                             CLOSE ( Fl );
                             CLOSE ( Ft );
                             HALT ( 1 )
                        END
                END
        END;
     IF ( ControlDef = 2 ) THEN
        BEGIN
             Help := '';
             READ ( Fl, Ch );
             IF ( IORESULT <> 0 ) THEN
                BEGIN
                     CLRSCR;
                     TEXTCOLOR ( WHITE );
                     TEXTBACKGROUND ( BLACK );
                     WRITELN;
                     WRITELN ( 'Ошибка чтения',
                               ' демонстрационного файла' );
                     WRITELN;
                     CLOSE ( Fl );
                     HALT ( 1 )
                END;
             WHILE ( Ch <> #0 ) DO
                   BEGIN
                        Help := Help + Ch;
                        READ ( Fl, Ch );
                        IF ( IORESULT <> 0 )THEN
                           BEGIN
                                CLRSCR;
                                TEXTCOLOR ( WHITE );
                                TEXTBACKGROUND ( BLACK );
                                WRITELN;
                                WRITELN ( 'Ошибка чтения',
                                          ' демонстрационного файла' );
                                WRITELN;
                                CLOSE ( Fl );
                                HALT ( 1 )
                           END
                   END;
             Line := Help
        END

END; { procedure ReadText }

{----------------------------------------------------------}

FUNCTION EofText : BOOLEAN;

VAR
   Ch : CHAR;

BEGIN
     IF ( ControlDef IN [ 0, 1 ] ) THEN
        BEGIN
             EofText := ( EofKey <> 0 );
             Error := IORESULT;
             IF ( ControlDef = 1 ) THEN
                BEGIN
                     IF ( EofKey <> 0 ) THEN
                        Ch := #255
                     ELSE
                        Ch := #0;
                     WRITE ( Fl, Ch )
                END;
        END;
     IF ( ControlDef = 2 ) THEN
        BEGIN
             READ ( fl, Ch );
             IF ( Ch IN [ #0, #255 ] ) THEN
                BEGIN
                     IF ( Ch = #255 ) THEN
                        EofText := TRUE
                     ELSE
                        EofText := FALSE
                END
             ELSE
                 BEGIN
                     CLRSCR;
                     TEXTCOLOR ( WHITE );
                     TEXTBACKGROUND ( BLACK );
                     WRITELN ( CHR ( 07 ) );
                     WRITELN ( 'Ошибка синхронизации #1, модуль DEF' );
                     WRITELN ( 'Ch = ', Ch, '  ', ORD ( Ch ) );
                     WRITELN ( 'Help = ', Help );
                     WRITELN;
                     CLOSE ( Fl );
                     CLOSE ( Ft );
                     HALT ( 1 )
                 END;
        END

END; { function EofText }

{----------------------------------------------------------}

PROCEDURE CloseText;

BEGIN
     IF ( ControlDef IN [ 0, 1 ] ) THEN
        BEGIN
             CLOSE ( ft );
             Error := IORESULT
        END

END; { procedure CloseText }

{----------------------------------------------------------}

FUNCTION DefResult : BYTE;

BEGIN
     IF ( ControlDef IN [ 0, 1 ] ) THEN
        BEGIN
             DefResult := Error;
             Error := 0
        END;
     IF ( ControlDef = 2 ) THEN
        BEGIN
             DefResult := 0
        END

END; { function DefResult }

{----------------------------------------------------------}

PROCEDURE SetRightButton ( Ch1, Ch2 : CHAR );

BEGIN
     RightButton [ 1 ] := Ch1;
     RightButton [ 2 ] := Ch2

END; { procedure SetRightButton }

{----------------------------------------------------------}

PROCEDURE SetLeftButton ( Ch1, Ch2 : CHAR );

BEGIN
     LeftButton [ 1 ] := Ch1;
     LeftButton [ 2 ] := Ch2

END; { procedure SetLeftButton }

{----------------------------------------------------------}

PROCEDURE  SetMouseLeft ( Ch1, Ch2 : CHAR );

BEGIN
     MouseLeft [ 1 ] := Ch1;
     MouseLeft [ 2 ] := Ch2

END; { procedure SetMouseLeft }

{----------------------------------------------------------}

PROCEDURE  SetMouseRight ( Ch1, Ch2 : CHAR );

BEGIN
     MouseRight [ 1 ] := Ch1;
     MouseRight [ 2 ] := Ch2

END; { procedure SetMouseRight }

{----------------------------------------------------------}

PROCEDURE  SetMouseUp ( Ch1, Ch2 : CHAR );

BEGIN
     MouseUp [ 1 ] := Ch1;
     MouseUp [ 2 ] := Ch2

END; { procedure SetMouseUp }

{----------------------------------------------------------}

PROCEDURE  SetMouseDown ( Ch1, Ch2 : CHAR );

BEGIN
     MouseDown [ 1 ] := Ch1;
     MouseDown [ 2 ] := Ch2

END; { procedure SetMouseDown }

{----------------------------------------------------------}

PROCEDURE GoMouse;

VAR
   sbl, sbr : BOOLEAN;
   Key : BOOLEAN;

BEGIN
     rg.AX := $0003;
     INTR ( $33, rg );
     sbl := ( ( rg.BX AND $0001 ) <> 0 );
     sbr := ( ( rg.BX AND $0002 ) <> 0 );
     IF ( Btl AND ( NOT sbl ) ) THEN
        BEGIN
             SingCh1 := TRUE;
             Ch1 := LeftButton [ 1 ];
             IF ( ORD ( LeftButton [ 2 ] ) <> 0 ) THEN
                BEGIN
                     SingCh2 := TRUE;
                     Ch2 := LeftButton [ 2 ]
                END;
             Btl := sbl;
             EXIT
        END;
     IF ( Btr AND ( NOT sbr ) ) THEN
        BEGIN
             SingCh1 := TRUE;
             Ch1 := RightButton [ 1 ];
             IF ( ORD ( RightButton [ 2 ] ) <> 0 ) THEN
                BEGIN
                     SingCh2 := TRUE;
                     Ch2 := RightButton [ 2 ]
                END;
             Btr := sbr;
             EXIT
        END;
     Btl := sbl;
     Btr := sbr;

     Key := FALSE;
     IF ( rg.CX < 300 ) THEN
        BEGIN
             Key := TRUE;
             SingCh1 := TRUE;
             Ch1 := MouseRight [ 1 ];
             IF ( MouseRight [ 2 ] <> #0 ) THEN
                BEGIN
                     SingCh2 := TRUE;
                     Ch2 := MouseRight [ 2 ]
                END
        END;
     IF ( rg.CX > 340 ) THEN
        BEGIN
             Key := TRUE;
             SingCh1 := TRUE;
             Ch1 := MouseLeft [ 1 ];
             IF ( MouseLeft [ 2 ] <> #0 ) THEN
                BEGIN
                     SingCh2 := TRUE;
                     Ch2 := MouseLeft [ 2 ]
                END
        END;
     IF ( rg.DX < 90 ) THEN
        BEGIN
             Key := TRUE;
             SingCh1 := TRUE;
             Ch1 := MouseUp [ 1 ];
             IF ( MouseUp [ 2 ] <> #0 ) THEN
                BEGIN
                     SingCh2 := TRUE;
                     Ch2 := MouseUp [ 2 ]
                END
        END;
     IF ( rg.DX > 110 ) THEN
        BEGIN
             Key := TRUE;
             SingCh1 := TRUE;
             Ch1 := MouseDown [ 1 ];
             IF ( MouseDown [ 2 ] <> #0 ) THEN
                BEGIN
                     SingCh2 := TRUE;
                     Ch2 := MouseDown [ 2 ]
                END
        END;
     IF ( Key ) THEN
        BEGIN
             rg.AX := $0004;
             rg.DX := 99;
             rg.CX := 319;
             INTR ( $33, rg )
        END;

END; { procedure GoMouse }

{----------------------------------------------------------}

FUNCTION GetKey : CHAR;

VAR
   Ch : CHAR;
   Key : BOOLEAN;

BEGIN
     Key := FALSE;
     IF ( ControlDef IN [ 0, 1 ] ) THEN
        BEGIN
             IF ( ( SingMouse ) AND ( NOT SingCh1 ) AND ( NOT SingCh2 ) )
                THEN
                    GoMouse;
             WHILE ( ( NOT SingCh1 ) AND ( NOT SingCh2 ) AND
                   ( NOT Key ) ) DO
                   BEGIN
                        IF ( KEYPRESSED ) THEN
                           BEGIN
                                Ch := READKEY;
                                Key := TRUE
                           END
                        ELSE
                            IF ( SingMouse ) THEN
                               GoMouse
                   END;
             IF ( SingCh1 ) THEN
                BEGIN
                     Ch := Ch1;
                     SingCh1 := FALSE
                END
             ELSE
                 IF ( SingCh2 ) THEN
                    BEGIN
                         Ch := Ch2;
                         SingCh2 := FALSE
                    END;
             GetKey := Ch;
             IF ( ControlDef = 1 ) THEN
                BEGIN
                     WRITE ( Fl, Ch );
                     IF ( IORESULT <> 0 ) THEN
                        BEGIN
                             CLRSCR;
                             TEXTCOLOR ( WHITE );
                             TEXTBACKGROUND ( BLACK );
                             WRITELN;
                             WRITELN ( 'Ошибка записи',
                                       ' демонстрационного файла' );
                             WRITELN;
                             CLOSE ( Fl );
                             CLOSE ( Ft );
                             HALT ( 1 )
                        END
                END
        END;
     IF ( ControlDef = 2 ) THEN
        BEGIN
              IF ( KEYPRESSED ) THEN
                 Ch := READKEY;
              IF ( ( Ch = #0 ) AND ( KEYPRESSED ) ) THEN
                 Ch := READKEY
              ELSE
                  IF ( Ch = #03 ) THEN
                     BEGIN
                          WINDOW ( 1, 1, 80, 25 );
                          CLRSCR;
                          TEXTCOLOR ( WHITE );
                          TEXTBACKGROUND ( BLACK );
                          WRITELN;
                          WRITELN ( 'Прерывание демонстрационной версии' );
                          WRITELN;
                          CLOSE ( Fl );
                          HALT ( 255 )
                     END;
              READ ( Fl, Ch );
              IF ( IORESULT <> 0 ) THEN
                 BEGIN
                      CLRSCR;
                      TEXTCOLOR ( WHITE );
                      TEXTBACKGROUND ( BLACK );
                      WRITELN;
                      WRITELN ( 'Ошибка чтения',
                                ' демонстрационного файла' );
                      WRITELN;
                      CLOSE ( Fl );
                      HALT ( 1 )
                 END;
              GetKey := Ch;
              DELAY ( DefWait )
        END

END; { function GetKey }

{----------------------------------------------------------}

FUNCTION SingKey : BOOLEAN;

VAR
   Key : BOOLEAN;
   Ch : CHAR;

BEGIN
     IF ( ControlDef IN [ 0, 1 ] ) THEN
        BEGIN
             IF ( ( SingMouse ) AND ( NOT SingCh1 ) AND ( NOT SingCh2 ) )
                THEN
                    GoMouse;
             Key := KEYPRESSED;
             Key := ( ( Key ) OR ( SingCh1 ) OR ( SingCh2 ) );
             SingKey := Key;
             IF ( ControlDef = 1 ) THEN
                BEGIN
                     IF ( Key ) THEN
                        Ch := #01
                     ELSE
                        Ch := #0;
                     WRITE ( Fl, Ch );
                     IF ( IORESULT <> 0 ) THEN
                        BEGIN
                             CLRSCR;
                             TEXTCOLOR ( WHITE );
                             TEXTBACKGROUND ( BLACK );
                             WRITELN;
                             WRITELN ( 'Ошибка записи',
                                      ' демонстрационного файла' );
                             WRITELN;
                             CLOSE ( Fl );
                             CLOSE ( Ft );
                             HALT ( 1 )
                        END
                END
        END;
     IF ( ControlDef = 2 ) THEN
        BEGIN
             READ ( Fl, Ch );
             IF ( IORESULT <> 0 ) THEN
                 BEGIN
                      CLRSCR;
                      TEXTCOLOR ( WHITE );
                      TEXTBACKGROUND ( BLACK );
                      WRITELN;
                      WRITELN ( 'Ошибка чтения',
                                ' демонстрационного файла' );
                      WRITELN;
                      CLOSE ( Fl );
                      HALT ( 1 )
                 END;
             IF ( Ch = #01 ) THEN
                SingKey := TRUE;
             IF ( Ch = #0 ) THEN
                SingKey := FALSE;
             IF ( NOT ( Ch IN [ #0, #01 ] )  ) THEN
                BEGIN
                     CLRSCR;
                     TEXTCOLOR ( WHITE );
                     TEXTBACKGROUND ( BLACK );
                     WRITELN ( CHR ( 07 ) );
                     WRITELN ( 'Ошибка синхронизации #2, модуль DEF' );
                     WRITELN ( 'Ch = ', Ch, '  ', ORD ( Ch ) );
                     WRITELN ( 'Help = ', Help );
                     WRITELN;
                     CLOSE ( Fl );
                     HALT ( 1 )
                END
        END

END; { function SingKey }

{----------------------------------------------------------}

PROCEDURE AnyKey;

VAR
   ch : CHAR;
   index : BYTE;

BEGIN
     IF ( ControlDef IN [ 0, 1 ] ) THEN
        BEGIN
             WHILE ( KEYPRESSED ) DO
                   ch := READKEY;
             ch := READKEY;
             WHILE ( KEYPRESSED ) DO
                   ch := READKEY
        END;
     IF ( ControlDef = 2 ) THEN
        FOR index := 1 TO 5 DO
            DELAY ( DefWait )

END; { procedure AnyKey }

{----------------------------------------------------------}

PROCEDURE HideKey;

VAR
  ch : CHAR;

BEGIN
     WHILE ( KEYPRESSED ) DO
           ch := READKEY

END; { procedure HideKey }

{----------------------------------------------------------}

FUNCTION NulLoadFunction : BYTE;

BEGIN
     NulLoadFunction := 0

END; { function NulLoadFunction }

{----------------------------------------------------------}

FUNCTION NulControlFunction : BOOLEAN;

BEGIN
     NulControlFunction := FALSE

END; { function NulControlFunction }

{----------------------------------------------------------}

FUNCTION NulRealFunction ( x : REAL ) : REAL;

BEGIN
     NulRealFunction := 0.0

END; { function NulRealFunction }

{----------------------------------------------------------}

FUNCTION NulCheckEditFunc ( VAR Stroka : StandartString ) : BOOLEAN;

BEGIN
     NulCheckEditFunc := TRUE

END; { function NulCheckEditFunc }

{----------------------------------------------------------}

PROCEDURE NulRunProcedure;

BEGIN

END; { procedure NulRunProcedure }

{----------------------------------------------------------}

PROCEDURE NulHelpEditProc ( VAR Stroka : StandartString );

BEGIN

END; { procedure NulHelpEditProc }

{----------------------------------------------------------}

PROCEDURE SetHeapMess ( HeapMess : StandartString );

BEGIN
     HMess := HeapMess

END; { procedure SetHeapMess }

{----------------------------------------------------------}

FUNCTION NulKeyFunction : CHAR;

BEGIN
     NulKeyFunction := #27;

END; { function KeyFunction }

{----------------------------------------------------------}

FUNCTION HeapFunc ( Size : WORD ) : INTEGER;

BEGIN
     HeapFunc := 0;
     CLRSCR;
     TEXTCOLOR ( WHITE );
     TEXTBACKGROUND ( BLACK );
     WRITELN;
     WRITELN ( 'Нет памяти для размещения динамических переменных' );
     WRITELN ( HMess );
     WRITELN ( 'Аварийный останов программы' );
     WRITELN

END; { function HeapFunc }

{----------------------------------------------------------}

PROCEDURE SetMakeDemonstration ( Name : StandartString );

BEGIN
     Name_Fl := Name;
     ASSIGN ( fl, Name_Fl );
     REWRITE ( fl );
     IF ( IORESULT <> 0 ) THEN
        BEGIN
             CLRSCR;
             TEXTCOLOR ( WHITE );
             TEXTBACKGROUND ( BLACK );
             WRITELN ( CHR ( 07 ) );
             WRITELN ( 'Ошибка создания демонстрационного файла' );
             HALT ( 1 )
        END;
     ControlDef := 1

END; { procedure SetMakeDemonstration }

{----------------------------------------------------------}

PROCEDURE SetEmulation ( Name : StandartString );

BEGIN
     Name_Fl := Name;
     ASSIGN ( fl, Name_Fl );
     RESET ( fl );
     IF ( IORESULT <> 0 ) THEN
        BEGIN
             CLRSCR;
             TEXTCOLOR ( WHITE );
             TEXTBACKGROUND ( BLACK );
             WRITELN ( CHR ( 07 ) );
             WRITELN ( 'Ошибка открытия демонстрационного файла' );
             HALT ( 1 )
        END;
     ControlDef := 2

END; { procedure SetEmulation }

{----------------------------------------------------------}

PROCEDURE CloseDef;

BEGIN
     IndBuf := 1;
     SizeBuf := 0;
     IF ( ControlDef IN [ 1, 2 ] ) THEN
        BEGIN
             CLOSE ( Fl );
             IF ( IORESULT <> 0 ) THEN
                BEGIN
                     CLRSCR;
                     TEXTCOLOR ( WHITE );
                     TEXTBACKGROUND ( BLACK );
                     WRITELN ( CHR ( 07 ) );
                     WRITELN ( 'Ошибка закрытия файла, модуль DEF' );
                     WRITELN;
                     CLOSE ( Fl );
                     HALT ( 1 )
                END
        END

END; { procedure CloseDef }

{----------------------------------------------------------}

PROCEDURE SetWait ( Wait : WORD );

BEGIN
     DefWait := Wait

END; { procedure SetWait }

{----------------------------------------------------------}

PROCEDURE MouseOff;

BEGIN
     SingMouse := FALSE

END; { procedure MouseOff }

{----------------------------------------------------------}

PROCEDURE MouseOn;

BEGIN
     rg.AX := $0001;
     INTR ( $33, rg );
     SingMouse := ( rg.AX <> 0 );
     Ch1 := #0;
     Ch2 := #0;
     SingCh1 := FALSE;
     SingCh2 := FALSE;
     Btl := FALSE;
     Btr := FALSE;
     IF ( SingMouse ) THEN
        BEGIN
             rg.AX := $0002;
             INTR ( $33, rg );
             rg.AX := $0004;
             rg.DX := 99;
             rg.CX := 319;
             INTR ( $33, rg )
        END

END; { procedure MouseOn }

{----------------------------------------------------------}

PROCEDURE SetPassword ( Ps : BYTE );

          { Установить пароль чтения текстовых файлов }
BEGIN
     PasswordText := Ps

END; { procedure SetPassword }

{----------------------------------------------------------}

BEGIN
     { HeapError := @HeapFunc; }
     Error := 0;
     HMess := '';
     ControlDef := 0;
     DefWait := 350;
     Help := '';
     rg.AX := $0001;
     INTR ( $33, rg );
     SingMouse := ( rg.AX <> 0 );
     Ch1 := #0;
     Ch2 := #0;
     SingCh1 := FALSE;
     SingCh2 := FALSE;
     Btl := FALSE;
     Btr := FALSE;
     IF ( SingMouse ) THEN
        BEGIN
             rg.AX := $0002;
             INTR ( $33, rg );
             rg.AX := $0004;
             rg.DX := 99;
             rg.CX := 319;
             INTR ( $33, rg )
        END;
     SetLeftButton  ( #$0D, #0 );
     SetRightButton ( #0, #82 );
     SetMouseLeft   ( #0, #77 );
     SetMouseRight  ( #0, #75 );
     SetMouseUp     ( #0, #72 );
     SetMouseDown   ( #0, #80 );
     PasswordText := 0;
     IndBuf := 1;
     SizeBuf := 0
END.
