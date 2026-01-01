{$M 32768,0,655360}
program list;
uses crt,dir1991;
var
    a1:array[1..100] of string;
    a2,a3,a4:array[1..100] of string[100];
    f,f1:text;
    ch:char;
    funckey:boolean;
    nabor,s,s2,nameoffile,name,nameout:string;
    s1:string[8];
    ent,x,y,i,j,k,n,h,lis:integer;
    numer,numerp,numeraz,simv,shrift,tip,double,progon,leftm,rightm,stran,strok:integer;
    m1:array[1..10] of string[20];
label
  1,4,5,6,7,8,10;

procedure usec(var s:string);

  label 1;

  begin
    1: if copy(s,length(s),1)=' ' then begin
          delete(s,length(s),1); goto 1; end;
  end;

procedure read0;
var i:integer;
begin
  for i:=1 to stran do a1[i]:='';
  for i:=1 to stran do begin
    readln(f1,s);
    if copy(s,1,3)='[&]' then exit;
    if eof(f1) then begin usec(s); a1[i]:=s; exit; end;;
    usec(s);
    a1[i]:=s;
    end;
end;
procedure read1;
var i:integer;
    label 1;
begin
  for i:=1 to stran do begin a1[i]:=''; a2[i]:=''; end;
  for i:=1 to stran do begin
    readln(f1,s);
    if copy(s,1,3)='[&]' then goto 1;
    if eof(f1) then begin usec(s); a1[i]:=s; exit; end;;
    usec(s);
    a1[i]:=s;
    end;
1: for i:=1 to stran do begin
    readln(f1,s);
    if copy(s,1,3)='[&]' then exit;
    if eof(f1) then begin usec(s); a2[i]:=s; exit; end;;
    usec(s);
    a2[i]:=s;
    end;
end;
procedure read2;
var i:integer;
    label 1,2,3;
begin
  for i:=1 to stran do begin a3[i]:=''; a4[i]:=''; a1[i]:=''; a2[i]:=''; end;
  for i:=1 to stran do begin
    readln(f1,s);
    if copy(s,1,3)='[&]' then goto 1;
    if eof(f1) then begin usec(s); a1[i]:=s; exit; end;;
    usec(s);
    a1[i]:=s;
    end;
1:  for i:=1 to stran do begin
    readln(f1,s);
    if copy(s,1,3)='[&]' then goto 2;
    if eof(f1) then begin usec(s); a2[i]:=s; exit; end;;
    usec(s);
    a2[i]:=s;
    end;
2:  for i:=1 to stran do begin
    readln(f1,s);
    if copy(s,1,3)='[&]' then goto 3;
    if eof(f1) then begin usec(s); a3[i]:=s; exit; end;;
    usec(s);
    a3[i]:=s;
    end;
3: for i:=1 to stran do begin
    readln(f1,s);
    if copy(s,1,3)='[&]' then exit;
    if eof(f1) then begin usec(s); a4[i]:=s; exit; end;;
    usec(s);
    a4[i]:=s;
    end;
end;





