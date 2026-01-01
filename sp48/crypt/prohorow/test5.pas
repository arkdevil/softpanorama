{****************************************************************************}
{*                                                                          *}
{*      Data Encryption ToolKit. Version 1.3                                *}
{*                                                                          *}
{*      test5.pas -- test module for DES module 5                           *}
{*                                                                          *}
{*      Copyright (c) 1991, 1992, Andrew Prokhorow. All rights reserved.    *}
{*                                                                          *}
{*      Purpose:                                                            *}
{*        Test PasswordDecryptProgram procedure. File test5.exe must be     *}
{*        encrypted from Test to @ and from TestValue to Incorrect          *}
{*        by arbitrary key (password).                                      *}
{*                                                                          *}
{****************************************************************************}


program Test5;

  uses Encrypt;

  const
    TestValue: LongInt = 0;
    Correct: String = 'Password correct';
    Incorrect: String = 'Password incorrect';

  procedure Test;
    begin
      WriteLn (Correct)
    end;

  begin
    PasswordDecryptProgram;
    if TestValue <> 0 then
      begin
        WriteLn (Incorrect);
        Halt (1)
      end;
    Test;
    Halt (0)
  end.
