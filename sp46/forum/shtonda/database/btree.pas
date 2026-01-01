(****************************************************************)
(*                     DATABASE TOOLBOX 4.0                     *)
(*     Copyright (c) 1984, 87 by Borland International, Inc.    *)
(*                                                              *)
(*                          BTree                               *)
(*                                                              *)
(*  Purpose: Implements a customer database that has 1 data     *)
(*           file and 2 index files.  Demonstrates how to       *)
(*           use Turbo Access to implement common database      *)
(*           tasks.                                             *)
(*                                                              *)
(****************************************************************)
program BTree;
uses
  CRT,
  DOS,
  TAccess,
{ If a compiler error occurs here, the Turbo Pascal compiler cannot
  find the TAccess unit.  You can compile and configure the TAccess
  unit for your database project by using the TABuild utility. See
  the manual for detailed instructions. }

  Printer,
  WindowU,
  MiscTool,
{ If a compiler error occurs here, you need to unpack the source
  to the MiscTool unit from the archived file Tools.arc.  See the
  README file on disk 1 for detailed instructions. }

  EditLn;

{$I btree.typ} { Record and key definitions }
{$V-}
var
{  global variables }
  DatF          : DataFile;
  CodeIndexFile,
  NameIndexFile : IndexFile;
  NoOfRecs      : Integer;
  Ch            : Char;
  CustCode      : CodeStr;
  FrameWindow,
  MainWindow,
  ListWindow,
  EditWindow : WindowRec;


const
  Changes : byte = 0;
    { Counter for the number of changes to the database:
        Add, Update or Delete }
  ChangesPerFlush = 5;
    { Flush the database after this many transactions. }

procedure FlushBTree;
{ Flush's the data file and index files out to disk to prevent
  corruption of the database in case of a power failure. }
begin
  Inc(Changes, 1);
  if Changes = ChangesPerFlush then
  begin
    FlushFile(DatF);
    FlushIndex(CodeIndexFile);
    FlushIndex(NameIndexFile);
    Changes := 0;
  end
end; { FlushBTree }

const
  MaxItems = 5;

type
  PromptRec = record
                PromptX : byte;
                PromptStr : string[20];
                HelpStr : string[80];
              end;
  MenuPrompts = record
                  NumItems : byte;
                  MenuRecs : array[1..MaxItems] of PromptRec;
                end;
const
  MainMenu : MenuPrompts =
             (NumItems : 4;
              MenuRecs :
                ((PromptX : 12;
                  PromptStr : 'Add';
                  HelpStr :  'Add a new record to the database'),
                 (PromptX : 28;
                  PromptStr : 'Find';
                  HelpStr : 'Search for a record on a code or name'),
                 (PromptX : 44;
                  PromptStr : 'List';
                  HelpStr : 'List Customer records to the screen or the printer'),
                 (PromptX : 60;
                  PromptStr : 'Quit';
                  HelpStr : 'Quit the program'),
                 (PromptX : 0;
                  PromptStr : '';
                  HelpStr : '')
               )
            );

   FindMenu : MenuPrompts =
              (NumItems : 5;
               MenuRecs :
                 ((PromptX : 8;
                   PromptStr : 'Update';
                   HelpStr : 'Change fields in this record'
                   ),
                   (PromptX : 20;
                    PromptStr : 'Delete';
                    HelpStr : 'Delete this record'),
                   (PromptX : 32;
                    PromptStr : 'Next';
                    HelpStr : 'Retrieve the Next record'),
                   (PromptX : 44;
                    PromptStr : 'Previous';
                    HelpStr : 'Retrieve the Previous record'),
                   (PromptX : 60;
                    PromptStr : 'Exit';
                    HelpStr : 'Exit to the previous menu')
                 )
                );

  DeviceMenu : MenuPrompts =
              (NumItems : 3;
               MenuRecs :
                 ((PromptX : 10;
                   PromptStr : 'Screen';
                   HelpStr : 'Send list of records to the screen'
                   ),
                   (PromptX : 30;
                    PromptStr : 'Printer';
                    HelpStr : 'Send list of records to the printer'),
                   (PromptX : 50;
                    PromptStr : 'Exit';
                    HelpStr : 'Exit to the previous menu'),
                   (PromptX : 0;
                    PromptStr : '';
                    HelpStr : ''),
                   (PromptX : 0;
                    PromptStr : '';
                    HelpStr : '')
                 )
                );

  SortMenu : MenuPrompts =
              (NumItems : 4;
               MenuRecs :
                 ((PromptX : 10;
                   PromptStr : 'Code';
                   HelpStr : 'Sort records by customer code'
                   ),
                   (PromptX : 26;
                    PromptStr : 'Name';
                    HelpStr : 'Sort records by last and first name'),
                   (PromptX : 40;
                    PromptStr : 'Unsorted';
                    HelpStr : 'List records in order they were entered'),
                   (PromptX : 58;
                    PromptStr : 'Exit';
                    HelpStr : 'Exit to the previous menu'),
                   (PromptX : 0;
                    PromptStr : '';
                    HelpStr : '')
                 )
                );

