

         {----------------------------------------------------}
         {     Модуль ViewLT  V 1.0 пакета  TURBO SUPPORT     }
         {     Язык программирования Turbo Pascal  V 6.0      }
         {----------------------------------------------------}
         { Дата последних изменений :  09/08/1991             }
         {----------------------------------------------------}
         { Модуль предназначен для обработки текстовых потоков}
         {    для просмотра и отметки блоков срок текста      }
         {----------------------------------------------------}
         { (c) 1991, Мигач Ярослав                            }
         {----------------------------------------------------}

UNIT ViewBT;

{$IFDEF DEBUGVIEW}
      {$D+,L+,R+,S+}
{$ELSE}
      {$D-,L-,R-,S-}
{$ENDIF}

{$F+,O+,I-,V-,B-,A+}

INTERFACE

USES Crt, Dos, Fkey11, Def, TWindow, LcText, ViewT;

CONST
     MaxBlk = 1000;

TYPE
    ViewBlockText = OBJECT  ( ViewText )
                { обьект позволяющий отмечать блоки строк текстовой
                  подсказки как элементы меню                  }

                BeginBlock : ARRAY [ 1..MaxBlk ] OF LONGINT;
                           { Номера строк начала соответствующих }
                           {          текстовых блоков           }

                EndBlock : ARRAY [ 1..MaxBlk ] OF LONGINT;
                           { Номера строк конца соответствующих }
                           {          текстовых блоков           }

                ControlBlock : ARRAY [ 1..MaxBlk ] OF BYTE;
                           { Признаки отмеченных блоков }

                ColorText : BYTE;
                              { цвет текста }

                ColorFon : BYTE;
                              { цвет основного фона }

                ColorHelp : BYTE;
                              { цвет фона подсказки }

                ColorInsert : BYTE;
                              { цвет выделенной строки }

                NumberHelpBlock : LONGINT;
                               { номер вспомогательного блока }

                NumberEndBlock : LONGINT;
                               { номер последненго блока }

                WindowBlock : BYTE;
                               { количество блоков пролистываемых в окне }

                CONSTRUCTOR Init ( WindPtr : TextWindowPtr;
                                   Stream : POINTER );
                          { инициализация обьекта }

                PROCEDURE MarkBlock; VIRTUAL;
                          { маркировка блоков }

                PROCEDURE SetColorText ( Cl : BYTE ); VIRTUAL;
                          { установить цвет текста в окне }

                PROCEDURE SetColorFon ( Cl : BYTE ); VIRTUAL;
                          { установить цвет фона в окне }

                PROCEDURE SetColorHelp ( Cl : BYTE ); VIRTUAL;
                          { установить цвет фона активной стороки }

                PROCEDURE SetColorInsert ( Cl : BYTE ); VIRTUAL;
                          { установит цвет символов выделенной стороки }

                PROCEDURE Show_Inf; VIRTUAL;
                          {  показать текущее состояние информации в }
                          {           активизированном окне          }

                PROCEDURE Control_Inf ( VAR ext_byte : LONGINT ); VIRTUAL;
                          { процедура управления информацией в }
                          {        активизированном окне       }

                FUNCTION TestBlock ( num : LONGINT ) : BOOLEAN;
                         { проверка заданнго блока  на наличие }
                         {            флага отметки            }

                FUNCTION SizeBlock ( Num : LONGINT ) : LONGINT;
                         { Выдает размер блока / количество строк / }

                PROCEDURE line_down; VIRTUAL;  { группа процедур       }
                PROCEDURE line_up;   VIRTUAL;  { управления текстовой }
                PROCEDURE Insert;     VIRTUAL; { информацией в окне    }
                PROCEDURE TextEnd;    VIRTUAL;
                PROCEDURE TextHome;   VIRTUAL;
                PROCEDURE Window_Down; VIRTUAL;
                PROCEDURE Window_Up;   VIRTUAL;

                DESTRUCTOR Done;
                         { деинициализация обьекта }

                DESTRUCTOR DoneWithStream;
                         { деинициализация обьекта вместе с потоком }

                END; { object ViewBlockText }

{----------------------------------------------------------}

    
    ViewTehnicHelp = OBJECT ( ViewBlockText )

                PROCEDURE MarkBlock; VIRTUAL;
                          { маркировка блоков }

                PROCEDURE Control_Inf ( VAR ext_byte : LONGINT ); VIRTUAL;
                          { процедура управления информацией в }
                          {        активизированном окне       }

                FUNCTION GetHelpNumber ( NumLine : LONGINT )
                                         : StandartString;
                          { Получить номер подсказки }

                END; { object  ViewTehnicHelp }

