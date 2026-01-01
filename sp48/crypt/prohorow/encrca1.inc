{****************************************************************************}
{*                                                                          *}
{*      Data Encryption ToolKit. Version 1.3                                *}
{*                                                                          *}
{*      encrca1.inc -- declare Encryption Control Area 1                    *}
{*                                                                          *}
{*      Copyright (c) 1991, 1992, Andrew Prokhorow. All rights reserved.    *}
{*                                                                          *}
{*      Purpose:                                                            *}
{*        This file declares constants that compose together                *}
{*        Encryption Control Area 1.                                        *}
{*                                                                          *}
{****************************************************************************}


const
  EncryptionControlArea1: array [1..7] of Char = 'eNCryPt';
  EncryptionControlNumber1: Char = Chr (EncryptionFragmentNumber1 + 128);
  EncryptionControlList11: String [EncryptionFragmentNumber1 * 2 - 1] = '';
  EncryptionControlList21: String [EncryptionFragmentNumber1 * 2 - 1] = '';
  EncryptionControlList31: String [EncryptionFragmentNumber1 * 2 - 1] = '';
