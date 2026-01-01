{*******************************************************}
{                                                       }
{         Borland Delphi Unit                           }
{                                                       }
{         Copyright (c) 1995 OKO ROSNO                  }
{                                                       }
{*******************************************************}
unit DBTools;

{$W-,R-,B-,N+,P+}

interface

uses DB;

function DataSetGotoValue(DataSet: TDataSet; const Value,
  FieldName: string): Boolean;

function DataSetGotoData(DataSet: TDataSet; Data: Pointer;
  const FieldName: string): Boolean;

function DataSetSortedSearch(DataSet: TDataSet; const Value: string;
  const FieldName: string; Unique, IgnoreCase: Boolean): Boolean;

procedure ConvertStringToLogicType(Locale: TLocale; FldLogicType: Integer;
  FldSize: Word; const FldName, Value: String; Buffer: Pointer);

function LoginToDatabase(Database: TDatabase; OnLogin: TLoginEvent): Boolean;

procedure InitRSRUN(Database: TDatabase; const ConName: string;
  ConType: Integer; const ConServer: string);

implementation

Uses
  Classes, SysUtils, WinTypes, DbiTypes, DbiProcs, DbiErrs, Forms, Controls,
  Dialogs, DBTables, DBConsts, IniFiles, ExtConst;

{ Routine for convert string to IDAPI logical field type }

procedure ConvertStringToLogicType(Locale: TLocale; FldLogicType: Integer;
  FldSize: Word; const FldName, Value: String; Buffer: Pointer);
var
  E: Integer;
  L: Longint;
  B: WordBool;
  F: Extended;
  D: Double;
  BCD: FMTBcd;
  Buf: array[0..63] of Char;
  DateTime: TDateTime;
  dtData: TDateTime;
  Data: Longint absolute dtData;
begin
  case FldLogicType of
    fldZSTRING:
      begin
        AnsiToNative(Locale, Value, PChar(Buffer), FldSize);
      end;
    fldBYTES, fldVARBYTES:
      begin
        L := Length(Value);
        if L > FldSize then L := FldSize;
        Move(Value[1], Buffer^, L);
      end;
    fldINT16, fldINT32, fldUINT16:
      begin
        if Value = '' then DBErrorFmt(SFieldValueError, [FldName])
        else begin
          Val(Value, L, E);
          if E <> 0 then DBErrorFmt(SInvalidIntegerValue, [Value, FldName]);
          Move(L, Buffer^, FldSize);
        end;
      end;
    fldBOOL:
      begin
        L := Length(Value);
        if L = 0 then B := False
        else begin
          if Value[1] in ['Y', 'y', 'T', 't', '1'] then B := True
          else B := False;
        end;
        Move(B, Buffer^, SizeOf(WordBool));
      end;
    fldFLOAT, fldBCD:
      begin
        if Value = '' then DBErrorFmt(SFieldValueError, [FldName])
        else begin
          if not TextToFloat(StrPLCopy(Buf, Value, SizeOf(Buf) - 1), F) then
            DBErrorFmt(SInvalidFloatValue, [Value, FldName]);
          D := F;
          if FldLogicType <> fldBCD then
            Move(D, Buffer^, SizeOf(Double))
          else begin
            DbiBcdFromFloat(D, 32, FldSize, BCD);
            Move(BCD, Buffer^, SizeOf(BCD));
          end;
        end;
      end;
    fldDATE, fldTIME, fldTIMESTAMP:
      begin
        if Value = '' then begin
          Data := 0;
        end
        else begin
          case FldLogicType of
            fldDATE:
              begin
                DateTime := StrToDate(Value);
                Data := Trunc(DateTime);
              end;
            fldTIME:
              begin
                DateTime := StrToTime(Value);
                Data := Round(Frac(DateTime) * MSecsPerDay);
              end;
            fldTIMESTAMP:
              begin
                DateTime := StrToDateTime(Value);
                dtData := DateTime * MSecsPerDay;
              end;
          end;
        end;
        Move(dtData, Buffer^, FldSize);
      end;
    else DbiError(DBIERR_INVALIDFLDTYPE);
  end;