const
  EmptyCode = 'No Customer Code entered';
  DuplicateCode = 'Duplicate customer code';
  EmptyLName = 'No Last Name entered';

var
  PromptY,
  HelpY : byte;

procedure DrawPrompt(var CurWindow : WindowRec;
                         var CurMenu : MenuPrompts;
                         MenuNum : integer;
                         On : boolean;
                         DrawHelp : boolean);
begin
  SetWindow(CurWindow);
  if On then
    SetColor(White, Green)
  else
    SetWindowColor(CurWindow);
  with CurMenu.MenuRecs[MenuNum], CurWindow.Vis do
  begin
    GotoXY(PromptX, PromptY);
    Write(' ', PromptStr, ' ');
    if DrawHelp then
    begin
      SetColor(White, Blue);
      GotoXY(1, HelpY);
      Write(' ':succ(X2 - X1));
      GotoXY(1, HelpY);
      Write(' ', HelpStr);
    end;
  end;
  SetWindowColor(CurWindow);
end; { DrawPrompt }

procedure DrawMenu(var CurWindow : WindowRec;
                   var CurMenu : MenuPrompts;
                   StartMenu : integer);
var
  CurMenuItem : integer;
begin
  with CurWindow, CurWindow.Vis, CurMenu do
  begin
    SetWindow(CurWindow);
    HelpY := pred(Y2);
    PromptY := HelpY - 1;
    GotoXY(1, PromptY);
    Write(' ':succ(X2 - x1));
    for CurMenuItem := 1 to NumItems do
      DrawPrompt(CurWindow, CurMenu, CurMenuItem, false, false);
    DrawPrompt(CurWindow, CurMenu, StartMenu, true, true);
  end;
end; { DrawMenu }

procedure DoMenu(var CurWindow : WindowRec;
                var CurMenu : MenuPrompts;
                var CurMenuItem : integer);

function MenuKey(var CurMenu : MenuPrompts;
                 var ch : char;
                 var CurItem : integer) : boolean;
var
  Item : integer;

begin
  MenuKey := false;
  with CurMenu do
  begin
    Item := 1;
    repeat
      if (MenuRecs[Item].PromptStr[1] = ch) then
      begin
        CurItem := Item;
        MenuKey := true;
        Exit;
      end;
      Item := succ(Item);
    until (Item > NumItems);
  end;
end; { MenuKey }

var
  LastMenuItem : integer;
  MenuCh : char;
  done : boolean;

begin { DoMenu }
  DrawMenu(MainWindow, CurMenu, CurMenuItem);
  done := false;
  LastMenuItem := CurMenuItem;
  with CurWindow.Vis, CurMenu do
  begin
    repeat
      MenuCh := UpCase(scankey);
      case MenuCh of
        LeftKey : if CurMenuItem = 1 then
                    CurMenuItem := NumItems
                  else
                    CurMenuItem := pred(CurMenuItem);
        RightKey : if CurMenuItem = NumItems then
                     CurMenuItem := 1
                   else
                     CurMenuItem := succ(CurMenuItem);
        'A'..'Z' : done := MenuKey(CurMenu, MenuCh, CurMenuItem);
        CR : done := true;
        else;
      end;
      if CurMenuItem <> LastMenuItem then
      begin
        DrawPrompt(CurWindow, CurMenu, LastMenuItem, false, false);
        DrawPrompt(CurWindow, CurMenu, CurMenuItem, true, true);
      end;
      LastMenuItem := CurMenuItem;
    until done;
  end;
