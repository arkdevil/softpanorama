unit Demopre;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, Quickrep, Gauges, StdCtrls, Spin;

type
  TPrevForm = class(TForm)
    QRCustomPreview1: TQRCustomPreview;
    Panel1: TPanel;
    SpinEdit1: TSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    procedure SpinEdit1Change(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  PrevForm: TPrevForm;

implementation

{$R *.DFM}

procedure TPrevForm.SpinEdit1Change(Sender: TObject);
begin
    QRCustomPreview1.PageNumber:=Spinedit1.Value;
end;

procedure TPrevForm.FormShow(Sender: TObject);
begin
   SpinEdit1.MaxValue:=QRPrinter.PageCount;
   SpinEdit1.MinValue:=1;
   SpinEdit1.Value:=1;
   QRCustomPreview1.ZoomToFit;
end;

end.
