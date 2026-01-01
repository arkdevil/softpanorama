{*******************************************************}
{                                                       }
{         Borland Delphi Unit                           }
{                                                       }
{         Copyright (c) 1995 OKO ROSNO                  }
{                                                       }
{*******************************************************}
unit DBLists;

{$N+,P+,S-}

interface

uses SysUtils, WinTypes, WinProcs, DbiTypes, DbiProcs, Classes, DB;

type

{ TDatabaseList }

  TDatabaseList = class(TDataSet)
  protected
    function CreateHandle: HDBICur; override;
  end;

{ TLangDrivList }

  TLangDrivList = class(TDataSet)
  protected
    function CreateHandle: HDBICur; override;
  end;

{ TTableList }

  TTableList = class(TDBDataSet)
  private
    FExtended: Boolean;
    FSystemTables: Boolean;
  protected
    function CreateHandle: HDBICur; override;
  published
    property ExtendedInfo: Boolean read FExtended write FExtended;
    property SystemTables: Boolean read FSystemTables write FSystemTables;
  end;

{ TStoredProcList }

  TStoredProcList = class(TDBDataSet)
  private
    FExtended: Boolean;
    FSystemProcs: Boolean;
  protected
    function CreateHandle: HDBICur; override;
  published
    property ExtendedInfo: Boolean read FExtended write FExtended;
    property SystemProcs: Boolean read FSystemProcs write FSystemProcs;
  end;

{ TTableItems }

  TTableItems = class(TDBDataSet)
  private
    FTableName: TFileName;
  published
    property TableName: TFileName read FTableName write FTableName;
  end;

{ TFieldList }

  TFieldList = class(TTableItems)
  protected
    function CreateHandle: HDBICur; override;
  end;

{ TIndexList }

  TIndexList = class(TTableItems)
  protected
    function CreateHandle: HDBICur; override;
  end;

{ TDatabaseDesc }

  TDatabaseDesc = class(TObject)
  private
    FDescription: DBDesc;
  public
    property Description: DBDesc read FDescription;
    constructor Create(DataBaseName: string);
  end;

{ TDriverDesc }

  TDriverDesc = class(TObject)
  private
    FDescription: DRVType;
  public
    property Description: DRVType read FDescription;
    constructor Create(DriverType: string);
  end;

{ Designer registration }

procedure Register;

implementation

uses DbiErrs, Forms, DBConsts, ExtConst;

{ TDatabaseList }

function TDatabaseList.CreateHandle: HDBICur;
begin
  Check(DbiOpenDatabaseList(Result));
end;

{ TLangDrivList }

function TLangDrivList.CreateHandle: HDBICur;
begin
  Check(DbiOpenLdList(Result));
end;

{ TTableList }

function TTableList.CreateHandle: HDBICur;
begin
  Check(DbiOpenTableList(DBHandle, ExtendedInfo, SystemTables, nil, Result));
end;

{ TStoredProcList }

function TStoredProcList.CreateHandle: HDBICur;
begin
  if DataBase.IsSQLBased then
    Check(DbiOpenSPList(DBHandle, ExtendedInfo, SystemProcs, nil, Result))
  else
    DatabaseError(GetExtStr(SLocalDatabase));
end;

{ TFieldList }

function TFieldList.CreateHandle: HDBICur;
var
  STableName: array[0..SizeOf(TFileName) - 1] of Char;
begin
  Check(DbiOpenFieldList(DBHandle, AnsiToNative(DBLocale, FTableName,
    STableName, SizeOf(STableName) - 1), nil, False, Result));
end;

{ TIndexList }

function TIndexList.CreateHandle: HDBICur;
var
  STableName: array[0..SizeOf(TFileName) - 1] of Char;
begin
  Check(DbiOpenIndexList(DBHandle, AnsiToNative(DBLocale, FTableName,
    STableName, SizeOf(STableName) - 1), nil, Result));
end;

{ TDatabaseDesc }

constructor TDatabaseDesc.Create(DataBaseName: String);
var
  Buffer: PChar;
  BufLen: Word;
begin
  BufLen := Length(DatabaseName) + 1;
  Buffer := AllocMem(BufLen);
  try
    StrPCopy(Buffer, DatabaseName);
    Check(DbiGetDatabaseDesc(Buffer, @FDescription));
  finally
    FreeMem(Buffer, BufLen);
  end;
end;

{ TDriverDesc }

constructor TDriverDesc.Create(DriverType: String);
var
  Buffer: PChar;
  BufLen: Word;
begin
  BufLen := Length(DriverType) + 1;
  Buffer := AllocMem(BufLen);
  try
    StrPCopy(Buffer, DriverType);
    Check(DbiGetDriverDesc(Buffer, FDescription));
  finally
    FreeMem(Buffer, BufLen);
  end;
end;

{ Designer registration }

procedure Register;
begin
  RegisterComponents(GetExtStr(srDBExt), [TDatabaseList, TLangDrivList,
    TTableList, TStoredProcList, TFieldList, TIndexList]);
end;

end.
