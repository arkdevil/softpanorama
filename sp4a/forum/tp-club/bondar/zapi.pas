(* Программа делает очистку индексных файлов ,
при запуске с параметром S и в подкаталогах.
Автор Евгений Бондарь,Луганск,[0642] 52-41-07 [p]
*)
{$I-,R-,B-,S-,V-}
uses Dos;

Const NeedRecurs:boolean=false;

var
 S:string;
 R:registers;
 Buf:array[0..511] of byte;
 f:file ;

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

Function Which:byte;
{Define Index type}

var Ls,Ls1:Longint;
Begin
 ls1:=LongInt(Buf[11])*16777216+LongINT(Buf[10])*65536+LongInt(Buf[9])*256+LongInt(Buf[8]);
 If Ls1=FileSize(f) then begin
    Which:=1;exit;
 end;
 If (Buf[12]>0) and (Buf[53]<2) Then begin
   If Buf[14] and 64 <>0 then Which:=3  {Idx-C}
   else Which:=2; {Idx}
    exit;
 End;
 If (Buf[0]=6) and (buf[2]=1) then Begin
 	Which:=4;exit;
 End;
 Which:=0;

end;

Function ZapUsualIdx:boolean;
{Clear FoxBase-Idx}
var i:word;
Begin
     ZapUsualIdx:=false;
     Seek(f,0);
     Buf[0]:=0;Buf[1]:=2;Buf[2]:=0;Buf[3]:=0;
     For i:=4 to 7 do Buf[i]:=255;
     Buf[8]:=0;Buf[9]:=4;Buf[10]:=0;Buf[11]:=0;
     BlockWrite(f,Buf,512);
     For i:=1 to 511 do Buf[i]:=0;
     Buf[0]:=3;
     For i:=4 to 11 do Buf[i]:=255;
     BlockWrite(f,Buf,512);
     if IoResult<>0 then begin Put(' - Ошибка записи'^M^J^G);ZapUsualIdx:=true;end;
End;

Function ZapCompact:boolean;

{Clear FoxPro Idx-Compact}

var i:word;
Begin
     ZapCompact:=false;
     Seek(f,0);
     Buf[0]:=0;Buf[1]:=4;
     For i:=3 to 11 do Buf[i]:=0;
     BlockWrite(f,Buf,512);
     Seek(f,1024);BlockRead(f,Buf,512);
     if IoResult<>0 then begin Put(' - Ошибка чтения'^M^J^G);ZapCompact:=true;exit;end;
     Buf[0]:=3;Buf[1]:=0;Buf[2]:=0;Buf[3]:=0;
     For i:=4 to 11 do Buf[i]:=255;
     Buf[12]:=$de;Buf[13]:=1;Buf[14]:=255;Buf[15]:=255;
     Buf[16]:=0;Buf[17]:=0;Buf[18]:=15;Buf[19]:=15;
     Buf[20]:=16;Buf[21]:=4;Buf[22]:=4;Buf[23]:=3;
     Seek(f,1024);
     BlockWrite(f,Buf,512);
     if IoResult<>0 then begin Put(' - Ошибка записи'^M^J^G);ZapCompact:=true;exit;end;
End;

Function ZapCdx:boolean;
Begin
     ZapCdx:={false}true;
     Put(' - составной пока не умею'^M^J^G);
End;

Function ZapNtx:boolean;
Begin
     ZapNtx:={false}true;
     Put(' - Clipper пока не умею'^M^J^G);
End;

Procedure ZapFile(S:string);
{Find and Clear Files}

label 99;
Var
 Sr:SearchRec;
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
	assign(f,Name);reset(f,1);
	if IoResult<>0 then begin Put(' - Ошибка чтения'^M^J^G);goto 99;end;
        BlockRead(f,buf,512);
	I:=Which;
        If I=0 then begin
		Put(' - Не опознана структура'^M^J^G);close(f);goto 99;
	end;
        Case I Of
             1:if ZapUsualIdx then goto 99;
             2:if ZapCompact then goto 99;
             3:if ZapCdx then goto 99;
             4:if ZapNtx then goto 99;
        End;
	Truncate(f);Close(f);
	if IoResult<>0 then begin Put(' - Ошибка записи'^M^J^G);goto 99;end;
	Put(' - Готово !'^M^J);
99:	FindNext(Sr);
 End;
End;

{Main Procedure}

BEGIN
  Put(^M^J'Очистка индексных файлов (Idx).V1.0. БОНДАРЬ-Software,1992.Луганск,52-41-07.'^M^J);
  If Paramcount=0 then begin
	Put('Вызов : ZapI файл(ы) [Subdir]'^M^J^g);Exit;
  end;
  If Paramcount>1 then begin
	S:=ParamStr(2);NeedRecurs:=((S[1]='S') or (S[1]='s'));
  end;
  ZapFile('');
END.
