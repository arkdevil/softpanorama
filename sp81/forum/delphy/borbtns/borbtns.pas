{-------------------------------------------------------------------}
{ BORBTNS - BWCC Style CheckBoxes & Radio Buttons for Delphi        }
{ v. 1.00 April, 8 1995                                             }
{-------------------------------------------------------------------}
{ Copyright Enrico Lodolo                                           }
{ via F.Bolognese 27/3 - 440129 Bologna - Italy                     }
{ CIS 100275,1255 - Internet ldlc18k1@bo.nettuno.it                 }
{-------------------------------------------------------------------}

unit BorBtns;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Menus;

type
  TBorCheck = class(TCustomControl)
  private
    FDown:Boolean;
    FState:TCheckBoxState;
    FFocused:Boolean;
    FCheckColor:TColor;
  protected
    constructor Create(AOwner: TComponent); override;
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState;X, Y: Integer);
      override;
    procedure KeyDown(var Key:Word;Shift:TShiftSTate); override;
    procedure KeyUp(var Key:Word;Shift:TShiftSTate); override;
    procedure SetDown(Value:Boolean);
    procedure SetState(Value:TCheckBoxState);
    procedure SetChecked(Value:Boolean);
    function  GetChecked:Boolean;
    procedure SetCheckColor(Value:TColor);
    procedure DoEnter; override;
    procedure DoExit; override;
  public
  published
    property Caption;
    property CheckColor:TColor read FCheckColor write SetCheckColor
             default clBlack;
    property Checked:Boolean read GetChecked write SetChecked
             default False;
    property Down:Boolean read FDown write SetDown default False;
    property DragCursor;
    property DragMode;
    property Font;
    property ParentFont;
    property PopupMenu;
    property ShowHint;
    property State:TCheckBoxState read FState write SetState
             default cbUnchecked;
    property TabOrder;
    property TabStop;
    property OnClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

type
  TBorRadio = class(TCustomControl)
  private
    FDown:Boolean;
    FChecked:Boolean;
    FFocused:Boolean;
    FCheckColor:TColor;
    FGroupIndex:Byte;
    procedure TurnSiblingsOff;
  protected
    constructor Create(AOwner: TComponent); override;
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState;X, Y: Integer);
      override;
    procedure KeyDown(var Key:Word;Shift:TShiftSTate); override;
    procedure KeyUp(var Key:Word;Shift:TShiftSTate); override;
    procedure SetDown(Value:Boolean);
    procedure SetChecked(Value:Boolean);
    procedure SetCheckColor(Value:TColor);
    procedure DoEnter; override;
    procedure DoExit; override;
  public
  published
    property Caption;
    property CheckColor:TColor read FCheckColor write SetCheckColor
             default clBlack;
    property Checked:Boolean read FChecked write SetChecked
             default False;
    property Down:Boolean read FDown write SetDown default False;
    property DragCursor;
    property DragMode;
    property Font;
    property GroupIndex:Byte read FGroupIndex write FGroupIndex
      default 0;
    property ParentFont;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property OnClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

procedure Register;

implementation

{-------------------------------------------------------------------}
{                          Borland Style CheckBox                   }
{-------------------------------------------------------------------}

constructor TBorCheck.Create(AOwner: TComponent);

begin
  inherited Create(AOwner);
  Width := 98;
  Height := 20;
  ParentColor:=False;
  Color:=clBtnFace;
end;

const BW=12;

procedure TBorCheck.Paint;

var BL,BT,BR,BB:Integer;
    TX,TY,TW,TH:Integer;
    Rect:TRect;

