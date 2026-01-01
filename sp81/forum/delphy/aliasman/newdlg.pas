unit Newdlg;

{ New Alias Dialog}

{ Copyright (c) 1995 Mark E. Edington }

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, StdCtrls,
  ExtCtrls;

type
  TNewAliasDialog = class(TForm)
    AliasName: TEdit;
    DriverList: TComboBox;
    Panel1: TPanel;
    NewAliasLabel: TLabel;
    OKButton: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  end;

var
  NewAliasDialog: TNewAliasDialog;

implementation

{$R *.DFM}

uses AliasMan;

procedure TNewAliasDialog.FormShow(Sender: TObject);
begin
  AliasName.Text := '';
  AliasName.SetFocus;
end;

procedure TNewAliasDialog.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if ModalResult = mrOK then
  try
    CheckAliasName(AliasName.Text);
  except
    CanClose := False;
    AliasName.SetFocus;
    raise;
  end;
end;

end.
