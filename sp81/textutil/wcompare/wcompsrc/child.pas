unit Child;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Menus, StdCtrls, Clipbrd, Printers, Options, IniFiles;

type
  TEditForm = class(TForm)
    MainMenu1: TMainMenu;
    Edit1: TMenuItem;
    Cut1: TMenuItem;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    Delete1: TMenuItem;
    N3: TMenuItem;
    SelectAll1: TMenuItem;
    Character1: TMenuItem;
    Left1: TMenuItem;
    Right1: TMenuItem;
    Center1: TMenuItem;
    N4: TMenuItem;
    WordWrap1: TMenuItem;
    N5: TMenuItem;
    Font1: TMenuItem;
    PopupMenu1: TPopupMenu;
    Cut2: TMenuItem;
    Copy2: TMenuItem;
    Paste2: TMenuItem;
    SaveFileDialog: TSaveDialog;
    Memo1: TMemo;
    FontDialog1: TFontDialog;
    PrintDialog1: TPrintDialog;
    PrinterSetupDialog1: TPrinterSetupDialog;
    File1: TMenuItem;
    Exit1: TMenuItem;
    N6: TMenuItem;
    PrintSetup1: TMenuItem;
    Print1: TMenuItem;
    N7: TMenuItem;
    SaveAs1: TMenuItem;
    Save1: TMenuItem;
    N8: TMenuItem;
    Close1: TMenuItem;
    Open1: TMenuItem;
    New1: TMenuItem;
    Compare1: TMenuItem;
    Window1: TMenuItem;
    Cascade1: TMenuItem;
    Tile1: TMenuItem;
    Delete2: TMenuItem;
    Compare2: TMenuItem;
    SetOptions1: TMenuItem;
    procedure New1Click(Sender: TObject);
    procedure AlignClick(Sender: TObject);
    procedure SetWordWrap(Sender: TObject);
    procedure SelectAll(Sender: TObject);
    procedure CutToClipboard(Sender: TObject);
    procedure CopyToClipboard(Sender: TObject);
    procedure PasteFromClipboard(Sender: TObject);
    procedure Delete(Sender: TObject);
    procedure SetEditItems(Sender: TObject);
    procedure SetPopUpItems(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure Open(const AFilename: string);
    procedure SaveAs1Click(Sender: TObject);
    procedure Save1Click(Sender: TObject);
    procedure SetFont(Sender: TObject);
    procedure PrintSetup1Click(Sender: TObject);
    procedure Print1Click(Sender: TObject);
    procedure Close1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Exit1Click(Sender: TObject);
    procedure Compare(Sender: TObject);
    procedure Options(Sender: TObject);
    procedure Cascade1Click(Sender: TObject);
    procedure Tile1Click(Sender: TObject);
    procedure SaveOptions1Click(Sender: TObject);
  private
    Filename: string;
    procedure UpdateMenus;
  public
    destructor Destroy; override;
    { Public declarations }
  end;

var
  EditForm: TEditForm;

implementation

uses
  Main;

{$R *.DFM}

const
  BackupExt = '.BAK';
  SWarningText = 'Save Changes to "%s"?';

procedure TEditForm.New1Click(Sender: TObject);
begin
  FrameForm.NewChild(Sender);
end;

procedure TEditForm.AlignClick(Sender: TObject);
begin
  Left1.Checked:= false;
  Right1.Checked:= false;
  Center1.Checked:=  false;
  with Sender as TMenuItem do
  begin
    Checked:= true;
    Memo1.Alignment:= TAlignment(Tag);
  end;
end;

procedure TEditForm.SetWordWrap(Sender: TObject);
begin
  with Memo1 do
    begin
      WordWrap:= not WordWrap;
      if WordWrap then
        ScrollBars:= ssVertical else
        ScrollBars:= ssBoth;
      WordWrap1.Checked:= WordWrap;
    end;
end;

procedure TEditForm.SelectAll(Sender: TObject);
begin
  Memo1.SelectAll;
end;

procedure TEditForm.CutToClipboard(Sender: TObject);
begin
  Memo1.CutToClipboard;
end;

procedure TEditForm.CopyToClipboard(Sender: TObject);
begin
  Memo1.CopyToClipboard;
end;

procedure TEditForm.PasteFromClipboard(Sender: TObject);
begin
  Memo1.PasteFromClipboard;
end;

procedure TEditForm.Delete(Sender: TObject);
begin
  Memo1.ClearSelection;
end;

procedure TEditForm.UpdateMenus;
var
  HasSelection: boolean;
begin
  Paste1.Enabled:= Clipboard.HasFormat(CF_TEXT);
  Paste2.Enabled:= Clipboard.HasFormat(CF_TEXT);
  HasSelection:= Memo1.SelLength <> 0;
  Cut1.Enabled:= HasSelection;
  Cut2.Enabled:= HasSelection;
  Copy1.Enabled:= HasSelection;
  Copy2.Enabled:= HasSelection;
  Delete1.Enabled:= HasSelection;
  Delete2.Enabled:= HasSelection;
end;

procedure TEditForm.SetEditItems(Sender: TObject);
begin
  UpdateMenus;
end;

procedure TEditForm.SetPopUpItems(Sender: TObject);
begin
  UpdateMenus;
end;

procedure TEditForm.Open1Click(Sender: TObject);
begin
  FrameForm.OpenChild(Sender);
end;

procedure TEditForm.Open(const AFilename: string);
begin
  Filename:= AFilename;
  Memo1.Text:= '';
  Memo1.Lines.LoadFromFile(Filename);
  Memo1.SelStart:= 0;
  Caption:= Filename;
  Memo1.Modified:= false;
end;

procedure TEditForm.SaveAs1Click(Sender: TObject);
begin
  SaveFileDialog.Filename:= Filename;
  if SaveFileDialog.Execute then
  begin
    Filename:= SaveFileDialog.Filename;
    Caption:= Filename;
    Save1Click(Sender);
  end;
end;

procedure TEditForm.Save1Click(Sender: TObject);
  procedure CreateBackup(const Filename: string);
  var
    BackupFilename: string;
  begin
    BackupFilename:= ChangeFileExt(Filename, BackupExt);
    DeleteFile(BackupFilename);
    RenameFile(Filename, BackupFilename);
  end;
begin
  if Filename = '' then
    SaveAs1Click(Sender)
  else
  begin
    CreateBackup(Filename);
    Memo1.Lines.SaveToFile(Filename);
    Memo1.Modified:= False;
  end;
end;

procedure TEditForm.SetFont(Sender: TObject);
begin
  FontDialog1.Font:= Memo1.Font;
  if FontDialog1.Execute then
  Memo1.Font:= FontDialog1.Font;
end;

procedure TEditForm.PrintSetup1Click(Sender: TObject);
begin
  PrinterSetupDialog1.Execute;
end;

procedure TEditForm.Print1Click(Sender: TObject);
var
  Line: integer;
  PrintText: System.Text;
begin
  if PrintDialog1.Execute then
  begin
    AssignPrn(PrintText);
    Rewrite(PrintText);
    Printer.Canvas.Font:= Memo1.Font;
    for Line:= 0 to Memo1.Lines.Count - 1 do
      Writeln(PrintText, Memo1.Lines[Line]);
    CloseFile(PrintText);
  end;
end;

procedure TEditForm.Close1Click(Sender: TObject);
begin
  Close;
end;

procedure TEditForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action:= caFree;
end;

procedure TEditForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  DialogValue: integer;
  FName: string;
begin
  if Memo1.Modified then
  begin
    Fname:= Caption;
    if length(FName) = 0 then
      FName:= 'Untitled';
    DialogValue:= MessageDlg(Format(SWarningText, [FName]), mtconfirmation,
      [mbYes, mbNo, mbCancel], 0);
    case DialogValue of
      id_Yes: Save1Click(Self);
      id_Cancel: CanClose:= false;
    end;
  end;
end;

procedure TEditForm.Exit1Click(Sender: TObject);
begin
  FrameForm.Exit1Click(Sender);
end;

procedure TEditForm.Options(Sender: TObject);
begin
  OptionsDlg.ShowModal;
end;

procedure TEditForm.Cascade1Click(Sender: TObject);
begin
  FrameForm.Cascade1Click(Sender);
end;

procedure TEditForm.Tile1Click(Sender: TObject);
begin
  FrameForm.Tile1Click(Sender);
end;

procedure TEditForm.Compare(Sender: TObject);
var
  EditForm1, EditForm2: TEditForm;
  EditBuf1, EditBuf2: PChar;
  Eof1, Eof2: integer;
  Size1, Size2: integer;
  TextStart1, TextStart2: integer;
  TextLength1, TextLength2: integer;
  LocalSyncReach, LocalMatchReach: word;
begin
  if FrameForm.MDICHildCount <> 2 then

  messagedlg('Two open files required for comparing.', mtinformation, [mbok], 0)

  else

  begin
    EditForm1:= FrameForm.MDIChildren[0] As TEditForm;
    with EditForm1.Memo1 do
    begin
      TextStart1:= SelStart + SelLength;
      Eof1:= GetTextLen;
      Size1:= GetTextLen;
      GetMem(EditBuf1, Eof1 + 1);
      GetTextBuf(EditBuf1, Eof1);
    end;
    EditForm2:=FrameForm.MDIChildren[1] As TEditForm;
    with EditForm2.Memo1 do
    begin
      TextStart2:= SelStart + SelLength;
      Eof2:= GetTextLen;
      Size2:= GetTextLen;
      GetMem(EditBuf2, Eof2 + 1);
      GetTextBuf(EditBuf2, Eof2);
    end;

    LocalSyncReach:= FrameForm.SyncReach;
    LocalMatchReach:= FrameForm.MatchReach;

    asm
      push  ds
      cld
      mov   ax,TextStart1
      mov   cx,TextStart2
      lds   si,EditBuf1
      les   di,EditBuf2
      add   Eof1,si
      add   si,ax
      add   Eof2,di
      add   di,cx

    @next_compare:
      cmp   si,Eof1
      jz    @mismatch2
      cmp   di,Eof2
      jz    @mismatch2
      mov   al,ds:[si]
      mov   ah,es:[di]
      cmpsb
      jz    @next_compare
      cmp   al,10   {linefeed}
      jnz   @ck_cr1
      dec   di
      jmp   @next_compare
    @ck_cr1:
      cmp   al,13   {carriage return}
      jnz   @second_file
      cmp   ah,32   {space}
      jz    @next_compare
      jmp   @mismatch

    @second_file:
      cmp   ah,10
      jnz   @ck_cr2
      dec   si
      jmp   @next_compare
    @ck_cr2:
      cmp   ah,13
      jnz   @mismatch
      cmp   al,32
      jz    @next_compare

    @mismatch:
      dec   si
      dec   di
    @mismatch2:
      mov   TextStart1,si
      mov   TextStart2,di

    @synchronize:
      mov   bx,TextStart1
      mov   cx,LocalSyncReach

    @next_sync:
      push  cx
      mov   dx,TextStart2
      mov   cx,LocalSyncReach

    @next_try:
      push  cx
      mov   cx,LocalMatchReach

      mov   si,bx
      mov   di,dx
    @next_char:
      cmp   si,Eof1
      jz    @next_try_end
      cmp   di,Eof2
      jz    @file2_end
      mov   al,ds:[si]
      mov   ah,es:[di]
      cmpsb
      jz    @possible_sync
      cmp   al,10   {linefeed}
      jz    @adjust_2b
      cmp   al,13   {carriage return}
      jz    @ck_adjust_2b
      cmp   ah,10
      jz    @adjust_1b
      cmp   ah,13
      jnz   @next_try_end

    @ck_adjust_1b:
      cmp   al,32   {space}
      jz    @next_char
    @adjust_1b:
      dec   si
      inc   dx      {adjust}
      jmp   @next_char

    @ck_adjust_2b:
      cmp   ah,32
      jz    @next_char
    @adjust_2b:
      dec   di
      inc   bx      {adjust}
      jmp   @next_char

    @possible_sync:
      cmp   al,32
      jz    @next_char
      loop  @next_char
      jmp   @evaluate

    @file2_end:
      pop   cx
      jmp   @next_sync_end

    @next_try_end:
      pop   cx
      cmp   dx,Eof2
      jz    @next_sync_end
      inc   dx
      cmp   dx,Eof2
      jz    @next_sync_end
      loop  @next_try

    @next_sync_end:
      pop   cx
      cmp   bx,Eof1
      jz    @evaluate_eof
      inc   bx
      cmp   bx,Eof1
      jz    @evaluate_eof
      loop  @next_sync
      jmp   @evaluate_eof

    @evaluate:
      pop   cx
      pop   cx
    @evaluate_eof:

      sub   bx,TextStart1
      mov   TextLength1,bx
      mov   ax,word ptr EditBuf1
      sub   TextStart1,ax

      sub   dx,TextStart2
      mov   TextLength2,dx
      mov   ax,word ptr EditBuf2
      sub   TextStart2,ax
      pop   ds
    end;

    with EditForm1.Memo1 do
    begin
      SelStart:= TextStart1;
      SelLength:= TextLength1
    end;
    with EditForm2.Memo1 do
    begin
      SelStart:= TextStart2;
      SelLength:= TextLength2;
    end;

    FreeMem(EditBuf1, Size1 + 1);
    FreeMem(EditBuf2, Size2 + 1);
  end;
end;

procedure TEditForm.SaveOptions1Click(Sender: TObject);
var
  WinIni: TIniFile;
  TempString: string;
begin
  With TIniFile.Create('WCOMPARE.INI') Do
    try
     WriteInteger('WCOMPARE', 'SyncReach', FrameForm.SyncReach);
     WriteInteger('WCOMPARE', 'MatchReach', FrameForm.MatchReach);
     WriteInteger('WCOMPARE', 'WindowOption', FrameForm.WinOption);
    finally
      Free;
      FrameForm.SetWindows;
    end;
end;

destructor TEditForm.Destroy;
begin
  inherited Destroy;
  FrameForm.SetWindows;
end;

end.
