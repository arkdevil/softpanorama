{*******************************************************}
{                                                       }
{         Borland Delphi Unit                           }
{                                                       }
{         Copyright (c) 1995 OKO ROSNO                  }
{                                                       }
{*******************************************************}
{$D-,L-,S-}

unit DBExtReg;

interface

uses Classes, DsgnIntf;

procedure Register;

implementation

uses DB, Controls, SysUtils, DBDict, DBExtCtl, TypInfo, 
  DBConsts, LibConst, ExtConst;

{ TDictFieldProperty }

type
  TDictFieldProperty = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValueList(List: TStrings); virtual;
    procedure GetValues(Proc: TGetStrProc); override;
    function GetDataSourcePropName: string; virtual;
  end;

function TDictFieldProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paValueList, paSortList, paMultiSelect];
end;

procedure TDictFieldProperty.GetValues(Proc: TGetStrProc);
var
  I: Integer;
  Values: TStringList;
begin
  Values := TStringList.Create;
  try
    GetValueList(Values);
    for I := 0 to Values.Count - 1 do Proc(Values[I]);
  finally
    Values.Free;
  end;
end;

function TDictFieldProperty.GetDataSourcePropName: string;
begin
  Result := 'LookupSource';
end;

procedure TDictFieldProperty.GetValueList(List: TStrings);
var
  Instance: TComponent;
  PropInfo: PPropInfo;
  DataSource: TDataSource;
begin
  Instance := GetComponent(0);
  PropInfo := TypInfo.GetPropInfo(Instance.ClassInfo, GetDataSourcePropName);
  if (PropInfo <> nil) and (PropInfo^.PropType^.Kind = tkClass) then
  begin
    DataSource := TObject(GetOrdProp(Instance, PropInfo)) as TDataSource;
    if (DataSource <> nil) and (DataSource.DataSet <> nil) then
      DataSource.DataSet.GetFieldNames(List);
  end;
end;

{ Designer registration }

procedure Register;
begin
  RegisterComponents(GetExtStr(srDBExt), [TDBGlyphGrid, TDBDateEdit]);
  RegisterComponents(GetExtStr(srDBExt), [TDBDictList, TDBDictCombo]);
  RegisterPropertyEditor(TypeInfo(string), TDBDictCombo, 'LookupField',
    TDictFieldProperty);
  RegisterPropertyEditor(TypeInfo(string), TDBDictList, 'LookupField',
    TDictFieldProperty);
  RegisterPropertyEditor(TypeInfo(string), TDBDictCombo, 'SortedField',
    TDictFieldProperty);
  RegisterPropertyEditor(TypeInfo(string), TDBDictList, 'SortedField',
    TDictFieldProperty);
end;

end.