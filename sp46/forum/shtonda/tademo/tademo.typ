(****************************************************************)
(*                     DATABASE TOOLBOX 4.0                     *)
(*     Copyright (c) 1984, 87 by Borland International, Inc.    *)
(*                                                              *)
(*        TADemo record and keys type definitions               *)
(*                                                              *)
(*  Purpose: Input file for TABuild for TADemo                  *)
(*                                                              *)
(****************************************************************)

{ type definitions for TADemo.pas. }
TYPE
  CodeStr = string[15];
  CustRec = record
    CustStatus : LongInt;
    CustCode   : CodeStr;
    EntryDate  : string[8];
    FirstName  : string[15];
    LastName   : string[30];
    Company    : string[40];
    Addr1      : string[40];
    Addr2      : string[40];
    Phone      : string[15];
    PhoneExt   : string[5];
    Remarks1   : string[40];
    Remarks2   : string[40];
    Remarks3   : string[40];
  end; { CustRec }
  { The following type declarations are needed by TABuild }
  MaxDataType = CustRec;
  MaxKeyType = CodeStr;