end; { DoMenu }

type
  EntryRec = record
               x, y, MaxLen : byte;
               Prompt : String[20];
             end;
  Fields = (CustCodeF, EntryDateF, FirstNameF, LastNameF,
            CompanyF, Addr1F, Addr2F, PhoneF, PhoneExtF,
            Remarks1F, Remarks2F,Remarks3F);

const
  EntryFields : array[Fields] of EntryRec =
   ((x : 14; y :  2; MaxLen : 15; Prompt : 'Code: '),
    (x : 40; y :  2; MaxLen :  8; Prompt : 'Date: '),
    (x : 14; y :  4; MaxLen : 15; Prompt : 'First Name: '),
    (x : 14; y :  5; MaxLen : 30; Prompt : 'Last Name: '),
    (x : 14; y :  7; MaxLen : 40; Prompt : 'Company: '),
    (x : 14; y :  9; MaxLen : 40; Prompt : 'Address 1: '),
    (x : 14; y : 10; MaxLen : 40; Prompt : 'Address 2: '),
    (x : 14; y : 12; MaxLen : 15; Prompt : 'Phone: '),
    (x : 45; y : 12; MaxLen :  5; Prompt : 'Extension: '),
    (x : 14; y : 14; MaxLen : 40; Prompt : 'Remarks 1: '),
    (x : 14; y : 15; MaxLen : 40; Prompt : 'Remarks 2: '),
    (x : 14; y : 16; MaxLen : 40; Prompt : 'Remarks 3: ')
   );

procedure OutForm;
{  OutForm displays the entry form on the screen }
var
  CurItem : Fields;
begin
  DisplayWindow(FrameWindow);
  DisplayWindow(EditWindow);
  for CurItem := CustCodeF to Remarks3F do
  with EntryFields[CurItem] do
  begin
    GotoXY(x - (Length(Prompt) + 1), y);
    Write(Prompt);
    SetColor(Black, White);
    Write(' ':MaxLen + 2);
    SetWindowColor(EditWindow);
  end;
end; { OutForm }

procedure ClearForm;
{ ClearForm clears all fields in the entry form. }
var
  CurItem : Fields;
begin
  SetWindow(EditWindow);
  SetColor(Black, White);
  for CurItem := CustCodeF to Remarks3F do
  with EntryFields[CurItem] do
  begin
    GotoXY(x - 1, Y);
    Write(' ':MaxLen + 2);
  end;
  SetWindowColor(EditWindow);
end; { ClearForm }

procedure UpdateRecCount;
var
  NumRecs : LongInt;
begin
  SetWindow(MainWindow);
  GotoXY(57, 2);
  SetColor(White, Green);
  NumRecs := UsedRecs(DatF);
  Write(' ', NumRecs:5, ' record');
  if NumRecs = 1 then
    Write('  ')
  else
    Write('s ');
  SetWindowColor(MainWindow);
end; { UpdateRecCount }

