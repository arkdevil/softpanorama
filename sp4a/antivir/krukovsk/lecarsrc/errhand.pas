{************************************************}
{                                                }
{        L e c a r                               }
{   Turbo Pascal 6.X                             }
{   Попросту, без чинов и Copyright-ов  1992     }
{   Версия 2.0 от                                }
{************************************************}

{$A+,B-,D+,E-,F-,G-,I+,L+,N-,O-,R+,S+,V+,X+}
{$M 16384,0,655360}

Unit ErrHand;

Interface

Uses Objects, Common;

type
  TMonth =(January, February, March, April, May, June, Jyle, August, September, October, November, December);
  PBirth = ^TBirth;
  TBirth = record
    Name  : PString;
    Month : TMonth;
    Day   : Byte;
    Year  : Word;
  end;
  PSayProgram = ^TSayProgram;
  TSayProgram = record
    Ident : PString;
    Say   : PString;
  end;
  PBirthDay = ^TBirthDay;
  TBirthDay = object(TCollection)
    procedure FreeItem(Item : Pointer); Virtual;
    function GetItem(var S: TStream): Pointer; virtual;
    procedure PutItem(var S: TStream; Item: Pointer); virtual;
  end;
  PGoodProgram = ^TGoodProgram;
  TGoodProgram = object(TCollection)
    procedure FreeItem(Item : Pointer); Virtual;
    function GetItem(var S: TStream): Pointer; virtual;
    procedure PutItem(var S: TStream; Item: Pointer); virtual;
  end;
  PMsgCollection = ^TMsgCollection;
  TMsgCollection = object(TCollection)
    procedure FreeItem(Item : Pointer); Virtual;
    function GetItem(var S: TStream): Pointer; virtual;
    procedure PutItem(var S: TStream; Item: Pointer); virtual;
  end;

const
  BirthDays : PBirthDay = nil;
  GoodPrograms : PGoodProgram = nil;
  Message : PMsgCollection = nil;

  RBirthDay: TStreamRec = (
    ObjType: 1001;
    VmtLink: Ofs(TypeOf(TBirthDay)^);
    Load: @TBirthDay.Load;
    Store: @TBirthDay.Store);
  RGoodProgram: TStreamRec = (
    ObjType: 1002;
    VmtLink: Ofs(TypeOf(TGoodProgram)^);
    Load: @TGoodProgram.Load;
    Store: @TGoodProgram.Store);
  RMsgCollection: TStreamRec = (
    ObjType: 1003;
    VmtLink: Ofs(TypeOf(TMsgCollection)^);
    Load: @TMsgCollection.Load;
    Store: @TMsgCollection.Store);

var
  LastError : String;

function GetError : Byte;
function GetErrorName(Code : Byte) : String;
function NewBirth(AName: String; AMonth: TMonth; ADay: Byte; AYear: Word): Pointer;
function NewGoodProgram(AIdent, ASay: String): Pointer;
procedure RegisterMsgCollection;
procedure RegisterBirthDay;
procedure RegisterGoodProgram;

Implementation

Var
  SaveExit : Pointer;

function NewGoodProgram(AIdent, ASay: String): Pointer;
var
  AGood : PSayProgram;
begin
  New(AGood);
  if AGood <> nil then
    with AGood^ do
    begin
      Ident := NewStr(AIdent);
      Say := NewStr(ASay);
    end;
  NewGoodProgram := AGood;
end;

function NewBirth(AName: String; AMonth: TMonth; ADay: Byte; AYear: Word): Pointer;
var
  ABirth : PBirth;
begin
  New(ABirth);
  if ABirth <> nil then
    with ABirth^ do
    begin
      Name := NewStr(AName);
      Month := AMonth;
      Day := ADay;
      Year := AYear;
    end;
  NewBirth := ABirth;
end;

procedure TBirthDay.FreeItem(Item : Pointer);
begin
  DisposeStr(PBirth(Item)^.Name);
  Dispose(PBirth(Item));
end;

function TBirthDay.GetItem(var S: TStream): Pointer;
var
  ABirth : PBirth;
begin
  New(ABirth);
  if ABirth <> nil then
    with ABirth^ do
    begin
      Name := S.ReadStr;
      S.Read(Month, SizeOf(Month));
      S.Read(Day, SizeOf(Day));
      S.Read(Year, SizeOf(Year));
    end;
  if S.Status <> stOk then GetItem := nil else GetItem := ABirth;
