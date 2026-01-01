PROGRAM Tests_ViewText_and_Text_Stream;

{$DEFINE DEBUGTEXT}
{$F+,O+,I-,D+,L+,R+,S+}


USES Crt, Dos, Def, TWindow, Fkey11, LcText, ViewT;

VAR
   ft : TEXT;
   number : BYTE;
   num : LONGINT;
   help : ViewText;
   Stroka : StandartString;
   Stream : LocationTextPtr;
   Index : LONGINT;
   Line : STRING;
   LnPtr : RecLinePtr;
   Wind : TextWindowPtr;

{----------------------------------------------------------}

PROCEDURE func_help;

VAR
   ch : CHAR;
   HelpWindow : TextWindow;

BEGIN
     WITH HelpWindow DO
          BEGIN
               MakeWindow ( 8, 6, 50, 18 , RED, WHITE );
               WPrint ( 2, 4, '        Пользуйтесь клавишами :'  );
               WPrint ( 2, 5, '       '+#24+' , '+#25+' , Pg/up , Pg/Dn ' );
               WPrint ( 2, 8, '             F1 и ESC ' );
               TypeFrameWindow ( #196 );
               REPEAT
                     ch := READKEY;
                     IF ( KEYPRESSED ) THEN
                        ch := READKEY
               UNTIL ( ch = #27 );
               UnFrameDone ( #196 )
          END

END; { procedure help }

{----------------------------------------------------------}

PROCEDURE ShowStream;

BEGIN
     AnyKey;
     NEW ( Wind, MakeWindow ( 4,4 ,76, 21, CYAN, BLUE ) );
     Wind^.TypeFrameWindow ( #205 );
     WITH help DO
          BEGIN
               init ( Wind, Stream );
               SetState ( TRUE, FALSE );
               set_key ( f1, func_help );
               num := 1;
               control_inf ( num )
          END;
     help.done;
     DISPOSE ( Wind, UnFrameDone ( #196 ) );
     WINDOW ( 1, 1, 80, 25 );
     TEXTBACKGROUND ( BLACK );
     TEXTCOLOR ( WHITE );
     CLRSCR

END; { procedure ShowStream }

{----------------------------------------------------------}

BEGIN
     ASSIGN ( ft, 'TESTS.TXT' );
     {$I+}
     REWRITE ( ft );
     FOR Index := 1 TO 99 DO
         WRITELN ( FT, ' Строка номер - ', Index );
     WRITE ( FT, '/****************************/' );
     CLOSE ( ft );
     CLRSCR;
     NEW ( Stream, Init ( 1024, 'TESTS.TXT' ) );
     WRITELN;
     WRITELN ( 'Попытка установить строку #', Stream^.GetSize - 1 );
     Stream^.SetLineNumber ( Stream^.GetSize - 1 );
     WRITELN ( 'Строк в потоке - ', Stream^.GetSize );
     WRITELN ( 'Отсечение предпоследней строки потока' );
     Stream^.TruncateLines;
     WRITELN ( 'Строк в потоке - ', Stream^.GetSize );
     AnyKey;
     FOR Index := Stream^.GetSize DOWNTO 1 DO
         BEGIN
              WRITELN ( 'Попытка установить строку #', Index );
              Stream^.SetLineNumber ( Index );
              WRITELN ( 'Попытка прочесть строку #', Index );
              Stream^.ReadLine ( Line );
              WRITELN ( Line );
              WRITELN;
         END;
     WRITELN;
     Index := Stream^.GetSize DIV 2;
     Stream^.SetLineNumber ( Index );
     WRITELN ( 'Строк в файле - ', Stream^.GetSize );
     WRITELN ( 'Попытка удалить строки ', Index, ', ', Index + 1 );
     Stream^.DelLines ( 2 );
     WRITELN ( 'Строк в файле - ', Stream^.GetSize );
     Index := 1;
     Stream^.SetLineNumber ( Index );
     WRITELN ( 'Попытка удалить строки ', Index, ', ', Index + 1 );
     Stream^.DelLines ( 2 );
     WRITELN ( 'Строк в файле - ', Stream^.GetSize );
     Index := Stream^.GetSize - 1;
     Stream^.SetLineNumber ( Index );
     WRITELN ( 'Попытка удалить строки ', Index, ', ', Index + 1 );
     Stream^.DelLines ( 2 );
     WRITELN ( 'Строк в файле - ', Stream^.GetSize );
     WRITELN;
     WRITELN ( 'Строк в файле - ', Stream^.GetSize );
     WRITELN ( 'Попытка добавить строку в файл' );
     Stream^.AddLine ( '/**********************/' );
     WRITELN ( 'Строк в файле - ', Stream^.GetSize );
     Stream^.SetLineNumber ( Stream^.GetSize );
     WRITELN ( 'Попытка вставить предпоследнюю строку в файл' );
     Stream^.InsLine ( ' Строка номер - 99    /INS/' );
     WRITELN ( 'Строк в файле - ', Stream^.GetSize );
     WRITELN ( 'Попытка вставить первые 2 строки в файле' );
     Stream^.SetLineNumber ( 1 );
     Stream^.InsLine ( ' Строка номер - 2    /INS/' );
     Stream^.SetLineNumber ( 1 );
     Stream^.InsLine ( ' Строка номер - 1    /INS/' );
     WRITELN ( 'Строк в файле - ', Stream^.GetSize );
     WRITELN;
     Stream^.SetLineNumber ( 2 );
     WRITELN ( 'Строк в файле - ', Stream^.GetSize );
     WRITELN ( 'Попытка прочесть 70 первых строк потока' );
     AnyKey;
     LnPtr := NIL;
     Stream^.ReadLines ( 70, LnPtr );
     WRITELN ( 'Попытка удалить 70 первых строк потока' );
     AnyKey;
     Stream^.SetLineNumber ( 2 );
     Stream^.DelLines ( 70 );
     WRITELN ( 'Строк в файле - ', Stream^.GetSize );
     Stream^.ReSetStream;
     WRITELN ( 'Строк в файле после переустановки - ', Stream^.GetSize );
     Stream^.SetLineNumber ( Stream^.GetSize );
     Stream^.ReadLine ( Line );
     WRITE ( Line );
     AnyKey;
     WRITELN ( 'Попытка восстановить прежде удаленные стороки' );
     Stream^.SetLineNumber ( 2 );
     Stream^.InsertLines ( 70, LnPtr );
     WRITELN ( 'Строк в файле - ', Stream^.GetSize );
     Stream^.ReSetStream;
     WRITELN ( 'Строк в файле после переустановки - ', Stream^.GetSize );
     AnyKey;
     WRITELN ( 'Добавим к файлу 70 строк' );
     Stream^.Addlines ( 70, LnPtr );
     WRITELN ( 'Строк в файле - ', Stream^.GetSize );
     Stream^.ReSetStream;
     WRITELN ( 'Строк в файле после переустановки - ', Stream^.GetSize );
     ClearListRecLine ( LnPtr );
     WRITELN ( 'Удаляем последние 70 строк' );
     Stream^.SetLineNumber ( Stream^.GetSize - 70 );
     Stream^.DelLines ( 70 );
     WRITELN ( 'Строк в файле - ', Stream^.GetSize );
     Stream^.ReSetStream;
     WRITELN ( 'Строк в файле после переустановки - ', Stream^.GetSize );
     ShowStream;
     DISPOSE ( Stream, Done )

END.