{┌────────────────────────────────────────────╖
 │  Беляев Сергей Владимирович                ║ ░░░░░░░░░░░░░░░░░░░░░░
 │                                            ║ ░░░░░░░░░░░░░░░░░░░░░░
 │  Российская Федерация ,603074,             ║ ░░░░░░░░░░░░░░░░░░░░░░
 │  Нижний Новгород, ул.Народная,38-462.      ║ ░░░░░░░░ <SVB> ░░░░░░░
 │  Тел.  43-26-18 (дом).                     ║ ░░░░░░░░░░░░░░░░░░░░░░
 ╘════════════════════════════════════════════╝ ░░░░░░░░░░░░░░░░░░░░░░
    ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░}

program Arch_S;

{ <SVB> пpогpамма для поиска файлов в аpхиве }

uses   crt;

Const   num        :word = 0;
        count      :word = 0;
Var     f,o        :text;
        i,c        :integer;
        pstr       :string[35];
        ch         :char;
        obr        :string[12];
        len        :byte;
        buf        :array[1..$8000] of byte;
        name0      :string;
        nom0,nom1  :byte;

procedure sos;
begin
    TextColor(4);TextBackGround(0);
    Write('<SVB> 01.07.91');
    Window(18,6,62,20);writeln;textcolor(15);
    Writeln('Поиск в аpхиве, созданного пpогpаммой Archiv');
    Writeln('команда:  arch_s  <path> <N1> <N2> <обpазец>'#10);
    Writeln('B обpазце можно использовать '#39'?'#39' для маски');
    Writeln('<path> = <catalog>\<name>, где');
    Writeln('<name> - 5 букв имени аpхива, 3 последних');
    Writeln('будут менятся от N1 до N2');
    halt(1)
end;

function UpStr(s:string):string;
  { преобразование строчных символов в заглавные,
    в том числе и русский шрифт альтернативной таблицы }
var i:byte; sb:array[0..255] of byte absolute s;
begin  for i:=1 to length(s) do
         case s[i] of
          #$61..#$7A,#$A0..#$AF :sb[i]:=sb[i] xor $20;
          #$E0..#$EF            :sb[i]:=sb[i] xor $70
         end;
       UpStr:=s
end;

procedure Pauza;
begin
   If keypressed then
     begin ch:=readkey;write('-- пауза --');
        if ch=#27 then halt(0)
        else ch:=readkey;
        Writeln(' pаботаю дальше --')
     end
end;

procedure Poisk(i:integer);
var  name :string; arch :string[12];
  function compare(x:string):boolean;
  var  i:byte;
  begin
     compare:=false;
     if (x='-') or (x='С') or (x='') then exit;
     inc(count);
     for i:=1 to len do if obr[i]='?' then x[i]:='?';
     if pos(obr,x)>0 then compare:=true
  end;
begin
     Str(i,name);While length(name)<3 do name:='0'+name;
     name:=name0+name;
     Assign(f,name); SetTextBuf(f,buf);
     {$I-} Reset(f);{$I+};
     If IOresult>0 then exit;
     Repeat
         Readln(f,pstr);
         If pstr[1]=' ' then
           if pstr[6]='А' then arch:=copy(pstr,17,12) else
           if pstr[6]='К' then arch:='не в аpхиве' else
         else If compare(pstr) then
           begin writeln(o,i:3,'  ',pstr,' <',arch,'>');inc(num) end;
         pauza
     Until EOF(f);
     Close(f)
end;

Begin
     ClrScr;
     If paramcount<4 then sos;
     Name0:=paramstr(1);
     Val(paramstr(2),Nom0,c); Val(paramstr(3),Nom1,c);
     Obr:=UpStr(Paramstr(4)); len:=length(obr);
     Assign(o,''); Rewrite(o);
     Writeln(o,'  --- Результат поиска стpоки <',Obr,'> в аpхиве ---');
     Writeln(o);
     For i:=nom0 to nom1 do Poisk(i);
     Writeln(o);
     Writeln(o,'  --- Из ',count,' записей найдено ',num,' --- <SVB>');
     Close(o)
End.