end;

procedure TBirthDay.PutItem(var S: TStream; Item: Pointer);
var
  ABirth : PBirth;
begin
  ABirth := Item;
  with ABirth^ do
  begin
    S.WriteStr(Name);
    S.Write(Month, SizeOf(Month));
    S.Write(Day, SizeOf(Day));
    S.Write(Year, SizeOf(Year));
  end;
end;

procedure TGoodProgram.FreeItem(Item : Pointer);
begin
  DisposeStr(PSayProgram(Item)^.Ident);
  DisposeStr(PSayProgram(Item)^.Say);
  Dispose(PSayProgram(Item));
end;

function TGoodProgram.GetItem(var S: TStream): Pointer;
var
  ASay : PSayProgram;
begin
  New(ASay);
  if ASay <> nil then
    with ASay^ do
    begin
      Ident := S.ReadStr;
      Say := S.ReadStr;
    end;
  if S.Status <> stOk then GetItem := nil else GetItem := ASay;
end;

procedure TGoodProgram.PutItem(var S: TStream; Item: Pointer);
var
  ASay : PSayProgram;
begin
  ASay := Item;
  with ASay^ do
  begin
    S.WriteStr(Ident);
    S.WriteStr(Say);
  end;
end;

procedure TMsgCollection.FreeItem(Item : Pointer);
begin
  DisposeStr(Item);
end;

function TMsgCollection.GetItem(var S: TStream): Pointer;
begin
  GetItem := S.ReadStr;
end;

procedure TMsgCollection.PutItem(var S: TStream; Item: Pointer);
begin
  S.WriteStr(Item);
end;

procedure RegisterMsgCollection;
begin
  RegisterType(RMsgCollection);
end;

procedure RegisterBirthDay;
begin
  RegisterType(RBirthDay);
end;

procedure RegisterGoodProgram;
begin
  RegisterType(RGoodProgram);
end;

function GetError : Byte; Assembler;
asm
  Mov   AH,  59h
  Xor   BX,  BX
  Push  DS
  Push  BP
  Int   21h
  Pop   BP
  Pop   DS
end;

function GetErrorName(Code : Byte) : String;
var
  Msg : PString;
begin
  GetErrorName := 'Unknown';
  If Code < Message^.Count then Msg := Message^.At(Code) else Exit;
  If Msg = NIL then GetErrorName := '' else GetErrorName := Msg^;
end;

{$F+}
procedure Int24(Flags,CS,IP,AX,BX,CX,DX,SI,DI,DS,ES,BP : Word); interrupt;
begin
  AX := Hi(AX) Shl 8 + 3;      { Abort }
  LastError := GetErrorName(GetError);
end;

procedure ExitHandler;
begin
  ExitProc := SaveExit;
  SetVector($24, SaveInt24);
  If Seg(Message) <= Seg(HeapPtr) then Dispose(Message, Done);
  If BirthDays <> nil then Dispose(BirthDays, Done);
  Halt(0);
end;
{$F-}

