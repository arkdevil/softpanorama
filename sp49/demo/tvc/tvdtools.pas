{************************************************}
{                                                }
{      Unit for Turbo Vision Constructor 2.0     }
{          Contain objects and tools             }
{              1992. Igor Gorin.                 }
{                                                }
{************************************************}

unit TVDTools;

{$X+}

interface

uses Objects, Drivers, Views, MsgBox, TVObject, Dialogs, Menus, TVColl;

const
  Strings : PKeyCollection = nil;

procedure SetID(P : PView; ID : Byte);
{ - Get for TView objects ID }

function GetID(P : PView) : Byte;
{ - Get TView objects ID }

function GetIDObject(Grup : PGroup;ID : Byte) : PView;
{ - Get object with ID }

procedure PutIDObject(G : PGroup; ID : Byte; P : PView);
{ - Insert object with ID in group }

function LoadDialog(ResFile : PResourceFile; Key : String;
  Rec : TStreamRec) : PDialog;
{ - Load dialog with change TStreamRec }

function FileExists(FileName: FNameStr) : Boolean;
{ - Returns True if file exists; otherwise,
  it returns False. Closes the file if it exists. }

type
  { Object for input KeyCode }
  { MaxLen have be > MaxLenght strings in AList !!! }
  PCodeInputLine = ^TCodeInputLine;
  TCodeInputLine = object(TInputLine)
    List : PKeyCollection;
    constructor Init(var Bounds: TRect; AMaxLen: Integer;
      AList : PKeyCollection);
    procedure HandleEvent(var Event : TEvent); virtual;
    function DataSize : Word; virtual;
    procedure SetData(var Rec); virtual;
    procedure GetData(var Rec); virtual;
  end;

type
  { StatusLine with context help }
  PHelpStatusLine = ^THelpStatusLine;
  THelpStatusLine= object (TStatusLine)
    function Hint(AHelpCtx : Word) : String; virtual;
  end;

const
  RHelpStatusLine : TStreamRec = (
    ObjType : 42; { = RStatusLine.ObjType }
    VmtLink : Ofs(TypeOf(THelpStatusLine)^);
    Load : @THelpStatusLine.Load;
    Store : @THelpStatusLine.Store);

type
  { Stream for Resourse }
  PProtectStream = ^TProtectStream;
  TProtectStream = object(TBufStream)
    procedure Error(Code, Info : Integer); virtual;
  end;

const
  StreamError : Array[stPutError..stError] of String[32] =
    ('Put of unregistered object type',
     'Get of unregistered object type',
     'Cannot expand stream',
     'Read beyond end of stream',
     'Cannot initialize stream',
     'Access error');

implementation
 
procedure SetID(P : PView; ID : Byte);
{ - set for TView objects ID }
type
  TWord = record
    Lo : Byte;
    Hi : Byte;
  end;
begin
  { Uses high 5 bit in fild ~Options~... }
  { Clear 6 Hi free bits }
  TWord(P^. Options).Hi := TWord(P^.Options).Hi and 3;
  { Set 6 bits }
  TWord(P^. Options).Hi := TWord(P^.Options).Hi or (ID Shl 2);

  { Clear 3 bits in ~GrowMode~ }
  P^.GrowMode := P^.GrowMode and Not(128 + 64 + 32);
  { Set 2 bits in ~GrowMode~ }
  P^.GrowMode := P^.GrowMode or (ID and Not(16+8+4+2+1));
end;

function GetID(P : PView) : Byte;
{ - get TView objects ID }
begin
  { Uses high 6 bit in ~Options~ and 2 bits in ~GrowMode ~}
  GetID := (Hi(P^.Options) Shr 2) or (P^.GrowMode and Not(16+8+4+2+1));
end;

function GetIDObject(Grup : PGroup; ID : Byte) : PView;

  function ObjectID(P : PView) : Boolean; far;
  begin
    ObjectID := GetID(P) = ID;
  end;

begin
  GetIDObject := Grup^.FirstThat(@ObjectID);
end;

