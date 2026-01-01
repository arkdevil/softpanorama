
               {------------------------------------------------}
               {  Модуль Font_PM  V 1.0  пакета   TURBO SUPPORT }
               {  Язык программирования Turbo Pascal V 6.0      }
               {------------------------------------------------}
               { Дата последних изменений : 20/10/1992          }
               {------------------------------------------------}
               {      Модуль включает в себя обьект для         }
               {       работы с печатающим устройством          }
               {        в качестве печатающей машинки           }
               {------------------------------------------------}
               { (c) 1992,   IPM Group                          }
               {  Программа        - Ярослав Мигач              }
               {  Шрифт подготовил - Андрей Букин               }
               {------------------------------------------------}

UNIT Font_PM;

{$F+,O+,A+,X+,L-,D-,R-,S-,V-,I-}
{$L FONT_PM.OBJ }

INTERFACE

USES LPtr;

PROCEDURE PMLineList ( Line : STRING; VAR Key : BOOLEAN );
PROCEDURE PMList ( Line : STRING; VAR Key : BOOLEAN );
PROCEDURE SetPMInterval ( Int : BYTE );
FUNCTION GetPMInterval : BYTE;

IMPLEMENTATION

TYPE
    PartFont = ARRAY [ $21..255, 1..24 ] OF BYTE;
    FontType = ARRAY [ 1..4 ] OF PartFont;

{----------------------------------------------------------}

PROCEDURE FontPrintMachine; FAR; EXTERNAL;

VAR
   PointFont : ^FontType;
             { Указатель на массив шрифта }

   LinePrint : STRING;
             { Накапливаемая печатаемая строка }

   Interval : BYTE;
             { Интервал перевода строк }

{----------------------------------------------------------}

PROCEDURE SetPointFont;

          { Установить указатель на таблицу шрифтов }
BEGIN
     PointFont := ADDR ( FontPrintMachine )

END; { PROCEDURE SetPointFont }

{----------------------------------------------------------}

PROCEDURE SendSymbol ( Cod, Kvadr : BYTE; VAR Key : BOOLEAN );

          { Передать  четверть символа }
VAR
   Index : BYTE;

BEGIN
     IF ( Key ) THEN
        EXIT;
     IF ( Cod < $21 ) THEN
        Cod := ORD ( $FF );
     FOR Index := 1 TO 24 DO
         List ( CHR ( PointFont^ [ Kvadr ] [ Cod, Index ] ), Key )

END; { PROCEDURE SendSymbol }

{----------------------------------------------------------}

PROCEDURE LineFead ( VAR Key : BOOLEAN );

          { Сброс принтера, перевод страницы }
BEGIN
     List ( #$1B + #$40, Key );
     List ( #12, Key );

END; { PROCEDURE LineFead }

{----------------------------------------------------------}

PROCEDURE PMLineList ( Line : STRING; VAR Key : BOOLEAN );

          { Печать строки с переводом каретки }
VAR
   SizeFont : WORD;
   Ind : BYTE;

BEGIN
     IF ( Key ) THEN
        EXIT;
     LinePrint := LinePrint + Line;

     FOR Ind := 1 TO LENGTH ( LinePrint ) DO
         IF ( LinePrint [ Ind ] = #12 ) THEN
            LineFead ( Key );
     SizeFont := 24 * LENGTH ( Line );
     List ( #$1B + #$45, Key );

     List ( #$1B + #$5A +
            CHR ( LO ( SizeFont ) ) + CHR ( HI ( SizeFont ) ), Key );
     FOR Ind := 1 TO LENGTH ( Line ) DO
         SendSymbol ( ORD ( Line [ Ind ] ), 1, Key );

     List ( #$1B + #$33 + #$01 + #$0D + #$0A, Key );

     List ( #$1B + #$5A +
            CHR ( LO ( SizeFont ) ) + CHR ( HI ( SizeFont ) ), Key );
     FOR Ind := 1 TO LENGTH ( Line ) DO
         SendSymbol ( ORD ( Line [ Ind ] ), 2, Key );

     List ( #$1B + #$33 + #$0E + #$0D + #$0A, Key );

     List ( #$1B + #$5A +
            CHR ( LO ( SizeFont ) ) + CHR ( HI ( SizeFont ) ), Key );
     FOR Ind := 1 TO LENGTH ( Line ) DO
         SendSymbol ( ORD ( Line [ Ind ] ), 3, Key );

     List ( #$1B + #$33 + #$01 + #$0D + #$0A, Key );

     List ( #$1B + #$5A +
            CHR ( LO ( SizeFont ) ) + CHR ( HI ( SizeFont ) ), Key );
     FOR Ind := 1 TO LENGTH ( Line ) DO
         SendSymbol ( ORD ( Line [ Ind ] ), 4, Key );

     List ( #$1B + #$33 + CHR ( Interval ) + #$0D + #$0A, Key );

     LinePrint := ''

END; { PROCEDURE PMLineList }

{----------------------------------------------------------}

PROCEDURE PMList ( Line : STRING; VAR Key : BOOLEAN );

          { Печать строки без перевода каретки }
BEGIN
     IF ( Line = #12 ) THEN
        LineFead ( Key )
     ELSE
         LinePrint := LinePrint + Line

END; { PROCEDURE PMList }

{----------------------------------------------------------}

PROCEDURE SetPMInterval ( Int : BYTE );

          { Установить интервал }
BEGIN
     IF ( Int >= 10 ) THEN
        Interval := Int

END; { PROCEDURE SetPMInterval }

{----------------------------------------------------------}

FUNCTION GetPMInterval : BYTE;

         { Получить интервал }
BEGIN
     GetPMInterval := Interval

END; { FUNCTION GetPMInterval }

{----------------------------------------------------------}

BEGIN
     LinePrint := '';
     Interval := $34;
     SetPointFont

END. { Unit Font_PM }
