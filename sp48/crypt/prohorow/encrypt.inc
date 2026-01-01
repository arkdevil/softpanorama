;****************************************************************************;
;*                                                                          *;
;*      Data Encryption ToolKit. Version 1.3                                *;
;*                                                                          *;
;*      encrypt.inc -- declare constants and macros for encrypt library     *;
;*                                                                          *;
;*      Copyright (c) 1991, 1992, Andrew Prokhorow. All rights reserved.    *;
;*                                                                          *;
;*      Purpose:                                                            *;
;*        This file define encrypt library macros and manifest constants    *;
;*        that are used with them.                                          *;
;*                                                                          *;
;****************************************************************************;


EncryptionKeySize       equ     8
EncryptionKeyMaxNumber  equ     255
EncryptionKeyLength     equ     9
EncryptionKeyMaxLength  equ     EncryptionKeyLength * EncryptionKeyMaxNumber
EncryptedBlockSize      equ     8
EncryptedBlockMaxNumber equ     4095
EncryptedBlockMaxSize   equ     EncryptedBlockSize * EncryptedBlockMaxNumber
EncryptedFragmentMaxNumber equ  84
EncryptionControlAreaMaxId equ  9
                        ifdef   EncryptionKeyNumber
EncryptionKeyCurrentLength equ  EncryptionKeyLength * EncryptionKeyNumber
EncryptionKeyAreaSize   equ     EncryptionKeyNumber * 128 + 8
                        endif

;       Operation codes
EncryptNochain          equ     0
DecryptNochain          equ    -0
EncryptChain            equ     1
DecryptChain            equ    -1
EncryptAuth             equ     2
DecryptAuth             equ    -2
EncryptLastAuth         equ     3
DecryptLastAuth         equ    -3
EncryptFirstAuth        equ     4
DecryptFirstAuth        equ    -4

;       Return codes
NormalEncryption        equ     0
InvalidEncryptParam     equ     1
InvalidEncryptAuth      equ     2

EncryptionControlArea   macro   Id, Number
                        ifidn   <Id>, <0>
EncryptionControlArea0  db      'eNcRyPt'       ; signature
                        elseifidn <Id>, <1>
EncryptionControlArea1  db      'eNCryPt'       ; signature
                        elseifidn <Id>, <2>
EncryptionControlArea2  db      'eNcrYPt'       ; signature
                        elseifidn <Id>, <3>
EncryptionControlArea3  db      'enCRyPt'       ; signature
                        elseifidn <Id>, <4>
EncryptionControlArea4  db      'eNcRYpt'       ; signature
                        elseifidn <Id>, <5>
EncryptionControlArea5  db      'enCrYPt'       ; signature
                        elseifidn <Id>, <6>
EncryptionControlArea6  db      'eNCrYpt'       ; signature
                        elseifidn <Id>, <7>
EncryptionControlArea7  db      'encRYPt'       ; signature
                        elseifidn <Id>, <8>
EncryptionControlArea8  db      'eNCRypt'       ; signature
                        elseifidn <Id>, <9>
EncryptionControlArea9  db      'enCRYpt'       ; signature
                        else
                        display "Identifier must be in range [0..9]"
                        .err
                        endif
                if      Number gt EncryptedFragmentMaxNumber or Number lt 1
                display "Numebr of fragments must be in range [1..84]"
                .err
                endif
                db      Number or 80h           ; size
                rept    Number
                db      6 dup (0)               ; fragment descriptor
                endm
                endm
