{┌────────────────────────────────────────────╖
 │  Беляев Сергей Владимирович                ║ ░░░░░░░░░░░░░░░░░░░░░░
 │                                            ║ ░░░░░░░░░░░░░░░░░░░░░░
 │  Российская Федерация ,603074,             ║ ░░░░░░░░░░░░░░░░░░░░░░
 │  Нижний Новгород, ул.Народная,38-462.      ║ ░░░░░░░░ <SVB> ░░░░░░░
 │  Тел.  43-26-18 (дом).                     ║ ░░░░░░░░░░░░░░░░░░░░░░
 ╘════════════════════════════════════════════╝ ░░░░░░░░░░░░░░░░░░░░░░
    ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░}

program pal_gif;

{ <SVB> 28.04.92 }

uses  disk;

type  tri = array[1..3] of byte;

var   f,o  :word;
      num  :word;
      lon  :longint;
      i    :byte;
      pal1 :array[0..16] of byte;
      pal2 :array[0..16] of tri;

procedure err;
begin
     Writeln(#7'Error !');halt(1)
end;

procedure conv(x:byte;var y:tri);
var i,b:byte;
begin
    for i:=0 to 2 do
    begin
      b:=(x and (9 shl i)) shr i;
      case b of
        0:y[3-i]:=0;
        1:y[3-i]:=$AA;
        8:y[3-i]:=$55;
        9:y[3-i]:=$FF;
      end;
    end;
end;

begin
     if paramcount<>2 then begin
       writeln;
       writeln('╓────────────────────────────────────────────────┐');
       writeln('║ Command: Pal_GIF <file.pcs> <file.gif>         │');
       writeln('║ Пеpенос палитpы из файла, созданного с помощью │');
       writeln('║ пpогpаммы Ega3arc в файл  *.GIF                │');
       writeln('╚════════════════════════════════════════════════╛');
       halt(1)
     end;
     if Ofile(f,0,paramstr(1)) then err;
     if Ofile(o,2,paramstr(2)) then err;
     if Rfile(f,pal1,16,num) then err;
     if Sfile(o,0,13,lon) then err;
     for i:=0 to 15 do conv(pal1[i],pal2[i]);
     if Wfile(o,pal2,48,num) then err;
     if Cfile(f) then err;if Cfile(o) then err;
end.
