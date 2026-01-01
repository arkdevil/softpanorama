{Создание структуры каталогов. 
Автор Евгений Бондарь,Луганск,[0642] 52-41-07 [p]
}
{$I-,R-,B-,S-,V-}
{$M 4096,0,0}
Uses Dos;
Type Names=string[12];
const
 N4='-й параметр-не число!';
 K:byte=1;
 Pref:Boolean=False;
 Name:Names='';

var
i,j:longint;
c:word;
s:Names;
curs:word absolute 0:$450;
ch:char;
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


Procedure Abort(Mess:string);
Begin
	Put(Mess+^M^J^G);Halt;
End;


Procedure DefOpt;
{Разбор командной строки}
Begin
	ch:=S[2];
	Pref:=(ch='P') or (ch='p');
End;

{Главная процедура}

begin
  Put(^M^J'Размножение директорий.Бондарь-SoftWare,1992'^M^J);
  IF ParamCount<2 then Abort('Usage:BMD Numb1 Numb2 [Step] [What_Append] [/P]');
  if ParamCount>=5 then begin
	S:=ParamStr(5);
	DefOpt;
  end;
  If ParamCount>=4 then Begin
	S:=Paramstr(4);
	If S[1]='/' then DefOpt
	Else Name:=S;
  End;
  Val(paramstr(1),i,c);
  if c<>0 then Abort('1'+n4);
  Val(ParamStr(2),j,c);
  if c<>0 then Abort('2'+n4);
  If ParamCount>=3 then begin
	S:=ParamStr(3);
	If S[1]='/' then DefOpt
	Else Begin
		Val(S,k,c);
		if c<>0 then begin Name:=S;k:=1;end;
	End;
  end;
  c:=curs;
  while i<=j do begin
    str(i,s);
    IF not Pref then s:=name+s
    else S:=S+name;
    Put(S);
    MkDir(s);
    if IOResult<>0 then Abort('- Ошибка открытия директории');
    i:=i+k;
    Curs:=c;
  end;
end.
