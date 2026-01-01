{Уничтожение каталога с подкаталогами(кроме содержащих ReadOnly)
Автор Евгений Бондарь,Луганск,[0642] 52-41-07 [p]
}
{$I-,R-,B-,S-,V-}
{$M 16384,0,0}
uses dos;
var
 F:File;
 n,p:byte;
 S:pathStr;
 c:char;
 w:word;

 Curs:word absolute 0:$450;
 R:registers;

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


Function delDir(S:PathStr):boolean;
{Рекурсивное уничтожение файлов и самой директории}
var
 Sr:SearchRec;
Begin
  ChDir(S);
  If IoResult <>0 then begin delDir:=false;exit;end;
  FindFirst('*.*',AnyFile,Sr);

  With Sr do begin
     While DosError = 0 do begin
	{If (Attr and VolumeId)=0 then}
	  Case Attr Of
		Directory:If (Name<>'.') and (Name<>'..') then begin
			If Not DelDir(Name) then Put('Директория '+Name+' не может быть уничтожена'^M^J);
		End;
		else begin
			Assign(f,name);Erase(f);
		End;
	  End;
	FindNext(Sr);
     end;
  end;
  ChDir('..');
  Rmdir(S);
  DelDir:=IoResult=0;
End;

Function Kb16:Char;
{Замена ReadKey (CRT) - с целью сокращения EXE}
var R:registers;
Begin
     With R do begin
          Ax:=0;Intr($16,R);
          Kb16:=UpCase(Chr(Al))
     End;
End;

{Главная процедура}

begin
 If ParamCount<1 then
	Put(
'Полное уничтожение каталога.'^M^J'Использование : BDD <Directory> .БОHДАРЬ - SoftWare,1992.Луганск,52-41-07'^M^J)
 Else begin
	c:=' ';
	Put(^M^J'Вы действительно хотите уничтожить каталог вместе с подкаталогами ?(Y/N) ');
	W:=Curs;
	While (C<>'N') and (c<>'Y') do begin
		Curs:=w;C:=Kb16;
	End;
	If c='Y' then begin
		Put(^M^J'Начнем,пожалуй.'^M^J);
                If DelDir(ParamStr(1)) then Put('Все,однако !'^M^J)
                else Put('Директория '+ParamStr(1)+' не может быть уничтожена'^M^J);
	End;
 end;
end.
