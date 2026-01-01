
{*******************************************************}
{                                                       }
{             Turbo Pascal Version 6.0                  }
{       Selection ListViewer. Turbo Vision Unit         }
{                                                       }
{          Copyright Borland International              }
{    Portions Copyright (c) 1992 Dimarker's Software    }
{                                                       }
{*******************************************************}

unit DList;

{$F+,O+,S-,X+,B-}

interface

uses Objects, Views, Drivers;

const
   CSelViewer = #26#22#27#28#29;

const
   InsMovesDown : boolean = True;

type

{ TSelViewer }

  { Palette layout }
  { 1 = Active }
  { 2 = Inactive }
  { 3 = Focused }
  { 4 = Selected }
  { 5 = Divider }

  PSelViewer = ^TSelViewer;
  TSelViewer = object(TView)
    HScrollBar: PScrollBar;
    VScrollBar: PScrollBar;
    NumCols: Integer;
    TopItem: integer;
    Focused: integer;
    Range  : integer;
    Sel    : PByteArray;
    constructor Init(var Bounds: TRect; ANumCols: Word;
      AHScrollBar, AVScrollBar: PScrollBar);
    constructor Load(var S: TStream);
    procedure   ChangeBounds(var Bounds: TRect); virtual;
    procedure   Draw; virtual;
    procedure   FocusItem(Item: integer); virtual;
    function    GetPalette: PPalette; virtual;
    function    GetText(Item: integer; MaxLen: Integer): String; virtual;
    function    IsSelected(Item: integer): Boolean; virtual;
    function    HasSelection(Item: integer): boolean;
    procedure   HandleEvent(var Event: TEvent); virtual;
    procedure   SelectItem(Item: integer); virtual;
    procedure   SetRange(ARange: Integer);
    procedure   SetState(AState: Word; Enable: Boolean); virtual;
    procedure   Store(var S: TStream);
    destructor  Done; virtual;
  private
    procedure FocusItemNum(Item: integer); virtual;
  end;

{ TSelBox }

  PSelBox = ^TSelBox;
  TSelBox = object(TSelViewer)
    List: PCollection;
    constructor Init(var Bounds: TRect; ANumCols: Word;
      AScrollBar: PScrollBar);
    constructor Load(var S: TStream);
    function    DataSize: Word; virtual;
    procedure   GetData(var Rec); virtual;
    function    GetText(Item: Integer; MaxLen: Integer): String; virtual;
    procedure   NewList(AList: PCollection); virtual;
    procedure   SetData(var Rec); virtual;
    procedure   Store(var S: TStream);
  end;

  PVSelBox   = ^TVSelBox;
  TVSelBox   = object(TSelBox)
   ColSize : integer;
   constructor Init(var Bounds: TRect; ANumCols: Word;
                    AScrollBar: PScrollBar);
   procedure   Draw; virtual;
   constructor Load(var S: TStream);
   procedure   Store(var S: TStream);
  end;

implementation

{ TSelViewer }

constructor TSelViewer.Init(var Bounds: TRect; ANumCols: Word;
  AHScrollBar, AVScrollBar: PScrollBar);
var
  ArStep, PgStep: Integer;
begin
  TView.Init(Bounds);
  Options := Options or (ofFirstClick + ofSelectable);
  EventMask := EventMask or evBroadcast;
  Range := 0;
  NumCols := ANumCols;
  Focused := 0;
  if AVScrollBar <> nil then
  begin
    if NumCols = 1 then
    begin
      PgStep := Size.Y -1;
      ArStep := 1;
    end else
    begin
      PgStep := Size.Y * NumCols;
      ArStep := Size.Y;
    end;
    AVScrollBar^.SetStep(PgStep, ArStep);
  end;
  if AHScrollBar <> nil then AHScrollBar^.SetStep(Size.X div NumCols, 1);
  HScrollBar := AHScrollBar;
  VScrollBar := AVScrollBar;
end;

constructor TSelViewer.Load(var S: TStream);
begin
  TView.Load(S);
  GetPeerViewPtr(S, HScrollBar);
  GetPeerViewPtr(S, VScrollBar);
  S.Read(NumCols, SizeOf(Word) + (SizeOf(integer) * 3));
  if Range > 0 then
   begin
    GetMem(Sel, Range);
    S.Read(Sel^, Range);
   end;
end;

procedure TSelViewer.ChangeBounds(var Bounds: TRect);
begin
  TView.ChangeBounds(Bounds);
  if HScrollBar <> nil then HScrollBar^.SetStep(Size.X div NumCols, 1);
end;

procedure TSelViewer.Draw;
var
  I, J, Item: Integer;
  NormalColor, SelectedColor, InsColor, FocusedColor, Color: Word;
  ColWidth, CurCol, Indent: Integer;
  B: TDrawBuffer;
  Text: String;
  SCOff: Byte;
begin
  NormalColor := GetColor(1);
  FocusedColor := GetColor(2);
  InsColor    := GetColor(3);
  SelectedColor := GetColor(4);
  if HScrollBar <> nil then Indent := HScrollBar^.Value
  else Indent := 0;
  ColWidth := Size.X div NumCols + 1;
  for I := 0 to Size.Y - 1 do
  begin
    for J := 0 to NumCols-1 do
    begin
      Item := J*Size.Y + I + TopItem;
      CurCol := J*ColWidth;
      if (Focused = Item) and (Range > 0) then
       begin
	if Sel^[Item] = 0 then Color := FocusedColor
        else                   Color := InsColor;
        SetCursor(CurCol+1,I);
        SCOff := 0;
       end
      else
       if (Item < Range) and (boolean(Sel^[Item])) then
        begin
         Color := SelectedColor;
         SCOff := 2;
        end
       else
        begin
         Color := NormalColor;
         SCOff := 4;
        end;
      MoveChar(B[CurCol], ' ', Color, ColWidth);
      if Item < Range then
      begin
        Text := GetText(Item, ColWidth + Indent);
        Text := Copy(Text,Indent,ColWidth);
        MoveStr(B[CurCol+1], Text, Color);
        if ShowMarkers then
        begin
          WordRec(B[CurCol]).Lo := Byte(SpecialChars[SCOff]);
          WordRec(B[CurCol+ColWidth-2]).Lo := Byte(SpecialChars[SCOff+1]);
        end;
      end;
      MoveChar(B[CurCol+ColWidth-1], #179, GetColor(5), 1);
    end;
    WriteLine(0, I, Size.X, 1, B);
  end;
end;

procedure TSelViewer.FocusItem(Item: integer);
begin
  Focused := Item;
  if VScrollBar <> nil then VScrollBar^.SetValue(Item);
  if Item < TopItem then
    if NumCols = 1 then TopItem := Item
    else TopItem := Item - Item mod Size.Y
  else if Item >= TopItem + (Size.Y*NumCols) then
    if NumCols = 1 then TopItem := Item - Size.Y + 1
    else TopItem := Item - Item mod Size.Y - (Size.Y*(NumCols - 1));
end;

procedure TSelViewer.FocusItemNum(Item: integer);
begin
  if Item < 0 then Item := 0
  else if (Item >= Range) and (Range > 0) then Item := Range-1;
  if Range <> 0 then FocusItem(Item);
end;

function TSelViewer.HasSelection(Item: integer): boolean;
 begin
  HasSelection:=False;
  if (Item < Range) and (Item >= 0) then
   HasSelection:=Sel^[Item] <> 0;
 end;

function TSelViewer.GetPalette: PPalette;
const
  P: String[Length(CSelViewer)] = CSelViewer;
begin
  GetPalette := @P;
end;

function TSelViewer.GetText(Item: integer; MaxLen: Integer): String;
begin
  Abstract;
end;

function TSelViewer.IsSelected(Item: integer): Boolean;
begin
  IsSelected := Item = Focused;
end;

procedure TSelViewer.HandleEvent(var Event: TEvent);
const
  MouseAutosToSkip = 4;
var
  Mouse: TPoint;
  ColWidth: Word;
  OldItem, NewItem: Integer;
  Count: Word;
 begin
  TView.HandleEvent(Event);
  if Event.What = evMouseDown then
  begin
    ColWidth := Size.X div NumCols + 1;
    OldItem := Focused;
    MakeLocal(Event.Where, Mouse);
    NewItem := Mouse.Y + (Size.Y * (Mouse.X div ColWidth)) + TopItem;
    Count := 0;
    repeat
      if NewItem <> OldItem then FocusItemNum(NewItem);
      OldItem := NewItem;
      MakeLocal(Event.Where, Mouse);
      if MouseInView(Event.Where) then
	NewItem := Mouse.Y + (Size.Y * (Mouse.X div ColWidth)) + TopItem
      else
      begin
        if NumCols = 1 then
	begin
	  if Event.What = evMouseAuto then Inc(Count);
	  if Count = MouseAutosToSkip then
	  begin
	    Count := 0;
	    if Mouse.Y < 0 then NewItem := Focused-1
	    else if Mouse.Y >= Size.Y then NewItem := Focused+1;
	  end;
        end
        else
	begin
	  if Event.What = evMouseAuto then Inc(Count);
	  if Count = MouseAutosToSkip then
	  begin
	    Count := 0;
	    if Mouse.X < 0 then NewItem := Focused-Size.Y
	    else if Mouse.X >= Size.X then NewItem := Focused+Size.Y
	    else if Mouse.Y < 0 then
	      NewItem := Focused - Focused mod Size.Y
	    else if Mouse.Y > Size.Y then
	      NewItem := Focused - Focused mod Size.Y + Size.Y - 1;
	  end
        end;
      end;
    until not MouseEvent(Event, evMouseMove + evMouseAuto);
    FocusItemNum(NewItem);
    if Event.Double and (Range > Focused) then SelectItem(Focused);
    ClearEvent(Event);
  end
  else if Event.What = evKeyDown then
  begin
    if (Event.CharCode = ' ') and (Focused < Range) then
    begin
      SelectItem(Focused);
      NewItem := Focused;
    end
    else case CtrlToArrow(Event.KeyCode) of
      kbUp: NewItem := Focused - 1;
      kbDown: NewItem := Focused + 1;
      kbRight: if NumCols > 1 then NewItem := Focused + Size.Y else Exit;
      kbLeft: if NumCols > 1 then NewItem := Focused - Size.Y else Exit;
      kbPgDn: NewItem := Focused + Size.Y * NumCols;
      kbPgUp: NewItem := Focused - Size.Y * NumCols;
      kbHome: NewItem := TopItem;
      kbEnd: NewItem := TopItem + (Size.Y * NumCols) - 1;
      kbIns : if Range > 0 then
       begin
        boolean(Sel^[Focused]):=not boolean(Sel^[Focused]);
        NewItem:=Focused;
        if InsMovesDown then Inc(NewItem);
       end;
      kbCtrlPgDn: NewItem := Range - 1;
      kbCtrlPgUp: NewItem := 0;
    else
      Exit;
    end;
    FocusItemNum(NewItem);
    ClearEvent(Event);
  end else if Event.What = evBroadcast then
    if Options and ofSelectable <> 0 then
      if (Event.Command = cmScrollBarClicked) and
         ((Event.InfoPtr = HScrollBar) or (Event.InfoPtr = VScrollBar)) then
        Select
      else
       if (Event.Command = cmScrollBarChanged) then
        begin
         if (VScrollBar = Event.InfoPtr) then
          begin
           FocusItemNum(VScrollBar^.Value);
           DrawView;
          end
         else if (HScrollBar = Event.InfoPtr) then DrawView;
        end;
 end;

procedure TSelViewer.SelectItem(Item: integer);
 begin
  Message(Owner, evBroadcast, cmListItemSelected, @Self);
 end;

procedure TSelViewer.SetRange(ARange: Integer);
 var P: PByteArray;
 begin
  if (Range = ARange) or (ARange < 0) then Exit;
  if Sel = nil then
   begin
    GetMem(Sel, ARange);
    FillChar(Sel^, ARange, 0);
   end
  else
   begin
    GetMem(P, ARange);
    FillChar(P^, ARange, 0);
    if Range > ARange then Move(Sel^, P^, ARange)
    else                   Move(Sel^, P^, Range);
    FreeMem(Sel, Range);
    Sel:=P;
   end;
  Range := ARange;
  if VScrollBar <> nil then
   begin
    if Focused > ARange then Focused := 0;
    VScrollbar^.SetParams(Focused, 0, ARange-1, VScrollBar^.PgStep,
      VScrollBar^.ArStep);
   end;
 end;

procedure TSelViewer.SetState(AState: Word; Enable: Boolean);

procedure ShowSBar(SBar: PScrollBar);
 begin
  if (SBar <> nil) then
    if GetState(sfActive) then SBar^.Show
    else SBar^.Hide;
 end;

 begin
  TView.SetState(AState, Enable);
  if AState and (sfSelected + sfActive) <> 0 then
  begin
    ShowSBar(HScrollBar);
    ShowSBar(VScrollBar);
    DrawView;
  end;
 end;

procedure TSelViewer.Store(var S: TStream);
 begin
  TView.Store(S);
  PutPeerViewPtr(S, HScrollBar);
  PutPeerViewPtr(S, VScrollBar);
  S.Write(NumCols, SizeOf(Word) + (SizeOf(integer) * 3));
  S.Write(Sel^, Range);
 end;

destructor TSelViewer.Done;
 begin
  if Sel <> nil then FreeMem(Sel, Range);
  TView.Done;
 end;


{ TSelBox }

type
  TSelBoxRec = record
    List: PCollection;
    Selection: Word;
  end;

constructor TSelBox.Init(var Bounds: TRect; ANumCols: Word;
  AScrollBar: PScrollBar);
var
  ARange: Integer;
 begin
  TSelViewer.Init(Bounds, ANumCols, nil, AScrollBar);
  List := nil;
  SetRange(0);
 end;

constructor TSelBox.Load(var S: TStream);
 begin
  TSelViewer.Load(S);
  List := PCollection(S.Get);
 end;

function TSelBox.DataSize: Word;
 begin
  DataSize := SizeOf(TSelBoxRec);
 end;

procedure TSelBox.GetData(var Rec);
 begin
  TSelBoxRec(Rec).List := List;
  TSelBoxRec(Rec).Selection := Focused;
 end;

function TSelBox.GetText(Item: Integer; MaxLen: Integer): String;
 begin
  if List <> nil then GetText := PString(List^.At(Item))^
  else GetText := '';
 end;

procedure TSelBox.NewList(AList: PCollection);
 begin
  if List <> nil then Dispose(List, Done);
  List := AList;
  if AList <> nil then SetRange(AList^.Count)
  else SetRange(0);
  if Range > 0 then FocusItem(0);
  DrawView;
 end;

procedure TSelBox.SetData(var Rec);
 begin
  NewList(TSelBoxRec(Rec).List);
  FocusItem(TSelBoxRec(Rec).Selection);
  DrawView;
 end;

procedure TSelBox.Store(var S: TStream);
 begin
  TSelViewer.Store(S);
  S.Put(List);
 end;

{ TVSelBox ; vertical split on ANumCols & ColumnSize }

constructor TVSelBox.Init(var Bounds: TRect; ANumCols: Word;
                          AScrollBar: PScrollBar);
 begin
  TSelBox.Init(Bounds, ANumCols, AScrollBar);
  if ANumCols > 0 then
   ColSize:=(Bounds.B.X - Bounds.A.X) div ANumCols
  else
   ColSize:=Bounds.B.X - Bounds.A.X;
 end;

procedure TVSelBox.Draw;
 var
  i: integer;
  ArStep, PgStep: Integer;
 begin
  i:=NumCols;
  if (Size.X div ColSize) > NumCols then
   Inc(NumCols);
  if (Size.X div ColSize) < NumCols then
   if NumCols > 1 then
    Dec(NumCols);
  if i <> NumCols then
   begin
    if VScrollBar <> nil then
    begin
      if NumCols = 1 then
      begin
        PgStep := Size.Y -1;
        ArStep := 1;
      end else
      begin
        PgStep := Size.Y * NumCols;
        ArStep := Size.Y;
      end;
      VScrollBar^.SetStep(PgStep, ArStep);
    end;
    if HScrollBar <> nil then HScrollBar^.SetStep(Size.X div NumCols, 1);
   end;
  TSelBox.Draw;
 end;

constructor TVSelBox.Load(var S: TStream);
 begin
  TSelBox.Load(S);
  S.Read(ColSize, SizeOf(integer));
 end;

procedure TVSelBox.Store(var S: TStream);
 begin
  TSelBox.Store(S);
  S.Write(ColSize, SizeOf(integer));
 end;


end.