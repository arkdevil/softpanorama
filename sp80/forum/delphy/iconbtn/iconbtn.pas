unit Iconbtn;

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
  Icon1 := TIcon.Create;
  Icon1.Handle := LoadIcon( hInstance , 'HELP' );
  IconbuttonImage.Picture.Graphic := Icon1;
end;

procedure TIconButtonDemo.IconButtonPanelMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  IconButtonPanel.BevelOuter := bvLowered;
  Invalidate;
end;

procedure TIconButtonDemo.IconButtonPanelMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  IconButtonPanel.BevelOuter := bvRaised;
  Invalidate;
end;

end.
