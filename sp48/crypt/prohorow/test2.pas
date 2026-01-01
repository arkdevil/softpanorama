{****************************************************************************}
{*                                                                          *}
{*      Data Encryption ToolKit. Version 1.3                                *}
{*                                                                          *}
{*      test2.pas -- test module for DES module 2                           *}
{*                                                                          *}
{*      Copyright (c) 1991, 1992, Andrew Prokhorow. All rights reserved.    *}
{*                                                                          *}
{*      Purpose:                                                            *}
{*        Test EncryptionKey and DecryptionKey procedures.                  *}
{*                                                                          *}
{****************************************************************************}


program Test2;

  uses Encrypt;

  const
    TestValue: array [1..4] of Integer = (1, 2, 3, 4);
    Key: String = 'Prokhorow';
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
    EncryptionKey (KeyArea, Key);
    EncryptBlock (KeyArea, TestValue);
    TestWrite;
    DecryptionKey (KeyArea, Key);
    EncryptBlock (KeyArea, TestValue);
    TestWrite
  end.
