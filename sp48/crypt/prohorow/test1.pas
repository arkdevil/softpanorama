{****************************************************************************}
{*                                                                          *}
{*      Data Encryption ToolKit. Version 1.3                                *}
{*                                                                          *}
{*      test1.pas -- test module for DES module 1                           *}
{*                                                                          *}
{*      Copyright (c) 1991, 1992, Andrew Prokhorow. All rights reserved.    *}
{*                                                                          *}
{*      Purpose:                                                            *}
{*        Test InitEncryption and EncryptBlock procedures.                  *}
{*                                                                          *}
{****************************************************************************}


program Test1;

  uses Encrypt;

  const
    TestValue: array [1..4] of Integer = (1, 2, 3, 4);
    Key: array [1..4] of Integer = (100, 200, 300, 400);
    EncryptionKeyNumber = 1;

{$i encrcon.inc}

  var
    KeyArea: array [1..EncryptionKeyAreaSize] of Char;

  procedure TestWrite;

    var
      I: Integer;

    begin
      for I := 1 to 4 do
        Write (TestValue[I], ' ');
      WriteLn
    end;

  begin
    TestWrite;
    InitEncryption (KeyArea, Key, EncryptionKeyNumber);
    EncryptBlock (KeyArea, TestValue);
    TestWrite;
    InitEncryption (KeyArea, Key, - EncryptionKeyNumber);
    EncryptBlock (KeyArea, TestValue);
    TestWrite
  end.
