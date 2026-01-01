{****************************************************************************}
{*                                                                          *}
{*      Data Encryption ToolKit. Version 1.3                                *}
{*                                                                          *}
{*      encrca8.inc -- declare Encryption Control Area 8                    *}
{*                                                                          *}
{*      Copyright (c) 1991, 1992, Andrew Prokhorow. All rights reserved.    *}
{*                                                                          *}
{*      Purpose:                                                            *}
{*        This file declares constants that compose together                *}
{*        Encryption Control Area 8.                                        *}
{*                                                                          *}
{****************************************************************************}


const
  EncryptionControlArea8: array [1..7] of Char = 'eNCRypt';
  EncryptionControlNumber8: Char = Chr (EncryptionFragmentNumber8 + 128);
  EncryptionControlList18: String [EncryptionFragmentNumber8 * 2 - 1] = '';
  EncryptionControlList28: String [EncryptionFragmentNumber8 * 2 - 1] = '';
  EncryptionControlList38: String [EncryptionFragmentNumber8 * 2 - 1] = '';
