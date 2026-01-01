{****************************************************************************}
{*                                                                          *}
{*      Data Encryption ToolKit. Version 1.3                                *}
{*                                                                          *}
{*      encrca7.inc -- declare Encryption Control Area 7                    *}
{*                                                                          *}
{*      Copyright (c) 1991, 1992, Andrew Prokhorow. All rights reserved.    *}
{*                                                                          *}
{*      Purpose:                                                            *}
{*        This file declares constants that compose together                *}
{*        Encryption Control Area 7.                                        *}
{*                                                                          *}
{****************************************************************************}


const
  EncryptionControlArea7: array [1..7] of Char = 'encRYPt';
  EncryptionControlNumber7: Char = Chr (EncryptionFragmentNumber7 + 128);
  EncryptionControlList17: String [EncryptionFragmentNumber7 * 2 - 1] = '';
  EncryptionControlList27: String [EncryptionFragmentNumber7 * 2 - 1] = '';
  EncryptionControlList37: String [EncryptionFragmentNumber7 * 2 - 1] = '';
