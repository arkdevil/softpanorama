(****************************************************************)
(*                     DATABASE TOOLBOX 4.0                     *)
(*     Copyright (c) 1984, 87 by Borland International, Inc.    *)
(*                                                              *)
(*                        HiTADemo                              *)
(*                                                              *)
(*  Purpose: This program demonstrates the use of the Turbo     *)
(*           Access high-level calls contained in TAHigh.pas.   *)
(*           TADemo.pas is functionally equivalent to  this     *)
(*           program but uses the "lower" level Turbo Access    *)
(*           routines.                                          *)
(*                                                              *)
(****************************************************************)
program HiTADemo;
uses
  DOS,
  CRT,
  TAccess,
{ If a compiler error occurs here, the Turbo Pascal compiler cannot
  find the TAccess unit.  You can compile and configure the TAccess
  unit for your database project by using the TABuild utility. See
  the manual for detailed instructions. }

  TAHigh;

{$I HiTADemo.typ}

const
  DataFileNm = 'CustFile.dat';
  IndexFileNm = 'CustFile.ndx';

type
  Filename = string[66];

var
  Customers : DataSet;
  CustRecord : CustRec;

function AnswerYes : boolean;
var
  Response : char;
begin
  repeat
    Response := UpCase(ReadKey);
    if not (Response in ['Y','N']) then
      Write(^G);
  until Response in ['Y','N'];
  AnswerYes := Response = 'Y';
  Writeln;
end; { AnswerYes }

procedure Pause;
var
  ch : char;
begin
  Writeln;
  Write(' Press any key to continue . . .');
  ch := ReadKey;
end; { Pause }

procedure Beep;
begin
  Sound(220);
  Delay(200);
  NoSound;
end; { Beep }

procedure Abort(S : String);
begin
  Beep;
  GotoXY(1, 24);
  ClrEol;
  Write(S, ' terminating execution');
  Halt;
end;

(***********************************************************************)
(*  Obtain CustRecord information from the user to put in the data base  *)
(***********************************************************************)
procedure InputInformation(var CustRecord : CustRec);
begin
  Writeln;
  Writeln(' Enter customer Information ');
  Writeln;
  with CustRecord do
  begin
    CustStatus := 0;
    Write('customer code: '); Readln(CustCode);
    Write('Entry date   : '); Readln(EntryDate);
    Write('First name   : '); Readln(FirstName);
    Write('Last name    : '); Readln(LastName);
    Write('Company      : '); Readln(Company);
    Writeln('Address ');
    Write('   Number & Street   : '); Readln(Addr1);
    Write('   City, State & Zip : '); Readln(Addr2);
    Write('Phone     : '); Readln(Phone);
    Write('Extension : '); Readln(PhoneExt);
    Write('Remarks   : '); Readln(Remarks1);
    Write('Remarks   : '); Readln(Remarks2);
    Write('Remarks   : '); Readln(Remarks3);
  end;
  Writeln;
end; { InputInformation }


(***********************************************************************)
(*  Place the customer information on the screen to be viewed          *)
(***********************************************************************)
procedure DisplayCustomer(CustRecord: CustRec);
begin
  with CustRecord do
  begin
    Writeln;
    WriteLn('   Code: ',CustCode,'    Date: ',EntryDate);
    Writeln('   Name: ',FirstName,' ',LastName);
    WriteLn('Company: ',Company);
    Writeln('Address: ',Addr1);
    Writeln('         ',Addr2);
    Writeln('  Phone:',Phone,' ext. ',PhoneExt);
    WriteLn('Remarks: ',Remarks1);
    Writeln('         ',Remarks2);
    WriteLn('         ',Remarks3);
  end;
  Writeln;
end; { Display customer }

(********************************************************************)
(* Traverse database use TANext to list customers sequentially      *)
(********************************************************************)
procedure ListCustomers(var Customers: DataSet);
var
  Count : LongInt;
  TempCode : CodeStr;
begin
  Count := 0;
  TAReset(Customers);
  repeat
    TANext(Customers, CustRecord, TempCode);
    if Ok then
    begin
      DisplayCustomer(CustRecord);
      Count := succ(Count);
    end;
  until not Ok;
  if Count > 0 then
  begin
    Writeln;
    Writeln(Count, ' total customer(s)');
  end;
end; { ListCustomers }


(************************************************************************)
(*   Find customer based on customer code                               *)
(************************************************************************)
procedure FindCustomer(var Customers: DataSet);
var
  SearchCode : CodeStr;
begin
  Write('Enter the customer code: ');
  ReadLn(SearchCode);
  TARead(Customers, CustRecord, SearchCode, ExactMatch);
  if OK then
    DisplayCustomer(CustRecord)
  else
    Writeln('A record was not found for the key ',SearchCode);
end { FindCustomer };

(************************************************************************)
(*   Search customer based on partial customer code                     *)
(************************************************************************)
procedure SearchCustomer(var Customers: DataSet);
var
  SearchCode   : CodeStr;
begin
  Write('Enter the Partial customer code: '); ReadLn(SearchCode);
  TARead(Customers, CustRecord, SearchCode, PartialMatch);
  if OK then
    DisplayCustomer(CustRecord)
  else
    Writeln('A record was not found for the key ',SearchCode);
end { Search customer };

(************************************************************************)
(*   Next customer based on customer code                               *)
(************************************************************************)
procedure NextCustomer(var Customers: DataSet);
var
  CustomerCode   : CodeStr;
begin
  TANext(Customers,CustRecord, CustomerCode);
  if OK then
    DisplayCustomer(CustRecord)
  else
    Writeln('The end of the database has been reached.');
end; { Next customer }