procedure setting;
  begin
    textcolor(10); textbackground(4);
    gotoxy(1,01);write('╔════════════════════════════╗');
    gotoxy(1,02);write('║ Имя обрабатываемого файла: ║');
    gotoxy(1,03);write('║                            ║');
    gotoxy(1,04);write('║ Адрес вывода:              ║');
    gotoxy(1,05);write('║                            ║');
    gotoxy(1,06);write('║ Шрифт:                     ║');
    gotoxy(1,07);write('║ Двойной прогон:            ║');
    gotoxy(1,08);write('║ Тип печати:                ║');
    gotoxy(1,09);write('║ Частота строк:             ║');
    gotoxy(1,10);write('║                            ║');
    gotoxy(1,11);write('║ Строк на странице:         ║');
    gotoxy(1,12);write('║ символов в строке:         ║');
    gotoxy(1,13);write('║ Левый отступ:              ║');
    gotoxy(1,14);write('║ Правый отступ:             ║');
    gotoxy(1,15);write('║                            ║');
    gotoxy(1,16);write('║ Нумерация:                 ║');
    gotoxy(1,17);write('║ Номер 1 страницы:          ║');
    gotoxy(1,18);write('║ Прогон:                    ║');
    gotoxy(1,19);write('║                            ║');
    gotoxy(1,20);write('║ Порядковый номер листа, с  ║');
    gotoxy(1,21);write('║ которого нач.печать:       ║');
    gotoxy(1,22);write('║                            ║');
    gotoxy(1,23);write('║                            ║');
    gotoxy(1,24);write('╚════════════════════════════╝');
    textcolor(15);
    gotoxy(3,03);write(name);
    gotoxy(3,05);write(nameout);
    gotoxy(10,06);
      case shrift of
        0:  write('СТАНДАРТНЫЙ');
        1:  write('ЭЛИТА      ');
        2:  write('СЖАТЫЙ     ');
      end;
    gotoxy(19,07);
    if double=1 then write('УСТАНОВЛЕН') else write('ОТМЕНЕН');
    gotoxy(16,08);
      case tip of
        0:  write('В ОДНУ ПОЛОСУ');
        1:  write('В ДВЕ ПОЛОСЫ ');
        2:  write('ПЕЧАТЬ 2х2 ');
      end;
    gotoxy(18,09);        write(strok,'/216');
    gotoxy(22,11);        write(stran);
    gotoxy(22,12);        write(simv);
    gotoxy(22,13);        write(leftm);
    gotoxy(22,14);        write(rightm);
    gotoxy(18,16);
    if numeraz=1 then write('УСТАНОВЛЕНA') else write('ОТМЕНЕНA');
    gotoxy(25,17);        write(numer);
    gotoxy(18,18);
    if progon=1 then write('УСТАНОВЛЕН') else write('ОТМЕНЕН');
    gotoxy(25,21);        write(numerp);
    end;
