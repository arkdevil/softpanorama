unit Ap_testm;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, Alphabar, DB, DBTables, Grids,
  DBGrids, Menus;

type
  TMainform = class(TForm)
    EmployeeTable: TTable;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    EmployeeTableLastName: TStringField;
    EmployeeTableFirstName: TStringField;
    EmployeeTableSalary: TFloatField;
    PanelKind: TRadioGroup;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Label1: TLabel;
    Label2: TLabel;
    SymbolEdit: TEdit;
    SymbolPanel: TAlphaPanel;
    AlphaPanel: TAlphaPanel;
    PopupMenu1: TPopupMenu;
    pomIndexPanel: TMenuItem;
    pomFilterPanel: TMenuItem;
    procedure PanelKindClick(Sender: TObject);
    procedure AlphaPanelValueChange(Sender: TObject);
    procedure pomIndexPanelClick(Sender: TObject);
    procedure pomFilterPanelClick(Sender: TObject);
    procedure SymbolPanelValueChange(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Mainform: TMainform;

implementation

{$R *.DFM}

procedure TMainform.PanelKindClick(Sender: TObject);
begin
  case PanelKind.ItemIndex of
    0 : begin {** Index panel }
          EmployeeTable.CancelRange;
          AlphaPanel.CatchButtons := false;
          AlphaPanel.Hint := 'click to move the table cursor';
        end;
    1 : begin {** Filter panel }
          AlphaPanel.CatchButtons := true;
          AlphaPanel.ActiveButton := #0;
          AlphaPanel.Hint := 'click to activate/deactivate a filter';
        end;
  end;
end;

procedure TMainform.AlphaPanelValueChange(Sender: TObject);
begin
  case PanelKind.ItemIndex of
    0 : EmployeeTable.FindNearest([AlphaPanel.ActiveButton]);
    1 : begin
          if AlphaPanel.ActiveButton = #0 then
          begin
            EmployeeTable.CancelRange;
            EmployeeTable.First;
          end
          else
            with EmployeeTable do
            begin
              EditRangeStart;
              FieldByName('LastName').AsString := AlphaPanel.ActiveButton;
              EditRangeEnd;
              FieldByName('LastName').AsString := chr(ord(AlphaPanel.ActiveButton) + 1);
              ApplyRange;
            end;
        end;
  end;
end;

procedure TMainform.pomIndexPanelClick(Sender: TObject);
begin
  pomIndexPanel.Checked := true;
  pomFilterPanel.Checked := false;
  PanelKind.ItemIndex := 0;
end;

procedure TMainform.pomFilterPanelClick(Sender: TObject);
begin
  pomIndexPanel.Checked := false;
  pomFilterPanel.Checked := true;
  PanelKind.ItemIndex := 1;
end;

procedure TMainform.SymbolPanelValueChange(Sender: TObject);
begin
  SymbolEdit.Text := SymbolEdit.Text + SymbolPanel.ActiveButton;
end;

end.
