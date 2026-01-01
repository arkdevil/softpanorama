(****************************************************************)
(*                     DATABASE TOOLBOX 4.0                     *)
(*     Copyright (c) 1984, 87 by Borland International, Inc.    *)
(*                                                              *)
(*                          TADemo                              *)
(*                                                              *)
(*  Purpose: Shows how to implement a simple database using     *)
(*           the Turbo Access low-level calls.                  *)
(*                                                              *)
(****************************************************************)
Program TADemo;
uses
  DOS,
  CRT,
  TAccess;
{ If a compiler error occurs here, the Turbo Pascal compiler cannot
  find the TAccess unit.  You can compile and configure the TAccess
  unit for your database project by using the TABuild utility. See
  the manual for detailed instructions. }


{$I Tademo.typ}
const
  DataFileNm = 'CustFile.dat';
  IndexFileNm = 'CustFile.ndx';

type
  Filename = string[66];
var
  CustFile : DataFile;
  CodeIndx : IndexFile;
  Customer : CustRec;

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

procedure Pause;
var
  ch : char;
begin
  Writeln;
  Write(' Press any key to continue . . .');
  ch := ReadKey;
end; { Pause }

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

procedure OpenDataFile(var CustFile : DataFile;
                       Fname: FileName;
                       Size : integer     );
begin
  OpenFile(CustFile, fname, Size);
  if not OK then
    MakeFile(CustFile,fname,Size);
  if not Ok then
    Abort('Could not create data file: ' + FName);
end;  { OpenDataFile }


(***********************************************************************)
(*  Obtain customer information from the user to put in the data base  *)
(***********************************************************************)
procedure InputInformation(var Customer : CustRec);
begin
  Writeln;
  Writeln(' Enter Customer Information ');
  Writeln;
  with Customer do
  begin
    CustStatus := 0;
    Write('Customer code: '); Readln(CustCode);
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

function ValidRecord(var Customer : CustRec) : boolean;
begin
  ValidRecord := (Customer.CustStatus = 0);
end;

(***********************************************************************)
(*  Rebuild index files based on existing data files.                  *)
(***********************************************************************)
procedure RebuildIndex(VAR CustFile: DataFile;
                       VAR CodeIndex: IndexFile;
                       FileNm : FileName);
var
  RecordNumber : LongInt;
begin
  MakeIndex(CodeIndex,FileNm,
            SizeOf(Customer.CustCode)-1,NoDuplicates);
  if not Ok then 
    Abort('Could not Rebuild index file ' + FileNm);
  for RecordNumber := 1 to FileLen(CustFile) - 1 do
  begin
    GetRec(CustFile,RecordNumber,Customer);
    If ValidRecord(Customer)then
      AddKey(CodeIndex,RecordNumber,Customer.CustCode);
  end
end; { RebuildIndex }

(***********************************************************************)
(*  Setup index files -- open if exists, create if the user wants to.  *)
(***********************************************************************)

procedure OpenIndexFile(var CodeIndx : IndexFile;
                        Fname    : FileName;
                        KeySize  : integer;
                        Dups     : integer);
begin
  OpenIndex(CodeIndx, Fname,KeySize,Dups);
  if not OK then
    MakeIndex(CodeIndx, Fname,KeySize,Dups);
  if not OK then
    Abort('Could not create index file ' + Fname);
end; { OpenIndexFile }

(***********************************************************************)
(*  Place the customer information on the screen to be viewed          *)
(***********************************************************************)

procedure DisplayCustomer(var Customer: CustRec);
begin
  with Customer do
  begin
    Writeln;
    Writeln('   Code: ',CustCode,'    Date: ',EntryDate);
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
end;  { DisplayCustomer }

(***********************************************************************)
(*  Access the customer records sequentially  -- no index files.       *)
(***********************************************************************)
procedure ListCustomers(var CustFile: DataFile);
var
  NumberOfRecords,
  RecordNumber    : LongInt;
