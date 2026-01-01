{ VCRLOAD.PAS                                                   }
{ Загрузчик файлов цветов, созданных редактором цветов VCRS.EXE }
{ Автор : Богуш Андрей Витальевич                               }
{         Минск (0172) 27-29-37р                                }
{                      52-69-93д                                }
{ Компилятор Turbo Pascal 5.5                                   }


uses  dos;

type
    coltype = array[0..15,1..3] of byte;

Var
    vgacol   : coltype;

Procedure SetcolReg(rno:byte);
Var
   r : registers;
   cr : byte;
begin
  r.ah := $10;
  r.al := $7;
  r.bl :=rno;
  Intr($10,r);
  cr   := r.bh;

  r.ah := $10;
  r.al := $10;
  r.bx := cr;
  r.dh := vgacol[rno,1];
  r.ch := vgacol[rno,2];
  r.cl := vgacol[rno,3];
  Intr($10,r);
end;

Procedure SetPalette;
Var
   k : byte;
begin
  for k:=0 to 15 do SetcolReg(k);
end;


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
               Writeln('Error in file.'^G);
               Halt;
               end;

       Close(f);
  SetPalette;
end;


begin
Writeln('VGA color registers loader. Copyright (C) Fsoft 1992 by Bogush A.V.');
if ParamCount<1 then begin
                       Writeln('Usage : VCRLOAD filename.vga');
                       Halt;
                     end;
LoadFile;
Writeln('Registers loaded.');
end.