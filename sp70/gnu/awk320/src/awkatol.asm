; string to long integer conversion
;
;  Copyright (C) 1988, 1989, 1990, 1991 by Rob Duff
;  All rights reserved
;
;long fatol(char far * str);
;
_TEXT   SEGMENT BYTE PUBLIC 'CODE'
        ASSUME  CS:_TEXT

        PUBLIC  _fatol
_fatol  PROC    NEAR
        push    bp
        mov     bp,sp
        push    si
        push    di
        push    ds
        xor     bx,bx
        xor     di,di
        xor     cx,cx

        lds     si, [bp+4]              ; string pointer
        mov     bp,10                   ; constant BASE

        lodsb
        cmp     al,'+'
        je      fatal
        cmp     al,'-'                  ; check sign
        jne     check
        mov     cl,al                   ; set sign
fatal:
        lodsb
check:
        mov     ch,al                   ; next character
        sub     ch,'0'
        jb      final
        cmp     ch,10
        jb      digit
        sub     ch,'A'-'0'              ; uppercase
        jb      final
        cmp     ch,6
        jb      hex
        sub     ch,'a'-'A'              ; uppercase
        jb      final
        cmp     ch,6
        jnb     final
hex:
        add     ch,10
digit:
        mov     ax,di
        mul     bp
        mov     di, ax
        mov     ax,bx
        mul     bp
        mov     bx,ax
        add     bl,ch
        adc     bh,0
        adc     di,dx
        jmp     fatal
final:
        test    cl,cl
        jz      finish
        neg     di
        neg     bx
        adc     di,0
finish:
        mov     ax,bx
        mov     dx,di
        pop     ds
        pop     di
        pop     si
        pop     bp
        ret

_fatol  ENDP

_TEXT   ENDS
        END

