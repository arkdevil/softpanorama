unit lookfile;
interface
    procedure look(var nameoffile:string; var stroka:integer; var color:integer);
implementation
uses crt,dos;
procedure look;
var i,j,j2,lt,list,prod,buf,pos,got,nac:integer;
    fin:longint;
  c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c0:integer;
    ch:char;
    s:string;
    f:text;
    a:array[1..200] of string[76];
    a1:array[1..3] of string[76];
label
    1,2,4,5,15,10,20,30,40,50;
begin
if color=1 then begin
  c0:=0;    c1:=1;     c2:=2;     c3:=3;      c4:=4;
  c5:=5;    c6:=6;     c7:=7;     c8:=8;      c9:=9;
  c10:=10;  c11:=11;   c12:=12;   c13:=13;    c14:=14;
  c15:=15;  end else begin
  c0:=0;    c1:=0;     c2:=0;     c3:=0;      c4:=0;
  c5:=0;    c6:=0;     c7:=0;     c8:=0;      c9:=15;
  c10:=15;   c11:=15;    c12:=15;    c13:=7;     c14:=15;
  c15:=15;   end;
    textbackground(c0);  got:=0; pos:=0;  nac:=200;
    clrscr;
    for i:=1 to 200 do a[i]:='';
    assign(f,nameoffile);
4:  list:=1;   buf:=0;   j2:=0;
    reset(f);
    for i:=1 to 20 do begin
       readln(f,s);
       if copy(s,1,1)='#' then j2:=j2+1;
       end;
       if j2>0 then nac:=10*(20-j2);
       if stroka>(20-j2) then begin got:=1; pos:=stroka; end;
       close(f); reset(f); j2:=0;
    textcolor(c14); textbackground(c0);
    gotoxy(1,2); write('                                                                                ');
    gotoxy(3,1);write(' ',Nameoffile);
    gotoxy(30,1);write('Выход: ESC');
    gotoxy(45,1);write('Просмотр:  PgUp,PgDn,Home');
1:  buf:=buf+1;    lt:=1;

2:  if buf=1 then j2:=0;
    for i:=1 to nac do begin
       readln(f,s);
       if copy(s,1,1)='#' then begin delete(s,1,1);j2:=j2+1; a1[j2]:=s;i:=i-1; goto 5; end;
       a[i]:=s;
       if eof(f) then begin
             for j:=i+1 to nac do a[j]:='';
             prod:=0;
             fin:=(buf-1)*nac+i;
{             stroka:=0;}
             goto 10;
             end;
    5:   end;
       if (buf)*nac<stroka then begin list:=list+10;
       pos:=stroka; got:=1; goto 1; end;
       stroka:=0;
       fin:=buf*nac+1;
    prod:=1;
10: s:=' ';
    textcolor(c13); textbackground(c1);
    gotoxy(1,3);write('╔══════════════════════════════════════════════════════════════════════════════╗');
    if j2>0 then
      for i:=1 to j2 do begin
        gotoxy(1,3+i);write('║                                                                              ║');
        textcolor(c14);
        gotoxy(3,3+i);write(a1[i]);
        textcolor(c13);
        end;
15: textcolor(c13);
    for i:=1 to 20-j2 do begin
    gotoxy(1,3+i+j2);write('║ ');textcolor(c14);
    write(a[(lt-1)*(20-j2)+i],s:(76-length(a[(lt-1)*(20-j2)+i])));
    textcolor(c13);
    gotoxy(79,3+i+j2);write(' ║');
    end;
    if got=1 then if (((lt)*(20-j2))+j2+nac*(buf-1))>=pos then pos:=0 else begin list:=list+1; lt:=lt+1; goto 15; end;
    gotoxy(1,24);write('╚══════════════════════════════════════════════════════════════════════════════╝');
    textcolor(c10);  textbackground(c4);
    gotoxy(72,1); write('Лист ',list:3);
    textcolor(c14); textbackground(c1);
20: ch:=readkey;
    if ch=chr(0) then ch:=readkey;
    if ch=chr(81) then begin
                     if (fin+(20-j2))<((buf-1)*nac+lt*(20-j2)) then goto 20;
                     list:=list+1;
                     lt:=lt+1;
                     if lt=11 then
                            if prod=1 then goto 1 else begin lt:=lt-1; list:=list-1; goto 20; end;
                     goto 15;
                     end;
    if ch=chr(73) then begin
                     list:=list-1;
                     lt:=lt-1;
                     if lt=0 then begin
                               buf:=buf-1;
                               if buf=0 then begin lt:=1;list:=1;buf:=1; goto 20; end;
                               close(f); reset(f);
                               if buf-1=0 then begin lt:=10; goto 2; end;
                               for i:=1 to (buf-1)*nac+j2 do readln(f);
                               lt:=10;
                               goto 2;
                               end;
                     goto 15;
                     end;
    if ch=chr(71) then begin close(f); goto 4; end;
    if ch=chr(27) then goto 40;
    goto 20;
 40: textbackground(c0); close(f);
end;
end.
