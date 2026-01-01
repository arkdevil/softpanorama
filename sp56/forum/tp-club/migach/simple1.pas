
PROGRAM Simple1;

USES Crt, FKey11;

TYPE
    Location = RECORD
                     X : INTEGER;
                     Y : INTEGER;
               END;

VAR
   CoordM : Location;
   CoordV : Location;
   CoordHelp : Location;
   NewGame : BYTE;
   RorL, UorD : BYTE;
   Level : BYTE;
   BitKArta : ARRAY [1..10] OF BYTE;
   ColorKub : BYTE;
   Index, DY, i : BYTE;
   Ch : CHAR;
   Col, IndKub, IndexY, IndexX, help :BYTE;

{----------------------------------------------------------}

PROCEDURE SetLocation ( Loc : Location; Ch : STRING );

BEGIN
     GOTOXY ( Loc.X, Loc.Y );
     WRITE ( Ch )

END; { Procedure SetLocation }


{----------------------------------------------------------}

PROCEDURE Color ( IndColor : BYTE );

BEGIN
     TEXTBACKGROUND ( IndColor );

END; { PROCEDURE Color }

{----------------------------------------------------------}

PROCEDURE Kub ( Loc : Location );

BEGIN
     ColorKub := 1 + RANDOM ( 6 );
     FOR Index := 1 TO 2 DO
         BEGIN
              Color ( ColorKub );
              SetLocation ( Loc, '       ' );
              Color ( 0 );
              SetLocation ( Loc, ' ' );
              INC ( Loc.Y )
         END;
     SetLocation ( Loc, '        ' );
END; { PROCEDURE Kub }

{----------------------------------------------------------}

PROCEDURE UnKub ( Loc : Location );

BEGIN
     Color ( 0 );
     FOR Index := 1 TO 2 DO
         BEGIN
              SetLocation ( Loc, '        ' );
              INC ( Loc.Y )
         END;
     SetLocation ( Loc, '        ' );
END; { PROCEDURE UnKub }

{----------------------------------------------------------}

PROCEDURE Bool ( VAR Loc : Location; LorR, UporDown : STRING );

BEGIN
     TEXTCOLOR ( 5 );
     SetLocation ( Loc , ' ' );
     IF ( LorR = 'Right' ) THEN
        BEGIN
             INC ( Loc.X, 2 );
             IF ( UPorDOWN = 'Down' ) THEN
                INC ( Loc.Y )
             ELSE
                DEC ( Loc.Y );
        END
     ELSE
        BEGIN
             DEC ( Loc.X, 2 );
             IF ( UPorDOWN = 'Down' ) THEN
                INC ( Loc.Y )
             ELSE
                DEC ( Loc.Y );
        END;

     SetLocation ( Loc , '*' );

END; { PROCEDURE Bool }

{----------------------------------------------------------}

PROCEDURE Raketka ( VAR Loc : Location );

BEGIN
     IF ( NOT KEYPRESSED ) THEN
        EXIT;
     Ch := READKEY;
     IF ( Ch = #0 ) THEN
        BEGIN
             Ch := READKEY;
             TEXTCOLOR ( LIGHTRED );
             SetLocation ( Loc, '     ' );
             CASE Ch OF

             Arrow_Left  : BEGIN
                                IF ( Loc.X <> 1 ) THEN
                                   DEC ( Loc.X )
                           END;

             Arrow_Right : BEGIN
                                IF ( Loc.X <> 80 ) THEN
                                   INC ( Loc.X )
                           END;

             #27         : NewGame := 0

             ELSE
                BEGIN
                      SOUND ( 800 );
                      DELAY ( 300 );
                      NOSOUND
                END

             END; { case }

             SetLocation ( Loc, '#####' )

        END;

END; { PROCEDURE }

{----------------------------------------------------------}

FUNCTION VARleftORr ( VARrorl : BYTE ) : STRING;

BEGIN
     IF ( ( VARRorL MOD 2 ) = 0 ) THEN
        VARleftORr := 'Left'
     ELSE
        VARleftORr := 'Right';
END; { FUNCTION VARleftORr }

{----------------------------------------------------------}

FUNCTION VARupORd ( VARUorD : BYTE ) : STRING;

BEGIN
     IF ( ( VARUorD MOD 2 ) = 0 ) THEN
        VARupORd := 'Up'
     ELSE
        VARupORd := 'Down';

END; { FUNCTION VARupORdf }

{----------------------------------------------------------}

BEGIN { Program }
   RANDOMIZE;
   NewGame := 0;
   WHILE ( NewGame = 0 ) DO
    BEGIN
     TEXTBACKGROUND ( BLACK );
     CLRSCR;
     WINDOW ( 1, 1, 80, 25 );
     CoordM.y := 1 ;
     WHILE ( CoordM.y < 12 ) DO
           BEGIN
                CoordM.x := 1 ;
                WHILE ( CoordM.x < 80 ) DO
                      BEGIN
                           Kub ( CoordM );
                           INC ( CoordM.x , 8 );
                      END;
                INC ( CoordM.y , 3 )
           END;


     CoordM.X := 2;
     CoordM.Y := 23;
     TEXTCOLOR ( LIGHTRED );
     SetLocation ( CoordM , '#####' );

     CoordV.X := 1;
     CoordV.Y := 13;
     TEXTCOLOR ( 5 );
     SetLocation ( CoordV , '*' );

     RorL := 1;
     UorD := 1;
     FOR i := 1 TO 10 DO
         BitKarta [ i ] := 1;
     Level := 13;
     Bool ( CoordV, 'Right', 'Down' );
     Raketka ( CoordM );

     WHILE ( (CoordV.Y < 22) AND (Level > 1) ) DO
          BEGIN
               IF ( ( CoordV.X > ( CoordM.X - 1 ) )
                    AND ( CoordV.X < ( CoordM.X + 5 ) )
                    AND ( CoordV.Y = 22 ) ) THEN
                 INC ( UorD );
               IF ( CoordV.Y = Level ) THEN
                  BEGIN
                       INC ( UorD );
                       RorL := 1 + RANDOM ( 1 );
                       BitKarta [ ( CoordV.X DIV 8 ) + 1 ] := 0;
                       CoordHelp.X := ( CoordV.X DIV 8 ) * 8;
                       CoordHelp.Y := Level + 4 ;
                       UnKub ( CoordHelp );
                  END;
               IF ( ( CoordV.X = 1 ) OR ( CoordV.x = 80 ) ) THEN
                  INC ( RorL );
               DELAY ( 20 );
               Bool ( CoordV, VARleftORr ( RorL ), VARupORd ( UorD ) );
               Raketka ( CoordM );
               help := 0;
               FOR i := 1 TO 10 DO
                   IF ( BitKArta [i] <> 0 ) THEN
                      help := 1;
               IF ( help = 0 ) THEN
                      DEC ( Level,3 );

          END; { WHILE }

     DELAY ( 200 );

     IF ( CoordV.Y = 22 ) THEN
        WHILE ( CoordV.Y < 25 ) DO
              BEGIN
                   Bool ( CoordV, VARleftORr ( RorL ), VARupORd ( UorD ) );
              END;

     IF ( Level = 1 ) THEN
        BEGIN
             CLRSCR;
             WINDOW ( 22, 8, 58, 17 );
             TEXTBACKGROUND ( RED );
             READ ( NewGame )
        END

   END; { big WHILE }

END. { Program }