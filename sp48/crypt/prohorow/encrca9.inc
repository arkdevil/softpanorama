{****************************************************************************}
{*                                                                          *}
{*      Data Encryption ToolKit. Version 1.3                                *}
{*                                                                          *}
{*      encrca9.inc -- declare Encryption Control Area 9                    *}
{*                                                                          *}
{*      Copyright (c) 1991, 1992, Andrew Prokhorow. All rights reserved.    *}
{*                                                                          *}
{*      Purpose:                                                            *}
{*        This file declares constants that compose together                *}
{*        Encryption Control Area 9.                                        *}
{*                                                                          *}
{****************************************************************************}


const
  EncryptionControlArea9: array [1..7] of Char = 'enCRYpt';
  EncryptionControlNumber9: Char = Chr (EncryptionFragmentNumber9 + 128);
  EncryptionControlList19: String [EncryptionFragmentNumber9 * 2 - 1] = '';
  EncryptionControlList29: String [EncryptionFragmentNumber9 * 2 - 1] = '';
  EncryptionControlList39: String [EncryptionFragmentNumber9 * 2 - 1] = '';
