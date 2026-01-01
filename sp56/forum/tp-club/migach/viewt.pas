

               {----------------------------------------------}
               {  Модуль ViewT  V 1.2  пакета  TURBO SUPPORT  }
               {  Язык программирования Turbo Pascal V 6.0    }
               {----------------------------------------------}
               { Дата последних изменений : 31/03/1992        }
               {----------------------------------------------}
               {      Модуль включает в себя обьект для       }
               {  просмотра текста из заданного текстового    }
               {       потока в активизированном окне         }
               {----------------------------------------------}
               { (c) 1991 - 1992, Мигач Ярослав               }
               {----------------------------------------------}


UNIT ViewT;

{$IFDEF DEBUGVIEW}
      {$D+,L+,R+,S+}
{$ELSE}
      {$D-,L-,R-,S-}
{$ENDIF}

{$F+,O+,I-,V-,B-,A+}

INTERFACE

USES Dos, Crt, Def, Fkey11, TWindow, LcText;

TYPE
    ViewTextPtr = ^ViewText;
                  { Указатель на обьект управления текстом }

    ViewText = OBJECT  ( control_func_key )
                          { обьект управляющий текстом в окне }

                        TextStream : LocationTextPtr;
                                      { текстовый поток меню }

                        key_ramka : BOOLEAN; { ключ наличия рамки }

                        number : LONGINT;   { текущий номер первой }
                                            {   строки в окне      }

                        OldNumber : LONGINT; { Предыдущий номер первой }
                                             { строки в окне           }

                        PointBeginX : BYTE;
                                            { указатель на первый выводимый }
                                            { символ строки                 }

                        end_number  : LONGINT; { номер последней строки }

                        hlp_number : LONGINT; { вспомогательный номер }

                        size_y : BYTE;  { размер окна по вертикали }

                        size_x : BYTE; { размер окна по горизонтали }

                        GetKeyboard : KeyFunction;
                                       { функция получения управляющего кода }

                        GetSingKey : ControlFunction;
                                       { получение признака управляющего кода }

                        WindowPtr : TextWindowPtr;
                                    { Указатель на обьект текстового окна }

                        Ch : CHAR;
                             { Символ опроса }

                        SingAlt : BOOLEAN;
                          { Признак выхода при выполнении дополнительной функции }

                        LinesList : RecLinePtr;
                          { Вспомогательный строковый список }

                        CodError : BYTE;
                          { Код ошибки }

                        CONSTRUCTOR Init ( WindPtr : TextWindowPtr;
                                           Stream : POINTER );
                                      { инициализация обьекта }

                        PROCEDURE SetNewWindow ( WindPtr : TextWindowPtr );
                                     { Установить новое окно }

                        FUNCTION GetWindowPtr : TextWindowPtr;
                                     { получить указатель на окно }

                        PROCEDURE SetSingAlt ( Sg : BOOLEAN );
                          { Установить признак дополнительной обработки }

                        PROCEDURE line_down; VIRTUAL;
                                      { На сроку вниз }

                        PROCEDURE line_up; VIRTUAL;
                                      { На строку вверх }

                        PROCEDURE window_down; VIRTUAL;
                                      { На окно вниз }

                        PROCEDURE window_up; VIRTUAL;
                                      { На окно вверх }

                        PROCEDURE TextEnd; VIRTUAL;
                                      { На последнее окно }

                        PROCEDURE TextHome; VIRTUAL;
                                      { На первое окно }

                        PROCEDURE CharLeft; VIRTUAL;
                                      { Сдвинуть на символ влево }

                        PROCEDURE CharRight; VIRTUAL;
                                      { Сдвинуть на символ вправо }

                        PROCEDURE SetControl  ( fn1 : ControlFunction;
                                    fn2 : KeyFunction );
                                           { установить функции управления }

                        PROCEDURE show_inf;VIRTUAL;
                                           { показать текущую информацию }
                                           {          в окне             }

                        PROCEDURE control_inf ( VAR num_exit : LONGINT );
                                  VIRTUAL;
                                           { управление информацией  }
                                           {         в окне          }

                        PROCEDURE SetState ( KeyFrm, KeyShade : BOOLEAN );
                                             VIRTUAL;
                                            { установить состооояние }

                        FUNCTION GetLine ( num : LONGINT ) : String;
                                 VIRTUAL;
                                         { получить текстовую стороку с }
                                         {      заданным номером        }

                        FUNCTION GetLastNumber : LONGINT; VIRTUAL;
                                         { получить номер последней строки }
                                         {            текста               }

                        PROCEDURE ClearInf; VIRTUAL;
                                  { очистка буфера текста и вспомогательных }
                                  {               переменных                }

                        PROCEDURE SwapInformation;
                                  { Замена информации в промежуточном списке }

                        DESTRUCTOR Done; { деинициализация обьекта }

                        DESTRUCTOR DoneWithStream;
                            { деинициализация обьекта Вместе с потоком }

                  END; { object ViewText }

