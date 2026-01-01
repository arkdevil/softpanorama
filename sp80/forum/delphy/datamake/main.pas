unit Main;
{ -----------------------  DataMake program --------------------------
  --  (c) 1995 E.Martin.
  --                Compuserve: 100661,3653
  --
  --    This program is a simple code generator. It's intended to produce
  --    a Unit that will create all the databases used by your application.
  --    This way, a program can be shipped without the datafiles, which can
  --    be created as needed.
  --    The program is fairly easy to use, as it is based in the DataList
  --    example program that ships with Delphi.
  --    The code generated : CreateDB.Pas is ready to be included in our project
  --      whenever you decide you can call CreateDBMS to recreate the datafiles.
  --      The code style is structured and readable (as much as this is) and can
  --      be easily modified to further specialize.
  --
  --    This program is FreeWare: use or modify at your own will.
  --
  --  Revision history:
  --  14/Jun/95 : created.
  --
  -----------------------------------------------------------------------
}


interface

uses SysUtils,WinTypes, WinProcs, Classes, Graphics, Forms, Controls,
  StdCtrls, DBTables, DB, Buttons, ExtCtrls;

type
  TForm1 = class(TForm)
    DatabaseListbox: TListBox;
    TableListbox: TListBox;
    FieldListbox: TListBox;
    IndexListbox: TListBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Table: TTable;
    SpeedButton1: TSpeedButton;
    SelectionsListBox: TListBox;
    Label5: TLabel;
    Panel1: TPanel;
    Label6: TLabel;
    procedure AddTable( table: string);
    procedure TableListboxClick(Sender: TObject);
    procedure DatabaseListboxClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TableListboxDblClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SelectionsListBoxDblClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DatabaseListboxDblClick(Sender: TObject);
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

var
  AliasList: TStringList;

procedure TForm1.TableListboxClick(Sender: TObject);
begin
  FieldListbox.Clear;
  IndexListbox.Clear;
  Table.DatabaseName := DatabaseListbox.Items[DatabaseListbox.ItemIndex];
  Table.TableName := TableListbox.Items[TableListbox.ItemIndex];
  Table.GetFieldNames(FieldListbox.Items);
  Table.GetIndexNames(IndexListbox.Items);
end;

procedure TForm1.DatabaseListboxClick(Sender: TObject);
begin
  TableListbox.Clear;
  FieldListbox.Clear;
  IndexListbox.Clear;
  Session.GetTableNames(DatabaseListbox.Items[DatabaseListbox.ItemIndex],
    '', True, False, TableListbox.Items);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Session.GetDatabaseNames(DatabaseListbox.Items);
  AliasList := TStringList.Create;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  AliasList.Free;
end;

procedure TForm1.AddTable( table: string);
var
  idx: Integer;
begin
  { Add to the SelectedList if not already there }
  for idx:= 0 to SelectionsListBox.Items.Count-1 do
    if SelectionsListBox.Items[idx] = table
       then Exit;
  SelectionsListBox.Items.Add(table);
  AliasList.Add(DatabaseListbox.Items[DatabaseListbox.ItemIndex]);
end;

procedure TForm1.DatabaseListboxDblClick(Sender: TObject);
var
  idx: Integer;
begin
  { Add all the DataBase tables to the selection list }
  {SelectionsListBox.Items.AddStrings(TableListbox.Items);}
  for idx:= 0 to TableListBox.Items.Count-1 do
     AddTable(TableListBox.Items[idx]);
end;


procedure TForm1.TableListboxDblClick(Sender: TObject);
begin
  AddTable(TableListbox.Items[TableListbox.ItemIndex]);
end;

procedure TForm1.SelectionsListBoxDblClick(Sender: TObject);
begin
  { remove elem from table }
  SelectionsListBox.Items.Delete(SelectionsListBox.ItemIndex);
end;

function GetTableType(table : tTable):string;
begin
  if Table.tableType = ttDefault then
  begin
    if CompareText(ExtractFileExt(Table.TableName), '.dbf') = 0 then
    begin
      GetTableType := 'ttDBase';
      exit;
    end
    else if CompareText(ExtractFileExt(Table.TableName), '.db') = 0 then
    begin
      GetTableType := 'ttParadox';
      exit;
    end
    else GetTableType := 'ttDefault';
  end
  else if table.tableType = ttDBase then GetTableType := 'ttDBase'
  else if Table.TableType = ttParadox then GetTableType := 'ttParadox'
  else GetTableType := 'ttASCII';
end;

function GetFieldType(fldtyp:TFieldType) : string;
begin
  case fldtyp of
    ftUnknown : Result := 'ftUnknown';
    ftString :  Result := 'ftString';
    ftSmallInt: Result := 'ftSmallInt';
    ftInteger : Result := 'ftInteger';
    ftWord :    Result := 'ftWord';
    ftBoolean:  Result := 'ftBoolean';
    ftFloat :   Result := 'ftFloat';
    ftCurrency: Result := 'ftCurrency';
    ftBCD :     Result := 'ftBCD';
    ftDate :    Result := 'ftDate';
    ftTime :    Result := 'ftTime';
    ftDateTime: Result := 'ftDateTime';
    ftBytes :   Result := 'ftBytes';
    ftVarBytes: Result := 'ftVarBytes';
    ftBlob :    Result := 'ftBlob';
    ftMemo :    Result := 'ftMemo';
    ftGraphic : Result := 'ftGraphic';
  end;