const
  Printable : CharSet = [#32..#127];
  Term : CharSet  =  [Esc, CR, Tab, F2, UpKey, DownKey, ^X, ^E];

procedure InputCust(var Cust : CustRec;
                    StartField : Fields; var TC : char);
var
  CurField : Fields;
  EntryStr : String;

begin
  SetWindow(EditWindow);
  SetColor(Black, White);
  CurField := StartField;
  repeat
    with Cust, EntryFields[CurField] do
    case CurField of
      CustCodeF  : EditLine(CustCode, MaxLen, x, y, Printable, Term, TC);
      EntryDateF : EditLine(EntryDate, MaxLen, x, y, Printable, Term, TC);
      FirstNameF : EditLine(FirstName, MaxLen, x, y, Printable, Term, TC);
      LastNameF  : EditLine(LastName, MaxLen, x, y, Printable, Term, TC);
      CompanyF   : EditLine(Company, MaxLen, x, y, Printable, Term, TC);
      Addr1F     : EditLine(Addr1, MaxLen, x, y, Printable, Term, TC);
      Addr2F     : EditLine(Addr2, MaxLen, x, y, Printable, Term, TC);
      PhoneF     : EditLine(Phone, MaxLen, x, y, Printable, Term, TC);
      PhoneExtF  : EditLine(PhoneExt, MaxLen, x, y, Printable, Term, TC);
      Remarks1F  : EditLine(Remarks1, MaxLen, x, y, Printable, Term, TC);
      Remarks2F  : EditLine(Remarks2, MaxLen, x  , y, Printable, Term, TC);
      Remarks3F  : EditLine(Remarks3, MaxLen, x, y, Printable, Term, TC);
    end;
    case TC of
      Tab,
      CR,
      ^X,
      DownKey : if CurField = Remarks3F then
                  CurField := CustCodeF
                else
                  CurField := succ(CurField);
      UpKey,
      ^E : if CurField = CustCodeF then
             CurField := Remarks3F
           else
             CurField := pred(CurField);
      else;
    end;
  until ((TC = CR) and (CurField = CustCodeF)) or
        (TC = F2) or (TC = Esc);
  SetWindowColor(EditWindow);
end;

procedure OutCust(var Cust : CustRec);
{  OutCust displays the customer data contained in Cust }
var
  CurItem : Fields;
begin
  SetWindow(EditWindow);
  SetColor(Black, White);
  for CurItem := CustCodeF to Remarks3F do
  with Cust, EntryFields[CurItem] do
  begin
    GotoXY(x - 1, y);
    Write(' ':MaxLen + 2);
    GotoXY(x, y);
    case CurItem of
      CustCodeF  : Write(CustCode);
      EntryDateF : Write(EntryDate);
      FirstNameF : Write(FirstName);
      LastNameF  : Write(LastName);
      CompanyF   : Write(Company);
      Addr1F     : Write(Addr1);
      Addr2F     : Write(Addr2);
      PhoneF     : Write(Phone);
      PhoneExtF  : Write(PhoneExt);
      Remarks1F  : Write(Remarks1);
      Remarks2F  : Write(Remarks2);
      Remarks3F  : Write(Remarks3);
    end;
  end;
  SetWindowColor(EditWindow);
end; { OutCust }


function KeyFromName(LastNm : ShortLastNm; FirstNm : ShortFirstNm) : NameStr;
const
  Blanks  =  '               ';
begin
  KeyFromName := UpcaseStr(LastNm) +
                 Copy(Blanks,1,(SizeOf(ShortLastNm) - 1) - Length(LastNm)) +
                 UpcaseStr(FirstNm);
end; { KeyFromName }


procedure Error(var CurWindow : WindowRec;
                Message : String; Noise : boolean);
const
  ErrorLine = 25;
var
  ch : char;
begin
  SetWindow(MainWindow);
  Message := ' Error: ' + Message + ' ';
  with MainWindow.Vis do
    GotoXY(1, ErrorLine);
  SetColor(White, Red);
  Write(Message);
  if Noise then
    Beep;
  GotoXY(WhereX -1, WhereY);
  ch := ScanKey;
  SetWindowColor(MainWindow);
  GotoXY(1, ErrorLine);
  with MainWindow.Vis do
    Write(' ':X2 - X1);
  SetWindow(CurWindow);
end; { Error }

type
  ScrColor = record
               Fore,
               Back : byte;
             end;
   HelpRec = record
               HelpColor : ScrColor;
               Prompts : array[1..5] of string[80]
             end;
const
  MenuHelp : HelpRec =
             (HelpColor : (Fore : White; Back : Green);
              Prompts :
              ('     '^B#17#196#217^E'-Next Field',
               '   '^B'F2'^E'-Add Record    '^B'ESC'^E'-Exit',
               '   '^B#25^E'-Next  '^B#24^E'-Previous',
               '     '^B#27^E'-Cursor Left    '^B#26^E'-Cursor Right',
               '   '^B'^Y'^E'-Delete To EOL   '^B'DEL'^E'-Delete Char'
              )
             );

procedure EditHelp;
{ Parse the prompt for highlight indicators, and display on
the screen. }

procedure Parse(CurPrompt : integer);
var
  i : integer;
begin
  with MenuHelp, HelpColor do
  begin
    SetColor(Fore, Back);
    for i := 1 to length(Prompts[CurPrompt]) do
    begin
      if Prompts[CurPrompt][i] =  ^B then
        SetColor(black, white)
      else if Prompts[CurPrompt][i] = ^E then
        SetColor(Fore, Back)
      else write(Prompts[CurPrompt][i]);
    end;
  end;
end; { Parse }

var
  CurPrompt : integer;

begin
  SetWindow(MainWindow);
  with MenuHelp.HelpColor do
    SetColor(Fore, Back);
  with MainWindow.Vis do
  begin
    GotoXY(1, Y2 - 2);
    Write(' ':succ(X2 - X1));
    GotoXY(1, Y2 - 1);
    Write(' ':succ(X2 - X1));
    GotoXY(1, Y2 - 2);
    for CurPrompt := 1 to 3 do
      Parse(CurPrompt);
    GotoXY(1, Y2 - 1);
    for CurPrompt := 4 to 5 do
      Parse(CurPrompt);
    SetWindow(EditWindow);
  end;
end; { EditHelp }


function ValidKeys(var Cust : CustRec;
                    var StartField : Fields) : boolean;
var
  RecNum : LongInt;
  Ccode : CodeStr;
  KeysOk : boolean;
  var
    ErrorStr : String;

begin
  with Cust do
  begin
    KeysOk := CustCode <> '';
    if not KeysOk then
      ErrorStr := EmptyCode
    else
    begin
      Ccode := CustCode;
      FindKey(CodeIndexFile, RecNum, Ccode);
      KeysOk := not Ok;
      if not KeysOk then
        ErrorStr := DuplicateCode;
    end;
    if KeysOk then
    begin
      KeysOk := LastName <> '';
      if not KeysOk then
      begin
        ErrorStr := EmptyLName;
        StartField := LastNameF;
      end;
    end
    else
      StartField := CustCodeF;
  end;
  if not KeysOk then
    Error(EditWindow, ErrorStr, true);
  ValidKeys := KeysOk;
end; { ValidKeys }


procedure Add;
{  Add is used to add customers }
var
  RecNum : LongInt;
  KeyN  : string[25];
  Cust  : CustRec;
  TC    : char;
  StartField : Fields;
  KeysOk : boolean;

begin
  EditHelp;
  repeat
    with Cust do
    begin
      FillChar(Cust,SizeOf(Cust),0);
      StartField := CustCodeF;
      repeat
        InputCust(Cust, StartField, TC);
        if TC <> Esc then
          KeysOk := ValidKeys(Cust, StartField);
      until KeysOk or (TC = Esc);
      if TC <> Esc then
      begin
        AddRec(DatF,RecNum,Cust);
        AddKey(CodeIndexFile, RecNum,CustCode);
        KeyN := KeyFromName(LastName,FirstName);
        AddKey(NameIndexFile, RecNum,KeyN);
        FlushBTree;
      end;
    end; { with }
    UpdateRecCount;
    ClearForm;
  until TC = Esc;
end; { Add }


procedure Find;
{  Find is used to find, edit and delete customers }
var
  KeyN    : NameStr;

function FindRecord(var RecNum : LongInt;
                    var CodeSearch : boolean) : boolean;
var
  CurField : Fields;
  CCode    : CodeStr;
  FirstNm  : ShortFirstNm;
  LastNm   : ShortLastNm;
  PNm      : NameStr;
  TC       : Char;

begin
  CurField := CustCodeF;
  CCode := '';
  CodeSearch := true;
  repeat
    SetWindow(EditWindow);
    SetColor(Black, White);
    with EntryFields[CurField] do
      EditLine(CCode,MaxLen, x, y, Printable, [CR, Esc, F2],TC);
      if TC = Esc then
      begin
        FindRecord := false;
        Exit;
      end;
      if CCode <> '' then
      begin
        FindKey(CodeIndexFile, RecNum, CCode);
        if not OK then
          Error(EditWindow, 'Customer code not found', false);
      end;
  until OK or (CCode = '');
  if CCode = '' then
  begin
    CodeSearch := false;
    CurField := FirstNameF;
    FirstNm := '';
    LastNm := '';
    SetWindow(EditWindow);
    SetColor(Black, White);
    repeat
      with EntryFields[CurField] do
      case CurField of
        FirstNameF :begin
                      EditLine(FirstNm,MaxLen,x,y,Printable,[CR, Esc, F2],TC);
                      CurField := LastNameF;
                    end;
        LastNameF : begin
                      EditLine(LastNm,MaxLen,x,y,Printable, [CR, Esc, F2],TC);
                      CurField := CustCodeF;
                    end;
           else
        end;
    until (TC <> CR) or (CurField = CustCodeF);
    if TC = Esc then
    begin
      FindRecord := false;
      Exit;
    end;
    KeyN := KeyFromName(LastNm,FirstNm);
    SearchKey(NameIndexFile, RecNum,KeyN);
    if not OK then
      PrevKey(NameIndexFile,RecNum,KeyN);
  end; { if }
  SetWindowColor(EditWindow);
  FindRecord := True;
end; { FindRecord }

procedure EditRecord(var Cust : CustRec;
                     RecNum : LongInt);
var
  TempNum : LongInt;
  TC : char;
  SaveCode,
  CCode : CodeStr;
  SaveName : NameStr;
  UpdateOk : boolean;
  SaveCust : CustRec;


begin
  EditHelp;
  with Cust do
  begin
    SaveCust := Cust;
    SaveCode := CustCode;
    SaveName := KeyFromName(LastName,FirstName);
    repeat
      InputCust(Cust, CustCodeF, TC);
      if TC = Esc then
      begin
        Cust := SaveCust;
        OutCust(Cust);
        Exit;
      end;
      UpdateOk := CustCode = SaveCode;
      if not UpdateOk then
      begin
        CCode := CustCode;
        FindKey(CodeIndexFile, TempNum, CCode);
        UpdateOk := not Ok;
      end;
      if not UpdateOk then
      begin
        Error(EditWindow, 'Customer Code taken by another record', true);
        CustCode := SaveCode;
        OutCust(Cust);
      end;
    until UpdateOk;
    PutRec(DatF, RecNum,Cust);
    if CustCode <> SaveCode then
    begin
      DeleteKey(CodeIndexFile, RecNum, SaveCode);
      AddKey(CodeIndexFile, RecNum, CustCode);
    end;
    KeyN := KeyFromName(LastName,FirstName);
    if KeyN <> SaveName then
    begin
      DeleteKey(NameIndexFile, RecNum, SaveName);
      AddKey(NameIndexFile, RecNum,KeyN);
    end;
    FlushBTree;
  end; { with }
end; { EditRecord }

procedure DeleteRecord(var Cust : CustRec;
                       var RecNum : LongInt;
                       CodeSearch : boolean);
begin
  with Cust do
  begin
    DeleteKey(CodeIndexFile,RecNum,CustCode);
    KeyN := KeyFromName(LastName,FirstName);
    if not Ok then
      Exit;
    DeleteKey(NameIndexFile,RecNum,KeyN);
    if not Ok then
      Exit;
    DeleteRec(DatF,RecNum);
    FlushBTree;
    UpdateRecCount;
    if (UsedRecs(DatF) > 0) and OK then
    begin
      if CodeSearch then
      begin
        SearchKey(CodeIndexFile, RecNum, CustCode);
        if not OK  then
          PrevKey(CodeIndexFile, RecNum, CustCode)
      end
      else
      begin
        SearchKey(NameIndexFile, RecNum, KeyN);
        if not OK  then
          PrevKey(NameIndexFile, RecNum, KeyN)
      end;
    end
    else
      Error(EditWindow, 'The database is now empty', false);
  end; { with }
end; { DeleteRecord }

procedure NextRecord(var RecNum : LongInt; CodeSearch : boolean);
begin
  if CodeSearch then
  begin
    NextKey(CodeIndexFile, RecNum,KeyN);
    if not Ok then
      begin
        Error(EditWindow, 'Last Code in the database, wrap to beginning', false);
        NextKey(CodeIndexFile, RecNum,KeyN);
      end
  end
  else
  begin
    NextKey(NameIndexFile, RecNum,KeyN);
    if not Ok then
    begin
      Error(EditWindow, 'Last Name in the database, wrap to beginning', false);
      NextKey(NameIndexFile, RecNum, KeyN);
    end
  end
end; { NextRecord }

procedure PreviousRecord(var RecNum : LongInt; CodeSearch : boolean);
begin
  if CodeSearch then
  begin
    PrevKey(CodeIndexFile, RecNum, KeyN);
    if not Ok then
    begin
      Error(EditWindow, 'First code in the database, Wrap to End', false);
      PrevKey(CodeIndexFile, RecNum, KeyN);
    end;
  end
  else
  begin
    PrevKey(NameIndexFile, RecNum, KeyN);
    if not Ok then
    begin
      Error(EditWindow, 'First name in the database, Wrap to end', false);
      PrevKey(NameIndexFile, RecNum, KeyN);
    end;
  end;
end; { PreviousRecord }


const
  UpdateItem   = 1;
  DeleteItem   = 2;
  NextItem     = 3;
  PreviousItem = 4;
  ExitItem     = 5;

var
  MenuItem : integer;
  RecNum   : LongInt;
  Cust    : CustRec;
  CodeSearch : boolean;

begin { Find }
  if FindRecord(RecNum, CodeSearch) then
  begin
    MenuItem := UpdateItem;
    repeat
      GetRec(DatF, RecNum, Cust);
      OutCust(Cust);
      DoMenu(MainWindow, FindMenu, MenuItem);
      case MenuItem of
        UpdateItem   : EditRecord(Cust, RecNum);
        DeleteItem   : DeleteRecord(Cust, RecNum, CodeSearch);
        NextItem     : NextRecord(RecNum, CodeSearch);
        PreviousItem : PreviousRecord(RecNum, CodeSearch);
        else;
      end;
    until (MenuItem = ExitItem) or (UsedRecs(DatF) = 0);
  end;
end; { Find }

procedure List;
{  List is used to list customers }
const
  ScreenDev  = 1;
  PrinterDev = 2;
  CodeSearch = 1;
  NameSearch = 2;
  Unsorted   = 3;
var
  D, LD   : LongInt;
  Ch : char;
  LDevice,
  SearchType  : integer;
  Name     : string[35];
  Cust     : CustRec;
  Pause,
  Done : boolean;

function SelectDevice(var LDevice : integer) : boolean;
begin
  LDevice := ScreenDev;
  DoMenu(MainWindow, DeviceMenu, LDevice);
  SelectDevice := LDevice <> 3;
end; { SelectDevice }

function SelectKey(var SearchType : integer) : boolean;
begin
  SearchType := CodeSearch;
  DoMenu(MainWindow, SortMenu, SearchType);
  SelectKey := SearchType <> 4;
end; { SelectKey }

procedure ListPrompt(var Pause : boolean);
var
  SaveX,
  SaveY : byte;
begin
  SaveX := WhereX; SaveY := WhereY;
  SetWindow(MainWindow);
  with MainWindow.Vis do
    GotoXY(1, Y2);
  ClrEol;
  with MainWindow.Vis do
    GotoXY(1, Y2);
  SetColor(Black, White);
  Pause := not Pause;
  if not Pause then
    Write(' SPACE - pause ')
  else
    Write(' SPACE - continue ');
  SetColor(White, Red);
  Write(' Esc - Exit ');
  SetWindow(ListWindow);
  GotoXY(SaveX, SaveY);
end;  { ListPrompt }

procedure ListExit;
var
  ch : char;
begin
  SetWindow(MainWindow);
  with MainWindow.Vis do
  begin
    GotoXY(1, Y2);
    SetColor(White, Red);
    Write(' ':X2 - X1);
    GotoXY(1, Y2);
  end;
  Write('Hit any key to continue');
  ch := ScanKey;
  EraseWindow(ListWindow);
end; { ListExit }

procedure KeyCheck;
begin
  if KeyPressed then
  begin
    ch := ReadKey;
    if Ch = Esc then
      done := true
    else
      if ch = ' ' then
        ListPrompt(Pause);
  end;
end; { KeyCheck }

procedure GetNextRecord;
var
  Ccode    : CodeStr;
  KeyN     : NameStr;
begin
  case SearchType of
    CodeSearch : NextKey(CodeIndexFile,D,Ccode);
    NameSearch : NextKey(NameIndexFile,D,KeyN);
    Unsorted : begin
                 OK := false;
                 while (D < LD) and not OK do
                 begin
                   D := D + 1;
                   GetRec(DatF,D,Cust);
                   OK := Cust.CustStatus = 0;
                 end;
                 Delay(200);
               end;
    end;
    if OK and (SearchType <> UnSorted) then
      GetRec(DatF,D,Cust);
end; { GetNextRecord }

procedure DisplayRecord;
begin
  with Cust do
  begin
    Write(CustCode, ' ':16 - Length(CustCode));
    Write(Name, ' ':31 - Length(Name));
    if Phone <> '' then
    begin
      Write(Phone);
      if PhoneExt <> '' then
        Write(' ext. ', PhoneExt);
    end;
  end;
  Writeln;
  Delay(70);  { Slow down screen output }
end; { DisplayRecord }

procedure PrintRecord;
begin
  with Cust do
  begin
    Write(LST, CustCode, ' ':16 - Length(CustCode));
    Write(LST, Name, ' ':31 - Length(Name));
    if Phone <> '' then
    begin
      Write(LST, Phone);
      if PhoneExt <> '' then
        Write(LST, ' ext. ', PhoneExt);
    end;
  end;
  Writeln(LST);
end; { PrintRecord }

begin { List }
  repeat
    if not SelectDevice(LDevice) then
      Exit;
  until Selectkey(SearchType);
  EraseWindow(MainWindow);
  DisplayWindow(ListWindow);
  Pause := true;
  Done := false;
  GotoXY(1, 1);
  ListPrompt(Pause);
  ClearKey(CodeIndexFile);
  ClearKey(NameIndexFile);
  D := 0;
  LD := FileLen(DatF) - 1;
  repeat
    KeyCheck;
    if not Pause and not Done then
    begin
      GetNextRecord;
      if Ok then
        with Cust do
        begin
          Name := Cust.LastName;
          if FirstName <> '' then
            Name := Name + ', ' + FirstName;
          if LDevice = ScreenDev then
             DisplayRecord
          else
            PrintRecord;
        end;
      end;
  until not OK or done;
  if LDevice = ScreenDev then
    ListExit;
end; { List }

procedure CleanUp;
begin
  CloseFile(DatF);
  CloseIndex(CodeIndexFile);
  CloseIndex(NameIndexFile);
  NormVideo;
  Window(1, 1, 80, 25);
  ClrScr;
end; { Cleanup }

procedure OpenDatabase;
begin
  OpenFile(DatF,'CUST.DAT',SizeOf(CustRec));
  if OK then
    OpenIndex(CodeIndexFile,'CUST.IXC',15,0);
  if OK then
    OpenIndex(NameIndexFile,'CUST.IXN',25,1);
  if not OK then
  begin
    MakeFile(DatF,'CUST.DAT',SizeOf(CustRec));
    MakeIndex(CodeIndexFile,'CUST.IXC',SizeOf(CodeStr) - 1,0);
    MakeIndex(NameIndexFile,'CUST.IXN',SizeOf(NameStr) - 1,1);
    FlushBTree;
  end;
end; { OpenDatabase }


const
  SelectAdd = 1;
  SelectFind = 2;
  SelectList = 3;
  SelectQuit = 4;

var
  MenuItem : integer;
  done : boolean;

procedure SetUp;
begin
  OpenDatabase;
  NewWindow(ListWindow, 'Customer Phone List',
            1, 1, 79, 24, White, Blue, Yellow, false);
  NewWindow(EditWindow, 'Customer Record',
            10, 3, 71, 20, White, Blue, Yellow, false);
  NewWindow(MainWindow, '',
            1, 1, 80, 25, White, Black, Black, true);
  NewWindow(FrameWindow, 'Customer Database Example',
            1, 1, 80, 22, White, Black, Red, false);
  OutForm;
  UpdateRecCount;
  MenuItem := 1;
  done := false;
end; { SetUp }

begin
  SetUp;
  repeat
    SetWindow(MainWindow);
    DoMenu(MainWindow, MainMenu, MenuItem);
    case MenuItem of
      SelectAdd  : Add;
      SelectFind : if UsedRecs(DatF) > 0 then
                   begin
                     Find;
                     UpdateRecCount;
                     ClearForm;
                   end
                   else
                   begin
                     Error(MainWindow, 'Database empty', false);
                     MenuItem := SelectAdd;
                   end;
      SelectList : if UsedRecs(DatF) > 0 then
                   begin
                     List;
                     DisplayWindow(MainWindow);
                     OutForm;
                   end
                   else
                   begin
                     Error(MainWindow, 'Database empty', false);
                     MenuItem := SelectAdd;
                   end;
      SelectQuit : done := true;
    end;
    if not Done then
      UpdateRecCount;
  until done;
  Cleanup;
end.