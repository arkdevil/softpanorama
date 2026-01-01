

         {----------------------------------------------------}
         {     Модуль EditF  V 1.2  пакета  TURBO SUPPORT     }
         {     Язык программирования Turbo Pascal  V 6.0      }
         {----------------------------------------------------}
         { Дата последних изменений :  31/10/1991             }
         {----------------------------------------------------}
         { Модуль предназначен для обработки текстовых потоков}
         {       для просмотра и редактирования шаблонов      }
         {----------------------------------------------------}
         { (c) 1991, Мигач Ярослав                            }
         {----------------------------------------------------}

UNIT EditF;

{$IFDEF DEBUGVIEW}
      {$D+,L+,R+,S+}
{$ELSE}
      {$D-,L-,R-,S-}
{$ENDIF}

{$F+,O+,I-,V-,B-,A+}

INTERFACE

USES Crt, Dos, Fkey11, Def, TWindow, LcText, ViewT;

CONST
     MaxEdit = 79;
               { максимальная длина редактируемой строки }

     MaxNumEdit = 255;
               { максимальное количество редактируемых строк }

TYPE
    BufEdit = ARRAY [ 1..$8000 ] OF CHAR;
               { Массив редактируемых полей }

    EditFormPtr = ^EditForm;
               { Указатель на обьект шаблона редактирования }

    EditForm = OBJECT  ( ViewText )

                ControlEdit : ARRAY [ 1.. MaxNumEdit ] OF RECORD
                              x, y, lend : WORD;
                                    { координаты и длина подсказки  }
                              num_x : BYTE;
                                    { текущий номер в общей строке }
                              Help : HelpEditProc;
                                     { процедура подсказки }
                              SetUp : RunProcedure;
                                     { процедура начальной установки }
                              Check : CheckEditFunc
                                     { проверочная функция }
                              END;
                              { информация о координатах редактирования }

                PointBuf : ^BufEdit;
                              { Указатель на массив редактируемых полей }

                MaxFields : WORD;
                              { Максимальное колическтво полей в шаблоне }

                SizeFields : WORD;
                              { Общее количество символов выделяемое под поля }

                NumberHelpLine : LONGINT;
                              { номер вспомогательной строки }

                NumberLineEdit : LONGINT;
                               { номер редактируемой строки }

                ColorFon, ColorText : BYTE;
                               { Основной цвет окна }

                ColorField : BYTE;
                               { Цвет поля }

                CONSTRUCTOR Init ( WindPtr : TextWindowPtr;
                                           Stream : POINTER );
                                      { инициализация обьекта }

                PROCEDURE SetColorField ( Color : BYTE );
                           { Установить цвет поля редактирования }

                PROCEDURE SetLineEdit ( knum : WORD;
                                        Stroka : StandartString );
                           { установить строку редактируемого поля }

                PROCEDURE SetHelpEdit ( knum : WORD;
                                        proc : HelpEditProc );
                          { установить процедуру подсказки }

                PROCEDURE SetCheckEdit ( knum : WORD;
                                         func : CheckEditFunc );
                          { установить функцию контроля }

                PROCEDURE SetSetUpEdit ( knum : WORD;
                                         proc : RunProcedure );
                          { установить процедуру начальной установки }

                FUNCTION GetLineEdit ( knum : WORD ) : StandartString;
                         { получить редактируемую строку }

                FUNCTION GetFullLineEDit ( knum : WORD ) : StandartString;
                         { получить полную редактируемую строку }

                FUNCTION SetFieldTo ( Num : LONGINT ) : BOOLEAN;
                         { Устанавливает указатель активного поля   }
                         { на редактируемое поле с заданным номером }
                         { Возвращает значение TRUE если установка  }
                         {          произведена успешно             }

                PROCEDURE Show_Inf; VIRTUAL;
                          {  показать текущее состояние информации в }
                          {           активизированном окне          }

                PROCEDURE SetCoordEdit;

                FUNCTION GetNumberField : WORD;
                          { получить текущий номер поля редактирования }

                PROCEDURE Control_Inf ( VAR ext_byte : LONGINT ); VIRTUAL;
                          { процедура управления информацией в }
                          {        активизированном окне       }

                PROCEDURE line_down; VIRTUAL;  { группа процедур       }
                PROCEDURE line_up;   VIRTUAL;  { управления текстовой }
                PROCEDURE window_down; VIRTUAL;{ информацией в окне    }
                PROCEDURE window_up;  VIRTUAL;
                PROCEDURE TextEnd;    VIRTUAL;
                PROCEDURE TextHome;   VIRTUAL;
                PROCEDURE EditLeft;   VIRTUAL;
                PROCEDURE EditRight;  VIRTUAL;

                DESTRUCTOR Done;
                         { деинициализация обьекта }

                DESTRUCTOR DoneWithStream;
                         { деинициализация обьекта вммместе с потоком }

                END; { object EditForm }

