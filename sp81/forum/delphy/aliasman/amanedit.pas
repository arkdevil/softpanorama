unit Amanedit;

{ Alias Property Editor Form }

{ Copyright (c) 1995 Mark E. Edington }

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, StdCtrls,
     PropStr, SysUtils, DbiProcs, DB, ExtCtrls, Grids, Buttons, AliasMan;


const

{ String Constants }

  SDuplicateName = 'Duplicate alias name';
  SDeleteConfirm = 'OK to delete "%s" alias?';
  SSaveConfirm   = 'Save Changes?';
  SConnOK        = 'Connection Successful';

type

{ TAliasEditorForm }

  TAliasEditorForm = class(TForm)
    NewButton: TButton;
    ConnectButton: TButton;
    OKButton: TBitBtn;
    CloseButton: TBitBtn;
    AliasLabel: TLabel;
    ParamLabel: TLabel;
    ListPanel: TPanel;
    SaveConfig: TCheckBox;
    AliasListBox: TListBox;
    AliasDataGrid: TStringGrid;
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure AliasListBoxClick(Sender: TObject);
    procedure NewButtonClick(Sender: TObject);
    procedure DeleteButtonClick(Sender: TObject);
    procedure FileSave(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ConnectButtonClick(Sender: TObject);
    procedure AliasDataGridSelectCell(Sender: TObject; Col, Row: Longint;
      var CanSelect: Boolean);
    procedure AliasDataGridKeyPress(Sender: TObject; var Key: Char);
    procedure CloseButtonClick(Sender: TObject);
    procedure AliasDataGridEnter(Sender: TObject);
  private
    FileChanged: Bool;
    AliasChanged: Bool;
    AliasChgName: String;
    AliasList: TStringList;
    AliasManager: TAliasManager;
    function Edit: Boolean;
    procedure CheckChanges;
    procedure UpdateAliasData;
    procedure RefreshAliasListBox(RefreshData: Boolean);
    procedure RefreshDataDisplay;
    procedure WriteAliasChanges;
  end;

function EditAliases(TheAliasManager: TAliasManager): Boolean;

implementation

{$R *.DFM}

uses Dialogs, NewDlg, DbiTypes;

function EditAliases(TheAliasManager: TAliasManager): Boolean;
begin
  with TAliasEditorForm.Create(Application) do
  try
    AliasManager := TheAliasManager;
    Result := Edit;
  finally
    Free;
  end;
end;

{ TAliasManagerForm }

function TAliasEditorForm.Edit: Boolean;
begin
  Result := ShowModal = mrOK;
end;

procedure TAliasEditorForm.FormShow(Sender: TObject);
begin
  { If the AliasManager was not instansiated for us, let's do it ourselves }
  if not Assigned(AliasManager) then AliasManager := TAliasManager.Create(Self);
  NewAliasDialog := TNewAliasDialog.Create(Application);
  AliasList := TStringList.Create;
  AliasManager.GetAliasList(AliasList, True);
  RefreshAliasListBox(True);
  AliasManager.GetDriverList(NewAliasDialog.DriverList.Items);
  NewAliasDialog.DriverList.ItemIndex := 0;
  AliasDataGrid.DefaultColWidth := AliasDataGrid.ClientWidth div 2 - 1;
  AliasDataGrid.Col := 1;
end;

procedure TAliasEditorForm.FormHide(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to AliasList.Count-1 do
    AliasList.Objects[I].Free;
  AliasList.Free;
end;

procedure TAliasEditorForm.CheckChanges;
begin
  if AliasChanged then UpdateAliasData;
end;

procedure TAliasEditorForm.UpdateAliasData;
var
  I: Integer;
  AliasData: TAliasData;
begin
  if not AliasChanged then Exit;
  with AliasListBox.Items do
    AliasData := TAliasData(Objects[IndexOf(AliasChgName)]);
  with AliasDataGrid, AliasData do
    for I := 0 to Count-1 do
      Strings[I] := Cells[1, I];
  if AliasData.ChangeFlag <> cfAdd then AliasData.ChangeFlag := cfEdit;
  AliasChanged := False;
end;

procedure TAliasEditorForm.RefreshAliasListBox(RefreshData: Boolean);
var
  I: Integer;
  IndexSave: Integer;
begin
  IndexSave := AliasListBox.ItemIndex;
  AliasListBox.Clear;
  for I := 0 to AliasList.Count-1 do
    if TAliasData(AliasList.Objects[I]).ChangeFlag <> cfDelete then
      AliasListBox.Items.AddObject(AliasList[I], AliasList.Objects[I]);
  if RefreshData then
  begin
    with AliasListBox do
    if Items.Count > 0 then
    begin
      if IndexSave < 0 then
        ItemIndex := 0
      else if IndexSave >= Items.Count then
        ItemIndex := Items.Count-1
      else
        ItemIndex := IndexSave;
    end;
    RefreshDataDisplay;
  end;
end;

procedure TAliasEditorForm.RefreshDataDisplay;
var
  I: Integer;
  AliasData: TAliasData;
begin
  if AliasListBox.ItemIndex < 0 then
    AliasDataGrid.RowCount := 0
  else
  begin
    CheckChanges;
    AliasData := TAliasData(AliasListBox.Items.Objects[AliasListBox.ItemIndex]);
    with AliasDataGrid, AliasData do
    begin
      Row := 0;
      RowCount := Count;
      for I := 0 to Count-1 do
      begin
        Cells[0, I] := PropName[I];
        Cells[1, I] := Strings[I];
      end;
    end;
  end;
end;

procedure TAliasEditorForm.AliasListBoxClick(Sender: TObject);
begin
  RefreshDataDisplay;
end;

procedure TAliasEditorForm.NewButtonClick(Sender: TObject);
var
  AliasData: TAliasData;
  ExistingAlias: Integer;
begin
  if NewAliasDialog.ShowModal = mrOK then
  with AliasManager, NewAliasDialog do
  begin
    AliasData := TAliasData.Create;
    try
      with AliasListBox do
      { Use settings from the currently highlighted entry if the driver type is the same as
         the one we are adding.  Except for the path, leave that blank }
       if (Items.Count > 0) and (TAliasData(Items.Objects[ItemIndex]).Value[SType] = DriverList.Text) then
       begin
         AliasData.Assign(TAliasData(Items.Objects[ItemIndex]));
         AliasData.Value[SPath] := '';
       end
       else
         GetDriverData(DriverList.Text, AliasData);
      AliasData.ChangeFlag := cfAdd;
      AliasName.Text := AnsiUpperCase(AliasName.Text); 
      ExistingAlias := AliasList.IndexOf(AliasName.Text);
      if  ExistingAlias >= 0 then
      begin
        { Special Case, alias deleted, then new one created with the same name }
        if TAliasData(AliasList.Objects[ExistingAlias]).ChangeFlag = cfDelete then
        begin
          AliasList.Objects[ExistingAlias].Free;
          AliasData.ChangeFlag := cfEdit;
          AliasList.Objects[ExistingAlias] := AliasData;
        end
        else
          raise Exception.Create(SDuplicateName);
      end
      else
        AliasList.AddObject(AliasName.Text, AliasData);
    except
      AliasData.Free;
      raise;
    end;
    RefreshAliasListBox(False);
    AliasListBox.ItemIndex := AliasListBox.Items.IndexOf(AliasName.Text);
    RefreshDataDisplay;
    FileChanged := True;
    AliasDataGrid.SetFocus;
  end;
end;

procedure TAliasEditorForm.DeleteButtonClick(Sender: TObject);
var
  AliasName: String;
  DelIndex: Integer;
begin
  with AliasListBox do AliasName := Items[ItemIndex];
  if MessageDlg(Format(SDeleteConfirm, [AliasName]), mtConfirmation, mbYesNoCancel, 0) = idYes then
  begin
    FileChanged := True;
    DelIndex := AliasList.IndexOf(AliasListBox.Items[AliasListBox.ItemIndex]);
    TAliasData(AliasList.Objects[DelIndex]).ChangeFlag := cfDelete;
    RefreshAliasListBox(True);
    if AliasListBox.Items.Count > 0 then
      AliasListBox.SetFocus;
  end;
end;

procedure TAliasEditorForm.ConnectButtonClick(Sender: TObject);
var
  NameBuf: DbiName;
  hDB: HDBiDB;
begin
  StrPCopy(NameBuf, AliasListBox.Items[AliasListBox.ItemIndex]);
  Check(DbiOpenDatabase(NameBuf, nil, dbiREADWRITE, dbiOPENSHARED,
                              nil, 0, nil, nil, hDb ));
  DBiCloseDatabase(hDB);
  ShowMessage(SConnOK);
end;

procedure TAliasEditorForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  Response: Integer;
begin
  if FileChanged then
  begin
    Response := MessageDlg(SSaveConfirm, mtConfirmation, mbYesNoCancel, 0);
    if Response = idYes then
      FileSave(Sender)
    else
      CanClose := Response <> idCancel;
  end;
end;

procedure TAliasEditorForm.AliasDataGridSelectCell(Sender: TObject; Col,
  Row: Longint; var CanSelect: Boolean);
begin
  if Col = 0 then CanSelect := False;
end;

procedure TAliasEditorForm.AliasDataGridKeyPress(Sender: TObject; var Key: Char);
begin
  if not AliasChanged and (AliasListBox.Items.Count > 0) then
  begin
    AliasChgName := AliasListBox.Items[AliasListBox.ItemIndex];
    AliasChanged := True;
    FileChanged := True;
  end;
end;

procedure TAliasEditorForm.WriteAliasChanges;
var
  I: Integer;
  AliasData: TAliasData;
begin
  { First do the deleted ones }
  for I := 0 to AliasList.Count-1 do
  begin
    AliasData := TAliasData(AliasList.Objects[I]);
    if AliasData.ChangeFlag = cfDelete then
       AliasManager.DeleteAlias(AliasList[I]);
  end;
  { Now do the new ones and the edits }
  for I := 0 to AliasListBox.Items.Count-1 do
  begin
    AliasData := TAliasData(AliasListBox.Items.Objects[I]);
    with AliasManager, AliasListBox do
    case AliasData.ChangeFlag of
      cfEdit: ModifyAlias(Items[I], AliasData);
       cfAdd: AddAlias(Items[I], AliasData);
    end;
  end;
end;

procedure TAliasEditorForm.FileSave(Sender: TObject);
begin
  CheckChanges;
  if FileChanged then
  begin
    WriteAliasChanges;
    if SaveConfig.Checked then AliasManager.Save;
    FileChanged := False;
  end;
  Close;
end;

procedure TAliasEditorForm.CloseButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TAliasEditorForm.AliasDataGridEnter(Sender: TObject);
begin
  if AliasListBox.Items.Count < 1 then NewButton.SetFocus;
end;

end.
