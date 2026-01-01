unit Main;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls,simprep,mdrep, biorep,ExtCtrls,printers, DBCtrls, DB,
  DBTables,quickrep, Spin,demopre;

type
  TTQuickReportDemo = class(TForm)
    PreviewBtn: TButton;
    PrintBtn: TButton;
    PrintDialogChk: TCheckBox;
    Bevel1: TBevel;
    ExitBtn: TButton;
    Image1: TImage;
    Shape1: TShape;
    Label2: TLabel;
    ReportCombo: TRadioGroup;
    OrientationCombo: TRadioGroup;
    Label1: TLabel;
    SpinEdit1: TSpinEdit;
    Label3: TLabel;
    PreviewCombo: TRadioGroup;
    procedure ExitBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PrintBtnClick(Sender: TObject);
    procedure PreviewBtnClick(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    procedure ShowPreview;
    procedure PreviewComboClick(Sender: TObject);
  private
    { Private declarations }
    aReport : TQuickReport;
    procedure PickReport;
  public
    { Public declarations }
  end;

var
  TQuickReportDemo: TTQuickReportDemo;

implementation

{$R *.DFM}

procedure TTQuickReportDemo.ExitBtnClick(Sender: TObject);
begin
   Close;
end;

procedure TTQuickReportDemo.FormCreate(Sender: TObject);
begin
   ReportCombo.ItemIndex:=0;
   OrientationCombo.ItemIndex:=0;
   PreviewCombo.ItemIndex:=0;
end;

procedure TTQuickReportDemo.PickReport;
begin
   case ReportCombo.ItemIndex of
      0 : aReport:=SimpForm.SimpRep;
      1 : aReport:=Bioform.BioRep;
      2 : aReport:=MDForm.MDRep;
   end;
   aReport.DisplayPrintDialog:=PrintDialogChk.Checked;
   if OrientationCombo.ItemIndex=0 then
      aReport.Orientation:=poPortrait
   else
      aReport.Orientation:=poLandscape;
end;

procedure TTQuickReportDemo.PrintBtnClick(Sender: TObject);
begin
   PickReport;
   aReport.Print;
end;

procedure TTQuickReportDemo.PreviewBtnClick(Sender: TObject);
begin
   PickReport;
   aReport.Preview;
end;

procedure TTQuickReportDemo.SpinEdit1Change(Sender: TObject);
begin
   QRPrinter.Thumbs:=SpinEdit1.Value;
end;

procedure TTQuickReportDemo.ShowPreview;
begin
   PrevForm.ShowModal;
end;

procedure TTQuickReportDemo.PreviewComboClick(Sender: TObject);
begin
   if PreviewCombo.ItemIndex=0 then
      QRPrinter.OnPreview:=nil
   else
      QRPrinter.OnPreview:=ShowPreview;
end;

end.
