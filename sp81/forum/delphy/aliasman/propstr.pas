unit PropStr;

{ Property String List }

{ Copyright (c) 1995 Mark E. Edington }

interface

uses Classes, SysUtils;

type

{ TPropStringList }

  TPropStringList = class(TStringList)
  private
    PropIndex: Integer;
    FPropList: TList;
  protected
    function GetValue(const APropName: String): String;
    procedure SetValue(const APropName, AValue: String);
    function GetPropName(Index: Integer): String;
  public
    constructor Create;
    destructor Destroy; override;
    function IndexOfProp(const APropName: String): Integer;
    procedure Assign(Source: TPersistent); override;
    function Add(const S: string): Integer; override;
    procedure Insert(Index: Integer; const S: string); override;
    procedure Delete(Index: Integer); override;
    procedure Clear; override;
    procedure Sort; override;
    procedure LoadFromIniFile(const FileName, Section: String);
    property PropName[Index: Integer]: String read GetPropName;
    property Value[const APropName: String]: String read GetValue write SetValue;
  end;

implementation


Uses IniFiles;

{ TPropStringList }

constructor TPropStringList.Create;
begin
  inherited Create;
  FPropList := TList.Create;
end;

destructor TPropStringList.Destroy;
begin
  if FPropList <> nil then
  begin
    Clear;
    FPropList.Destroy;
  end;
  inherited Destroy;
end;


procedure TPropStringList.Assign(Source: TPersistent);
var
  I: Integer;
begin
  if Source is TPropStringList then
  begin
    BeginUpdate;
    try
      Clear;
      for I := 0 to TPropStringList(Source).Count - 1 do
      begin
        Value[TPropStringList(Source).PropName[I]] := TPropStringList(Source).Strings[I];
        Objects[I] := TPropStringList(Source).Objects[I];
      end;
    finally
      EndUpdate;
    end;
    Exit;
  end;
  inherited Assign(Source);
end;

function TPropStringList.Add(const S: string): Integer;
begin
  Result := inherited Add(S);
  FPropList.Expand.Insert(Result, nil);
end;

procedure TPropStringList.Insert(Index: Integer; const S: string);
begin
  inherited Insert(Index, S);
  FPropList.Expand.Insert(Index, nil);
end;

procedure TPropStringList.Delete(Index: Integer);
begin
  inherited Delete(Index);
  DisposeStr(FPropList[Index]);
  FPropList.Delete(Index);
end;

procedure TPropStringList.Clear;
var
  I: Integer;
begin
  inherited Clear;
  for I := 0 to FPropList.Count - 1 do DisposeStr(FPropList[I]);
  FPropList.Clear;
end;

procedure TPropStringList.Sort;
begin
  raise EStringListError.Create('Cannot sort a TPropStringList');
end;

function TPropStringList.GetValue(const APropName: String): String;
begin
  PropIndex := IndexOfProp(APropName);
  if PropIndex >= 0 then
    Result := Strings[PropIndex]
  else
    Result := '';
end;

procedure TPropStringList.SetValue(const APropName, AValue: String);
var
  NewIndex: Integer;
begin
  PropIndex := IndexOfProp(APropName);
  if PropIndex >= 0 then
    Strings[PropIndex] := AValue
  else
  begin
    NewIndex := Add(AValue);
    FPropList.Insert(NewIndex, NewStr(APropName));
  end;
end;

function TPropStringList.IndexOfProp(const APropName: String): Integer;
begin
  if APropName <> '' then
    for Result := 0 to GetCount - 1 do
      if (PropName[Result] <> '') and
         (CompareText(PropName[Result], APropName) = 0) then Exit;
  Result := -1;
end;

function TPropStringList.GetPropName(Index: Integer): String;
begin
  if FPropList[Index] = nil then
    Result := ''
  else
    Result := PString(FPropList[Index])^;
end;

procedure TPropStringList.LoadFromIniFile(const FileName, Section: String);
var
  I: Integer;
  IniFile: TIniFile;
  KeyList: TStringList;
begin
  IniFile := TIniFile.Create(FileName);
  try
    KeyList := TStringList.Create;
    try
      IniFile.ReadSection(Section, KeyList);
      for I := 0 to KeyList.Count-1 do
        Self.Value[KeyList[I]] := IniFile.ReadString(Section, KeyList[I], '');
    finally
      KeyList.Destroy;
    end;
  finally
    IniFile.Destroy;
  end;
end;

end.
