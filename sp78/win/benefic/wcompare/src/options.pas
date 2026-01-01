unit Options;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Spin, Buttons, ExtCtrls;

type
  TOptionsDlg = class(TForm)
    Sync: TSpinEdit;
    Sensitivity: TSpinEdit;
    OKButton: TBitBtn;
    CancelBtn: TBitBtn;
    SaveOptions: TButton;
    DefaultBtn: TButton;
    WindowOption: TRadioGroup;
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    procedure CurrentValue(Sender: TObject);
    procedure SetValue(Sender: TObject);
    procedure SaveValues(Sender: TObject);
    procedure DefaultBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OptionsDlg: TOptionsDlg;

implementation

uses Main, Child;

{$R *.DFM}

procedure TOptionsDlg.CurrentValue(Sender: TObject);
begin
  Sensitivity.Value:= FrameForm.MatchReach;
  Sync.Value:= FrameForm.SyncReach;
  OptionsDlg.ActiveControl:= Sync;
  Sync.SelectAll;
  WindowOption.ItemIndex:= FrameForm.WinOption;
end;

procedure TOptionsDlg.SetValue(Sender: TObject);
begin
  with FrameForm do
  begin
    SyncReach:= Sync.Value;
    MatchReach:= Sensitivity.Value;
    WinOption:= WindowOption.ItemIndex;
    SetWindows;
  end;
end;

procedure TOptionsDlg.SaveValues(Sender: TObject);
begin
  SetValue(Sender);
  EditForm.SaveOptions1Click(Sender);
end;

procedure TOptionsDlg.DefaultBtnClick(Sender: TObject);
begin
  Sync.Value:= 400;
  Sensitivity.Value:= 10;
  WindowOption.ItemIndex:= 0;
  FrameForm.SetWindows;
end;

end.