IMPLEMENTATION

{----------------------------------------------------------}

PROCEDURE FatalError ( Line : STRING );

BEGIN
     WINDOW ( 1, 1, 80, 25 );
     TEXTBACKGROUND ( BLACK );
     TEXTCOLOR ( LIGHTGRAY );
     CLRSCR;
     WRITELN ( #07 );
     WRITELN ( 'Критический сбой в обьекте EditForm' );
     WRITELN ( Line );
     WRITELN ( 'Выполнение программы прекращается,'
              ,' обращайтесь к программисту' );
     HALT ( 1 )

END; { procedure FatalError }

{----------------------------------------------------------}

CONSTRUCTOR EditForm.Init;

           { инициализация обьекта }
VAR
   indx : WORD;
   Line : STRING;

BEGIN
     ViewText.Init ( WindPtr, Stream );
     ColorFon := WindowPtr^.ColorFon;
     ColorText := WindowPtr^.ColorSym;
     ColorField := ColorText;
     FOR indx := 1 TO MaxNumEdit DO
         WITH ControlEdit [ indx ] DO
              BEGIN
                   lend := 0;
                   x := 0;
                   y := 0;
                   Help := NulHelpEditProc;
                   SetUp := NulRunProcedure;
                   Check := NulCheckEditFunc
              END;
     NumberHelpLine := 1;
     NumberLineEdit := 1;
     MaxFields := 0;
     SizeFields := 0;
     TextStream^.SetLineNumber ( 1 );
     WHILE ( NOT TextStream^.EofText ) DO
           BEGIN
                TextStream^.ReadLine ( Line );
                FOR Indx := 1 TO LENGTH ( Line ) DO
                    BEGIN
                         IF ( Line [ Indx ] IN [ '_', '#' ] ) THEN
                            INC ( SizeFields );
                         IF ( Line [ Indx ] IN [ '#' ] ) THEN
                            INC ( MaxFields )
                    END
           END;
     IF ( MaxFields = 0 ) THEN
        FatalError ( 'В предлагаемом шаблоне нет полей для редактирования' );
     IF ( MaxFields >= MaxNumEdit ) THEN
        FatalError ( 'Слишком много полей в шаблоне редактирования ' );
     IF ( SizeFields > $8000 ) THEN
        FatalError ( 'Слишком много места для полей редактирования ' );
     GETMEM ( PointBuf, SizeFields );
     FOR indx := 1 TO SizeFields DO
         PointBuf^ [ indx ] := ' ';
     SetCoordEdit

END;  { constructor EditForm.Init }

{----------------------------------------------------------}

PROCEDURE EditForm.line_down;

VAR
   Old : BYTE;
   y : BYTE;

BEGIN
     IF ( Number < 1 ) THEN
        Number := 1;
     IF ( NumberLineEdit < 1 ) THEN
        NumberLineEdit := 1;
     IF ( NumberHelpLine < 1 ) THEN
        NumberHelpLine := 1;
     NumberHelpLine := ControlEdit [ NumberLineEdit ].y;
     IF ( NumberLineEdit >= MaxNumEdit ) THEN
        EXIT;
     IF ( ControlEdit [ NumberLineEdit + 1 ].lend = 0 ) THEN
        EXIT;
     Old := ControlEdit [ NumberLineEdit ].Num_X;
     WHILE ( ( NumberHelpLine = ControlEdit [ NumberLineEdit ].y ) AND
           ( ControlEdit [ NumberLineEdit + 1 ].lend <> 0 ) ) DO
           INC ( NumberLineEdit );
     y := ControlEdit [ NumberLineEdit ].y;
     WHILE ( ( ControlEdit [ NumberLineEdit + 1 ].y = y ) AND
             ( Old <> ControlEdit [ NumberLineEdit ].Num_X ) AND
           ( ControlEdit [ NumberLineEdit + 1 ].lend <> 0 ) ) DO
           INC ( NumberLineEdit );
     WHILE ( ControlEdit [ NumberLineEdit ].lend = 0 ) DO
        DEC ( NumberLineEdit );
     IF ( NumberLineEdit = 0 ) THEN
        FatalError ( 'Номер редактируемого поля = 0 в Line_Down' );
     IF ( NumberHelpLine = ControlEdit [ NumberLineEdit ].y ) THEN
        EXIT;
     NumberHelpLine := ControlEdit [ NumberLineEdit ].y;
     WHILE ( ( ( end_number - number + 1 ) > size_y ) AND
          ( NumberHelpLine > ( number + size_y - 1 ) ) ) DO
        INC ( number )

END; { procedure EditForm.line_down }

{----------------------------------------------------------}

PROCEDURE EditForm.line_up;

VAR
   Old : BYTE;
   y : BYTE;

BEGIN
     IF ( NumberLineEdit <= 1 ) THEN
        BEGIN
             NumberHelpLine := 1;
             number := 1;
             NumberLineEdit := 1;
             EXIT
        END;
     Old := ControlEdit [ NumberLineEdit ].Num_X;
     WHILE ( ( NumberHelpLine = ControlEdit [ NumberLineEdit ].y )
            AND ( NumberLineEdit > 1 ) ) DO
           DEC ( NumberLineEdit );
     y := ControlEdit [ NumberLineEdit ].y;
     IF ( NumberLineEdit > 1 ) THEN
        WHILE ( ( NumberLineEdit > 1 ) AND
                ( ControlEdit [ NumberLineEdit - 1 ].y  = y ) AND
                ( Old <> ControlEdit [ NumberLineEdit ].Num_X ) ) DO
              DEC ( NumberLineEdit );
     IF ( ControlEdit [ NumberLineEdit ].lend = 0 ) THEN
        INC ( NumberLineEdit );
     IF ( NumberLineEdit > MaxNumEdit ) THEN
        FatalError ( 'Номер редактируемого поля больше допустимого'+
                     ' в Line_Up' );
     IF ( NumberHelpLine = ControlEdit [ NumberLineEdit ].y ) THEN
        BEGIN
             EXIT
        END;
     NumberHelpLine := ControlEdit [ NumberLineEdit ].y;
     WHILE ( ( number > 1 ) AND ( NumberHelpLine < number ) ) DO
        DEC ( number )

END; { procedure EditForm.line_up }

{----------------------------------------------------------}

PROCEDURE EditForm.EditLeft;

BEGIN
     IF ( NumberLineEdit <= 1 ) THEN
        BEGIN
             NumberHelpLine := 1;
             number := 1;
             NumberLineEdit := 1;
             EXIT
        END;
     DEC ( NumberLineEdit );
     IF ( NumberLineEdit > MaxNumEdit ) THEN
        FatalError ( 'Номер редактируемого поля больше допустимого'+
                     ' в EditLeft' );
     IF ( NumberHelpLine = ControlEdit [ NumberLineEdit ].y ) THEN
        BEGIN
             EXIT
        END;
     NumberHelpLine := ControlEdit [ NumberLineEdit ].y;
     WHILE ( ( number > 1 ) AND ( NumberHelpLine < number ) ) DO
        DEC ( number )

END; { procedure EditForm.EditLeft }

{----------------------------------------------------------}

PROCEDURE EditForm.EditRight;

BEGIN
     IF ( NumberLineEdit >= MaxNumEdit ) THEN
        EXIT;
     IF ( ControlEdit [ NumberLineEdit + 1 ].lend = 0 ) THEN
        EXIT;
     INC ( NumberLineEdit );
     IF ( NumberLineEdit = 0 ) THEN
        FatalError ( 'Номер редактируемого поля = 0 в EditRight' );
     IF ( NumberHelpLine = ControlEdit [ NumberLineEdit ].y ) THEN
        EXIT;
     NumberHelpLine := ControlEdit [ NumberLineEdit ].y;
     WHILE ( ( ( end_number - number + 1 ) > size_y ) AND
          ( NumberHelpLine > ( number + size_y - 1 ) ) ) DO
        INC ( number )

END; { procedure EditForm.EditRight }

{----------------------------------------------------------}

PROCEDURE EditForm.window_up;

VAR
   Index : BYTE;

BEGIN
     FOR Index := 1 TO ( Size_Y DIV 2 ) DO
         Line_Up

END; { procedure EditForm.window_up }

{----------------------------------------------------------}

PROCEDURE EditForm.window_down;

VAR
   Index : BYTE;

BEGIN
     FOR Index := 1 TO ( Size_Y DIV 2 ) DO
         Line_Down

END; { procedure EditForm.wind_down }

{----------------------------------------------------------}

FUNCTION EditForm.SetFieldTo ( Num : LONGINT ) : BOOLEAN;

         { Устанавливает указатель активного поля   }
         { на редактируемое поле с заданным номером }
         { Возвращает значение TRUE если установка  }
         {          произведена успешно             }
BEGIN
     SetFieldTo := TRUE;
     IF ( ( Num < 1 ) AND ( Num > MaxNumEdit ) ) THEN
        BEGIN
             SetFieldTo := FALSE;
             EXIT
        END;
     WHILE ( ( Num < NumberLineEdit ) AND ( NumberLineEdit <> 1 ) ) DO
           EditLeft;
     WHILE ( ( Num > NumberLineEdit )
             AND ( ControlEdit [ NumberLineEdit ].Lend <> 0 ) ) DO
           EditRight;
     IF ( ControlEdit [ NumberLineEdit ].Lend = 0 ) THEN
        SetFieldTo := FALSE

END; { function EditForm.SetFieldTo }

{----------------------------------------------------------}

PROCEDURE EditForm.TextHome;

BEGIN
     number := 1;
     NumberHelpLine := 1;
     NumberLineEdit := 1

END; { procedure EditForm.TextHome }

{----------------------------------------------------------}

PROCEDURE EditForm.TextEnd;

VAR
    knum : BYTE;

BEGIN
     number := End_Number - size_y + 1;
     knum := 1;
     WHILE ( ControlEdit [ knum + 1 ].lend <> 0 ) DO
           INC ( knum );
     NumberHelpLine := ControlEdit [ knum ].y;
     NumberLineEdit := knum

END; { procedure EditForm.TextEnd }

{----------------------------------------------------------}

PROCEDURE EditForm.SetColorField ( Color : BYTE );

          { Установить цвет поля редактирования }
BEGIN
     ColorField := Color;

END; { procedure EditForm.SetColorField }

{----------------------------------------------------------}

PROCEDURE EditForm.Show_Inf;

          {  показать текущее состояние информации в }
          {           активизированном окне          }
VAR
   x, y : BYTE;
   indx : INTEGER;
   Stroka : StandartString;
   line : String;
   Help, HelpLF : StandartString;
   kindx : WORD;
   knum : WORD;
   j : WORD;
   ekey : BOOLEAN;

BEGIN
     IF ( number < 1 ) THEN
        number := 1;
     knum := 0;
     IF ( key_ramka ) THEN
        x := 1
     ELSE
         x := 0;
     TextStream^.SetLineNumber ( Number );
     TextStream^.SaveState;
     WindowPtr^.SetColorFon ( ColorFon );
     WindowPtr^.SetColorSymbol ( ColorText );
     FOR indx := 1 TO size_y DO
         BEGIN
              TextStream^.ReadLine ( Line );
              WHILE ( LENGTH ( line ) < size_x ) DO
                       line := line + ' ';
              ekey := TRUE;
              FOR j := 1 TO MaxNumEdit DO
                  IF ( ( ControlEdit [ j ].y = indx + number - 1 )
                                              And ekey ) THEN
                     BEGIN
                          knum := j - 1;
                          ekey := FALSE
                     END;
              WindowPtr^.SetColorSymbol ( ColorText );
              WindowPtr^.WPrint ( ( x + 1 ), ( indx + x ), line );
              WindowPtr^.SetColorSymbol ( ColorField );
              IF ( NOT ekey ) THEN FOR kindx := 1 TO LENGTH ( line ) DO
                  IF ( line [ kindx ] IN [ '#' ] ) THEN
                     BEGIN
                          Help := '';
                          INC ( knum );
                          HelpLF := GetLineEdit ( KNum );
                          FOR j := 1 TO LENGTH ( HelpLF ) DO
                              Help := Help + HelpLF [ j ];
                          WHILE ( LENGTH ( Help ) < ControlEdit [ knum ].lend ) DO
                                Help := Help + ' ';
                          WindowPtr^.WPrint ( ( x + kindx ), ( indx + x ),
                                               Help )
                     END
         END;
     WindowPtr^.PrintWindow;
     WindowPtr^.SetColorSymbol ( ColorText );
     TextStream^.RestoreState

END; { procedure EditForm.Show_Inf }

{----------------------------------------------------------}

PROCEDURE EditForm.Control_Inf ( VAR ext_byte : LONGINT );

         { процедура управления информацией в }
         {        активизированном окне       }
VAR
   ChCmd : CHAR;
   indx : BYTE;
   dep : BYTE;
   HelpLine : StandartString;
   j : BYTE;
   s : StandartString;

BEGIN
     IF ( key_ramka ) THEN
        dep := 1
     ELSE
        dep := 0;
     REPEAT
           show_inf;
           IF ( ControlEdit [ NumberLineEdit ].lend <> 0 ) THEN
              WITH ControlEdit [ NumberLineEdit ] DO
                  BEGIN
                       {$V-}
                       HelpLine := GetLineEdit ( NumberLineEDit );
                       REPEAT
                             SetUp;
                             WindowPtr^.XYEdit ( ( x + dep ), ( y + dep - number + 1 ),
                                       ChCmd, lend, HelpLine );
                             Set_Param (  3, ChCmd, SIZEOF ( ChCmd ) );
                             Set_Param ( 2, HelpLine,
                                         SIZEOF ( StandartString ) );
                             IF ( ChCmd = f1 ) THEN Help ( HelpLine );
                             Get_Param ( 3, ChCmd );
                       UNTIL ( ( ( ChCmd <> f1 ) AND ( Check ( HelpLine ) ) )
                               OR ( ChCmd = #27 ) );
                       s := '';
                       FOR j := 1 TO lend DO
                           s := s + ' ';
                       WindowPtr^.SetColorFon ( ColorFon );
                       WindowPtr^.SetColorSymbol ( ColorField );
                       WindowPtr^.XYPrint ( ( x + dep ), ( y + dep - number + 1 ), s );
                       WindowPtr^.XYPrint ( ( x + dep ), ( y + dep - number + 1 ),
                                   HelpLine );
                       WindowPtr^.SetColorSymbol ( ColorText );
                       SetLineEdit ( NumberLineEdit, HelpLine )
                  END
           ELSE
               FatalError ( 'Control_Inf' );
           CASE ChCmd OF
               arrow_down      : line_down;
               #$0D            : BEGIN
                                      IF ( ControlEdit
                                         [ NumberLineEdit + 1 ].lend = 0 ) THEN
                                         ChCmd := #$0D; { f2 }
                                      EditRight
                                 END;
               arrow_up        : line_up;
               ctl_arrow_right : EditRight;
               ctl_arrow_left  : EditLeft;
               page_down       : Window_Down;
               page_up         : Window_Up;
               key_end         : TextEnd;
               key_home        : TextHome
            ELSE
                run_for_key ( ChCmd )
            END
     UNTIL ( ChCmd IN [ #27, f2 ] );
     IF ( ChCmd = #27 ) THEN
         ext_byte := 0
     ELSE
        ext_byte := 1

END; { procedure EditForm.Control_Inf }

{----------------------------------------------------------}

PROCEDURE EditForm.SetCoordEdit;

VAR
   index : LONGINT;
   knum : WORD;
   line : String;
   j : BYTE;
   nx : BYTE;

BEGIN
     knum := 0;
     TextStream^.SetLineNumber ( 1 );
     FOR index := 1 TO TextStream^.GetSize DO
         BEGIN
              TextStream^.ReadLine ( Line );
              nx := 1;
              IF ( knum < MaxNumEdit ) THEN
                 ControlEdit [ knum + 1 ].lend := 0;
              FOR j := 1 TO LENGTH ( line ) DO
                  IF ( line [ j ] IN [ '#', '_' ] ) THEN
                     BEGIN
                         IF ( line [ j ] = '#' ) THEN
                            BEGIN
                                 INC ( knum );
                                 IF ( knum <= MaxNumEdit ) THEN
                                    BEGIN
                                         ControlEdit [ knum ].num_x := nx;
                                         INC ( nx );
                                         INC ( ControlEdit [ knum ].lend );
                                         ControlEdit [ knum ].x := j;
                                         ControlEdit [ knum ].y := index
                                    END
                            END
                         ELSE
                             BEGIN
                                  IF ( ( knum > 0 ) AND
                                       ( knum <= MaxNumEdit ) ) THEN
                                     INC ( ControlEdit [ knum ].lend )
                             END;
                         IF ( ControlEdit [ knum ].lend > MaxEdit ) THEN
                              ControlEdit [ knum ].lend := MaxEdit
                     END
         END;

END; { procedure EditForm.SetCoordEdit }

{----------------------------------------------------------}

DESTRUCTOR EditForm.Done;

           { деинициализация обьекта }
BEGIN
     ViewText.Done;
     FREEMEM ( PointBuf, SizeFields )

END; { dectructor EditForm.Done }

{----------------------------------------------------------}

DESTRUCTOR EditForm.DoneWithStream;

           { деинициализация обьекта вместе с потоком }
BEGIN
     ViewText.DoneWithStream;
     FREEMEM ( PointBuf, SizeFields )

END; { dectructor EditForm.DoneWithStream }
{----------------------------------------------------------}

PROCEDURE EditForm.SetLineEdit ( knum : WORD; Stroka : StandartString );

VAR
   Index : LONGINT;
   Sum : WORD;

BEGIN
     IF ( knum > MaxFields ) THEN
        FatalError ( 'Недопустимый номер поля в  SetLineEdit' );
     Sum := 1;
     FOR Index := 1 TO ( knum - 1 ) DO
         Sum := Sum + ControlEdit [ Index ].lend;
     IF ( ControlEdit [ Knum ].Lend = 0 ) THEN
        EXIT;
     IF ( LENGTH ( Stroka ) > ControlEdit [ Knum ].Lend ) THEN
        DELETE ( Stroka, ControlEdit [ KNum ].Lend,
                 ( LENGTH ( Stroka ) - ControlEdit [ KNum ].Lend ) );
     WHILE ( LENGTH ( Stroka ) < ControlEdit [ KNum ].Lend ) DO
           Stroka := Stroka + ' ';
     FOR Index := Sum TO ( Sum + ControlEdit [ Knum ].Lend - 1 ) DO
         PointBuf^[ Index ] := Stroka [ Index - Sum + 1 ]

END; { procedure EditForm.SetLineEdit }

{----------------------------------------------------------}

PROCEDURE EditForm.SetHelpEdit ( knum : WORD; proc : HelpEditProc );

BEGIN
     ControlEdit [ knum ].Help := proc

END; { procedure EditForm.SetHelpEdit }

{----------------------------------------------------------}

PROCEDURE EditForm.SetCheckEdit ( knum : WORD; func : CheckEditFunc );

BEGIN
     ControlEdit [ knum ].Check := func

END; { procedure EditForm.SetCheckEdit }

{----------------------------------------------------------}

PROCEDURE EditForm.SetSetUpEdit ( knum : WORD; proc : RunProcedure );

BEGIN
     ControlEdit [ knum ].SetUp := proc

END; { procedure EditForm.SetSetUpEdit }

{----------------------------------------------------------}

FUNCTION EditForm.GetLineEdit ( knum : WORD ) : StandartString;

VAR
   Index : LONGINT;
   Line : StandartString;
   Sum : WORD;

BEGIN
     IF ( knum > MaxFields ) THEN
        FatalError ( 'Недопустимый номер поля в  GetLineEdit' );
     Sum := 1;
     FOR Index := 1 TO ( knum - 1 ) DO
         Sum := Sum + ControlEdit [ Index ].lend;
     Line := '';
     GetLineEdit := '';
     IF ( ControlEdit [ Knum ].Lend = 0 ) THEN
        EXIT;
     FOR Index := Sum TO ( Sum + ControlEdit [ Knum ].Lend - 1 ) DO
         Line := Line + PointBuf^[ Index ];
     WHILE ( Line [ LENGTH ( Line ) ] = ' ' ) DO
           DELETE ( Line, LENGTH ( Line ), 1 );
     GetLineEdit := Line;

END; { function EditForm.GetLineEdit }

{----------------------------------------------------------}

FUNCTION EditForm.GetFullLineEdit ( knum : WORD ) : StandartString;

         { получить полную редактируемую строку }
VAR
   Line : StandartString;

BEGIN
     IF ( ( knum > 0 ) AND ( knum <= MaxNumEdit ) ) THEN
        BEGIN
             Line := GetLineEdit ( KNum );
             WHILE ( LENGTH ( Line ) <  ControlEdit [ knum ].lend ) DO
                   Line := Line + ' ';
             GetFullLineEdit := Line
        END
     ELSE
        FatalError ( 'Недопустимый номер редактируемой '+
                     'строки в GetFullLineEdit ' )

END; { procedure EditForm.GetFullLineEdit }

{----------------------------------------------------------}

FUNCTION EditForm.GetNumberField : WORD;

         { получить текущий номер поля редактирования }
BEGIN
     GetNumberField := NumberLineEdit

END; { function EditForm.GetNumberField }

{----------------------------------------------------------}

END.
