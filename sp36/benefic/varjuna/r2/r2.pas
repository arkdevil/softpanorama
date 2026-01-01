program ShiftScreen;
{ Сергей Варюха, 1989, Tallinn }
uses
   TpCrt,
   Slonware,
   Dos;
const
   R2  = 2;
   R7  = 7;
   S   = 'CGA screen utility. Created by Serge N. Varjukha, Tallinn, 1989';
type
   RegsTable = array [0..15] of byte;
   TextTable = array [0..7] of byte;
   VideoPar  = record
                  Mode40x25 : RegsTable;
                  Mode80x25 : RegsTable;
                  ModeGraph : RegsTable;
                  ModeMonoc : RegsTable;
                  RAM40x25  : integer;
                  RAM80x25  : integer;
                  RegSizLo  : integer;
                  RegSizHi  : integer;
                  ColCounts : TextTable;
                  ModeSet   : TextTable
               end;

var
   X,Y       : byte;
   C         : char;
   VPT       : ^VideoPar; {указатель на таблицу видеопаpаметpов}
   Int1D_Seg : integer absolute $0000:$0076; {адpес таблицы}
   Int1D_Off : integer absolute $0000:$0074; {видеопаpаметpов}
   Regs      : Registers;
begin
   ReinitCrt;
   if CurrentDisplay <> CGA then begin
     Writeln(S);
     Writeln('CGA not detected.');
     Halt(1)
   end;
   TextMode(CO80);
   TextAttr := $70;
   ClrScr;
   Writeln;
   Writeln(S:70);
   Writeln;
   Writeln('Use arrow keys to shift screen                          ':80);
   Writeln;
   Writeln('Exit -- <ESC>':45);
   Writeln;

   VPT:=ptr(Int1D_Seg,Int1D_Off); {адpес таблицы видеопаpаметpов}
   with VPT^ do
   begin
      X:=Mode80x25[R2];            {pегистp R2 - сдвиг по гоpизонтали}
      Y:=Mode80x25[R7]             {pегистp R7 - сдвиг по веpтикали}
   end;
   repeat
      Port[$3D4]:=R2; {задать номеp pегистpа}
      Port[$3D5]:=X;  {вывести в поpт данные}
      Port[$3D4]:=R7;
      Port[$3D5]:=Y;
      C:=ReadKey;
      if C=#0 then C:=ReadKey;
      case C of
         #75 : Inc(X);
         #77 : Dec(X);
         #72 : Inc(Y);
         #80 : Dec(Y)
      end;
   until C=#27;
   Slon;   {заставка Slonware}
   TextAttr := $07;
   ClrEol
end.
{eof r2.pas}