begin
     Canvas.Font:=Font;
     with Canvas do
       begin
         BT:=(Height div 2)-(BW div 2);
         BB:=BT+BW;
         BL:=1;
         BR:=BW+1;
         Brush.Color:=clBtnFace;
         if not FDown then
           begin
             Pen.Color:=clBtnFace;
             Rectangle(BL,BT,BR,BB);
             Pen.Color:=clBtnHighLight;
             MoveTo(BL,BB);
             LineTo(BL,BT);
             LineTo(BR,BT);
             Pen.Color:=clBtnShadow;
             LineTo(BR,BB);
             LineTo(BL,BB);
           end
         else
           begin
             Pen.Color:=clBlack;
             Pen.Width:=2;
             Rectangle(BL+1,BT+1,BR+1,BB+1);
             Pen.Width:=1;
           end;
         TX:=BR+5;
         TY:=(Height div 2)+(Font.Height div 2)-1;
         TW:=TextWidth(Caption);
         TH:=TextHeight(Caption);
         TextOut(TX,TY,Caption);
         case State of
           cbChecked:begin
                       Pen.Color:=FCheckColor;
                       Pen.Width:=1;
                       Dec(BT);Dec(BB);
                       MoveTo(BL+2,BT+BW div 2+1);
                       LineTo(BL+2,BB-1);
                       MoveTo(BL+3,BT+BW div 2);
                       LineTo(BL+3,BB-2);
                       MoveTo(BL+2,BB-1);
                       LineTo(BR-2,BT+3);
                       MoveTo(BL+3,BB-1);
                       LineTo(BR-1,BT+3);
                     end;
            cbGrayed:begin
                       if Down then
                         begin
                           Pen.Color:=clBtnFace;
                           Brush.Color:=clBtnFace;
                           Rectangle(BL+2,BT+2,BR-1,BB-1);
                         end;
                       Brush.Color:=clBtnShadow;
                       Rectangle(BL+2,BT+2,BR-1,BB-1);
                     end;
         end;
         Brush.Color:=clBtnFace;
         Rect:=Bounds(TX-1,TY,TW+3,TH+1);
         FrameRect(Rect);
         if FFocused then
           DrawFocusRect(Rect);
       end;
end;

procedure TBorCheck.SetDown(Value:Boolean);

begin
     if FDown<>Value then
       begin
         FDown:=Value;
         Paint;
       end;
end;

procedure TBorCheck.SetState(Value:TCheckBoxState);

begin
     if FState<>Value then
       begin
         FState:=Value;
         Paint;
         Click;
       end;
end;

function TBorCheck.GetChecked: Boolean;

begin
     Result:=State=cbChecked;
end;

procedure TBorCheck.SetChecked(Value:Boolean);

begin
     if Value then State := cbChecked
              else State := cbUnchecked;
end;

procedure TBorCheck.SetCheckColor(Value:TColor);

begin
     FCheckColor:=Value;
     Paint;
end;

procedure TBorCheck.DoEnter;

begin
     inherited DoEnter;
     FFocused:=True;
     Paint;
end;

procedure TBorCheck.DoExit;

begin
     inherited DoExit;
     FFocused:=False;
     Paint;
end;

procedure TBorCheck.MouseDown(Button: TMouseButton; Shift: TShiftState;
                                  X, Y: Integer);

begin
     SetFocus;
     FFocused:=True;
     inherited MouseDown(Button, Shift, X, Y);
     MouseCapture:=True;
     Down:=True;
end;

procedure TBorCheck.MouseUp(Button: TMouseButton; Shift: TShiftState;
                                  X, Y: Integer);

begin
     MouseCapture:=False;
     Down:=False;
     if (X>=0) and (X<=Width) and (Y>=0) and (Y<=Height) then
       Checked:=not Checked;
     inherited MouseUp(Button, Shift, X, Y);
end;

procedure TBorCheck.MouseMove(Shift: TShiftState;X, Y: Integer);

begin
     if MouseCapture then
       Down:=(X>=0) and (X<=Width) and (Y>=0) and (Y<=Height);
     inherited MouseMove(Shift,X,Y);
end;

procedure TBorCheck.KeyDown(var Key:Word;Shift:TShiftSTate);

begin
     if Key=vk_Space then Down:=True;
     inherited KeyDown(Key,Shift);
end;

procedure TBorCheck.KeyUp(var Key:Word;Shift:TShiftSTate);

begin
     if Key=vk_Space then
       begin
         Down:=False;
         Checked:=not Checked;
       end;
end;

{-------------------------------------------------------------------}
{                           Borland Radio Button                    }
{-------------------------------------------------------------------}

constructor TBorRadio.Create(AOwner: TComponent);

begin
  inherited Create(AOwner);
  Width := 98;
  Height := 20;
  ParentColor:=False;
  Color:=clBtnFace;
end;

procedure TBorRadio.Paint;

var BL,BT,BR,BB,BM:Integer;
    TX,TY,TW,TH:Integer;
    CX,CY:Integer;
    Rect:TRect;

