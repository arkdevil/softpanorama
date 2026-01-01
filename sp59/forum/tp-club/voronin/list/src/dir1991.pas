unit dir1991;
interface
       procedure dir(var nameoffile:string; var color:integer);
implementation

uses crt,dos,lookfile;
var s1:string;
procedure dir;
      type
           lin=string[12];
           lin1=string[4];
var
  c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c0:integer;
           fn:array[1..400] of lin;
           at:array[1..400] of lin1;
           as:array[1..400] of real;
           ch:char;
           f:text;
           funckey:boolean;
           mr,d,d1,s1,sh,d2,d3:string;
           y,i,m,n,ind,k,j:integer;
           s:searchrec;

label
  1,2,3,4,7,8,10,11,71,72,77,78,79,81,87,100;

begin
if color=1 then begin
  c0:=0;    c1:=1;     c2:=2;     c3:=3;      c4:=4;
  c5:=5;    c6:=6;     c7:=7;     c8:=8;      c9:=9;
  c10:=10;  c11:=11;   c12:=12;   c13:=13;    c14:=14;
  c15:=15;  end else begin
  c0:=0;    c1:=0;     c2:=0;     c3:=7;      c4:=7;
  c5:=0;    c6:=0;     c7:=0;     c8:=7;      c9:=15;
  c10:=15;   c11:=15;    c12:=15;    c13:=15;     c14:=15;
  c15:=15;   end;
2:        getdir(0,sh);
        window(1,1,80,25);
        textbackground(c0); clrscr;
        textbackground(c5); textcolor(c11);
        gotoxy(37,5); write('╔════════════════════════════════════════╗');
        for i:=1 to 18 do begin
        gotoxy(37,5+i); write('║                                        ║');
        end;
        gotoxy(37,24); write('╚════════════════════════════════════════╝');
        textcolor(c14);
        gotoxy(40,07); write('        РАБОТА  С  КАТАЛОГОМ        ');
        gotoxy(40,08); write('                                    ');
        gotoxy(40,09); write('┌──────────────────────────────────┐');
        gotoxy(40,10); write('│                                  │');
        gotoxy(40,11); write('│  ENTER - Выбрать файл            │');
        gotoxy(40,12); write('│  ESC - Выйти без выбора файла    │');
        gotoxy(40,13); write('│  F10   или отменить выбранный    │');
        gotoxy(40,14); write('│        файл                      │');
        gotoxy(40,15); write('│  F1 -  смена накопителя          │');
        gotoxy(40,16); write('│  F3 -  просмотр файла            │');
        gotoxy(40,17); write('│  F6 -  переименование файла      │');
        gotoxy(40,18); write('│  F8 -  удаление файла            │');
        gotoxy(40,19); write('│       ТЕКУЩИЙ НАКОПИТЕЛЬ:        │');
        gotoxy(40,20); write('│                                  │');
        gotoxy(40,21); write('│                                  │');
        gotoxy(40,22); write('│                                  │');
        gotoxy(40,23); write('└──────────────────────────────────┘');
        getdir(0,d1); textcolor(c15); textbackground(c4);
        gotoxy(43,20); write('╔═══════════════════════════╗');
        gotoxy(43,21); write('║  ',copy(d1,1,2),'                       ║');
        gotoxy(43,22); write('╚═══════════════════════════╝');

1:      for i:=1 to 400 do begin fn[i]:='                   '; at[i]:=''; as[i]:=0; end;
        window(1,1,80,25);
        mr:='*.*'; m:=17; n:=1; ind:=0;
        findfirst(mr,AnyFile,s);
        if doserror=18 then begin fn[1]:='Файлов нет'; goto 77; end;
    72: d1:=SearchRec(s).Name;
        str(SearchRec(s).Attr,d);   at[1]:=d;
    78: fn[1]:=d1;  as[1]:=SearchRec(s).Size;
        n:=2;
        while doserror<>18 do begin
        findnext(s);
        if doserror=18 then goto 77;
        d1:=SearchRec(s).Name;
        if d1=fn[1] then goto 77;
        str(SearchRec(s).Attr,d);
     {   if d='32' then goto 79;
        if d='16' then goto 79;
        if d='0' then goto 79;
        goto 71;    }
    79: fn[n]:=d1;  as[n]:=SearchRec(s).Size;
        at[n]:=d;  n:=n+1;
        71: ;
        end;
        {  вывод оглавления на экран }
