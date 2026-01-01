{****************************************************************************}
{*                                                                          *}
{*      Data Encryption ToolKit. Version 1.3                                *}
{*                                                                          *}
{*      encrca3.inc -- declare Encryption Control Area 3                    *}
{*                                                                          *}
{*      Copyright (c) 1991, 1992, Andrew Prokhorow. All rights reserved.    *}
{*                                                                          *}
{*      Purpose:                                                            *}
{*        This file declares constants that compose together                *}
{*        Encryption Control Area 3.                                        *}
{*                                                                          *}
{****************************************************************************}


const
  EncryptionControlArea3: array [1..7] of Char = 'enCRyPt';
  EncryptionControlNumber3: Char = Chr (EncryptionFragmentNumber3 + 128);
  EncryptionControlList13: String [EncryptionFragmentNumber3 * 2 - 1] = '';
  EncryptionControlList23: String [EncryptionFragmentNumber3 * 2 - 1] = '';
  EncryptionControlList33: String [EncryptionFragmentNumber3 * 2 - 1] = '';
