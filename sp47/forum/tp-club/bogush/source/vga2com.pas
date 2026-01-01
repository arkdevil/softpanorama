{ VGA2COM.PAS                                    }
{ Конвертер файлов .VGA в исполняемые .COM файлы }
{ Автор : Богуш Андрей Витальевич                }
{         Минск (0172) 27-29-37р                 }
{                      52-69-93д                 }
{ Компилятор Turbo Pascal 5.5                    }



Const
dump1 : array[1..11] of byte=($1E,$B8,$00,$00,$50,$8C,$DA,$EB,$32,$90,$56);


dump2 : array[1..78] of byte=(
$FC,$BE,$0B,$01,$B9,$0F,$00,$B4,$10,$B0,$07,$8A,$D9,$CD,$10,$88,
$3E,$0A,$01,$51,$AC,$8A,$F0,$AC,$8A,$E8,$AC,$8A,$C8,$B7,$00,$8A,
$1E,$0A,$01,$B4,$10,$B0,$10,$CD,$10,$59,$E2,$DB,$B4,$10,$B0,$07,
$B3,$00,$CD,$10,$88,$3E,$0A,$01,$AC,$8A,$F0,$AC,$8A,$E8,$AC,$8A,
$C8,$B7,$00,$8A,$1E,$0A,$01,$B4,$10,$B0,$10,$CD,$10,$CB);




type
    coltype = array[0..15,1..3] of byte;

Var
    vgacol   : coltype;

Procedure LoadFile;
Var
   f:file of byte;
   k,i  : byte;
begin
       Assign(f,Paramstr(1));
       Reset(f);
       Read(f,k);
       if chr(k)='V' then
        begin
          for k:=0 to 15 do
           for i:=1 to 3 do  Read(f,vgacol[k,i]);
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
  for k:=15 downto 0 do
      begin
       Write(f,vgacol[k,1]);
       Write(f,vgacol[k,2]);
       Write(f,vgacol[k,3]);
      end;
  for k:=1 to 78 do Write(f,dump2[k]);
  Close(f);
end;

begin
Writeln('VGA color regs file to .COM converter. Copyright (C) Fsoft 1992 by Bogush A.V.');
if ParamCount<2 then begin
                       Writeln('Usage : VGA2COM filename.vga filename.com');
                       Halt;
                     end;
LoadFile;
WriteCom;
Writeln('File converted. You can run '+ParamStr(2)+' to load VGA color registers.');
end.