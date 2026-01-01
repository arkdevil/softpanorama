
               {----------------------------------------------}
               {  Модуль EditT  V 1.1  пакета  TURBO SUPPORT  }
               {  Язык программирования Turbo Pascal V 6.0    }
               {----------------------------------------------}
               { Дата последних изменений : 03/08/1991        }
               {----------------------------------------------}
               {      Модуль включает в себя обьект для       }
               { редактирования текста из заданного текстового}
               {       потока в активизированном окне         }
               {----------------------------------------------}
               { (c) 1991, Мигач Ярослав                      }
               {----------------------------------------------}

UNIT EditT;

{$IFDEF DEBUGTEXT}
      {$D+,L+,R+,S+}
{$ELSE}
      {$D-,L-,R-,S-}
{$ENDIF}

{$F+,O+,I-,V-,B-,A+}

INTERFACE

USES Crt, Dos, Fkey11, Def, TWindow, LcText, ViewT;

CONST
     MinLineNumberEdit = 35;
        { минимальное количество строк из потока }

     DeltLineNumberEdit = 60;
        { загружаемое количество строк из потока }

     MaxLineNumberEdit = 80;
        { максимальное количество строк в обьекте }

TYPE
    EditTextPtr = ^EditText;

    EditText = OBJECT  ( ViewText )

                Kx : BYTE;
                         { текущая координата редактирования }

                SingEdit : BOOLEAN;
                         { признак редактирования списка }

                SingEdit2 : BOOLEAN;
                         { признак второй строки }

                Quantity : LONGINT;
                         { количество строк в обьекте редактирования }
                         {         загруженных из потока             }

                First : RecLinePtr;
                         { указатель на первую строку текста }

                FirstPtr : LONGINT;
                         { номер первой строки списка в потоке }

                NowNumber : LONGINT;
                         { номер редактируемой строки в списке }

                SingInsert : BOOLEAN;
                         { признак вставки/замещения текста }

                WordWap : BYTE;
                          { выравнивание текста по заданной позиции }

                CONSTRUCTOR Init ( WindPtr : TextWindowPtr;
                                   Stream : POINTER );
                          { инициализация обьекта }

                PROCEDURE Show_Inf; VIRTUAL;
                          {  показать текущее состояние информации в }
                          {           активизированном окне          }

                PROCEDURE Control_Inf ( VAR ext_byte : LONGINT ); VIRTUAL;
                          { процедура управления информацией в }
                          {        активизированном окне       }

                PROCEDURE Edit ( LnPtr : RecLinePtr; VAR chcmd : CHAR );

                PROCEDURE line_down; VIRTUAL;  { группа процедур       }
                PROCEDURE line_up;   VIRTUAL;  { управления текстовой }
                PROCEDURE window_down; VIRTUAL;{ информацией в окне    }
                PROCEDURE window_up;  VIRTUAL;
                PROCEDURE TextEnd;    VIRTUAL;
                PROCEDURE TextHome;   VIRTUAL;
                PROCEDURE NewLine;
                PROCEDURE SaveInf;
                PROCEDURE LoadInf;
                PROCEDURE DeleteLine;
                PROCEDURE ConcatUpLine;
                PROCEDURE LineWordWap;
                PROCEDURE SetWordWap ( Wp : BYTE );
                PROCEDURE SetInsert;
                PROCEDURE SetReplace;

                DESTRUCTOR Done;
                         { деинициализация обьекта }

                DESTRUCTOR DoneWithStream;
                         { деинициализация обьекта вместе с потоком }

                END; { object EditText }

IMPLEMENTATION

{----------------------------------------------------------}

PROCEDURE FatalError ( Line : STRING );

