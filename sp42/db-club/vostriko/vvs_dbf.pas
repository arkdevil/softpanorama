unit vvs_dbf;
interface
uses {TpCrt,}Dos;
{----------------------------------------------------------}
type head01=record   {общий заголовок}
       a1, {03 - без примечанй  83-с примечаниями}
       a2,a3,a4:byte; { 5a 05 06 yymmdd дата последнего обращения на запись}
       lf:longint; {записей в файле}
       headlen,  {длина заголовка}
       reclen:word; {длина записи}
       d1,d2,d3:byte; {резерв}
       d4:array[15..27] of byte; {резерв для локальной сети}
       h1,h2,h3,h4:byte; { 00 00 00 00 } {резерв}
     end;
     head02=record   { вектор описания поля}
       name:array[1..11] of char; {имя поля дополненное нулями}
       typef:char;   {тип поля /C,N,L,D,M/}
       posf:longint; {адрес поля записи в ОП}
       width:byte;   {ширина поля}
       dec:byte;
       e3:array[18..19] of byte; {резерв для локальной сети}
       f1:byte;
       f2:array[21..22] of byte; {резерв для локальной сети}
       f4:byte;      {set fields}
       g1:array[24..31] of byte; {резерв }
     end;
{ 0d - end of head,  потом может быть еще 00h }

{данные:}
{ 20h запись не удалена, 2Ah запись  удалена}
{далее данные сплошным потоком}