IMPLEMENTATION

{----------------------------------------------------------}

PROCEDURE FatalError ( Line : STRING );

BEGIN
     WINDOW ( 1, 1, 80, 25 );
     TEXTBACKGROUND ( BLACK );
     TEXTCOLOR ( LIGHTGRAY );
     CLRSCR;
     WRITELN ( #07 );
     WRITELN ( 'Критический сбой в обьекте ViewBlockText' );
     WRITELN ( Line );
     WRITELN ( 'Выполнение программы прекращается,'
              ,' обращайтесь к программисту' );
     HALT ( 1 )

END; { procedure FatalError }

{----------------------------------------------------------}

CONSTRUCTOR ViewBlockText.Init ( WindPtr :TextWindowPtr; Stream : POINTER );

           { инициализация обьекта }
VAR
   Index : WORD;

BEGIN
     ViewText.Init ( WindPtr, Stream );
     FOR Index := 1 TO MaxBlk DO
         ControlBlock [ Index ] := 0;
     MarkBlock;
     SetColorText ( BLUE );
     SetColorFon ( CYAN );
     SetColorHelp ( RED );
     SetColorInsert ( YELLOW );
     NumberHelpBlock := 1;
     WindowBlock := 7

END;  { constructor ViewBeginText.Init }

{----------------------------------------------------------}

PROCEDURE ViewBlockText.MarkBlock;

          { маркировка блоков }
VAR
   SingFirst : BOOLEAN;
   Line : STRING;
   Size : BYTE;

BEGIN
     NumberEndBlock := 1;
     TextStream^.SetLineNumber ( 1 );
     SingFirst := FALSE;
     Size := 0;
     WHILE ( ( NOT TextStream^.EOFText ) AND ( NumberEndBlock <= MaxBlk ) ) DO
           BEGIN
                TextStream^.ReadLine ( Line );
                IF ( NOT SingFirst ) THEN
                   BEGIN
                        IF ( ( Line <> '' ) AND ( Line [ 1 ] = ' ' ) ) THEN
                           BEGIN
                                SingFirst := TRUE;
                                BeginBlock [ NumberEndBlock ] :=
                                              TextStream^.GetLineNumber - 1;
                                Size := 0
                           END
                   END
                ELSE
                    BEGIN
                         INC ( Size );
                         IF ( ( ( Line <> '' ) AND ( Line [ 1 ] = ' ' ) ) OR
                            ( TextStream^.EOFText ) ) THEN
                            BEGIN
                                 EndBlock [ NumberEndBlock ] :=
                                              TextStream^.GetLineNumber - 2;
                                 INC ( NumberEndBlock );
                                 BeginBlock [ NumberEndBlock ] :=
                                              TextStream^.GetLineNumber - 1;
                                 Size := 0;
                                 IF ( TextStream^.EOFText ) THEN
                                     DEC ( EndBlock [ NumberEndBlock - 1 ] )
                            END
                         ELSE
                             IF ( Size >= 10 ) THEN
                                BEGIN
                                     SingFirst  := FALSE;
                                     EndBlock [ NumberEndBlock ] :=
                                               TextStream^.GetLineNumber - 1;
                                     INC ( NumberEndBlock );
                                     Size := 0
                                END
                    END
           END;
     DEC ( NumberEndBlock );
     IF ( NumberEndBlock = 0 ) THEN
        FatalError ( 'Необнаружено блоков в потоке MarkBlock' );
     TextStream^.SetLineNumber ( 1 )

END; { procedure ViewBeginText.MarkBlock }

{----------------------------------------------------------}

PROCEDURE ViewBlockText.Show_Inf;

          {  показать текущее состояние информации в }
          {           активизированном окне          }
VAR
   x, y : BYTE;
   Index : INTEGER;
   Stroka : STRING;
   Help : STRING;
   IndexX, EndX : BYTE;
   NumLine : LONGINT;
   NumBlock : LONGINT;
   First, Hlp : RecLinePtr;
   SzLines : LONGINT;

BEGIN
     First := NIL;
     Hlp := First;
     IF ( key_ramka ) THEN
        x := 1
     ELSE
         x := 0;
     stroka := '';
     FOR Index := 1 TO size_x DO
         stroka := CONCAT ( stroka, ' ' );
     IF ( Number < 1 ) THEN
        FatalError ( 'Установлен номер блока < 1 в Show_Inf' );
     TextStream^.SetLineNumber ( BeginBlock [ Number ] );
     NumLine := BeginBlock [ Number ];
     TextStream^.SaveState;
     SzLines := TextStream^.GetSize - NumLine;
     IF ( SzLines > Size_Y ) THEN
        SzLines := Size_Y;
     TextStream^.ReadLines ( SzLines, First );
     Hlp := First;
     NumBlock := Number;
     WindowPtr^.SetColorFon ( ColorFon );
     WindowPtr^.SetColorSymbol ( ColorText );
     FOR Index := 1 TO size_y DO
         BEGIN
              IF ( ( ControlBlock [ NumBlock ] <> 0 ) AND
                   ( NumLine <> 0 ) ) THEN
                  WindowPtr^.SetColorSymbol ( ColorInsert )
              ELSE
                  WindowPtr^.SetColorSymbol ( ColorText );
              IF ( NumBlock = NumberHelpBlock ) THEN
                  WindowPtr^.SetColorFon ( ColorHelp )
              ELSE
                  WindowPtr^.SetColorFon ( ColorFon );

              WindowPtr^.WPrint ( LO ( x + 1 ), LO ( Index + x ), stroka );
              IF ( Hlp <> NIL ) THEN
                 BEGIN
                      Help := Hlp^.Line;
                      Hlp := Hlp^.Next
                 END
              ELSE
                  Help := '';

              EndX := PointBeginX + Size_X - 1;
              IF ( EndX > LENGTH ( Help ) ) THEN
                 EndX := LENGTH ( Help );
              FOR IndexX := PointBeginX TO EndX DO
                  WindowPtr^.WChar ( LO ( X + IndexX - PointBeginX + 1),
                                     LO ( Index + x ), Help [ IndexX ] );

              IF ( NumLine <> 0 ) THEN
                 IF ( NumLine < EndBlock [ NumBlock ] ) THEN
                    INC ( NumLine )
                 ELSE
                     BEGIN
                          INC ( NumBlock );
                          NumLine := BeginBlock [ NumBlock ];
                          IF ( NumBlock > NumberEndBlock ) THEN
                             NumLine := 0
                     END
         END;
     TextStream^.RestoreState;
     WindowPtr^.PrintWindow;
     ClearListRecLine ( First );
     WindowPtr^.SetColorFon ( ColorFon );
     WindowPtr^.SetColorSymbol ( ColorText )

END; { procedure ViewBlockText.Show_Inf }

{----------------------------------------------------------}

PROCEDURE ViewBlockText.Control_Inf ( VAR ext_byte : LONGINT );

         { процедура управления информацией в }
         {        активизированном окне       }
VAR
   indx : WORD;
   ChCmd : CHAR;

BEGIN
     REPEAT
           show_inf;
           ChCmd := GetKeyBoard;
           IF ( GetSingKey ) THEN
              BEGIN
                   ChCmd := GetKeyBoard;
                   CASE ChCmd OF
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
                       run_for_key ( ChCmd )
                   END
              END
     UNTIL ( ChCmd IN [ #27, #$0D, #0 ] );
     IF ( ( ChCmd = #$0D ) OR ( ChCmd = #0 ) ) THEN
         ext_byte := NumberHelpBlock
     ELSE
         ext_byte := 0

END; { procedure ViewBlockText.Control_Inf }

{----------------------------------------------------------}

PROCEDURE ViewBlockText.Line_Down;

BEGIN
     IF ( NumberHelpBlock >= NumberEndBlock ) THEN
        EXIT;
     INC ( NumberHelpBlock );
     WHILE ( EndBlock [ NumberHelpBlock ] >=
             BeginBlock [ Number ] + Size_Y - 1 ) DO
           INC ( Number );
     IF ( Number > NumberEndBlock ) THEN
        FatalError ( 'Неожиданное завершение в Line_Down' )

END; { procedure ViewBlockText.Line_Down }

{----------------------------------------------------------}

PROCEDURE ViewBlockText.Line_Up;

BEGIN
     IF ( NumberHelpBlock <= 1 ) THEN
        EXIT;
     DEC ( NumberHelpBlock );
     IF ( ( Number > 1 ) AND ( NumberHelpBlock < Number ) ) THEN
        DEC ( Number )

END; { procedure ViewBlockText.Line_Up }

{----------------------------------------------------------}

PROCEDURE ViewBlockText.TextHome;

BEGIN
     Number := 1;
     NumberHelpBlock := 1

END; { procedure ViewBlockText.TextHome }

{----------------------------------------------------------}

PROCEDURE ViewBlockText.TextEnd;

BEGIN
     Number := NumberEndBlock;
     NumberHelpBlock := Number

END; { procedure ViewBlockText.TextEnd }

{----------------------------------------------------------}

PROCEDURE ViewBlockText.window_down;

VAR
   Index : BYTE;

BEGIN
     FOR Index := 1 TO WindowBlock DO
         Line_Down

END; { procedure ViewBlockText.wind_down }

{----------------------------------------------------------}

PROCEDURE ViewBlockText.window_up;

VAR
   Index : BYTE;

BEGIN
     FOR Index := 1 TO WindowBlock DO
         Line_Up

END; { procedure ViewBlockText.window_up }

{----------------------------------------------------------}

PROCEDURE ViewBlockText.Insert;

BEGIN
     IF ( ControlBlock [ NumberHelpBlock ] = 0 ) THEN
         ControlBlock [ NumberHelpBlock ] := 1
     ELSE
         ControlBlock [ NumberHelpBlock ] := 0

END; { procedure ViewBlockText.Insert }

{----------------------------------------------------------}

PROCEDURE ViewBlockText.SetColorText ( Cl : BYTE );

          { установить цвет текста в окне }
BEGIN
     ColorText := Cl

END;  { procedure ViewBlockText.SetColorText }

{----------------------------------------------------------}

PROCEDURE ViewBlockText.SetColorFon ( Cl : BYTE );

          { установить цвет фона в окне }
BEGIN
     ColorFon := Cl

END;  { procedure ViewBlockText.SetColorFon }

{----------------------------------------------------------}

PROCEDURE ViewBlockText.SetColorHelp ( Cl : BYTE );

          { установить цвет фона активного блока }
BEGIN
     ColorHelp := Cl

END;  { procedure ViewBlockText.SetColorHelp }

{----------------------------------------------------------}

PROCEDURE ViewBlockText.SetColorInsert ( Cl : BYTE );

          { установит цвет символов выделенного блока }
BEGIN
     ColorInsert := Cl

END;  { procedure ViewBlockText.SetColorInsert }

{----------------------------------------------------------}

FUNCTION ViewBlockText.TestBlock ( num : LONGINT ) : BOOLEAN;

         { проверка заданнго блока  на наличие }
         {            флага отметки            }
BEGIN
     IF ( ( Num < 1 ) OR ( Num > NumberEndBlock ) ) THEN
        FatalError ( 'Нет такого номера блока в TestBlock' );
     TestBlock := ( ControlBlock [ Num ] <> 0 )

END; { function ViewBlockText.TestBlock }

{----------------------------------------------------------}

FUNCTION ViewBlockText.SizeBlock ( Num : LONGINT ) : LONGINT;

         { Выдает размер блока / количество строк / }
BEGIN
     IF ( ( Num < 1 ) OR ( Num > NumberEndBlock ) ) THEN
        FatalError ( 'Нет такого номера блока в SizeBlock' );
     SizeBlock := EndBlock [ Num ] - BeginBlock [ Num ] + 1

END; { function ViewBlockText.SizeBlock  }

{----------------------------------------------------------}

DESTRUCTOR ViewBlockText.Done;

           { деинициализация обьекта }
BEGIN
     ViewText.Done

END; { dectructor ViewBlockText.Done }

{----------------------------------------------------------}

DESTRUCTOR ViewBlockText.DoneWithStream;

           { деинициализация обьекта вместе с потоком }
BEGIN
     ViewText.DoneWithStream

END; { dectructor ViewBlockText.DoneWithStream }

{==========================================================}

PROCEDURE ViewTehnicHelp.MarkBlock;

          { маркировка блоков }
VAR
   SingFirst : BOOLEAN;
   Line : STRING;
   Size : BYTE;

BEGIN
     NumberEndBlock := 1;
     TextStream^.SetLineNumber ( 1 );
     SingFirst := FALSE;
     Size := 0;
     WHILE ( ( NOT TextStream^.EOFText ) AND ( NumberEndBlock <= MaxBlk ) ) DO
           BEGIN
                TextStream^.ReadLine ( Line );
                IF ( NOT SingFirst ) THEN
                   BEGIN
                        IF ( ( LENGTH ( Line ) > 5 ) AND ( Line [ 1 ] = ' ' )
                             AND ( Line [ 2 ] IN [ '0','1','2','3','4','5',
                             '6','7','8','9' ] ) ) THEN
                           BEGIN
                                SingFirst := TRUE;
                                BeginBlock [ NumberEndBlock ] :=
                                              TextStream^.GetLineNumber - 1;
                                Size := 0
                           END
                   END
                ELSE
                    BEGIN
                         INC ( Size );
                         IF ( ( LENGTH ( Line ) = 0 ) OR ( Line [ 1 ] = ' ' )
                             AND ( Line [ 2 ] IN [ '0','1','2','3','4','5',
                             '6','7','8','9' ] ) OR ( Line [ 1 ] <>   ' ' )
                             OR ( TextStream^.EOFText ) ) THEN
                            BEGIN
                                 EndBlock [ NumberEndBlock ] :=
                                              TextStream^.GetLineNumber - 2;
                                 INC ( NumberEndBlock );
                                 BeginBlock [ NumberEndBlock ] :=
                                              TextStream^.GetLineNumber - 1;
                                 Size := 0;
                                 IF ( TextStream^.EOFText ) THEN
                                     DEC ( EndBlock [ NumberEndBlock - 1 ] )
                            END
                         ELSE
                             IF ( Size >= 10 ) THEN
                                BEGIN
                                     SingFirst  := FALSE;
                                     EndBlock [ NumberEndBlock ] :=
                                               TextStream^.GetLineNumber - 1;
                                     INC ( NumberEndBlock );
                                     Size := 0
                                END
                    END
           END;
     DEC ( NumberEndBlock );
     IF ( NumberEndBlock = 0 ) THEN
        FatalError ( 'Необнаружено блоков в потоке MarkBlock' );
     TextStream^.SetLineNumber ( 1 )

END; { procedure ViewTehnicHelp.MarkBlock }

{----------------------------------------------------------}

FUNCTION ViewTehnicHelp.GetHelpNumber ( NumLine : LONGINT )
                : StandartString;

         { Получить номер подсказки }
VAR
   Line : STRING;
   HelpS : StandartString;
   Hlp : BYTE;

BEGIN
     TextStream^.SetLineNumber ( NumLine );
     IF ( TextStream^.GetNumberError <> 0 ) THEN
        BEGIN
             GetHelpNumber := '';
             EXIT
        END;
     TextStream^.ReadLine ( Line );
     IF ( ( TextStream^.GetNumberError <> 0 ) OR
        ( LENGTH ( Line ) < 5 ) ) THEN
        BEGIN
             GetHelpNumber := '';
             EXIT
        END;
     WHILE ( ( Line [ 1 ] = ' ' ) AND ( Line <> '' ) ) DO
           DELETE ( Line, 1, 1 );
     Hlp := 1;
     HelpS := '';
     WHILE ( ( Line [ Hlp ] IN [ '1','2','3','4','5','6','7',
             '8','9','0','.' ] ) AND ( Hlp <= LENGTH ( Line ) ) ) DO
           BEGIN
                HelpS := HelpS + Line [ Hlp ];
                INC ( Hlp )
           END;
     GetHelpNumber := HelpS

END; { function ViewTehnicHelp.GetHelpNumber }

{----------------------------------------------------------}

PROCEDURE ViewTehnicHelp.Control_Inf ( VAR ext_byte : LONGINT );

         { процедура управления информацией в }
         {        активизированном окне       }
VAR
   ChCmd : CHAR;
        { код команды }

   Line : String;
        { строка с номером технологической подсказки }

   HelpS : StandartString;
        { строка с выделенным номером технологической подсказки }

   IndexLine : BYTE;
        { индексная переменная }

   Err : INTEGER;
        { код ошибки преобразования строки }

BEGIN
     REPEAT
           show_inf;
           ChCmd := GetKeyBoard;
           IF ( GetSingKey ) THEN
              BEGIN
                   ChCmd := GetKeyBoard;
                   CASE ChCmd OF
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
                       run_for_key ( ChCmd );
                   END
              END
     UNTIL ( ChCmd IN [ #27, #$0D ] );
     IF ( ( ChCmd = #$0D ) OR ( ChCmd = #0 ) ) THEN
        ext_byte := BeginBlock [ NumberHelpBlock ]
     ELSE
         ext_byte := 0

END; { procedure ViewTehnicHelp.Control_Inf }

{----------------------------------------------------------}

END.