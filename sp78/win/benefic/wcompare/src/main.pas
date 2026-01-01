unit Main;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Menus, Child, About, StdCtrls, ExtCtrls, IniFiles;

type
  TFrameForm = class(TForm)
    MainMenu1: TMainMenu;
    New1: TMenuItem;
    Open1: TMenuItem;
    N1: TMenuItem;
    Exit1: TMenuItem;
    New2: TMenuItem;
    OpenFileDialog: TOpenDialog;
    Help1: TMenuItem;
    Contents1: TMenuItem;
    N2: TMenuItem;
    About1: TMenuItem;
    procedure NewChild(Sender: TObject);
    procedure Tile1Click(Sender: TObject);
    procedure Cascade1Click(Sender: TObject);
    procedure OpenChild(Sender: TObject);
    procedure MainSetup(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure Contents1Click(Sender: TObject);
    procedure SetWindows;
  private
    { Private declarations }
  public
    { Public declarations }
    SyncReach: word;
    MatchReach: word;
    WinOption: word;
  end;

var
  FrameForm: TFrameForm;

implementation

{$R *.DFM}

procedure TFrameForm.NewChild(Sender: TObject);
var
  EditForm: TEditForm;
begin
  EditForm:= TEditForm.Create(Self);
  EditForm.Memo1.Text:= '';
  EditForm.Caption:= 'Untitled';
  SetWindows;
end;

procedure TFrameForm.Tile1Click(Sender: TObject);
begin
  Tile;
end;

procedure TFrameForm.Cascade1Click(Sender: TObject);
begin
  Cascade;
end;

procedure TFrameForm.OpenChild(Sender: TObject);
var
  F: file;
  FileS: longint;
  EditForm: TEditForm;
begin
  if OpenFileDialog.Execute then
  begin
    AssignFile(F, OpenFileDialog.Filename);
    FileS:= -1;
    {$I-} Reset(F, 1); FileS:= FileSize(F); CloseFile(F); {$I+}
     if  FileS > ((32 * 1024) - 1) then
    begin
      messagedlg('Maximum file size is 32K.', mtinformation, [mbok], 0);
      exit;
    end;

    if FileS = 0 then
    begin
      messagedlg('Can'#39't open ' + OpenFileDialog.Filename, mtinformation, [mbok], 0);
      exit;
    end;

    EditForm:= TEditForm.Create(Self);
    EditForm.Open(OpenFileDialog.Filename);
    OpenFileDialog.HistoryList.Add(OpenFileDialog.Filename);
    SetWindows;
  end;
end;

procedure TFrameForm.MainSetup(Sender: TObject);
var
  WinIni: TIniFile;
  TempString: string;
  code: integer;
begin
 	FrameForm.Width:= GetSystemMetrics (SM_CXSCREEN);
  FrameForm.Height:= GetSystemMetrics (SM_CYSCREEN);

  WinIni:= TIniFile.Create('WCOMPARE.INI');
  With TIniFile.Create('WCOMPARE.INI') Do
    try
      SyncReach:= ReadInteger('WCOMPARE', 'SyncReach', 400);
      MatchReach:= ReadInteger('WCOMPARE', 'MatchReach', 10);
      WinOption:= ReadInteger('WCOMPARE', 'WindowOption', 0);
    finally
      Free;
    end;
end;

procedure TFrameForm.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TFrameForm.About1Click(Sender: TObject);
begin
  AboutBox.ShowModal;
end;

procedure TFrameForm.Contents1Click(Sender: TObject);
begin
  Application.HelpCommand(HELP_CONTENTS,0);
end;

procedure TFrameForm.SetWindows;
begin
  if WinOption = 0 then Tile;
  if WinOption = 1 then Cascade;
end;

end.