{после последней записи 1Ah}
{после последнего байта данных поля типа memo в файле .dbt 1A1Ah}
  dbf_buffer_type = array[1..65535] of Char;
  dbt_buffer_type = array[1..512] of Char;
  dbf_head_type = array[1..2047] of Head02;


     fbase_dcb=record   { заголовок поля}
        filedbf:file;
        filedbt:file;
        head:head01;

        N:longint; {номер записи (начиная с нуля) файла dbf
                   { которую будем читань/записывать }
        Nm:longint; {номер записи (начиная с нуля) файла dbt
                   { которую будем читань/записывать }
        pwrite:boolean; {признак записи}
        lastwrite:boolean;{признак записи последней записи файла}
        k:word; {количество полей}
        Buf : ^dbf_buffer_type;    {pointer to text buffer}
        Bufm: ^dbt_buffer_type;    {pointer to memo text buffer}
        phead:^dbf_head_type;        {pointer to headers buffer}
     end;

{ 0d - end of head }
{}
{----------------------------------------------------------}
procedure Open_Dbf(var dcb: fbase_dcb;filename_dbf2:string );
{процедура открытия файла.
      1. заполняются все поля переменной dcb;
      2. открывается файл dbf и, если надо, dbt;
      3. отводится память под заголовок и буферы
переменная filename_dbf2 должна содержать имя файла без расширения.
расширение dbf и dbt берутся автоматически}
{----------------------------------------------------------}
procedure Close_Dbf(var dcb: fbase_dcb);
{процедура закрытия файла. Выполняет действия обратные Open_Dbf}
{----------------------------------------------------------}
procedure Read_Dbf(var dcb: fbase_dcb );
{процедура чтения очередной записи файла в буфер.}

{----------------------------------------------------------}
procedure Seek_Dbf(var dcb: fbase_dcb; N:Longint);
{установка указателя на N-ю запись. }
{----------------------------------------------------------}
function Find_Dbf(var dcb: fbase_dcb; fn:string):word;
{поиск порядкового номера поля fn, если поле не найдено то возвращается 0
  этот номер далее следует использовать в процедурах/функциях:
Get_Dbf,Put_Dbf,Put_Dbf_Long,Put_Dbf_Real

  поле fn должно быть задано прописными буквами}
{----------------------------------------------------------}
{----------------------------------------------------------}
procedure Update_Dbf(var dcb: fbase_dcb);
{обновление последней прочитанной записи}
{----------------------------------------------------------}
procedure Write_Dbf(var dcb: fbase_dcb);
{запись следующей записи}
{----------------------------------------------------------}
{----------------------------------------------------------}
function Get_Dbf(var dcb: fbase_dcb; nf:word):string;
{Возвращает текстовое значение поля с порядковым номером nf;
для полей типа M возвращаются первые 255 сммволов}
{----------------------------------------------------------}
procedure Put_Dbf(var dcb: fbase_dcb; nf:word; arg:string);
{Заносит в буфер текстовое значение поля с порядковым номером nf;
не работаеть с полями типа M}
{----------------------------------------------------------}
procedure Put_Dbf_Long(var dcb: fbase_dcb; nf:word; arg:Longint);
{Заносит в буфер текстовое значение числового поля с порядковым номером nf;}
{----------------------------------------------------------}
procedure Put_Dbf_Real(var dcb: fbase_dcb; nf:word; arg:Real);
{Заносит в буфер текстовое значение числового поля с порядковым номером nf;}
{----------------------------------------------------------}
implementation

{----------------------------------------------------------}
procedure Open_Dbf(var dcb: fbase_dcb;filename_dbf2:string );
var attr,
    i:word;

    head0:array[1..32] of byte;
    head1:head01 absolute head0;{описание заголовка}
    head2:head02 absolute head0;{описание поля}
    offset:word;
  procedure  haltmsg(s:string);
  const x=10; y=10;
  begin
    Writeln(s);
    readln;
    halt(13);
  end;
begin offset:=1;
  dcb.phead:=NIL; (* Указатель на текущий элемент заголовка *)
  dcb.Bufm:=NIL;      {pointer to memo text buffer}
  assign(dcb.filedbf,filename_dbf2+'.dbf'); GetFAttr(dcb.filedbf,attr);
  if attr=0 then
    haltmsg('Файл '+filename_dbf2+'.dbf не найден.');
  reset(dcb.filedbf,1);

  blockread(dcb.filedbf,head0,32);{чтение заголовка}
  dcb.head:=head1;
  dcb.k:=(dcb.head.headlen div 32)-1; {количество полей}
  dcb.pwrite:=false; {признак записи}
  dcb.lastwrite:=false;  {признак записи последней записи файла}

{прочитали все заголовки. Теперь получим память для буфера}
  {allocate edit buffer}
  if dcb.head.headlen >   MaxAvail then
    haltmsg('Мало памяти для заголовка '+filename_dbf2);
  GetMem(dcb.phead, dcb.head.headlen-32);
  blockread(dcb.filedbf,dcb.phead^,dcb.head.headlen-32);{чтение заголовка поля}

  for i:=1 to dcb.k do
  begin
    dcb.phead^[i].posf:=offset;
    offset:=offset+dcb.phead^[i].width;
    if (dcb.phead^[i].typef='M')and(dcb.Bufm=NIL) then
    begin
      assign(dcb.filedbt,filename_dbf2+'.dbt'); GetFAttr(dcb.filedbt,attr);
      if attr=0 then
        haltmsg('Файл '+filename_dbf2+'.dbt не найден.');
      reset(dcb.filedbt,1);
      {открыли файл. Теперь получим память для буфера}
      {allocate memo buffer}
      if 512 >   MaxAvail then
          haltmsg('Мало памяти для буфера '+filename_dbf2);
      GetMem(dcb.bufm, 512);     {pointer to memo text buffer}
      dcb.nm:=0; {указатель на начало файла}
      blockread(dcb.filedbt,dcb.bufm^,512);{}
    end;
  end;
{прочитали все заголовки. Теперь получим память для буфера}
  {allocate edit buffer}
  if dcb.head.reclen >   MaxAvail then
    haltmsg('Мало памяти для буфера '+filename_dbf2);
  GetMem(dcb.buf, dcb.head.reclen);
  dcb.n:=0; {указатель на начало файла}

end; { Open_Dbf }

{----------------------------------------------------------}
procedure Close_Dbf(var dcb: fbase_dcb);
var head0:array[1..32] of byte;
    head1:head01 absolute head0;{описание заголовка}
begin if  dcb.pwrite then {признак записи}
  begin head1:=dcb.head;
    seek(Dcb.filedbf,0);
    blockWrite(dcb.filedbf,head0,32);{запись заголовка}
    if  dcb.lastwrite then {признак записи}
     begin
       seek(Dcb.filedbf,Dcb.head.reclen*Dcb.head.lf+Dcb.head.headlen);
      {длина записи}   {*}  {записей в файле} {*}   {длина заголовка}
      dcb.buf^[1]:=chr($1a);
       blockWrite(dcb.filedbf,dcb.buf^,1);{запись заголовка}
     end;
  end;

  close(dcb.filedbf);
  if (dcb.Bufm<>NIL) then
  begin
    close(dcb.filedbt);
  end;

  FreeMem(dcb.buf, dcb.head.reclen);
  FreeMem(dcb.phead, dcb.head.headlen-32);
end; { Close_Dbf }

{----------------------------------------------------------}
procedure Read_Dbf(var dcb: fbase_dcb);
begin
  blockread(dcb.filedbf,dcb.buf^,dcb.head.reclen);{}
  dcb.n:=dcb.n+1; {указатель на следующую запись файла}
end; { Read_Dbf }
{----------------------------------------------------------}
procedure Write_Dbf(var dcb: fbase_dcb);
begin
  dcb.pwrite:=true; {признак записи}
  blockWrite(dcb.filedbf,dcb.buf^,dcb.head.reclen);{}
  dcb.n:=dcb.n+1; {указатель на следующую запись файла}
  if dcb.n>dcb.head.lf then
  begin dcb.head.lf:= dcb.n;
    dcb.lastwrite:=true;  {признак записи последней записи файла}
  end;
end; { Read_Dbf }
{----------------------------------------------------------}
procedure Seek_Dbf(var dcb: fbase_dcb; N:Longint);
Var n1:longint;
begin n1:=n*dcb.head.Reclen+dcb.head.headlen;
  dcb.n:=n; {указатель на следующую запись файла}
  seek(Dcb.filedbf,n1); {Read_Dbf(dcb);{}
end;

{----------------------------------------------------------}
procedure Update_Dbf(var dcb: fbase_dcb);
begin Seek_Dbf(dcb,dcb.n-1); {указатель на следующую запись файла}
  Write_Dbf(dcb);
end;

{----------------------------------------------------------}
function Find_Dbf(var dcb: fbase_dcb; fn:string):word;
var fnam:string[11]; {имя поля}
    n,k,
    i:word;
begin k:=0;
  for n:=1 to dcb.k do if k=0 then
  begin
    fnam:='';
    for i:=1 to 11 do
       if dcb.phead^[n].name[i]<>chr(0) then fnam:=fnam+dcb.phead^[n].name[i];
    if fn=fnam then k:=n;
  end;
  Find_Dbf:=k
end; { Find_Dbf }
{----------------------------------------------------------}
function Get_Dbf(var dcb: fbase_dcb; nf:word):string;
var S:string; {имя поля}
    nr:word;
    i:word; n4:longint;
begin S:='';
  for i:=1 to dcb.phead^[nf].width do S:=S+dcb.buf^[i+dcb.phead^[nf].posf];
  if (dcb.phead^[nf].typef='M') then
   begin {memo}
     val(s,n4,i);
     if i=0 then
     begin
       if n4<>dcb.nm then
        begin
          dcb.nm:=n4; {указатель на начало файла}
          seek(Dcb.filedbt,n4*512); {Read_Dbf(dcb);{}
          blockread(dcb.filedbt,dcb.bufm^,512,nr);{}


        end;
       S:='';
       i:=1;
       while (i<=256)and(dcb.bufm^[i]<>chr($1a))do
       begin
         S:=S+dcb.bufm^[i]; i:=i+1;
       end;
     end;
   end;  {memo}
  Get_Dbf:=S;
end; { Get_Dbf }

{----------------------------------------------------------}
procedure Put_Dbf(var dcb: fbase_dcb; nf:word; arg:string);
var S:string[1]; {}
    i:word;
begin  for i:=1 to dcb.phead^[nf].width do
  begin S:=' '; if i<=length(arg) then s:=copy(arg,i,1);
  dcb.buf^[i+dcb.phead^[nf].posf]:=S[1];
  end;
end; { Put_Dbf }

{----------------------------------------------------------}
procedure Put_Dbf_Long(var dcb: fbase_dcb; nf:word; arg:Longint);
var S:string[20]; {}
    i:word;
begin   i:=dcb.phead^[nf].width; {длина поля}
  str(arg:20,s);
  Put_Dbf(dcb,nf,copy(S,21-i,i));
end; { Put_Dbf_long }
{----------------------------------------------------------}
procedure Put_Dbf_Real(var dcb: fbase_dcb; nf:word; arg:Real);
var S:string[20]; {}
    i:word;
begin   i:=dcb.phead^[nf].width; {длина поля}
  str(arg:20:2,s);
  Put_Dbf(dcb,nf,copy(S,21-i,i));
end; { Put_Dbf_Real }

{----------------------------------------------------------}

begin

end.
