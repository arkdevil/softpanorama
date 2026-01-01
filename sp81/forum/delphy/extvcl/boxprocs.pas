{*******************************************************}
{                                                       }
{         Borland Delphi Unit                           }
{                                                       }
{         Copyright (c) 1995 OKO ROSNO                  }
{                                                       }
{*******************************************************}
unit BoxProcs;

interface

uses Classes, Controls, StdCtrls;

procedure BoxMoveSelectedItems(SrcList, DstList: TCustomListBox);
procedure BoxMoveAllItems(SrcList, DstList: TCustomListBox);
procedure BoxDragOver(List: TCustomListBox; Source: TObject;
  X, Y: Integer; State: TDragState; var Accept: Boolean; Sorted: Boolean);
procedure BoxMoveFocusedItem(List: TCustomListBox; DstIndex: Integer);

procedure BoxMoveSelected(List: TCustomListBox; Items: TStrings);
procedure BoxSetItem(List: TCustomListBox; Index: Integer);
function BoxGetFirstSelection(List: TCustomListBox): Integer;
function BoxCanDropItem(List: TCustomListBox; X, Y: Integer;
  var DragIndex: Integer): Boolean;

implementation

uses WinTypes;

procedure BoxMoveSelected(List: TCustomListBox; Items: TStrings);
var
  I: Integer;
begin
  I := 0;
  while I < List.Items.Count do begin
    if List.Selected[I] then begin
      Items.AddObject(List.Items[I], List.Items.Objects[I]);
      List.Items.Delete(I);
    end
    else begin
      Inc(I);
    end;
  end;
end;

function BoxGetFirstSelection(List: TCustomListBox): Integer;
var
  I: Integer;
begin
  Result := LB_ERR;
  for I := 0 to List.Items.Count - 1 do
    if List.Selected[I] then begin
      Result := I;
      break;
    end;
end;

procedure BoxSetItem(List: TCustomListBox; Index: Integer);
var
  MaxIndex: Integer;
begin
  with List do begin
    SetFocus;
    MaxIndex := List.Items.Count - 1;
    if Index = LB_ERR then Index := 0
    else begin
     if Index > MaxIndex then Index := MaxIndex;
    end;
    if Index >= 0 then begin
      if TListBox(List).MultiSelect then Selected[Index] := True
      else List.ItemIndex := Index;
    end;
  end;
end;

procedure BoxMoveSelectedItems(SrcList, DstList: TCustomListBox);
var
  Index: Integer;
begin
  Index := BoxGetFirstSelection(SrcList);
  if Index <> LB_ERR then begin
    BoxMoveSelected(SrcList, DstList.Items);
    BoxSetItem(SrcList, Index);
  end;
end;

procedure BoxMoveAllItems(SrcList, DstList: TCustomListBox);
var
  I: Integer;
begin
  for I := 0 to SrcList.Items.Count - 1 do begin
    DstList.Items.AddObject(SrcList.Items[I], SrcList.Items.Objects[I]);
  end;
  SrcList.Items.Clear;
  BoxSetItem(SrcList, 0);
end;

function BoxCanDropItem(List: TCustomListBox; X, Y: Integer;
  var DragIndex: Integer): Boolean;
var
  Focused: Integer;
begin
  Result := False;
  if (List.SelCount = 1) or (not TListBox(List).MultiSelect) then
  begin
    Focused := List.ItemIndex;
    if Focused <> LB_ERR then begin
      DragIndex := List.ItemAtPos(Point(X, Y), True);
      if (DragIndex >= 0) and (DragIndex <> Focused) then begin
        Result := True;
      end;
    end;
  end;
end;

procedure BoxDragOver(List: TCustomListBox; Source: TObject;
  X, Y: Integer; State: TDragState; var Accept: Boolean; Sorted: Boolean);
var
  DragIndex: Integer;
  R: TRect;
  procedure DrawItemFocusRect(Idx: Integer);
  begin
    R := List.ItemRect(Idx);
    List.Canvas.DrawFocusRect(R);
  end;
begin
  if Source <> List then
    Accept := Source is TCustomListBox
  else begin
    if Sorted then Accept := False
    else begin
      Accept := BoxCanDropItem(List, X, Y, DragIndex);
      if (List.Tag - 1) = DragIndex then begin
        if State = dsDragLeave then begin
          DrawItemFocusRect(List.Tag - 1);
          List.Tag := 0;
        end;
      end
      else begin
        if List.Tag > 0 then DrawItemFocusRect(List.Tag - 1);
        DrawItemFocusRect(DragIndex);
        List.Tag := DragIndex + 1;
      end;
    end;
  end;
end;

procedure BoxMoveFocusedItem(List: TCustomListBox; DstIndex: Integer);
var
  InsIndex, DelIndex: Integer;
begin
  if (DstIndex >= 0) and (DstIndex < List.Items.Count) then
    if (DstIndex <> List.ItemIndex) then begin
      if DstIndex > List.ItemIndex then begin
        InsIndex := DstIndex + 1;
        DelIndex := List.ItemIndex;
      end
      else begin
        InsIndex := DstIndex;
        DelIndex := List.ItemIndex + 1;
      end;
      List.Items.InsertObject(InsIndex, List.Items[List.ItemIndex],
                        List.Items.Objects[List.ItemIndex]);
      List.Items.Delete(DelIndex);
      BoxSetItem(List, DstIndex);
    end;
end;

end.
