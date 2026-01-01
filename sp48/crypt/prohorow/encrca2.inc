{****************************************************************************}
{*                                                                          *}
{*      Data Encryption ToolKit. Version 1.3                                *}
{*                                                                          *}
{*      encrca2.inc -- declare Encryption Control Area 2                    *}
{*                                                                          *}
{*      Copyright (c) 1991, 1992, Andrew Prokhorow. All rights reserved.    *}
{*                                                                          *}
{*      Purpose:                                                            *}
{*        This file declares constants that compose together                *}
{*        Encryption Control Area 2.                                        *}
{*                                                                          *}
{****************************************************************************}


const
  EncryptionControlArea2: array [1..7] of Char = 'eNcrYPt';
  EncryptionControlNumber2: Char = Chr (EncryptionFragmentNumber2 + 128);
  EncryptionControlList12: String [EncryptionFragmentNumber2 * 2 - 1] = '';
  EncryptionControlList22: String [EncryptionFragmentNumber2 * 2 - 1] = '';
  EncryptionControlList32: String [EncryptionFragmentNumber2 * 2 - 1] = '';
