{Для всех файлов ,указанных в командной строке запуск Clipper,если OBJ
отсутствует или старый.
Автор Евгений Бондарь,Луганск,[0642] 52-41-07 [p]
}
{$I-,R-,B-,S-,V-}
{$M 4096,0,0}
uses Dos;
Const Clip:String[11]='CLIPPER.EXE';
var
	 f,f1:file;
         Dir:dirStr;
         Name:NameStr;
         Ext:ExtStr;
         FullName:String;
         Time,Time1:LongInt;
	 i,De:Integer;
         R:Registers;

Procedure Put(Mess:string);
{Вывод строки на дисплей.Позволяет сэкономить пару параграфов,относительно
 Write}
Var
 L:byte Absolute Mess;
 i:byte;
Begin
  with R do begin
	Ah:=2;For i:=1 to L Do begin Dl:=Ord(Mess[i]);MsDos(r);End;
  End;
End;


Function Exist(Name:String):Boolean;
{Проверка существования файла}
Var f:file;
Begin
	Assign(f,Name);Reset(f);Close(f);
	Exist:=Ioresult=0;
End;


Function ExistOnPath(name:String;Var FullName:String):boolean;
{Проверка существования файла во всех каталогах PATH}
Var
 S,Rs:string;
 L:Byte absolute S;
 Lr:Byte absolute Rs;
 i:byte;

Begin
 ExistOnPath:=true;
 FullName:=Name;
 If Exist(name) then Exit;
 Rs:=GetEnv('PATH');
 S:='';
 While Lr<>0 do Begin
	I:=1;
	While (Rs[i]<>';') and (i<>Lr) do Begin S:=S+Rs[i];Inc(i);end;
	If (S[L]<>'\') and (S[L]<>'/') Then FullName:=S+'\'+Name
	else FullName:=S+Name;
	If Exist(FullName) then exit
	Else Begin
		Delete(Rs,1,i);S:='';
	End;
 End;
 ExistOnPath:=False;
End;

Function NeedClipper(Name:String):Boolean;
{Проверка необходимости трансляции}
Begin
 NeedClipper:=False;
 Assign(F,Name+'.obj');Assign(F1,Name+'.prg');
 Reset(f1,1);
 GetFtime(F1,Time1);
 If IoResult<>0 then Exit;
 Reset(f,1);
 GetFtime(F,Time);
 If (IoResult<>0) or (Time<Time1) then Begin
   Close(f);Close(f1);
   NeedClipper:=True;
 End;
End;

{Главная процедура}


begin
 If ParamCount=0 then Begin
	Put('Запуск Clipper ,если Obj отсутствует или он старый.'^M^J'Использование :NeedClip <Prg1> ..[PrgN]'^M^J);
	Put('При наличии ошибки в PRG останавливается с кодом 1'^M^J'Бондарь-SoftWare,1992.Луганск,52-41-07'^M^J);
	Halt;
 End;
 If ExistOnPath(Clip,FullName) then For i:=1 To ParamCount do begin
	If NeedClipper(ParamStr(i)) then Exec(FullName,ParamStr(i)+' -q');
	De:=DosExitCode;
	If De<>0 Then Halt(De);
 End
 Else Put('Не обнаружен '+Clip+^M^J);
end.