BEGIN
     WINDOW ( 1, 1, 80, 25 );
     TEXTBACKGROUND ( BLACK );
     TEXTCOLOR ( LIGHTGRAY );
     CLRSCR;
     WRITELN ( #07 );
     WRITELN ( 'Критический сбой в обьекте Edit Text' );
     WRITELN ( Line );
     WRITELN ( 'Выполнение программы прекращается,'
              ,' обращайтесь к программисту' );
     HALT ( 1 )

END; { procedure FatalError }

{----------------------------------------------------------}

PROCEDURE FullLine ( MaxLend : BYTE; VAR Source, Dest : STRING );

VAR
   Index : BYTE;

BEGIN
     IF ( MaxLend >= LENGTH ( Source ) ) THEN
        FatalError ( 'Несанкционированное обращение к процедуре FullLine' );
     Dest := '';
     WHILE ( LENGTH ( Source ) > MaxLend ) DO
           BEGIN
                Dest := Dest + Source [ MaxLend + 1 ];
                DELETE ( Source, MaxLend + 1, 1 )
           END;
     WHILE ( NOT ( Source [ LENGTH ( Source ) ] IN [ ' ', '.', ',', '(',
             ')', ':', ';' ] ) AND ( Source <> '' ) ) DO
           BEGIN
                Dest := Source [ LENGTH ( Source ) ] + Dest;
                DELETE ( Source, LENGTH ( Source ), 1 )
           END

END; { procedure FullLine }

{----------------------------------------------------------}

PROCEDURE EditText.SetWordWap ( Wp : BYTE );

BEGIN
     IF ( ( Wp < 10 ) OR ( Wp > 255 ) ) THEN
        EXIT;
     WordWap := Wp

END; { procedure EditTex.SetWordWap }

{----------------------------------------------------------}

CONSTRUCTOR EditText.Init ( WindPtr : TextWindowPtr; Stream : POINTER );

           { инициализация обьекта }
BEGIN
     ViewText.Init ( WindPtr, Stream );
     Kx := 1;
     SingEdit := FALSE;
     SingEdit2 := FALSE;
     Quantity := 0;
     First := NIL;
     FirstPtr := 1;
     NowNumber := 1;
     SingInsert := TRUE;
     Kx := 1;
     WordWap := 65;

END;  { constructor EditText.Init }

{----------------------------------------------------------}

PROCEDURE EditText.Edit ( LnPtr : RecLinePtr; VAR chcmd : CHAR );

CONST

    cr = $0D; { выход из редактора }
    esc = 27;
    ctlf = 06;
    CtlA = 01;

    del =  08; { удаление предыдущего слова }
    ctlg = 07; { удаление текущего символа }
    ddel = 83;
    ctld = 04; right = 77; { на символ вперед }
    ctlh = 19; ctls = 19; left = 75; { на символ назад }
    ins = 82; invs = 22;

    Tab = 09;
    CtlY = $19;
    CtlP = $10;

    KHome = 2;
    KEnd  = 3;

    ln = 255;

VAR
   cm : CHAR;    { командная переменная }
   u : INTEGER; { вспомогательная переменная }
   key_edit : BOOLEAN; { ключ редактирования }
   help : StandartString;
   Stroka : STRING;
   Delt : BYTE;
   X, Y : BYTE;
   IndPos, NewPos, OldPos : BYTE;
   KeyTemp : BOOLEAN;

PROCEDURE quit;

BEGIN
     HideCursor;
     WHILE ( Stroka [ LENGTH ( Stroka ) ] = ' ' ) DO
           DELETE ( Stroka, LENGTH ( Stroka ), 1 );
     LnPtr^.Line := Stroka

END; { procedure quit }

PROCEDURE SetSymbol;

BEGIN
     SingEdit := TRUE;
     IF ( SingInsert ) THEN
        BEGIN
             IF ( kx > LENGTH ( Stroka ) ) THEN
                BEGIN
                     Stroka := Stroka + chcmd;
                     IF ( kx < ln ) THEN
                        INC ( kx )
                END
             ELSE
                 BEGIN
                      IF ( LENGTH ( stroka ) = ln ) THEN
                         BEGIN
                              System.DELETE ( stroka, LENGTH ( stroka ), 1 )
                         END;
                      System.INSERT ( chcmd, stroka, kx );
                      INC ( kx )
                 END
        END
     ELSE
         BEGIN
              IF ( kx > LENGTH ( stroka ) ) THEN
                  stroka := Stroka + chcmd
              ELSE
                  stroka [ kx ] := chcmd;
              IF ( kx < ln ) THEN
                 INC ( kx )
         END;
     WHILE ( Stroka [ LENGTH ( Stroka ) ] = ' ' )
             AND ( Kx <= LENGTH ( Stroka ) ) DO
           DELETE ( Stroka, LENGTH ( Stroka ), 1 )

END; { procedure SetSymbol }

PROCEDURE ShowLine;

VAR
   Index, Num : BYTE;
   OldWindowNumber : BYTE;

BEGIN
     IF ( Kx < PointBeginX ) THEN
        BEGIN
             PointBeginX := Kx;
             Show_Inf
        END;
     IF ( Kx > ( PointBeginX + Size_X - 1 ) ) THEN
        BEGIN
             WHILE ( Kx > ( PointBeginX + Size_X - 1 ) ) DO
                   INC ( PointBeginX );
             Show_Inf
        END;
     Num := PointBeginX + Size_X - 1;
     IF ( Num > LENGTH ( Stroka ) ) THEN
        Num := LENGTH ( Stroka );
     WindowPtr^.XYPrint ( 1 + Delt, Y, Help );
     FOR Index := PointBeginX TO Num DO
         WindowPtr^.XYChar ( ( Index - PointBeginX + 1 + Delt ), Y,
                             Stroka [ Index ] );
     WindowPtr^.Cursor ( ( Kx - PointBeginX + 1 + Delt ), Y )

END; { procedure ShowLine }

BEGIN
    Stroka := LnPtr^.Line;
    IF ( Key_Ramka ) THEN
       Delt := 1
    ELSE
        Delt := 0;
    Y := NowNumber - Number + 1 + Delt;
    WHILE ( Kx > LENGTH ( Stroka ) ) DO
          Stroka := Stroka + ' ';
    IF ( Kx < 1 ) THEN
       Kx := 1;
    Help := '';
    FOR u := 1 TO Size_X DO
        Help := Help + ' ';

    WHILE TRUE DO   { цикл редактирования }

        BEGIN
               { ввод команды }

             ShowLine;
             WHILE ( Stroka [ LENGTH ( Stroka ) ] = ' ' ) DO
                   DELETE ( Stroka, LENGTH ( Stroka ), 1 );
             IF ( LENGTH ( Stroka ) > WordWap  ) THEN
                BEGIN
                     KeyTemp := FALSE;
                     FOR IndPos := 1 TO LENGTH ( Stroka ) DO
                         IF ( Stroka [ IndPos ] IN [ ' ', '.', ',', '(',
                                ')', ':', ';'] ) THEN
                            KeyTemp := TRUE;
                     IF KeyTemp THEN
                        BEGIN
                             chcmd := #0;
                             quit;
                             EXIT
                        END
                END;
             WHILE ( Kx > LENGTH ( Stroka ) ) DO
                   Stroka := Stroka + ' ';
             chcmd := GetKeyBoard;
             IF ( ( GetSingKey ) AND ( chcmd = #0 ) ) THEN
                BEGIN
                     cm := GetKeyBoard;
                     CASE  ORD ( cm )  OF
                           left: chcmd := CHR ( ctls );
                           right:chcmd := CHR ( ctld );
                           ddel :chcmd := CHR ( ctlg );
                           ins  :chcmd := CHR ( invs );
                           ORD ( Ctl_Arrow_Left ) : chcmd := CHR ( CtlA );
                           ORD ( Ctl_Arrow_Right ): chcmd := CHR ( CtlF );
                           ORD ( Key_Home ) : chcmd := CHR ( KHome );
                           ORD ( Key_End ) : chcmd := CHR ( KEnd )
                     ELSE
                         BEGIN
                              chcmd := cm;
                              quit;
                              EXIT
                         END
                     END
                END;
            CASE ORD ( chcmd ) OF

                     ctla : IF ( Kx <> 1 ) THEN
                               BEGIN
                                    KeyTemp := Stroka [ Kx ] IN
                                        [ ' ', ',','.','-','(',')' ];
                                    DEC ( kx );
                                    WHILE ( ( Kx <> 1 ) AND ( ( NOT
                                        (  Stroka [ Kx ] IN
                                         [ ' ', ',','.','-','(',')' ] )
                                         AND NOT KeyTemp )
                                         OR
                                        (  ( Stroka [ Kx ] IN
                                         [ ' ', ',','.','-','(',')' ] )
                                         AND KeyTemp  )
                                         ) )  DO
                                         DEC ( Kx )
                               END
                             ELSE
                                 BEGIN
                                      chcmd := Arrow_Up;
                                      Kx := 1;
                                      Quit;
                                      EXIT
                                 END;

                     KHome: Kx := 1;

                     KEnd : Kx := LENGTH ( Stroka ) + 1;

                     Tab  : BEGIN
                                 NewPos := ( ( Kx DIV 5 ) + 1 ) * 5;
                                 IF ( NewPos > ln ) THEN
                                    NewPos := Kx;
                                 chcmd := ' ';
                                 OldPos := Kx;
                                 IF ( SingInsert ) THEN
                                    FOR IndPos := OldPos TO NewPos - 1 DO
                                        SetSymbol
                                 ELSE
                                     Kx := NewPos
                            END;

                     CtlY : BEGIN
                                  Quit;
                                  Exit
                            END;

                     cr   : BEGIN
                                 quit;
                                 EXIT
                            END;

                     esc  : BEGIN
                                 quit;
                                 EXIT
                            END;

                     invs : SingInsert := NOT ( SingInsert );

                     del  :BEGIN
                           IF ( Kx = 1 ) AND ( NowNumber <> 1 ) THEN
                              BEGIN
                                   quit;
                                   EXIT
                              END;
                           IF ( LENGTH ( Stroka ) = 0 ) THEN
                               BEGIN
                                    chcmd := CHR ( CtlY );
                                    Quit;
                                    EXIT
                               END
                            ELSE
                                IF ( kx > 1 ) THEN
                                   BEGIN
                                        DEC ( kx );
                                        DELETE ( stroka, kx, 1 )
                                   END
                                ELSE
                                    IF ( ( kx = 1 ) AND
                                       ( LENGTH ( stroka ) <> 0 ) ) THEN
                                       DELETE ( stroka, 1, 1 )
                            END;

                     ctlg : IF ( ( LENGTH ( stroka ) <> 0 ) AND
                                 ( kx <= LENGTH ( stroka ) ) ) THEN
                               DELETE ( stroka, kx, 1 )
                            ELSE
                                IF ( LENGTH ( Stroka ) = 0 ) THEN
                                   BEGIN
                                        chcmd := CHR ( CtlY );
                                        Quit;
                                        EXIT
                                   END;

                     ctld : BEGIN
                                 IF ( kx < ln ) THEN
                                    BEGIN
                                         INC ( kx );
                                         IF ( LENGTH ( Stroka ) < Kx ) THEN
                                            Stroka := Stroka + ' '
                                    END
                            END;

                     ctls : IF ( kx <> 1 ) THEN
                                DEC ( kx )
                            ELSE
                                BEGIN
                                     chcmd := CHR ( 75 );
                                     quit;
                                     EXIT
                                END;

                     ctlf : IF ( Kx < LENGTH ( Stroka ) ) THEN
                               BEGIN
                                    KeyTemp := Stroka [ Kx ] IN
                                        [ ' ', ',','.','-','(',')' ];
                                    INC ( Kx );
                                    WHILE ( ( Kx < LENGTH ( Stroka ) ) AND ( ( NOT
                                        (  Stroka [ Kx ] IN
                                         [ ' ', ',','.','-','(',')' ] )
                                         AND NOT KeyTemp )
                                         OR
                                        (  ( Stroka [ Kx ] IN
                                         [ ' ', ',','.','-','(',')' ] )
                                         AND KeyTemp  )
                                         ) )  DO
                                         INC ( Kx )
                               END
                             ELSE
                                 BEGIN
                                      chcmd := Arrow_Down;
                                      Kx := 1;
                                      Quit;
                                      EXIT
                                 END
            ELSE
                SetSymbol
            END
        END

END; { procedure EditText.Edit }

{----------------------------------------------------------}

PROCEDURE EditText.Show_Inf;

          {  показать текущее состояние информации в }
          {           активизированном окне          }
VAR
   LnPtr : RecLinePtr;
   x, y : BYTE;
   indx : INTEGER;
   stroka : String;
   Help : String;
   MQuantity : LONGINT;
   IndexX, EndX : BYTE;

BEGIN
     LnPtr := FindLine ( Number, First );
     IF ( key_ramka ) THEN
        x := 1
     ELSE
         x := 0;
     stroka := '';
     FOR indx := 1 TO size_x DO
         stroka := CONCAT ( stroka, ' ' );
     IF ( Number < 1 ) THEN
        Number := 1;
     MQuantity := Number;
     FOR indx := 1 TO size_y DO
         BEGIN
              WindowPtr^.WPrint ( LO ( x + 1 ), LO ( indx + x ), stroka );
              IF ( LnPtr <> NIL ) THEN
                 BEGIN
                      Help := LnPtr^.Line;
                      LnPtr := LnPtr^.Next
                 END
              ELSE
                  Help := '';
              INC ( MQuantity );
              EndX := PointBeginX + Size_X - 1;
              IF ( EndX > LENGTH ( Help ) ) THEN
                 EndX := LENGTH ( Help );
              IF ( ( indx + number - 1 ) <= end_number ) THEN
                  FOR IndexX := PointBeginX TO EndX DO
                      WindowPtr^.WChar ( LO ( X + IndexX - PointBeginX + 1),
                           LO ( indx + x ), Help [ IndexX ] )
         END;
     WindowPtr^.PrintWindow

END; { procedure EditText.Show_Inf }

{----------------------------------------------------------}

PROCEDURE EditText.Control_Inf ( VAR ext_byte : LONGINT );

         { процедура управления информацией в }
         {        активизированном окне       }
VAR
   chcmd : CHAR;
   Index : LONGINT;
   Hlp : RecLinePtr;
   OldEditNumber : LONGINT;
   CurrentSize : LONGINT;
   OldPtr : LONGINT;

BEGIN
     Ext_Byte := 0;
     IF ( TextStream^.GetSize < FirstPtr ) THEN
        FirstPtr := 1;
     LoadInf;
     IF ( CodError <> 0 ) THEN
        EXIT;
     OldEditNumber := 0;
     REPEAT
           IF ( Number < 1 ) THEN
              FatalError ( 'Начальный номер меньше 1 в Control_Inf' );
           IF ( Number > NowNumber ) THEN
              FatalError ( 'Начальный номер больше номера строки'+
                           'редактирования в Control_Inf' );
           IF ( ( NowNumber - Number + 1 ) > Size_Y ) THEN
              FatalError ( 'Недопустимая разность между стартовым номером'+
                           ' и номером редактирования в Control_Inf' );
           IF ( OldEditNumber <> Number ) THEN
              Show_Inf;
           IF ( CodError <> 0 ) THEN
              EXIT;
           OldEditNumber := Number;
           Hlp := FindLine ( NowNumber, First );
           IF ( Hlp = NIL ) THEN
              FatalError ( 'Пустой указатель на редактируемую строку' +
                           ' в Control_Inf' );
           Edit ( Hlp, chcmd );
           CASE chcmd OF
                #0            : BEGIN
                                     LineWordWap;
                                     OldEditNumber := 0
                                END;
                arrow_down    : line_down;
                arrow_up      : line_up;
                page_down     : window_down;
                page_up       : window_up;
                Ctl_Page_Down : TextEnd;
                Ctl_Page_Up   : TextHome;
                #$0D          : BEGIN
                                     NewLine;
                                     OldEditNumber := 0
                                END;
                #$19          : BEGIN
                                     DeleteLine;
                                     OldEditNumber := 0
                                END;
                #$08          : BEGIN
                                     ConcatUpLine;
                                     OldEditNumber := 0
                                END
           ELSE
               run_for_key ( chcmd )
           END;
           IF ( CodError <> 0 ) THEN
              EXIT;

           CurrentSize := SizeListLine ( First );

           IF ( CurrentSize >= MaxLineNumberEdit ) THEN
              BEGIN
                   SaveInf;
                   IF ( CodError <> 0 ) THEN
                      EXIT;
                   OldEditNumber := 0;
                   LoadInf;
                   IF ( CodError <> 0 ) THEN
                      EXIT
              END;

           IF ( ( NowNumber = 1 ) AND ( FirstPtr > 1 ) ) THEN
              BEGIN
                   SaveInf;
                   IF ( CodError <> 0 ) THEN
                      EXIT;
                   OldPtr := FirstPtr;
                   FirstPtr := FirstPtr - 25;
                   IF ( FirstPtr < 1 ) THEN
                      FirstPtr := 1;
                   OldEditNumber := 0;
                   Number := Number + ( OldPtr - FirstPtr );
                   NowNumber := NowNumber + ( OldPtr - FirstPtr );
                   LoadInf;
                   IF ( CodError <> 0 ) THEN
                      EXIT
              END;

	   IF ( ( ( CurrentSize - NowNumber ) <= 25 ) AND
              ( TextStream^.GetSize - FirstPtr > DeltLineNumberEdit ) ) THEN
              BEGIN
                   SaveInf;
                   IF ( CodError <> 0 ) THEN
                      EXIT;
                   OldPtr := FirstPtr;
                   FirstPtr := FirstPtr + Number;
                   IF ( TextStream^.GetSize - FirstPtr <
                        DeltLineNumberEdit ) THEN
                      FirstPtr := TextStream^.GetSize - DeltLineNumberEdit + 1;
                   OldEditNumber := 0;
                   IF ( ( FirstPtr - OldPtr ) >= Number ) THEN
                      FirstPtr := OldPtr + Number - 1;
                   Number := Number - ( FirstPtr - OldPtr );
                   NowNumber := NowNumber - ( FirstPtr - OldPtr );
                   LoadInf;
                   IF ( CodError <> 0 ) THEN
                      EXIT
              END

     UNTIL ( chcmd IN [ #27 ] );
     SaveInf;
     IF ( CodError <> 0 ) THEN
        EXIT;
     IF ( CurrentSize > DeltLineNumberEdit ) THEN
        BEGIN
             OldPtr := FirstPtr;
             FirstPtr := FirstPtr + Number;
             IF ( TextStream^.GetSize - FirstPtr <
                DeltLineNumberEdit ) THEN
                FirstPtr := TextStream^.GetSize - DeltLineNumberEdit + 1;
             OldEditNumber := 0;
             IF ( ( FirstPtr - OldPtr ) >= Number ) THEN
                FirstPtr := OldPtr + Number - 1;
             Number := Number - ( FirstPtr - OldPtr );
             NowNumber := NowNumber - ( FirstPtr - OldPtr )
        END;
     ext_byte := 0;
     ClearListRecLine ( First )

END; { procedure EditText.Control_Inf }

{----------------------------------------------------------}

PROCEDURE EditText.SaveInf;

BEGIN
     IF ( SingEdit ) THEN
        BEGIN
             TextStream^.SetLineNumber ( FirstPtr );
             IF ( TextStream^.GetNumberError <> 0 ) THEN
                BEGIN
                     CodError := 4;
                     EXIT
                END;
             TextStream^.ReplaseLines ( Quantity,
                            SizeListLine ( First ), First );
             IF ( TextStream^.GetNumberError <> 0 ) THEN
                BEGIN
                     CodError := 3;
                     EXIT
                END
        END;
     SingEdit := FALSE

END; { procedure SaveInf }

{----------------------------------------------------------}

PROCEDURE EditText.LoadInf;

VAR
   Index : LONGINT;

BEGIN
     ClearListRecLine ( First );
     TextStream^.SetLineNumber ( FirstPtr );
     IF ( TextStream^.GetNumberError <> 0 ) THEN
        BEGIN
             CodError := 4;
             EXIT
        END;
     Quantity := TextStream^.GetSize - TextStream^.GetLineNumber + 1;
     IF ( Quantity > DeltLineNumberEdit ) THEN
        Quantity := DeltLineNumberEdit;
     TextStream^.ReadLines ( Quantity, First );
     IF ( TextStream^.GetNumberError <> 0 ) THEN
        BEGIN
             CodError := 3;
             EXIT
        END;
     TextStream^.SaveState

END; { procedure EditText.LoadInf }

{----------------------------------------------------------}

PROCEDURE EditText.NewLine;

VAR
   Hlp, Old : RecLinePtr;
   Num : BYTE;
   Line : STRING;

BEGIN
     Old := FindLine ( NowNumber, First );
     Line := Old^.Line;
     NEW ( Hlp );
     IF ( ( SingInsert ) OR ( SizeListLine ( First ) = NowNumber ) ) THEN
        BEGIN
             SingEdit := TRUE;
             Hlp^.Next := NIL;
             Hlp^.Line := '';
             FOR Num := Kx TO LENGTH ( Line ) DO
                 Hlp^.Line := Hlp^.Line + Line [ Num ];
             WHILE ( LENGTH ( Line ) >= Kx ) DO
                   DELETE ( Line, Kx, 1 );
             Old^.Line := Line;
             InsertList ( NowNumber + 1, First, Hlp );
             INC ( End_Number )
        END;
     Kx := 1;
     line_down

END; { procedure EditText.NewLine }

{----------------------------------------------------------}

PROCEDURE EditText.LineWordWap;

VAR
   OldKx : BYTE;
   Hlp : RecLinePtr;
   Src, Dest : STRING;

BEGIN
     OldKx := Kx;
     Hlp := FindLine ( NowNumber, First );
     Src := Hlp^.Line;
     FullLine ( WordWap, Src, Dest );
     IF ( ( Src = '' ) OR ( Dest = '' ) ) THEN
         FatalError ( 'Неправильно произведено выравнивание в '+
                      'LineWordWap' );
     Hlp^.Line := Src;
     Hlp := NIL;
     NEW ( Hlp );
     Hlp^.Next := NIL;
     Hlp^.Line := Dest;
     InsertList ( NowNumber + 1, First, Hlp );
     INC ( End_Number );
     Kx := OldKx;
     IF ( Kx > LENGTH ( Src ) ) THEN
       BEGIN
            Kx := Kx - LENGTH ( Src );
            Line_Down
       END;
     SingEdit := TRUE

END; { procedure EditText.LineWordWap }

{----------------------------------------------------------}

PROCEDURE EditText.ConcatUpLine;

VAR
   Line : STRING;
   Hlp : RecLinePtr;

BEGIN
     Hlp := FindLine ( NowNumber, First );
     Line := Hlp^.Line;
     DelListLine ( NowNumber, First );
     Hlp := FindLine ( NowNumber - 1, First );
     Kx := LENGTH ( Hlp^.Line );
     Hlp^.Line := Hlp^.Line + Line;
     IF ( Kx < LENGTH ( Hlp^.Line ) ) THEN
        INC ( Kx );
     SingEdit := TRUE;
     Line_Up

END; { procedure EditText.ConcatUpLine }

{----------------------------------------------------------}

PROCEDURE EditText.line_down;

VAR
   HelpSize : LONGINT;

BEGIN
     HelpSize := SizeListLine ( First );
     IF ( HelpSize > NowNumber ) THEN
        INC ( NowNumber );
     WHILE ( ( NowNumber - Number ) >= Size_Y ) DO
         INC ( Number )

END; { procedure EditText.line_down }

{----------------------------------------------------------}

PROCEDURE EditText.line_up;

VAR
   Num : LONGINT;

BEGIN
     IF ( NowNumber > 1 ) THEN
        BEGIN
             DEC ( NowNumber );
             WHILE ( NowNumber < Number ) DO
                   DEC ( Number )
        END

END; { procedure EditText.line_up }

{----------------------------------------------------------}

PROCEDURE EditText.window_up;

VAR
   Index : BYTE;

BEGIN
     FOR Index := 1 TO Size_Y - 1 DO
         line_Up

END; { procedure EditText.window_up }

{----------------------------------------------------------}

PROCEDURE EditText.DeleteLine;

          { удаление строки из текстового редактора }
VAR
   HelpSize : LONGINT;

BEGIN
     IF ( NowNumber <> 1 ) THEN
        BEGIN
             DelListLine ( NowNumber, First );
             IF ( NowNumber > SizeListLine ( First ) ) THEN
                DEC ( NowNumber );
        END
     ELSE
         BEGIN
              IF ( SizeListLine ( First ) <> 1 ) THEN
                 DelListLine ( 1, First )
              ELSE
                  First^.Line := ''
         END;
     SingEdit := TRUE

END; { procedure EditText.DeleteLine }

{----------------------------------------------------------}

PROCEDURE EditText.TextHome;

BEGIN
     SaveInf;
     FirstPtr := 1;
     Number := 1;
     NowNumber := 1;
     Kx := 1;
     LoadInf;
     Show_Inf

END; { procedure EditText.TextHome }

{----------------------------------------------------------}

PROCEDURE EditText.TextEnd;

BEGIN
     SaveInf;
     FirstPtr := TextStream^.GetSize - Size_Y + 1;
     IF ( FirstPtr < 1 ) THEN
        FirstPtr := 1;
     Number := 1;
     LoadInf;
     NowNumber := SizeListLine ( First );
     Kx := LENGTH ( FindLine ( NowNumber, First )^.Line );
     Show_Inf

END; { procedure EditText.TextEnd }

{----------------------------------------------------------}

PROCEDURE EditText.window_down;

VAR
   Index : BYTE;

BEGIN
     FOR Index := 1 TO Size_Y - 1 DO
         Line_Down

END; { procedure EditText.wind_down }

{----------------------------------------------------------}

PROCEDURE EditText.SetInsert;

          { включить режим вставки }
BEGIN
     SingInsert := TRUE

END; { procedure EditText.SetInsert }

{----------------------------------------------------------}

PROCEDURE EditText.SetReplace;

          { включить режим замещения }
BEGIN
     SingInsert := FALSE

END; { procedure EditText.SetInsert }

{----------------------------------------------------------}

DESTRUCTOR EditText.Done;

           { деинициализация обьекта }
BEGIN
     ViewText.Done

END; { dectructor EditText.Done }

{----------------------------------------------------------}

DESTRUCTOR EditText.DoneWithStream;

           { деинициализация обьекта вместе с потоком }
BEGIN
     ViewText.DoneWithStream

END; { dectructor EditText.DoneWithStream }

{----------------------------------------------------------}

END.