begin
  NumberOfRecords := FileLen(CustFile);
  Writeln('                   Customers  ');
  Writeln;
  for RecordNumber := 1 to NumberOfRecords - 1 do
  begin
    GetRec(CustFile,RecordNumber,Customer);
    if ValidRecord(Customer) then
      DisplayCustomer(Customer);
  end;
end; { ListCustomers }


(************************************************************************)
(*   Find customer based on customer code                               *)
(************************************************************************)
procedure FindCustomer(var CustFile: DataFile;
                       var CodeIndx: IndexFile );
var
  RecordNumber : LongInt;
  SearchCode   : CodeStr;
begin
  Write('Enter the Customer code: '); ReadLn(SearchCode);
  FindKey(CodeIndx,RecordNumber,SearchCode);
  if OK then
  begin
    GetRec(CustFile,RecordNumber,Customer);
    DisplayCustomer(Customer);
  end
  else
    Writeln('A record was not found for the key ',SearchCode);
end; { FindCustomer }

(************************************************************************)
(*   Search customer based on customer code                             *)
(************************************************************************)
procedure SearchCustomer(var CustFile: DataFile;
                         var CodeIndx: IndexFile );
var
  RecordNumber : LongInt;
  SearchCode   : CodeStr;
begin
  Write('Enter the Partial Customer code: '); ReadLn(SearchCode);
  SearchKey(CodeIndx,RecordNumber,SearchCode);
  if OK then
  begin
    GetRec(CustFile,RecordNumber,Customer);
    DisplayCustomer(Customer);
  end
  else
      Writeln('A record was not found greater than the key ',SearchCode);
end; { SearchCustomer }

(************************************************************************)
(*   Next customer based on customer code                               *)
(************************************************************************)
procedure NextCustomer(var CustFile: DataFile;
                       var CodeIndx: IndexFile);
var
  RecordNumber : LongInt;
  SearchCode   : CodeStr;
begin
  NextKey(CodeIndx,RecordNumber,SearchCode);
  if OK then
  begin
    GetRec(CustFile,RecordNumber,Customer);
    Write('The next customer is : ');
    DisplayCustomer(Customer);
  end
  else
    Writeln('The end of the database has been reached.');
end; { NextCustomer }

(************************************************************************)
(*   Previous customer based on customer code                           *)
(************************************************************************)
procedure PreviousCustomer(var CustFile: DataFile;
                           var CodeIndx: IndexFile);
var
  RecordNumber : LongInt;
  SearchCode   : CodeStr;
begin
  PrevKey(CodeIndx,RecordNumber,SearchCode);
  if OK then
  begin
    GetRec(CustFile,RecordNumber,Customer);
    Write('The previous customer is : ');
    DisplayCustomer(Customer);
  end
  else
    Writeln('The start of the database has been reached.');
end; { PreviousCustomer }

(****************************************************************************)
(*  AddCustomers inserts records into the data file and keys into the index *)
(****************************************************************************)

procedure AddCustomer(var CustFile: DataFile;
                      var CodeIndx: IndexFile);
var
  RecordNumber    : LongInt;
  TempCode        : CodeStr;
begin
  repeat
    InputInformation(Customer);
    TempCode := Customer.CustCode;
    FindKey(CodeIndx,RecordNumber,TempCode);
    If not OK then
    begin
      AddRec(CustFile,RecordNumber,Customer);
      AddKey(CodeIndx,RecordNumber,Customer.CustCode);
      Write('Add another record? ');
    end
    else
      Write('Duplicate code exists. Try another code? ');
  until not AnswerYes;
end; { AddCustomer }

(****************************************************************************)
(*  DeleteCustomer accepts the customer code and deletes data and key info. *)
(****************************************************************************)
procedure DeleteCustomer(var CustFile: DataFile;
                         var CodeIndx: IndexFile);
var
  RecordNumber    : LongInt;
  CustomerCode    : CodeStr;
