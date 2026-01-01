{**********************************************************}
{                                                          }
{  Turbo Vision Constructor.  Version 2.0                  }
{  Unit contain inputlines for numeric and real input      }
{  1992. Igor Gorin.                                       }
{                                                          }
{**********************************************************}

unit TVFields;

interface

{$X+}

uses Objects, Drivers, Dialogs;

type
  { Accepts only valid numeric input between Min and Max }
  PNumInputLine = ^TNumInputLine;
  TNumInputLine = object(TInputLine)
    Min: Longint;
    Max: Longint;
    constructor Init(var Bounds: TRect; AMaxLen: Integer;
      AMin, AMax: Longint);
    constructor Load(var S: TStream);
    function DataSize: Word; virtual;
    procedure GetData(var Rec); virtual;
    procedure SetData(var Rec); virtual;
    procedure Store(var S: TStream);
    function Valid(Command: Word): Boolean; virtual;
  end;

  { Accepts only valid real input between Min and Max }
  PRealInputLine = ^TRealInputLine;
  TRealInputLine = object(TInputLine)
    Min: Real;
    Max: Real;
    constructor Init(var Bounds: TRect; AMaxLen: Integer;
      AMin, AMax: Real);
    constructor Load(var S: TStream);
    function DataSize: Word; virtual;
    procedure GetData(var Rec); virtual;
    procedure SetData(var Rec); virtual;
    procedure Store(var S: TStream);
    function Valid(Command: Word): Boolean; virtual;
  end;

procedure RegisterFields;

const
  RRealInputLine: TStreamRec = (
     ObjType: 40061;
     VmtLink: Ofs(TypeOf(TRealInputLine)^);
     Load:    @TRealInputLine.Load;
     Store:   @TRealInputLine.Store
  );
  RNumInputLine: TStreamRec = (
     ObjType: 40060;
     VmtLink: Ofs(TypeOf(TNumInputLine)^);
     Load:    @TNumInputLine.Load;
     Store:   @TNumInputLine.Store
  );

implementation

uses Views, MsgBox;

procedure RegisterFields;
begin
  RegisterType(RRealInputLine);
  RegisterType(RNumInputLine);
end;

{ TNumInputLine -------------------------------------------}
constructor TNumInputLine.Init(var Bounds: TRect; AMaxLen: Integer;
  AMin, AMax: Longint);
begin
  TInputLine.Init(Bounds, AMaxLen);
  Min := AMin;
  Max := AMax;
end;

constructor TNumInputLine.Load(var S: TStream);
begin
  TInputLine.Load(S);
  S.Read(Min, SizeOf(LongInt) * 2);
end;

function TNumInputLine.DataSize: Word;
begin
  DataSize := SizeOf(LongInt);
end;

procedure TNumInputLine.GetData(var Rec);
var
  Code: Integer;
begin
  Val(Data^, Longint(Rec), Code);
end;

procedure TNumInputLine.Store(var S: TStream);
begin
  TInputLine.Store(S);
  S.Write(Min, SizeOf(Longint) * 2);
end;

procedure TNumInputLine.SetData(var Rec);
var
  S: string[12];
begin
  Str(Longint(Rec), Data^);
  SelectAll(True);
end;

function TNumInputLine.Valid(Command: Word): Boolean;
var
  Code: Integer;
  Value: Longint;
  Params: array[0..1] of LongInt;
  Ok: Boolean;
begin
  Ok := True;
  if (Command <> cmCancel) and (Command <> cmValid) and
     (Command <> cmQuit) then
  begin
    if Data^ = '' then Data^ := '0';
    Val(Data^, Value, Code);
    if (Code <> 0) or (Value < Min) or (Value > Max) then
    begin
      Select;
      Params[0] := Min;
      Params[1] := Max;
      MessageBox('Number must be from %D to %D.', @Params, mfError + mfOkButton);
      SelectAll(True);
      Ok := False;
    end;
  end;
  if Ok then Valid := TInputLine.Valid(Command)
  else Valid := False;
end;

{ TRealInputLine -------------------------------------------}
constructor TRealInputLine.Init(var Bounds: TRect; AMaxLen: Integer;
  AMin, AMax: Real);
begin
  TInputLine.Init(Bounds, AMaxLen);
  Min := AMin;
  Max := AMax;
end;

constructor TRealInputLine.Load(var S: TStream);
begin
  TInputLine.Load(S);
  S.Read(Min, SizeOf(Real) * 2);
end;

function TRealInputLine.DataSize: Word;
begin
  DataSize := SizeOf(Real);
end;

procedure TRealInputLine.GetData(var Rec);
var
  Code: Integer;
begin
  Val(Data^, Real(Rec), Code);
end;

procedure TRealInputLine.Store(var S: TStream);
begin
  TInputLine.Store(S);
  S.Write(Min, SizeOf(Real) * 2);
end;

procedure TRealInputLine.SetData(var Rec);
var
  S: string[12];
begin
  Str(Real(Rec):5:2, Data^);
  SelectAll(True);
end;

function TRealInputLine.Valid(Command: Word): Boolean;
var
  Code: Integer;
  Value: Real;
  Ok: Boolean;
  MInStr, MaxStr : String[20];
begin
  Ok := True;
  if (Command <> cmCancel) and (Command <> cmValid) and
     (Command <> cmQuit) then
  begin
    if Data^ = '' then Data^ := '0';
    Val(Data^, Value, Code);
    if (Code <> 0) or (Value < Min) or (Value > Max) then
    begin
      Select;
      Str(Min:5:2, MinStr);
      Str(Max:5:2, MaxStr);
      MessageBox(^C'Value must be from '+
        MinStr + ' to '+ MaxStr + '.', nil, mfError + mfOkButton);
      SelectAll(True);
      Ok := False;
    end;
  end;
  if Ok then Valid := TInputLine.Valid(Command)
  else Valid := False;
end;

end.