(************************************************************************)
(*   Previous customer based on customer code                            *)
(************************************************************************)
procedure PreviousCustomer(var Customers: DataSet);
var
  TempCode : CodeStr;
begin
  TAPrev(Customers, CustRecord, TempCode);
  if OK then
    DisplayCustomer(CustRecord)
  else
    Writeln('The start of the database has been reached.');
end { Previous customer };

(****************************************************************************)
(*  AddCustomers inserts records into the data file and keys into the index *)
(****************************************************************************)
procedure AddCustomer(var Customers: DataSet);
var
  TempCode        : CodeStr;
begin
  repeat
    InputInformation(CustRecord);
    TempCode := CustRecord.CustCode;
    TAInsert(Customers, CustRecord, TempCode);
    if Ok then
      Write('Add another record? ')
    else
      Write('Duplicate code exists. Try another code? ');
  until not AnswerYes;
end; { AddCustomer }

(****************************************************************************)
(*  DeleteCustomer accepts the customer code and deletes data and key info. *)
(****************************************************************************)
procedure DeleteCustomer(var Customers: DataSet);
var
  CustomerCode    : CodeStr;
begin
  repeat
    Write(' Enter code of customer to be deleted: ');
    Readln(CustomerCode);
    TADelete(Customers, CustomerCode);
    if Ok then
      Write('Delete another record? ')
    else
      Write('customer code was not fould. Try another code? ');
  until not AnswerYes;
end { DeleteCustomer };

(****************************************************************************)
(* UpdateCustomer show a customer and then allow reentry of information     *)
(****************************************************************************)
procedure UpdateCustomer(var  Customers : DataSet);
var
  SearchCode    : CodeStr;
begin
  repeat
    Write('Enter code of customer to be updated: ');
    Readln(SearchCode);
    TARead(Customers, CustRecord, SearchCode, ExactMatch);
    if Ok then
    begin
      DisplayCustomer(CustRecord);
      InputInformation(CustRecord);
      if SearchCode = CustRecord.CustCode then
        TAUpdate(Customers, CustRecord, SearchCode)
      else
      begin
        TAInsert(Customers, CustRecord, CustRecord.CustCode);
        if Ok then
          TADelete(Customers, SearchCode)
        else
          Writeln('Customer Code already used');
      end;
      Write('Update another record? ');
    end
    else
      Write('customer code was not found. Try another code? ');
  until not AnswerYes;
end; { Update customer }

(****************************************************************************)
(*  Rebuild's the Data set's index file from the data file                  *)
(****************************************************************************)
procedure RebuildDatabase(var Customers : DataSet);

procedure RebuildIndex(VAR CustFile: DataFile;
                       VAR CodeIndex: IndexFile;
                       FileNm : FileName);
var
  RecordNumber : LongInt;
begin
  MakeIndex(CodeIndex,FileNm,
            SizeOf(CustRecord.CustCode)-1,NoDuplicates);
  if not Ok then
    Abort('Could not Rebuild index file ' + FileNm);
  for RecordNumber := 1 to FileLen(CustFile) - 1 do
  begin
    GetRec(CustFile,RecordNumber, CustRecord);
    If (CustRecord.CustStatus = 0) then
      AddKey(CodeIndex,RecordNumber,CustRecord.CustCode);
  end
end; { RebuildIndex }

begin { RebuildDatabase }
  with Customers do
  begin
    CloseIndex(Index);
    RebuildIndex(Data, Index, IndexFileNm);
  end;
end; { RebuildDatabase }

(*******************************************************************)
(*                          Main menu                              *)
(*******************************************************************)
function Menu: char;
begin
  ClrScr;
  GotoXY(1,3);
  Writeln('   Enter Number or First Letter');
  Writeln;
  Writeln(' 1)  List customer Records ');
  Writeln(' 2)  Find a Record by customer Code ');
  Writeln(' 3)  Search on Partial customer Code ');
  Writeln(' 4)  Next customer');
  Writeln(' 5)  Previous customer');
  Writeln(' 6)  Add to customer Database ');
  Writeln(' 7)  Update a customer Record ');
  Writeln(' 8)  Delete a customer Record ');
  Writeln(' 9)  Rebuild Index file ');
  Writeln(' 0)  Exit ');
  Writeln(' ');
  Menu := UpCase(ReadKey);
  Writeln;
end { menu };

{$F+}
procedure CleanUp;
begin
  TAClose(Customers);
end;
{$F-}

procedure SetUpDatabase(var Customers : DataSet);
begin
  TAOpen(Customers, DataFileNm,SizeOf(CustRec),
                    IndexFileNm, SizeOf(CodeStr) - 1);
  if not Ok then
    TACreate(Customers, DataFileNm, SizeOf(CustRec),
                        IndexFileNm, SizeOf(CodeStr) - 1);
  if not Ok then
    Abort('Could not create data set.');
  TAErrorProc := @CleanUp;
end; { SetUpDatabase }

(***********************************************************************)
(*                            Main program                             *)
(***********************************************************************)
var
  Finished: Boolean;

begin
  SetUpDatabase(Customers);
  Finished := false;
  repeat
    case Menu of
      '1','L': ListCustomers(Customers);
      '2','F': FindCustomer(Customers);
      '3','S': SearchCustomer(Customers);
      '4','N': NextCustomer(Customers);
      '5','P': PreviousCustomer(Customers);
      '6','A': AddCustomer(Customers);
      '7','U': UpdateCustomer(Customers);
      '8','D': DeleteCustomer(Customers);
      '9','R': RebuildDatabase(Customers);
      '0','E': Finished := true;
      else Write('Choose 0-9: ');
    end; { case }
    if not Finished then
      Pause;
  until Finished;
  CleanUp;
end.