{----------------------------------------------------------}

PROCEDURE War ( Line : StandartString );
PROCEDURE ShowError ( Num : BYTE );

IMPLEMENTATION

{----------------------------------------------------------}

PROCEDURE FatalError ( Line : STRING );

BEGIN
     WINDOW ( 1, 1, 80, 25 );
     TEXTBACKGROUND ( BLACK );
     TEXTCOLOR ( LIGHTGRAY );
     CLRSCR;
     WRITELN ( #07 );
     WRITELN ( 'Критический сбой в обьекте ViewText' );
     WRITELN ( Line );
     WRITELN ( 'Выполнение программы прекращается,'
              ,' обращайтесь к программисту' );
     HALT ( 1 )

END; { procedure FatalError }

{----------------------------------------------------------}

PROCEDURE War ( Line : StandartString );

          { вывод предупреждающего сообщения }
VAR
   i : BYTE;
   Wr : TextWindowPtr;

BEGIN
     NEW ( Wr, MakeWindow ( 20, 19, ( 25 + LENGTH ( Line ) ), 22,
                            RED, WHITE ) );
     Wr^.SetShade ( BLACK, BLACK );
     Wr^.SetColorSymbol ( WHITE + BLINK );
     Wr^.FrameWindow ( 1, 1, ( 5 + LENGTH ( Line ) ), 3, 1, CHR ( 196 ) );
     Wr^.SetColorSymbol ( WHITE );
     Wr^.WPrint ( 3, 2, Line );
     Wr^.PrintWindow;
     FOR i := 1 TO 8 DO
         BEGIN
              SOUND ( 900 - i * 8 );
              DELAY ( 100 );
              NOSOUND;
              DELAY ( 50 )
         END;
     DELAY ( 1500 );
     DISPOSE ( Wr, TypeDone )

END; { procedure War }

{----------------------------------------------------------}

PROCEDURE ShowError ( Num : BYTE );

VAR
   Help : STRING;

BEGIN
     CASE Num OF
           1 : War ( 'Ошибка чтения текстового потока' );
           2 : War ( 'Ошибка записи текстового потока' );
           3 : War ( 'Ошибка открытия/закрытия файла текстового потока' );
           4 : War ( 'Ошибка установки номера прямого доступа т п' );
           5 : War ( 'Ошибка отсечения текстового потока' );
           6 : War ( 'Ошибка создания динамических переменных т п' );
     ELSE
         IF ( Num <> 0 ) THEN
            BEGIN
                 STR ( Num, Help );
                 War ( 'Ошибка текстового потока #' + Help + ' ' )
            END;
     END

END; { procedure ShowError }

{----------------------------------------------------------}

PROCEDURE ViewText.ClearInf;

VAR
   indx : BYTE;

BEGIN
     number := 1;
     OldNumber := 1;
     PointBeginX := 1;
     end_number := TextStream^.GetSize;
     ClearListRecLine ( LinesList );
     LinesList := NIL;
     CodError := 0

END; { procedure ViewText.ClearInf }

{----------------------------------------------------------}

PROCEDURE ViewText.line_down;

BEGIN
     IF ( ( end_number - number + 1 ) > size_y ) THEN
        BEGIN
             INC ( number )
        END

END; { procedure ViewText.line_down }

{----------------------------------------------------------}

PROCEDURE ViewText.SetSingAlt ( Sg : BOOLEAN );

          { Установить признак дополнительной обработки }
BEGIN
     SingAlt := Sg

END; { procedure ViewText.SetSingAlt }

{----------------------------------------------------------}

PROCEDURE ViewText.line_up;

BEGIN
     IF ( number > 1 ) THEN
        BEGIN
             DEC ( number )
        END

END; { procedure ViewText.line_up }

{----------------------------------------------------------}

PROCEDURE ViewText.window_up;

BEGIN
     number := number - size_y;
     IF ( number < 1 ) THEN
        number := 1

END; { procedure ViewText.window_up }

{----------------------------------------------------------}

PROCEDURE ViewText.window_down;

BEGIN
     IF ( End_Number <= Size_y ) THEN
        EXIT;
     number := number + size_y;
     IF ( number > ( end_number - size_y + 1 ) ) THEN
        number := end_number - size_y + 1

END; { procedure ViewText.wind_down }

{----------------------------------------------------------}

PROCEDURE ViewText.TextHome;

BEGIN
     number := 1

END; { procedure ViewText.TextHome }

{----------------------------------------------------------}

PROCEDURE ViewText.CharLeft;

BEGIN
     IF ( PointBeginX = 1 ) THEN
        EXIT;
     DEC ( PointBeginX )

END; { procedure ViewText.CharLeft }

{----------------------------------------------------------}

PROCEDURE ViewText.CharRight;

BEGIN
     IF ( PointBeginX > 255 - Size_X ) THEN
        EXIT;
     INC ( PointBeginX )

END; { procedure ViewText.CharRight }

{----------------------------------------------------------}

PROCEDURE ViewText.TextEnd;

BEGIN
     number := End_Number - size_y + 1

END; { procedure ViewText.TextEnd }

{----------------------------------------------------------}

PROCEDURE ViewText.SetNewWindow ( WindPtr : TextWindowPtr );

          { Установить новое окно }
BEGIN
     WindowPtr := WindPtr;
     Size_X := WindowPtr^.Sx;
     Size_Y := WindowPtr^.Sy;
     ClearListRecLine ( LinesList );
     LinesList := NIL

END; { procedure ViewText.SetNewWindow }

{----------------------------------------------------------}

FUNCTION ViewText.GetWindowPtr : TextWindowPtr;

         { получить указатель на окно }
BEGIN
     GetWindowPtr := WindowPtr

END; { function ViewText.GetWindowPtr }

{----------------------------------------------------------}

CONSTRUCTOR ViewText.Init ( WindPtr : TextWindowPtr; Stream : POINTER );

       { инициализация обьекта }
BEGIN
     control_func_key.Init;
     LinesList := NIL;
     WindowPtr := WindPtr;
     Size_X := WindowPtr^.Sx;
     Size_Y := WindowPtr^.Sy;
     SetState ( FALSE, FALSE );
     TextStream := Stream;
     TextStream^.SetErrorProc ( ShowError );
     GetKeyBoard := GetKey;
     GetSingKey := SingKey;
     ClearInf

END; { constructor ViewText.init }

{----------------------------------------------------------}

PROCEDURE ViewText.SetControl  ( fn1 : ControlFunction; fn2 : KeyFunction );

        { установить функции управления }
BEGIN
     GetSingKey := fn1;
     GetKeyBoard := fn2

END; { procedure ViewText.SetControl }

{----------------------------------------------------------}

PROCEDURE ViewText.SwapInformation;

VAR
   Quantity : LONGINT;
   Help : LONGINT;
   HelpList : RecLinePtr;
   Index : LONGINT;

BEGIN
     IF ( CodError <> 0 ) THEN
        EXIT;

     IF ( LinesList = NIL ) THEN
        BEGIN
             { Загрузка вспомогательного списка }

             TextStream^.SetLineNumber ( number  );
             IF ( TextStream^.GetNumberError <> 0 ) THEN
                BEGIN
                     CodError := 4;
                     EXIT
                END;
             TextStream^.SaveState;
             Quantity := TextStream^.GetSize - Number + 1;
             IF ( Quantity > Size_Y ) THEN
                Quantity := Size_Y;
             TextStream^.ReadLines ( Quantity, LinesList );
             IF ( TextStream^.GetNumberError <> 0 ) THEN
                BEGIN
                     CodError := 1;
                     EXIT
                END
        END
     ELSE
         IF ( OldNumber <> Number ) THEN
            BEGIN
                 { Изменение списка }

                 Quantity := ABS ( OldNumber - Number );
                 HelpList := NIL;
                 IF ( OldNumber < Number ) THEN
                    TextStream^.RestoreState;
                 IF ( Quantity >= ( Size_Y - 1 ) ) THEN
                    BEGIN
                         ClearListRecLine ( LinesList );
                         LinesList := NIL;
                         TextStream^.SetLineNumber ( number  );
                         IF ( TextStream^.GetNumberError <> 0 ) THEN
                         BEGIN
                              CodError := 4;
                              EXIT
                         END;
                         TextStream^.SaveState;
                         Quantity := TextStream^.GetSize - Number + 1;
                         IF ( Quantity > Size_Y ) THEN
                            Quantity := Size_Y;
                         TextStream^.ReadLines ( Quantity, LinesList );
                         IF ( TextStream^.GetNumberError <> 0 ) THEN
                            BEGIN
                                 CodError := 1;
                                 EXIT
                            END
                    END
                 ELSE
                     BEGIN
                          IF ( OldNumber < Number ) THEN
                             TextStream^.SetLineNumber ( OldNumber +
                                                         Size_Y )
                          ELSE
                              TextStream^.SetLineNumber ( Number );
                          IF ( TextStream^.GetNumberError <> 0 ) THEN
                             BEGIN
                                  CodError := 1;
                                  EXIT
                             END;
                          TextStream^.ReadLines ( Quantity, HelpList );
                          IF ( TextStream^.GetNumberError <> 0 ) THEN
                             BEGIN
                                  CodError := 1;
                                  EXIT
                             END;
                          IF ( OldNumber < Number ) THEN
                             BEGIN
                                  FOR Index := 1 TO Quantity DO
                                      DelListLine ( 1, LinesList );
                                  AddListLine ( LinesList, HelpList )
                             END
                          ELSE
                              BEGIN
                                   IF ( SizeListLine ( LinesList )
                                        < Size_Y ) THEN
                                      BEGIN
                                           Help := Size_Y - SizeListLine
                                                            ( LinesList );
                                           Quantity := Quantity - Help
                                      END;
                                   FOR Index := 1 TO Quantity DO
                                       DelListLine (
                                              SizeListLine ( LinesList ),
                                              LinesList );
                                   InsertList ( 1, LinesList, HelpList )
                              END
                     END
            END;
     OldNumber := Number;


END; { procedure ViewText.SwapInformation }

{----------------------------------------------------------}

PROCEDURE ViewText.show_inf;

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
     WindowPtr^.PrintWindow

END; { procedure ViewText.show_inf }

{----------------------------------------------------------}

PROCEDURE ViewText.control_inf ( VAR num_exit : LONGINT );

          { управление просмотром при помощи клавиш }
          {       функциональной клавиатуры         }
VAR
   OldSize : LONGINT;

BEGIN
     Num_Exit := 0;
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
                        page_down  : window_down;
                        page_up    : window_up;
                        arrow_left : CharLeft;
                        arrow_right: CharRight;
                        Key_end    : TextEnd;
                        Key_Home   : TextHome
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
     IF ( Ch <> #27 ) THEN
        Num_Exit := Number

END; { procedure ViewText.control_inf }

{----------------------------------------------------------}

PROCEDURE ViewText.SetState  ( KeyFrm, KeyShade : BOOLEAN );

          { установить состояние окна просмотра }
BEGIN
     key_ramka := KeyFrm;
     IF ( KeyFrm ) THEN
        BEGIN
             Size_X := WindowPtr^.Sx - 2;
             Size_Y := WindowPtr^.Sy - 2
        END
     ELSE
         BEGIN
              Size_X := WindowPtr^.Sx;
              Size_Y := WindowPtr^.Sy
         END;
     IF ( KeyShade ) THEN
        BEGIN
             DEC ( Size_X );
             DEC ( Size_Y )
        END;
     ClearListRecLine ( LinesList );
     LinesList := NIL

END; { procedure ViewText.SetState }

{----------------------------------------------------------}

FUNCTION ViewText.GetLine ( num : LONGINT ) : String;

VAR
   Help : StandartString;

BEGIN
     TextStream^.SetLineNumber ( num );
     IF ( TextStream^.GetNumberError = 0 ) THEN
        BEGIN
             TextStream^.ReadLine ( Help );
             IF ( TextStream^.GetNumberError <> 0 ) THEN
                BEGIN
                     CodError := 1;
                     Help := 'Ошибка загрузки';
                     EXIT
                END
        END
     ELSE
         Help := ' Номер строки недопустим в функции ViewText.GetLine';
     GetLine := Help

END; { function ViewText.GetLine }

{----------------------------------------------------------}

FUNCTION ViewText.GetLastNumber : LONGINT;

BEGIN
     GetLastNumber := end_number

END; { function ViewText.GetLastNumber }

{----------------------------------------------------------}

DESTRUCTOR ViewText.done;

           { деинициализация обьекта }
BEGIN
     control_func_key.done;
     ClearListRecLine ( LinesList )

END; { destructor ViewText.done }

{----------------------------------------------------------}

DESTRUCTOR ViewText.DoneWithStream;

           { деинициализация обьекта Вместе с потоком }
BEGIN
     control_func_key.done;
     ClearListRecLine ( LinesList );
     TextStream^.Done

END; { destructor ViewTextWithStream.done }

{----------------------------------------------------------}

END.