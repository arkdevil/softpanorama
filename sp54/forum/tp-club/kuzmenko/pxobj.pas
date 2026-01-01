{********************************************************************}
{*                                                                  *}
{*                    Dimarker's Software 1992                      *}
{*                                                                  *}
{*            Paradox Engine 2.0 Object-Oriented Module             *}
{*                   for use with Turbo Vision                      *}
{*                                                                  *}
{********************************************************************}

{$F+,N+,E+,O+,X+}

unit PXObj;

interface

uses Objects, PXEngine, Drivers;

type

 PPX = ^TPX;
 TPX = object(TObject)
  TblHandle: TableHandle;
  RecHandle: RecordHandle;
  Ok       : boolean;
  Error    : integer;
  CurrKey  : word;
  Buffer   : PByteArray;
  BShift   : PWordArray;
  RecSize  : word;
  constructor Init;
  procedure   DateDecode(Date: longint; var Da, Mo, Yr: integer);
  function    DateEncode(Da, Mo, Yr: integer): longint;
  function    ErrMsg: string;
  function    RErrMsg: string;
{ field handles }
  function    FldBlank(FieldNo: integer): boolean;
  function    FldHandle(FieldName: string): integer;
  function    FldName(FieldNo: integer): NameString;
  function    FLdType(FieldNo: integer): NameString;
  function    FldWidth(FieldNo: integer): integer;
  function    FldLen(FieldNo: integer): integer;
  function    FldStr(FieldNo: integer): string;
{ move data from record buffer }
  function    GetAlpha(FieldNo: integer): string;
  function    GetDate(FieldNo: integer): longint;
  function    GetDoub(FieldNo: integer): double;
  function    GetLong(FieldNo: integer): longint;
  function    GetShort(FieldNo: integer): integer;
  function    GetCurrKey: word;
  procedure   GetBuffer(var Buf);
{ index maintaining }
  procedure   KeyAdd(TName: string; Flds: string; Mode: integer);
  procedure   KeyAddC(TName: string; Flds: string; Mode: integer);
  procedure   KeyDrop(TName: string; IndexId: integer);
  function    KeyNFlds: integer;
{ network operations }
  function    NetErrUser: string;
  procedure   NetFileLock(TName: string; LockType: integer);
  procedure   NetFileUnlock(TName: string; LockType: integer);
  procedure   NetRecGotoLock(LckHandle: LockHandle);
  function    NetRecLock: LockHandle;
  function    NetRecLocked: boolean;
  procedure   NetRecUnLock(LckHandle: LockHandle);
  function    NetTblChanged: boolean;
  procedure   NetTblLock(LockType: integer);
  procedure   NetTblRefresh;
  procedure   NetTblUnlock(LockType: integer);
  function    NetUserName: string;
{ security procedures }
  procedure   PswAdd(S: string);
  procedure   PswDel(S: string);
{ move data to record buffer }
  procedure   PutAlpha(FldNo: integer; Value: string);
  procedure   PutBlank(FldNo: integer);
  procedure   PutDate(FldNo: integer; Value: longint);
  procedure   PutDoub(FldNo: integer; Value: double);
  procedure   PutLong(FldNo: integer; Value: longint);
  procedure   PutShort(FldNo: integer; Value: integer);
  procedure   PX;
{ record and buffer management }
  procedure   RecAppend;
  procedure   RecBufClose;
  procedure   RecBufCopy(ToTable: TPX);
  procedure   RecBufEmpty;
  procedure   RecBufGet;
  procedure   RecBufOpen;
  procedure   RecDelete;
  procedure   RecFirst;
  procedure   RecGet;
  procedure   RecGoto(RecNo: longint);
  procedure   RecInsert;
  procedure   RecLast;
  procedure   RecNext;
  function    RecNFlds: integer;
  function    RecNum: longint;
  procedure   RecPrev;
  procedure   RecUpdate;
{ flushing }
  procedure   Save;
{ field search }
  procedure   SrchFld(FldNo, Mode: integer);
  procedure   FirstFld(FldNo: integer);
  procedure   NextFld(FldNo: integer);
  procedure   ClosestFld(FldNo: integer);
{ key search   }
  procedure   SrchKey(NFlds, Mode: integer);
  procedure   FirstKey(NFlds: integer);
  procedure   NextKey(NFlds: integer);
  procedure   ClosestKey(NFlds: integer);
{ table manipulations }
  procedure   TblAdd(SrcName, DestName: string);
  procedure   TblBufClose;
  procedure   TblBufOpen(TName: string; IndexId: integer;
                         SaveEveryChange: boolean);
  procedure   TblClose;
  procedure   TblCopy(FromName, ToName: string);
  procedure   TblCreate(TName: string; NFields: integer;
                        Fields, Types: NamesArrayPtr);
  procedure   TblDecrypt(TName: string);
  procedure   TblDelete(TName: string);
  procedure   TblEmpty(TName: string);
  procedure   TblEncrypt(TName, Password: string);
  function    TblExist(TName: string): boolean;
  procedure   TblMaxSize(MaxTblSize: integer);
  function    TblName: string;
  function    TblNRecs: longint;
  procedure   TblOpen(TName: string; IndexId: integer;
                      SaveEveryChange: boolean);
  function    TblProtected(TName: string): boolean;
  procedure   TblRename(FromName, ToName: string);
 end;

{ function PXBufInit: integer;}

implementation


type
 PLongint = ^longint;
 PWord    = ^word;
 PDouble  = ^double;
 PInteger = ^integer;

 constructor TPX.Init;
  begin
   TObject.Init;
  end;

 procedure TPX.DateDecode(Date: longint; var Da, Mo, Yr: integer);
  begin
   Error:=PXDateDecode(Date, Mo, Da, Yr);
   Ok:=Error = 0;
  end;

 function TPX.DateEncode(Da, Mo, Yr: integer): longint;
  var L: longint;
  begin
   Error:=PXDateEncode(Mo, Da, Yr, TDate(L));
   Ok:=Error = 0;
   DateEncode:=L;
  end;

 function TPX.ErrMsg: string;
  begin
   ErrMsg:=PXErrMsg(Error);
  end;

 function TPX.FldBlank(FieldNo: integer): boolean;
  var B: boolean;
  begin
   Error:=PXFldBlank(RecHandle, FieldNo, B);
   Ok:=Error = 0;
   FldBlank:=B;
  end;

 function TPX.FldHandle(FieldName: string): integer;
  var i: FieldHandle;
  begin
   Error:=PXFldHandle(TblHandle, FieldName, i);
   Ok:=Error = 0;
   FldHandle:=i;
  end;

 function TPX.FldName(FieldNo: integer): NameString;
  var s: NameString;
  begin
   Error:=PXFldName(TblHandle, FieldNo, s);
   Ok:=Error = 0;
   FldName:=s;
  end;

 function TPX.FldType(FieldNo: integer): NameString;
  var s: NameString;
  begin
   Error:=PXFldType(TblHandle, FieldNo, s);
   Ok:=Error = 0;
   FldType:=s;
  end;

 function TPX.FldWidth(FieldNo: integer): integer;
  var
   i, c: integer;
   s: NameString;
  begin
   PXFldType(TblHandle, FieldNo, s);
   if Ok then
    case s[1] of
     'N','$' : i:=12;
     'D'     : i:=10;
     'S'     : i:=6;
     'A'     : begin
                s[1]:=#32;
                Val(s, i, c);
               end;
    end
   else
    i:=0;
   FldWidth:=i;
  end;

 function TPX.FldLen(FieldNo: integer): integer;
  var
   i, c: integer;
   s: NameString;
  begin
   PXFldType(TblHandle, FieldNo, s);
   if Ok then
    case s[1] of
     'N','$' : i:=8;
     'D'     : i:=4;
     'S'     : i:=2;
     'A'     : begin
                s[1]:=#32;
                Val(s, i, c);
               end;
    end
   else
    i:=0;
   FldLen:=i;
  end;

 function TPX.FldStr(FieldNo: integer): string;
  var
   s: NameString;
   r: string;
   N: double;
   I: integer;
   L: longint;
   DList: array [0..5] of integer;
  begin
   FillChar(r, SizeOf(r), ' ');
   r[0]:=#0;
   PXFldType(TblHandle, FieldNo, s);
   case s[1] of
    'A' : begin
           PxGetAlpha(RecHandle, FieldNo, r);
           s[1]:=#32;
           Val(s, byte(r[0]), i);
          end;
    'N' : begin
           if not FldBlank(FieldNo) then
            PXGetDoub(RecHandle, FieldNo, N)
           else N:=0;
           Str(N:12:2, r);
          end;
    '$' : begin
           if not FldBlank(FieldNo) then
            PXGetDoub(RecHandle, FieldNo, N)
           else N:=0;
           Str(N:12:2, r);
          end;
    'S' : begin
           if not FldBlank(FieldNo) then
            PXGetShort(RecHandle, FieldNo, I)
           else I:=0;
           Str(I:6, r);
          end;
    'D' :  begin
            if not FldBlank(FieldNo) then
             begin
              PXGetDate(RecHandle, FieldNo, L);
              FillChar(DList, SizeOf(DList), 0);
              DateDecode(L, DList[0], DList[2], DList[4]);
              Dec(DList[4]);
              FormatStr(r, '%02d/%02d/%4d', DList);
             end
            else begin L:=0; Str(L:10, r); r[11]:=' '; end;
          end;
   end;
   FldStr:=r;
  end;

 function TPX.GetAlpha(FieldNo: integer): string;
  var s: string;
  begin
   Error:=PXGetAlpha(RecHandle, FieldNo, s);
   Ok:=Error = 0;
   GetAlpha:=s;
  end;

 function TPX.GetDate(FieldNo: integer): longint;
  var d: TDate;
  begin
   Error:=PXGetDate(RecHandle, FieldNo, d);
   Ok:=Error = 0;
   GetDate:=longint(d);
  end;

 function TPX.GetDoub(FieldNo: integer): double;
  var d: double;
  begin
   Error:=PXGetDoub(RecHandle, FieldNo, d);
   Ok:=Error = 0;
   GetDoub:=d;
  end;

 function TPX.GetLong(FieldNo: integer): longint;
  var d: longint;
  begin
   Error:=PXGetLong(RecHandle, FieldNo, d);
   Ok:=Error = 0;
   GetLong:=d;
  end;

 function TPX.GetShort(FieldNo: integer): integer;
  var d: integer;
  begin
   Error:=PXGetShort(RecHandle, FieldNo, d);
   Ok:=Error = 0;
   GetShort:=d;
  end;

 function  TPX.GetCurrKey: word;
  begin
   GetCurrKey:=CurrKey;
  end;

 procedure TPX.GetBuffer(var Buf);
  begin
   RecBufGet;
   Move(Buffer^, Buf, RecSize);
  end;

 procedure TPX.KeyAdd(TName: string; Flds: string; Mode: integer);
  var
   F: FieldHandleArray;
   i: integer;
  begin
   for i:=1 to Length(Flds) do
    F[i]:=byte(Flds[i]) - 48;
   i:=byte(Flds[0]);
   Error:=PXKeyAdd(TName, i, F, Mode);
   Ok:=Error = 0;
  end;

 procedure TPX.KeyAddC(TName: string; Flds: string; Mode: integer);
  var
   F: FieldHandleArray;
   i: integer;
  begin
   for i:=1 to Length(Flds) do
    F[i]:=byte(Flds[i]);
   i:=byte(Flds[0]);
   Error:=PXKeyAdd(TName, i, F, Mode);
   Ok:=Error = 0;
  end;

 procedure TPX.KeyDrop(TName: string; IndexId: integer);
  begin
   Error:=PXKeyDrop(TName, IndexId);
   Ok:=Error = 0;
  end;

 function TPX.KeyNFlds: integer;
  var i: integer;
  begin
   Error:=PXKeyNFlds(TblHandle, i);
   Ok:=Error = 0;
   KeyNFlds:=i;
  end;

 function TPX.NetErrUser: string;
  var s: string;
  begin
   Error:=PXNetErrUser(s);
   Ok:=Error = 0;
   NetErrUser:=s;
  end;

 procedure TPX.NetFileLock(TName: string; LockType: integer);
  begin
   Error:=PXNetFileLock(TName, LockType);
   Ok:=Error = 0;
  end;

 procedure TPX.NetFileUnlock(TName: string; LockType: integer);
  begin
   Error:=PXNetFileUnlock(TName, LockType);
   Ok:=Error = 0;
  end;

 procedure TPX.NetRecGotoLock(LckHandle: LockHandle);
  begin
   Error:=PXNetRecGotoLock(TblHandle, LckHandle);
   Ok:=Error = 0;
  end;

 function  TPX.NetRecLock: LockHandle;
  var L: LockHandle;
  begin
   Error:=PXNetRecLock(TblHandle, L);
   Ok:=Error = 0;
   NetRecLock:=L;
  end;

 function  TPX.NetRecLocked: boolean;
  var B: boolean;
  begin
   Error:=PXNetRecLocked(TblHandle, B);
   Ok:=Error = 0;
   NetRecLocked:=B;
  end;

 procedure TPX.NetRecUnLock(LckHandle: LockHandle);
  begin
   Error:=PXNetRecUnLock(TblHandle, LckHandle);
   Ok:=Error = 0;
  end;

 function TPX.NetTblChanged: boolean;
  var B: boolean;
  begin
   Error:=PXNetTblChanged(TblHandle, B);
   Ok:=Error = 0;
   NetTblChanged:=B;
  end;

 procedure TPX.NetTblLock(LockType: integer);
  begin
   Error:=PXNetTblLock(TblHandle, LockType);
   Ok:=Error = 0;
  end;

 procedure TPX.NetTblRefresh;
  begin
   Error:=PXNetTblRefresh(TblHandle);
   Ok:=Error = 0;
  end;

 procedure TPX.NetTblUnlock(LockType: integer);
  begin
   Error:=PXNetTblUnlock(TblHandle, LockType);
   Ok:=Error = 0;
  end;

 function TPX.NetUserName: string;
  var s: string;
  begin
   Error:=PXNetUserName(s);
   Ok:=Error = 0;
   NetUserName:=s;
  end;

 procedure TPX.PswAdd(S: string);
  begin
   Error:=PXPswAdd(S);
   Ok:=Error = 0;
  end;

 procedure TPX.PswDel(S: string);
  begin
   Error:=PXPswDel(S);
   Ok:=Error = 0;
  end;

 procedure TPX.PutAlpha(FldNo: integer; Value: string);
  begin
   Error:=PXPutAlpha(RecHandle, FldNo, Value);
   Ok:=Error = 0;
  end;

 procedure TPX.PutBlank(FldNo: integer);
  begin
   Error:=PXPutBlank(RecHandle, FldNo);
   Ok:=Error = 0;
  end;

 procedure TPX.PutDate(FldNo: integer; Value: longint);
  begin
   Error:=PXPutDate(RecHandle, FldNo, longint(Value));
   Ok:=Error = 0;
  end;

 procedure TPX.PutDoub(FldNo: integer; Value: double);
  begin
   Error:=PXPutDoub(RecHandle, FldNo, Value);
   Ok:=Error = 0;
  end;

 procedure TPX.PX;
  begin
   if Error <> 0 then
    Writeln(ErrMsg);
  end;

 procedure TPX.PutLong(FldNo: integer; Value: longint);
  begin
   Error:=PXPutLong(RecHandle, FldNo, Value);
   Ok:=Error = 0;
  end;

 procedure TPX.PutShort(FldNo: integer; Value: integer);
  begin
   Error:=PXPutShort(RecHandle, FldNo, Value);
   Ok:=Error = 0;
  end;

 procedure TPX.RecAppend;
  begin
   Error:=PXRecAppend(TblHandle, RecHandle);
   Ok:=Error = 0;
  end;

 procedure TPX.RecBufClose;
  begin
   if BShift <> nil then FreeMem(BShift, (RecNFlds + 1) * SizeOf(word));
   if Buffer <> nil then FreeMem(Buffer, RecSize);
   BShift:=Nil;
   Buffer:=Nil;
   RecSize:=0;
   Error:=PXRecBufClose(RecHandle);
   Ok:=Error = 0;
  end;

 procedure TPX.RecBufCopy(ToTable: TPX);
  begin
   Error:=PXRecBufCopy(RecHandle, ToTable.RecHandle);
   Ok:=Error = 0;
  end;

 procedure TPX.RecBufEmpty;
  begin
   Error:=PXRecBufEmpty(RecHandle);
   Ok:=Error = 0;
  end;

 procedure TPX.RecBufGet;
  var
   i,f : integer;
   s   : string[4];
   w   : word;
  begin
   if Ok then
    begin
     w:=0;
     for i:=1 to RecNFlds do
      begin
       s:=FldType(i);
       f:=FldLen(i);
       case s[1] of
        'A'     : PString( @Buffer^[w])^:=GetAlpha(i);
        'D'     : PLongint(@Buffer^[w])^:=GetDate( i);
        'N','$' : PDouble( @Buffer^[w])^:=GetDoub( i);
        'S'     : PWord(   @Buffer^[w])^:=GetShort(i);
       end;
       Inc(w, f);
      end;
    end;
  end;

 procedure TPX.RecBufOpen;
  var
   i,j,k,w: integer;
   S      : NameString;
  begin
   Error:=PXRecBufOpen(TblHandle, RecHandle);
   Ok:=Error = 0;
   if Ok then
    begin
     j:=RecNFlds;                                { number of records }
     GetMem(BShift, SizeOf(word) * (j + 1));     { shift from buffer[0] }
     RecSize:=0;                                 { start of value }
     for i:=1 to j do
      begin
       PXFldType(TblHandle, i, S);               { get type of field }
       BShift^[i]:=RecSize;                      { begining of value }
       case S[1] of
        'D'     : Inc(RecSize, 4);               { longint }
        'N','$' : Inc(RecSize, 8);               { double }
        'S'     : Inc(RecSize, 2);               { short (word) }
        'A'     : begin                          { string }
                   S[1]:=' ';
                   Val(S, w, k);
                   Inc(RecSize, w + 1);
                  end;
       end;
      end;
     GetMem(Buffer, RecSize);
    end;
  end;

 procedure TPX.RecDelete;
  begin
   Error:=PXRecDelete(TblHandle);
   Ok:=Error = 0;
  end;

 procedure TPX.RecFirst;
  begin
   Error:=PXRecFirst(TblHandle);
   Ok:=Error = 0;
  end;

 procedure TPX.RecGet;
  begin
   Error:=PXRecGet(TblHandle, RecHandle);
   Ok:=Error = 0;
  end;

 procedure TPX.RecGoto(RecNo: longint);
  begin
   Error:=PXRecGoto(TblHandle, RecNo);
   Ok:=Error = 0;
  end;

 procedure TPX.RecInsert;
  begin
   Error:=PXRecInsert(TblHandle, RecHandle);
   Ok:=Error = 0;
  end;

 procedure TPX.RecLast;
  begin
   Error:=PXRecLast(TblHandle);
   Ok:=Error = 0;
  end;

 procedure TPX.RecNext;
  begin
   Error:=PXRecNext(TblHandle);
   Ok:=Error = 0;
  end;

 function TPX.RecNFlds: integer;
  var i: integer;
  begin
   Error:=PXRecNFlds(TblHandle, i);
   Ok:=Error = 0;
   RecNFlds:=i;
  end;

 function TPX.RecNum: longint;
  var L: longint;
  begin
   Error:=PXRecNum(TblHandle, L);
   Ok:=Error = 0;
   RecNum:=L;
  end;

 procedure TPX.RecPrev;
  begin
   Error:=PXRecPrev(TblHandle);
   Ok:=Error = 0;
  end;

 procedure TPX.RecUpdate;
  begin
   Error:=PXRecUpdate(TblHandle, RecHandle);
   Ok:=Error = 0;
  end;

 procedure TPX.Save;
  begin
   Error:=PXSave;
   Ok:=Error = 0;
  end;

 procedure TPX.SrchFld(FldNo, Mode: integer);
  var P: pointer;
  begin
   Error:=PXSrchFld(TblHandle, RecHandle, FldNo, Mode);
   Ok:=Error = 0;
  end;

 procedure TPX.FirstFld(FldNo: integer);
  begin
   Error:=PXSrchFld(TblHandle, RecHandle, FldNo, SearchFirst);
   Ok:=Error = 0;
  end;

 procedure TPX.NextFld(FldNo: integer);
  begin
   Error:=PXSrchFld(TblHandle, RecHandle, FldNo, SearchNext);
   Ok:=Error = 0;
  end;

 procedure TPX.ClosestFld(FldNo: integer);
  begin
   Error:=PXSrchFld(TblHandle, RecHandle, FldNo, ClosestRecord);
   Ok:=Error = 0;
  end;

 procedure TPX.SrchKey(NFlds, Mode: integer);
  begin
   Error:=PXSrchKey(TblHandle, RecHandle, NFlds, Mode);
   Ok:=Error = 0;
  end;

 procedure TPX.FirstKey(NFlds: integer);
  begin
   Error:=PXSrchKey(TblHandle, RecHandle, NFlds, SearchFirst);
   Ok:=Error = 0;
  end;

 procedure TPX.NextKey(NFlds: integer);
  begin
   Error:=PXSrchKey(TblHandle, RecHandle, NFlds, SearchNext);
   Ok:=Error = 0;
  end;

 procedure TPX.ClosestKey(NFlds: integer);
  begin
   Error:=PXSrchKey(TblHandle, RecHandle, NFlds, ClosestRecord);
   Ok:=Error = 0;
  end;

 procedure TPX.TblAdd(SrcName, DestName: string);
  begin
   Error:=PXTblAdd(SrcName, DestName);
   Ok:=Error = 0;
  end;

 procedure TPX.TblBufClose;
  begin
   RecBufClose;
   TblClose;
  end;

 procedure TPX.TblBufOpen(TName: string; IndexId: integer;
                          SaveEveryChange: boolean);
  begin
   TblOpen(TName, IndexId, SaveEveryChange);
   if Ok then
    begin
     RecBufOpen;
    end;
  end;

 procedure TPX.TblClose;
  begin
   Error:=PXTblClose(TblHandle);
   Ok:=Error = 0;
   CurrKey:=0;
  end;

 procedure TPX.TblCopy(FromName, ToName: string);
  begin
   Error:=PXTblCopy(FromName, ToName);
   Ok:=Error = 0;
  end;

 procedure TPX.TblCreate(TName: string; NFields: integer;
                         Fields, Types: NamesArrayPtr);
  begin
   Error:=PXTblCreate(TName, NFields, Fields, Types);
   Ok:=Error = 0;
  end;

 procedure TPX.TblDecrypt(TName: string);
  begin
   Error:=PXTblDecrypt(TName);
   Ok:=Error = 0;
  end;

 procedure TPX.TblDelete(TName: string);
  begin
   Error:=PXTblDelete(TName);
   Ok:=Error = 0;
  end;

 procedure TPX.TblEmpty(TName: string);
  begin
   Error:=PXTblEmpty(TName);
   Ok:=Error = 0;
  end;

 procedure TPX.TblEncrypt(TName, Password: string);
  begin
   Error:=PXTblEncrypt(TName, Password);
   Ok:=Error = 0;
  end;

 function TPX.TblExist(TName: string): boolean;
  var B: boolean;
  begin
   Error:=PXTblExist(TName, B);
   Ok:=Error = 0;
   TblExist:=B;
  end;

 procedure TPX.TblMaxSize(MaxTblSize: integer);
  begin
   Error:=PXTblMaxSize(MaxTblSize);
   Ok:=Error = 0;
  end;

 function TPX.TblName: string;
  var S: string;
  begin
   Error:=PXTblName(TblHandle, S);
   Ok:=Error = 0;
   TblName:=S;
  end;

 function TPX.TblNRecs: longint;
  var L: longint;
  begin
   Error:=PXTblNRecs(TblHandle, L);
   Ok:=Error = 0;
   TblNRecs:=L;
  end;

 procedure TPX.TblOpen(TName: string; IndexId: integer;
                       SaveEveryChange: boolean);
  begin
   Error:=PXTblOpen(TName, TblHandle, IndexId, SaveEveryChange);
   Ok:=Error = 0;
   if Ok then
    CurrKey:=IndexId;
  end;

 function TPX.TblProtected(TName: string): boolean;
  var B: boolean;
  begin
   Error:=PXTblProtected(TName, B);
   Ok:=Error = 0;
   TblProtected:=B;
  end;

 procedure TPX.TblRename(FromName, ToName: string);
  begin
   Error:=PXTblRename(FromName, ToName);
   Ok:=Error = 0;
  end;

 function TPX.RErrMsg: string;
  var s: string;
  begin
   case Error of
      0 : s:='Ошибок нет';
      1 : s:='Устройство не готово';
      2 : s:='Каталог не найден';
      3 : s:='Файл занят';
      4 : s:='Файл блокирован';
      5 : s:='Файл не найден';
      6 : s:='Таблица испорчена';
      7 : s:='Индекс испорчен';
      8 : s:='Индекс устарел';
      9 : s:='Запись блокирована';
     10 : s:='Каталог занят';
     11 : s:='Каталог блокирован';
     12 : s:='Нет доступа к каталогу';
     13 : s:='Неверный порядок сортировки';
     14 : s:='Разделяемый каталог';
     15 : s:='Несколько файлов PARADOX.NET';
     21 : s:='Доступ без пароля';
     22 : s:='Таблица защищена от записи';
     30 : s:='Неверный тип данных';
     33 : s:='Неверный аргумент';
     40 : s:='Не хватает памяти для выполнения операции';
     41 : s:='Нет дисковой памяти для выполнения операции';
     50 : s:='Другой пользователь удалил запись';
     70 : s:='Предел количества открытых файлов';
     72 : s:='Предел количества открытых таблиц';
     73 : s:='Неверная дата';
     74 : s:='Неверное имя поля';
     75 : s:='Неверный номер поля';
     76 : s:='Неверный номер таблицы';
     78 : s:='PXEngine не инициализирован';
     79 : s:='Предыдущая фатальная ошибка - не могу продолжать';
     81 : s:='Структуры таблиц различны';
     82 : s:='PXEngine уже инициализирован';
     83 : s:='Операция не доступна на открытой таблице';
     86 : s:='Предел количества временных имен';
     89 : s:='Запись не найдена';
     94 : s:='Таблица проиндексирована';
     95 : s:='Таблица не индексирована';
     96 : s:='Вторичный индекс устарел';
     97 : s:='Совпадение ключей';
     98 : s:='Не могу использовать сеть';
     99 : s:='Неверное имя таблицы';
    101 : s:='Конец таблицы';
    102 : s:='Начало таблицы';
    103 : s:='Предел количества буферов записей';
    104 : s:='Неверный номер буфера записи';
    105 : s:='Операция на пустой таблице';
    106 : s:='Неверный код блокировки';
    107 : s:='PXEngine не инициализирован для работы в сети';
    108 : s:='Неверное имя файла';
    109 : s:='Неверная разблокировка';
    110 : s:='Неверный номер блокировки';
    111 : s:='Слишком много блокировок для таблицы';
    112 : s:='Неверная сортировка таблицы';
    113 : s:='Неверный тип сети';
    114 : s:='Неверное имя каталога';
    115 : s:='Слишком много паролей';
    116 : s:='Неверный пароль';
    118 : s:='Таблица занята';
    119 : s:='Таблица заблокирована';
    120 : s:='Таблица не найдена';
    121 : s:='Вторичный индекс не найден';
    122 : s:='Вторичный индекс испорчен';
    123 : s:='Вторичный индекс уже открыт';
    124 : s:='Диск защищен от записи';
    125 : s:='Запись слишком велика для индекса';
    126 : s:='Ошибка оборудования';
    127 : s:='Переполнение стека - отмена операции';
    128 : s:='Таблица заполнена';
    129 : s:='Не хватает места для буфера выгрузки - отмена операции';
    130 : s:='Table is SQL replica';
    136 : s:='Невозможно обновить вторичный индекс';
   else s:='' end;
   RErrMsg:=s;
  end;
end.
