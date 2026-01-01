{Уничтожение каталога с подкаталогами(кроме содержащих ReadOnly)
Автор Евгений Бондарь,Луганск,[0642] 52-41-07 [p]
}
{$I-,R-,B-,S-,V-}
{$M 4096,0,0}
uses dos;
Const Before:boolean=false;
var
 F:File;
 R:Registers;
 BfTime:LongInt;
 T:DateTime;
 Sp:string[6];
 Cd:integer;

Procedure Put(s:string);
{Вывод строки на дисплей.Позволяет сэкономить пару параграфов,относительно
 Write}
Var
 L:byte Absolute s;
 i:byte;
Begin
  with R do begin
	Ah:=2;For i:=1 to L Do begin Dl:=Ord(s[i]);MsDos(r);End;
  End;
End;

Procedure Abort(Mess:String);
begin
	Put(Mess+^M^J^G);Halt(1);
End;

Procedure delDir(S:PathStr);
{Рекурсивное уничтожение файлов}

var
 Sr:SearchRec;
Begin
  FindFirst('*',Directory,Sr);
  With Sr do begin
     While DosError = 0 do begin
	If (Name<>'.') and (Name<>'..') and (Attr=Directory) then begin
		ChDir(Name);
		DelDir(S+'\'+name);
		ChDir('..');
	End;
	FindNext(Sr);
     end;
  end;
  FindFirst(ParamStr(1),Archive+SysFile+ReadOnly+Hidden,Sr);
  With Sr do begin
     While DosError = 0 do begin
        If not Before or (Time<BfTime) then begin
           Put(S+'\'+name+^M^J);
           Assign(f,name);
	   If (Attr and ReadOnly)<>0 then SetFattr(F,Archive);
           Erase(f);
        end;
	FindNext(Sr);
     end;
  end;
End;

{Главная процедура}

begin
 If ParamCount<1 then Put(
'Уничтожение файла во всех подкаталогах.'^M^J'Использование : BDFile <Mask> [DDMMYY].ELB-SoftWare,1992.Луганск,52-41-07'^M^J)
 Else begin
   If ParamCount>1 then with T do begin
	Sp:=ParamStr(2);
	Val(Copy(Sp,1,2),Day,Cd);
	If (cd<>0) or (day=0) or (day>31) then Abort('Неверно задан день');
	Val(Copy(Sp,3,2),Month,Cd);
	If (cd<>0) or (month=0) or (month>12) then Abort('Неверно задан месяц');
	Val(Copy(Sp,5,2),Year,Cd);
	If (cd<>0) then Abort('Неверно задан год');
	Year:=year+1900;
	Hour:=0;Min:=0;Sec:=0;
	PackTime(T,BfTime);
	Before:=true;
   End;
   DelDir('');Put('Все,однако !'^M^J);
 end;
end.
