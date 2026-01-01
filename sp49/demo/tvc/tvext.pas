{************************************************}
{                                                }
{   Unit has new objects of the Turbo Vision     }
{   Copyright (c) 1992 by Igor Gorin             }
{                                                }
{************************************************}

unit TVExt;

interface

uses Objects, Dialogs, Views, Drivers;

type
  { The ListBox of RadioButtons }
  PRadioButtonsList =^TRadioButtonsList;
  TRadioButtonsList = object(TListBox)
    function GetText(Item : Integer; MaxLen : Integer) : String; virtual;
    procedure GetData(var Rec); virtual;
    procedure SetData(var Rec); virtual;
    function DataSize : Word; virtual;
  end;

  { The ListBox of CheckBoxes }
  PCheckBoxesList=^TCheckBoxesList;
  TCheckBoxesList = object(TListBox)
    Value : Word;
    constructor Init(var Bounds: TRect; ANumCols: Word;
      AScrollBar: PScrollBar);
    procedure HandleEvent(var Event : TEvent); virtual;
    function GetText(Item : Integer; MaxLen : Integer) : String; virtual;
    procedure SelectItem(Item: Integer); virtual;
    procedure Load(var S : TStream); virtual;
    procedure Store(var S : TStream); virtual;
    procedure GetData(var Rec); virtual;
    procedure SetData(var Rec); virtual;
    function DataSize : Word; virtual;
  end;

const
  RRadioButtonsList : TStreamRec = (
    ObjType : 2010;
    VmtLink : Ofs(TypeOf(TRadioButtonsList)^);
    Load : @TRadioButtonsList.Load;
    Store : @TRadioButtonsList.Store);

const
  RCheckBoxesList : TStreamRec = (
    ObjType : 2011;
    VmtLink : Ofs(TypeOf(TCheckBoxesList)^);
    Load : @TCheckBoxesList.Load;
    Store : @TCheckBoxesList.Store);

implementation

{ TRadioButtonsList ---------------------------------------}

function TRadioButtonsList.GetText(Item : Integer; MaxLen : Integer) : String;
var
  S : String;
begin
  S := TListBox.GetText(Item, MaxLen);
  if IsSelected(Item) then
    S := '(' + #7 + ') ' + S
  else
    S := '( ) ' + S;
  GetText := S;
end;

procedure TRadioButtonsList.GetData(var Rec);
begin
  Word(Rec) := Focused;
end;

procedure TRadioButtonsList.SetData(var Rec);
begin
  Focused := Integer(Rec);
end;

function TRadioButtonsList.DataSize : Word;
begin
  DataSize := SizeOf(Integer);
end;

{ TCheckBoxesList ------------------------------------------}

constructor TCheckBoxesList.Init(var Bounds: TRect; ANumCols: Word;
  AScrollBar: PScrollBar);
begin
  TListBox.Init(Bounds, ANumCols, AScrollBar);
  Value := 0;
end;

function TCheckBoxesList.GetText(Item : Integer; MaxLen : Integer) : String;
var
  S : String;
begin
  S := TListBox.GetText(Item, MaxLen);

  { if is marked }
  if Value and (1 shl Item) <> 0 then
    S := '[X]' + S
  else
    S := '[ ]' + S;
  GetText := S;
end;

procedure TCheckBoxesList.SelectItem(Item: Integer);
begin
  TListBox.SelectItem(Item);
  Value := Value xor (1 shl Item);
  DrawView;
end;

procedure TCheckBoxesList.HandleEvent(var Event : TEvent);
var
  DoSelect : Boolean;
begin
  if Event.What = evMouseDown then
    DoSelect := True
  else
    DoSelect := False;

  TListBox.HandleEvent(Event);
  if DoSelect and (Range > Focused) then SelectItem(Focused);
end;

procedure TCheckBoxesList.GetData(var Rec);
begin
  Integer(Rec) := Value;
end;

procedure TCheckBoxesList.SetData(var Rec);
begin
  Value := Word(Rec);
end;

function TCheckBoxesList.DataSize : Word;
begin
  DataSize := SizeOf(Word);
end;

procedure TCheckBoxesList.Load(var S : TStream);
begin
  TListBox.Load(S);
  S.Write(Value, SizeOf(Value));
end;

procedure TCheckBoxesList.Store(var S : TStream);
begin
  TListBox.Store(S);
  S.Read(Value, SizeOf(Value));
end;

end.