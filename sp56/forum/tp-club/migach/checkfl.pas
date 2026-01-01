

         {----------------------------------------------------}
         {             Модуль CheckFl V 1.0                   }
         {     Язык программирования Turbo Pascal  V 6.0      }
         {----------------------------------------------------}
         { Дата последних изменений :  01/11/1991             }
         {----------------------------------------------------}
         {   Модуль предназначен для защиты программ от       }
         {                   вирусов                          }
         {----------------------------------------------------}
         { (c) 1991, Мигач Ярослав                            }
         {----------------------------------------------------}


UNIT CheckFl;

{$F+,O+,A+,D-,L-,R-,S-,I-}

INTERFACE

USES Crt, Dos;

PROCEDURE CheckStart ( Name : STRING );

IMPLEMENTATION

TYPE
    BOX = ARRAY [ 1..$C000 ] OF BYTE;

VAR
   Fl : FILE;
   BoxPtr : ^BOX;
   Counter : LONGINT;
   Index, Fact : WORD;
   Check1, C1 : LONGINT;
   Check2, C2 : LONGINT;
   Lend : LONGINT;
   OldByte : BYTE;

PROCEDURE ChkStart ( Num : BYTE );

BEGIN
     IF ( IORESULT <> 0 ) THEN
        BEGIN
             CASE Num OF
             1    : WRITELN ( 'Нет запускаемого файла в текущем каталоге' );
             2..4 : WRITELN ( 'Ошибка чтения контрольной суммы файла' );
             5    : WRITELN ( 'Ошибка чтения контролируемого файла' );
             6    : WRITELN ( 'Ошибка закрытия контролируемого файла' )
             ELSE
                 WRITELN ( 'Ошибка запуска' + #7,  Num )
             END;
             WRITE ( CHR ( 7 ) );
             HALT ( 1 )
        END

END; { procedure ChkStart }

PROCEDURE CheckStart ( Name : STRING );

BEGIN
     ASSIGN ( Fl, Name );
     RESET ( Fl, 1 );
     ChkStart ( 1 );
     SEEK ( Fl, ( FILESIZE ( Fl ) - SIZEOF ( Check1 ) - SIZEOF ( Check2 ) -
                                  SIZEOF ( Lend ) ) );
     BLOCKREAD ( Fl, Lend, SIZEOF ( Lend ) );
     ChkStart ( 2 );
     BLOCKREAD ( Fl, Check1, SIZEOF ( Check1 ) );
     ChkStart ( 3 );
     BLOCKREAD ( Fl, Check2, SIZEOF ( Check2 ) );
     ChkStart ( 4 );
     IF ( Lend <> ( FILESIZE ( Fl ) - SIZEOF ( Check1 ) - SIZEOF ( Check2 ) -
          SIZEOF ( Lend ) ) ) THEN
        BEGIN
             WRITELN ( CHR ( 7 ) );
             WRITELN ( Counter, ' ', C1, ' ', C2 );
             WRITELN ( 'Код программы изменен !!!' );
             WRITELN ( 'Возможно наличие вируса или нарушение авторских прав' );
             WRITELN;
             WRITELN ( ' Выполнение программы прекращается ...' );
             HALT ( 1 )
        END;
     SEEK ( Fl, 0 );
     Counter := 0;
     C1 := 0;
     C2 := 0;
     OldByte := 0;
     NEW ( BoxPtr );
     WHILE ( Counter < Lend ) AND ( NOT EOF ( Fl ) ) DO
           BEGIN
                BLOCKREAD ( Fl, BoxPtr^, $C000, Fact );
                ChkStart ( 5 );
                FOR Index := 1 TO Fact DO
                    IF ( Counter < Lend ) THEN
                         BEGIN
                              C1 := C1 + BoxPtr^[ Index ];
                              C2 := C2 + (  BoxPtr^[ Index ] AND OldByte );
                              OldByte := BoxPtr^[ Index ];
                              INC ( Counter )
                         END
           END;
     DISPOSE ( BoxPtr );
     CLOSE ( Fl );
     ChkStart ( 6 );
     IF ( ( Counter <> Lend ) OR ( C1 <> Check1 ) OR ( C2 <> Check2 ) ) THEN
        BEGIN
             WRITELN ( CHR ( 7 ) );
             WRITELN ( Counter, ' ', C1, ' ', C2 );
             WRITELN ( 'Код программы изменен !!!' );
             WRITELN ( 'Возможно наличие вируса или нарушение авторских прав' );
             WRITELN;
             WRITELN ( ' Выполнение программы прекращается ...' );
             HALT ( 1 )
        END
END; { procedure CheckStart }

END.