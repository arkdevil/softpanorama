(****************************************************************)
(*                     DATABASE TOOLBOX 4.0                     *)
(*     Copyright (c) 1984, 87 by Borland International, Inc.    *)
(*                                                              *)
(*           BTree record and keys type definitions             *)
(*                                                              *)
(*  Purpose: Input file for TABuild for BTree                   *)
(*                                                              *)
(****************************************************************)
type
  FirstNmStr = string[15];
  ShortFirstNm = String[10];
  LastNmStr = String[30];
  ShortLastNm  = String[15];

  NameStr = String[25]; { string definition for the name key }
             { NameStr built from ShortLastNm + ShortFirstNm }
  CodeStr = string[15]; { string definition for the code key }

{  customer (maximum size) record definition }
  CustRec = record
              CustStatus : LongInt;        {   record status }
              CustCode   : CodeStr;        {   customer code }
              EntryDate  : string[8];      {      entry date }
              FirstName  : FirstNmStr;     {      first name }
              LastName   : LastNmStr;      {       last name }
              Company    : string[40];     {         company }
              Addr1      : string[40];     {  Address Line 1 }
              Addr2      : string[40];     {  Address Line 2 }
              Phone      : string[15];     {    Phone number }
              PhoneExt   : string[5];      {       extension }
              Remarks1   : string[40];     {  remarks line 1 }
              Remarks2   : string[40];     {  remarks line 2 }
              Remarks3   : string[40];     {  remarks line 3 }
            end;
MaxDataType = CustRec;
MaxKeyType =  NameStr;
