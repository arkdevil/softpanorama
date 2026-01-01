
PROGRAM UKR_LPT;

USES Dos, Crt, Def, Lptr, TWindow;

VAR
   Index : WORD;
   Hlp : BYTE;
   Key : BOOLEAN;
   HelpS : StandartString;

BEGIN
     Key := FALSE;
     Hlp := 0;
     FOR Index := 32 TO 255 DO
         BEGIN
              STR ( Index, HelpS );
              WHILE ( LENGTH ( HelpS ) <> 3 ) DO
                    HelpS := '0' + HelpS;
              HelpS := ' ' + HelpS +
              '- ' + CHR ( Index );
              List ( HelpS, Key );
              INC ( Hlp );
              IF ( Hlp = 6 ) THEN
                 BEGIN
                      ListLn ( '', Key );
                      Hlp := 0
                 END;
         END;
     List ( CHR ( 12 ), Key );
     WINDOW ( 1, 1, 80, 25 );
     TEXTCOLOR ( LIGHTGRAY );
     TEXTBACKGROUND ( BLACK );
     GOTOXY ( 1, 25 )
END.
