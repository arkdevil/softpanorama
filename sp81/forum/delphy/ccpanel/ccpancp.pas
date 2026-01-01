unit Ccpancp;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls , CcClEdit , DsgnIntf;

type
  TCCPanel = class(TPanel)
  private
    { Private declarations }
    FHighLightColor : TColor;
    FShadowColor : TColor;
  protected
    { Protected declarations }
    procedure Paint; override;
  public
    { Public declarations }
    constructor Create(AOwner : TComponent); override;
  published
    { Published declarations }
    property HighLightColor : TColor read FHighLightColor
     write FHighLightColor default clBtnHighLight;
    property ShadowColor : TColor read FShadowColor
     write FShadowColor default clBtnShadow;
  end;
  TCCPropertyEditor = class(TPropertyEditor)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
    function GetValue : String; override;
    procedure SetValue( const value : String ); override;
  end;

{ This is required to add the component to the VCL palette }
procedure Register;

implementation

procedure Register;
begin
  { Put the component in a waite group tab with their name }
  RegisterComponents('CIUPKC Freeware', [TCCPanel]);
  { Register the property editor for the TColor properties }
  RegisterPropertyEditor( TypeInfo( TColor ) ,
                          TCCPanel  ,
                          ''                 ,
                          TCCPropertyEditor   );
end;

procedure TCCPropertyEditor.Edit;
var TheEditForm : TRGBEditDialog;
    TheResult : Integer;
begin
  { Create the color edit dialog }
  TheEditForm := TRGBEditDialog.Create( Application );
  { Set the initial RGB value from existing color }
  TheEditForm.SetInitialRGBValue( GetOrdValue );
  try
    { Show the dialog box modally and get result }
    TheResult := TheEditForm.ShowModal;
    if TheResult = mrOK then
    begin
      { Set the value if an OK is entered }
      SetOrdValue( TheEditForm.FinalRGBValue );
    end;
  finally
    { Get rid of the dialog box }
    TheEditForm.Free;
  end;
end;

function TCCPropertyEditor.GetAttributes: TPropertyAttributes;
begin
  { allow only dialog box editing of this property type }
  Result :=  [paDialog];
end;

function TCCPropertyEditor.GetValue : String;
var The_String : String;
begin
  { Create an RGB triplet string }
  The_String := IntToStr( GetRValue( GetOrdValue ) );
  The_String := The_String + ',';
  The_String := The_String + IntToStr( GetGValue( GetOrdValue ) );
  The_String := The_String + ',';
  The_String := The_String + IntToStr( GetBValue( GetOrdValue ) );
  Result := The_String;
end;

Procedure TCCPropertyEditor.SetValue( const Value : String );
begin
  { convert the string to an integer for setting the value }
  SetOrdValue( StrToInt( Value ) );
end;


constructor TCCPanel.Create(AOwner : TComponent);
begin
  { Call inherited method to make sure all default behavior occurs }
  inherited Create(AOwner);
  { Set the default values for the highlight and shadow colors }
  FHighLightColor := clBtnHighLight;
  FShadowColor := clBtnShadow;
end;

{ This is copied from the VCL Source library }
procedure TCCPanel.Paint;
var
  Rect: TRect;
  TopColor, BottomColor: TColor;
  Text: array[0..255] of Char;
  FontHeight: Integer;
const
  Alignments: array[TAlignment] of Word = (DT_LEFT, DT_RIGHT, DT_CENTER);

  { This is the procedure which needs modification }
  procedure AdjustColors(Bevel: TPanelBevel);
  begin
    { Rather than 'hardwiring' the default color, make it a property }
    TopColor := FHighLightColor;
    { Invert the color if lowered rather than raised }
    if Bevel = bvLowered then TopColor := FShadowColor;
    { Rather than 'hardwiring' the default color, make it a property }
    BottomColor := FShadowColor;
    { Invert the color if lowered rather than raised }
    if Bevel = bvLowered then BottomColor := FHighLightColor;
  end;

begin
  { Find out how big the panel is }
  Rect := GetClientRect;
  { If there is an outer bevel draw it }
  if BevelOuter <> bvNone then
  begin
    { Get the raised/lowered highlight/shadow colors }
    AdjustColors(BevelOuter);
    { Call the internal procedure to draw the bevels }
    { Note that rect comes back modified for next op }
    Frame3D(Canvas, Rect, TopColor, BottomColor, BevelWidth);
  end;
  { Draw the border between bevels }
  { Rect comes back modified again }
  Frame3D(Canvas, Rect, Color, Color, BorderWidth);
  { If there is an inner bevel draw it }
  if BevelInner <> bvNone then
  begin
    { Get highlight/shadow colors for raised/lowered }
    AdjustColors(BevelInner);
    { Draw using the private procedure    }
    { Rect is now the center of the panel }
    Frame3D(Canvas, Rect, TopColor, BottomColor, BevelWidth);
  end;
  { Use the canvas property to draw the center of the panel }
  with Canvas do
  begin
    { Set up the brush color }
    Brush.Color := Color;
    { Fill up the interior }
    FillRect(Rect);
    { Set the brush to empty }
    Brush.Style := bsClear;
    { Get the current font }
    Font := Self.Font;
    { Find out how high letters are }
    FontHeight := TextHeight('W');
    { Use the rect to draw in }
    with Rect do
    begin
      { Find the middle and set rect's top to it}
      Top := ((Bottom + Top) - FontHeight) shr 1;
      { Set the bottom of rect to the height of the font }
      Bottom := Top + FontHeight;
    end;
    { Set up an ASCIIZ String }
    StrPCopy(Text, Caption);
    { Draw caption in the rect with alignment styles }
    DrawText(Handle, Text, StrLen(Text), Rect, (DT_EXPANDTABS or
      DT_VCENTER) or Alignments[Alignment]);
  end;
end;

end.
