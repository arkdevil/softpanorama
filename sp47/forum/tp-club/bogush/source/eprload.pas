{ EPRLOAD.PAS                                                            }
{ Загрузчик палитры EGA из файла, созданного редактором палитры EPRS.EXE }
{ Автор : Богуш Андрей Витальевич                                        }
{         Минск (0172) 27-29-37р                                         }
{                      52-69-93д                                         }
{ Компилятор Turbo Pascal 5.5                                            }


uses  dos;

type
    ptype = array[0..15] of byte;

Var
    egapal   : ptype;

Procedure SetPalReg(rno:byte);
Var
   r : registers;
   cr : byte;
begin
  r.ah := $10;
  r.al := 0;
  r.bl := rno;
  r.bh := egapal[rno];
  Intr($10,r);
end;

Procedure SetPalette;
Var
   k : byte;
begin
  for k:=0 to 15 do SetPalReg(k);
end;


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
               Writeln('Error in file.'^G);
               Halt;
               end;

       Close(f);
  SetPalette;
end;


begin
Writeln('EGA palette registers loader. Copyright (C) Fsoft 1992 by Bogush A.V.');
if ParamCount<1 then begin
                       Writeln('Usage : EPRLOAD filename.ega');
                       Halt;
                     end;
LoadFile;
Writeln('Registers loaded.');
end.