procedure help;
  begin
    textcolor(10); textbackground(1);
    if h=1 then begin
    gotoxy(1,01);write('╔════════════════════════════╗');
    gotoxy(1,02);write('║ Вы находитесь в главном ме-║');
    gotoxy(1,03);write('║ ню программы LIST. В этом  ║');
    gotoxy(1,04);write('║ меню вы можете:            ║');
    gotoxy(1,05);write('║                            ║');
    gotoxy(1,06);write('║ 1. Определить имя файла,   ║');
    gotoxy(1,07);write('║ который должен быть обра-  ║');
    gotoxy(1,08);write('║ ботан                      ║');
    gotoxy(1,09);write('║                            ║');
    gotoxy(1,10);write('║ 2. Определить имя файла    ║');
    gotoxy(1,11);write('║ для вывода или указать вы- ║');
    gotoxy(1,12);write('║ вод на принтер             ║');
    gotoxy(1,13);write('║                            ║');
    gotoxy(1,14);write('║ 3. Перейти в меню настрой- ║');
    gotoxy(1,15);write('║ ки печати                  ║');
    gotoxy(1,16);write('║                            ║');
    gotoxy(1,17);write('║ 4. С помощью функции "КАЛЬ-║');
    gotoxy(1,18);write('║ КУЛЯТОР" узнать, на какую  ║');
    gotoxy(1,19);write('║ позицию приходится разде-  ║');
    gotoxy(1,20);write('║ литель страниц             ║');
    gotoxy(1,21);write('║                            ║');
    gotoxy(1,22);write('║ 5. Начать обработку        ║');
    gotoxy(1,23);write('║                            ║');
    gotoxy(1,24);write('╚════════════════════════════╝');
    end;
    if h=2 then begin
    gotoxy(1,01);write('╔════════════════════════════╗');
    gotoxy(1,02);write('║ Вы находитесь в подменю    ║');
    gotoxy(1,03);write('║  НАСТРОЙКА ПЕЧАТИ          ║');
    gotoxy(1,04);write('║                            ║');
    gotoxy(1,05);write('║ В этом подменю вы можете:  ║');
    gotoxy(1,06);write('║                            ║');
    gotoxy(1,07);write('║                            ║');
    gotoxy(1,08);write('║                            ║');
    gotoxy(1,09);write('║                            ║');
    gotoxy(1,10);write('║ 1. Вызвать меню установки  ║');
    gotoxy(1,11);write('║ параметров принтера        ║');
    gotoxy(1,12);write('║                            ║');
    gotoxy(1,13);write('║                            ║');
    gotoxy(1,14);write('║ 2. Вызвать меню установки  ║');
    gotoxy(1,15);write('║ параметров листа           ║');
    gotoxy(1,16);write('║                            ║');
    gotoxy(1,17);write('║                            ║');
    gotoxy(1,18);write('║                            ║');
    gotoxy(1,19);write('║                            ║');
    gotoxy(1,20);write('║                            ║');
    gotoxy(1,21);write('║                            ║');
    gotoxy(1,22);write('║                            ║');
    gotoxy(1,23);write('║                            ║');
    gotoxy(1,24);write('╚════════════════════════════╝');
    end;
    if h=3 then begin
    gotoxy(1,01);write('╔════════════════════════════╗');
    gotoxy(1,02);write('║ Вы находитесь в меню нас-  ║');
    gotoxy(1,03);write('║ тройки принтера. В  этом   ║');
    gotoxy(1,04);write('║ меню вы можете:            ║');
    gotoxy(1,05);write('║                            ║');
    gotoxy(1,06);write('║ 1. Установить тип шрифта   ║');
    gotoxy(1,07);write('║                            ║');
    gotoxy(1,08);write('║ 2. Установить двойной про- ║');
    gotoxy(1,09);write('║    гон                     ║');
    gotoxy(1,10);write('║                            ║');
    gotoxy(1,11);write('║ 3. Установить частоту      ║');
    gotoxy(1,12);write('║    строк                   ║');
    gotoxy(1,13);write('║                            ║');
    gotoxy(1,14);write('║                            ║');
    gotoxy(1,15);write('║                            ║');
    gotoxy(1,16);write('║                            ║');
    gotoxy(1,17);write('║                            ║');
    gotoxy(1,18);write('║                            ║');
    gotoxy(1,19);write('║                            ║');
    gotoxy(1,20);write('║                            ║');
    gotoxy(1,21);write('║                            ║');
    gotoxy(1,22);write('║                            ║');
    gotoxy(1,23);write('║                            ║');
    gotoxy(1,24);write('╚════════════════════════════╝');
    end;
    if h=4 then begin
    gotoxy(1,01);write('╔════════════════════════════╗');
    gotoxy(1,02);write('║ Вы находитесь в меню нас-  ║');
    gotoxy(1,03);write('║ тройки листа   . В  этом   ║');
    gotoxy(1,04);write('║ меню вы можете:            ║');
    gotoxy(1,05);write('║                            ║');
    gotoxy(1,06);write('║ 1. Установить тип печати:  ║');
    gotoxy(1,07);write('║    одинарный,двойной,      ║');
    gotoxy(1,08);write('║    печать 2х2              ║');
    gotoxy(1,09);write('║                            ║');
    gotoxy(1,10);write('║ 2. Число строк на листе    ║');
    gotoxy(1,11);write('║                            ║');
    gotoxy(1,12);write('║ 3. Число знаков в строке   ║');
    gotoxy(1,13);write('║                            ║');
    gotoxy(1,14);write('║ 4. Левый и правый отступ   ║');
    gotoxy(1,15);write('║                            ║');
    gotoxy(1,16);write('║ 5. Установить или отменить ║');
    gotoxy(1,17);write('║    прогон бумаги и нумера- ║');
    gotoxy(1,18);write('║    цию страниц             ║');
    gotoxy(1,19);write('║                            ║');
    gotoxy(1,20);write('║ 6. Указать номер страницы  ║');
    gotoxy(1,21);write('║    с которой нужно начать  ║');
    gotoxy(1,22);write('║    печать и номер первой   ║');
    gotoxy(1,23);write('║    страницы                ║');
    gotoxy(1,24);write('╚════════════════════════════╝');
    end;



  ch:=readkey; setting;
  end;
procedure menu;
  label 10;
begin
textcolor(2); textbackground(1);
   gotoxy(x,y);   write('╔═════════════════════════╗');
   for i:=1 to n+2 do begin gotoxy(x,y+i); write('║                         ║'); end;
   gotoxy(x,y+n+3);write('╚═════════════════════════╝');
textcolor(10); textbackground(1);
   for i:=1 to n do begin gotoxy(x+4,y+i+1); write(m1[i]); end;
