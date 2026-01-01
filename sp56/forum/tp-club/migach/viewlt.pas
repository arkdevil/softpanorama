

         {----------------------------------------------------}
         {     Модуль ViewLT  V 1.1 пакета  TURBO SUPPORT     }
         {     Язык программирования Turbo Pascal  V 6.0      }
         {----------------------------------------------------}
         { Дата последних изменений :  30/12/1991             }
         {----------------------------------------------------}
         { Модуль предназначен для обработки текстовых потоков}
         {          для просмотра и отметки срок текста       }
         {----------------------------------------------------}
         { (c) 1991, Мигач Ярослав                            }
         {----------------------------------------------------}

UNIT ViewLT;

{$IFDEF DEBUGVIEW}
      {$D+,L+,R+,S+}
{$ELSE}
      {$D-,L-,R-,S-}
{$ENDIF}

{$F+,O+,I-,V-,B-,A+}

INTERFACE

USES Crt, Dos, Fkey11, Def, TWindow, LcText, ViewT;

CONST
     MaxNumberInsertLines = $4000;
        { Максималиное рассматриваемое в обьекте количество строк }

TYPE
    ViewLineTextPtr = ^ViewLineText;
                   { Указатель на обьект строкового меню }

    ViewLineText = OBJECT  ( ViewText )
                { обьект позволяющий отмечать строки текстовой
                  подсказки как элементы меню                  }

                ControlLine : ARRAY [ 1 .. MaxNumberInsertLines ] OF BYTE;
                              { информация о строках текста }

                ColorText : BYTE;
                              { цвет текста }

                ColorFon : BYTE;
                              { цвет основного фона }

                ColorHelp : BYTE;
                              { цвет фона подсказки }

                ColorSymHelp : BYTE;
                              { Цвет символов строки подсказки }

                ColorInsert : BYTE;
                              { цвет выделенной строки }

                NumberHelpLine : LONGINT;
                               { номер вспомогательной строки }

                CONSTRUCTOR Init ( WindPtr : TextWindowPtr;
                                   Stream : POINTER );
                          { инициализация обьекта }

                PROCEDURE SetColorText ( Cl : BYTE ); VIRTUAL;
                          { установить цвет текста в окне }

                PROCEDURE SetColorFon ( Cl : BYTE ); VIRTUAL;
                          { установить цвет фона в окне }

                PROCEDURE SetColorHelp ( Cl : BYTE ); VIRTUAL;
                          { установить цвет фона активной стороки }

                PROCEDURE SetSymbolHelp ( Cl : BYTE );
                          { Установить цветсимволов активной строки }

                PROCEDURE SetColorInsert ( Cl : BYTE ); VIRTUAL;
                          { установит цвет символов выделенной стороки }

                PROCEDURE Show_Inf; VIRTUAL;
                          {  показать текущее состояние информации в }
                          {           активизированном окне          }

                PROCEDURE Control_Inf ( VAR ext_byte : LONGINT ); VIRTUAL;
                          { процедура управления информацией в }
                          {        активизированном окне       }

                PROCEDURE SetLineNumber ( Num : LONGINT );
                          { Установит активную строку по заданному номеру }

                FUNCTION TestLine ( num : LONGINT ) : BYTE; VIRTUAL;
                         { проверка заданной строки на наличие }
                         {            флага отметки            }

                PROCEDURE line_down; VIRTUAL;  { группа процедур       }
                PROCEDURE line_up;   VIRTUAL;  { управления текстовой }
                PROCEDURE window_down; VIRTUAL;{ информацией в окне    }
                PROCEDURE window_up;  VIRTUAL;
                PROCEDURE Insert;     VIRTUAL;
                PROCEDURE TextEnd;    VIRTUAL;
                PROCEDURE TextHome;   VIRTUAL;

                DESTRUCTOR Done;
                         { деинициализация обьекта }

                DESTRUCTOR DoneWithStream;
                         { деинициализация обьекта вммместе с потоком }

                END; { object ViewLineText }

    ViewLineNumberText = OBJECT  ( ViewLineText )
                { обьект позволяющий отмечать строки текстовой
                  подсказки как элементы меню  по номерам          }

                LastNumber : BYTE;

                CONSTRUCTOR Init ( WindPtr : TextWindowPtr;
                                   Stream : POINTER );
                          { инициализация обьекта }

                PROCEDURE Show_Inf; VIRTUAL;
                          {  показать текущее состояние информации в }
                          {           активизированном окне          }

                PROCEDURE Insert;     VIRTUAL;

                END; { object ViewLineNumberText }

