unit Cccledit;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls;

type
  TRGBEditDialog = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    Shape1: TShape;
    ScrollBar1: TScrollBar;
    Label1: TLabel;
    Label2: TLabel;
    ScrollBar2: TScrollBar;
    Label3: TLabel;
    ScrollBar3: TScrollBar;
    procedure FormCreate(Sender: TObject);
    procedure ScrollBar1Change(Sender: TObject);
    procedure ScrollBar2Change(Sender: TObject);
    procedure ScrollBar3Change(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
private
    { Private declarations }
  public
    { Public declarations }
    StartingRGBValue ,
    FinalRGBValue : Longint;
    procedure SetInitialRGBValue( The_Value : Longint );
end;

var
  RGBEditDialog: TRGBEditDialog;
  CurrentRedValue ,
  CurrentBlueValue ,
  CurrentGreenValue  : Byte;
implementation

{$R *.DFM}

procedure TRGBEditDialog.SetInitialRGBValue( The_Value : Longint );
var TheString : String;
begin
  { Get the three components of the property value using API call }
  CurrentRedValue := GetRValue( The_Value );
  CurrentGreenValue := GetGValue( The_Value );
  CurrentBlueValue := GetBValue( The_Value );
  { Set the scrollbars based on the imported values }
  Scrollbar1.Position := CurrentRedValue;
  Scrollbar2.Position := CurrentGreenValue;
  Scrollbar3.Position := CurrentBlueValue;
  { Set up the default return value and default starting value }
  FinalRGBValue := The_Value;
  StartingRGBValue := The_Value;
  { Set up the label captions }
  Str( CurrentRedValue , TheString );
  Label1.Caption := 'Red Value is ' + TheString;
  Str( CurrentGreenValue , TheString );
  Label2.Caption := 'Green Value is ' + TheString;
  Str( CurrentBlueValue , TheString );
  Label3.Caption := 'Blue Value is ' + TheString;
  { Make the shape's brush color that of the starting color to see it }
  Shape1.Brush.Color := StartingRGBValue;
end;

procedure TRGBEditDialog.FormCreate(Sender: TObject);
begin
  { Initialize everything to zero }
  CurrentRedValue := 0;
  CurrentBlueValue := 0;
  CurrentGreenValue := 0;
  FinalRGBValue := RGB(  0 , 0 , 0 );
  Label1.Caption := 'Red Value is 0';
  Label2.Caption := 'Green Value is 0';
  Label3.Caption := 'Blue Value is 0';
end;

procedure TRGBEditDialog.ScrollBar1Change(Sender: TObject);
var ValueString : String;
begin
  { Set up the string for scrollbar position }
  Str( ScrollBar1.Position , ValueString );
  { Typecast the value to a byte for the holders }
  CurrentRedValue := Byte( ScrollBar1.Position );
  { Set up the caption }
  Label1.Caption := 'Red Value is ' + ValueString;
  { Create the final RGB value again }
  FinalRGBValue := RGB( CurrentRedValue , CurrentBlueValue , CurrentGreenValue );
  { And make the shape show it }
  Shape1.Brush.Color := FinalRGBValue;
end;

procedure TRGBEditDialog.ScrollBar2Change(Sender: TObject);
var ValueString : String;
begin
  { Set up the string for scrollbar position }
  Str( ScrollBar2.Position , ValueString );
  { Typecast the value to a byte for the holders }
  CurrentGreenValue := Byte( ScrollBar2.Position );
  { Set up the caption }
  Label2.Caption := 'Green Value is ' + ValueString;
  { Create the final RGB value again }
  FinalRGBValue := RGB( CurrentRedValue , CurrentBlueValue , CurrentGreenValue );
  { And make the shape show it }
  Shape1.Brush.Color := FinalRGBValue;
end;

procedure TRGBEditDialog.ScrollBar3Change(Sender: TObject);
var ValueString : String;
begin
  { Set up the string for scrollbar position }
  Str( ScrollBar3.Position , ValueString );
  { Typecast the value to a byte for the holders }
  CurrentBlueValue := Byte( ScrollBar3.Position );
  { Set up the caption }
  Label3.Caption := 'Blue Value is ' + ValueString;
  { Create the final RGB value again }
  FinalRGBValue := RGB( CurrentRedValue , CurrentBlueValue , CurrentGreenValue );
  { And make the shape show it }
  Shape1.Brush.Color := FinalRGBValue;
end;

procedure TRGBEditDialog.OKBtnClick(Sender: TObject);
begin
  { Return an OK result }
  ModalResult := mrOK;
  { Don't call close because that'll be done in the Property Editor }
end;

procedure TRGBEditDialog.CancelBtnClick(Sender: TObject);
begin
  { Return a cancel result }
  ModalResult := mrCancel;
  { Don't call close because that'll be done in the Property Editor }
end;

end.
