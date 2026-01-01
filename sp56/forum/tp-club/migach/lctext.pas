

         {----------------------------------------------------}
         {   Модуль LcText  V 1.4    пакета  TURBO SUPPORT    }
         {     Язык программирования Turbo Pascal  V 6.0      }
         {----------------------------------------------------}
         { Дата последних изменений :  14/05/1991             }
         {----------------------------------------------------}
         { Модуль предназначен для обработки текстовых файлов }
         {          на уровне потоков ввода/вывода            }
         {----------------------------------------------------}
         { (c) 1991, Мигач Ярослав                            }
         {----------------------------------------------------}

UNIT LcText;

{$IFDEF DEBUGTEXT}
      {$D+,L+,R+,S+}
{$ELSE}
      {$D-,L-,R-,S-}
{$ENDIF}

{$F+,O+,I-,V-,B-,A+}

INTERFACE

USES Dos, Crt, Def;

TYPE
     RecLinePtr = ^RecLine;
                { Указатель на элемент строкового списка }


     RecLine = RECORD  { элемент строкового списка }

                     Line : STRING;
                            { строка списка }
                     Next : RecLinePtr
                            { указатель на следующий элеметн списка }

               END; { record RecLine }

     TypeBuffer = ARRAY [ 0..$FFFE ] OF BYTE;
                  { тип буфера для хранения и обработки части текстового }
                  {                     файла                            }

     ErrorProcedure = PROCEDURE ( Err : BYTE );
                  { процедура выдачи сообщения об ошибке }

{----------------------------------------------------------}

     LocationTextPtr = ^LocationText;

     LocationText = OBJECT { поток ввода/вывода для обработки текста }

                    BufferPtr : ^TypeBuffer;
                            { указатель на буфер хранения и обработки }
                            { текстового файла                        }

                    SizeBuf : WORD;
                             { размер отведенного буфера в байтах }

                    SizeFact : WORD;
                             { количество информации размещенной в буфере }

                    PointBeginBuf : LONGINT;
                    DublePointBeginBuf : LONGINT;
                             { индекс начала буфера в файле }

                    NowLinePtr : WORD;
                    DubleNowLinePtr : WORD;
                             { указатель на текущую строку в буфере }

                    NowLineNumber : LONGINT;
                    DubleNowLineNumber : LONGINT;
                             { номер текущей строки }

                    MaxLineNumber : LONGINT;
                             { количество строк в текстовом файле }

                    DubleKeyEOF : BOOLEAN;
                    KeyEOF : BOOLEAN;
                             { признак выхода указателя за границу потока }

                    SingState : BOOLEAN;
                              { признак сохраненного состояния }

                    Fl : FILE;
                             { файл потока }

                    NumError : BYTE;
                             { код ошибки операции }

                    ErrorProc : ErrorProcedure;
                             { процедура выдачи сообщения об ошибке }

                    SingWrite : BOOLEAN;
                             { признак записи текущего блока }

                    SingStreamEOF : BOOLEAN;
                             { признак окончания потока }

                    CONSTRUCTOR Init ( SzBuf : WORD; Name : STRING );
                             { Инициализация обьекта, резервирования буфера }
                             { и открытие файла                             }

                    PROCEDURE ReSetStream;
                              { Начальная установка текстового потока }

                    FUNCTION GetNumberError : BYTE;
                             { получит код ошибки  }

                    PROCEDURE SetLineNumber ( Num : LONGINT ); VIRTUAL;
                             { установить номер обрабатываемой строки       }

                    FUNCTION GetLineNumber : LONGINT;
                             { получить номер обрабатываемой строки         }

                    FUNCTION GetSize : LONGINT;
                             { получить общее количество строк в текстовом  }
                             { потоке                                       }

                    FUNCTION GetCurrentChar : CHAR; VIRTUAL;
                              { возвращает текущий символ потока }

                    PROCEDURE SetCurrentChar ( Ch : CHAR ); VIRTUAL;
                              { устанавливает текущий символ потока }

                    PROCEDURE NextChar;
                              { осуществляет переход к последующему символу }

                    PROCEDURE PrevChar;
                              { осуществляет переход к предыдущему символу }

                    FUNCTION EofText : BOOLEAN;
                             { получить признак завершения потока           }

                    PROCEDURE TruncateLines;
                              { отсекает строки из по потока начиная с }
                              {              текущей                   }

                    PROCEDURE DelLines ( Quantity : LONGINT ); VIRTUAL;
                             { удалить из потока заданное количество строк  }
                             { начиная с текущей                            }

                    PROCEDURE ReadLines ( Quantity : LONGINT;
                                          VAR LnPtr : RecLinePtr ); VIRTUAL;
                              { создает список из заданного количества      }
                              { строк загружая их из потока                 }

                    PROCEDURE InsertLines ( Quantity : LONGINT;
                                            LnPtr : RecLinePtr ); VIRTUAL;
                              { вставляет заданное количество строк из      }
                              { списка в поток                              }

                    PROCEDURE AddLines ( Quantity : LONGINT;
                                            LnPtr : RecLinePtr ); VIRTUAL;
                              { добавляет заданное количество строк из      }
                              { списка в поток                              }

                    PROCEDURE ReplaseLines ( DelQuantity : LONGINT;
                                             InsQuantity : LONGINT;
                                             LnPtr : RecLinePtr ); VIRTUAL;
                              { заменяет заданное количество строк текста в }
                              { потоке                                      }

                    PROCEDURE ReadLine ( VAR Line : STRING );
                              { загружает одну строку из потока             }

                    PROCEDURE InsLine ( Line : STRING );
                              { вставляет одну строку в поток              }

                    PROCEDURE DelLine;
                              { удаляет одну строку из потока              }

                    PROCEDURE WriteLine ( Line : STRING );
                              { пишет одну строку в поток                  }

                    PROCEDURE AddLine ( Line : STRING );
                              { добавляет строку в поток }

                    PROCEDURE SetErrorProc ( Param : ErrorProcedure );
                              { установить процедуру обработки ошибочных }
                              { ситуаций                                 }

                    PROCEDURE SaveState; VIRTUAL;
                              { сохранить текущее состояние }

                    PROCEDURE RestoreState; VIRTUAL;
                              { восстановить сохраненнге ранее состояние }

                    DESTRUCTOR Done; VIRTUAL;
                              { закрывает файл, уничтожает буфер и         }
                              { деинициализирует обьект                    }

                    {$IFDEF DEBUGTEXT}
                    FUNCTION CheckBeginLine : BOOLEAN;
                              { Функция проверки установки указателя }
                              {      на начало текущей строки        }

                    FUNCTION CheckLineNumber : BOOLEAN;
                              { Функция проверки на соответствие      }
                              { установленоой строки заданной позиции }

                    FUNCTION CheckLend : BOOLEAN;
                              { Функция контроля длины потока }
                    {$ENDIF}

                    END; { object LocationText }

{----------------------------------------------------------}

     LocationListTextPtr = ^LocationListText;

     LocationListText = OBJECT   ( LocationText )
                    { поток ввода/вывода для обработки спискового текста }

                    List : RecLinePtr;
                           { список строк текста }

                    MaxLine : LONGINT;
                           { максимальное количество строк в списке }


                    CONSTRUCTOR Init ( LnPtr : RecLinePtr; Max : LONGINT );
                             { Инициализация обьекта, резервирования буфера }
                             { и открытие файла                             }

                    PROCEDURE ReSetStream;
                              { Начальная установка текстового потока }

                    FUNCTION GetListPtr : RecLinePtr;
                             { получить указатель на список потока }

                    PROCEDURE SetLineNumber ( Num : LONGINT ); VIRTUAL;
                             { установить номер обрабатываемой строки       }

                    PROCEDURE TruncateLines;
                              { отсекает строки из по потока начиная с }
                              {              текущей                   }

                    PROCEDURE DelLines ( Quantity : LONGINT ); VIRTUAL;
                             { удалить из потока заданное количество строк  }
                             { начиная с текущей                            }

                    PROCEDURE ReadLines ( Quantity : LONGINT;
                                          VAR LnPtr : RecLinePtr ); VIRTUAL;
                              { создает список из заданного количества      }
                              { строк загружая их из потока                 }

                    PROCEDURE InsertLines ( Quantity : LONGINT;
                                            LnPtr : RecLinePtr ); VIRTUAL;
                              { вставляет заданное количество строк из      }
                              { списка в поток                              }

                    PROCEDURE AddLines ( Quantity : LONGINT;
                                            LnPtr : RecLinePtr ); VIRTUAL;
                              { добавляет заданное количество строк из      }
                              { списка в поток                              }

                    PROCEDURE SaveState; VIRTUAL;
                              { сохранить текущее состояние }

                    PROCEDURE RestoreState; VIRTUAL;
                              { восстановить сохраненнге ранее состояние }

                    DESTRUCTOR Done; VIRTUAL;
                              { деинициализирует обьект                    }

                    END; { object LocationListText }

{----------------------------------------------------------}

     LocationProtectTextPtr = ^LocationProtectText;

     LocationProtectText = OBJECT   ( LocationText )
                    { поток ввода/вывода для обработки защищенного текста }

                    Password : BYTE;
                           { константа защиты }

                    CONSTRUCTOR Init ( SzBuf : WORD; Name : STRING;
                                       Ps : BYTE );
                             { Инициализация обьекта, резервирования буфера }
                             { и открытие файла                             }

                    FUNCTION GetCurrentChar : CHAR; VIRTUAL;
                              { возвращает текущий символ потока }

                    PROCEDURE SetCurrentChar ( Ch : CHAR ); VIRTUAL;
                              { устанавливает текущий символ потока }

                    PROCEDURE SetPassword ( Ps : BYTE );
                             { Установка нового пароля }

                    END; { object LocationProtectText }

{----------------------------------------------------------}

PROCEDURE NulErrProc ( Err : BYTE );
PROCEDURE ClearListRecLine ( VAR LnPtr : RecLinePtr );
FUNCTION FindLine ( Quantity : LONGINT; LnPtr : RecLinePtr ) : RecLinePtr;
FUNCTION SizeListLine ( LnPtr : RecLinePtr ) : LONGINT;
PROCEDURE DelListLine ( Number : LONGINT; VAR LnPtr : RecLinePtr );
PROCEDURE AddListLine ( VAR LnPtr, InsPtr : RecLinePtr );
PROCEDURE AddListOneLine ( VAR Lst : RecLinePtr; Line : STRING );
PROCEDURE InsertList ( Number : LONGINT; VAR LnPtr, InsPtr : RecLinePtr );
FUNCTION FullSizeList ( LnPtr : RecLinePtr ) : LONGINT;
FUNCTION FullSizeQLines ( Quantity : LONGINT; LnPtr : RecLinePtr ) : LONGINT;
PROCEDURE TruncateListLine ( MaxLine : LONGINT; VAR LnPtr : RecLinePtr );
FUNCTION BuildLineList ( Line : STRING;
                         Next : RecLinePtr ) : RecLinePtr;
