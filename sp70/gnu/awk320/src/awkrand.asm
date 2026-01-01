; long integer random number generator
;
;  Copyright (C) 1988, 1989, 1990, 1991 by Rob Duff
;  All rights reserved
;
        TITLE   rand

_TEXT   SEGMENT  BYTE PUBLIC 'CODE'
_TEXT   ENDS
_DATA   SEGMENT  WORD PUBLIC 'DATA'
_DATA   ENDS
DGROUP  GROUP   _DATA
        ASSUME  CS: _TEXT, DS: DGROUP

        PUBLIC  _rexp
_DATA   SEGMENT
        DB      'RAND'
_init   DW      0, 0, 0, 1, 0, 0, 0, 0          ;c
_mult   DW      09F8Dh, 0B276h, 04E35h, 0945Ah  ; a
_seed   DW      1, 0, 0, 0                      ; Xn
_rexp   DW      -31
_real   DW      8 dup (0)                       ; Xn+1
_DATA   ENDS
_TEXT   SEGMENT

        PUBLIC  _srandl
_srandl PROC NEAR
        push    bp
        mov     bp, sp
        mov     ax, [bp+4]
        mov     _seed+0, ax
        mov     ax, [bp+6]
        mov     _seed+2, ax
        pop     bp
        ret     

_srandl ENDP

; linear congruential method
;
; Xn = (aXn-1 + c) mod m
;
; m = 0x10000000000000000       m == 2^64
; a = 0x0945A4E35B2769F8D       a mod 8 == 5
; c = 0x00000000000000001       c mod 2 == 1
;
        PUBLIC  _randl
_randl  PROC NEAR
        push    bp
        mov     bp,sp
        push    si
        push    di
        cld
        mov     ax, ds          ; set extra segment
        mov     es, ax

        mov     si, OFFSET _init
        mov     di, OFFSET _real
        xor     ax, ax
        mov     cx, 8           ; move "c" to accumulator
    rep movsw

        mov     bx, OFFSET _real+6
        mov     si, OFFSET _seed
        mov     di, OFFSET _mult

        lodsw                   ; x[0]
        mul     WORD PTR [di]   ; a[0]
        add     [bx+0], ax      ; b[0]
        adc     [bx+2], dx      ;
        adc     [bx+4], cx      ;
        adc     [bx+6], cx      ;
        lodsw                   ; x[1]
        mul     WORD PTR [di]   ; a[0]
        add     [bx+2], ax      ; b[1]
        adc     [bx+4], dx      ;
        adc     [bx+6], cx      ;
        lodsw                   ; x[2]
        mul     WORD PTR [di]   ; a[0]
        add     [bx+4], ax      ; b[2]
        adc     [bx+6], dx      ;
        lodsw                   ; x[3]
        mul     WORD PTR [di]   ; a[0]
        add     [bx+6], ax      ; b[3]

        sub     si, 8
        inc     di
        inc     di

        lodsw                   ; x[0]
        mul     WORD PTR [di]   ; a[1]
        add     [bx+2], ax      ; b[1]
        adc     [bx+4], dx      ; b[2]
        adc     [bx+6], cx      ; b[3]
        lodsw                   ; x[1]
        mul     WORD PTR [di]   ; a[1]
        add     [bx+4], ax      ; b[2]
        adc     [bx+6], dx      ; b[3]
        lodsw                   ; x[2]
        mul     WORD PTR [di]   ; a[1]
        add     [bx+6], ax      ; b[3]

        sub     si, 6
        inc     di
        inc     di

        lodsw                   ; x[0]
        mul     WORD PTR [di]   ; a[2]
        add     [bx+4], ax      ; b[2]
        adc     [bx+6], dx      ; b[3]
        lodsw                   ; x[1]
        mul     WORD PTR [di]   ; a[2]
        add     [bx+6], ax      ; b[3]

        sub     si, 4
        inc     di
        inc     di

        lodsw                   ; x[0]
        mul     WORD PTR [di]   ; a[3]
        add     [bx+6], ax      ; b[3]

        mov     si, OFFSET _real+6
        mov     di, OFFSET _seed+0
        mov     cx, 4
    rep movsw

        mov     ax, WORD PTR _real+10
        mov     dx, WORD PTR _real+12
        and     dh, 7Fh

        pop     di
        pop     si
        pop     bp
        ret     

_randl  ENDP

_TEXT   ENDS
        END

