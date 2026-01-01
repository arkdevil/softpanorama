{****************************************************************************}
{*                                                                          *}
{*      Data Encryption ToolKit. Version 1.3                                *}
{*                                                                          *}
{*      test5.pas -- test module for DES module 5                           *}
{*                                                                          *}
{*      Copyright (c) 1991, 1992, Andrew Prokhorow. All rights reserved.    *}
{*                                                                          *}
{*      Purpose:                                                            *}
{*        Test EncryptProgram and DecryptProgram procedures. File           *}
{*        test4.exe must be encrypted from TestValue1 to Key and from       *}
{*        TestValue2 to EncryptionControlArea0 by 'Prokhorow' key.          *}
{*                                                                          *}
{****************************************************************************}


program Test4;

  uses Encrypt;

  const
    TestValue1: array [1..5] of Integer = (1, 2, 3, 4, 5);
    Key: String = 'Prokhorow';
    TestValue2: array [1..5] of Integer = (6, 7, 8, 9, 10);
    EncryptionKeyNumber = 1;
    EncryptionFragmentNumber0 = 3;

{$i encrcon.inc}
{$i encrca0.inc}

  var
    KeyArea: array [1..EncryptionKeyAreaSize] of Char;

  procedure TestWrite;

    var
      I: Integer;

    begin
      for I := 1 to 5 do
        Write (TestValue1[I], ' ');
      for I := 1 to 5 do
        Write (TestValue2[I], ' ');
      WriteLn
    end;

  begin
    TestWrite;
    DecryptionKey (KeyArea, Key);
    DecryptProgram (KeyArea, SelfEncryptStart, EncryptionControlArea0);
    TestWrite;
    EncryptionKey (KeyArea, Key);
    EncryptProgram (KeyArea, SelfEncryptStart, EncryptionControlArea0);
    TestWrite
  end.
