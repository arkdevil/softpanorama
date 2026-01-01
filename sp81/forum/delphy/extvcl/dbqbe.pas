{*******************************************************}
{                                                       }
{       Delphi VCL Unit                                 }
{       Copyright (c) 1995 OKO ROSNO                    }
{       Fedor V. Koshevnikov                            }
{                                                       }
{*******************************************************}

unit DbQBE;

{*************************************************************************}
{ The Delphi TQBEQuery component.                                         }
{ This component derives from TDBDataSet and is much like TQuery except   }
{ the language used for Query is QBE (Query by example).                  }
{ You can create the QBE queries from Paradox or DatabaseDesktop and then }
{ load or paste the query strings in the QBE property of TQBEQuery.       }
{*************************************************************************}

{$N+,P+,S-}

interface

uses SysUtils, WinTypes, WinProcs, DbiErrs, DbiTypes, DbiProcs,
  Classes, Controls, DB;

type

{ TQBEQuery }

  TQBEQuery = class(TDBDataSet)
  private
    FStmtHandle: HDBIStmt;
    FQBE: TStrings;
    FPrepared: Boolean;
    FText: PChar;
    FLocal: Boolean;
    FQBEBinary: PChar;
    function CreateCursor(GenHandle: Boolean): HDBICur;
    procedure DefineProperties(Filer: TFiler); override;
    procedure FreeStatement;
    function GetQueryCursor(GenHandle: Boolean): HDBICur;
    procedure GetStatementHandle(QBEText: PChar);
    function GetQBEText: PChar;
    procedure PrepareQBE(Value: PChar);
    procedure QueryChanged(Sender: TObject);
    procedure ReadBinaryData(Stream: TStream);
    procedure SetQuery(Value: TStrings);
    procedure SetPrepared(Value: Boolean);
    procedure SetPrepare(Value: Boolean);
    procedure WriteBinaryData(Stream: TStream);
  protected
    function CreateHandle: HDBICur; override;
    procedure Disconnect; override;
    procedure SetDBFlag(Flag: Integer; Value: Boolean); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ExecQBE;
    procedure Prepare;
    procedure UnPrepare;
    property Prepared: Boolean read FPrepared write SetPrepare;
    property Local: Boolean read FLocal;
    property StmtHandle: HDBIStmt read FStmtHandle;
    property Text: PChar read FText;
    property QBEBinary: PChar read FQBEBinary write FQBEBinary;
  published
    property QBE: TStrings read FQBE write SetQuery;
    property UpdateMode;
  end;

{ Designer registration }

procedure Register;

implementation

uses DBConsts, LibConst;

{ Utility routine }

function CheckOpen(Status: DBIResult): Boolean;
begin
  case Status of
    DBIERR_NONE:
      Result := True;
    DBIERR_NOTSUFFTABLERIGHTS:
      begin
        if not Session.GetPassword then DbiError(Status);
        Result := False;
      end;
  else
    DbiError(Status);
  end;
end;

{ TQBEQuery }

constructor TQBEQuery.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FQBE := TStringList.Create;
  TStringList(QBE).OnChange := QueryChanged;
  FText := nil;
end;

destructor TQBEQuery.Destroy;
begin
  Destroying;
  Disconnect;
  QBE.Free;
  StrDispose(FText);
  StrDispose(QBEBinary);
  inherited Destroy;
end;

procedure TQBEQuery.Disconnect;
begin
  Close;
  UnPrepare;
end;

procedure TQBEQuery.SetPrepare(Value: Boolean);
begin
  if Value then Prepare
  else UnPrepare;
end;

procedure TQBEQuery.Prepare;
begin
  SetDBFlag(dbfPrepared, True);
  SetPrepared(True);
end;

procedure TQBEQuery.UnPrepare;
begin
  SetPrepared(False);
  SetDBFlag(dbfPrepared, False);
end;

procedure TQBEQuery.SetQuery(Value: TStrings);
begin
  Disconnect;
  TStringList(QBE).OnChange := nil;
  QBE.Assign(Value);
  TStringList(QBE).OnChange := QueryChanged;
  QueryChanged(nil);
end;

procedure TQBEQuery.QueryChanged(Sender: TObject);
begin
  Disconnect;
  StrDispose(FText);
  FText := QBE.GetText;
  StrDispose(QBEBinary);
  QBEBinary := nil;
