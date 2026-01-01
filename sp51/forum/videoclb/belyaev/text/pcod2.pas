{┌────────────────────────────────────────────╖
 │  Беляев Сергей Владимирович                ║ ░░░░░░░░░░░░░░░░░░░░░░
 │                                            ║ ░░░░░░░░░░░░░░░░░░░░░░
 │  Российская Федерация ,603074,             ║ ░░░░░░░░░░░░░░░░░░░░░░
 │  Нижний Новгород, ул.Народная,38-462.      ║ ░░░░░░░░ <SVB> ░░░░░░░
 │  Тел.  43-26-18 (дом).                     ║ ░░░░░░░░░░░░░░░░░░░░░░
 ╘════════════════════════════════════════════╝ ░░░░░░░░░░░░░░░░░░░░░░
    ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░}

program pcod2;

{ <SVB> 21.01.92 }

uses dos;

const
      alt  ='АБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдежзийклмноп'+
            '░▒▓│┤╡╢╖╕╣║╗╝╜╛┐└┴┬├─┼╞╟╚╔╩╦╠═╬╧╨╤╥╙╘╒╓╫╪┘┌█▄▌▐▀';
      found='░▒▓│┤╡╢╖╕╣║╗╝╜╛┐└┴┬├─┼╞╟╚╔╩╦╠═╬╧╨╤╥╙╘╒╓╫╪┘┌█▄▌▐▀'+
            'ЫЬЭезГДЕЖЧХСТЛМбгижйдкНОУРШЦЩФЪАБВЗИЙКПЮЯвалмноп';
      s_lm = '`abcdefghijklmnopqrstuvwxyz{|}~';
      s_lg = '`ABCDEFGHIJKLMNOPQRSTUVWXYZ{|}~';
      s_rm = 'юабцдефгхийклмнопярстужвьызшэщч';
      s_rg = 'ЮАБЦДЕФГХИЙКЛМНОПЯРСТУЖВЬЫЗШЭЩЧ';
      max  = 10240;

var f  :file;
    ft :text;
    buf:array[1..max] of byte;
    prc:array[0..255] of byte;
    num:word;
    i  :word;
    st:string;
    srf:searchrec;
    dir:dirstr;
    nm :namestr;
    ext:extstr;
    poz:longint;
    s_old,s_new:string;

procedure init;
begin
   For i:=0 to 255 do prc[i]:=i;
   For i:=1 to length(s_old) do prc[ord(s_old[i])]:=ord(s_new[i])
end;

procedure sos;
begin
  writeln;
  writeln('┌────────────────┐');
  writeln('│ <SVB> 31.05.91 └────────────────┐Ключ╓ A - базовая --> альтеpн ╖');
  writeln('│ Программа перекодировки текстов └────╢ F - альтеpн --> базовая ║');
  writeln('│ PCOD2 <path> {<таблица>|/<ключ>}     ║ N - нейpон  --> альтеpн ║');
  writeln('│      пpимеp: PCOD2 F:*.PC  /LmRg     ╙──── LmRm,RgRm,.. ───────╢');
  writeln('│ латинские(L) маленькие (m) --> pусские(R) большие(g)           ║');
  writeln('╘════════════════════════════════════════════════════════════════╝');
  writeln('  Таблица состоит из 2 стpочек: пеpекодиpуются символы');
  writeln('  пеpвой стpоки в символы втоpой');
  halt(0)
end;

procedure CodLR;
begin
     if length(st)<>5 then sos;
     for i:=2 to 5 do st[i]:=upcase(st[i]);
     case pos(copy(st,2,2),'LMLGRMRG') of
       1:s_old:=s_lm;
       3:s_old:=s_lg;
       5:s_old:=s_rm;
       7:s_old:=s_rg
       else sos
     end;
     case pos(copy(st,4,2),'LMLGRMRG') of
       1:s_new:=s_lm;
       3:s_new:=s_lg;
       5:s_new:=s_rm;
       7:s_new:=s_rg
       else sos
     end;
end;

begin
   if paramcount<1 then sos;
   if paramcount=2 then st:=paramstr(2) else st:='/';
   if st[1]<>'/' then begin
      Assign(ft,st);Reset(ft);
      Readln(ft,s_old);Readln(ft,s_new);
      Close(ft) end
   else case upcase(st[2]) of
          'A':begin s_old:=found;s_new:=alt end;
          'F':begin s_old:=alt;s_new:=found end;
          'N':begin s_old:=found+#$14 ;s_new:=alt+' ' end
          else CodLR
        end;
   init;
   st:=paramstr(1);
   Findfirst(st,$27,srf);
   fsplit(st,dir,nm,ext);
   While doserror=0  do
   BEGIN
     st:=dir+srf.name;
     Assign(f,st);Reset(f,1);
     poz:=0;
     while not eof(f) do
      begin
        BlockRead(f,buf,max,num);
        For i:=1 to num do buf[i]:=prc[buf[i]];
        Seek(f,poz);
        BlockWrite(f,buf,num);
        poz:=poz+num
      end;
     Findnext(srf);
     Close(f);
   END;
end.
