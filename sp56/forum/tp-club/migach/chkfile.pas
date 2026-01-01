


         {----------------------------------------------------}
         {          Программа ChkFile V 1.0                   }
         {     Язык программирования Turbo Pascal  V 6.0      }
         {----------------------------------------------------}
         { Дата последних изменений :  01/11/1991             }
         {----------------------------------------------------}
         {   Программа предназначен для защиты программ от    }
         {                   вирусов                          }
         {----------------------------------------------------}
         { (c) 1991, Мигач Ярослав                            }
         {----------------------------------------------------}


PROGRAM ChkFile;

{$F+,O+,A+,D-,L-,R-,S-,I-}

USES Crt, Dos;

TYPE
    BOX = ARRAY [ 1..$C000 ] OF BYTE;

VAR
   Name : STRING [ 12 ];
   Fl : FILE;
   BoxPtr : ^BOX;
   Index, Fact : WORD;
   C1 : LONGINT;
   C2 : LONGINT;
   Lend : LONGINT;
   OldByte : BYTE;

PROCEDURE ChkStart;

BEGIN
     IF ( IORESULT <> 0 ) THEN
        BEGIN
             WRITELN ( 'Ошибка записи' + #7 );
             HALT ( 1 )
        END

END; { procedure ChkStart }

BEGIN
     Name := PARAMSTR ( 1 );
     ASSIGN ( Fl, Name );
     RESET ( Fl, 1 );
     ChkStart;
     SEEK ( Fl, 0 );
     C1 := 0;
     C2 := 0;
     OldByte := 0;
     NEW ( BoxPtr );
     WHILE ( NOT EOF ( Fl ) ) DO
           BEGIN
                BLOCKREAD ( Fl, BoxPtr^, $C000, Fact );
                ChkStart;
                FOR Index := 1 TO Fact DO
                    BEGIN
                         C1 := C1 + BoxPtr^[ Index ];
                         C2 := C2 + (  BoxPtr^[ Index ] AND OldByte );
                         OldByte := BoxPtr^[ Index ]
                    END
           END;
     Lend := FileSize ( Fl );
     DISPOSE ( BoxPtr );
     SEEK ( Fl, Lend );
     BLOCKWRITE ( Fl, Lend, SIZEOF ( Lend ) );
     ChkStart;
     BLOCKWRITE ( Fl, C1, SIZEOF ( C1 ) );
     ChkStart;
     BLOCKWRITE ( Fl, C2, SIZEOF ( C2 ) );
     ChkStart;
     CLOSE ( Fl );
     ChkStart;
     WRITELN ( Lend, ' ', C1, ' ', C2 )

END.