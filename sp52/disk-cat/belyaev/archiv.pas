{┌────────────────────────────────────────────╖
 │  Беляев Сергей Владимирович                ║ ░░░░░░░░░░░░░░░░░░░░░░
 │                                            ║ ░░░░░░░░░░░░░░░░░░░░░░
 │  Российская Федерация ,603074,             ║ ░░░░░░░░░░░░░░░░░░░░░░
 │  Нижний Новгород, ул.Народная,38-462.      ║ ░░░░░░░░ <SVB> ░░░░░░░
 │  Тел.  43-26-18 (дом).                     ║ ░░░░░░░░░░░░░░░░░░░░░░
 ╘════════════════════════════════════════════╝ ░░░░░░░░░░░░░░░░░░░░░░
    ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░}

{$M 16384,0,64000}

{##################  <SVB> 22 июля 1992 года  ##########################}
{#  Программа для получения информации о файлах во всех подкаталогах,  #}
{#  если встречаются архивы с расширениями .LZH, .ZIP, .ARC, .ARJ, то  #}
{#  сообщается информация об их содержимом                             #}
{#######################################################################}

program ARCHIV2;

uses  crt,dos;

type  typ_pol =(nm,sz,dd,mm,yy,hh,mi);
      typ_arc =(_zip,_arc,_arj,_lzh,_out);

const  s_o:string[35] ='12345678.123 1234567 DD-MM-YY HH:MM';
       format:array[_zip.._out,nm..mi] of byte =
         ((63, 1,31,34,37,41,44),  {v.1.93  zip !!! для предыдущих - 62,... }
          ( 1,16,54,51,57,61,64),  {v.3.5   arc}
          ( 1,17,48,45,42,51,54),  {v.2.30  lzh}
          ( 3,18,49,46,43,52,55),  {v.2.11  arj}
          ( 1,14,22,25,28,31,34));
       typ_name:array[_zip.._lzh] of string[3] =('ZIP','ARC','ARJ','LZH');
       typ_prg :array[_zip.._lzh] of string[12] =
         ('pkunzip -v ',
          'pkxarc -v ',
          'arj l ',
          'lha ');
       len_pol :array[nm..mi] of byte = (12,7,2,2,2,2,2);
       beg_end :array[_zip.._lzh] of byte = (26,45,36,37);
       ch_stop =['-','─'];

var   ff,fo      :text;
      bufo       :array[1..5120] of byte;
      str        :string;
      tp         :typ_arc;
      np         :typ_pol;
      disk       :string[1];
      filebuf    :string[80];
      i,j        :word;

procedure wword(x:word;y:char);
begin
  x:=x mod 100;
  if x<10 then write(fo,'0');
  if y<>'s' then write(fo,x,y) else writeln(fo,x)
end;

procedure readstr;
begin FillChar(str,sizeof(str),' ');Readln(ff,str) end;

procedure poisk(x:string);
var   f :searchrec;
      p :^searchrec;
      datt:datetime;

begin
   writeln(fo,'     Каталог    ',x);writeln(fo);

   FindFirst(x+'\'+'*.*',$27,f);
   while DosError=0 do begin
        write(fo,f.name);write(fo,f.size:20-length(f.name),' ');
        unpacktime(f.time,datt);
        wword(datt.day,'-');wword(datt.month,'-');wword(datt.year,' ');
        wword(datt.hour,':');wword(datt.min,'s');
        FindNext(f)
   end;
   writeln(fo);

   for tp:=_zip to _lzh do begin
     FindFirst(x+'\'+'*.'+typ_name[tp],$27,f);
     while DosError=0 do
        begin
          writeln(fo,'     Архив      ',f.name);
          swapvectors;
          exec(GetEnv('COMSPEC'),'/C '+typ_prg[tp]+x+'\'+f.name+'>'+filebuf);
          swapvectors;
          writeln(f.name);
          if DosError<>0 then writeln('ОШИБКА ',DosError);
          Reset(ff);
          Repeat readstr until (str[beg_end[tp]] in ch_stop) or eof(ff);
          Readstr;
          While not((str[beg_end[tp]] in ch_stop) or eof(ff)) do begin
            for np:=sz to mi do
              move(str[format[tp,np]],s_o[format[_out,np]],len_pol[np]);
            i:=format[tp,nm];
            Repeat
              j:=pos('/',copy(str,i,255));
              if j>0 then i:=i+j
            Until j=0;
            move(str[i],s_o[format[_out,nm]],12);
            if copy(s_o,1,8)<>'        ' then Writeln(fo,s_o);Readstr;
          end;
          close(ff);writeln(fo);FindNext(f)
        end;
   end;
   writeln(fo,'     Конец      ',x);
   writeln(fo);

   FindFirst(x+'\*.*',$10,f);
   while DosError=0 do begin
     if (f.attr=$10) and (f.name[1]<>'.') then begin
       new(p);p^:=f; poisk(x+'\'+f.name);
       f:=p^;dispose(p) end;
     FindNext(f)
   end
end;

procedure sos;
begin
   clrscr;TextColor(4);
   Writeln('<SVB> 22.07.92');TextColor(11);Window(10,5,70,20);
   Writeln('Программа Archiv предназначена для вывода информации о');
   Writeln('файлах в указанном каталоге и во всех его подкаталогах.');
   Writeln('В открытых каталогах должны быть файлы для распаковки:');
   Writeln('──────── PkxArc ─── PkUnzip ─── LHa ──── Arj ────────');
   TextColor(14);
   Writeln(#10'Формат команды: Archiv <инф.кат> [<файл>] [<буф.кат>]');
   TextColor(11);
   Writeln(#10'<инф.кат> - католог, о котором выводится информация;');
   Writeln('<буф.кат> - католог для промежуточных файлов');
   Writeln('<файл>    - файл для вывода информации');
   TextColor(10);
   Writeln(#13#10'Пример: '#10'Archiv a: inf.txt');
   TextColor(12);
   Write('──────────── arc ─── zip ─── lzh ─── arj ─────────────');
   halt(0)
end;

begin
     if paramcount<1 then sos;
     if paramcount=3 then filebuf:=paramstr(3)+'qq.$$$'
     else filebuf:='qq.$$$';
     assign(ff,filebuf);
     if paramcount>=2 then assign(fo,paramstr(2)) else assign(fo,'con');
     Rewrite(fo);SetTextBuf(fo,bufo);
     disk:=copy(Fexpand(paramstr(1)+'\*.*'),1,1);
     writeln(fo,'Свободно     ',DiskFree(ord(disk[1])-64));
     writeln(fo);
     poisk(paramstr(1));
     close(fo);erase(ff);
end.