textcolor(14); textbackground(3);
   gotoxy(x+4,y+k+1); write(m1[k]);
   gotoxy(58,3);
10: ch:=readkey; if ch=chr(0) then begin funckey:=true; ch:=readkey; end;
   if ch=chr(80) then begin
     textcolor(10); textbackground(1);
     gotoxy(x+4,y+k+1); write(m1[k]);
     k:=k+1; if k>n then k:=1;
     textcolor(14); textbackground(3);
     gotoxy(x+4,y+k+1); write(m1[k]);
     sound(300); delay(2); nosound;
     goto 10;
     end;
   if ch=chr(72) then begin
     textcolor(10); textbackground(1);
     gotoxy(x+4,y+k+1); write(m1[k]);
     k:=k-1; if k=0 then k:=n;
     textcolor(14); textbackground(3);
     gotoxy(x+4,y+k+1); write(m1[k]);
     sound(300); delay(2); nosound;
     goto 10;
     end;
   if ch=chr(13) then begin ent:=1; exit; end;
   if ch=chr(27) then begin ent:=0; exit; end;
   goto 10;




end;
procedure nastr;
  label 5;
  begin
m1[1]:='Справка';
m1[2]:='Cтандартный шрифт';
m1[3]:='Шрифт типа "ЭЛИТА"';
m1[4]:='Сжатый шрифт';
m1[5]:='Двойной прогон';
m1[6]:='Частота 1/6';
m1[7]:='Частота 1/8';
m1[8]:='Частота N/216';
n:=8;  x:=51;  y:=11;   k:=1;
5: menu;
if ent=0 then begin
  window(51,11,80,25);
  textbackground(0); clrscr;
  window(1,1,80,25);
  exit; end;
if k=1 then begin h:=3; help; goto 5; end;
if k=2 then begin shrift:=0; setting; goto 5; end;
if k=3 then begin shrift:=1; setting; goto 5; end;
if k=4 then begin shrift:=2; setting; goto 5; end;
if k=5 then begin if double=0 then double:=1 else double:=0; setting; goto 5; end;
if k=6 then begin strok:=36; setting; goto 5; end;
if k=7 then begin strok:=27; setting; goto 5; end;
if k=8 then begin
    textcolor(15); textbackground(4);
    gotoxy(18,09);        write('N/216  ');
    textcolor(7);
    gotoxy(3,10);write('▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒');
    textcolor(14);
    gotoxy(3,10);write('Введите N : ');readln(i);
    strok:=i;
    setting;
    goto 5; end;

  end;

procedure polosa;
  label 5;
  begin
m1[1]:='Справка';
m1[2]:='Тип печати';
m1[3]:='Строк на листе';
m1[4]:='Знаков в строке';
m1[5]:='Левый отступ';
m1[6]:='Правый отступ';
m1[7]:='Прогон бумаги';
m1[8]:='Нумерация';
m1[9]:='Номер 1 страницы';
m1[10]:='Первый печ.лист';
n:=10;  x:=51;  y:=11;   k:=1;
5: menu;
if ent=0 then begin
  window(51,11,80,25);
  textbackground(0); clrscr;
  window(1,1,80,25);
  exit; end;
if k=1 then begin h:=4; help; goto 5; end;
if k=2 then begin
     case tip of
     0: tip:=1;
     1: tip:=2;
     2: tip:=0;
     end;
     setting; goto 5; end;
if k=3 then begin
    textcolor(7); textbackground(4);
    gotoxy(22,11);        write('▒▒▒▒▒');
    textcolor(15); textbackground(4);
    gotoxy(22,11);        readln(stran);
    setting; goto 5; end;
if k=4 then begin
    textcolor(7); textbackground(4);
    gotoxy(22,12);        write('▒▒▒▒▒');
    textcolor(15); textbackground(4);
    gotoxy(22,12);        readln(simv);
    setting; goto 5; end;
if k=5 then begin
    textcolor(7); textbackground(4);
    gotoxy(22,13);        write('▒▒▒▒▒');
    textcolor(15); textbackground(4);
    gotoxy(22,13);        readln(leftm);
    setting; goto 5; end;
