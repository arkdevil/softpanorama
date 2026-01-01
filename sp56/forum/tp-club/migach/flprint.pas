
UNIT FLprint;


INTERFACE

USES Dos, Crt, Def, TWindow, FKey11, MnCmd, MnGroup, ViewT, Lptr, FONT_PM;

VAR
   TypeFont : RECORD
                    Epson : ARRAY [ 1..9 ] OF BYTE;
                    SingCondens : BOOLEAN;
                    SingJet : BOOLEAN;
                    JetFont : STRING [ 4 ];
                    SingRoman : BOOLEAN;
                    SingMachin : BOOLEAN;
                    MachineInterval : BYTE;
              END;

PROCEDURE DefaultFont;
PROCEDURE ReSetFonts;
PROCEDURE SetFont ( VAR KeyNotPrint : BOOLEAN );
PROCEDURE EndFont ( VAR KeyNotPrint : BOOLEAN );
PROCEDURE SetJetFont;
PROCEDURE DefWideFont;
PROCEDURE DefCondens;
PROCEDURE DefTypeFont;
PROCEDURE DefTypePrint;
PROCEDURE SetPrinter;
PROCEDURE DefRoman;
PROCEDURE FontMachine;

IMPLEMENTATION

{----------------------------------------------------------}

PROCEDURE DefaultFont;

          { Предопределенный шрифт }
VAR
   Index : BYTE;

BEGIN
     FOR Index := 1 TO 9 DO
         TypeFont.Epson [ Index ] := 0;
     TypeFont.SingCondens := FALSE;
     TypeFont.JetFont := '1015';
     TypeFont.SingMachin := FALSE;
     TypeFont.SingJet := FALSE

END; { procedure DefaultFont }

{----------------------------------------------------------}

PROCEDURE ReSetFonts;

          { Сброс всех установленных шрифтов }
BEGIN
     TypeFont.SingJet := FALSE;
     DefaultFont

END; { procedure ReSetFonts }

{----------------------------------------------------------}

PROCEDURE SetFont ( VAR KeyNotPrint : BOOLEAN );

VAR
   Index : BYTE;
   Sum : BYTE;
   HelpS : STRING [ 3 ];

