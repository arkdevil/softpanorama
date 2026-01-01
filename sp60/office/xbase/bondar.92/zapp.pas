(* Программа делает ZAP на все указанные DBF,
при запуске с параметром S и в подкаталогах.
Автор Евгений Бондарь,Луганск,[0642] 52-41-07 [p]
*)
{$I-,R-,B-,S-,V-}
uses Dos;

Const NeedRecurs:boolean=false;

var
 S:string;
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


Procedure ZapFile(S:string);
{Поиск по маске,переход в подкаталоги и  собственно ZAP}
label 99;
Var
 Sr:SearchRec;
 f:file of byte;
 buf :array[1..11] of byte;
 i,j:byte;
Begin
  If NeedRecurs then Begin
   S:=S+'\';
   FindFirst('*',Directory,Sr);
   With Sr do begin
     While DosError = 0 do begin
	If (Name<>'.') and (Name<>'..') and (Attr=Directory) then begin
		ChDir(Name);
		ZapFile(S+Name);
		ChDir('..');
	End;
	FindNext(Sr);
     end;
   end;
  End;
  FindFirst(ParamStr(1),Archive,Sr);
  While DosError=0 do With Sr do begin
	Put(s+Name);
	assign(f,Name);reset(f);
	Read(f,i);
	if IoResult<>0 then begin Put(' - Ошибка чтения'^M^J^G);goto 99;end;
	if (i<>3) And (i<>131) and (i<>$f5) and (i<>$8b) then begin
		Put(' - Не опознана структура'^M^J^G);goto 99;
	end;
	for i:=2 to 10 do read(f,buf[i]);
	i:=0;
	Seek(f,4);Write(f,i,i,i);
	Seek(f,buf[10]*256+buf[9]-1);
	i:=13;j:=26;Write(f,i,j);
	Truncate(f);Close(f);
	if IoResult<>0 then begin Put(' - Ошибка записи'^M^J^G);goto 99;end;
	Put(' - Готово !'^M^J);
99:	FindNext(Sr);
 End;
End;

{Основная программа}
BEGIN
  Put(^M^J'Удаление всех записей в базах dBASE.V1.3'^M^J'БОНДАРЬ-Software,1992.Луганск,52-41-07.'^M^J);
  If Paramcount=0 then begin
	Put('Вызов : Zap файл(ы) [Subdir]'^M^J^g);Exit;
  end;
  If Paramcount>1 then begin
	S:=ParamStr(2);NeedRecurs:=((S[1]='S') or (S[1]='s'));
  end;
  ZapFile('');
END.
