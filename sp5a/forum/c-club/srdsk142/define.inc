; SRDISK - device driver definitions
; Copyright (c) 1992 Marko Kohtala


; General capabilities in conf.c_flags

C_APPENDED      equ 1   ; Capable of having appended drivers
C_MULTIPLE      equ 2   ; Capable of driving many disks
C_32BITSEC      equ 4   ; Capable of handling over 32-bit sector addresses
C_NOALLOC       equ 8   ; Incapable of allocating memory by itself
C_UNKNOWN       equ 0xF0

; If C_NOALLOC is not set, the malloc field in configuration structure points
; into the allocation function. If C_NOALLOC is set, then the malloc
; points into the data that SRDISK.EXE needs to be able to handle the memory
; by itself.

; What this driver can actually do:
CAPABLE         equ C_32BITSEC or C_NOALLOC or C_APPENDED

; Boolean
TRUE    EQU 1
FALSE   EQU 0


; Some important internal settings
MULTIPLEXAH     equ     72h             ; Multiplex int 2F AH parameter
V_FORMAT        equ     0               ; config_s format version used here

HOOKINT19       equ     FALSE           ; Hook int 19 if TRUE

DEBUGGING       equ     FALSE
DEBUGINIT       equ     FALSE

;******************* Derived definitions ********************

DR_ATTRIBUTES = 0800h                   ; Removable media

if CAPABLE and C_32BITSEC
DR_ATTRIBUTES = DR_ATTRIBUTES or 2      ; 32-bit addr
endif


if DEBUGGING
debug   macro char,num
        push ax
        push dx
        IFDIFI <num>,<dx>
          IF TYPE num EQ 1
          xor dh,dh
          mov dl,num
          ELSE
          mov dx,num
          ENDIF
        ENDIF
        mov al,char
        call debug_c
        pop dx
        pop ax
        endm
else
debug   macro char
        endm
endif ;DEBUGGING