FUNCTION GetCurrentDir : STRING;
PROCEDURE SwapLines ( Num1, Num2 : LONGINT; VAR List : RecLinePtr );
FUNCTION BuildDirList ( DirPath : STRING ) : RecLinePtr;
FUNCTION SortList ( List : RecLinePtr ) : RecLinePtr;
FUNCTION SortDirList ( List : RecLinePtr ) : RecLinePtr;
FUNCTION CopyListLine ( Quantity : LONGINT; LnPtr : RecLinePtr ) : RecLinePtr;

IMPLEMENTATION

{----------------------------------------------------------}

PROCEDURE FatalError ( Line : STRING );

BEGIN
     WINDOW ( 1, 1, 80, 25 );
     TEXTBACKGROUND ( BLACK );
     TEXTCOLOR ( LIGHTGRAY );
     CLRSCR;
     WRITELN ( #07 );
     WRITELN ( 'Критический сбой в обьекте LocationText' );
     WRITELN ( Line );
     WRITELN ( 'Выполнение программы прекращается,'
              ,' обращайтесь к программисту' );
     HALT ( 1 )

END; { procedure FatalError }

{----------------------------------------------------------}

{$IFDEF DEBUGTEXT}

PROCEDURE ErrorInProc ( Line : STRING );

BEGIN
     WINDOW ( 1, 1, 80, 25 );
     TEXTBACKGROUND ( BLACK );
     TEXTCOLOR ( LIGHTGRAY );
     CLRSCR;
     WRITELN ( #07 );
     WRITELN ( 'Критический сбой в процедуре модуля LcText' );
     WRITELN ( Line );
     WRITELN ( 'Выполнение программы прекращается,'
              ,' обращайтесь к программисту' );
     HALT ( 1 )

END; { procedure ErrorInProc }

{$ENDIF}

{----------------------------------------------------------}

PROCEDURE NulErrProc ( Err : BYTE );

{$IFDEF DEBUGTEXT}
VAR
   HelpS : StandartString;
{$ENDIF}

BEGIN
     {$IFDEF DEBUGTEXT}
     STR ( Err, HelpS );
     FatalError ( 'Вызвана процедура обработки ошибок с кодом #' + HelpS )
     {$ENDIF}

END; { procedure NulErrProc }

{----------------------------------------------------------}

FUNCTION GetCurrentDir : STRING;

VAR
   DirPath : STRING;

BEGIN
     GETDIR ( 0, dirpath );
     IF ( DirPath [ LENGTH ( dirpath ) ] <> '\' ) THEN
        dirpath := CONCAT ( dirpath, '\' );
     GetCurrentDir := DirPath

END; { function GetCurrentDir }

{----------------------------------------------------------}

PROCEDURE ClearListRecLine ( VAR LnPtr : RecLinePtr );

          { процедура очистки строкового списка }
VAR
   Hlp : RecLinePtr;

BEGIN
     WHILE ( LnPtr <> NIL ) DO
           BEGIN
                Hlp := LnPtr^.Next;
                DISPOSE ( LnPtr );
                LnPtr := Hlp
           END

END; { procedure ClearListRecLine }

{----------------------------------------------------------}

FUNCTION FindLine ( Quantity : LONGINT; LnPtr : RecLinePtr ) : RecLinePtr;

        { возвращает указатель на заданную запись списка }
BEGIN
     WHILE ( ( Quantity > 1 ) AND ( LnPtr <> NIL ) ) DO
           BEGIN
                DEC ( Quantity );
                LnPtr := LnPtr^.Next
           END;
     FindLine := LnPtr

END; { function FindLine }

{----------------------------------------------------------}

FUNCTION SizeListLine ( LnPtr : RecLinePtr ) : LONGINT;

         { возвращает количество сторок в списке }
VAR
   Quantity : LONGINT;

BEGIN
     Quantity := 0;
     WHILE ( LnPtr <> NIL ) DO
           BEGIN
                INC ( Quantity );
                LnPtr := LnPtr^.Next
           END;
     SizeListLine := Quantity

END; { function SizeListLine }

{----------------------------------------------------------}

PROCEDURE DelListLine ( Number : LONGINT; VAR LnPtr : RecLinePtr );

         { удаляет заданную строку из списка }
VAR
   Prev, Now, Next : RecLinePtr;

BEGIN
     Now := FindLine ( Number, LnPtr );
     IF ( LnPtr = NIL ) THEN
        EXIT;
     IF ( Number = 1 ) THEN
        BEGIN
             Now := LnPtr;
             LnPtr := LnPtr^.Next;
             DISPOSE ( Now );
             EXIT
        END;
     Prev := FindLine ( Number - 1, LnPtr );
     Now := Prev^.Next;
     IF ( Now = NIL ) THEN
        EXIT;
     Next := Now^.Next;
     DISPOSE ( Now );
     Prev^.Next := Next

END; { procedure DelLine }

{----------------------------------------------------------}

PROCEDURE AddListLine ( VAR LnPtr, InsPtr : RecLinePtr );

VAR
   Hlp : RecLinePtr;

BEGIN
     IF ( InsPtr = NIL ) THEN
        EXIT;
     IF ( LnPtr = NIL ) THEN
        BEGIN
             LnPtr := InsPtr;
             InsPtr := NIL;
             EXIT
        END;
     IF ( LnPtr^.Next = NIL ) THEN
        BEGIN
             LnPtr^.Next := InsPtr;
             InsPtr := NIL;
             EXIT
        END;
     Hlp := FindLine ( SizeListLine ( LnPtr ), LnPtr );
     IF ( Hlp^.Next <> NIL ) THEN
        FatalError ( 'Ошибка в процедуре AddListLine' );
     Hlp^.Next := InsPtr;
     InsPtr := NIL

END; { procedure AddListLine }

{----------------------------------------------------------}

PROCEDURE AddListOneLine ( VAR Lst : RecLinePtr; Line : STRING );

          { Добавить в список одну строку }
VAR
   Hlp : RecLinePtr;

BEGIN
     NEW ( Hlp );
     Hlp^.Next := NIL;
     Hlp^.Line := Line;
     AddListLine ( Lst, Hlp )

END; { procedure AddListOneLine }

{----------------------------------------------------------}

FUNCTION CopyListLine ( Quantity : LONGINT; LnPtr : RecLinePtr ) : RecLinePtr;

         { Передает указатель на дубликат списка }
VAR
   Hlp, First : RecLinePtr;

BEGIN
     First := NIL;
     WHILE ( ( Quantity > 0 ) AND ( LnPtr <> NIL ) ) DO
           BEGIN
                DEC ( Quantity );
                IF ( First = NIL ) THEN
                   BEGIN
                        NEW ( First );
                        First^.Line := LnPtr^.Line;
                        First^.Next := NIL;
                        Hlp := First
                   END
                ELSE
                    BEGIN
                         NEW ( Hlp^.Next );
                         Hlp := Hlp^.Next;
                         Hlp^.Line := LnPtr^.Line;
                         Hlp^.Next := NIL
                    END;
                LnPtr := LnPtr^.Next
           END;
     CopyListLine := First

END; { function CopyListLine }

{----------------------------------------------------------}

PROCEDURE InsertList ( Number : LONGINT; VAR LnPtr, InsPtr : RecLinePtr );

          { вставить подсписок в список начиная со строки с }
          {               заданным номером                  }
VAR
   HlpRes, HlpPrev : RecLinePtr;
   HelpInsPtr : RecLinePtr;
   NumIns : LONGINT;
   NextLnPtr : RecLinePtr;

BEGIN
     IF ( InsPtr = NIL ) THEN
        EXIT;
     IF ( LnPtr = NIL ) THEN
        BEGIN
             LnPtr := InsPtr;
             InsPtr := NIL;
             EXIT
        END;
     IF ( Number = 1 ) THEN
        BEGIN
             AddListLine ( InsPtr, LnPtr );
             LnPtr := InsPtr;
             InsPtr := NIL;
             EXIT
        END;
     IF ( Number > SizeListLine ( LnPtr ) ) THEN
        BEGIN
             AddListLine ( LnPtr, InsPtr );
             EXIT
        END;
     HlpPrev := FindLine ( Number - 1, LnPtr );
     HlpRes := HlpPrev^.Next;
     HlpPrev^.Next := NIL;
     AddListLine ( LnPtr, InsPtr );
     AddListLine ( LnPtr, HlpRes )

END; { procedure InsertList }

{----------------------------------------------------------}

FUNCTION FullSizeList ( LnPtr : RecLinePtr ) : LONGINT;

         { размер списка строк в байтах }
VAR
   Size : LONGINT;

BEGIN
     Size := 0;
     WHILE ( LnPtr <> NIL ) DO
           BEGIN
                Size := Size + LENGTH ( LnPtr^.Line ) + 2;
                LnPtr := LnPtr^.Next
           END;
     FullSizeList := Size

END; { function FullSizeList }

{----------------------------------------------------------}

FUNCTION FullSizeQLines ( Quantity : LONGINT; LnPtr : RecLinePtr ) : LONGINT;

         { размер списка из нескольких строк в байтах }
VAR
   Size : LONGINT;

BEGIN
     Size := 0;
     WHILE ( ( LnPtr <> NIL ) AND ( Quantity > 0 ) ) DO
           BEGIN
                Size := Size + LENGTH ( LnPtr^.Line ) + 2;
                LnPtr := LnPtr^.Next;
                DEC ( Quantity )
           END;
     FullSizeQLines := Size

END; { function FullSizeQLines }

{----------------------------------------------------------}

PROCEDURE TruncateListLine ( MaxLine : LONGINT; VAR LnPtr : RecLinePtr );

       { усекает список строк до заданного размера }
BEGIN
     WHILE ( SizeListLine ( LnPtr ) > MaxLine ) DO
           DelListLine ( SizeListLine ( LnPtr ), LnPtr )

END; { procedure TruncateListLine }

{----------------------------------------------------------}

FUNCTION BuildLineList ( Line : STRING;
                         Next : RecLinePtr ) : RecLinePtr;

         { построить список строк }
VAR
   Hlp : RecLinePtr;

BEGIN
     NEW ( Hlp );
     Hlp^.Line := Line;
     Hlp^.Next := Next;
     BuildLineList := Hlp

END; { function BuildLineList }

{----------------------------------------------------------}

FUNCTION BuildDirList ( DirPath : STRING ) : RecLinePtr;

VAR
   Line, Stroka : STRING;
   Catalog : SEARCHREC;
   Hlp : RecLinePtr;
   Line2 : STRING;
   First : RecLinePtr;

BEGIN
     Stroka := DirPath + '*.*';
     First := NIL;
     FINDFIRST ( Stroka, ANYFILE  - VOLUMEID, Catalog );
     IF ( DOSERROR <> 0 ) THEN
        BEGIN
             AddListOneLine ( First, 'Нет файлов на диске ' );
             BuildDirList := First;
             EXIT
        END;
     IF ( Catalog.Name = '.' ) THEN
        Line := '..'
     ELSE
         Line := Catalog.Name;
     WHILE ( LENGTH ( Line ) < 14 ) DO
           Line := Line + ' ';
     IF ( ( Catalog.Attr AND Directory ) <> 0 ) THEN
        Line := Line +'< SUB-DIR >'
     ELSE
         BEGIN
              STR ( Catalog.Size, Line2 );
              Line := Line + Line2
         END;
     AddListOneLine ( First, Line );
     WHILE ( DOSERROR = 0 ) DO
         BEGIN
              FINDNEXT ( Catalog );
              IF ( ( Catalog.Name <> '..' ) AND ( DOSERROR = 0 ) ) THEN
                 BEGIN
                      Line := Catalog.Name;
                      WHILE ( LENGTH ( Line ) < 14 ) DO
                            Line := Line + ' ';
                      IF ( ( Catalog.Attr AND Directory ) <> 0 ) THEN
                         Line := Line +'< SUB-DIR >'
                      ELSE
                          BEGIN
                               STR ( Catalog.Size, Line2 );
                               Line := Line + Line2
                          END;
                      AddListOneLine ( First, Line )
                 END
         END;
     BuildDirList := First

END; { function BuildDirList }

{----------------------------------------------------------}

PROCEDURE SwapLines ( Num1, Num2 : LONGINT; VAR List : RecLinePtr );

          { Обмен местами двух строк в списке }
VAR
   Hlp1, Hlp2 : RecLinePtr;

BEGIN
     NEW ( Hlp1 );
     Hlp1^.Line := FindLine ( Num1, List )^.Line;
     Hlp1^.Next := NIL;
     NEW ( Hlp2 );
     Hlp2^.Line := FindLine ( Num2, List )^.Line;
     Hlp2^.Next := NIL;
     DelListLine ( Num1, List );
     InsertList ( Num1, List, Hlp2 );
     DelListLine ( Num2, List );
     InsertList ( Num2, List, Hlp1 )

END; { procedure SwapLines }

{----------------------------------------------------------}

FUNCTION SortDirList ( List : RecLinePtr ) : RecLinePtr;

        { Сортировка имен файлов в списке директория }
VAR
   Quantity : LONGINT;
   Index : LONGINT;
   IndexFind : LONGINT;
   FindNumber : LONGINT;
   RecHlp1, RecHlp2 : RecLinePtr;
   Line1 : STRING;
   NewList : RecLinePtr;

FUNCTION EqLines ( VAR Line2 : STRING ) : BOOLEAN;

         { Признак обмена }
VAR
   Hlp : BYTE;

BEGIN
     EqLines := TRUE;
     IF ( ( POS ( '< SUB-DIR >', Line1 ) = 0 ) AND
          ( POS ( '< SUB-DIR >', Line2 ) <> 0 ) ) THEN
        EXIT;
     IF ( ( POS ( '< SUB-DIR >', Line1 ) <> 0 ) AND
         ( POS ( '< SUB-DIR >', Line2 ) = 0 ) ) THEN
        BEGIN
             EqLines := FALSE;
             EXIT
        END;

      Hlp := 1;
      WHILE ( Line1 [ Hlp ] <> ' ' ) DO
            BEGIN
                 IF ( Line1 [ Hlp ] > Line2 [ Hlp ] ) THEN
                    EXIT;
                 IF ( Line1 [ Hlp ] < Line2 [ Hlp ] ) THEN
                    BEGIN
                         EqLines := FALSE;
                         EXIT
                    END;
                 INC ( Hlp )
            END;
      EqLines := FALSE

END; { Function EdLines }

BEGIN
     NewList := NIL;
     Quantity := SizeListLine ( List );
     RecHlp1 := List;
     FOR IndexFind := 1 TO Quantity DO
         BEGIN
              FindNumber := 1;
              Line1 := List^.Line;
              RecHlp1 := List;
              RecHlp2 := RecHlp1^.Next;
              FOR Index := 2 TO SizeListLine ( List ) DO
                  BEGIN
                       IF ( EqLines (  RecHlp2^.Line ) ) THEN
                          BEGIN
                               Line1 := RecHlp2^.Line;
                               FindNumber := Index
                          END;
                       RecHlp2 := RecHlp2^.Next
                  END;
              AddListOneLine ( NewList, Line1 );
              DelListLine ( FindNumber, List );
         END;
     SortDirList := NewList

END; { function SortDirList }

{----------------------------------------------------------}

FUNCTION SortList ( List : RecLinePtr ) : RecLinePtr;

        { Сортировка строкового списка }
VAR
   Quantity : LONGINT;
   Index : LONGINT;
   IndexFind : LONGINT;
   FindNumber : LONGINT;
   RecHlp1, RecHlp2 : RecLinePtr;
   Line1 : STRING;
   NewList : RecLinePtr;

FUNCTION EqLines ( VAR Line2 : STRING ) : BOOLEAN;

         { Признак обмена }
VAR
   Hlp : BYTE;

BEGIN
     EqLines := TRUE;
      Hlp := 1;
      WHILE ( Line1 [ Hlp ] <> ' ' ) DO
            BEGIN
                 IF ( Line1 [ Hlp ] > Line2 [ Hlp ] ) THEN
                    EXIT;
                 IF ( Line1 [ Hlp ] < Line2 [ Hlp ] ) THEN
                    BEGIN
                         EqLines := FALSE;
                         EXIT
                    END;
                 INC ( Hlp )
            END;
      EqLines := FALSE

END; { Function EdLines }

BEGIN
     NewList := NIL;
     Quantity := SizeListLine ( List );
     RecHlp1 := List;
     FOR IndexFind := 1 TO Quantity DO
         BEGIN
              FindNumber := 1;
              Line1 := List^.Line;
              RecHlp1 := List;
              RecHlp2 := RecHlp1^.Next;
              FOR Index := 2 TO SizeListLine ( List ) DO
                  BEGIN
                       IF ( EqLines (  RecHlp2^.Line ) ) THEN
                          BEGIN
                               Line1 := RecHlp2^.Line;
                               FindNumber := Index
                          END;
                       RecHlp2 := RecHlp2^.Next
                  END;
              AddListOneLine ( NewList, Line1 );
              DelListLine ( FindNumber, List );
         END;
     SortList := NewList

END; { function SortList }

{----------------------------------------------------------}

{$IFDEF DEBUGTEXT}

FUNCTION LocationText.CheckBeginLine : BOOLEAN;

         { Функция проверки установки указателя }
         {      на начало текущей строки        }
BEGIN
     CheckBeginLine := TRUE;
     IF ( NowLineNumber <> 1 ) THEN
        BEGIN
             IF ( NowLineNumber <> MaxLineNumber ) THEN
                PrevChar
             ELSE
                 IF ( GetCurrentChar = #$0A ) THEN
                    BEGIN
                         IF ( NOT KeyEOF ) THEN
                            BEGIN
                                 NextChar;
                                 IF ( NOT KeyEOF ) THEN
                                    BEGIN
                                         CheckBeginLine := FALSE;
                                         EXIT
                                    END;
                                 KeyEOF := FALSE
                            END
                    END
                 ELSE
                     PrevChar;
             IF ( GetCurrentChar <> #$0A ) THEN
                CheckBeginLine := FALSE;
             PrevChar;
             IF ( GetCurrentChar <> #$0D ) THEN
                CheckBeginLine := FALSE;
             NextChar;
             NextChar
        END
     ELSE
         BEGIN
              PrevChar;
              CheckBeginLine := KeyEOF;
              KeyEOF := FALSE
         END

END; { function LocationText.CheckBeginLine }

{$ENDIF}

{----------------------------------------------------------}

{$IFDEF DEBUGTEXT}

FUNCTION LocationText.CheckLineNumber : BOOLEAN;

         { Функция проверки на соответствие      }
         { установленоой строки заданной позиции }
VAR
   SaveBufferPtr : LONGINT;
   SaveLinePtr : WORD;
   LineNumber : LONGINT;

BEGIN
     CheckLineNumber := TRUE;
     IF ( NowLineNumber = 1 ) THEN
        EXIT;
     LineNumber := NowLineNumber;
     SaveBufferPtr := PointBeginBuf;
     SaveLinePtr := NowLinePtr;

     { предполагается, что процедура SetLineNumber }
     {             работает корректно              }

     SetLineNumber ( 1 );
     SetLineNumber ( LineNumber );
     IF ( SaveBufferPtr <> PointBeginBuf ) THEN
        CheckLineNumber := FALSE;
     IF ( SaveLinePtr <> NowLinePtr ) THEN
        CheckLineNumber := FALSE

END; { function LocationText.CheckLineNumber }

{$ENDIF}

{----------------------------------------------------------}

{$IFDEF DEBUGTEXT}

FUNCTION LocationText.CheckLend : BOOLEAN;

         { Функция контроля длины потока }
VAR
   OldSize : LONGINT;
   OldLineNumber : LONGINT;

BEGIN
     OldLineNumber := NowLineNumber;
     OldSize := MaxLineNumber;
     ReSetStream;
     CheckLend := ( MaxLineNumber = OldSize );
     SetLineNumber ( OldLineNumber )

END; { function LocationText.CheckLend }

{$ENDIF}

{----------------------------------------------------------}

CONSTRUCTOR LocationText.Init ( SzBuf : WORD; Name : STRING );

            { Инициализация обьекта, резервирования буфера }
            { и открытие файла                             }
VAR
   Index : WORD;
           { индексная переменная }

   GetByte : CHAR;
           { вспомогательный символ }

BEGIN
           { Начальные установки }

     ErrorProc := NulErrProc;
     SizeBuf := SzBuf;
     BufferPtr := NIL;
     SizeFact := 0;
     NowLinePtr := 0;
     NowLineNumber := 1;
     MaxLineNumber := 1;
     PointBeginBuf := 0;
     SingWrite := FALSE;
     NumError := 0;
     SingStreamEOF := FALSE;
     KeyEOF :=FALSE;
     IF ( SizeBuf < 512 ) THEN
        SizeBuf := 512;
     IF ( Name = '' ) THEN
        BEGIN
             FAIL;
             EXIT
        END;
     SaveState;

           { создание буфера }

     GETMEM ( BufferPtr, SizeBuf );
     IF ( BufferPtr = NIL ) THEN
        BEGIN
             FAIL;
             EXIT
        END;

           { открытие файла }

     ASSIGN ( Fl, Name );
     RESET ( Fl, 1 );
     IF ( IORESULT <> 0 ) THEN
        BEGIN
             REWRITE ( Fl, 1 );
             IF ( IORESULT <> 0 ) THEN
                BEGIN
                     FREEMEM ( BufferPtr, SizeBuf );
                     FAIL;
                     EXIT
                END;
             EXIT
        END;
     IF ( FILESIZE ( Fl ) = 0 ) THEN
        BEGIN
             SingStreamEOF := TRUE;
             EXIT
        END;

     ReSetStream

END; { constructor LocationText.Init }

{----------------------------------------------------------}

PROCEDURE LocationText.ReSetStream;

          { начальная установка текстового потока }
VAR
   GetByte : CHAR;
             { вспомогательный символ }
BEGIN
     NumError := 0;
     NowLinePtr := 0;
     PointBeginBuf := 0;
     MaxLineNumber := 1;
     SingStreamEOF := FALSE;

           { установка на начало файла }

     SEEK ( Fl, 0 );
     BLOCKREAD ( Fl, BufferPtr^, SizeBuf, SizeFact );
     IF ( IORESULT <> 0 ) THEN
        BEGIN
             NumError := 1;
             ErrorProc ( NumError );
             EXIT
        END;

           { посчет количества строк в файле }

     REPEAT
           GetByte := GetCurrentChar;
           NextChar;
           IF ( ( GetCurrentChar = #$0A ) AND ( GetByte = #$0D ) ) THEN
              INC ( MaxLineNumber );
           IF ( NumError <> 0 ) THEN
              EXIT;
     UNTIL ( KeyEOF );
     KeyEOF := FALSE;

           { установка на начало файла }

     SEEK ( Fl, 0 );
     BLOCKREAD ( Fl, BufferPtr^, SizeBuf, SizeFact );
     IF ( IORESULT <> 0 ) THEN
        BEGIN
             NumError := 1;
             ErrorProc ( NumError );
             EXIT
        END;
     NowLinePtr := 0;
     PointBeginBuf := 0;
     SingStreamEOF := FALSE;
     NowLineNumber := 1

END; { procedure LocationText.ReSetStream }

{----------------------------------------------------------}

FUNCTION LocationText.GetNumberError : BYTE;

         { получит код ошибки   }
BEGIN
     GetNumberError := NumError;
     NumError := 0

END; { function LocationText.GetNumberError }

{----------------------------------------------------------}

FUNCTION LocationText.GetCurrentChar : CHAR;

         { возвращает текущий символ потока }
BEGIN
     GetCurrentChar := CHR ( BufferPtr^ [ NowLinePtr ] )

END; { function LocationText.GetCurrentChar }

{----------------------------------------------------------}

PROCEDURE LocationText.SetCurrentChar ( Ch : CHAR );

          { устанавливает текущий символ потока }
BEGIN
     BufferPtr^ [ NowLinePtr ] := ORD ( Ch )

END; { procedure LocationText.SetCurrentChar }

{----------------------------------------------------------}

PROCEDURE LocationText.NextChar;

          { осуществляет переход к последующему символу }
VAR
   HelpS : StandartString;

BEGIN
     KeyEOF := FALSE;
     IF ( SizeFact = 0 ) THEN
        BEGIN
             KeyEOF := TRUE;
             EXIT
        END;
     IF ( NowLinePtr < ( SizeFact - 1 ) ) THEN
        BEGIN
             INC ( NowLinePtr );
             EXIT
        END;
     IF ( SizeFact < SizeBuf ) THEN
        BEGIN
             KeyEOF := TRUE;
             EXIT
        END;
     IF ( NumError <> 0 ) THEN
        BEGIN
             STR ( NumError, Helps );
             FatalError ( 'Установлен код ошибки #'+Helps+
                          ' при входе в NextChar' )
        END;
     NowLinePtr := 0;
     PointBeginBuf := PointBeginBuf + SizeBuf;
     SEEK ( Fl, PointBeginBuf );
     BLOCKREAD ( Fl, BufferPtr^, SizeBuf, SizeFact );
     IF ( IORESULT <> 0 ) THEN
        BEGIN
             NumError := 1;
             ErrorProc ( NumError );
             EXIT
        END;
     IF ( SizeFact = 0 ) THEN
        BEGIN
             KeyEOF := TRUE;
             EXIT
        END

END; { procedure LocationText.NextChar }

{----------------------------------------------------------}

PROCEDURE LocationText.PrevChar;

          { осуществляет переход к предыдущему символу }
VAR
   HelpS : StandartString;

BEGIN
     KeyEOF := FALSE;
     IF ( SizeFact = 0 ) THEN
        BEGIN
             KeyEOF := TRUE;
             EXIT
        END;
     IF ( NowLinePtr > 0 ) THEN
        BEGIN
             DEC ( NowLinePtr );
             EXIT
        END;
     IF ( PointBeginBuf = 0 ) THEN
        BEGIN
             KeyEOF := TRUE;
             EXIT
        END;
     IF ( NumError <> 0 ) THEN
        BEGIN
             STR ( NumError, Helps );
             FatalError ( 'Установлен код ошибки #'+Helps+
                          ' при входе в PrevChar' )
        END;
     PointBeginBuf := PointBeginBuf - SizeBuf;
     IF ( PointBeginBuf < 0 ) THEN
        PointBeginBuf := 0;
     SEEK ( Fl, PointBeginBuf );
     BLOCKREAD ( Fl, BufferPtr^,SizeBuf, SizeFact );
     IF ( IORESULT <> 0 ) THEN
        BEGIN
             NumError := 1;
             ErrorProc ( NumError )
        END;
     IF ( SizeFact = 0 ) THEN
        BEGIN
             KeyEOF := TRUE;
             EXIT
        END;
     NowLinePtr := SizeFact - 1

END; { procedure LocationText.PrevChar }

{----------------------------------------------------------}

PROCEDURE LocationText.SetLineNumber ( Num : LONGINT );

          { установить номер обрабатываемой строки       }
VAR
   Key    : BOOLEAN;
            { признак направления поиска }

   HelpS : StandartString;
            { вспомогательная строка }
BEGIN

        { проверки и начальные установки }

     IF ( NumError <> 0 ) THEN
        BEGIN
             STR ( NumError, Helps );
             FatalError ( 'Установлен код ошибки #'+Helps+
                          ' при входе в SetLineNumber' )
        END;

     SingStreamEOF := FALSE;
     IF ( Num = NowLineNumber ) THEN
        EXIT;
     IF ( ( Num < 1 ) OR ( Num > MaxLineNumber ) ) THEN
        BEGIN
             NumError := 4;
             ErrorProc ( NumError );
             EXIT
        END;

          { установка на первую строку файлового потока }

     IF ( Num = 1 ) THEN
        BEGIN
             NowLineNumber := 1;
             NowLinePtr := 0;
             IF ( PointBeginBuf <> 0 ) THEN
                BEGIN
                     PointBeginBuf := 0;
                     SEEK ( Fl, 0 );
                     BLOCKREAD ( Fl, BufferPtr^, SizeBuf, SizeFact );
                     IF ( IORESULT <> 0 ) THEN
                        BEGIN
                             NumError := 1;
                             ErrorProc ( NumError )
                        END
                END;
             KeyEOF := FALSE;
             EXIT
        END;

        { установить направление движения указателя по потоку }
        { TRUE - прямое направление движения }
        { FALSE - реверсивное движение }

     Key := ( ( Num - NowLineNumber ) > 0 );
     KeyEOF := FALSE;

        { установить указатель для реверсивного движения по потоку }

     IF ( NOT Key ) THEN
        BEGIN
             IF ( GetCurrentChar <> #$0A ) THEN
                PrevChar;
             IF ( GetCurrentChar <> #$0A ) THEN
                FatalError ( 'Нет #$0A при обратном ходе в SetLineNumber' );
             PrevChar;
             IF ( GetCurrentChar <> #$0D ) THEN
                FatalError ( 'Нет #$0D при обратном ходе в SetLineNumber' )
        END;

         { цикл поиска по потоку }

     WHILE ( ( Num <> NowLineNumber ) AND ( NOT KeyEOF ) ) DO
           BEGIN
                IF ( Key ) THEN
                   BEGIN
                        IF ( GetCurrentChar = #$0D ) THEN
                           BEGIN
                                NextChar;
                                IF ( GetCurrentChar = #$0A ) THEN
                                   INC ( NowLineNumber )
                           END;
                        NextChar
                   END
                ELSE
                    BEGIN
                         PrevChar;
                         IF ( ( GetCurrentChar = #$0A ) OR ( KeyEOF ) ) THEN
                            BEGIN
                                 IF ( NOT KeyEOF ) THEN
                                    PrevChar;
                                 IF ( ( GetCurrentChar = #$0D )
                                      OR ( KeyEOF ) ) THEN
                                    DEC ( NowLineNumber )
                            END
                    END
           END;

        { в случае реверсивного движения установить указатель }
                 { на начало следующей строки }

     IF ( ( NOT Key ) AND ( NOT KeyEOF ) ) THEN
        BEGIN
             IF ( GetCurrentChar = #$0A ) THEN
                FatalError ( 'Сбой в конце строки при обратном '+
                             'ходе в SetLineNumber' )
             ELSE
                 IF ( GetCurrentChar = #$0D ) THEN
                    BEGIN
                         NextChar;
                         NextChar
                    END
        END;

        { проверка на соответствие установленного и запрашиваемого номера }

     IF ( Num <> NowLineNumber ) THEN
        FatalError ( 'Ошибка в процедуре SetLineNumber'+
                     ' - несоответствие номера при поиске строки' );

     {$IFDEF DEBUGTEXT}
     IF ( NOT CheckBeginLine ) THEN
        BEGIN
             STR ( NowLineNumber, HelpS );
             FatalError ( 'Нет установки на начало строки #' + HelpS +
                          ' в процедуре SetLineNumber' )
        END;
     {$ENDIF}

END; { procedure LocationText.SetLineNumber }

{----------------------------------------------------------}

FUNCTION LocationText.GetLineNumber : LONGINT;

         { получить номер обрабатываемой строки         }
BEGIN
     GetLineNumber := NowLineNumber

END; { function LocationText.GetLineNumber }

{----------------------------------------------------------}

FUNCTION LocationText.GetSize : LONGINT;

         { получить общее количество строк в текстовом  }
         { потоке                                       }
BEGIN
     GetSize := MaxLineNumber

END; { function LocationText.GetSize }

{----------------------------------------------------------}

FUNCTION LocationText.EofText : BOOLEAN;

         { получить признак завершения потока           }
BEGIN
     EofText := SingStreamEOF

END; { function LocationText.EofText }

{----------------------------------------------------------}

PROCEDURE LocationText.ReadLines ( Quantity : LONGINT;
                                   VAR LnPtr : RecLinePtr );

          { создает список из заданного количества      }
          { строк загружая их из потока                 }
VAR
   HelpS : StandartString;
          { вспомогательная переменная }

FUNCTION GetLine ( Quantity : LONGINT ) : RecLinePtr;

         { возвращает указатель на список из заданного количества строк }
VAR
   Hlp : RecLinePtr;
   GetByte : CHAR;
   Sz : WORD;
   KeyFind : BOOLEAN;

BEGIN
        { начальные установки и проверки }

     IF ( NumError <> 0 ) THEN
        BEGIN
             STR ( NumError, Helps );
             FatalError ( 'Установлен код ошибки #'+Helps+
                          ' при входе в GetLine/ReadLines' )
        END;
     Sz := 0;
     IF ( Quantity = 0 ) THEN
        BEGIN
             GetLine := NIL;
             EXIT
        END;
     NEW ( Hlp );
     IF ( Hlp = NIL ) THEN
        BEGIN
             NumError := 6;
             ErrorProc ( NumError );
             GetLine := NIL;
             EXIT;
        END;
     Hlp^.Line := '';
     KeyFind := FALSE;

           { формирование строки потока }

     WHILE ( ( NOT KeyFind ) AND ( NOT KeyEOF ) ) DO
           BEGIN
                Hlp^.Line := Hlp^.Line + GetCurrentChar;
                IF ( GetCurrentChar = #$0D ) THEN
                   BEGIN
                        NextChar;
                        IF ( GetCurrentChar = #$0A ) THEN
                           KeyFind := TRUE
                         ELSE
                             Hlp^.Line := Hlp^.Line + GetCurrentChar
                    END;
                 NextChar
           END;

           { формирование признака последней строки }

     INC ( NowLineNumber );
     IF ( NowLineNumber > MaxLineNumber ) THEN
        BEGIN
             NowLineNumber := MaxLineNumber;
             SingStreamEOF := TRUE;
             IF ( NOT KeyEOF ) THEN
                FatalError ( 'Окончание потока ненайдено в GetChar/ReadLines' );
        END;

          { возврат к началу последней строки }

     IF ( ( SingStreamEOF ) AND ( GetCurrentChar <> #$0A ) ) THEN
        BEGIN
             REPEAT
                   GetByte := GetCurrentChar;
                   PrevChar
             UNTIL ( ( KeyEOF ) OR ( ( GetByte = #$0A ) AND
                     ( GetCurrentChar = #$0D ) ) );
             IF ( NOT KeyEOF ) THEN
                BEGIN
                     NextChar;
                     NextChar
                END
        END;

         { удаление из строки "лишних" символов полученных при формировании }

     IF ( ( Hlp^.Line <> '' ) AND
        ( Hlp^.Line [ LENGTH ( Hlp^.Line ) ] = #$0D ) ) THEN
        DELETE ( Hlp^.Line, LENGTH ( Hlp^.Line ), 1 );
     IF ( ( Hlp^.Line [ 1 ] = #$0A ) AND ( SingStreamEOF ) ) THEN
        Hlp^.Line := '';

        { приступить к формированию следующей строки списка }

     DEC ( Quantity );
     Hlp^.Next := GetLine ( Quantity );
     GetLine := Hlp

END; { function GetLine }

BEGIN  { ReadLines }

        { проверки }

     IF ( NumError <> 0 ) THEN
        BEGIN
             STR ( NumError, Helps );
             FatalError ( 'Установлен код ошибки #'+Helps+
                          ' при входе в ReadLines' )
        END;

     IF ( ( ( NowLineNumber + Quantity ) > MaxLineNumber + 1 ) OR
           ( Quantity < 0 ) ) THEN
        BEGIN
             NumError := 4;
             ErrorProc ( NumError );
             EXIT
        END;
     IF ( Quantity = 0 ) THEN
        EXIT;

        { загрузка списка строк }

     IF ( LnPtr <> NIL ) THEN
        FatalError ( 'Передан не пустой указатель в ReadLines' );
     KeyEOF := FALSE;
     LnPtr := GetLine ( Quantity );

END; { procedure LocationText.ReadLines }

{----------------------------------------------------------}

PROCEDURE LocationText.TruncateLines;

          { Отсекает строки от потока начиная с текущей }
VAR
   HelpS : StandartString;
            { вспомогательная строка }

   HelpChar : CHAR;
            { вспомогательный символ }

BEGIN
        { проверки }

     IF ( NumError <> 0 ) THEN
        BEGIN
             STR ( NumError, Helps );
             FatalError ( 'Установлен код ошибки #'+Helps+
                          ' при входе в TruncateLines' )
        END;

        { уничтожение всего потока }

     IF ( NowLineNumber = 1 ) THEN
        BEGIN
             SEEK ( Fl, 0 );
             TRUNCATE ( Fl );
             PointBeginBuf := 0;
             KeyEOF := TRUE;
             NowLinePtr := 0;
             SizeFact := 0;
             MaxLineNumber := 1;
             SingState := FALSE;
             IF ( IORESULT <> 0 ) THEN
                BEGIN
                     NumError := 5;
                     ErrorProc ( NumError );
                     EXIT
                END;
             {$IFDEF DEBUGTEXT}
             IF ( NOT CheckBeginLine ) THEN
                BEGIN
                     STR ( NowLineNumber, HelpS );
                     FatalError ( 'Нет установки на начало строки #' + HelpS +
                                  ' в процедуре TruncateLines' )
                END;
             {$ENDIF}
             EXIT
        END;

           { Установить указатель в конце предыдущей строки }

        IF ( GetCurrentChar <> #$0A ) THEN
           PrevChar;
        IF ( GetCurrentChar <> #$0A ) THEN
           FatalError ( 'Нет #$0A при обратном ходе в TruncateLines' );
        PrevChar;
        IF ( GetCurrentChar <> #$0D ) THEN
           FatalError ( 'Нет #$0D при обратном ходе в TruncateLines' );

           { отсечение по указателю }

        SEEK ( Fl, PointBeginBuf + NowLinePtr );
        TRUNCATE ( Fl );
        SizeFact := NowLinePtr;
        MaxLineNumber := NowLineNumber - 1;
        IF ( IORESULT <> 0 ) THEN
           BEGIN
                NumError := 5;
                ErrorProc ( NumError );
                EXIT
           END;

           { Установить указатель к началу последней строки }

        PrevChar;
        REPEAT
              HelpChar := GetCurrentChar;
              PrevChar
        UNTIL ( ( KeyEOF ) OR ( HelpChar = #$0A ) AND
                ( GetCurrentChar = #$0D ) );
        IF ( NOT KeyEOF ) THEN
           BEGIN
                NextChar;
                NextChar
           END;
        KeyEOF := FALSE;
        DEC ( NowLineNumber );
        IF ( DubleNowLineNumber > NowLineNumber ) THEN
           SingState := FALSE;

     {$IFDEF DEBUGTEXT}
     IF ( NOT CheckBeginLine ) THEN
        BEGIN
             STR ( NowLineNumber, HelpS );
             FatalError ( 'Нет установки на начало строки #' + HelpS +
                          ' в процедуре TruncateLines' )
        END;
     IF ( NOT CheckLineNumber ) THEN
        BEGIN
             STR ( NowLineNumber, HelpS );
             FatalError ( 'Неверно установлена строка #' + HelpS +
                          ' в процедуре TruncateLines' )
        END;
     IF ( NOT CheckLend ) THEN
        FatalError ( 'Несоответствие длины потока после TruncateLines' );

     {$ENDIF}

END; { procedure LocationText.TruncateLines }

{----------------------------------------------------------}

PROCEDURE LocationText.DelLines ( Quantity : LONGINT );

          { удалить из потока заданное количество строк  }
          { начиная с текущей                            }
VAR
   SaveLineNumber : LONGINT;
           { сохраненный номер текущей строки  }

   SaveLinePointer : WORD;
           { сохраненный указатель на текущую строку в буфере }

   SaveBufPtr : LONGINT;
           { сохраненный указатель на начало буфера в файле }

   BeginDel, EndDel : LONGINT;
           { Начало и конец удаляемого участка }

   DelBuf : LONGINT;
           { указатетель начала буфера для перезаписи }

   SizeDel : LONGINT;
           { количество байт удаляемой информации }

   SizeFl : LONGINT;
            { размер файла }

   HelpS : StandartString;
            { вспомогательная строка }

   HelpChar : CHAR;
            { вспомогательный символ }

BEGIN
        { проверки }

     IF ( NumError <> 0 ) THEN
        BEGIN
             STR ( NumError, Helps );
             FatalError ( 'Установлен код ошибки #'+Helps+
                          ' при входе в DelLines' )
        END;

     IF ( ( ( NowLineNumber + Quantity ) > MaxLineNumber + 1) OR
           ( Quantity < 0 ) ) THEN
        BEGIN
             NumError := 4;
             ErrorProc ( NumError );
             EXIT
        END;
     IF ( Quantity = 0 ) THEN
        EXIT;

     IF ( ( NowLineNumber + Quantity ) = MaxLineNumber + 1 ) THEN
        BEGIN
             TruncateLines;
             EXIT
        END;

        { сохранение текущих параметров }

     SaveLineNumber := NowLineNumber;
     SaveLinePointer := NowLinePtr;
     SaveBufPtr := PointBeginBuf;

        { вычисляем размер удаляемого участка }

     SetLineNumber ( NowLineNumber +  Quantity );
     BeginDel := SaveBufPtr + SaveLinePointer;
     EndDel := PointBeginBuf + NowLinePtr;
     SizeDel := EndDel - BeginDel;
     IF ( SizeDel <= 0 ) THEN
        FatalError ( 'Значение удаляемого участка <= 0 в процедуре DelLines' );

        { удаляем участок cдвигая файл }

     SizeFl := FILESIZE ( Fl );
     DelBuf := EndDel;
     PointBeginBuf := BeginDel;
     REPEAT
           SEEK ( Fl, DelBuf );
           BLOCKREAD ( Fl, BufferPtr^, SizeBuf, SizeFact );
           IF ( IORESULT <> 0 ) THEN
              BEGIN
                   NumError := 1;
                   ErrorProc ( NumError );
                   EXIT
              END;
           SEEK ( Fl, PointBeginBuf );
           IF ( SizeFact <> 0 ) THEN
              BLOCKWRITE ( Fl, BufferPtr^, SizeFact );
           IF ( IORESULT <> 0 ) THEN
              BEGIN
                   NumError := 2;
                   ErrorProc ( NumError );
                   EXIT
              END;
           PointBeginBuf := PointBeginBuf + SizeBuf;
           DelBuf := DelBuf + SizeBuf
     UNTIL ( SizeFact = 0 );
     SEEK ( Fl, ( SizeFl - SizeDel ) );
     TRUNCATE ( Fl );
     IF ( IORESULT <> 0 ) THEN
        BEGIN
             NumError := 5;
             ErrorProc ( NumError );
             EXIT
        END;

        { восстанавливаем параметры }

     PointBeginBuf := SaveBufPtr;
     NowLinePtr := SaveLinePointer;
     NowLineNumber := SaveLineNumber;
     MaxLineNumber := MaxLineNumber - Quantity;
     SEEK ( Fl, PointBeginBuf );
     BLOCKREAD ( Fl, BufferPtr^, SizeBuf, SizeFact );
     IF ( IORESULT <> 0 ) THEN
         BEGIN
              NumError := 1;
              ErrorProc ( NumError );
              EXIT
         END;

     IF ( DubleNowLineNumber > NowLineNumber ) THEN
        SingState := FALSE;

     {$IFDEF DEBUGTEXT}
     IF ( NOT CheckBeginLine ) THEN
        BEGIN
             STR ( NowLineNumber, HelpS );
             FatalError ( 'Нет установки на начало строки #' + HelpS +
                          ' в процедуре DelLines' )
        END;
     IF ( NOT CheckLineNumber ) THEN
        BEGIN
             STR ( NowLineNumber, HelpS );
             FatalError ( 'Неверно установлена строка #' + HelpS +
                          ' в процедуре DelLines' )
        END;
     IF ( NOT CheckLend ) THEN
        FatalError ( 'Несоответствие длины потока после DelLines' );
     {$ENDIF}

END; { procedure LocationText.DelLines }

{----------------------------------------------------------}

PROCEDURE LocationText.AddLines ( Quantity : LONGINT; LnPtr : RecLinePtr );

          { добавляет заданное количество строк из      }
          { списка в поток                              }
VAR
   SaveBufPtr : LONGINT;
           { сохраненный указатель на начало буфера в файле }

   SaveLinePtr : WORD;
           { сохраненный указатель по буферу }

   Hlp : RecLinePtr;
           { вспомогательный указатель }

   SizeAdd : WORD;
           { количество байт добавляемой информации }

   Index : BYTE;
           { индекс символа в строке }

   HelpS : StandartString;
           { вспомогательная строка }

   KeyLine : BOOLEAN;
           { признак возможности отсутствия установки на начало строки }

PROCEDURE AddChar ( HlpCh : CHAR );

          { добавить символ в поток }
BEGIN
     IF ( NumError <> 0 ) THEN
        BEGIN
             STR ( NumError, Helps );
             FatalError ( 'Установлен код ошибки #'+Helps+
                          ' при входе в AddLines/AddChar' )
        END;

     IF ( SizeFact < SizeBuf ) THEN
        BEGIN
             INC ( SizeFact );
             INC ( NowLinePtr );
             SetCurrentChar ( HlpCh );
             EXIT
        END;
     SEEK ( Fl, PointBeginBuf );
     BLOCKWRITE ( Fl, BufferPtr^, SizeFact );
     PointBeginBuf := PointBeginBuf + SizeBuf;
     IF ( IORESULT <> 0 ) THEN
        BEGIN
             NumError := 2;
             ErrorProc ( NumError );
             EXIT;
        END;
     NowLinePtr := 0;
     SizeFact := 1;
     SetCurrentChar ( HlpCh )

END; { procedure AddChar }

BEGIN
        { проверки и начальные установки }

     IF ( NumError <> 0 ) THEN
        BEGIN
             STR ( NumError, Helps );
             FatalError ( 'Установлен код ошибки #'+Helps+
                          ' при входе в AddLines' )
        END;

     IF ( ( LnPtr = NIL ) OR ( Quantity = 0 ) ) THEN
        EXIT;
     IF ( Quantity < 0 ) THEN
        BEGIN
             NumError := 4;
             ErrorProc ( NumError );
             EXIT
        END;

           { начальные установки }

     SaveBufPtr := PointBeginBuf;
     SaveLinePtr := NowLinePtr;
     KeyLine := ( ( NowLineNumber = MaxLineNumber ) AND
                  ( GetCurrentChar = #$0A ) );
     PointBeginBuf := ( FILESIZE ( Fl ) DIV SizeBuf ) * SizeBuf;
     SEEK ( Fl, PointBeginBuf );
     BLOCKREAD ( Fl, BufferPtr^, SizeBuf, SizeFact );
     NowLinePtr := SizeFact - 1;
     Hlp := LnPtr;

        { добавление строк из списка в файл }

     REPEAT
           IF NOT ( ( SizeFact = 0 ) AND ( MaxLineNumber = 1 ) ) THEN
              BEGIN
                   INC ( MaxLineNumber );
                   AddChar ( #$0D );
                   AddChar ( #$0A )
              END;
           FOR Index := 1 TO LENGTH ( Hlp^.Line ) DO
               AddChar ( Hlp^.Line [ Index ]  );
           Hlp := Hlp^.Next;
           DEC ( Quantity );
     UNTIL ( ( Hlp = NIL ) OR ( Quantity = 0 ) OR ( NumError <> 0 ) );
     SEEK ( Fl, PointBeginBuf );
     BLOCKWRITE ( Fl, BufferPtr^, SizeFact );
     IF ( IORESULT <> 0 ) THEN
        BEGIN
             NumError := 2;
             ErrorProc ( NumError );
             EXIT;
        END;

        { возвратить исходное состояние }

     PointBeginBuf := SaveBufPtr;
     NowLinePtr := SaveLinePtr;
     KeyEOF := FALSE;
     SEEK ( Fl, PointBeginBuf );
     BLOCKREAD ( Fl, BufferPtr^, SizeBuf, SizeFact );
     IF ( IORESULT <> 0 ) THEN
        BEGIN
             NumError := 1;
             ErrorProc ( NumError );
             EXIT
        END;
     IF ( KeyLine ) THEN
        IF ( GetCurrentChar = #$0A ) THEN
           NextChar
        ELSE
            FatalError ( 'Ошибка в AddLines при установка на начало строки' );

     {$IFDEF DEBUGTEXT}
     IF ( NOT CheckBeginLine ) THEN
        BEGIN
             STR ( NowLineNumber, HelpS );
             FatalError ( 'Нет установки на начало строки #' + HelpS +
                          ' в процедуре AddLines' )
        END;
     IF ( NOT CheckLineNumber ) THEN
        BEGIN
             STR ( NowLineNumber, HelpS );
             FatalError ( 'Неверно установлена строка #' + HelpS +
                          ' в процедуре AddLines' )
        END;
     IF ( NOT CheckLend ) THEN
        FatalError ( 'Несоответствие длины потока после AddLines' );
     {$ENDIF}

END; { procedure LocationText.AddLines }

{----------------------------------------------------------}

PROCEDURE LocationText.InsertLines ( Quantity : LONGINT; LnPtr : RecLinePtr );

          { вставляет заданное количество строк из      }
          { списка в поток                              }
VAR
   SaveLineNumber : LONGINT;
           { сохраненный номер текущей строки  }

   SaveLinePointer : WORD;
           { сохраненный указатель на текущую строку в буфере }

   SaveBufPtr : LONGINT;
           { сохраненный указатель на начало буфера в файле }

   Index : BYTE;
           { индексная переменная строки }

   SizeAdd : LONGINT;
           { длина подключаемого хвоста }

   OldSize : LONGINT;
           { Старое значение длины файла }

   SizeCheck : WORD;
           { Контрольный размер }

   Hlp : RecLinePtr;
           { вспомогательный указатель }

   HelpS : StandartString;
           { вспомогательная строка }

PROCEDURE LocationChar ( HlpCh : CHAR );

          { разместить символ в потоке }
BEGIN
     IF ( NumError <> 0 ) THEN
        BEGIN
             STR ( NumError, Helps );
             FatalError ( 'Установлен код ошибки #'+Helps+
                          ' при входе в InsertLines/LocationChar' )
        END;

     IF ( NowLinePtr < SizeFact  - 1 ) THEN
        BEGIN
             SetCurrentChar ( HlpCh );
             INC ( NowLinePtr );
             EXIT
        END;

     SetCurrentChar ( HlpCh );
     SEEK ( Fl, PointBeginBuf );
     BLOCKWRITE ( Fl, BufferPtr^, SizeFact );
     PointBeginBuf := PointBeginBuf + SizeBuf;
     IF ( IORESULT <> 0 ) THEN
        BEGIN
             NumError := 2;
             ErrorProc ( NumError );
             EXIT;
        END;
     SEEK ( Fl, PointBeginBuf );
     BLOCKREAD ( Fl, BufferPtr^, SizeBuf, SizeFact );
     IF ( IORESULT <> 0 ) THEN
        BEGIN
             NumError := 1;
             ErrorProc ( NumError );
             EXIT;
        END;
     IF ( SizeFact = 0 ) THEN
        FatalError ( 'Неожиданное окончание потока в '+
                     'InsertLines/LocationChar' );
     NowLinePtr := 0

END; { procedure LocationChar }

BEGIN
        { проверки }

     IF ( NumError <> 0 ) THEN
        BEGIN
             STR ( NumError, Helps );
             FatalError ( 'Установлен код ошибки #'+Helps+
                          ' при входе в InsertLines' )
        END;

     IF ( Quantity < 0 ) THEN
        BEGIN
             NumError := 4;
             ErrorProc ( NumError );
             EXIT
        END;

     IF ( ( Quantity = 0 ) OR ( LnPtr = NIL ) ) THEN
        EXIT;

        { Вставка в пустой поток }

     IF ( ( NowLineNumber = 1 ) AND ( SizeFact = 0 ) ) THEN
        BEGIN
             AddLines ( Quantity, LnPtr );
             EXIT
        END;

        { сохранение текущих параметров }

     SaveLineNumber := NowLineNumber;
     SaveLinePointer := NowLinePtr;
     SaveBufPtr := PointBeginBuf;
     IF ( DubleNowLineNumber > NowLineNumber ) THEN
        SingState := FALSE;

        { добавляем к файлу "хвост" заданой длины }

     OldSize := FILESIZE ( Fl );
     SizeAdd := FullSizeQLines ( Quantity, LnPtr );
     WHILE ( SizeAdd > 0 ) DO
           BEGIN
                PointBeginBuf := FILESIZE ( Fl );
                SEEK ( Fl, PointBeginBuf );
                IF ( SizeAdd >= SizeBuf ) THEN
                   BEGIN
                        SizeAdd := SizeAdd - SizeBuf;
                        SizeFact := SizeBuf
                   END
                ELSE
                    BEGIN
                         SizeFact := SizeAdd;
                         SizeAdd := 0
                    END;
                BLOCKWRITE ( Fl, BufferPtr^, SizeFact );
                IF ( IORESULT <> 0 ) THEN
                   BEGIN
                        NumError := 2;
                        ErrorProc ( NumError );
                        EXIT
                   END
           END;

        { перенос части файла в "хвост" }

        PointBeginBuf := FILESIZE ( Fl );
        WHILE ( OldSize > SaveBufPtr + SaveLinePointer ) DO
              BEGIN
                   IF ( ( OldSize - ( SaveBufPtr + SaveLinePointer) )
                         >= SizeBuf ) THEN
                      SizeFact := SizeBuf
                   ELSE
                       SizeFact := OldSize - ( SaveBufPtr + SaveLinePointer);
                   PointBeginBuf := PointBeginBuf - SizeFact;
                   OldSize := OldSize - SizeFact;
                   SEEK ( Fl, OldSize );
                   BLOCKREAD ( Fl, BufferPtr^, SizeFact, SizeCheck );
                   IF ( SizeCheck <> SizeFact ) THEN
                      FatalError ( 'Несоответствие размера в процедуре '+
                                   'InsertLines при преносе "хвоста"' );
                   IF ( IORESULT <> 0 ) THEN
                      BEGIN
                           NumError := 1;
                           ErrorProc ( NumError );
                           EXIT
                      END;
                   SEEK ( Fl, PointBeginBuf );
                   BLOCKWRITE ( Fl, BufferPtr^, SizeFact );
                   IF ( IORESULT <> 0 ) THEN
                      BEGIN
                           NumError := 2;
                           ErrorProc ( NumError );
                           EXIT
                      END
              END;

        { восстановление параметров }

     PointBeginBuf := SaveBufPtr;
     NowLinePtr := SaveLinePointer;
     NowLineNumber := SaveLineNumber;
     SEEK ( Fl, PointBeginBuf );
     IF ( NumError = 0 ) THEN
        BLOCKREAD ( Fl, BufferPtr^, SizeBuf, SizeFact );
     IF ( IORESULT <> 0 ) THEN
         BEGIN
              NumError := 1;
              ErrorProc ( NumError )
         END;

       { занесение вставляемых строк в поток }

     Hlp := LnPtr;
     REPEAT
           INC ( MaxLineNumber );
           INC ( NowLineNumber );
           FOR Index := 1 TO LENGTH ( Hlp^.Line ) DO
               LocationChar ( Hlp^.Line [ Index ]  );
           LocationChar ( #$0D );
           LocationChar ( #$0A );
           Hlp := Hlp^.Next;
           DEC ( Quantity );
     UNTIL ( ( Hlp = NIL ) OR ( Quantity = 0 ) OR ( NumError <> 0 ) );
     SEEK ( Fl, PointBeginBuf );
     BLOCKWRITE ( Fl, BufferPtr^, SizeFact );
     IF ( IORESULT <> 0 ) THEN
        BEGIN
             NumError := 2;
             ErrorProc ( NumError );
             EXIT;
        END;

     {$IFDEF DEBUGTEXT}
     IF ( NOT CheckBeginLine ) THEN
        BEGIN
             STR ( NowLineNumber, HelpS );
             FatalError ( 'Нет установки на начало строки #' + HelpS +
                          ' в процедуре InsertLines' )
        END;
     IF ( NOT CheckLineNumber ) THEN
        BEGIN
             STR ( NowLineNumber, HelpS );
             FatalError ( 'Неверно установлена строка #' + HelpS +
                          ' в процедуре InsertLines' )
        END;
     IF ( NOT CheckLend ) THEN
        FatalError ( 'Несоответствие длины потока после InsertLines' );
     {$ENDIF}

END; { procedure LocationText.InsertLines }

{----------------------------------------------------------}

PROCEDURE LocationText.ReplaseLines ( DelQuantity : LONGINT;
                         InsQuantity : LONGINT; LnPtr : RecLinePtr );

          { заменяет заданное количество строк текста в }
          { потоке                                      }
VAR
   HelpLineNumber : LONGINT;

   HelpS : StandartString;

BEGIN
     IF ( NumError <> 0 ) THEN
        BEGIN
             STR ( NumError, Helps );
             FatalError ( 'Установлен код ошибки #'+Helps+
                          ' при входе в ReplaseLines' )
        END;

     IF ( ( NowLineNumber + DelQuantity ) = MaxLineNumber + 1 ) THEN
        HelpLineNumber := NowLineNumber
     ELSE
         HelpLineNumber := 0;
     DelLines ( DelQuantity );
     IF ( HelpLineNumber = 0 ) THEN
        InsertLines ( InsQuantity, LnPtr )
     ELSE
         BEGIN
              AddLines ( InsQuantity, LnPtr );
              SetLineNumber ( HelpLineNumber )
         END

END; { procedure LocationText.ReplaceLines }

{----------------------------------------------------------}

PROCEDURE LocationText.ReadLine ( VAR Line : STRING );

         { загружает одну строку из потока             }
VAR
   Hlp : RecLinePtr;

BEGIN
     IF ( NumError <> 0 ) THEN
        EXIT;
     Hlp := NIL;
     ReadLines ( 1, Hlp );
     Line := Hlp^.Line;
     ClearListRecLine ( Hlp )

END; { procedure LocationText.ReadLine }

{----------------------------------------------------------}

PROCEDURE LocationText.InsLine ( Line : STRING );

          { вставляет одну строку в поток              }
VAR
   Hlp : RecLinePtr;

BEGIN
     IF ( NumError <> 0 ) THEN
        EXIT;
     NEW ( Hlp );
     IF ( Hlp = NIL ) THEN
        BEGIN
             NumError := 6;
             ErrorProc ( NumError );
             EXIT
        END;
     Hlp^.Line := Line;
     Hlp^.Next := NIL;
     InsertLines ( 1, Hlp );
     DISPOSE ( Hlp )

END; { procedure LocationText.InsLine }

{----------------------------------------------------------}

PROCEDURE LocationText.DelLine;

          { удаляет одну строку из потока              }
BEGIN
     IF ( NumError = 0 ) THEN
        DelLines ( 1 )

END; { procedure LocationText.DelLine }

{----------------------------------------------------------}

PROCEDURE LocationText.WriteLine ( Line : STRING );

          { пишет одну строку в поток                  }
VAR
   Hlp : RecLinePtr;

BEGIN
     IF ( NumError <> 0 ) THEN
        EXIT;
     NEW ( Hlp );
     IF ( Hlp = NIL ) THEN
        BEGIN
             NumError := 6;
             ErrorProc ( NumError );
             EXIT
        END;
     Hlp^.Line := Line;
     Hlp^.Next := NIL;
     ReplaseLines ( 1, 1, Hlp );
     DISPOSE ( Hlp )

END; { procedure LocationText.WriteLine }

{----------------------------------------------------------}

PROCEDURE LocationText.AddLine ( Line : STRING );

          { добавляет строку в поток }
VAR
   Hlp : RecLinePtr;

BEGIN
     IF ( NumError <> 0 ) THEN
        EXIT;
     NEW ( Hlp );
     IF ( Hlp = NIL ) THEN
        BEGIN
             NumError := 6;
             ErrorProc ( NumError );
             EXIT
        END;
     Hlp^.Line := Line;
     Hlp^.Next := NIL;
     AddLines ( 1, Hlp );
     DISPOSE ( Hlp )

END; { procedure LocationText.AddLine }

{----------------------------------------------------------}

PROCEDURE LocationText.SetErrorProc ( Param : ErrorProcedure );

          { установить процедуру обработки ошибочных }
          { ситуаций                                 }
BEGIN
     ErrorProc := Param

END; { procedure LocationText.SetErrorProc }

{----------------------------------------------------------}

PROCEDURE LocationText.SaveState;

          { сохранить текущее состояние }
BEGIN
     DublePointBeginBuf := PointBeginBuf;
     DubleNowLinePtr := NowLinePtr;
     DubleNowLineNumber := NowLineNumber;
     DubleKeyEOF := KeyEof;
     SingState := TRUE

END; { procedure LocationText.SaveState }

{----------------------------------------------------------}
PROCEDURE LocationText.RestoreState;

          { восстановить сохраненнге ранее состояние }
VAR
   HelpS : StandartString;
            { вспомогательная строка }

BEGIN
        { проверки }

     IF ( NumError <> 0 ) THEN
        BEGIN
             STR ( NumError, Helps );
             FatalError ( 'Установлен код ошибки #'+Helps+
                          ' при входе в RestoreState' )
        END;

     IF ( NOT SingState ) THEN
        BEGIN
             IF ( DubleNowLineNumber > GetSize ) THEN
                FatalError ( 'Невозможно восстановить сохраненное состояние'+
                             ' - RestoreState' );
             SetLineNumber ( DubleNowLineNumber );
             EXIT
        END;

     IF ( DublePointBeginBuf <> PointBeginBuf ) THEN
        BEGIN
             SEEK ( fl, DublePointBeginBuf );
             BLOCKREAD ( Fl, BufferPtr^, SizeBuf, SizeFact );
             IF ( IORESULT <> 0 ) THEN
                 BEGIN
                      NumError := 1;
                      ErrorProc ( NumError );
                      EXIT
                 END
        END;
     PointBeginBuf := DublePointBeginBuf;
     NowLinePtr := DubleNowLinePtr;
     NowLineNumber := DubleNowLineNumber;
     KeyEOF := DubleKeyEOF;

     {$IFDEF DEBUGTEXT}
     IF ( NOT CheckBeginLine ) THEN
        BEGIN
             STR ( NowLineNumber, HelpS );
             FatalError ( 'Нет установки на начало строки #' + HelpS +
                          ' в процедуре RestoreState' )
        END;
     IF ( NOT CheckLineNumber ) THEN
        BEGIN
             STR ( NowLineNumber, HelpS );
             FatalError ( 'Неверно установлена строка #' + HelpS +
                          ' в процедуре RestoreState' )
        END;
     {$ENDIF}

END; { procedure LocationText.RestoreState }

{----------------------------------------------------------}

DESTRUCTOR LocationText.Done;

           { закрывает файл, уничтожает буфер и         }
           { деинициализирует обьект                    }

BEGIN
     IF ( SingWrite ) THEN
        BEGIN
             SEEK ( Fl, PointBeginBuf );
             BLOCKWRITE ( Fl, BufferPtr^, SizeFact );
             IF ( IORESULT <> 0 ) THEN
                BEGIN
                     NumError := 2;
                     ErrorProc ( NumError )
                END;
        END;
     CLOSE ( Fl );
     IF ( IORESULT <> 0 ) THEN
        BEGIN
             NumError := 2;
             ErrorProc ( NumError )
        END;
     FREEMEM ( BufferPtr, SizeBuf )

END; { destructor LocationText.Done }

{==========================================================}

CONSTRUCTOR LocationListText.Init ( LnPtr : RecLinePtr; Max : LONGINT );

            { Инициализация обьекта, резервирования буфера }
            { и открытие файла                             }

BEGIN
     NumError := 0;
     List := LnPtr;
     IF ( List = NIL ) THEN
        BEGIN
             NEW ( List );
             List^.Next := NIL;
             List^.Line := ''
        END;
     NowLineNumber := 1;
     MaxLine := Max;
     TruncateListLine ( MaxLine, List );
     MaxLineNumber := SizeListLine ( List );
     SaveState

END; { constructor LocationListText.Init }

{----------------------------------------------------------}

PROCEDURE LocationListText.ReSetStream;

          { начальная установка текстового потока }
BEGIN
     NumError := 0;
     NowLinePtr := 0;
     MaxLineNumber := SizeListLine ( List );
     SingStreamEOF := FALSE

END; { procedure LocationListText.ReSetStream }

{----------------------------------------------------------}

FUNCTION LocationListText.GetListPtr : RecLinePtr;

         { получить указатель на список потока }
BEGIN
     GetListPtr := List

END; { function LocationListText.GetListPtr }

{----------------------------------------------------------}

PROCEDURE LocationListText.SetLineNumber ( Num : LONGINT );

          { установить номер обрабатываемой строки       }
BEGIN
     IF ( NumError <> 0 ) THEN
        EXIT;
     IF ( ( Num < 1 ) OR ( Num > MaxLineNumber ) ) THEN
        BEGIN
             NumError := 4;
             ErrorProc ( NumError );
             EXIT
        END;
     SingStreamEOF := FALSE;
     NowLineNumber := Num

END; { procedure LocationListText.SetLineNumber }

{----------------------------------------------------------}

PROCEDURE LocationListText.DelLines ( Quantity : LONGINT );

          { удалить из потока заданное количество строк  }
          { начиная с текущей                            }
VAR
   Index : LONGINT;

BEGIN
     IF ( ( NowLineNumber + Quantity ) = MaxLineNumber + 1 ) THEN
        BEGIN
             TruncateLines;
             EXIT
        END;

     FOR Index := 1 TO QuanTity DO
         DelListLine ( NowLineNumber, List );
     MaxLineNumber := MaxLineNumber - Quantity;
     IF ( MaxLineNumber <> SizeListLine ( List ) ) THEN
        FatalError ( 'Ошибка при удалении строк из списка в DelLines' );
     IF ( NowLineNumber > MaxLineNumber ) THEN
        FatalError ( 'Ошибка при установке строки в процедуре '+
                     'удаления в DelLines' )

END; { procedure LocationListText.DelLines }

{----------------------------------------------------------}

PROCEDURE LocationListText.ReadLines ( Quantity : LONGINT;
                       VAR LnPtr : RecLinePtr );

         { создает список из заданного количества      }
         { строк загружая их из потока                 }
VAR
   Hlp : RecLinePtr;
   Build : RecLinePtr;

BEGIN
     IF ( Quantity < 1 ) THEN
        BEGIN
             NumError := 4;
             ErrorProc ( NumError );
             EXIT
        END;
     Hlp := FindLine ( NowLineNumber, List );
     IF ( Hlp = NIL ) THEN
        FatalError ( 'Достигнут пустой указззатель при чтении ReadLines' );
     LnPtr := CopyListLine ( Quantity, Hlp );
     NowLineNumber := NowLineNumber + Quantity;
     IF ( NowLineNumber > MaxLineNumber ) THEN
        BEGIN
             SingStreamEOF := TRUE;
             NowLineNumber := MaxLineNumber
        END
     ELSE
         SingStreamEOF := FALSE

END; { procedure LocationListText.ReadLines }

{----------------------------------------------------------}

PROCEDURE LocationListText.InsertLines ( Quantity : LONGINT;
                               LnPtr : RecLinePtr );

         { вставляет заданное количество строк из      }
         { списка в поток                              }
VAR
   First : RecLinePtr;

BEGIN
     IF ( ( MaxLineNumber = 1 ) AND ( List^.Line = '' ) ) THEN
        BEGIN
             AddLines ( Quantity, LnPtr );
             EXIT
        END;
     First := CopyListLine ( Quantity, LnPtr );
     Quantity := SizeListLine ( First );
     InsertList ( NowLineNumber, List, First );
     TruncateListLine ( MaxLine, List );
     NowLineNumber := NowLineNumber + Quantity;
     MaxLineNumber := MaxLineNumber   +  Quantity;
     IF ( MaxLineNumber <> SizeListLine ( List ) ) THEN
        FatalError ( 'Ошибка при добавлении в список в In  sertLines' );
     IF ( NowLineNumber > MaxLineNumber ) THEN
        NowLineNumber := MaxLineNumber

END; { procedure LocationListText.InsertLines }

{----------------------------------------------------------}

PROCEDURE LocationListText.AddLines ( Quantity : LONGINT;
                              LnPtr : RecLinePtr );

         { добавляет заданное количество строк из      }
         { списка в поток                              }
VAR
   First : RecLinePtr;

BEGIN
     First := CopyListLine ( Quantity, LnPtr );
     Quantity := SizeListLine ( First );
     IF ( ( SizeListLine ( List ) = 1 ) AND ( List^ .Line = '' ) ) THEN
        BEGIN
             DISPOSE ( List );
             List := NIL;
             AddListLine ( List, First );
             MaxLineNumber := Quantity
        END
     ELSE
         BEGIN
             AddListLine ( List, First );
             MaxLineNumber := MaxLineNumber + Quantity
         END;
     IF ( MaxLineNumber <> SizeListLine ( List ) ) THEN
        FatalError ( 'Ошибка при добавленииии строк в список в AddLines' );
     TruncateListLine ( MaxLine, List );
     MaxLineNumber := SizeListLine ( List );
     IF ( NowLineNumber > MaxLineNumber ) THEN
        NowLineNumber := MaxLineNumber

END; { procedure LocationListText.AddLines }

{----------------------------------------------------------}

PROCEDURE LocationListText.TruncateLines;

          { Отсекает строки от потока начиная с текущей }
BEGIN
     IF ( NowLineNumber = 1 ) THEN
        BEGIN
             ClearListRecLine ( List );
             List := NIL;
             NEW ( List );
             List^.Line := '';
             List^.Next := NIL;
             EXIT
        END;
     TruncateListLine ( NowLineNumber, List );
     MaxLineNumber := SizeListLine ( List );
     NowLineNumber := MaxLineNumber

END; { procedure LocationListText.TruncateLines }

{----------------------------------------------------------}

PROCEDURE LocationListText.SaveState;

          { сохранить текущее состояние }
BEGIN
     DubleNowLineNumber := NowLineNumber;
     SingState := TRUE

END; { procedure LocationListText.SaveState }

{----------------------------------------------------------}

PROCEDURE LocationListText.RestoreState;

          { восстановить сохраненнге ранее состояние }

BEGIN
     NowLineNumber := DubleNowLineNumber;
     IF ( NowLineNumber > MaxLineNumber ) THEN
        FatalError ( 'Невозможно восстановить состояние спискового потока' )

END; { procedure LocationListText.RestoreState }

{----------------------------------------------------------}

DESTRUCTOR LocationListText.Done;

           { деинициализирует обьект                    }
BEGIN
     ClearListRecLine ( List )

END; { destructor LocationListText.Done }

{==========================================================}

CONSTRUCTOR LocationProtectText.Init ( SzBuf : WORD; Name : STRING;
                                       Ps : BYTE );

            { Инициализация обьекта, резервирования буфера }
            { и открытие файла                             }
BEGIN
     Password := Ps;
     LocationText.Init ( SzBuf, Name );

END; { constructor LocationProtectText.Init }

{----------------------------------------------------------}

FUNCTION LocationProtectText.GetCurrentChar : CHAR;

         { возвращает текущий символ потока }
BEGIN
     GetCurrentChar := CHR ( BufferPtr^ [ NowLinePtr ] - Password )

END; { function LocationProtectText.GetCurrentChar }

{----------------------------------------------------------}

PROCEDURE LocationProtectText.SetCurrentChar ( Ch : CHAR );

          { устанавливает текущий символ потока }
BEGIN
     BufferPtr^ [ NowLinePtr ] := ORD ( Ch ) + Password

END; { procedure LocationProtectText.SetCurrentChar }

{----------------------------------------------------------}

PROCEDURE LocationProtectText.SetPassword ( Ps : BYTE );

          { Установка нового пароля }
BEGIN
     Password := Ps

END; { procedure LocationProtectText.SetPassword }

{----------------------------------------------------------}

END.
