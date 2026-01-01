unit Biorep;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, DBCtrls, Quickrep, StdCtrls, ExtCtrls, DB, DBTables;

type
  TBioform = class(TForm)
    Table1: TTable;
    DataSource1: TDataSource;
    DetailBand: TQRBand;
    QRDBText1: TQRDBText;
    Biorep: TQuickReport;
    Table1SpeciesNo: TFloatField;
    Table1Category: TStringField;
    Table1Common_Name: TStringField;
    Table1SpeciesName: TStringField;
    Table1Lengthcm: TFloatField;
    Table1Length_In: TFloatField;
    Table1Notes: TMemoField;
    Table1Graphic: TGraphicField;
    DBImage1: TDBImage;
    QRDBText3: TQRDBText;
    QRLabel1: TQRLabel;
    QRDBText4: TQRDBText;
    QRLabel2: TQRLabel;
    QRLabel3: TQRLabel;
    QRDBText5: TQRDBText;
    QRLabel4: TQRLabel;
    TitleBand: TQRBand;
    Image1: TImage;
    QRLabel6: TQRLabel;
    QRLabel7: TQRLabel;
    QRLabel8: TQRLabel;
    QRShape2: TQRShape;
    QRLabel5: TQRLabel;
    QRDBText2: TQRDBText;
    QRBand1: TQRBand;
    QRShape1: TQRShape;
    QRBand2: TQRBand;
    QRSysData1: TQRSysData;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Bioform: TBioform;

implementation

{$R *.DFM}

end.