end;

function GetRequired(required:Boolean): string;
begin
  if required then Result := 'True'
    else           Result := 'False';
end;

function GetIndexOptions(Options: TIndexOptions): string;
begin
  Result := '[';
  if ixPrimary in Options then Result := Result +'ixPrimary';
  if ixUnique in Options then
  begin
     if Length(Result) > 1 then Result := Result +', ';
     Result := Result +'ixUnique';
  end;
  if ixDescending in Options then
  begin
     if Length(Result) > 1 then Result := Result +', ';
     Result := Result +'ixDescending';
  end;
  if ixExpression in Options then
  begin
     if Length(Result) > 1 then Result := Result +', ';
     Result := Result +'ixExpression';
  end;
  if ixCaseInsensitive in Options then
  begin
     if Length(Result) > 1 then Result := Result +', ';
     Result := Result +'ixCaseInsensitive';
  end;
  Result := Result+']';
end;


{ ----------------
  Code generation
  ---------------- }
procedure TForm1.SpeedButton1Click(Sender: TObject);
var
   idx, jdx: Integer;
   nl, qt, sTemp: string;
   out: TextFile;
begin
  if SelectionsListBox.Items.Count = 0 then
  begin
    Close;
    Exit;
  end;
  SetCursor(LoadCursor(0,IDC_WAIT));

  { 1- Open output file : CreateDB.pas }
  AssignFile(out, 'CreateDB.PAS');
  Rewrite(out);

  { 2- Generate common code header }
  nl := #13+#10; { newline }
  qt := #39;     { quote }
  Write(out, 'Unit CreateDB;'+nl+
             '{ Generated by DataMake (c) 1995 E. Martin'+nl+
             '      Date : '+DateToStr(Now)+' }'+nl+nl+
             'interface'+nl+nl+
             'procedure CreateDBMS;'+nl+nl+
             'implementation'+nl+nl+
             'uses DBTables, DB;'+nl+nl);
             { breaking block to prevent overflowing output buffer }
  Write(out, 'procedure CreateDBMS;'+nl+
             'var'+nl+
             '  table: TTable;'+nl+
             'begin'+nl+
             '  table := TTable.Create(nil);'+nl+
             '  with table do'+nl+
             '  begin'+
             nl);

  { 3- For each table in the Selection box }
  for idx:= 0 to SelectionsListBox.Items.Count-1 do
  begin

    { 4- Generate table structure }
    with Table do
    begin
      DatabaseName := AliasList[idx];
      TableName := SelectionsListBox.Items[idx];
      FieldDefs.Update;
      IndexDefs.Update;
      { now we have the table on-line }
      Write(out, nl+'    { Creating : '+DatabaseName+' --> '+TableName+' }'+nl+
                 '    DataBaseName := '+qt+ DatabaseName +qt+';'+nl+
                 '    TableName := '+qt+ TableName +qt+';'+nl+
                 '    TableType := '+GetTableType(Table)+';'+nl+
                 '    with FieldDefs do'+nl+
                 '    begin'+nl+
                 '      Clear;'+
                 nl);
      with FieldDefs do
      begin
        for jdx:=0 to Count-1 do
        begin
          Write(out, '      Add('+qt+Items[jdx].Name+qt+', '+
                     GetFieldType(Items[jdx].DataType)+', '+
                     IntToStr(Items[jdx].Size)+', '+
                     GetRequired(Items[jdx].Required)+');'+nl);
        end;
      end; { FieldDefs }
      Write(out, '    end; { FieldDefs }'+nl);

      { 5- Generate index structure }
      Write(out, '    with IndexDefs do'+nl+
                 '    begin'+nl+
                 '      Clear;'+nl);
      with IndexDefs do
      begin
        for jdx:=0 to Count-1 do
        begin
          Write(out, '      Add('+qt+Items[jdx].Name+qt+', '+
                     qt+Items[jdx].Fields+qt+', '+
                     GetIndexOptions(Items[jdx].Options)+');'+nl);
          if ixExpression in TIndexDef(Items[jdx]).Options  then { this would require some hardcore DBE programming }
            raise Exception.Create('SORRY: This version of DataMake doesnt support dBase Index Expressions');
        end;
      end; { IndexDefs }
      Write(out, '    end; { IndexDefs }'+nl);
    end; {table}
    Write(out, '    CreateTable;'+nl);
  end;

  { 6- Generate common code footer }
  Write(out,'  end; { table }'+nl+
            '  table.Free;'+nl+
            'end;'+nl+nl+
            'end.'+nl);

  CloseFile(out);
  SetCursor(LoadCursor(0,IDC_ARROW));
  Close;
end;

end.
