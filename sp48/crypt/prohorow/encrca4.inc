{****************************************************************************}
{*                                                                          *}
{*      Data Encryption ToolKit. Version 1.3                                *}
{*                                                                          *}
{*      encrca4.inc -- declare Encryption Control Area 4                    *}
{*                                                                          *}
{*      Copyright (c) 1991, 1992, Andrew Prokhorow. All rights reserved.    *}
{*                                                                          *}
{*      Purpose:                                                            *}
{*        This file declares constants that compose together                *}
{*        Encryption Control Area 4.                                        *}
{*                                                                          *}
{****************************************************************************}


const
  EncryptionControlArea4: array [1..7] of Char = 'eNcRYpt';
  EncryptionControlNumber4: Char = Chr (EncryptionFragmentNumber4 + 128);
  EncryptionControlList14: String [EncryptionFragmentNumber4 * 2 - 1] = '';
  EncryptionControlList24: String [EncryptionFragmentNumber4 * 2 - 1] = '';
  EncryptionControlList34: String [EncryptionFragmentNumber4 * 2 - 1] = '';