if k=6 then begin
    textcolor(7); textbackground(4);
    gotoxy(22,14);        write('▒▒▒▒▒');
    textcolor(15); textbackground(4);
    gotoxy(22,14);        readln(rightm);
    setting; goto 5; end;
if k=7 then begin if progon=0 then progon:=1 else progon:=0; setting; goto 5; end;
if k=8 then begin if numeraz=0 then numeraz:=1 else numeraz:=0; setting; goto 5; end;
if k=9 then begin
    textcolor(7); textbackground(4);
    gotoxy(25,17);        write('▒▒▒▒▒');
    textcolor(15); textbackground(4);
    gotoxy(25,17);        readln(numer);
    setting; goto 5; end;
if k=10 then begin
    textcolor(7); textbackground(4);
    gotoxy(25,21);        write('▒▒▒▒▒');
    textcolor(15); textbackground(4);
    gotoxy(25,21);        readln(numerp);
    setting; goto 5; end;
  end;

procedure printer;
  var beg,l,f9:integer;
  label 1,2,5,7;

  begin
    beg:=numerp;  lis:=numer-1;   f9:=0;
2:    assign(f1,name);
    reset(f1);
    textbackground(1);
    clrscr;
    textbackground(0); textcolor(14);
    gotoxy(1,1);
    write(' PgUp,PgUp-листать     F1-печатать лист     F2-печатать все    ESC-выход        ');
    gotoxy(1,2);
    write('                                                                                ');
    for i:=1 to beg do begin
       if tip=0 then read0;
       if tip=1 then read1;
       if tip=2 then read2;
    end;
       lis:=lis+1;
    textbackground(1); textcolor(11);
    for i:=1 to 20 do begin
      gotoxy(2,i+3); write(copy(a1[i],1,76));
    end;
1:
textcolor(13); textbackground(0);
gotoxy(10,2);write('Порядковый номер листа: ',beg,'   Печатаемый номер листа: ',lis);
if f9=1 then begin ch:=chr(59); goto 7; end;
ch:=readkey; if ch=chr(0) then ch:=readkey;
if ch=chr(60) then begin ch:=chr(59); f9:=1; end;
7:  if ch=chr(81) then begin
    textbackground(1);
    clrscr;
    textbackground(0); textcolor(14);
    gotoxy(1,1);
    write(' PgUp,PgUp-листать     F1-печатать лист     F2-печатать все    ESC-выход        ');
    gotoxy(1,2);
    write('                                                                                ');
       if eof(f1) then begin sound(100); delay(30); nosound; goto 5; end;
       if tip=0 then  read0;
       if tip=1 then  read1;
       if tip=2 then  read2;
       beg:=beg+1; lis:=lis+1;
5:  textbackground(1); textcolor(11);
    for i:=1 to 20 do begin
      gotoxy(2,i+3); write(copy(a1[i],1,76));
    end;

    goto 1;