end;

{ BDE-filter-based DataSet position routines }

const
  FieldLogicMap: array[TFieldType] of Integer =
    (fldUNKNOWN, fldZSTRING, fldINT16, fldINT32, fldUINT16,
    fldBOOL, fldFLOAT, fldFLOAT, fldBCD, fldDATE, fldTIME, fldTIMESTAMP,
    fldBYTES, fldVARBYTES, fldBLOB, fldBLOB, fldBLOB);

function DataSetGotoData(DataSet: TDataSet; Data: Pointer;
  const FieldName: string): Boolean;
type
  TSimpleEQFilter = array [1..18] of Integer;
const
  EQFilterHeaderSize = 26 + SizeOf(CANExpr);
  SimpleEQFilter: TSimpleEQFilter = (
    CANEXPRVERSION,
    0,                      { Full expression size } {# 2}
    3,                      { iNodes }
    SizeOf(CANExpr),
    EQFilterHeaderSize,
    Integer(nodeBINARY),
    Integer(canEQ),
    8,
    16,
    Integer(nodeFIELD),
    Integer(canFIELD2),
    0,                      { iFieldNumber } {# 12}
    0,                      { offset of field name in literal area }
    Integer(nodeCONST),
    Integer(canCONST2),
    0,                      { field logical type } {# 16}
    0,                      { const size } {# 17}
    0);                     { offset of const in literal area } {# 18}
var
  Bookmark: TBookmark;
  Field: TField;
  FilterDesc, Temp: PByte;
  Filter: hDBIFilter;
  SaveCursor: TCursor;
  SaveReqLive: Boolean;
begin
  Result := False;
  if DataSet = nil then Exit;
  Field := DataSet.FindField(FieldName);
  if Field = nil then Exit;
  { fill CANExpr header and nodes }
  SimpleEQFilter[12] := Field.FieldNo;
  SimpleEQFilter[16] := FieldLogicMap[Field.DataType];
  SimpleEQFilter[17] := Field.DataSize;
  SimpleEQFilter[18] := Length(FieldName) + 1;
  SimpleEQFilter[2]  := EQFilterHeaderSize + SimpleEQFilter[18] +
                        SimpleEQFilter[17];
  { move CANExpr and literal area to whole buffer }
  FilterDesc := AllocMem(SimpleEQFilter[2]);
  DataSet.DisableControls;
  SaveCursor := Screen.Cursor;
  try
    Screen.Cursor := crHourGlass;
    Temp := FilterDesc;
    Move(SimpleEQFilter, FilterDesc^, SizeOf(SimpleEQFilter));
    Inc(Temp, SizeOf(SimpleEQFilter));
    Move(FieldName[1], Temp^, Length(FieldName));
    Inc(Temp, Length(FieldName) + 1);
    Move(Data^, Temp^, Field.DataSize);
    Check(DbiAddFilter(DataSet.Handle, 0, 0, False, pCANExpr(FilterDesc),
      nil, Filter));
    try
      Check(DbiActivateFilter(DataSet.Handle, Filter));
      Bookmark := nil;
      try
        DataSet.Resync([]);
        Bookmark := DataSet.GetBookmark;
      finally
        DbiDeactivateFilter(DataSet.Handle, Filter);
      end;
      try
        DataSet.Resync([]);
      except
        raise;
      end;
      if Bookmark <> nil then begin
        try
          DataSet.GotoBookmark(Bookmark);
          Result := True;
        finally
          DataSet.FreeBookmark(Bookmark);
        end;
      end;
    finally
      DbiDropFilter(DataSet.Handle, Filter);
    end;
  finally
    Screen.Cursor := SaveCursor;
    if FilterDesc <> nil then FreeMem(FilterDesc, SimpleEQFilter[2]);
    DataSet.EnableControls;
  end;
end;

function DataSetGotoValue(DataSet: TDataSet; const Value,
  FieldName: string): Boolean;
var
  Buffer: Pointer;
  Field: TField;
  SaveIndex, SaveIndexFld: string;
begin
  Result := False;
  if DataSet = nil then Exit;
  Field := DataSet.FindField(FieldName);
  if Field = nil then Exit;
  if DataSet is TTable then begin
    with TTable(DataSet) do begin
      if State = dsSetKey then Exit;
      if Field.IsIndexField then begin
        SetKey;
        Field.AsString := Value;
        Result := GotoKey;
      end
      else begin
        DisableControls;
        try
          SaveIndexFld := IndexFieldNames;
          SaveIndex := IndexName;
          try
            IndexFieldNames := FieldName;
            SetKey;
            Field.AsString := Value;
            Result := GotoKey;
          except
            Result := False;
          end;
        finally
          if (SaveIndexFld = '') and (SaveIndex = '') then
          begin
            IndexFieldNames := SaveIndexFld;
            IndexName := SaveIndex;
          end
          else begin
            if SaveIndex <> '' then
              IndexName := SaveIndex
            else
              IndexFieldNames := SaveIndexFld;
          end;
          EnableControls;
        end;
      end;
    end;
  end;
  if not Result then begin
    Buffer := AllocMem(Field.DataSize);
    try
      ConvertStringToLogicType(DataSet.Locale, FieldLogicMap[Field.DataType],
        Field.DataSize, FieldName, Value, Buffer);
      Result := DataSetGotoData(DataSet, Buffer, FieldName);
    finally
      FreeMem(Buffer, Field.DataSize);
    end;
  end;
end;

{ DataSetSortedSearch. Navigate on sorted DataSet routine. }

function DataSetKeySortedSearch(DataSet: TDataSet; const Value: string;
  const FieldName: string): Boolean;
var
  Temp: string;
  Field: TField;
begin
  Result := False;
  Field := DataSet.FindField(FieldName);
  if (DataSet is TTable) and (Field.IsIndexField) then begin
    with TTable(DataSet) do begin
      if State = dsSetKey then Exit;
      try
        SetKey;
        KeyExclusive := False;
        Field.AsString := Value;
        GotoNearest;
        Temp := Field.AsString;
        if Temp[0] > Value[0] then Temp[0] := Value[0];
        Result := (Temp = Value);
      except
        Result := False;
      end;
    end;
  end;
end;

function DataSetSortedSearch(DataSet: TDataSet; const Value: string;
  const FieldName: string; Unique, IgnoreCase: Boolean): Boolean;
var
  L, H, I, C: Longint;
  CurrentPos: Longint;
  CurrentValue: string;
  Bookmark: TBookmark;
  Field: TField;

  function UpStr(const Value: string): string;
  begin
    if IgnoreCase then Result := AnsiUpperCase(Value)
    else Result := Value;
  end;

  function GetCurrentStr: string;
  begin
    Result := Field.AsString;
    if Result[0] > Value[0] then Result[0] := Value[0];
    Result := UpStr(Result);
  end;

begin
  Result := False;
  if DataSet = nil then Exit;
  Field := DataSet.FindField(FieldName);
  if Field = nil then Exit;
  if (DataSet is TTable) then begin
    Result := DataSetKeySortedSearch(DataSet, UpStr(Value), FieldName);
    if Result then Exit;
  end;
  if Field.DataType = ftString then
  begin
    DataSet.DisableControls;
    Bookmark := DataSet.GetBookmark;
    try
      L := 0;
      DataSet.First;
      CurrentPos := 0;
      H := DataSet.RecordCount - 1;
      if Value <> '' then
      begin
        while L <= H do
        begin
          I := (L + H) shr 1;
          if I <> CurrentPos then DataSet.MoveBy(I - CurrentPos);
          CurrentPos := I;
          CurrentValue := GetCurrentStr;
          if (UpStr(Value) > CurrentValue) then
            L := I + 1
          else begin
            H := I - 1;
            if (UpStr(Value) = CurrentValue) then
            begin
              Result := True;
              if Unique then begin
                L := I;
                Break;
              end;
            end;
          end;
        end; { while }
        if Result then begin
          if (L <> CurrentPos) then DataSet.MoveBy(L - CurrentPos);
          if not Unique then begin
            while (L < DataSet.RecordCount) and
              (UpStr(Value) <> GetCurrentStr) do
            begin
              Inc(L);
              DataSet.MoveBy(1);
            end;
          end;
          CurrentPos := L;
        end;
      end
      else Result := True;
    finally
      if not Result then DataSet.GotoBookmark(Bookmark);
      DataSet.FreeBookmark(Bookmark);
      DataSet.EnableControls;
    end;
  end
  else begin
    try
      DbiError(DBIERR_INVALIDFLDTYPE);
    except
      raise;
    end;
  end;
end;

{ Database Login routine }

function LoginToDatabase(Database: TDatabase; OnLogin: TLoginEvent): Boolean;
var
  EndLogin: Boolean;
begin
  Result := Database.Connected;
  if Result then Exit;
  Database.OnLogin := OnLogin;
  repeat
    try
      EndLogin := True;
      Database.Connected := True;
    except
      on E: EDbEngineError do begin
        EndLogin := (MessageDlg(E.Message + '. ' + GetExtStr(SRetryLogin),
          mtConfirmation, [mbYes, mbNo], 0) <> mrYes);
      end;
      on E: EDatabaseError do begin
        { User select "Cancel" in login dialog }
        MessageDlg(E.Message, mtError, [mbOk], 0);
      end;
      else raise;
    end;
  until EndLogin;
  Result := Database.Connected;
end;

procedure InitRSRUN(Database: TDatabase; const ConName: string;
  ConType: Integer; const ConServer: string);
const
  IniFileName = 'RPTSMITH.CON';
  scConNames = 'ConnectNamesSection';
  idConNames = 'ConnectNames';
  idType = 'Type';
  idServer = 'Server';
  idSQLDataFilePath = 'Database';
  idDataFilePath = 'DataFilePath';
  idSQLUserid = 'USERID';
var
  ParamList: TStringList;
  DBPath: string[127];
  TempStr, AppConName: string[127];
  UserName: string[30];
  ExeName: string[12];
  IniFile: TIniFile;
begin
  ParamList := TStringList.Create;
  try
    Session.GetAliasParams(Database.AliasName, ParamList);
    if Database.IsSQLBased then
      DBPath := ParamList.Values['SERVER NAME']
    else
      DBPath := ParamList.Values['PATH'];
    UserName := ParamList.Values['USER NAME'];
  finally
    ParamList.Free;
  end;

  AppConName := ConName;
  if AppConName = '' then begin
    ExeName := ExtractFileName(Application.ExeName);
    AppConName := Copy(ExeName, 1, Pos('.', ExeName) - 1);
  end;

  IniFile := TIniFile.Create(IniFileName);
  try
    TempStr := IniFile.ReadString(scConNames, idConNames, '');
    if Pos(AppConName, TempStr) = 0 then begin
      if TempStr <> '' then TempStr := TempStr + ',';
      IniFile.WriteString(scConNames, idConNames, TempStr + AppConName);
    end;
    IniFile.WriteInteger(AppConName, idType, ConType);
    IniFile.WriteString(AppConName, idServer, ConServer);
    if Database.IsSQLBased then begin
      IniFile.WriteString(AppConName, idSQLDataFilePath, DBPath);
      IniFile.WriteString(AppConName, idSQLUserid, UserName);
    end
    else begin
      IniFile.WriteString(AppConName, idDataFilePath, DBPath);
    end;
  finally
    IniFile.Free;
  end;
end;

end.