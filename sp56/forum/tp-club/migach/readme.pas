
             {-------------------------------------------------}
             {               ReadMe  V 1.0                     }
             { Программа просмотра текстовых файлов            }
             {-------------------------------------------------}
             { Язык программирования Turbo Pascal V 6.0        }
             {-------------------------------------------------}
             { Дата последних изменений :  03/03/1992          }
             {-------------------------------------------------}
             { Программа предназначена для просмотра текстовых }
             { файлов типа README или README.1ST. Если         }
             { указанные файлы отсутствуют в текущем каталоге, }
             { то вызывается на просмотр файл, имя которого    }
             { указано в качестве первого параметра            }
             {-------------------------------------------------}
             { (c) 1992 Ярослав Мигач                          }
             {-------------------------------------------------}

PROGRAM ReadMe;

USES Crt, Dos, CheckFl, Def, FKey11, TWindow, LcText, ViewT;

VAR
   GWind : TextWindowPtr;
           { Титульное текстовое окно }

   ViewName : StandartString;
           { Имя просматриваемого файла }

{----------------------------------------------------------}

PROCEDURE Title;

          { Вывод титульного окна }
BEGIN
     NEW ( GWind, MakeWindow ( 1, 1, 80, 25, MAGENTA, MAGENTA ) );
     GWind^.ClearWindow ( #178, BLUE, YELLOW );
     GWind^.TypeFrameWindow ( CHR ( 219 ) );
     GWind^.SetColorSymbol  ( YELLOW );
     GWind^.FrameWindow ( 1, 1, 80, 25, 0, #196 );
     GWind^.SetColorSymbol ( WHITE );
     GWind^.XYPrint ( 3, 25, '  Enter, ESC - выход, ' + #26 +
     ', ' + #27 + ', ' + #24 + ', ' + #25 +
     ', Pg/Up, Pg/Down, Home, End  -  перемещение ' );
     GWind^.SetColorSymbol ( BLACK );
     GWind^.SetColorFon ( CYAN );
     GWind^.XYPrint ( 20, 2, 'Программа просмотра текстов  V 1.0' );
     GWind^.SetColorFon ( MAGENTA );
     GWind^.SetColorSymbol ( LIGHTCYAN );
     GWind^.XYPrint ( 25, 23,'(c) 1992, Ярослав Мигач');

END; { procedure Title }

{----------------------------------------------------------}

PROCEDURE CheckName;

          { Проверка и установка имени текстового файла }
VAR
   Fl : FILE;

BEGIN
     ViewName := '';

     ASSIGN ( Fl, 'README.1ST' );
     RESET ( Fl );
     IF ( IORESULT = 0 ) THEN
        BEGIN
             CLOSE ( Fl );
             IF ( IORESULT <> 0 ) THEN
                BEGIN
                     War ( 'Ошибка дисковой операции' );
                     EXIT
                END;
             ViewName := 'README.1ST';
             EXIT
        END;

     ASSIGN ( Fl, 'README' );
     RESET ( Fl );
     IF ( IORESULT = 0 ) THEN
        BEGIN
             CLOSE ( Fl );
             IF ( IORESULT <> 0 ) THEN
                BEGIN
                     War ( 'Ошибка дисковой операции' );
                     EXIT
                END;
             ViewName := 'README';
             EXIT
        END;

     IF ( PARAMSTR ( 1 ) = '' ) THEN
        BEGIN
             War ( 'Нет файла для просмотра' );
             EXIT
        END;

     ASSIGN ( Fl, PARAMSTR ( 1 ) );
     RESET ( Fl );
     IF ( IORESULT = 0 ) THEN
        BEGIN
             CLOSE ( Fl );
             IF ( IORESULT <> 0 ) THEN
                BEGIN
                     War ( 'Ошибка дисковой операции' );
                     EXIT
                END;
             ViewName := PARAMSTR ( 1 );
             EXIT
        END;

     War ( 'Ошибка дисковой операции' )

END; { procedure CheckName }

{----------------------------------------------------------}

PROCEDURE ShowText;

          { Показать текст в окне просмотра }
VAR
   Wind : TextWindowPtr;
        { Указатель на экземпляр текстового окна просмотра }

   Stream : LocationTextPtr;
        { Указатель на тестовый поток }

   Help : ViewText;
        { Обьект просмотра текстового списка }

   Num : LONGINT;
        { Код возврата }

BEGIN
     NEW ( Stream, Init ( $C000, ViewName ) );
     NEW ( Wind, MakeWindow ( 3,4 ,77, 21, CYAN, BLUE ) );
     Wind^.TypeFrameWindow ( #205 );
     WITH Help DO
          BEGIN
               Init ( Wind, Stream );
               SetState ( TRUE, FALSE );
               Control_Inf ( Num )
          END;
     Help.done;
     DISPOSE ( Wind, UnFrameDone ( #196 ) );
     DISPOSE ( Stream, Done )

END; { procedure ShowText }

{----------------------------------------------------------}

PROCEDURE EndWindow;

          { Закрытие титульного окна }
BEGIN
     DISPOSE ( GWind, UnFrameDone ( #205 ) );
     WINDOW ( 1, 1, 80, 25 );
     TEXTBACKGROUND ( BLACK );
     TEXTCOLOR ( LIGHTGRAY );
     GOTOXY ( 1, 25 );
     WRITELN

END; { procedure EndWindow }

{----------------------------------------------------------}

BEGIN
     CheckStart ( 'README.EXE' );
     Title;
     CheckName;
     IF ( ViewName <> '' ) THEN
        ShowText;
     EndWindow

END.