begin
     Canvas.Font:=Font;
     with Canvas do
       begin
         BM:=BW div 2;
         BT:=(Height div 2)-BM;
         BB:=BT+BW;
         BL:=1;
         BR:=BW+1;
         Brush.Color:=clBtnFace;
         if Down then
           begin
             Pen.Color:=clBlack;
             MoveTo(BL+BM,BT);
             LineTo(BL,BT+BM);
             LineTo(BL+BM,BB);
             LineTo(BR,BT+BM);
             LineTo(BL+BM,BT);
             MoveTo(BL+BM,BT+1);
             LineTo(BL+1,BT+BM);
             LineTo(BL+BM,BB-1);
             LineTo(BR-1,BT+BM);
             LineTo(BL+BM,BT+1);
           end
         else
           begin
             Pen.Color:=clBtnFace;
             Rectangle(BL,BT,BR,BB);
             if Checked then Pen.Color:=clBtnShadow
                        else Pen.Color:=clBtnHighLight;
             MoveTo(BL+BM,BT);
             LineTo(BL,BT+BM);
             LineTo(BL+BM,BB);
             if Checked then Pen.Color:=clBtnHighLight
                        else Pen.Color:=clBtnShadow;
             LineTo(BR,BT+BM);
             LineTo(BL+BM,BT);
           end;
         if Checked then
            begin
              Pen.Color:=CheckColor;
              CX:=BL+BM;CY:=BT+BM;
              MoveTo(CX-1,CY-1);
              LineTo(CX+2,CY-1);
              MoveTo(CX-2,CY);
              LineTo(CX+3,CY);
              MoveTo(CX-1,CY+1);
              LineTo(CX+2,CY+1);
              MoveTo(CX,CY-2);
              LineTo(CX,CY+3);
            end;
         TX:=BR+5;
         TY:=(Height div 2)+(Font.Height div 2)-1;
         TW:=TextWidth(Caption);
         TH:=TextHeight(Caption);
         TextOut(TX,TY,Caption);
         Brush.Color:=clBtnFace;
         Rect:=Bounds(TX-1,TY,TW+3,TH+1);
         FrameRect(Rect);
         if FFocused then
           DrawFocusRect(Rect);
       end;
end;

procedure TBorRadio.SetDown(Value:Boolean);

begin
     if FDown<>Value then
       begin
         FDown:=Value;
         Paint;
       end;
end;

procedure TBorRadio.TurnSiblingsOff;

var i:Integer;
    Sibling: TBorRadio;

begin
     if Parent <> nil then
       for i:=0 to Parent.ControlCount-1 do
         if Parent.Controls[i] is TBorRadio then
           begin
             Sibling:=TBorRadio(Parent.Controls[i]);
             if (Sibling<>Self) and
                (Sibling.GroupIndex=GroupIndex) then
                  Sibling.SetChecked(False);
           end;
end;

procedure TBorRadio.SetChecked(Value: Boolean);

begin
     if FChecked <> Value then
       begin
         TabStop:=Value;
         FChecked:=Value;
         if Value then
           begin
             TurnSiblingsOff;
             Click;
           end;
         Paint;
       end;
end;

procedure TBorRadio.SetCheckColor(Value:TColor);

begin
     FCheckColor:=Value;
     Paint;
end;

procedure TBorRadio.DoEnter;

begin
     inherited DoEnter;
     FFocused:=True;
     Checked:=True;
     Paint;
end;

procedure TBorRadio.DoExit;

begin
     inherited DoExit;
     FFocused:=False;
     Paint;
end;

procedure TBorRadio.MouseDown(Button: TMouseButton; Shift: TShiftState;
                                  X, Y: Integer);

begin
     SetFocus;
     FFocused:=True;
     inherited MouseDown(Button, Shift, X, Y);
     MouseCapture:=True;
     Down:=True;
end;

procedure TBorRadio.MouseUp(Button: TMouseButton; Shift: TShiftState;
                                  X, Y: Integer);

begin
     MouseCapture:=False;
     Down:=False;
     if (X>=0) and (X<=Width) and (Y>=0) and (Y<=Height)
       and not Checked then Checked:=True;
     inherited MouseUp(Button, Shift, X, Y);
end;

procedure TBorRadio.MouseMove(Shift: TShiftState;X, Y: Integer);

begin
     if MouseCapture then
       Down:=(X>=0) and (X<=Width) and (Y>=0) and (Y<=Height);
     inherited MouseMove(Shift,X,Y);
end;

procedure TBorRadio.KeyDown(var Key:Word;Shift:TShiftSTate);

begin
     if Key=vk_Space then Down:=True;
     inherited KeyDown(Key,Shift);
end;

procedure TBorRadio.KeyUp(var Key:Word;Shift:TShiftSTate);

begin
     if Key=vk_Space then
       begin
         Down:=False;
         if not Checked then Checked:=True;
       end;
end;

procedure Register;

begin
     RegisterComponents('Samples',[TBorCheck,TBorRadio]);
end;

end.
