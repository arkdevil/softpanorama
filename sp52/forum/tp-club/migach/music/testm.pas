PROGRAM test_music;

		{---------------------------------}
                {    TEST_MUSIC  V 1.0            }
                {			          }
                {   Демонстрационная программа    }
                {  работы пакета фоновой музыки   }
                {				  }
                {   (c) 1990, Мигач Ярослав       }
                {---------------------------------}

USES Dos, Crt, Music;

VAR
        stroka : STRING;
        indx, k, m, n, x : INTEGER;
        ch : CHAR;

PROCEDURE QUIT;

BEGIN
        Play_off;
        CLRSCR;
        HALT

END;

BEGIN
        n_music ( 1, 200 );
        FOR indx := 1 TO 20 DO
                BEGIN
                     note ( indx * 50, 500 );
                     note ( 0, 55 )
                END;
        FOR indx := 20 DOWNTO 1 DO
            BEGIN
                 note ( indx * 50, 500 );
                 note ( 0, 55 )
            END;
        note ( 0, 1 );
        stroka := ' Проверка работы пакета Music V 1.0, ESC - выход  ';
        CLRSCR;
        k := 1;
        Play_on ( 1 );
        WHILE TRUE DO
              BEGIN
                   n := 30;
                   m := k;
                   WHILE ( ( m < LENGTH ( stroka ) ) AND ( n <> 0 ) ) DO
                         BEGIN
                             GOTOXY ( 35 + ( 15 - n ), 12 );
                             WRITE ( stroka [ m ] );
                                   IF ( KEYPRESSED ) THEN
                                      BEGIN
                                           ch := READKEY;
                                           IF ( ch = CHR ( 27 ) ) THEN
                                              QUIT
                                      END;
                              INC ( m );
                              DEC ( n );
                              DELAY ( 10 )
                         END;
                    x := 1;
                    IF ( ( n <> 0 ) AND ( m >= LENGTH ( stroka ) ) ) THEN
                        WHILE ( n <> 0 ) DO
                              BEGIN
                                   GOTOXY ( 35 + ( 15 - n ), 12 );
                                          WRITE ( stroka [ x ] );
                                                IF ( KEYPRESSED ) THEN
                                                   BEGIN
                                                        ch := READKEY;
                                                        IF ( ch = CHR ( 27 ) ) THEN
                                                           QUIT
                                                    END;
                                           INC ( x );
                                           DEC ( n );
                                           DELAY ( 10 )
                              END;
                     INC ( k );
                     DELAY ( 10 );
                     IF ( k = LENGTH ( stroka ) ) THEN
                        k := 1
            END

END.
