.MODEL  TINY
.386
.CODE
.STARTUP

; ---------------------------------------------------------------------------
; Sample program for the Hercules routines
; ---------------------------------------------------------------------------

        mov     ax, 7 * 100h + '·'
        call    HsetBack
        
        call    Hcls

        mov     si, offset Message
        mov     ah, 7
        call    Hprint$

        mov     bh, 2
        call    HsetStart

        xor     edx, edx

Lus:    mov     cx, 8
        call    Hval

        mov     ah, 15
        mov     bx, 7
        call    Hstr0
        
        mov     si, offset Message2
        mov     ah, 7
        call    Hprint0

        inc     edx
        cmp     edx, 1000
        jne     Lus
        
        .EXIT

Message         BYTE    'EDX = $'
Message2        BYTE    '1234567890123', 0

        INCLUDE HERCULES.INC

        END
