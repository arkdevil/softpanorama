

               {----------------------------------------------}
               {  Модуль LPtr  V 1.3   пакета   TURBO SUPPORT }
               {  Язык программирования Turbo Pascal V 6.0    }
               {----------------------------------------------}
               { Дата последних изменений : 20/20/1991        }
               {----------------------------------------------}
               {      Модуль включает в себя обьект для       }
               {       работы с печатающим устройством        }
               {----------------------------------------------}
               { (c) 1989-1991, Мигач Ярослав                 }
               {----------------------------------------------}

UNIT Lptr;

{$F+,O+,A+,X+,L-,D-,R-,S-,V-,I-}

INTERFACE

USES Crt, Dos, Def, TWindow;

PROCEDURE epson ( ch : CHAR; VAR key : BOOLEAN );
PROCEDURE List ( Stroka : STRING; VAR key : BOOLEAN );
PROCEDURE ListLn ( Stroka : STRING; VAR key : BOOLEAN );

IMPLEMENTATION

{----------------------------------------------------------}

PROCEDURE epson ( ch : CHAR; VAR key : BOOLEAN );

VAR
   rg : REGISTERS;
   cc: CHAR;
   rm : BOOLEAN;
   ss : STRING;
   all : BOOLEAN;
   Wind : TextWindow;

BEGIN
    IF ( key ) THEN
       EXIT;
    rm := FALSE;
    all := FALSE;
    WHILE ( NOT all ) DO
          BEGIN
               rg.DX := 0;
               rg.AH := 2;
               INTR ( $17, rg );
               IF ( rg.AH = 144 ) THEN
                   all := TRUE
               ELSE
                   IF ( ( NOT rm ) AND ( NOT all ) AND ( rg.AH <> 16 ) AND
                        ( rg.AH <> 208 ) AND ( rg.AH <> 80 ) ) THEN
                      BEGIN
                           Wind.MakeWindow ( 10, 15, 36, 19, RED, BLUE );
                           CASE rg.AH OF
                                 24 :  Wind.WPrint ( 4, 2,
                                       'Включите ON LINE' );
                                 25 :  Wind.WPrint ( 4, 2,
                                       'Включите ON LINE' );
                                 56 :  Wind.WPrint ( 4, 2,
                                       'Нет бумаги' );
                                 57 :  Wind.WPrint ( 4, 2,
                                       'Нет бумаги' );
                                200 :  Wind.WPrint ( 4, 2,
                                       'Включите принтер' )
                           ELSE
                                BEGIN
                                     STR ( rg.AH, ss );
                                     Wind.WPrint ( 4, 2,
                                             'Сбой принтера' );
                                     Wind.WPrint ( 4, 3,
                                             CONCAT ( 'Ошибка # ',ss ) )
                                END
                           END;
                           rm := TRUE;
                           Wind.SetShade ( BLACK, WHITE );
                           Wind.PrintWindow;
                           WRITE ( CHR ( 7 ) )
                       END;
               IF ( ( KEYPRESSED ) AND ( NOT all ) ) THEN
                  BEGIN
                       cc := READKEY;
                       IF ( rm ) THEN
                          Wind.UnFrameDone ( ' ' );
                       rm := FALSE;
                       IF ( cc = CHR ( 27 ) ) THEN
                          BEGIN
                               key := TRUE;
                               EXIT
                          END
                  END

          END;
    IF ( rm ) THEN
       Wind.UnFrameDone ( ' ' );
    rm := FALSE;
    WHILE TRUE DO
          BEGIN
               rg.DX := 0;
               rg.AH := 0;
               rg.AL := ORD ( ch );
               INTR ( $17, rg );
               IF ( ( rg.AH mod 2 ) = 0 ) THEN
                  BEGIN
                       IF ( rm ) THEN
                          Wind.UnFrameDone ( ' ' );
                       EXIT
                  END;
               IF ( ( NOT rm ) AND ( rg.AH <> 208 ) ) THEN
                  BEGIN
                       Wind.MakeWindow ( 10, 15, 36, 19, RED, BLUE );
                           CASE rg.AH OF
                                 24 :  Wind.WPrint ( 4, 2,
                                       'Включите ON LINE' );
                                 25 :  Wind.WPrint ( 4, 2,
                                       'Включите ON LINE' );
                                 56 :  Wind.WPrint ( 4, 2,
                                       'Нет бумаги' );
                                 57 :  Wind.WPrint ( 4, 2,
                                       'Нет бумаги' );
                                200 :  Wind.WPrint ( 4, 2,
                                       'Включите принтер' )
                           ELSE
                                BEGIN
                                     STR ( rg.AH, ss );
                                     Wind.WPrint ( 4, 2,
                                             'Сбой принтера' );
                                     Wind.WPrint ( 4, 3,
                                             CONCAT ( 'Ошибка # ',ss ) )
                                END
                           END;
                       rm := TRUE;
                       Wind.SetShade ( BLACK, WHITE );
                       Wind.PrintWindow;
                       WRITE ( CHR ( 7 ) )
                   END;
               IF KEYPRESSED THEN
                  BEGIN
                       cc := READKEY;
                       IF ( rm ) THEN
                          Wind.UnFrameDone ( ' ' );
                       rm := FALSE;
                       IF ( cc = CHR ( 27 ) ) THEN
                          BEGIN
                               key := TRUE;
                               EXIT
                          END
                  END
           END

END; { procedure epson }

{----------------------------------------------------------}

PROCEDURE List ( Stroka : STRING; VAR key : BOOLEAN );

          { вывод строки на печатающее устройство }
VAR
   index : BYTE;
           { индексная переменная }

BEGIN
     IF ( key ) THEN
        EXIT;
     FOR index := 1 TO LENGTH ( Stroka ) DO
         IF ( NOT key ) THEN
            epson ( Stroka [ index ], key )

END; { procedure List }

{----------------------------------------------------------}

PROCEDURE ListLn ( Stroka : STRING; VAR key : BOOLEAN );

          { вывод строки и перевод строки на печать }

BEGIN
     IF ( key ) THEN
        EXIT;
     List ( Stroka, key );
     IF ( key ) THEN
        EXIT;
     epson ( CHR ( $0D ), key );
     IF ( key ) THEN
        EXIT;
     epson ( CHR ( $0A ), key )

END; { procedure ListLn }

{----------------------------------------------------------}

END.
