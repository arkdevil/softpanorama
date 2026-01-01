(****************************************************************)
(*                     DATABASE TOOLBOX 4.0                     *)
(*     Copyright (c) 1984, 87 by Borland International, Inc.    *)
(*                                                              *)
(*        HITADemo record and keys type definitions             *)
(*                                                              *)
(*  Purpose: Input file for TABuild for HITADemo                *)
(*                                                              *)
(****************************************************************)

{ type definitions for HITADemo.pas. }
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
  end; (* CustRec *)

  MaxDataType = CustRec;
  MaxKeyType = CodeStr;