BEGIN
     IF ( KeyNotPrint ) THEN
        EXIT;
     IF ( NOT TypeFont.SingJet ) THEN
        BEGIN
             IF ( TypeFont.SingMachin ) THEN
                BEGIN
                     List ( #27 + #$40, KeyNotPrint );
                     SetPMInterval ( TypeFont.MachineInterval )
                END
             ELSE
                 BEGIN
                      Sum := 0;
                      FOR Index := 1 TO 9 DO
                      BEGIN
                           Sum := Sum + TypeFont.Epson [ Index ]
                      END;
                      List ( #27 + #33 + CHR ( Sum ), KeyNotPrint );
                      IF ( TypeFont.SingCondens ) THEN
                         List ( #27 + #120 + #1, KeyNotPrint )
                      ELSE
                          List ( #27 + #120 + #0, KeyNotPrint );
                      IF ( TypeFont.SingRoman ) THEN
                         List ( #27 + #107 + #0, KeyNotPrint )
                      ELSE
                          List ( #27 + #107 + #1, KeyNotPrint )
                 END
        END
     ELSE
         List ( #27 + '(' + TypeFont.JetFont + 'X', KeyNotPrint )

END; { procedure SetFont }

{----------------------------------------------------------}

PROCEDURE EndFont ( VAR KeyNotPrint : BOOLEAN );

          { Установка шрифта в конце страницы }
BEGIN
     IF ( KeyNotPrint ) THEN
        EXIT;
     IF ( NOT TypeFont.SingJet ) THEN
        BEGIN
             IF ( NOT TypeFont.SingMachin ) THEN
                BEGIN
                     List ( #27 + #33 + #0, KeyNotPrint );
                     List ( #27 + #120 + #0, KeyNotPrint );
                     List ( #27 + #107 + #0, KeyNotPrint )
                END
        END
     ELSE
         List ( #27 + '(1015X', KeyNotPrint )

END; { procedure EndFont }

{----------------------------------------------------------}

PROCEDURE EnterParameter ( x, y, Ml : BYTE; VAR Ch : CHAR; VAR param : STRING ;
                           mess : STRING; Tp, ClF, ClC, ClF_C, ClC_C : BYTE );

          { Ввод параметра с заданным сообщением }
VAR
   SizeX : BYTE;
   SzL : BYTE;
   WindMsg : TextWindowPtr;

BEGIN
     SizeX := LENGTH ( Mess ) + 4;
     IF ( SizeX < 51 ) THEN
        SizeX := 51;
     IF ( ( SizeX + X ) > 79 ) THEN
        SizeX := 79 - X;
     IF ( Ml < ( SizeX - 8 ) ) THEN
        Szl := Ml
     ELSE
         Szl := SizeX - 8;
    NEW ( WindMsg, MakeWindow ( x, y, ( x + SizeX ), ( y + 4 ),
                                MAGENTA, WHITE ) );
    WindMsg^.WPrint ( 3, 2, mess );
    WindMsg^.WPrint ( 4, 3, CHR ( 16 ) );
    WindMsg^.FrameWindow ( 1, 1, SizeX, 4, 1, CHR(196) );
    WindMsg^.SetShade ( BLACK, BLACK );
    WindMsg^.PrintWindow;
    WindMsg^.SetTypeEdit ( Tp );
    WindMsg^.SetColorEdit ( ClF, ClC );
    WindMsg^.SetClearEdit;
    WindMsg^.SetColorClearEdit ( ClF_C, ClC_C );
    IF ( Param = 'Password' ) THEN
       BEGIN
            Param := '';
            WindMsg^.SetMaskEdit ( '*' )
       END;
    WindMsg^.XYEdit ( 6, 3, ch, Szl, param );
    DISPOSE ( WindMsg, TypeDone )

END; { procedure EnterParametr }

{----------------------------------------------------------}

PROCEDURE SetJetFont;

          { Установить шрифт для лазерного принтера }
VAR
   Line : StandartString;
   Ch : CHAR;
   Err : INTEGER;
   Num : WORD;

BEGIN
     Line := TypeFont.JetFont;
     REPEAT
           EnterParameter ( 34, 18, 4, Ch, Line,
                'Номер шрифта для лазерного принтера ', 1,
                LIGHTGRAY, BLUE, LIGHTGRAY, RED );
           IF ( Ch = #27 ) THEN
              EXIT;
           VAL ( Line, Num, Err );
           IF ( Err <> 0 ) THEN
              War ( 'Не числовое значение' )
           ELSE
               IF ( Num < 1000 ) THEN
                  War ( 'не менее 1000' );
               IF ( Num > 1020 ) THEN
                   War ( 'не более 1020' )
     UNTIL ( ( Err = 0 ) AND ( Num <= 1020 ) AND ( Num >= 1000 ) );
     TypeFont.JetFont := Line

END; { procedure SetJetFont }

{----------------------------------------------------------}

PROCEDURE DefTypeFont;

          { Определение типа шрифта }
VAR
   Command : BYTE;
   Line : StandartString;
   Ch : CHAR;
   Err : INTEGER;
   Num : WORD;
   Wn : TextWindowPtr;
   Menu : MenuCmdPtr;

BEGIN
    IF ( TypeFont.SingJet ) THEN
       BEGIN
            SetJetFont;
            EXIT
       END;
     TypeFont.Epson [ 1 ] := 0;
     IF ( TypeFont.Epson [ 2 ] = 0 ) THEN
        Command := 1
     ELSE
         Command := 2;
     NEW ( Wn, MakeWindow ( 35, 17, 66, 22, MAGENTA, WHITE ) );
     Wn^.WPrint ( 3, 2, '   Опрелелите тип шрифта  ' );
     Wn^.FrameWindow ( 1, 1, 31, 5, 1, CHR ( 205 ) );
     Wn^.SetShade ( BLACK, BLACK );
     Wn^.PrintWindow;
     NEW ( Menu, SetMenu ( 45, 20, 59, 24, BLUE, WHITE, LIGHTRED, WHITE,
                           BLACK, BLACK, #196, TRUE, 1, Command,
                           NulRunProcedure,
                 SetCmdC ( 3, 2, ' Норма   ',
                 SetCmdC ( 3, 3, ' Элит    ', NIL ) ) ) );
     Command := Menu^.StartMenu;
     DISPOSE ( Menu, Done );
     DISPOSE ( Wn, TypeDone );
     IF ( Command = 0 ) THEN
        EXIT;
     IF ( command = 1 ) THEN
        TypeFont.Epson [ 2 ] := 0
     ELSE
        TypeFont.Epson [ 2 ] := 1

END; { procedure DefTypeFont }

{----------------------------------------------------------}

PROCEDURE DefCondens;

          { Определение качественного режима }
VAR
   Command : BYTE;
   Line : StandartString;
   Ch : CHAR;
   Err : INTEGER;
   Num : WORD;
   Wn : TextWindowPtr;
   Menu : MenuCmdPtr;

BEGIN
    IF ( TypeFont.SingJet ) THEN
       BEGIN
            SetJetFont;
            EXIT
       END;
     TypeFont.Epson [ 1 ] := 0;
     IF ( NOT TypeFont.SingCondens ) THEN
        Command := 1
     ELSE
         Command := 2;
     NEW ( Wn, MakeWindow ( 35, 17, 66, 22, MAGENTA, WHITE ) );
     Wn^.WPrint ( 3, 2, '   Опрелелите стиль шрифта  ' );
     Wn^.FrameWindow ( 1, 1, 31, 5, 1, CHR ( 205 ) );
     Wn^.SetShade ( BLACK, BLACK );
     Wn^.PrintWindow;
     NEW ( Menu, SetMenu ( 45, 20, 59, 24, BLUE, WHITE, LIGHTRED, WHITE,
                           BLACK, BLACK, #196, TRUE, 1, Command,
                           NulRunProcedure,
                 SetCmdC ( 3, 2, ' Черновой',
                 SetCmdC ( 3, 3, ' Качество', NIL ) ) ) );
     Command := Menu^.StartMenu;
     DISPOSE ( Menu, Done );
     DISPOSE ( Wn, TypeDone );
     IF ( Command = 0 ) THEN
        EXIT;
     TypeFont.SingCondens := ( command = 2 )

END; { procedure DefCondens }

{----------------------------------------------------------}

PROCEDURE DefRoman;

          { Переопределение - Romn / Sanserif }
VAR
   Command : BYTE;
   Line : StandartString;
   Ch : CHAR;
   Err : INTEGER;
   Num : WORD;
   Wn : TextWindowPtr;
   Menu : MenuCmdPtr;

BEGIN
    IF ( TypeFont.SingJet ) THEN
       BEGIN
            SetJetFont;
            EXIT
       END;
     TypeFont.Epson [ 1 ] := 0;
     IF ( TypeFont.SingRoman ) THEN
        Command := 1
     ELSE
         Command := 2;
     NEW ( Wn, MakeWindow ( 35, 17, 66, 22, MAGENTA, WHITE ) );
     Wn^.WPrint ( 3, 2, '   Опрелелите качественный ' );
     Wn^.WPrint ( 3, 3, '          шрифт' );
     Wn^.FrameWindow ( 1, 1, 31, 5, 1, CHR ( 205 ) );
     Wn^.SetShade ( BLACK, BLACK );
     Wn^.PrintWindow;
     NEW ( Menu, SetMenu ( 45, 20, 59, 24, BLUE, WHITE, LIGHTRED, WHITE,
                           BLACK, BLACK, #196, TRUE, 1, Command,
                           NulRunProcedure,
                 SetCmdC ( 3, 2, ' Роман ',
                 SetCmdC ( 3, 3, ' Сансериф ', NIL ) ) ) );
     Command := Menu^.StartMenu;
     DISPOSE ( Menu, Done );
     DISPOSE ( Wn, TypeDone );
     IF ( Command = 0 ) THEN
        EXIT;
     TypeFont.SingRoman := ( Command = 1 )

END; { PROCEDURE DefRomam }

{----------------------------------------------------------}

PROCEDURE DefWideFont;

          { Определение ширины шрифта }
VAR
   Command : BYTE;
   Line : StandartString;
   Ch : CHAR;
   Err : INTEGER;
   Num : WORD;
   Wn : TextWindowPtr;
   Menu : MenuCmdPtr;

BEGIN
    IF ( TypeFont.SingJet ) THEN
       BEGIN
            SetJetFont;
            EXIT
       END;
     IF ( ( TypeFont.Epson [ 3 ] = 0 ) AND ( TypeFont.Epson [ 4 ] = 0 ) ) THEN
        Command := 1
     ELSE
         IF ( TypeFont.Epson [ 3 ] = 2 ) THEN
            Command := 2
         ELSE
             Command := 3;
     NEW ( Wn, MakeWindow ( 35, 17, 66, 22, MAGENTA, WHITE ) );
     Wn^.WPrint ( 3, 2, '   Опрелелите ширину шрифта' );
     Wn^.FrameWindow ( 1, 1, 31, 5, 1, CHR ( 205 ) );
     Wn^.SetShade ( BLACK, BLACK );
     Wn^.PrintWindow;
     NEW ( Menu, SetMenu ( 45, 19, 59, 24, BLUE, WHITE, LIGHTRED, WHITE,
                           BLACK, BLACK, #196, TRUE, 1, Command,
                           NulRunProcedure,
                 SetCmdC ( 3, 2, ' Норма    ',
                 SetCmdC ( 3, 3, ' Пропорц  ',
                 SetCmdC ( 3, 4, ' Уплотнен ', NIL ) ) ) ) );
     Command := Menu^.StartMenu;
     DISPOSE ( Menu, Done );
     DISPOSE ( Wn, TypeDone );
     IF ( Command = 0 ) THEN
        EXIT;
     TypeFont.Epson [ 3 ] := 0;
     TypeFont.Epson [ 4 ] := 0;
     IF ( Command = 1 ) THEN
        EXIT;
     IF ( command = 2 ) THEN
        TypeFont.Epson [ 3 ] := 2
     ELSE
        TypeFont.Epson [ 4 ] := 4

END; { procedure DefWideFont }

{----------------------------------------------------------}

PROCEDURE Codens ( VAR Cod : BYTE );

          { Выделенный шрифт }
BEGIN
     TypeFont.Epson [ 5 ] := ( NOT TypeFont.Epson [ 5 ] ) AND 8;
     IF ( TypeFont.Epson [ 5 ] = 0 ) THEN
        Cod := 2
     ELSE
         Cod := 1

END; { procedure Codens }

{----------------------------------------------------------}

PROCEDURE Duble ( VAR Cod : BYTE );

          { Двойной шрифт }
BEGIN
     TypeFont.Epson [ 6 ] := ( NOT TypeFont.Epson [ 6 ] ) AND 16;
     IF ( TypeFont.Epson [ 6 ] = 0 ) THEN
        Cod := 2
     ELSE
         Cod := 1

END; { procedure Duble }

{----------------------------------------------------------}

PROCEDURE Widely ( VAR Cod : BYTE );

          { Широкий шрифт }
BEGIN
     TypeFont.Epson [ 7 ] := ( NOT TypeFont.Epson [ 7 ] ) AND 32;
     IF ( TypeFont.Epson [ 7 ] = 0 ) THEN
        Cod := 2
     ELSE
         Cod := 1

END; { procedure Widely }

{----------------------------------------------------------}

PROCEDURE Curs ( VAR Cod : BYTE );

          { Курсив }
BEGIN
     TypeFont.Epson [ 8 ] := ( NOT TypeFont.Epson [ 8 ] ) AND 64;
     IF ( TypeFont.Epson [ 8 ] = 0 ) THEN
        Cod := 2
     ELSE
         Cod := 1

END; { procedure Curs }

{----------------------------------------------------------}

PROCEDURE Inst ( VAR Cod : BYTE );

          { Подчерк }
BEGIN
     TypeFont.Epson [ 9 ] := ( NOT TypeFont.Epson [ 9 ] ) AND 128;
     IF ( TypeFont.Epson [ 9 ] = 0 ) THEN
        Cod := 2
     ELSE
         Cod := 1

END; { procedure Inst }

{----------------------------------------------------------}

PROCEDURE Rst ( VAR Cod : BYTE );

         { Сброс типa печати }
VAR
   Index : BYTE;

BEGIN
     FOR Index := 5 TO 9 DO
         TypeFont.Epson [ Index ] := 0;
     Cod := 2

END; { procedure Rst }

{----------------------------------------------------------}

PROCEDURE DefTypePrint;

          { Определение типа печати }
VAR
   Command : BYTE;
   Line : StandartString;
   Ch : CHAR;
   Err : INTEGER;
   Num : WORD;
   Wn : TextWindowPtr;
   Menu : MenuGroupPtr;

BEGIN
    IF ( TypeFont.SingJet ) THEN
       BEGIN
            SetJetFont;
            EXIT
       END;
     NEW ( Wn, MakeWindow ( 35, 17, 66, 22, MAGENTA, WHITE ) );
     Wn^.WPrint ( 3, 2, '   Опрелелите ширину шрифта' );
     Wn^.FrameWindow ( 1, 1, 31, 5, 1, CHR ( 205 ) );
     Wn^.SetShade ( BLACK, BLACK );
     Wn^.PrintWindow;
     NEW ( Menu, SetMenu ( 40, 19, 68, 24, BLACK, LIGHTGREEN, CYAN, BLUE,
                           BLACK, BLACK, #196, TRUE, LIGHTRED,
                           NulRunProcedure,
           SetCmdG ( 3, 2, 'Выделенный', ( TypeFont.Epson [ 5 ] <> 0 ), @Codens,
           SetCmdG ( 3, 3, 'Двуударный', ( TypeFont.Epson [ 6 ] <> 0 ), @Duble,
           SetCmdG ( 3, 4, '2 * ширина', ( TypeFont.Epson [ 7 ] <> 0 ), @Widely,
           SetCmdG ( 16,2, ' Курсив   ', ( TypeFont.Epson [ 8 ] <> 0 ), @Curs,
           SetCmdG ( 16,3, ' Подчерк  ', ( TypeFont.Epson [ 9 ] <> 0 ), @Inst,
           SetCmdG ( 16,4, ' Сброс    ', FALSE, @Rst,
     NIL ) ) ) ) ) ) ) );
     REPEAT
           Ch := Menu^.StartMenu;
     UNTIL ( Ch = #27 );
     DISPOSE ( Menu, Done );
     DISPOSE ( Wn, TypeDone );

END; { procedure DefTypePrint }

{----------------------------------------------------------}

PROCEDURE SetMachineInterval;

          { Установить интервал для печатающей машинки }
VAR
   Wn : TextWindowPtr;
   Index : BYTE;
   Interval : BYTE;
   Ch : CHAR;

PROCEDURE ShowInt ( Num : BYTE );

VAR
   Hlp : BYTE;

BEGIN
     Wn^.SetColorFon ( LIGHTGRAY );
     Wn^.SetColorSymbol ( RED );
     Num := ( Num DIV 4 ) + 1;
     FOR  Hlp := 3 TO Num + 2 DO
          Wn^.XYPrint ( Hlp, 3, #177 );
     FOR Hlp := Num + 2 TO 38 DO
          Wn^.XYPrint ( Hlp, 3, ' ' )

END; { PROCEDURE ShowInt }

BEGIN
     NEW ( Wn, MakeWindow ( 40, 19, 80, 25, GREEN, WHITE ) );
     Wn^.SetShade ( BLACK, BLACK );
     Wn^.FrameWindow ( 1, 1, 40, 6, 1, #205 );
     Wn^.WPrint ( 2, 2, '   Установите интервал между строками' );
     Wn^.SetColorSymbol ( BLUE );
     Wn^.WPrint ( 2 + ( $34 DIV 4 ), 4, '|' );
     Wn^.SetColorSymbol ( WHITE );
     Wn^.WPrint ( 4 + ( $34 DIV 4 ), 4,  '<  '+ #25 + ', ' + #27 +
                 ', Enter, ESC >' );
     Wn^.WPrint ( 6, 5, 'Двойной интервал' );
     Wn^.PrintWindow;
     Interval := TypeFont.MachineInterval;
     REPEAT
           ShowInt ( Interval );
           Ch := GetKey;
           IF ( ( Ch = #0 ) AND ( SingKey ) ) THEN
              BEGIN
                   Ch := GetKey;
                   CASE Ch OF
                        Arrow_Right : IF ( Interval < $80 ) THEN
                                         INC ( Interval, 4 );
                        Arrow_Left  : IF ( Interval > 12 ) THEN
                                         DEC ( Interval, 4 )
                   END
              END
     UNTIL ( ( Ch = #27 ) OR ( Ch = #$0D ) );
     IF ( Ch = #$0D ) THEN
        BEGIN
             SetPMInterval ( Interval );
             TypeFont.MachineInterval := Interval
        END;
     DISPOSE ( Wn, TypeDone )

END; { PROCEDURE SetMachineInterval }

{----------------------------------------------------------}

PROCEDURE FontMachine;

          { Переключение шрифта печатающей машинки }
VAR
   Line : StandartString;
   Ch : CHAR;
   Err : INTEGER;
   Num : WORD;
   Command : BYTE;
   Wn : TextWindowPtr;
   Menu : MenuCmdPtr;

BEGIN
    IF ( NOT TypeFont.SingMachin ) THEN
       command := 1
    ELSE
        command := 2;
    NEW ( Wn, MakeWindow ( 45, 15, 76, 20, MAGENTA, WHITE ) );
    Wn^.WPrint ( 3, 2, 'Укажите признак печати шрифтом' );
    Wn^.WPrint ( 3, 3, '    печатающей машинки' );
    Wn^.FrameWindow ( 1,1,31,5,1,CHR(205));
    Wn^.SetShade ( BLACK, BLACK );
    Wn^.PrintWindow;
     NEW ( Menu, SetMenu ( 53, 18, 70, 22, BLUE, WHITE, LIGHTRED, WHITE,
                           BLACK, BLACK, #196, TRUE, 1, Command,
                           NulRunProcedure,
                 SetCmdC ( 3, 2, '    Обычный   ',
                 SetCmdC ( 3, 3, ' Машинописный ', NIL ) ) ) );
     Command := Menu^.StartMenu;
     DISPOSE ( Menu, Done );
     DISPOSE ( Wn, TypeDone );
     IF ( Command = 0 ) THEN
        EXIT;
    IF ( command = 1 ) THEN
       TypeFont.SingMachin := FALSE
    ELSE
        BEGIN
             TypeFont.SingMachin := TRUE;
             SetMachineInterval
        END;

END; { PROCEDURE FontMachine }

{----------------------------------------------------------}

PROCEDURE SetPrinter;

         { Принтер }
VAR
   Line : StandartString;
   Ch : CHAR;
   Err : INTEGER;
   Num : WORD;
   Command : BYTE;
   Wn : TextWindowPtr;
   Menu : MenuCmdPtr;

BEGIN
    IF ( TypeFont.SingJet ) THEN
       command := 1
    ELSE
        command := 2;
    NEW ( Wn, MakeWindow ( 45, 15, 76, 20, MAGENTA, WHITE ) );
    Wn^.WPrint ( 3, 2, 'Укажите тип подключенного' );
    Wn^.WPrint ( 3, 3, ' печатающего устройства' );
    Wn^.FrameWindow ( 1,1,31,5,1,CHR(205));
    Wn^.SetShade ( BLACK, BLACK );
    Wn^.PrintWindow;
     NEW ( Menu, SetMenu ( 53, 18, 70, 22, BLUE, WHITE, LIGHTRED, WHITE,
                           BLACK, BLACK, #196, TRUE, 1, Command,
                           NulRunProcedure,
                 SetCmdC ( 3, 2, 'LaserJet II',
                 SetCmdC ( 3, 3, '   IBM     ', NIL ) ) ) );
     Command := Menu^.StartMenu;
     DISPOSE ( Menu, Done );
     DISPOSE ( Wn, TypeDone );
     IF ( Command = 0 ) THEN
        EXIT;
    IF ( command = 1 ) THEN
       TypeFont.SingJet := TRUE
    ELSE
        TypeFont.SingJet := FALSE;
    IF ( TypeFont.SingJet ) THEN
       BEGIN
            NEW ( Wn, MakeWindow ( 10, 10, 70, 23, LIGHTGRAY, BLACK ) );
            Wn^.SetShade ( BLACK, BLACK );
            Wn^.FrameWindow ( 1, 1, 60, 13, 1, #205 );
            Wn^.WPrint ( 4, 3, '  Для поставки украинских шрифтов к ' );
            Wn^.WPrint ( 4, 4, ' лазерному принтеру Laser Jet II ( III )' );
            Wn^.WPrint ( 4, 5, '' );
            Wn^.SetColorSymbol ( BLUE );
            Wn^.WPrint ( 4, 6, '       Обращайтесь в I P M  Group' );
            Wn^.WPrint ( 4, 7, '' );
            Wn^.WPrint ( 4, 8, '        тел : 518-48-47  г. Киев' );
            Wn^.WPrint ( 4, 9, '' );
            Wn^.SetColorSymbol ( RED );
            Wn^.WPrint ( 4, 10, '         Нажмите любую клавишу' );
            Wn^.PrintWindow;
            AnyKey;
            DISPOSE ( Wn, TypeDone );
       END

END; { procedure SetPrinter }

{----------------------------------------------------------}

END.
