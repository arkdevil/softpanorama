{$A+,B-,D+,E+,F-,I-,L+,N-,O-,R-,S-,V-}
{$M 16384,0,655360}
uses dos;

type
      s2  = string[2];
      s12 = string[12];
      s13 = string[13];
type             {--------------- Типы данных для дерева в памяти }
      pbt = ^Bt;
      pat = ^At;
      At = record
	     PrDir : pAt;     { Ук. на предыдущий директорий }
	     PB    : pBt;     { Ук. на 1-й поддиректорий }
	     PE    : pBt;     { Ук. на последний поддиректорий }
	   end;
      Bt = record             { Структура поддиректория }
	     name    : s12;   { Имя }
	     contens : At;    { Содержание - см. At }
	     next    : pBt;   { Следующий поддиректорий в списке }
	   end;

var root   : At;  { Коренной директорий }
    CurDir : pAt; { Вспомогательный указатель, чтобы ходить по всему дереву }

    SaveDir: string;  { Здесь хранится оригинальный директорий }
    NumCat : word;    { Счетчик каталогов }

const
    DrawTree : boolean = false; { Рисовать дерево ? }

{-----------------------------------------------------------------}
function FillString(ch:char; c:byte):string;
       { - формирует на выходе строку из c байтов ch }
var ws:string;
begin
 fillchar(ws[1],c,ch); ws[0]:=char(c);
 fillstring:=ws;
end;
{----------------------------------------------------------------}
procedure ScanDir;   { Сканирование текущего директории и дополнение дерева }

var sr : searchrec;  { Буфер для поиска файлов }
    de : word;       { Сохраняем код последнего поиска }

  {-------}
  procedure IncludeFile(nm:s12; atr:word);
   begin
     if (atr and $10 =0) or (nm[1]='.') then exit; { Это директорий ? }
     inc(NumCat);
     with CurDir^ do
      begin
	if pb=nil
	  then { пустое поддерево }
	   begin
	     getmem(pb,sizeof(bt)); pe:=pb;       { Создаем первый эл-т списка }
	   end
	  else { уже что то есть }
	   begin
	    getmem(pe^.next,sizeof(bt)); pe:=pe^.next; { Создаем следующий }
	   end;
	pe^.name:=nm;
	pe^.contens.pb:=nil;
	pe^.next:=nil;
	pe^.contens.prdir:=curdir;
      end;

     ChDir(nm);
     CurDir:=@CurDir^.pe^.contens;
     ScanDir;
   end;
{---------------}
begin
   FindFirst('*.*',$10,sr);
   if DosError<>0 then exit;
   IncludeFile(sr.name,sr.attr);
   repeat
    FindNext(sr);
    de:=doserror;
    if De=0 then IncludeFile(sr.name,sr.attr);
   until De<>0;
   if CurDir^.Prdir<>nil
    then
     begin
       ChDir('..');
       CurDir:=CurDir^.PrDir;
     end;
end;
{-------------------------------------------------------------}
type  ttype = array[1..5] of char;
      abyte  = array[1..100] of byte;

      Buft  = array[1..100] of { Сюда попадет основная информация для treeinfo }
	       record
		 name : array[1..13] of char;
		 u    : byte;
		 c    : word;
	       end;

const tit:ttype = 'PNCI'#0;    { Метка Пети Нортона }


var buf1 : record              { Заголовок treeinfo }
	     Labl : ttype;
	     nd   : word;
	     nd1  : word;
	   end;
    buf  : ^buft;              { Ссылка на информацию }
    bufa : ^abyte;             { Экв. Buf, но работает с массивом байтов }
    csum : word;               { Контрольная сумма }
var
    f    : file;
    cd   : word;               { При выводе дерева на экран - счетчик директ. }
    i,j  : integer;
    acol : array[1..63] of boolean; { Признак колонки при рисовании }
    s    : string;
{-----------------------------------------------------------}
procedure WriteDir(nm:s13; u:byte; c:word; eod:boolean);
       { - Записывает в буфер для treeinfo и рисует на экране
	   директорию nm, u - ур. вложенности,
	   c - признак положения подкаталога для treeinfo
	   eod - true, если нет поддиректорий }