end;
if ch=chr(73) then begin close(f1); lis:=lis-2; if beg=1 then goto 2; beg:=beg-1; goto 2; end;
if ch=chr(27) then exit;
if ch=chr(59) then begin
 writeln(f,nabor);
 s1:=' ';
 { однополосная печать }
 if tip=0 then begin
   if numeraz=1 then begin
   i:=leftm+rightm+simv;
   j:=round(i/2)-4;
   for k:=1 to j do write(f,s1);
   writeln(f,'-',lis:3,' -');
   writeln(f);
   writeln(f);
   end;
   for i:=1 to stran do  begin
   writeln(f,s1:leftm,a1[i]);
   end;
   if progon=1 then writeln(f,chr(12));
   ch:=chr(81); if eof(f1) then exit; goto 7; end;

 { двухполосная печать }
 if tip=1 then begin
   if numeraz=1 then begin
   i:=leftm+rightm+simv;
   j:=round(i/2)-4;
   for k:=1 to j do write(f,s1);
   write(f,'-',(lis*2-1):3,' -');
   for k:=(j+6) to (i+j) do write(f,s1);
   write(f,'-',(lis*2):3,' -');
   writeln(f);
   writeln(f);
   end;
   for i:=1 to stran do begin
     write(f,s1:leftm,a1[i]);
     writeln(f,s1:(simv-length(a1[i])+rightm),'|',s1:rightm,a2[i]);
  end;

   if progon=1 then writeln(f,chr(12));
   ch:=chr(81); if eof(f1) then exit; goto 7; end;

 { 4-хполосная печать }
 if tip=2 then begin
   if numeraz=1 then begin
   l:=leftm+rightm+simv;
   j:=round(l/2)-4;
   for k:=1 to j do write(f,s1);
   write(f,'-',(lis*4):3,' -');
   for k:=(j+6) to (l+j) do write(f,s1);
   write(f,'-',(lis*4-3):3,' -');
   writeln(f);
   writeln(f);
   end;
   for i:=1 to stran do begin
     write(f,s1:leftm,a4[i]);
     writeln(f,s1:(simv-length(a4[i])+rightm),'|',s1:rightm,a1[i]);
  end;
   if progon=1 then writeln(f,chr(12));
  if (nameout='LPT1') then begin
   textcolor(10); textbackground(0);
   gotoxy(1,2); write('Переверните лист и нажмите клавишу');
   ch:=readkey;
   ch:=' ';
   gotoxy(1,2); write('                                  ');
   end;
    for k:=1 to j do write(f,s1);
   write(f,'-',(lis*4-2):3,' -');
   for k:=(j+6) to (l+j) do write(f,s1);
   write(f,'-',(lis*4-1):3,' -');
   writeln(f);
   writeln(f);
   end;
   for i:=1 to stran do begin
     write(f,s1:leftm,a2[i]);
     writeln(f,s1:(simv-length(a2[i])+rightm),'|',s1:rightm,a3[i]);
  end;

   if progon=1 then writeln(f,chr(12));
   ch:=chr(81);
   if eof(f1) then exit; goto 7; end;



end;

begin
{ чтение установок с диска }

assign(f,'list.set');
reset(f);
readln(f);
   readln(f,name);                  { чтение имени файла }
   readln(f,nameout);               { чтение адреса вывода }
   readln(f,shrift);                { чтение типа шрифта }
   readln(f,double);                { чтение установки двойного прогона }
   readln(f,tip);                   { чтение типа печати }
   readln(f,strok);                 { чтение частоты строк }
   readln(f,stran);                 { чтение числа строк на странице }
   readln(f,simv);                  { чтение числа символов в строке }
   readln(f,leftm);                 { чтение левого отступа }
   readln(f,rightm);                { чтение правого отступа }
   readln(f,numeraz);               { чтение признака нумерации страниц }
   readln(f,numer);                 { чтение номера первой страницы }
   readln(f,numerp);                { чтение номера первой страницы печати }
   readln(f,progon);                { чтение признака прогона бумаги }
close(f);
1: textbackground(0);
clrscr;
setting;
textcolor(10); textbackground(0);
gotoxy(40,1); write('█        █   █▀▀▀▀▀   █▀▀█▀▀█ ');
gotoxy(40,2); write('█        █   █▄▄▄▄▄      █    ');
gotoxy(40,3); write('█    ▄   █        █      █    ');
gotoxy(40,4); write('▀▀▀▀▀▀   ▀   ▀▀▀▀▀▀      ▀    ');

k:=1;
4: m1[1]:='Справка';
m1[2]:='Обработaть файл...';
m1[3]:='Адрес вывода';
m1[4]:='Настройка печати';
m1[5]:='Калькулятор';
m1[6]:='Обработка';
n:=6;  x:=41;  y:=8;
5: menu;
if ent=0 then begin textbackground(0); clrscr; goto 10; end;
if k=1 then begin h:=1; help; goto 5; end;
if k=2 then begin
  i:=1;
  dir(nameoffile,i);
  if nameoffile<>'' then name:=nameoffile;
  goto 1;
  end;
if k=3 then begin
    textcolor(7); textbackground(4);
    gotoxy(3,05);write('▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒');
    textcolor(14);
    gotoxy(3,05);readln(s);
    if s<>'' then nameout:=s;
    setting;
    goto 5;
    end;
if k=4 then begin
k:=1;
6:m1[1]:='Справка';
m1[2]:='Параметры печати';
m1[3]:='Параметры листа';
n:=3;  x:=45;  y:=11;
menu;
if ent=0 then begin
  textbackground(0);
  window(45,11,80,25);
  clrscr;
  window(1,1,80,25);
  k:=4; goto 4;
  end;
