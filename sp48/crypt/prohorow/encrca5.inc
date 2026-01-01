{****************************************************************************}
{*                                                                          *}
{*      Data Encryption ToolKit. Version 1.3                                *}
{*                                                                          *}
{*      encrca5.inc -- declare Encryption Control Area 5                    *}
{*                                                                          *}
{*      Copyright (c) 1991, 1992, Andrew Prokhorow. All rights reserved.    *}
{*                                                                          *}
{*      Purpose:                                                            *}
{*        This file declares constants that compose together                *}
{*        Encryption Control Area 5.                                        *}
{*                                                                          *}
{****************************************************************************}


const
  EncryptionControlArea5: array [1..7] of Char = 'enCrYPt';
  EncryptionControlNumber5: Char = Chr (EncryptionFragmentNumber5 + 128);
  EncryptionControlList15: String [EncryptionFragmentNumber5 * 2 - 1] = '';
  EncryptionControlList25: String [EncryptionFragmentNumber5 * 2 - 1] = '';
  EncryptionControlList35: String [EncryptionFragmentNumber5 * 2 - 1] = '';
