
PROGRAM AntiGame;

{$M $1400, 0, 0 }
{$F+,O-,S-}
USES Crt, DOS;

{$L ANTIGAME.OBJ }
{$L WIN.OBJ }

VAR
   Intp10 : PROCEDURE;
   Int10 : POINTER;

{----------------------------------------------------------}

PROCEDURE Analiz; INTERRUPT; EXTERNAL;
PROCEDURE InitDs; NEAR; EXTERNAL;

{----------------------------------------------------------}

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

{----------------------------------------------------------}

PROCEDURE Ukr;
Const Max = 145;Buf:Array[1..Max,1..2] Of Word =( {$I ukr.INC} (0,0));
Var        I : Word;

 Procedure Snd(Herz,Dlit:Word);                    
  Begin If Herz = 0 Then Begin NoSound;Delay(Dlit);
  End Else Begin Sound(Herz);Delay(Dlit);          
  End;  End;                                       

BEGIN

  for i:= 1 to Max Do Begin
   if KeyPressed Then Begin			
    End Else  Snd(Buf[I,1],Buf[I,2]);
  End;
  NoSound;

END; { procedure Ukr }

{----------------------------------------------------------}

PROCEDURE SetBackGround8;NEAR;

          { установить 8 фоновых цветов }
VAR
     rg : REGISTERS;

BEGIN
     rg.AH := $10;
     rg.AL := 03;
     rg.BL := 1;
     INTR ( $10, rg )

END; { procedure SetBackGround8 }

{----------------------------------------------------------}

PROCEDURE SetBackGround16;NEAR;

          { установить 16 фоновых цветов /EGA/VGA }
VAR
    rg : REGISTERS;

BEGIN
     rg.AH := $10;
     rg.AL := 03;
     rg.BL := 0;
     INTR ( $10, rg )

END; { procedure SetBackGround16 }

{----------------------------------------------------------}

PROCEDURE Finish; FAR;

          { Вывод сообщения и прерывание задачи }
VAR
   Buffer : ARRAY [ 1..$1000 ] OF BYTE;

BEGIN
     SetIntVec ( $10, Int10 );
     SetBackGround16;
     WINDOW ( 1, 1, 80, 25 );
     ReadWin ( Buffer );
     TEXTBACKGROUND ( WHITE );
     CLRSCR;
     WINDOW ( 10, 9, 70, 21 );
     TEXTCOLOR ( LIGHTRED );
     TEXTBACKGROUND ( BLUE );
     CLRSCR;
     WriteStr ( 10, 3, 'С П А С И Б О   З А   В Н И М А Н И Е !',
                LIGHTRED + LIGHTBLUE * 16 );
     WriteStr ( 10, 5, 'Ваша программа нарушает правила работы ',
                BLACK + WHITE * 16 );
     WriteStr ( 10, 6, '        за этим компьютером            ',
                BLACK + WHITE * 16 );
     WriteStr ( 10, 10, '       (c)  1992  Ярослав Мигач       ',
                WHITE + LIGHTMAGENTA * 16 );
     Ukr;
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
     SetBackGround8;
     SetIntVec ( $10, Addr ( Analiz ) );
     WINDOW ( 1, 1, 80, 25 );
     WriteWin ( Buffer );
     GOTOXY ( 1, 25 );
     TEXTCOLOR ( LIGHTGRAY );
     TEXTBACKGROUND ( BLACK );
     HALT ( 1 )

END; { procedeure Finish }

{----------------------------------------------------------}

BEGIN
     EXEC ( 'AIDSTEST.EXE', PARAMSTR ( 1 ) );
     InitDs;
     GetIntVec ( $10, Int10 );
     SetIntVec ( $10, Addr ( Analiz ) );
     KEEP ( 0 )

END.