Begin
  SaveExit := ExitProc;
  ExitProc := @ExitHandler;
  GetVector($24, SaveInt24);
  SetVector($24, Addr(Int24));
  LastError := '';
  RegisterMsgCollection;
  RegisterBirthDay;
  RegisterGoodProgram;
  Message := New(PMsgCollection, Init(50, 5));
  Message^.Insert(NewStr('None'));                         {00}
  Message^.Insert(NewStr('Invalid function number'));      {01}
  Message^.Insert(NewStr('File not found'));               {02}
  Message^.Insert(NewStr('Path not found'));               {03}
  Message^.Insert(NewStr('Too many open files'));          {04}
  Message^.Insert(NewStr('Access denied'));                {05}
  Message^.Insert(NewStr('Invalid handle'));               {06}
  Message^.Insert(NewStr('MCB destroyed'));                {07}
  Message^.Insert(NewStr('Insufficient memory'));          {08}
  Message^.Insert(NewStr('Invalid memory block addres'));  {09}
  Message^.Insert(NewStr('Invalid environment'));          {0A}
  Message^.Insert(NewStr('Invalid format'));               {0B}
  Message^.Insert(NewStr('Invalid accses code'));          {0C}
  Message^.Insert(NewStr('Invalid data'));                 {0D}
  Message^.Insert(NewStr(''));
  Message^.Insert(NewStr('Invalid drive specified'));
  Message^.Insert(NewStr('Can''t remove current dir'));
  Message^.Insert(NewStr('Not same device'));
  Message^.Insert(NewStr('No more matching file'));
  Message^.Insert(NewStr('Disk write protected'));
  Message^.Insert(NewStr('Unknown unit ID'));
  Message^.Insert(NewStr('Drive not ready'));
  Message^.Insert(NewStr('Unknown command'));
  Message^.Insert(NewStr('Data error (CRC error)'));
  Message^.Insert(NewStr('Bad request structure length'));
  Message^.Insert(NewStr('Seek error'));
  Message^.Insert(NewStr('Unknown media type'));
  Message^.Insert(NewStr('Sector not found'));
  Message^.Insert(NewStr('Printer out of paper'));
  Message^.Insert(NewStr('Write fault'));
  Message^.Insert(NewStr('Read fault'));
  Message^.Insert(NewStr('General failure'));
  Message^.Insert(NewStr('Sharing violation'));
  Message^.Insert(NewStr('Lock violation'));
  Message^.Insert(NewStr('Invalid disk change'));
  Message^.Insert(NewStr('Too many FCBs'));
  Message^.Insert(NewStr('Sharing buffer overflow'));
  Message^.Insert(NewStr(''));
  Message^.Insert(NewStr('Cannot complete file operation'));
  Message^.Insert(NewStr(''));
  Message^.Insert(NewStr(''));
  Message^.Insert(NewStr(''));
  Message^.Insert(NewStr(''));
  Message^.Insert(NewStr(''));
  Message^.Insert(NewStr(''));
  Message^.Insert(NewStr(''));
  Message^.Insert(NewStr(''));
  Message^.Insert(NewStr(''));
  Message^.Insert(NewStr(''));
  Message^.Insert(NewStr(''));
  Message^.Insert(NewStr('Network request not supported'));
  Message^.Insert(NewStr('Remote computer not listening'));
  Message^.Insert(NewStr('Duplicate name on network'));
  Message^.Insert(NewStr('Network name not found'));
  Message^.Insert(NewStr('Network busy'));
  Message^.Insert(NewStr('Network device no longer exists'));
  Message^.Insert(NewStr('Net BIOS command limit exceeded'));
  Message^.Insert(NewStr('Network adapter hardware error'));
  Message^.Insert(NewStr('Incorrect response from network'));
  Message^.Insert(NewStr('Unexpected network error'));
  Message^.Insert(NewStr('Incompatible remote adapter'));
  Message^.Insert(NewStr('Print gueue full'));
  Message^.Insert(NewStr('Queue not full'));
  Message^.Insert(NewStr('Not enough space for print file'));
  Message^.Insert(NewStr('Network name was deleted'));
  Message^.Insert(NewStr('Network access denided'));
  Message^.Insert(NewStr('Incorrect network device type'));
  Message^.Insert(NewStr('Network name not found'));
  Message^.Insert(NewStr('Network name limit exceeded'));
  Message^.Insert(NewStr('Net BIOS sessinon limit exceeded'));
  Message^.Insert(NewStr('Temporarily paused'));
  Message^.Insert(NewStr('Network request not accepted'));
  Message^.Insert(NewStr('Print or disk redirection is paused'));
  Message^.Insert(NewStr('LAN : Invalid network version'));
  Message^.Insert(NewStr('LAN : Account expied'));
  Message^.Insert(NewStr('LAN : Password expired'));
  Message^.Insert(NewStr('LAN : Login attempt invalid at this time'));
  Message^.Insert(NewStr('LAN : Disk limit exceeded on network node'));
  Message^.Insert(NewStr('LAN : Not logged in to network node'));
  Message^.Insert(NewStr(''));
  Message^.Insert(NewStr('File already exist'));
  Message^.Insert(NewStr(''));
  Message^.Insert(NewStr('Cannot make directory'));
  Message^.Insert(NewStr('Fail error from int 24h'));
  Message^.Insert(NewStr('Too many redirections'));
  Message^.Insert(NewStr('Duplicate redirection'));
  Message^.Insert(NewStr('Invalid password'));
  Message^.Insert(NewStr('Invalid parameter'));
  Message^.Insert(NewStr('Network data fault'));
  Message^.Insert(NewStr('LAN : Function not supported on network'));
  Message^.Insert(NewStr('LAN :  Required system component not installed'));    {5A}
  BirthDays := New(PBirthDay, Init(5, 1));
{
  BirthDays^.Insert(NewBirth('Круковский М.Ю.', January, 1, 1972));
  BirthDays^.Insert(NewBirth('Юрковский О.В.', March, 19, 1971));
  BirthDays^.Insert(NewBirth('', August, 25, 1971));
  BirthDays^.Insert(NewBirth('Булава Н.Н.', August, 26, 1971));
  BirthDays^.Insert(NewBirth('Завгородний И.Ю.', May, 28, 1971));
  BirthDays^.Insert(NewBirth('Оксютенко В.В.', December, 29, 1970));
  BirthDays^.Insert(NewBirth('', November, 8, 1970));
  BirthDays^.Insert(NewBirth('Грушевский Ф.Я.', March, 3, 1970));
  BirthDays^.Insert(NewBirth('Миненко C.М.', May, 21, 1969));
}
  GoodPrograms := New(PGoodProgram, Init(10, 1));
{
  GoodPrograms^.Insert(NewGoodProgram('NC.EXE',' - не плох, определенно не плох !'));
  GoodPrograms^.Insert(NewGoodProgram('LECAR.EXE', ' - ой, знакомые все лица !'));
  GoodPrograms^.Insert(NewGoodProgram('TURBO.EXE', ' - Здравствуй, папа !!!'));
  GoodPrograms^.Insert(NewGoodProgram('DIGGER.COM', ' - хороша цацка, а?'));
  GoodPrograms^.Insert(NewGoodProgram('WC.EXE', ' - а вторая секретная миссия есть?'));
  GoodPrograms^.Insert(NewGoodProgram('WC2.EXE', ' - и ты к Angel пристаешь ?'));
  GoodPrograms^.Insert(NewGoodProgram('RACONFIG.EXE', ' - какой версии ремота?'));
  GoodPrograms^.Insert(NewGoodProgram('FDSETUP.EXE', ' - интересно, какая станция'));
  GoodPrograms^.Insert(NewGoodProgram('ADM.EXE', ' - не держите меня, я его убью !!!'));
  GoodPrograms^.Insert(NewGoodProgram('DM.EXE', ' - не держите меня, я его убью !!!'));
  GoodPrograms^.Insert(NewGoodProgram('LEX.EXE', ' - плавали, знаем'));
  GoodPrograms^.Insert(NewGoodProgram('NDD.EXE', ' - Norton Disk Destroyer'));
  GoodPrograms^.Insert(NewGoodProgram('NAV.EXE', ' - ну и гадость эта ваша заливная рыба'));
  GoodPrograms^.Insert(NewGoodProgram('AIDSTEST.EXE', ' - здравствуйте, коллега'));
  GoodPrograms^.Insert(NewGoodProgram('LZEXE.EXE', ' - разворочууу....'));
  GoodPrograms^.Insert(NewGoodProgram('ARJ.EXE', ' - хорош'));
  GoodPrograms^.Insert(NewGoodProgram('LHA.EXE', ' - ошибки есть ... '));
  GoodPrograms^.Insert(NewGoodProgram('CLIPPER.EXE', ' - восстановление за дополнительную плату'));
  GoodPrograms^.Insert(NewGoodProgram('TD.EXE', ' - батюшки, братки !'));
  GoodPrograms^.Insert(NewGoodProgram('TC.EXE', ' - вай-вай, каво я вижу'));
  GoodPrograms^.Insert(NewGoodProgram('ACAD.EXE', ' - слов нет...'));
  GoodPrograms^.Insert(NewGoodProgram('AGENTC.EXE', ' - узнаю, узнаю'));
  GoodPrograms^.Insert(NewGoodProgram('WIN.COM', ' - еще раз увижу ...'));
  GoodPrograms^.Insert(NewGoodProgram('MOSG.EXE', ' - у вас что-то с мозгом не в порядке'));
  GoodPrograms^.Insert(NewGoodProgram('TPW.EXE', ' - ну в натуре я торчу от Borland, а ты ?'));
  GoodPrograms^.Insert(NewGoodProgram('TC.EXE', ' - ну в натуре я торчу от Borland, а ты ?'));
  GoodPrograms^.Insert(NewGoodProgram('BC.EXE', ' - ну в натуре я торчу от Borland, а ты ?'));
}
End.
