{*****************************************************}
{                                                     }
{       Borland Delphi VCL Unit                       }
{                                                     }
{       The CurrencyEdit component based on           }
{       analogous component by Robert Vivrette.       }
{                                                     }
{       Portions copyright (c) 1995 OKO ROSNO         }
{                                                     }
{*****************************************************}

Unit CurrEdit;

{$W-,R-,B-}

Interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Menus, Forms, Dialogs, StdCtrls;

type

{ TCurrencyEdit }

  TCurrencyEdit = class(TCustomMemo)
  private
    FDispFormat: PString;
    FFieldValue: Extended;
    FDecimalPlaces: Word;
    function GetDispFormat: string;
    procedure SetFormat(const Value: string);
    function GetFieldValue: Extended;
    procedure SetFieldValue(Value: Extended);
    function GetDisplayText: string;
    procedure SetDisplayText(const Value: string);
    function GetText: string;
    procedure SetText(const Value: string);
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure CMEnter(var Message: TCMEnter); message CM_ENTER;
    procedure CMExit(var Message: TCMExit); message CM_EXIT;
    procedure FormatText;
    procedure UnformatText;
    procedure SetEditRect;
    function DefaultDispFormat: string;
    function IsFormatStored: Boolean;
  protected
    procedure KeyPress(var Key: Char); override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    property DisplayText: string read GetDisplayText write SetDisplayText;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Alignment default taRightJustify;
    property AutoSize default True;
    property BorderStyle;
    property Color;
    property Ctl3D;
    property DisplayFormat: string read GetDispFormat write SetFormat stored IsFormatStored;
    property DecimalPlaces: Word read FDecimalPlaces write FDecimalPlaces default 2;
    property Value: Extended read GetFieldValue write SetFieldValue;
    property Text: string read GetText write SetText;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Font;
    property HideSelection;
    property MaxLength;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property Visible;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

{ Designer registration }

procedure Register;

implementation

Uses LibConst;

{ Designer registration }

procedure Register;
begin
  RegisterComponents(LoadStr(srAdditional), [TCurrencyEdit]);
end;

{ TCurrencyEdit }

constructor TCurrencyEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  AutoSize := True;
  Alignment := taRightJustify;
  Width := 121;
  Height := 25;
  FDispFormat := NewStr(DefaultDispFormat);
  FFieldValue := 0.0;
  FDecimalPlaces := 2;
  AutoSelect := False;
  WantReturns := False;
  WordWrap := False;
  FormatText;
end;

destructor TCurrencyEdit.Destroy;
begin
  DisposeStr(FDispFormat);
  inherited Destroy;
end;

function TCurrencyEdit.DefaultDispFormat: string;
begin
  Result := CurrencyString + ',0.00;-' + CurrencyString + ',0.00';
end;

function TCurrencyEdit.GetDispFormat: string;
begin
  Result := FDispFormat^;
end;

procedure TCurrencyEdit.SetFormat(const Value: string);
begin
  if FDispFormat^ <> Value then begin
    AssignStr(FDispFormat, Value);
    FormatText;
  end;
end;

function TCurrencyEdit.IsFormatStored: Boolean;
begin
  Result := (FDispFormat^ <> DefaultDispFormat);
end;

function TCurrencyEdit.GetFieldValue: Extended;
begin
  UnformatText;
  Result := FFieldValue;
end;

procedure TCurrencyEdit.SetFieldValue(Value: Extended);
begin
  if FFieldValue <> Value then begin
    FFieldValue := Value;
    FormatText;
  end;
end;

function TCurrencyEdit.GetDisplayText: string;
begin
  Result := inherited Text;
end;

procedure TCurrencyEdit.SetDisplayText(const Value: string);
begin
  inherited Text := Value;
end;

procedure TCurrencyEdit.SetText(const Value: string);
begin
  try
    FFieldValue := StrToFloat(Value);
  except
    FFieldValue := 0.0;
  end;
  FormatText;
end;

function TCurrencyEdit.GetText: string;
var
  I: Byte;
  IsNeg: Boolean;
begin
  IsNeg := (Pos('-',DisplayText) > 0) or (Pos('(',DisplayText) > 0);
  Result := '';
  for I := 1 to Length(DisplayText) do begin
    if DisplayText[I] in ['0'..'9', DecimalSeparator, 'e', 'E'] then
      Result := Result + DisplayText[I];
  end;
  if Result = '' then Result := '0.00'
  else if IsNeg then Result := '-' + Result;
end;

procedure TCurrencyEdit.UnformatText;
var
  TmpText : String;
begin
  TmpText := GetText;
  try
    FFieldValue := StrToFloat(TmpText);
  except
    MessageBeep(mb_IconAsterisk);
  end;
end;

procedure TCurrencyEdit.FormatText;
begin
  DisplayText := FormatFloat(FDispFormat^, FFieldValue);
end;

procedure TCurrencyEdit.CMEnter(var Message: TCMEnter);
begin
  SelectAll;
  inherited;
end;

procedure TCurrencyEdit.CMExit(var Message: TCMExit);
begin
  UnformatText;
  FormatText;
  inherited;
end;

procedure TCurrencyEdit.WMSize(var Message: TWMSize);
begin
  inherited;
  SetEditRect;
end;

procedure TCurrencyEdit.SetEditRect;
var
  Loc: TRect;
begin
  Loc.Bottom := ClientHeight + 1; {+1 is workaround for windows paint bug}
  Loc.Right := ClientWidth - 1;
  Loc.Top := 0;
  Loc.Left := 0;
  SendMessage(Handle, EM_SETRECTNP, 0, LongInt(@Loc));
end;

procedure TCurrencyEdit.KeyPress(var Key: Char);
var
  S: String;
begin
  {Allow backspace to edit}
  S := Text;
  if (not (Key in [Char(vk_Back),'0'..'9',DecimalSeparator,'-']))
    or ((Key = DecimalSeparator) and (FDecimalPlaces = 0))  {Integers}
    or ((Key = DecimalSeparator) and (Pos(DecimalSeparator, S) <> 0))
    {too many decimal points}
    or ((Key = '-') and (Pos('-', S) <> 0)) then {too many sign}
  begin
    Key := #0;
    Exit;
  end;
  if Key <> Char(vk_Back) then begin
    {S is a model of Text if we accept the keystroke.
    Use SelStart and SelLength to find the cursor (insert) position.}
    S := Copy(S, 1, SelStart) + Key + Copy(S, SelStart + SelLength + 1,
      Length(S));
    if ((Pos(DecimalSeparator, S) > 0) and (Length(S) - Pos(DecimalSeparator,
      S) > FDecimalPlaces))
      {too many decimal places}
      or (Pos('-', S) > 1) then {minus only at beginning}
    begin
      Key := #0;
    end;
  end;
  inherited KeyPress(Key);
end;

procedure TCurrencyEdit.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  case Alignment of
    taLeftJustify:
      Params.Style := Params.Style or ES_LEFT and not ES_MULTILINE;
    taRightJustify:
      Params.Style := Params.Style or ES_RIGHT and not ES_MULTILINE;
    taCenter:
      Params.Style := Params.Style or ES_CENTER and not ES_MULTILINE;
  end;
end;

procedure TCurrencyEdit.CreateWnd;
begin
  inherited CreateWnd;
  SetEditRect;
end;

end.