var i:byte;
    cb,curb:pbt;
{------}
   procedure DrawSubDir;  { Рисование данного имени на экране по алгоритму ncd }
   var ws : string;
       ch : string[1];
       i  : byte;
   begin
    if Lo(c)=0 then writeln;
    ws:='';
    for i:=1 to u do
      if Lo(c)=0 then
       begin
	if i=1 then ws:=ws+FillString(' ',6)
               else ws:=ws+FillString(' ',12);
	if i<>u then
	 if acol[i] then ws:=ws+'│' else ws:=ws+' ';
       end;
    acol[u]:=boolean(Hi(c)); { Будет ли ответвление вниз }
    case c of
     $0000 : ch:='└';
     $0100 : ch:='├';
     $0001 : if u<>0 then ch:='-' else ch:='';
     $0101 : ch:='┬';
    end;
    ws:=ws+ch+nm;
    if not eod then
         if u<>0 then ws:=ws+FillString('─',12-length(nm))
                 else ws:=ws+FillString('─',6 -length(nm));
    write(ws);
   end;
{------}
   procedure NextItem(flag:boolean);    { На следующий элемент списка + удаление}
   begin
    cb:=curb^.next;
    curdir^.prdir^.pb:=cb;
    freemem(curb,sizeof(bt));
    curb:=cb;
    if flag then
     begin
      CurDir:=@curb^.contens;
      eod:=curb^.contens.pb=nil;
     end;
   end;
{------}
begin
 nm[length(nm)+1]:=#0;         { Имя должно кончаться на 0 }
 inc(cd);
 move(nm[1],buf^[cd].name,13); { Заполнение буфера для treeinfo }
 buf^[cd].u:=u;
 buf^[cd].c:=c;

 if DrawTree then DrawSubDir;  { Рисуем имя на экране }

 curb:=CurDir^.pb;
 eod:=curb^.contens.pb=nil;
 if curb<>nil then             { Есть поддиректории ? }
  begin
    CurDir:=@curb^.contens;

    if curb^.next<>nil then    { Больше 1 поддиректория }
       begin
	WriteDir(curb^.name,u+1,$0101,eod);           {'─┬─'}
	NextItem(true);
	while (curb<>nil) and (curb^.next<>nil) do
	 begin
	  WriteDir(curb^.name,u+1,$0100,eod);         {' ├─'}
	  NextItem(true);
	 end;
	WriteDir(curb^.name,u+1,$0000,eod);           {' └─'}
	NextItem(false);
       end
    else
      begin
	 WriteDir(curb^.name,u+1,$0001,eod);          {'───'}
	 NextItem(false);
      end;

   CurDir:=CurDir^.PrDir;

  end
 else FreeMem(CurDir,sizeof(at));

end;
{----------------------------------------}
procedure NCDScan(drive:s2);
begin
  root.pb:=nil; root.prdir:=nil; { нуль дерево }
  NumCat:=1;
  CurDir:=@root;

  ChDir(drive+'\');
  writeln;
  ScanDir;

  buf1.labl:=tit; buf1.nd:=NumCat; buf1.nd1:=NumCat+$12a;
  cd:=0;
  getmem(buf,16*NumCat);      { Заполняем буфер заголовка treeinfo }

  getdir(0,s);
  WriteDir(copy(s,1,2)+'\',0,$0001,false); { Заполняем буфер }
			      { Имя коренного каталога - типа E:\, F:\ ... }
  assign(f,'treeinfo.ncd');
  rewrite(f,1);
  blockwrite(f,buf1,sizeof(buf1));
  blockwrite(f,buf^,16*NumCat);

  csum:=0; move(buf,bufa,sizeof(pointer));
  for i:=1 to NumCat*16 do csum:=csum+bufa^[i]; { Считаем контрольную сумму }

  blockwrite(f,csum,2);
  close(f);
  writeln;
  freemem(buf,16*NumCat); { Сброс буфера }
end;
{----------------------------------------}

var p,dr : s2;
begin
  Writeln(' -------------Scanning DIRecory-------------');
  Writeln('    (C) 1992 by Dmitry A. Gurtjak (Donetsk) '); Writeln;
  Writeln(' USAGE : SDIR [/g] [drive1:] [drive2:] ...');
  Writeln('         /g - graphic tree');
  GetDir(0,SaveDir);
  dr:='';

  for j:=1 to ParamCount do
   begin
     p:=copy(paramstr(j),1,2);
     if (p='/g') or (p='/G')
       then DrawTree:=true
       else
	if (p[1] in ['a'..'z','A'..'Z']) and (p[2]=':')
	 then
	  begin
	   dr:=p;
	   NCDScan(dr);
	  end;
   end;
  if dr='' then NCDScan(dr);

  ChDir(SaveDir);
end.