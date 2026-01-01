unit Simprep;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Quickrep, DB, DBTables, StdCtrls, ExtCtrls;

type
  TSimpForm = class(TForm)
    SimpRep: TQuickReport;
    TitleBand: TQRBand;
    Image1: TImage;
    QRLabel1: TQRLabel;
    QRLabel2: TQRLabel;
    DetailBand: TQRBand;
    Table1: TTable;
    DataSource1: TDataSource;
    QRDBText1: TQRDBText;
    QRDBText2: TQRDBText;
    QRLabel3: TQRLabel;
    QRDBText3: TQRDBText;
    QRDBText4: TQRDBText;
    QRDBText5: TQRDBText;
    PageFooterBand: TQRBand;
    QRSysData1: TQRSysData;
    QRShape1: TQRShape;
    QRLabel4: TQRLabel;
    QRLabel5: TQRLabel;
    QRLabel6: TQRLabel;
    QRLabel7: TQRLabel;
    QRLabel8: TQRLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SimpForm: TSimpForm;

implementation

{$R *.DFM}

end.
