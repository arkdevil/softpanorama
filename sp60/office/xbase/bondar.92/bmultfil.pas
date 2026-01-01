{Размножение файлов. 
Автор Евгений Бондарь,Луганск,[0642] 52-41-07 [p]
}
{$I-,R-,B-,S-,V-}
{$M 4096,0,0}
Uses Dos;
Type
 Names=String[65];
const
 N4='-й параметр-не число!';
 Pref:boolean=false;
 k:byte=1;
 Name:Names='';

var
i,j:longint;
c,numRead:word;
s:Names;
curs:word absolute 0:$450;
ch:char;
Buf:array[1..64000] of byte;
F:File;
R:Registers;

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

Procedure Abort(Mess:string;Err:byte);
Begin
	Put(^M^J+Mess+^M^J^G);Halt(Err);
End;

Procedure MakeFile(S:Names);
{Копия файла.Поскольку предполагается,что размножаться будут не очень
большие файлы,то делается это единым блоком}
Begin
	Assign(f,S);Rewrite(f,1);
	If IoResult<>0 then Abort(S+' - Ошибка открытия',4);
	BlockWrite(F,Buf,NumRead);
	If IoResult<>0 then Abort(S+' - Ошибка записи',5);
	Close(f);
End;

Procedure DefOpt;
{Разбор командной строки}
Begin
	ch:=S[2];
	Pref:=(ch='P') or (ch='p')
End;

{Главная процедура}

begin
  Put(^M^J'Размножение файла.Бондарь-SoftWare,1992'^M^J);
  IF ParamCount<3 then begin
	Put('Usage:BMultFil <Образец> <Число1> <Число2> [Шаг] [Придаток] [/P]'^M^J^G+
	'Копирует файл-образец в ряд файлов с названиями вида ПридатокЧисло,'^M^J+
	'где число меняется от Число1 до Число2 с Шагом [1].'^M^J+
	'Если указана опция /P ,создаются файлы ЧислоПридаток'^M^J);
	exit;
  end;
  if ParamCount=6 then begin
	S:=ParamStr(6);DefOpt;
  end;
  If ParamCount>=5 then Begin
	S:=Paramstr(5);
	If S[1]='/' then DefOpt
	Else Name:=S;
  End;

  Val(paramstr(2),i,c);
  if c<>0 then Abort('2'+n4,1);
  Val(ParamStr(3),j,c);
  if c<>0 then Abort('3'+n4,1);
  If ParamCount>=4 then begin
	S:=ParamStr(4);
	If S[1]='/' then DefOpt
	Else Begin
		Val(S,k,c);
		if c<>0 then begin Name:=S;k:=1;end;
	End;
  end;
  Assign(F,ParamStr(1));reset(F,1);
  If IoResult<>0 Then Abort(ParamStr(1)+' - Ошибка открытия',2);
  BlockRead(f,Buf,FileSize(f),NumRead);
  If IoResult<>0 then Abort(ParamStr(1)+' - Ошибка чтения',3);
  Close(f);
  c:=curs;
  while i<=j do begin
	str(i,s);
	IF not Pref then s:=name+s
	else S:=S+name;
	Put(S);
	MakeFile(s);
	i:=i+k;
	Curs:=c;
  end;
end.
