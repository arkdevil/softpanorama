{****************************************************************************}
{*                                                                          *}
{*      Data Encryption ToolKit. Version 1.3                                *}
{*                                                                          *}
{*      encrcon.inc -- declare constants for Encrypt unit                   *}
{*                                                                          *}
{*      Copyright (c) 1991, 1992, Andrew Prokhorow. All rights reserved.    *}
{*                                                                          *}
{*      Purpose:                                                            *}
{*        This file declares constants that are used with Encrypt unit.     *}
{*                                                                          *}
{****************************************************************************}


const
  EncryptionKeyAreaSize = EncryptionKeyNumber * 128 + 8;