begin
  repeat
    Write(' Enter code of customer to be deleted: ');
    Readln(CustomerCode);
    FindKey(CodeIndx,RecordNumber,CustomerCode);
    if OK then
    begin
      DeleteKey(CodeIndx,RecordNumber,CustomerCode);
      DeleteRec(CustFile,RecordNumber);
      Write('Delete another record? ');
    end
    else
      Write('Customer code was not fould. Try another code? ');
  until not AnswerYes;
end; { DeleteCustomer }

(****************************************************************************)
(* UpdateCustomer shows a customer and then allows reentry of information   *)
(****************************************************************************)
procedure UpdateCustomer(var  CustFile: DataFile;
                         var  CodeIndx: IndexFile);
var
  RecordNumber    : LongInt;
  CustomerCode    : CodeStr;
begin
  repeat
    Write('Enter code of customer to be updated: ');
    Readln(CustomerCode);
    FindKey(CodeIndx,RecordNumber,CustomerCode);
    if OK then
    begin
      GetRec(CustFile,RecordNumber,Customer);
      DisplayCustomer(Customer);
      InputInformation(Customer);
      PutRec(CustFile,RecordNumber,Customer);
      If ValidRecord(Customer) then
      begin
        DeleteKey(CodeIndx,RecordNumber,CustomerCode);
        AddKey(CodeIndx,RecordNumber,Customer.CustCode);
      end;
      Write('Update another record? ');
    end
    else
      Write('Customer code was not found. Try another code? ');
  until not AnswerYes;
end; { UpdateCustomer }

(*******************************************************************)
(*                          Main menu                              *)
(*******************************************************************)
function Menu: char;
begin
  ClrScr;
  GotoXY(1,3);
  Writeln('   Enter Number or First Letter');
  Writeln;
  Writeln(' 1)  List Customer Records ');
  Writeln(' 2)  Find a Record by Customer Code ');
  Writeln(' 3)  Search on Partial Customer Code ');
  Writeln(' 4)  Next Customer');
  Writeln(' 5)  Previous Customer');
  Writeln(' 6)  Add to Customer Database ');
  Writeln(' 7)  Update a Customer Record ');
  Writeln(' 8)  Delete a Customer Record ');
  Writeln(' 9)  Rebuild Index file ');
  Writeln(' 0)  Exit ');
  Writeln(' ');
  Menu := UpCase(ReadKey);
  Writeln;
end; { menu }

{$F+} { Force far calls for the following routine which Turbo Access }
                          { will call in the event of a fatal error. }
procedure CleanUp;
begin
  CloseIndex(CodeIndx);
  CloseFile(CustFile);
end;
{$F-}

procedure OpenDatabase;
begin
  OpenDataFile(CustFile,DataFileNm,SizeOf(CustRec));
  OpenIndexFile(CodeIndx,IndexFileNm,
                SizeOf(CodeStr)-1,NoDuplicates);
  TAErrorProc := @CleanUp; { Set up fatal error handler }
end;

(***********************************************************************)
(*                            Main program                             *)
(***********************************************************************)
var
  Finished: Boolean;
begin
  Finished := false;
  OpenDatabase;
  repeat
    case Menu of
      '1','L': ListCustomers(CustFile);
      '2','F': FindCustomer(CustFile,CodeIndx);
      '3','S': SearchCustomer(CustFile,CodeIndx);
      '4','N': NextCustomer(CustFile,CodeIndx);
      '5','P': PreviousCustomer(CustFile,CodeIndx);
      '6','A': AddCustomer(CustFile,CodeIndx);
      '7','U': UpdateCustomer(CustFile,CodeIndx);
      '8','D': DeleteCustomer(CustFile,CodeIndx);
      '9','R': begin
                 CloseIndex(CodeIndx);
                 RebuildIndex(CustFile,CodeIndx, IndexFileNm);
               end;
      '0','E': Finished := true;
      else
        Write('Choose 0-9: ');
    end; { case }
    if not Finished then
      Pause;
  until Finished;
  CleanUp;
end.
