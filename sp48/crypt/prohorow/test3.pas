{****************************************************************************}
{*                                                                          *}
{*      Data Encryption ToolKit. Version 1.3                                *}
{*                                                                          *}
{*      test3.pas -- test module for DES module 3                           *}
{*                                                                          *}
{*      Copyright (c) 1991, 1992, Andrew Prokhorow. All rights reserved.    *}
{*                                                                          *}
{*      Purpose:                                                            *}
{*        Test EncryptArea procedure.                                       *}
{*                                                                          *}
{****************************************************************************}


program Test3;

  uses Encrypt;

  const
    Key: String = 'Prokhorow';
    EncryptionKeyNumber = 1;

{$i encrcon.inc}

  var
    KeyArea: array [1..EncryptionKeyAreaSize] of Char;
    TestValue: array [1..16] of Integer;
    AddValue: array [1..4] of Integer;
    RetCode: Integer;

  procedure TestInit;

    var
      I: Integer;

    begin
      RetCode := 0;
      for I := 1 to 16 do
        TestValue[I] := I
    end;

  procedure AddInit;

    var
      I: Integer;

    begin
      for I := 1 to 4 do
        AddValue[I] := I * 100;
    end;

  procedure TestWrite;

    var
      I: Integer;

    begin
      Write (RetCode, ' : ');
      for I := 1 to 16 do
        Write (TestValue[I], ' ');
      Write ('/ ');
      for I := 1 to 4 do
        Write (AddValue[I], ' ');
      WriteLn
    end;

  begin

    TestInit;
    AddInit;
    TestWrite;
    EncryptionKey (KeyArea, Key);
    EncryptArea (KeyArea, TestValue, 4, AddValue, EncryptNochain, RetCode);
    TestWrite;
    DecryptionKey (KeyArea, Key);
    EncryptArea (KeyArea, TestValue, 4, AddValue, DecryptNochain, RetCode);
    TestWrite;

    TestInit;
    AddInit;
    TestWrite;
    EncryptionKey (KeyArea, Key);
    EncryptArea (KeyArea, TestValue, 4, AddValue, EncryptChain, RetCode);
    TestWrite;
    AddInit;
    DecryptionKey (KeyArea, Key);
    EncryptArea (KeyArea, TestValue, 4, AddValue, DecryptChain, RetCode);
    TestWrite;

    TestInit;
    AddInit;
    TestWrite;
    EncryptionKey (KeyArea, Key);
    EncryptArea (KeyArea, TestValue, 4, AddValue, EncryptAuth, RetCode);
    TestWrite;
    DecryptionKey (KeyArea, Key);
    EncryptArea (KeyArea, TestValue, 4, AddValue, DecryptAuth, RetCode);
    TestWrite;

    TestInit;
    AddInit;
    TestWrite;
    EncryptionKey (KeyArea, Key);
    EncryptArea (KeyArea, TestValue, 4, AddValue, EncryptAuth, RetCode);
    TestWrite;
    AddInit;
    DecryptionKey (KeyArea, Key);
    EncryptArea (KeyArea, TestValue, 4, AddValue, DecryptAuth, RetCode);
    TestWrite;

    TestInit;
    AddInit;
    TestWrite;
    EncryptionKey (KeyArea, Key);
    EncryptArea (KeyArea, TestValue, 4, AddValue, EncryptLastAuth, RetCode);
    TestWrite;
    DecryptionKey (KeyArea, Key);
    EncryptArea (KeyArea, TestValue, 4, AddValue, DecryptLastAuth, RetCode);
    TestWrite;

    TestInit;
    AddInit;
    TestWrite;
    EncryptionKey (KeyArea, Key);
    EncryptArea (KeyArea, TestValue, 4, AddValue, EncryptFirstAuth, RetCode);
    TestWrite;
    DecryptionKey (KeyArea, Key);
    EncryptArea (KeyArea, TestValue, 4, AddValue, DecryptFirstAuth, RetCode);
    TestWrite

  end.
