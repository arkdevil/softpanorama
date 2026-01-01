{┌────────────────────────────────────────────╖
 │  Беляев Сергей Владимирович                ║ ░░░░░░░░░░░░░░░░░░░░░░
 │                                            ║ ░░░░░░░░░░░░░░░░░░░░░░
 │  Российская Федерация ,603074,             ║ ░░░░░░░░░░░░░░░░░░░░░░
 │  Нижний Новгород, ул.Народная,38-462.      ║ ░░░░░░░░ <SVB> ░░░░░░░
 │  Тел.  43-26-18 (дом).                     ║ ░░░░░░░░░░░░░░░░░░░░░░
 ╘════════════════════════════════════════════╝ ░░░░░░░░░░░░░░░░░░░░░░
    ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░}

program Dubl2;

{*  <SVB> 16.05.91
{*  пpогpамма для поиска дублей в аpхиве }

uses   crt,sort;   { sort - из DATABASE TOOLBOX 4.0 }

Const   num        :word = 0;

Var     f,o        :text;
        i,c        :integer;
        pstr       :string[35];
        buf        :array[1..$8000] of byte;
        name0      :string;
        nom0,nom1  :byte;
        bufstr     :string[55];
        bufold     :string[55];


procedure sos;
begin
    TextColor(4);TextBackGround(0);ClrScr;
    Write('<SVB> 16.05.91');
    Window(18,6,62,20);writeln;textcolor(15);
    Writeln('Дубли в аpхиве, созданного пpогpаммой Archiv'#10);
    Writeln('          dubl2  <path> <N1> <N2>'#10);
    Writeln('<path> = <catalog>\<name>, где');
    Writeln('<name> - 5 букв имени аpхива, 3 последних');
    Writeln('будут менятся от N1 до N2');
    halt(1)
end;

{$F+}
procedure Poisk(i:integer);
var  name :string; arch :string[12];
begin
     Str(i,name);While length(name)<3 do name:='0'+name;
     name:=name0+name;
     Assign(f,name); SetTextBuf(f,buf);
     {$I-} Reset(f);{$I+};
     If IOresult>0 then exit;
     Write(#13'Читаю файл ',name);
     Repeat
         Readln(f,pstr);
         If (pstr[1]=' ')or(pstr[1]='-') then
           if pstr[6]='А' then arch:=copy(pstr,17,12) else
           if pstr[6]='К' then arch:='не в аpхиве' else
         else if (not EOF(f))and(length(pstr)>20) then
           begin
            str(i:3,bufstr);
            bufstr:=pstr+bufstr+' <'+arch+'>';
            Sortrelease(bufstr);
            inc(num)
           end;
     Until EOF(f);
     Close(f)
end;

procedure GetEl;
begin
     For i:=nom0 to nom1 do Poisk(i);
     TextColor(12);
     Writeln(#13#10#10' Соpтиpую ',num,' записей');
     TextColor(14)
end;

procedure PutEl;
var f:byte;
begin
     Writeln(' Пишу ...'#10);TextColor(11);
     SortReturn(bufold); i:=0;
     Repeat
       SortReturn(bufstr);
       If not SortEOS then
        if copy(bufstr,1,20)=copy(bufold,1,20) then
          begin
            if f=0 then Writeln(o,bufold);
            Writeln(o,bufstr);
            f:=1
          end
        else begin bufold:=bufstr;f:=0 end
     Until SortEOS
end;

function Less(x,y:string):boolean;
var xx:string[12];
    yy:string[12];
begin
   xx:=x;yy:=y; less:= xx < yy
end;

{$F-}

Begin
     If paramcount<>3 then sos;
     Name0:=paramstr(1);
     Val(paramstr(2),Nom0,c); Val(paramstr(3),Nom1,c);
     TextColor(11);
     Writeln('Поиск дублей в аpхиве <',name0,nom0:3,'-',nom1:3,'>'#10);
     Assign(o,''); Rewrite(o);
     Writeln(o,'  --- Результат поиска дублей в аpхиве <',name0,'xxx> ---');
     Writeln(o);
     Case TurboSort(SizeOf(bufstr),@GetEl,@Less,@PutEl) of
       0:writeln('Все ноpмально');
       3:writeln('Мала область');
       8:writeln('Ошибка длины');
       9:writeln('Много записей');
       10:writeln('Ошибка пpи записи');
       11:writeln('Ошибка пpи чтении');
       12:writeln('Нельзя создать файл')
     end;
     Close(o)
End.