procedure PutIDObject(G : PGroup; ID : Byte; P : PView);
{ Insert object with ID in group }
var
  F : PView;
  Cur : PView;
  DefButton : PButton;

  function IsDefaultButton(C : PView) : Boolean; far;
  begin
    if TypeOf(C^) = TypeOf(TButton) then
      IsDefaultButton := PButton(C)^.Flags and bfDefault <> 0
    else
      IsDefaultButton := False;
  end;

  procedure ChangeLink(C : PView); far;
  { Change filds ~Link~ in THistory and TLabel }
  begin
    if TypeOf(C^) = TypeOf(TLabel) then
      if PLabel(C)^.Link = F then PLabel(C)^.Link := P;

    if TypeOf(F^) = TypeOf(TInputLine) then
      if TypeOf(C^) = TypeOf(THistory) then
	if PHistory(C)^.Link = PInputLine(F) then
	  PHistory(C)^.Link := PInputLine(P);
  end;

  procedure LinkScrollers(C : PView); far;
  { Change filds ~Link~ in THistory and TLabel }
  begin
    if TypeOf(C^) = TypeOf(TScrollBar) then
    begin
      if PListViewer(F)^.HScrollBar = PScrollBar(C) then
         PListViewer(P)^.HScrollBar := PScrollBar(C);

      if PListViewer(F)^.VScrollBar = PScrollBar(C) then
         PListViewer(P)^.VScrollBar := PScrollBar(C);
    end;
  end;

begin
  F := GetIDObject(G, ID);

  { Save pointer an current object }
  Cur := G^.Current;

  if F <> nil then
  begin
    { Remembe default button and clear default }
    DefButton := PButton(G^.FirstThat(@IsDefaultButton));

    { Set old fields }
    P^.Origin := F^.Origin;
    P^.Size := F^.Size;
    P^.Options := F^.Options;
    P^.EventMask := F^.EventMask;
    P^.DragMode := F^.DragMode;
    P^.GrowMode := F^.GrowMode;
    P^.HelpCtx := F^.HelpCtx;

    { Insert new objecs }
    G^.InsertBefore(P, F);

    { if there are labels and history then change ~Link~ filds }
    G^.ForEach(@ChangeLink);

    { if there are scrollbar then change HScrollBar anf VScrollBar }
    if (TypeOf(F^) = TypeOf(TListBox)) or
       (TypeOf(F^) = TypeOf(TListViewer)) then
       G^.ForEach(@LinkScrollers);

    { Delete old objects }
    G^.Delete(F);

    { Restore current object }
    if Cur = F then P^.Select else Cur^.Select;

    Dispose(F, Done);
    if DefButton <> nil then DefButton^.SetState(sfSelected, False);

    SetID(P, ID);
  end;
end;

function FileExists(FileName: FNameStr) : Boolean;
{ Returns True if file exists; otherwise,
  it returns False. Closes the file if
  it exists. }
var
  F: File;
begin
  {$I-}
  Assign(F, FileName);
  Reset(F);
  Close(F);
  {$I+}
  FileExists := (IOResult = 0) and (FileName <> '');
end;  { FileExists }

function LoadDialog(ResFile : PResourceFile; Key : String;
  Rec : TStreamRec) : PDialog;
{ - Load dialog with change TStreamRec }
var
  MemRec : TStreamRec;
  D : PDialog;

begin
  { Save RDialog }
  MemRec := RDialog;

  RDialog.VmtLink := Rec.VmtLink;
  RDialog.Load := Rec.Load;
  RDialog.Store := Rec.Store;

  D := PDialog(ResFile^.Get(Key));

  { Restore RDialog }
  RDialog := MemRec;

  LoadDialog := D;
end;

{ ProtectStream --------------------------------------------}

procedure TProtectStream.Error(Code, Info : Integer);
begin
  TBufStream.Error(Code, Info);
  MessageBox(StreamError[Code] , nil, mfError + mfOkButton);
end;

{ THelpStatusLine ------------------------------------------}

function THelpStatusLine.Hint(AHelpCtx : Word) : String;
begin
  if Strings <> nil then
    Hint := Strings^.GetStr(AHelpCtx)
  else
    Hint := '';
end;

{ TCodeInputLine -------------------------------------------}

constructor TCodeInputLine.Init(var Bounds: TRect; AMaxLen: Integer;
      AList : PKeyCollection);
begin
  TInputLine.Init(Bounds, AMaxLen);
  List := AList;
end;

procedure TCodeInputLine.HandleEvent(var Event : TEvent);
begin
  if Event.What = evKeyDown then
  begin
    if Event.KeyCode = kbDown then
      TInputLine.HandleEvent(Event);
  end
  else
    TInputLine.HandleEvent(Event);
end;

function TCodeInputLine.DataSize : Word;
begin
  DataSize := SizeOf(Word);
end;

procedure TCodeInputLine.SetData(var Rec);
begin
  if List <> nil then
    Data^ := List^.GetStr(Word(Rec));
end;

procedure TCodeInputLine.GetData(var Rec);
begin
  if List <> nil then
    Word(Rec) := List^.GetKey(Data^);
end;


end.