if k=1 then begin h:=2; help; goto 6; end;
if k=2 then begin
  nastr;
  k:=2; goto 6;
  end;
if k=3 then begin
  polosa;
  k:=3; goto 6;
end;
end;
if k=5 then begin
   i:=leftm+rightm+simv;
   case shrift of
     0:  k:=100;
     1:  k:=83;
     2:  k:=58;
     end;

   j:=round(i/100*k)+1;
textcolor(10); textbackground(1);
gotoxy(40,1); write('╔════════════════════════════╗');
gotoxy(40,2); write('║ Разделитель страниц будет  ║');
gotoxy(40,3); write('║ расположен ў на  ',j:3,'  поз. ║');
gotoxy(40,4); write('╚════════════════════════════╝');
ch:=readkey;
textcolor(10); textbackground(0);
gotoxy(40,1); write('█        █   █▀▀▀▀▀   █▀▀█▀▀█ ');
gotoxy(40,2); write('█        █   █▄▄▄▄▄      █    ');
gotoxy(40,3); write('█    ▄   █        █      █    ');
gotoxy(40,4); write('▀▀▀▀▀▀   ▀   ▀▀▀▀▀▀      ▀    ');
k:=5; goto 5;
end;



if k=6 then begin   { начало процедуры печати }
    if nameout='LPT1' then begin
    textcolor(14); textbackground(4);
    gotoxy(35,20); write('╔═════════════════════════════════════╗');
    gotoxy(35,21); write('║ Включите принтер, установите бумагу ║');
    gotoxy(35,22); write('╚═════════════════════════════════════╝');
 7:   ch:=readkey;
    if ch=chr(27) then begin
    textcolor(0); textbackground(0);
    gotoxy(35,20); write('╔═════════════════════════════════════╗');
    gotoxy(35,21); write('║ Включите принтер, установите бумагу ║');
    gotoxy(35,22); write('╚═════════════════════════════════════╝');
    goto 5; end;
    end;
    assign(f,nameout);
    rewrite(f);

{$I-}
 8:   write(f,' ');
    if ioresult<>0 then begin
      sound(100);  delay(5); nosound; delay(100); if keypressed then goto 7 else goto 8; end;
{$I+}
    assign(f1,'list.fnt');
    reset(f1);
    readln(f1);  s:='';
    readln(f1,s1); s2:=s1; usec(s2); if shrift=0 then s:=s+s2+' ';
    readln(f1,s1); s2:=s1; usec(s2); if shrift=1 then s:=s+s2+' ';
    readln(f1,s1); s2:=s1; usec(s2); if shrift=2 then s:=s+s2+' ';
    readln(f1,s1); s2:=s1; usec(s2); if double=1 then s:=s+s2+' ';
    readln(f1,s1); s2:=s1; usec(s2); s:=s+s2+chr(strok)+' ';
    readln(f1,s1); s2:=s1; usec(s2); if shrift=2 then s:=s+s2+' ';
    close(f1);
    nabor:=s;
    printer;
    textcolor(0); textbackground(0);
    goto 1;




end; { конец процедуры печати }

10: assign(f,'list.set');
rewrite(f);
writeln(f,'Файл установочных данных к программе LIST');
   writeln(f,name);                  { чтение имени файла }
   writeln(f,nameout);               { чтение адреса вывода }
   writeln(f,shrift);                { чтение типа шрифта }
   writeln(f,double);                { чтение установки двойного прогона }
   writeln(f,tip);                   { чтение типа печати }
   writeln(f,strok);                 { чтение частоты строк }
   writeln(f,stran);                 { чтение числа строк на странице }
   writeln(f,simv);                  { чтение числа символов в строке }
   writeln(f,leftm);                 { чтение левого отступа }
   writeln(f,rightm);                { чтение правого отступа }
   writeln(f,numeraz);               { чтение признака нумерации страниц }
   writeln(f,numer);                 { чтение номера первой страницы }
   writeln(f,numerp);                { чтение номера первой страницы печати }
   writeln(f,progon);                { чтение признака прогона бумаги }
close(f);
end.