IMPLEMENTATION

{----------------------------------------------------------}

PROCEDURE FatalError ( Line : STRING );

BEGIN
     WINDOW ( 1, 1, 80, 25 );
     TEXTBACKGROUND ( BLACK );
     TEXTCOLOR ( LIGHTGRAY );
     CLRSCR;
     WRITELN ( #07 );
     WRITELN ( 'Критический сбой в обьекте ViewLineText' );
     WRITELN ( Line );
     WRITELN ( 'Выполнение программы прекращается,'
              ,' обращайтесь к программисту' );
     HALT ( 1 )

END; { procedure FatalError }

{----------------------------------------------------------}

PROCEDURE ViewLineText.line_down;

BEGIN
     IF ( NumberHelpLine >= end_number ) THEN
        NumberHelpLine := End_Number
     ELSE
         INC ( NumberHelpLine );
     IF ( ( ( end_number - number + 1 ) > size_y ) AND
          ( NumberHelpLine > ( number + size_y - 1 ) ) ) THEN
        INC ( number )

END; { procedure ViewLineText.line_down }

{----------------------------------------------------------}

PROCEDURE ViewLineText.line_up;

BEGIN
     IF ( NumberHelpLine <= 1 ) THEN
        BEGIN
             NumberHelpLine := 1;
             number := 1;
             EXIT
        END;
     DEC ( NumberHelpLine );
     IF ( ( number > 1 ) AND ( NumberHelpLine < number ) ) THEN
        DEC ( number )

END; { procedure ViewLineText.line_up }

{----------------------------------------------------------}

PROCEDURE ViewLineText.SetLineNumber ( Num : LONGINT );

          { Установит активную строку по заданному номеру }
VAR
   Quantity : LONGINT;
   Index : LONGINT;

BEGIN
     IF ( ( Num = NumberHelpLine ) OR ( Num < 1 ) OR
          ( Num > TextStream^.GetSize ) ) THEN
        EXIT;
     Quantity := ABS ( Num - NumberHelpLine );
     IF ( Num > NumberHelpLine ) THEN
        FOR Index := 1 TO Quantity DO
            line_down
     ELSE
         FOR Index := 1 TO Quantity DO
             line_up

END; { procedure ViewLineText.SetLineNumber }

{----------------------------------------------------------}

PROCEDURE ViewLineText.window_up;

BEGIN
     NumberHelpLine := NumberHelpLine - size_y;
     IF ( NumberHelpLine < 1 ) THEN
        NumberHelpLine := 1;
     number := number - size_y;
     IF ( number < 1 ) THEN
        number := 1;
     IF ( NumberHelpLine < number ) THEN
        NumberHelpLine := number;
     IF ( NumberHelpLine > ( number + size_y - 1 ) ) THEN
        NumberHelpLine := number + size_y - 1

END; { procedure ViewLineText.window_up }

{----------------------------------------------------------}

PROCEDURE ViewLineText.TextHome;

BEGIN
     number := 1;
     NumberHelpLine := 1

END; { procedure ViewLineText.TextHome }

{----------------------------------------------------------}

PROCEDURE ViewLineText.TextEnd;

BEGIN
     number := End_Number - size_y + 1;
     NumberHelpLine := End_Number

END; { procedure ViewLineText.TextEnd }

{----------------------------------------------------------}

PROCEDURE ViewLineText.window_down;

BEGIN
     ClearListRecLine ( LinesList );
     LinesList := NIL;
     NumberHelpLine := NumberHelpLine + size_y;
     IF ( NumberHelpLine > end_number ) THEN
        BEGIN
             TextEnd;
             EXIT
        END;
     number := number + size_y;
     IF ( number > ( end_number - size_y + 1 ) ) THEN
        number := end_number - size_y + 1

END; { procedure ViewLineText.wind_down }

{----------------------------------------------------------}

PROCEDURE ViewLineText.Insert;

BEGIN
     IF ( NumberHelpLine > MaxNumberInsertLines ) THEN
        EXIT;
     IF ( ControlLine [ NumberHelpLine ] = 0 ) THEN
         ControlLine [ NumberHelpLine ] := 1
     ELSE
         ControlLine [ NumberHelpLine ] := 0

END; { procedure ViewLineText.Insert }

{----------------------------------------------------------}

CONSTRUCTOR ViewLineText.Init ( WindPtr :TextWindowPtr; Stream : POINTER );

           { инициализация обьекта }
VAR
   indx : WORD;

BEGIN
     ViewText.Init ( WindPtr, Stream );
     FOR indx := 1 TO MaxNumberInsertLines DO
         ControlLine [ indx ] := 0;
     SetColorText ( BLUE );
     SetColorFon ( CYAN );
     SetColorHelp ( RED );
     SetColorInsert ( YELLOW );
     NumberHelpLine := 1;
     SingAlt := FALSE

END;  { constructor ViewLineText.Init }

{----------------------------------------------------------}

PROCEDURE ViewLineText.SetColorText ( Cl : BYTE );

          { установить цвет текста в окне }
BEGIN
     ColorText := Cl;
     ColorSymHelp := Cl

END;  { procedure ViewLineText.SetColorText }

{----------------------------------------------------------}

PROCEDURE ViewLineText.SetColorFon ( Cl : BYTE );

          { установить цвет фона в окне }
BEGIN
     ColorFon := Cl

END;  { procedure ViewLineText.SetColorFon }

{----------------------------------------------------------}

PROCEDURE ViewLineText.SetSymbolHelp ( Cl : BYTE );

          { Установить цветсимволов активной строки }
BEGIN
     ColorSymHelp := Cl

END; { procedure ViewLineText.SetSymbolHelp }

{----------------------------------------------------------}

PROCEDURE ViewLineText.SetColorHelp ( Cl : BYTE );

          { установить цвет фона активной стороки }
BEGIN
     ColorHelp := Cl

END;  { procedure ViewLineText.SetColorHelp }

{----------------------------------------------------------}

PROCEDURE ViewLineText.SetColorInsert ( Cl : BYTE );

          { установит цвет символов выделенной стороки }
BEGIN
     ColorInsert := Cl

END;  { procedure ViewLineText.SetColorInsert }

{----------------------------------------------------------}

PROCEDURE ViewLineText.show_inf;

          { показать на экране текущее состояние просмотра }
          {           в активизированном окне              }
VAR
   x, y : BYTE;
   HelpList : RecLinePtr;
   Index : LONGINT;
   indx : INTEGER;
   stroka : String;
   Help : STRING;
   IndexX, EndX : WORD;

BEGIN
     IF ( Number < 1 ) THEN
        FatalError ( 'Входной номер < 1  в  Show_Inf' );

        { Корректировка координаты смещения }

     IF ( key_ramka ) THEN
        x := 1
     ELSE
         x := 0;

       { Замена информации в промежуточном списке LinesList }

     SwapInformation;
     IF ( CodError <> 0 ) THEN
        EXIT;

       { Формирование строки - очистки }

     stroka := '';
     FOR indx := 1 TO size_x DO
         stroka := CONCAT ( stroka, ' ' );

       { Формирование изображения в памяти }

     FOR indx := 1 TO size_y DO
         BEGIN
              IF ( ( indx + number - 1 ) <= MaxNumberInsertLines ) THEN
                 BEGIN
                      IF ( ( indx + number - 1 ) = NumberHelpLine ) THEN
                         BEGIN
                              WindowPtr^.SetColorSymbol ( ColorSymHelp );
                              WindowPtr^.SetColorFon ( ColorHelp )
                         END
                      ELSE
                          BEGIN
                               WindowPtr^.SetColorFon ( ColorFon );
                               IF ( ControlLine [ indx + number - 1 ]
                                    <> 0 ) THEN
                                  WindowPtr^.SetColorSymbol ( ColorInsert )
                               ELSE
                                   WindowPtr^.SetColorSymbol ( ColorText )
                          END
                 END;
              WindowPtr^.WPrint ( LO ( ( x + 1 ) ), LO ( ( indx + x ) ), stroka );
              HelpList := FindLine ( Indx, LinesList );
              IF ( HelpList <> NIL ) THEN
                 Help := HelpList^.Line
              ELSE
                  Help := '';
              EndX := PointBeginX + Size_X - 1;
              IF ( EndX > LENGTH ( Help ) ) THEN
                 EndX := LENGTH ( Help );
              IF ( ( indx + number - 1 ) <= end_number ) THEN
                  FOR IndexX := PointBeginX TO EndX DO
                      WindowPtr^.WChar ( LO ( ( X + IndexX - PointBeginX + 1) ),
                           LO ( ( indx + x ) ), Help [ IndexX ] );
         END;
     WindowPtr^.PrintWindow;
     WindowPtr^.SetColorFon ( ColorFon );
     WindowPtr^.SetColorSymbol ( ColorText )

END; { procedure ViewLineText.show_inf }

{----------------------------------------------------------}

PROCEDURE ViewLineText.Control_Inf ( VAR ext_byte : LONGINT );

         { процедура управления информацией в }
         {        активизированном окне       }
VAR
   indx : WORD;
   OldSize : LONGINT;

BEGIN
     Ext_Byte := 0;
     IF ( CodError <> 0 ) THEN
        EXIT;
     FOR indx := 1 TO MaxNumberInsertLines DO
         ControlLine [ indx ] := 0;
     REPEAT
           show_inf;
           IF ( CodError <> 0 ) THEN
              EXIT;
           ch := GetKeyBoard;
           IF ( GetSingKey ) THEN
              BEGIN
                   ch := GetKeyBoard;
                   CASE ch OF
                        arrow_down : line_down;
                        arrow_up   : line_up;
                        arrow_Left : CharLeft;
                        arrow_Right: CharRight;
                        page_down  : window_down;
                        page_up    : window_up;
                        key_ins    : Insert;
                        key_end    : TextEnd;
                        key_home   : TextHome
                   ELSE
                       BEGIN
                            OldSize := TextStream^.GetSize;
                            run_for_key ( ch );
                            IF ( OldSize <> TextStream^.GetSize ) THEN
                               BEGIN
                                    end_number := TextStream^.GetSize;
                                    ClearListRecLine ( LinesList );
                                    LinesList := NIL
                               END
                       END
                   END
              END
     UNTIL ( ( ch IN [ #27, #$0D ] ) OR ( ( Ch = #0 ) AND ( SingAlt ) ) );
     IF ( ch <> #27 ) THEN
         ext_byte := NumberHelpLine
     ELSE
         ext_byte := 0

END; { procedure ViewLineText.Control_Inf }

{----------------------------------------------------------}

FUNCTION ViewLineText.TestLine ( num : LONGINT ) : BYTE;

         { проверка заданной строки на наличие }
         {            флага отметки            }
BEGIN
     IF ( ( num < 1 ) OR ( num > MaxNumberInsertLines ) OR ( Num > End_number) ) THEN
        BEGIN
             TestLine := 0;
             EXIT
        END;
     TestLine := ControlLine [ num ]

END; { function ViewLineText.TestLine }

{----------------------------------------------------------}

DESTRUCTOR ViewLineText.Done;

           { деинициализация обьекта }
BEGIN
     ViewText.Done

END; { dectructor ViewLineText.Done }

{----------------------------------------------------------}

DESTRUCTOR ViewLineText.DoneWithStream;

           { деинициализация обьекта вместе с потоком }
BEGIN
     ViewText.DoneWithStream

END; { dectructor ViewLineText.DoneWithStream }

{----------------------------------------------------------}

CONSTRUCTOR ViewLineNumberText.Init ( WindPtr : TextWindowPtr;
                                      Stream : POINTER );

           { инициализация обьекта }
VAR
   indx : WORD;

BEGIN
     ViewLineText.Init ( WindPtr, Stream );
     LastNumber := 0

END;  { constructor ViewLineNumberText.Init }

{----------------------------------------------------------}

PROCEDURE ViewLineNumberText.show_inf;

          { показать на экране текущее состояние просмотра }
          {           в активизированном окне              }
VAR
   x, y : BYTE;
   HelpList : RecLinePtr;
   Index : LONGINT;
   indx : INTEGER;
   stroka : String;
   Help, Line : STRING;
   IndexX, EndX : WORD;

BEGIN
     IF ( Number < 1 ) THEN
        FatalError ( 'Входной номер < 1  в  Show_Inf' );

        { Корректировка координаты смещения }

     IF ( key_ramka ) THEN
        x := 1
     ELSE
         x := 0;

       { Замена информации в промежуточном списке LinesList }

     SwapInformation;
     IF ( CodError <> 0 ) THEN
        EXIT;

       { Формирование строки - очистки }

     stroka := '';
     FOR indx := 1 TO size_x DO
         stroka := CONCAT ( stroka, ' ' );

       { Формирование изображения в памяти }

     FOR indx := 1 TO size_y DO
         BEGIN
              IF ( ( indx + number - 1 ) <= MaxNumberInsertLines ) THEN
                 BEGIN
                      IF ( ( indx + number - 1 ) = NumberHelpLine ) THEN
                         BEGIN
                              WindowPtr^.SetColorSymbol ( ColorSymHelp );
                              WindowPtr^.SetColorFon ( ColorHelp )
                         END
                      ELSE
                          BEGIN
                               WindowPtr^.SetColorFon ( ColorFon );
                               IF ( ControlLine [ indx + number - 1 ]
                                    <> 0 ) THEN
                                  WindowPtr^.SetColorSymbol ( ColorInsert )
                               ELSE
                                   WindowPtr^.SetColorSymbol ( ColorText )
                          END
                 END;
              IF ( ( indx + number - 1 ) <= MaxNumberInsertLines ) THEN
                 BEGIN
                      IF ( ControlLine [ indx + number - 1 ] <> 0 ) THEN
                         BEGIN
                              STR ( ControlLine [ indx + number - 1], Line );
                              WHILE ( LENGTH ( Line ) < 3 ) DO
                                    Line := Line + ' ';
                              Line := Line + ' - '
                         END
                      ELSE
                          Line := '      '
                 END;
              WindowPtr^.WPrint ( LO ( ( x + 1 ) ), LO ( ( indx + x ) ), stroka );
              HelpList := FindLine ( Indx, LinesList );
              IF ( HelpList <> NIL ) THEN
                 Help := HelpList^.Line
              ELSE
                  Help := '';
              Help := Line + Help;
              EndX := PointBeginX + Size_X - 1;
              IF ( EndX > LENGTH ( Help ) ) THEN
                 EndX := LENGTH ( Help );
              IF ( ( indx + number - 1 ) <= end_number ) THEN
                  FOR IndexX := PointBeginX TO EndX DO
                      WindowPtr^.WChar ( LO ( ( X + IndexX - PointBeginX + 1) ),
                           LO ( ( indx + x ) ), Help [ IndexX ] );
         END;
     WindowPtr^.PrintWindow;
     WindowPtr^.SetColorFon ( ColorFon );
     WindowPtr^.SetColorSymbol ( ColorText )

END; { procedure ViewLineNumberText.show_inf }

{----------------------------------------------------------}

PROCEDURE ViewLineNumberText.Insert;

BEGIN
     IF ( NumberHelpLine > MaxNumberInsertLines ) THEN
        EXIT;
     IF ( ControlLine [ NumberHelpLine ] = 0 ) THEN
         BEGIN
              INC ( LastNumber );
              ControlLine [ NumberHelpLine ] := LastNumber
         END
     ELSE
         IF ( ControlLine [ NumberHelpLine ] = LastNumber ) THEN
            BEGIN
                 ControlLine [ NumberHelpLine ] := 0;
                 DEC ( LastNumber )
            END;
     show_inf

END; { procedure ViewLineNumberText.Insert }

{----------------------------------------------------------}

END.
