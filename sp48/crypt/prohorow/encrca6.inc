{****************************************************************************}
{*                                                                          *}
{*      Data Encryption ToolKit. Version 1.3                                *}
{*                                                                          *}
{*      encrca6.inc -- declare Encryption Control Area 6                    *}
{*                                                                          *}
{*      Copyright (c) 1991, 1992, Andrew Prokhorow. All rights reserved.    *}
{*                                                                          *}
{*      Purpose:                                                            *}
{*        This file declares constants that compose together                *}
{*        Encryption Control Area 6.                                        *}
{*                                                                          *}
{****************************************************************************}


const
  EncryptionControlArea6: array [1..7] of Char = 'eNCrYpt';
  EncryptionControlNumber6: Char = Chr (EncryptionFragmentNumber6 + 128);
  EncryptionControlList16: String [EncryptionFragmentNumber6 * 2 - 1] = '';
  EncryptionControlList26: String [EncryptionFragmentNumber6 * 2 - 1] = '';
  EncryptionControlList36: String [EncryptionFragmentNumber6 * 2 - 1] = '';
