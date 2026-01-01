{ EGA2COM.PAS                                    }
{ Конвертер файлов .EGA в исполняемые .COM файлы }
{ Автор : Богуш Андрей Витальевич                }
{         Минск (0172) 27-29-37р                 }
{                      52-69-93д                 }
{ Компилятор Turbo Pascal 5.5                    }



Const
dump1 : array[1..11] of byte=($1E,$B8,$00,$00,$50,$8C,$DA,$EB,$12,$90,$45);

dump2 : array[1..32] of byte=(
$FC,$BE,$0B,$01,$B9,$0F,$00,$8A,$D9,$AC,$8A,$F8,$B0,$00,$B4,$10,
$CD,$10,$E2,$F3,$B3,$00,$AC,$8A,$F8,$B0,$00,$B4,$10,$CD,$10,$CB);




type
    ptype = array[0..15] of byte;

Var
    egapal   : ptype;

Procedure LoadFile;
Var
   f:file of byte;
   k,i  : byte;
begin
       Assign(f,Paramstr(1));
       Reset(f);
       Read(f,k);
       if chr(k)='E' then
        begin
          for k:=0 to 15 do Read(f,egapal[k]);
        end
          else begin
               Writeln('Bad header in input file.'^G);
               Halt;
               end;

       Close(f);
end;

Procedure WriteCom;
Var f: file of byte;
    k : byte;
begin
  Assign(f,ParamStr(2));
  Rewrite(f);
  for k:=1 to 11 do Write(f,dump1[k]);
  for k:=15 downto 0 do Write(f,egapal[k]);
  for k:=1 to 32 do Write(f,dump2[k]);
  Close(f);
end;

begin
Writeln('EGA palette regs file to .COM converter.Copyright (C) Fsoft 1992 by Bogush A.V.');
if ParamCount<2 then begin
                       Writeln('Usage : EGA2COM filename.ega filename.com');
                       Halt;
                     end;
LoadFile;
WriteCom;
Writeln('File converted. You can run '+ParamStr(2)+' to load EGA palette registers.');
end.