77: n:=n-1;
    textcolor(c10); textbackground(c1);
    writeln('╔═════════════════════════════════════════════════════════════════════════════╗');
    writeln('║ Каталог:                                                                    ║');
    writeln('╚═════════════════════════════════════════════════════════════════════════════╝');
    writeln;
    writeln('╔═══════════════════╤════════════╗');
    writeln('║                   │            ║');
    for i:=1 to 16 do     writeln('║                   │            ║');
    writeln('║                   │            ║');
    writeln('╚═══════════════════╧════════════╝');
    getdir(0,s1);
    textcolor(c15); gotoxy(12,2); write(s1);
    window(4,6,33,23);
    textcolor(c14);
    for i:=1 to 18 do begin
        if i>n then goto 87;
        if at[i]='16' then textcolor(c13) else textcolor(c14);
        gotoxy(1,i);
        write(fn[i]);
        gotoxy(18,i); textcolor(c10); write('│');
        gotoxy(21,i);
        if at[i]='16' then write('<DIR>')  else write(as[i]:1:0);

        end;
    87:    d1:=' ';
        if at[1]='16' then textcolor(c13) else textcolor(c14);
       gotoxy(1,1); textbackground(c3);
        write(fn[1],d1:(29-length(fn[1])));
        gotoxy(18,1); textcolor(c10); write('│');
        gotoxy(21,1);
        if at[1]='16' then write('<DIR>')  else write(as[1]:1:0);
       k:=1;  y:=1;
10:ch:=readkey;
   if ch=chr(0) then begin funckey:=true; ch:=readkey; end else funckey:=false;


   if funckey then begin
   if ch=chr(61) then begin
   window(1,1,80,25);
   i:=1; d:=fn[k];
   look(d,i,color);
   goto 2; end;
   if ch=chr(80) then begin
        textbackground(c1);
        if at[k]='16' then textcolor(c13) else textcolor(c14);
        gotoxy(1,y);
        write(fn[k],d1:(29-length(fn[k])));
        gotoxy(18,y); textcolor(c10); write('│');
        gotoxy(21,y);
        if at[k]='16' then write('<DIR>')  else write(as[k]:1:0);
        y:=y+1; k:=k+1;
        if k>n then begin
        sound(300);
        delay(15);nosound; k:=k-1;y:=y-1;end;
        if y>18 then begin
          y:=y-1;
          gotoxy(1,1);
          delline;

          end;
        if at[k]='16' then textcolor(c13) else textcolor(c14);
        textbackground(c3); gotoxy(1,y);
        write(fn[k],d1:(29-length(fn[k])));
        gotoxy(18,y); textcolor(c10); write('│');
        gotoxy(21,y);
        if at[k]='16' then write('<DIR>')  else write(as[k]:1:0);
        goto 10;
        end;
   if ch=chr(72) then begin
        textbackground(c1);
        if at[k]='16' then textcolor(c13) else textcolor(c14);
        gotoxy(1,y);
        write(fn[k],d1:(29-length(fn[k])));
        gotoxy(18,y); textcolor(c10); write('│');
        gotoxy(21,y);
        if at[k]='16' then write('<DIR>')  else write(as[k]:1:0);
        y:=y-1; k:=k-1;
        if k<=0 then begin
        sound(300);
        delay(15);nosound; k:=1;y:=1;end;
        if y<1 then begin
          y:=y+1;
          gotoxy(1,1);
          insline;
          end;
        if at[k]='16' then textcolor(c13) else textcolor(c14);
        gotoxy(1,y);
        textbackground(c3);
        write(fn[k],d1:(29-length(fn[k])));
        gotoxy(18,y); textcolor(c10); write('│');
        gotoxy(21,y);
        if at[k]='16' then write('<DIR>')  else write(as[k]:1:0);
        goto 10;
        end;
        if ch=chr(59) then begin
        window(1,1,80,25);
