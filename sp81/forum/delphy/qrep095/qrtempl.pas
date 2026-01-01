unit Qrtempl;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Quickrep, ExtCtrls;

type
  TQuickReport = class(TForm)
    TitleBand: TQRBand;
    DetailBand: TQRBand;
    PageFooterBand: TQRBand;
    Rep: TQuickReport;
    DateTimeLabel: TQRSysData;
    PageNumberLabel: TQRSysData;
    QRSysData1: TQRSysData;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  QuickReport: TQuickReport;

implementation

{$R *.DFM}

end.
