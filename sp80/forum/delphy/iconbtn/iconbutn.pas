unit Iconbutn;

{$R ICONBUTN.RES}

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls;

type
  TIconButtonDemo = class(TForm)
    IconButtonPanel: TPanel;
    IconButtonImage: TImage;
    procedure FormCreate(Sender: TObject);
    procedure IconButtonPanelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure IconButtonPanelMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  IconButtonDemo: TIconButtonDemo;
  Icon1: TIcon;

implementation

{$R *.DFM}

procedure TIconButtonDemo.FormCreate(Sender: TObject);
begin
  { Create the Icon to store the image in }
  Icon1 := TIcon.Create;
  { Load the image from the .RES file; could also }
  { do a direct file read with LoadFromFile       }
  Icon1.Handle := LoadIcon( hInstance , 'HELP' );
  { Use implicit type conversion to assign the Icon to }
  { the TImage graphic component                       }
  IconbuttonImage.Picture.Graphic := Icon1;
  { And release the resources }
  Icon1.Free;
end;

procedure TIconButtonDemo.IconButtonPanelMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  { Simulate pressing in by changing bevel property }
  { This will be linked to clicks on the TImage too }
  IconButtonPanel.BevelOuter := bvLowered;
end;

procedure TIconButtonDemo.IconButtonPanelMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  { Simulate popping out by changing bevel property }
  { This will be linked to clicks on the TImage too }
  IconButtonPanel.BevelOuter := bvRaised;
end;

end.
