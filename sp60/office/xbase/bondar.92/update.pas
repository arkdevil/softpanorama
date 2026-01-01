{Обновление директории,при запуске с параметром /F-освежение.
Автор Евгений Бондарь,Луганск,[0642] 52-41-07 [p] }

{$M 2048,0,0}
{$I-,R-,V-,B-,S-}
uses dos;
const
 were:boolean=false;
 fresh:boolean=true;
 ZNAK:SET OF CHAR=['/','\',':'];
 ErrMess:array[0..5] of string[20]=
(^M^J^G'Все,однако !   ',
 ' - Ошибка открытия ! ',
 ' - Ошибка чтения !   ',
 ' - Ошибка записи !   ',
 'Делать то и нечего!'^g,
 ' - Диск не готов !   '
 );
var
 Sr,Sr1:SearchRec;
 f,f1:file;
 num,i,j:word;
 ad1,ad2,p2:Pathstr;
 buf:array[1..maxint] of byte;
 d:byte;c:char;
 ln:byte absolute p2;
 Fs_d:DirStr; Fs_n:NameStr; Fs_Ext:Extstr;
 ts:string;
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


Procedure Abort(Err:byte);
Begin
	Put(ErrMess[Err]+^M^J);Halt(Err);
End;

Procedure Cpf(n,n1:string;tm:Longint;PlSize:boolean);
{Копирование файла при наличии свободного места}

const
 sp:longint=0;
var
 Rz,Rz1:longint;
Begin
	were:=true;
	assign(f,n);assign(f1,n1);
	Put(^m^j+n);
	Reset(f,1);
	rz:=FileSize(f);
	Sp:=DiskFree(d);
	If Sp<0 then Abort(5);
	Reset(f1,1);
	If IOResult=0 then begin
             Rz1:=FileSize(f1);
             if PlSize then Sp:=Sp+Rz1;
             if rz>Sp then begin Put(^g'- Не хватило места.Пропущен.'^M^J);close(f);exit;end;
        End;
	Rewrite(f1,1);
	If IoResuLt <> 0 then Abort(1);

	if Rz>maxint then rz:=MaxInt;
	Repeat
		BlockRead(F,buf,rz,i);
		If IoResuLt<>0 then Abort(2);
		BlockWrite(F1,Buf,i,j);
		If IoResuLt<>0 then Abort(3);
	Until (i=0) or (J<>i);
	SetFTime(f1,tm);
	Close(f);Close(f1);
End;

{Главная программа}
begin
	Put(^M^J'Обновление директории.Бондарь-Software,1991.Луганск,52-41-07.'^M^J);
	if ParamCount=0 then begin Put('Usage:Update <скелет> [<путь>] [/F]-только аналоги.'^M^J);exit;end;
	ad1:=paramstr(1);
	Fsplit(ad1,Fs_D,FS_n,FS_ext);
	if ParamCount>1 then begin
		p2:=ParamStr(2);
		if (p2='') or (p2='/f') or (p2='/F') then begin ad2:='a:';d:=1;end
		else begin
			if NOT (p2[ln] IN znak) then p2:=p2+'\';
			ad2:=p2;
 			if Ad2[1]='\' then d:=0
			else d:=Ord(UpCase(Ad2[1]))-64;
		end;
	End
	Else begin
{по умолчанию копируем на A:}
		ad2:='a:';d:=1;
	end;

	fresh:=not ((p2='/f') or (p2='/F') or
		(paramStr(3)='/f') or (ParamStr(3)='/F'));
	FindFirst(ad1,$20+$1,Sr);
	If DosError>128 then Abort(5);

{Поиск по маске и проверка необходимости копии}
	WHile DosError=0 do with Sr do begin
	   Ts:=ad2+name;
	   FindFirst(Ts,Archive+ReadOnly,Sr1);

	   if (DosError=0) then begin
		if (Time >Sr1.Time) or (Sr1.Size=0) then CpF(FS_d+name,Ts,Time,true)
	        end
	   else if Fresh then CpF(Fs_D+name,Ts,Time,false);
	   DosError:=0;
	   FindNext(Sr);
	End;
	if Were then Abort(0)
	ELSE Abort(4);
end.