end;

procedure TQBEQuery.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineBinaryProperty('Data', ReadBinaryData, WriteBinaryData, QBEBinary <> nil);
end;

procedure TQBEQuery.ReadBinaryData(Stream: TStream);
begin
  QBEBinary := StrAlloc(Stream.Size);
  Stream.ReadBuffer(QBEBinary^, Stream.Size);
end;

procedure TQBEQuery.WriteBinaryData(Stream: TStream);
begin
  Stream.WriteBuffer(QBEBinary^, StrBufSize(QBEBinary));
end;

procedure TQBEQuery.SetPrepared(Value: Boolean);
begin
  if Handle <> nil then DBError(SDataSetOpen);
  if Value <> Prepared then
  begin
    if Value then
    begin
      if StrLen(Text) > 1 then PrepareQBE(Text)
      else DBError(SEmptySQLStatement);
    end
    else FreeStatement;
    FPrepared := Value;
  end;
end;

procedure TQBEQuery.FreeStatement;
begin
  if StmtHandle <> nil then DbiQFree(FStmtHandle);
end;

function TQBEQuery.CreateCursor(GenHandle: Boolean): HDBICur;
begin
  if QBE.Count > 0 then
  begin
    SetPrepared(True);
    Result := GetQueryCursor(GenHandle);
  end
  else Result := nil;
end;

function TQBEQuery.CreateHandle: HDBICur;
begin
  Result := CreateCursor(True)
end;

procedure TQBEQuery.ExecQBE;
begin
  CheckInActive;
  SetDBFlag(dbfExecSQL, True);
  try
    CreateCursor(False);
  finally
    SetDBFlag(dbfExecSQL, False);
  end;
end;

function TQBEQuery.GetQueryCursor(GenHandle: Boolean): HDBICur;
var
  PCursor: phDBICur;
  CursorProps: CurProps;
begin
  Result := nil;
  if GenHandle then PCursor := @Result
  else PCursor := nil;
  Check(DbiQExec(StmtHandle, PCursor));
end;

procedure TQBEQuery.SetDBFlag(Flag: Integer; Value: Boolean);
var
  NewConnection: Boolean;
begin
  if Value then
  begin
    NewConnection := DBFlags = [];
    inherited SetDBFlag(Flag, Value);
    if not (csReading in ComponentState) and NewConnection then
      FLocal := not Database.IsSQLBased;
  end
  else begin
    if DBFlags - [Flag] = [] then SetPrepared(False);
    inherited SetDBFlag(Flag, Value);
  end;
end;

procedure TQBEQuery.PrepareQBE(Value: PChar);
begin
  GetStatementHandle(Value);
end;

procedure TQBEQuery.GetStatementHandle(QBEText: PChar);
const
  DataType: array[Boolean] of LongInt = (Ord(wantCanned), Ord(wantLive));
begin
  if Local then
  begin
    while not CheckOpen(DbiQPrepare(DBHandle, qrylangQBE, QBEText,
      FStmtHandle)) do {Retry};
    Check(DBiSetProp(hDbiObj(StmtHandle), stmtAUXTBLS, LongInt(False)));
  end else
  begin
    Check(DbiQPrepare(DBHandle, qrylangQBE, QBEText, FStmtHandle));
  end;
end;

function TQBEQuery.GetQBEText: PChar;
var
  BufLen: Word;
  I: Integer;
  StrEnd: PChar;
  StrBuf: array[0..255] of Char;
begin
  BufLen := 1;
  for I := 0 to QBE.Count - 1 do
    Inc(BufLen, Ord(QBE.Strings[I][0]) + 1);
  Result := StrAlloc(BufLen);
  try
    StrEnd := Result;
    for I := 0 to QBE.Count - 1 do
    begin
      StrPCopy(StrBuf, QBE.Strings[I]);
      StrEnd := StrECopy(StrEnd, StrBuf);
      StrEnd := StrECopy(StrEnd, ' ');
    end;
  except
    StrDispose(Result);
    raise;
  end;
end;

{ Designer registration }

procedure Register;
begin
  RegisterComponents(LoadStr(srDAccess), [TQBEQuery]);
end;

end.