{************************************************}
{                                                }
{        L e c a r                               }
{   Turbo Pascal 6.X                             }
{   Попросту, без чинов и Copyright-ов  1992     }
{   Версия 2.0 от                                }
{************************************************}

{$A+,B-,D+,E-,F-,G-,I+,L+,N-,O-,R+,S+,V+,X-}
{$M 16384,0,655360}

Unit Archiv;

Interface

Uses Objects;

type
  PArc = ^TArc;
  TArc = record
    Note, Name, CmdLine, Path : PString;
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

function NewArchiver(ANote, AName, ACmdLine, APath: String): Pointer;
procedure RegisterArchiver;

Implementation

var
  SaveExit : Pointer;

function NewArchiver(ANote, AName, ACmdLine, APath: String): Pointer;
var
  AArchiver : PArc;
begin
  New(AArchiver);
  if AArchiver <> nil then
    with AArchiver^ do
    begin
      Note := NewStr(ANote);
      Name := NewStr(AName);
      CmdLine := NewStr(ACmdLine);
      Path := NewStr(APath);
    end;
end;

procedure TArchiver.FreeItem(Item : Pointer);
begin
  DisposeStr(PArc(Item)^.Note);
  DisposeStr(PArc(Item)^.Name);
  DisposeStr(PArc(Item)^.CmdLine);
  DisposeStr(PArc(Item)^.Path);
  Dispose(PArc(Item));
end;

function TArchiver.GetItem(var S: TStream): Pointer;
var
  AArchiver : PArc;
begin
  New(AArchiver);
  if AArchiver <> nil then
    with AArchiver^ do
    begin
      Note := S.ReadStr;
      Name := S.ReadStr;
      CmdLine := S.ReadStr;
      Path := S.ReadStr;
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
    S.WriteStr(CmdLine);
    S.WriteStr(Path);
  end;
end;

procedure RegisterArchiver;
begin
  RegisterType(RArchiver);
end;

begin
  RegisterArchiver;
end.