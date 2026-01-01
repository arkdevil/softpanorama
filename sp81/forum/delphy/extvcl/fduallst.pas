{*******************************************************}
{                                                       }
{         Borland Delphi Unit                           }
{                                                       }
{         Copyright (c) 1995 OKO ROSNO                  }
{                                                       }
{*******************************************************}
{$L-,D+,S-}

unit FDualLst;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, CustCtrl, ExtCtrls, Buttons;

type
  TDualListForm = class(TForm)
    SrcList: TTextListBox;
    DstList: TTextListBox;
    SrcLabel: TLabel;
    DstLabel: TLabel;
    IncBtn: TBitBtn;
    IncAllBtn: TBitBtn;
    ExclBtn: TBitBtn;
    ExclAllBtn: TBitBtn;
    OkBtn: TBitBtn;
    CancelBtn: TBitBtn;
    HelpBtn: TBitBtn;
    Bevel1: TBevel;
    procedure IncBtnClick(Sender: TObject);
    procedure IncAllBtnClick(Sender: TObject);
    procedure ExclBtnClick(Sender: TObject);
    procedure ExclAllBtnClick(Sender: TObject);
    procedure SrcListDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure DstListDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure SrcListDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure DstListDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure FormActivate(Sender: TObject);
    procedure SrcListKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DstListKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    function GetShowHelp: Boolean;
    procedure SetShowHelp(Value: Boolean);
  public
    { Public declarations }
    procedure SetButtons;
    property ShowHelp: Boolean read GetShowHelp write SetShowHelp
      default True;
end;

implementation

uses BoxProcs;

{$R *.DFM}

procedure TDualListForm.SetButtons;
var
  SrcEmpty, DstEmpty: Boolean;
begin
  SrcEmpty := SrcList.Items.Count = 0;
  DstEmpty := DstList.Items.Count = 0;
  IncBtn.Enabled := not SrcEmpty;
  IncAllBtn.Enabled := not SrcEmpty;
  ExclBtn.Enabled := not DstEmpty;
  ExclAllBtn.Enabled := not DstEmpty;
end;

function TDualListForm.GetShowHelp: Boolean;
begin
  Result := (HelpBtn.Enabled) and (HelpBtn.Visible);
end;

procedure TDualListForm.SetShowHelp(Value: Boolean);
const
  x_FrmBtn = 19;
  x_GrpBtn = 18;
  x_BtnBtn = 8;
begin
  with HelpBtn do begin
    Enabled := Value;
    Visible := Value;
  end;
  if Value then begin
    HelpBtn.Left := Width - HelpBtn.Width - x_FrmBtn;
    CancelBtn.Left := HelpBtn.Left - CancelBtn.Width - x_GrpBtn;
    OkBtn.Left := CancelBtn.Left - OkBtn.Width - x_BtnBtn;;
  end
  else begin
    CancelBtn.Left := Width - CancelBtn.Width - x_FrmBtn;
    OkBtn.Left := CancelBtn.Left - OkBtn.Width - x_BtnBtn;;
  end;
end;

procedure TDualListForm.IncBtnClick(Sender: TObject);
begin
  BoxMoveSelectedItems(SrcList, DstList);
  SetButtons;
end;

procedure TDualListForm.IncAllBtnClick(Sender: TObject);
var
  I: Integer;
begin
  BoxMoveAllItems(SrcList, DstList);
  SetButtons;
end;

procedure TDualListForm.ExclBtnClick(Sender: TObject);
begin
  BoxMoveSelectedItems(DstList, SrcList);
  SetButtons;
end;

procedure TDualListForm.ExclAllBtnClick(Sender: TObject);
begin
  BoxMoveAllItems(DstList, SrcList);
  SetButtons;
end;

procedure TDualListForm.SrcListDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  BoxDragOver(SrcList, Source, X, Y, State, Accept, SrcList.Sorted);
  if State = dsDragLeave then
    (Source as TTextListBox).DragCursor := crDrag;
  if (State = dsDragEnter) and ((Source as TTextListBox).SelCount > 1) then
    (Source as TTextListBox).DragCursor := crMultiDrag;
end;

procedure TDualListForm.DstListDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  BoxDragOver(DstList, Source, X, Y, State, Accept, DstList.Sorted);
  if State = dsDragLeave then
    (Source as TTextListBox).DragCursor := crDrag;
  if (State = dsDragEnter) and ((Source as TTextListBox).SelCount > 1) then
    (Source as TTextListBox).DragCursor := crMultiDrag;
end;

procedure TDualListForm.SrcListDragDrop(Sender, Source: TObject; X,
  Y: Integer);
begin
  if Source = DstList then ExclBtnClick(SrcList)
  else
    if Source = SrcList then begin
      BoxMoveFocusedItem(SrcList, SrcList.ItemAtPos(Point(X, Y), True));
    end;
end;

procedure TDualListForm.DstListDragDrop(Sender, Source: TObject; X,
  Y: Integer);
begin
  if Source = SrcList then IncBtnClick(DstList)
  else
    if Source = DstList then begin
      BoxMoveFocusedItem(DstList, DstList.ItemAtPos(Point(X, Y), True));
    end;
end;

procedure TDualListForm.FormActivate(Sender: TObject);
begin
  SetButtons;
end;

procedure TDualListForm.SrcListKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Incr: Integer;
begin
  if not SrcList.Sorted then begin
    if (ssCtrl in Shift) and ((Key = VK_DOWN) or (Key = VK_UP)) then begin
      if Key = VK_DOWN then Incr := 1
      else Incr := -1;
      BoxMoveFocusedItem(SrcList, SrcList.ItemIndex + Incr);
      Key := 0;
    end;
  end;
end;

procedure TDualListForm.DstListKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Incr: Integer;
begin
  if not DstList.Sorted then begin
    if (ssCtrl in Shift) and ((Key = VK_DOWN) or (Key = VK_UP)) then begin
      if Key = VK_DOWN then Incr := 1
      else Incr := -1;
      BoxMoveFocusedItem(DstList, DstList.ItemIndex + Incr);
      Key := 0;
    end;
  end;
end;

end.
