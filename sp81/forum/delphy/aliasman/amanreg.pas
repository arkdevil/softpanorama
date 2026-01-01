unit Amanreg;

{ Alias Manager Component Registration }

{ Copyright (c) 1995 Mark E. Edington }

interface

uses Classes, DsgnIntf;

{ Edit this constant to change where TAliasManager gets installed }

const
  DefaultPage = 'Data Access';

procedure Register;

implementation

uses AliasMan, AManEdit;

{ TAliasEditor }

type
  TAliasEditor = class(TComponentEditor)
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
  end;

procedure TAliasEditor.ExecuteVerb(Index: Integer);
begin
  EditAliases(TAliasManager(Component));
end;

function TAliasEditor.GetVerb(Index: Integer): string;
begin
  Result := '&Edit Aliases';
end;

function TAliasEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;

{ Registration }

procedure Register;
begin
  RegisterComponents(DefaultPage, [TAliasManager]);
  RegisterComponentEditor(TAliasManager, TAliasEditor);
end;

end.
