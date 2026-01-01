{************************************************}
{        Unit for Turbo Vision Constructor       }
{                  Version 2.0                   }
{             contain keycollection              }
{               1992. Igor Gorin.                }
{************************************************}

unit TVColl;

interface

uses Objects;

type
  { Element of the collection }
  PKey = ^TKey;
  TKey = object(TObject)
    Key : Word;
    Name : PString;
    constructor Init(AKey : Word; S : String);
    destructor Done; virtual;
    constructor Load(var S : TStream);
    procedure Store(var S : TStream); virtual;
  end;

type
  { String collection }
  PKeyCollection = ^TKeyCollection;
  TKeyCollection = object(TCollection)
    procedure Put(Key : Word; S : String);
    function GetKey(S : String) : Word;
    function GetStr(Key : Word) : String;
  end;

const
  RKeyCollection : TStreamRec = (
    ObjType : 2000;
    VmtLink : Ofs(TypeOf(TKeyCollection)^);
    Load : @TkeyCollection.Load;
    Store : @TKeyCollection.Store);

const
  RKey : TStreamRec = (
    ObjType : 2001;
    VmtLink : Ofs(TypeOf(TKey)^);
    Load : @TKey.Load;
    Store : @TKey.Store);

procedure RegisterKeyCollection;
{ - Register RKey and RKeyCollection }

implementation

procedure RegisterKeyCollection;
{ - Register RKey and RKeyCollection }
begin
  RegisterType(RKey);
  RegisterType(RKeyCollection);
end;

function UpCaseStr(S : String) : String;
var
  I : Integer;
begin
  for I := 1 to Length(S) do
    S[I] := UpCase(S[I]);
  UpCaseStr := S;
end;

{ TKey ------------------------------------------------------}

constructor TKey.Init(AKey : Word;S : String);
begin
  Key := AKey;
  Name := NewStr(S);
end;

destructor TKey.Done;
begin
  DisposeStr(Name);
end;

procedure TKey.Store(var S : TStream);
begin
  S.Write(Key, SizeOf(Key));
  S.WriteStr(Name);
end;

constructor TKey.Load(var S : TStream);
begin
  S.Read(Key, SizeOf(Key));
  Name := S.ReadStr;
end;

{ TKeyCollection -------------------------------------------------}

procedure TKeyCollection.Put(Key : Word; S : String);

  function ThereIsKey(C : PKey) : Boolean; far;
  begin
    ThereIsKey := C^.Key = Key;
  end;

var
  K : PKey;

begin
  K := FirstThat(@ThereIsKey);
  if K = nil then
    Insert( New( PKey, Init(Key, S)))
  else
  begin
    DisposeStr(K^.Name);
    K^.name := NewStr(S);
  end;
end;

function TKeyCollection.GetKey(S : String) : Word;
var
  FoundKey : PKey;

  function ThereIsStr(C : PKey) : Boolean; far;
  begin
    ThereIsStr := C^.Name^ = S;
  end;

begin
  FoundKey := FirstThat(@ThereIsStr);
  if FoundKey <> nil then
    GetKey := FoundKey^.Key
  else
    GetKey := 0;
end;

function TKeyCollection.GetStr(Key : Word) : String;
var
  FoundKey : PKey;

  function ThereIsKey(C : PKey) : Boolean; far;
  begin
    ThereIsKey := C^.Key = Key;
  end;

begin
  FoundKey := FirstThat(@ThereIsKey);
  if FoundKey = nil then
    GetStr := ''
  else
    if FoundKey^.Name <> nil then
      GetStr := FoundKey^.Name^
    else
      GetStr := '';
end;

end.