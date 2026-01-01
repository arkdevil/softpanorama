{****************************************************************************}
{*                                                                          *}
{*      Data Encryption ToolKit. Version 1.3                                *}
{*                                                                          *}
{*      encrypt.pas -- data encryption (DES) module                         *}
{*                                                                          *}
{*      Copyright (c) 1991, 1992, Andrew Prokhorow. All rights reserved.    *}
{*                                                                          *}
{*      Purpose:                                                            *}
{*        InitEncryption -- initialize encryption with 8-byte keys.         *}
{*        EncryptBlock -- encrypt 8-byte block.                             *}
{*        EncryptionKey -- initialize encryption with pascal string key     *}
{*        DecryptionKey -- initialize decryption with pascal string key     *}
{*        EncryptArea -- encrypt sequence of 8-byte blocks.                 *}
{*        EncryptProgram -- encrypt loaded program.                         *}
{*        DecryptProgram -- decrypt loaded program.                         *}
{*        SelfEncryptStart -- get self segment address.                     *}
{*        PasswordDecryptProgram -- enter password and decrypt loaded       *}
{*        program.                                                          *}
{*                                                                          *}
{****************************************************************************}


unit Encrypt;

interface

  const
    EncryptNochain = 0;
    DecryptNochain = - 0;
    EncryptChain = 1;
    DecryptChain = - 1;
    EncryptAuth = 2;
    DecryptAuth = - 2;
    EncryptLastAuth = 3;
    DecryptLastAuth = - 3;
    EncryptFirstAuth = 4;
    DecryptFirstAuth = - 4;
    NormalEncryption = 0;
    InvalidEncryptParam = 1;
    InvalidEncryptAuth = 2;
    EncryptionKeySize = 8;
    EncryptionKeyMaxNumber = 255;
    EncryptedBlockSize = 8;
    EncryptionKeyLength = 9;
    EncryptionKeyMaxLength = EncryptionKeyLength * EncryptionKeyMaxNumber;
    EncryptedBlockMaxNumber = 4095;
    EncryptedBlockMaxSize = EncryptedBlockSize * EncryptedBlockMaxNumber;
    EncryptedFragmentMaxNumber = 84;
    EncryptionControlAreaMaxId = 9;

  procedure InitEncryption (var KeyArea, Key; NumKey: Integer);

  procedure EncryptBlock (var KeyArea, Block);

  procedure EncryptionKey (var KeyArea; KeyString: String);

  procedure DecryptionKey (var KeyArea; KeyString: String);

  procedure EncryptArea (var KeyArea, MainBlock; NumBlock: Integer;
    var AddBlock; OpCode: Integer; var ReturnCode: Integer);

  procedure EncryptProgram (var KeyArea; SegmentAddress: Word;
    var ControlArea);

  procedure DecryptProgram (var KeyArea; SegmentAddress: Word;
    var ControlArea);

  function SelfEncryptStart: Word;

  procedure PasswordDecryptProgram;

implementation

  procedure InitEncryption (var KeyArea, Key; NumKey: Integer);
    external;

  procedure EncryptBlock (var KeyArea, Block);
    external;

  procedure EncryptionKey (var KeyArea; KeyString: String);
    external;

  procedure DecryptionKey (var KeyArea; KeyString: String);
    external;

  procedure EncryptArea (var KeyArea, MainBlock; NumBlock: Integer;
    var AddBlock; OpCode: Integer; var ReturnCode: Integer);
    external;

  procedure EncryptProgram (var KeyArea; SegmentAddress: Word;
    var ControlArea);
    external;

  procedure DecryptProgram (var KeyArea; SegmentAddress: Word;
    var ControlArea);
    external;

  function SelfEncryptStart: Word;
    begin
      SelfEncryptStart := PrefixSeg + 16
    end;

  procedure PasswordDecryptProgram;
    external;

  {$l encrtpu1}
  {$l encrtpu2}
  {$l encrtpu3}
  {$l encrtpu4}
  {$l encrtpu5}

  end.
