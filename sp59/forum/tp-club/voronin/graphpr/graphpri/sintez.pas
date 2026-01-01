program sintez;
{┌───────────────────────────────────────────────────────────────────────┐}
{│                     программа SINTEZ                                  │}
{│ Программа предназначена для восстановления результатов работы прог-   │}
{│ раммы GRAPHPR в предыдущем сеансе работы. Формируется модуль ISH.PAS  │}
{│ содержащий операторы, сделанные в предыдущий раз и после этого необ-  │}
{│ ходимо дать команду компиляции для программы GRAPHPR1. Эта программа  │}
{│ почти ничем не отличается от базовой, за исключением двух пунктов:    │}
{│  1. программа не обнуляет файл PROGR.PAS а воссоздает его по сох-     │}
{│     раненному шаблону PROGR.SAV                                       │}
{│  2. Перед выходом в меню программа выполняет процедуру, включающую    │}
{│     в себя все операторы, которые вы сделали ранее.                   │}
{└───────────────────────────────────────────────────────────────────────┘}
uses crt;
var fp,fg,fg1,fo1:text;
    s:string;
    i,k,kol:integer;
    a:array[1..50] of string;
label 1,2,3,4,5,6,7,8;
begin
for k:=1 to 50 do a[k]:='';
assign(fp,'ish.pas'); rewrite(fp);
assign(fg,'progr.pas'); reset(fg); readln(fg); readln(fg);
writeln(fp,'unit ish;                      ');
writeln(fp,'interface                      ');
writeln(fp,'uses crt,graph,slaid,expander; ');
writeln(fp,'procedure ishod;               ');
writeln(fp,'implementation                 ');
writeln(fp,'procedure ishod;               ');

1:  readln(fg,s);
    if copy(s,1,3)='{█}' then goto 1;
    if copy(s,1,3)='{▒}' then begin
      writeln(fp,'assign(f2,''progr.sav'');');
      writeln(fp,'assign(f1,''progr.pas'');');
      writeln(fp,'reset(f1);        ');
      writeln(fp,'rewrite(f2);      ');
      writeln(fp,'while eof(f1)=false do begin  ');
      writeln(fp,'readln(f1,s);              ');
      writeln(fp,'writeln(f2,s);              ');
      writeln(fp,'end;              ');
      writeln(fp,'close(f1); close(f2);');
      writeln(fp,'end;              ');
      writeln(fp,'end.              ');
      close(fp); goto 2; end;
    writeln(fp,s);
    goto 1;
2:  close(fg);
    assign(fp,'progr.sav'); rewrite(fp);
    assign(fg,'progr.pas'); reset(fg);
3:  readln(fg,s);
    if copy(s,1,3)='{░}' then goto 4;
    writeln(fp,s);
    goto 3;
4:  close(fg); erase(fg); close(fp); rename(fp,'progr.pas');
    end.