81:     textcolor(c10); textbackground(c4);
        gotoxy(44,21); write('  Укажите диск >          ');
        gotoxy(62,21); readln(d2);  gotoxy(1,3);
        getdir(0,d3);
        if d2='' then begin
        getdir(0,d2); textcolor(c15); textbackground(c4);
        gotoxy(43,20); write('╔═══════════════════════════╗');
        gotoxy(43,21); write('║  ',copy(d2,1,2),'                       ║');
        gotoxy(43,22); write('╚═══════════════════════════╝');
            window(4,6,33,23);
            goto 10;
            end;
{$I-}
        chdir(copy(d2,1,1)+':\');
        if ioresult<>0 then begin
        textcolor(c15+blink); textbackground(c4);
        gotoxy(44,21); write(' Нет такого устройства !!!');
        for i:=1 to 10 do begin sound(900);delay(100);nosound;delay(100); end;
        chdir(d3);
{$I+}
        goto 81;
        end;

        getdir(0,d2); textcolor(c15); textbackground(c4);
        gotoxy(43,20); write('╔═══════════════════════════╗');
        gotoxy(43,21); write('║  ',copy(d2,1,2),'                       ║');
        gotoxy(43,22); write('╚═══════════════════════════╝');
        gotoxy(1,4);
        textbackground(c0); write('                                                                    ');
        goto 1;
        end;
    if ch=char(66) then begin
        if at[k]='16' then goto 10;
        window(1,1,80,25);
        textcolor(c10); textbackground(c1);
        gotoxy(3,2);
        writeln('Удаляется файл  ',Fn[k],'                 ');
        gotoxy(1,4);
        textbackground(c0);
        write('Нажмите ENTER для подтверждения или  ESC для отмены операции');
    3:  ch:=readkey;
        if ch=chr(27) then begin
              gotoxy(1,4);write('                                                              ');
              textbackground(c1);
              gotoxy(1,2);
              write('║ Каталог:                                                                    ║');
              getdir(0,s1);
              textcolor(c15);
              textbackground(c1);
              gotoxy(12,2); write('                                                       ');
              gotoxy(12,2); write(s1);
              window(4,6,33,23);
              textcolor(c14);
              goto 10;
              end;
         if ch=chr(13) then begin
             findfirst(fn[k],anyfile,s);
             assign(f,s.name); setfattr(f,0); setfattr(f,anyfile);
             erase(f);
             goto 1;
             end;
         goto 3;
        end;
    if ch=chr(64) then begin
        window(1,1,80,25);
              if at[k]<>'32' then begin
              textcolor(c4+blink);  textbackground(c0);
              gotoxy(2,4); write('Недопустимая операция                                               ');
              sound(500);delay(100);nosound;delay(1000);
              ch:=chr(27); goto 8; end;
        gotoxy(2,2);
        textbackground(c1);            textcolor(c11);
        write('                                                                       ');
        gotoxy(4,2);      write('Старое имя:   ');
        textcolor(c15);    write(fn[k]);
        textcolor(c11);    write('    Новое имя:  ');
        textcolor(c15);    readln(d3);
        if d3='' then begin ch:=chr(27); goto 8; end;
        gotoxy(1,4);
        textbackground(c0);
        write('Нажмите ENTER для подтверждения или  ESC для отмены операции');
    7:  ch:=readkey;
    8:  if ch=chr(27) then begin
              textbackground(c0);  textcolor(c10);
              gotoxy(1,4);write('                                                              ');
              textbackground(c1);
              gotoxy(1,2);
              write('║ Каталог:                                                                    ║');
              getdir(0,s1);
              textcolor(c15);
              textbackground(c1);
              gotoxy(12,2); write('                                                       ');
              gotoxy(12,2); write(s1);
              window(4,6,33,23);
              textcolor(c14);
              goto 10;
              end;
         if ch=chr(13) then begin
              if at[k]<>'32' then begin
              textcolor(c4+blink);  textbackground(c0);
              gotoxy(2,4); write('Недопустимая операция                                               ');
              sound(500);delay(100);nosound;delay(1000);
              ch:=chr(27); goto 8; end;
              assign(f,fn[k]);
              rename(f,d3);
              fn[k]:=d3;
              gotoxy(1,4);write('                                                              ');
              textbackground(c1);
              gotoxy(1,2);
              write('║ Каталог:                                                                    ║');
              getdir(0,s1);
              textcolor(c15);
              textbackground(c1);
              gotoxy(12,2); write('                                                       ');
              gotoxy(12,2); write(s1);
              window(4,6,33,23);
              textcolor(c14);
        textbackground(c3);
        if at[k]='16' then textcolor(c13) else textcolor(c14);
        gotoxy(1,y);
        write(fn[k],d1:(29-length(fn[k])));
        gotoxy(18,y); textcolor(c10); write('│');
        gotoxy(21,y);
        if at[k]='16' then write('<DIR>')  else write(as[k]:1:0);
              goto 10;
              end;

              goto 7;
              end;



    goto 10;
    end;
    if ch=chr(27) then begin nameoffile:=''; goto 100; end;
    if ch=chr(13) then begin
        if at[k]='16' then begin
           if fn[k]='.' then  chdir('\.') else  chdir(fn[k]);
           goto 1;
           end;
        window(2,2,78,2);
        textbackground(c1); textcolor(c15);
        nameoffile:=fexpand(fn[k]);
        write('Выбран файл:   ',nameoffile);
        window(1,1,80,25);
        gotoxy(1,4);
        textbackground(c0);
        write('Нажмите ENTER для подтверждения или  ESC для отмены операции');
    4:  ch:=readkey;
        if ch=chr(27) then begin
              gotoxy(1,4);write('                                                              ');
              textbackground(c1);
              gotoxy(1,2);
              write('║ Каталог:                                                                    ║');
              getdir(0,s1);
              textcolor(c15);
              textbackground(c1);
              gotoxy(12,2); write('                                                       ');
              gotoxy(12,2); write(s1);
              window(4,6,33,23);
              textcolor(c14);
              goto 10;
              end;
         if ch=chr(13) then goto 100;
              goto 4;
              end;

    goto 10;
100: chdir(sh);
     window(1,1,80,25);
end;
end.
