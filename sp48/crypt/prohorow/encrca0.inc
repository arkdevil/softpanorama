{****************************************************************************}
{*                                                                          *}
{*      Data Encryption ToolKit. Version 1.3                                *}
{*                                                                          *}
{*      encrca0.inc -- declare Encryption Control Area 0                    *}
{*                                                                          *}
{*      Copyright (c) 1991, 1992, Andrew Prokhorow. All rights reserved.    *}
{*                                                                          *}
{*      Purpose:                                                            *}
{*        This file declares constants that compose together                *}
{*        Encryption Control Area 0.                                        *}
{*                                                                          *}
{****************************************************************************}


const
  EncryptionControlArea0: array [1..7] of Char = 'eNcRyPt';
  EncryptionControlNumber0: Char = Chr (EncryptionFragmentNumber0 + 128);
  EncryptionControlList10: String [EncryptionFragmentNumber0 * 2 - 1] = '';
  EncryptionControlList20: String [EncryptionFragmentNumber0 * 2 - 1] = '';
  EncryptionControlList30: String [EncryptionFragmentNumber0 * 2 - 1] = '';
