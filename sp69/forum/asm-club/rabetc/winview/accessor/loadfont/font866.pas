{$A+,B-,D+,E-,F-,G-,I+,L+,N-,O-,P-,Q-,R-,S-,T+,V-,X+,Y+}
{$M 16384,0,0}
uses DOS;

const CopR = 'Font 866 loader.  (C) V.S. Rabets, 1994';
var NRows:   byte absolute $40:$84;    { Число строк экрана - 1    }
    Points:  word absolute $40:$85;    { Высота символа в пикселах }
    NCols:   word absolute $40:$4A;    { Ширина экрана в столбцах  }
    RegSize: word absolute $40:$4C;    { Размер буфера регенерации }
    R: registers;

procedure Help;
begin writeln (
   #9'Нерезидентный загрузчик экранного шрифта в кодировке 866.'#13#10 +
   #9'Загружаются шрифты 8x16, 8x14 и 8x8, только в текстовом режиме.'#13#10 +
   #9'При переключении видеорежима загруженный шрифт теряется.');
  writeln (#9'В Volkov Commander''е для устранения шрифта можно дважды нажать Alt-F9.');
  writeln (#9'Возвращаемые значения ErrorLevel:'#13#10 +
              #9#9'0 - шрифт загружен'#13#10 +
              #9#9'1 - выдан справочный экран'#13#10 +
              #9#9'2 - шрифт не загружен');
  halt (1);
end;

procedure Error (Mes: string);
begin
  writeln (Mes,'. Font is not loaded.'#7);
  halt (2);
end;

procedure Font866_16; external;  {$L 866_16.obj}
procedure Font866_14; external;  {$L 866_14.obj}
procedure Font866_08; external;  {$L 866_08.obj}

begin
  writeln (CopR);
  if ParamStr(1)='/?' then Help;
  if NCols*succ(word(NRows))*4<RegSize
     then Error ('The program is not intended for graphic mode');
  with R do begin
       AX:=$1100;
       BL:=0;
       BH:=Points;
       CX:=256;
       DX:=0;
       ES:=CSeg;
       case BH of
           16: BP:=Ofs(Font866_16);
           14: BP:=Ofs(Font866_14);
            8: BP:=Ofs(Font866_08);
           else begin
            write ('Current font height is ', Points);
            Error('.'#13#10'The program supports fonts 8x16, 8x14, 8x8 only');
           end;
       end;
       writeln ('Font 8x', BH, ' loaded. Change videomode to reset font.');
       intr ($10,R);
    end;
end.
