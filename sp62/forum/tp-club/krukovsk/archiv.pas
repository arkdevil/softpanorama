{**************************************************}
{                                                  }
{        L e c a r                                 }
{   Turbo Pascal 6.X,7.X                           }
{   Попросту, без чинов и Copyright-ов  1991,92,93 }
{   Версия 2.0 от .......(нужное дописать)         }
{**************************************************}

{$A+,B-,D+,E-,F-,G-,I+,L+,N-,O-,R-,S+,V+,X-}
{$M 16384,0,655360}

Unit Archiv;

Interface

Uses Dos, Common, Memory, Objects;

type
  PArc = ^TArc;
  TArc = object
    Mask    : Array [0..5] of Byte;
    FOffs   : Array [0..5] of Integer;
    Note,
    Name,
    ECmdLine,
    MCmdLine : PString;
    constructor Init(SourceStr: String);
    destructor Done;
    function TestFile(FileName: String): Boolean; virtual;
    function Extract(ArcFile, PathExtract: String): Boolean;
    function MoveFile(ArcFile, FileName: String): Boolean;
  end;
  PArchiver = ^TArchiver;
  TArchiver = object(TCollection)
    procedure FreeItem(Item : Pointer); Virtual;
    function GetItem(var S: TStream): Pointer; virtual;
    procedure PutItem(var S: TStream; Item: Pointer); virtual;
  end;

const
  Archivers : PArchiver = nil;

  RArchiver: TStreamRec = (
    ObjType: 1000;
    VmtLink: Ofs(TypeOf(TArchiver)^);
    Load: @TArchiver.Load;
    Store: @TArchiver.Store);

procedure RegisterArchiver;

Implementation

var
  SaveExit : Pointer;

constructor TArc.Init(SourceStr: String);
var
  I, J, Code : Integer;
  Tmp, S     : String;
  M,N        : Byte;
const
  WordChars = ['A'..'Z','a'..'z','0'..'9','.','+','-','_','%','/','*'];

function GetWord(var Line: String; var I: Integer): String;
var
  J: Integer;
begin
  While ((I <= Length(Line)) and (Line[I] = ' ') or (Line[I] = #8)) do Inc(I);
  J := I;
  if J > Length(Line) then GetWord := ''
  else
  begin
    Inc(I);
    if (Line[J] in WordChars) then
     while (I <= Length(Line)) and ((Line[I] in WordChars) or (Line[I+1]<> ' ' )) do
       Inc(I);
    GetWord := Copy(Line, J, I - J);
  end;
end;

function MyWord(var Line: String; var I: Integer): String;
var
  J: Integer;
begin
  While (I <= Length(Line)) and (Line[I] = ' ') or (Line[I] = #9) do Inc(I);
  J := I;
  if J > Length(Line) then MyWord := ''
  else
  begin
    Inc(I);
    if Line[J] in WordChars then
     while (I <= Length(Line)) and (Line[I] in WordChars) do Inc(I);
    MyWord := Copy(Line, J, I - J);
  end;
end;

begin
  I :=1;
  Tmp := GetWord(SourceStr,I); {Name}
  Name:= NewStr(Tmp);
  Tmp := GetWord(SourceStr,I); {Extract}
  ECmdLine:= NewStr(Tmp);
  Tmp := GetWord(SourceStr,I); {Extract}
  Note:= NewStr(Tmp);
  Tmp := GetWord(SourceStr,I); {Move}
  MCmdLine:= NewStr(Tmp);
  Tmp := GetWord(SourceStr,I); {Offset,Mark}
  J:= 1;
  for I:= 0 to 5 do
  begin
    S := MyWord(Tmp, J);
    N:= 0;
    if S[3] > '9' then Inc(N, (Byte(S[3]) - $41+10) shl 4) else Inc(N, (Byte(S[3]) - $30) shl 4);
    if S[4] > '9' then Inc(N, Byte(S[4]) - $41+10) else Inc(N, Byte(S[4]) - $30);
    M:= 0;
    if S[1] > '9' then Inc(M, (Byte(S[1]) - $41+10) shl 4) else Inc(M, (Byte(S[1]) - $30) shl 4);
    if S[2] > '9' then Inc(M, Byte(S[2]) - $41+10) else Inc(M, Byte(S[2]) - $30);
    Mask[I]:= M;
    FOffs[I]:= N;
  end;
end;

destructor TArc.Done;
begin
  DisposeStr(Note);
  DisposeStr(Name);
  DisposeStr(ECmdLine);
  DisposeStr(MCmdLine);
end;

function TArc.TestFile(FileName: String): Boolean;
var
  J       : Byte;
  Present : Boolean;
begin
  J := 0;
  Present := True;
  Repeat
    If Buff[FOffs[J]] <> Mask[J] then Present := False;
    Inc(J);
  Until (J > 5) OR (NOT Present);
  If Present then { найден архив }
    TestFile := True
  else TestFile := False;
end;

function TArc.Extract(ArcFile, PathExtract: String): Boolean;
var
  S : String;
begin
  SetMemTop(HeapPtr);
  SwapVectors;
  Exec(GetEnv('COMSPEC'), Concat(' /c ', ECmdLine^, ' ', ArcFile, ' ', PathExtract, ' ', Note^));
  SwapVectors;
  SetMemTop(HeapEnd);
end;

function TArc.MoveFile(ArcFile, FileName: String): Boolean;
begin
  SetMemTop(HeapPtr);
  SwapVectors;
  Exec(GetEnv('COMSPEC'), Concat('/c ', MCmdLine^, ' ', ArcFile, ' ', FileName));
  SwapVectors;
  SetMemTop(HeapEnd);
end;


procedure TArchiver.FreeItem(Item : Pointer);
begin
  PArc(Item)^.Done;
end;

function TArchiver.GetItem(var S: TStream): Pointer;
var
  AArchiver : PArc;
begin
  AArchiver:= New(PArc, Init(''));
  if AArchiver <> nil then
    with AArchiver^ do
    begin
      Note := S.ReadStr;
      Name := S.ReadStr;
      ECmdLine := S.ReadStr;
      MCmdLine := S.ReadStr;
    end;
  GetItem := AArchiver;
end;

procedure TArchiver.PutItem(var S: TStream; Item: Pointer);
var
  AArchiver : PArc;
begin
  AArchiver := Item;
  with AArchiver^ do
  begin
    S.WriteStr(Note);
    S.WriteStr(Name);
    S.WriteStr(ECmdLine);
    S.WriteStr(MCmdLine);
  end;
end;

procedure RegisterArchiver;
begin
  RegisterType(RArchiver);
end;

begin
  RegisterArchiver;
end.