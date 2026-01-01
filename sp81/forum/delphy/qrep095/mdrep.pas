unit Mdrep;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Quickrep, DB, DBTables, ExtCtrls, Buttons, Spin;

type
  TMDForm = class(TForm)
    MDRep: TQuickReport;
    Title: TQRBand;
    CustomerHeading: TQRBand;
    CustomerGroup: TQRGroup;
    QRDBText1: TQRDBText;
    QRLabel3: TQRLabel;
    QRLabel4: TQRLabel;
    QRDBText3: TQRDBText;
    QRDBText4: TQRDBText;
    QRLabel5: TQRLabel;
    QRDBText5: TQRDBText;
    CustomerFooter: TQRBand;
    QRDBCalc1: TQRDBCalc;
    QRLabel7: TQRLabel;
    PageFooter: TQRBand;
    QRLabel8: TQRLabel;
    QRSysData1: TQRSysData;
    Summary: TQRBand;
    QRSysData2: TQRSysData;
    QRLabel13: TQRLabel;
    QRLabel12: TQRLabel;
    QRLabel11: TQRLabel;
    QRLabel10: TQRLabel;
    QRLabel9: TQRLabel;
    QRLabel14: TQRLabel;
    Detail: TQRBand;
    QRDBText2: TQRDBText;
    QRDBText7: TQRDBText;
    QRDBText9: TQRDBText;
    QRDBText10: TQRDBText;
    QRDBText11: TQRDBText;
    QRDBText6: TQRDBText;
    QRDBCalc2: TQRDBCalc;
    QRLabel6: TQRLabel;
    CustomerTable: TTable;
    OrdersTable: TTable;
    CustomerDS: TDataSource;
    OrderDS: TDataSource;
    OrdersTableOrderNo: TFloatField;
    OrdersTableSaleDate: TDateTimeField;
    OrdersTableItemsTotal: TCurrencyField;
    OrdersTableTaxRate: TFloatField;
    OrdersTableFreight: TCurrencyField;
    OrdersTableAmountPaid: TCurrencyField;
    CustomerTableCustNo: TFloatField;
    CustomerTableCompany: TStringField;
    CustomerTablePhone: TStringField;
    CustomerTableFAX: TStringField;
    CustomerTableContact: TStringField;
    OrdersTableCustNo: TFloatField;
    QRLabel15: TQRLabel;
    Image1: TImage;
    QRLabel1: TQRLabel;
    QRLabel16: TQRLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MDForm: TMDForm;

implementation

{$R *.DFM}

end.
