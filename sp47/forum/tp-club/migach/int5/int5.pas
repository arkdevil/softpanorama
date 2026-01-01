

         {----------------------------------------------------}
         {               Модуль Int5 V 1.0                    }
         {     Язык программирования Turbo Pascal  V 6.0      }
         {----------------------------------------------------}
         { Дата последних изменений :  01/10/1991             }
         {----------------------------------------------------}
         {   Модуль предназначен для перехвата прерывания     }
         {                печати экрана                       }
         {----------------------------------------------------}
         { (c) 1991, Мигач Ярослав                            }
         {----------------------------------------------------}


UNIT Int5;

{$F+,O+,A+,R-,S-,D-,L-,B-,I-}

INTERFACE

USES Dos, Crt;

IMPLEMENTATION

{$L WIN}

procedure WriteStr(X, Y: Byte; S: String; Attr: Byte);
external {WIN};

procedure WriteChar(X, Y, Count: Byte; Ch: Char; Attr: Byte);
external {WIN};

procedure FillWin(Ch: Char; Attr: Byte);
external {WIN};

procedure WriteWin(var Buf);
external {WIN};

procedure ReadWin(var Buf);
external {WIN};

function WinSize: Word;
external {WIN};

VAR
   SaveExit : POINTER;
   SaveInt  : POINTER;

PROCEDURE IntLevel; INTERRUPT;

VAR
   Buffer : ARRAY [ 1..$800 ] OF BYTE;

BEGIN
     WINDOW ( 10, 15, 70, 20 );
     TEXTCOLOR ( LIGHTRED );
     TEXTBACKGROUND ( BLACK );
     ReadWin ( Buffer );
     CLRSCR;
     WriteStr ( 10, 3, 'С П А С И Б О   З А   В Н И М А Н И Е !',
                LIGHTGREEN + BLACK * 16 );
     SOUND ( 800 );
     DELAY ( 100 );
     SOUND ( 600 );
     DELAY ( 100 );
     SOUND ( 400 );
     DELAY ( 100 );
     SOUND ( 200 );
     DELAY ( 100 );
     SOUND ( 100 );
     DELAY ( 100 );
     SOUND ( 50 );
     DELAY ( 100 );
     NOSOUND;
     DELAY ( 2000 );
     WriteWin ( Buffer )

END; { procedure IntLevel }

PROCEDURE RestoreInt;

BEGIN
     SetIntVec ( $5, SaveInt );
     ExitProc := SaveExit

END; { procedure RestoreInt }

BEGIN
     SaveExit := ExitProc;
     ExitProc := @RestoreInt;
     GetIntVec ( $5, SaveInt );
     SetIntVec ( $5, ADDR ( IntLevel ) )

END.
