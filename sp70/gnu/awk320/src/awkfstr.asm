; far string operations
;
;  Copyright (C) 1988, 1989, 1990, 1991 by Rob Duff
;  All rights reserved
;
_TEXT   SEGMENT PUBLIC WORD 'CODE'

        ASSUME  CS:_TEXT

        PUBLIC  _fstrstr
_fstrstr PROC    NEAR
        push    bp
        mov     bp,sp
        push    si
        push    di
        push    ds
        cld

        les     di,[bp+8]
        cmp     BYTE PTR es:[di],0
        jnz     str01
        mov     dx,[bp+6]
        mov     ax,[bp+4]
        jmp     short str06

str01:  les     di,[bp+4]
        push    es

        mov     bx,di
        xor     ax,ax
        mov     cx,-1
  repnz scasb
        not     cx
        mov     dx,cx

        les     di,[bp+8]
        push    es

        mov     bp,di
        xor     ax,ax
        mov     cx,-1
  repnz scasb
        inc     cx
        not     cx

        pop     ds
        pop     es

str02:  mov     si,bp
        lodsb
        xchg    di,bx
        xchg    cx,dx
  repnz scasb
        mov     bx,di

        jnz     str03
        cmp     cx,dx
        jnb     str04
str03:  xor     bx,bx
        mov     es,bx
        mov     bx,1
        jmp     short str05

str04:  xchg    cx,dx
        jcxz    str05

        mov     ax,cx
        dec     cx
   repz cmpsb
        mov     cx,ax
        jnz     str02

str05:  mov     ax,bx
        dec     ax
        mov     dx,es

str06:  pop     ds
        pop     di
        pop     si
        pop     bp
        ret
_fstrstr ENDP

        PUBLIC  _fstrcat
_fstrcat PROC    NEAR
        push    bp
        mov     bp,sp
        push    si
        push    di
        cld
        push    ds

        les     di,[bp+4]
        mov     dx,di
        xor     al,al
        mov     cx,-1
  repnz scasb
        push    es

        lea     si,[di-1]
        les     di,[bp+8]
        mov     cx,-1
  repnz scasb
        not     cx
        sub     di,cx
        push    es

        pop     ds
        pop     es
        xchg    si,di
        test    si,1
        jz      fstrcat
        movsb
        dec     cx
fstrcat: shr     cx,1
   repz movsw
        adc     cx,cx
    rep movsb

        mov     ax,dx
        mov     dx,es

        pop     ds
        pop     di
        pop     si
        pop     bp
        ret
_fstrcat ENDP

        PUBLIC  _fstrlen
_fstrlen PROC    NEAR
        push    bp
        mov     bp,sp
        push    si
        push    di
        cld

        les     di,[bp+4]
        xor     al,al
        mov     cx,-1
  repnz scasb
        mov     ax,cx
        not     ax
        dec     ax

        pop     di
        pop     si
        pop     bp
        ret
_fstrlen ENDP

        PUBLIC  _fstrchr
_fstrchr PROC    NEAR
        push    bp
        mov     bp,sp
        push    si
        push    di
        cld

        les     di,[bp+4]
        xor     al,al
        mov     cx,-1
  repnz scasb
        not     cx

        mov     al,[bp+8]
        cmp     al,0
        je      chr01
        mov     di,[bp+4]
  repnz scasb
        jz      chr01

        xor     di,di
        mov     es,di
        inc     di
chr01:
        dec     di
        mov     ax,di
        mov     dx,es
        pop     di
        pop     si
        pop     bp
        ret
_fstrchr ENDP

        PUBLIC  _fstrcmp
_fstrcmp PROC    NEAR
        push    bp
        mov     bp,sp
        push    si
        push    di
        mov     dx,ds
        cld

        xor     ax,ax
        mov     bx,ax
        les     di,[bp+8]
        mov     si,di
        xor     al,al
        mov     cx,-1
  repnz scasb
        not     cx

        mov     di,si
        lds     si,[bp+4]
   repz cmpsb

        mov     al,[si-1]
        mov     bl,es:[di-1]
        sub     ax,bx

        mov     ds,dx
        pop     di
        pop     si
        pop     bp
        ret
_fstrcmp ENDP

        PUBLIC  _fstrcpy
_fstrcpy PROC    NEAR
        push    bp
        mov     bp,sp
        push    si
        push    di
        push    ds
        cld

        les     di,[bp+8]
        mov     si,di
        xor     al,al
        mov     cx,-1
  repnz scasb
        not     cx

        push    es
        pop     ds
        les     di,[bp+4]
   repz movsb

        mov     dx,[bp+6]
        mov     ax,[bp+4]

        pop     ds
        pop     di
        pop     si
        pop     bp
        ret
_fstrcpy ENDP

        PUBLIC  _fstrncat
_fstrncat PROC   NEAR
        push    bp
        mov     bp,sp
        push    si
        push    di
        push    ds

        cld
        xor     al,al

        les     di,[bp+8]
        mov     cx,-1
  repnz scasb
        not     cx
        dec     cx
        mov     bx,cx

        les     di,[bp+4]
        mov     cx,-1
  repnz scasb
        dec     di

        mov     cx,[bp+12]
        cmp     cx,bx
        jb      fstrncat
        mov     cx,bx
fstrncat:
        lds     si,[bp+8]
    rep movsb
        stosb

        mov     dx,[bp+6]
        mov     ax,[bp+4]

        pop     ds
        pop     di
        pop     si
        pop     bp
        ret
_fstrncat ENDP

        PUBLIC  _fstrncpy
_fstrncpy PROC   NEAR
        push    bp
        mov     bp,sp
        push    si
        push    di
        push    ds
        cld

        les     di,[bp+8]
        mov     si,di

        xor     al,al
        mov     bx,[bp+12]
        mov     cx,bx
  repnz scasb
        sub     bx,cx
        xchg    cx,bx

        mov     di,es
        mov     ds,di
        les     di,[bp+4]
   repz movsb

        mov     cx,bx
   repz stosb

        mov     dx,[bp+6]
        mov     ax,[bp+4]

        pop     ds
        pop     di
        pop     si
        pop     bp
        ret
_fstrncpy ENDP

        PUBLIC  _fstrlwr
_fstrlwr PROC    NEAR
        push    bp
        mov     bp,sp
        push    si
        push    di
        push    ds
        cld

        lds     si,[bp+8]
        les     di,[bp+4]
        mov     dx,di
strlwr: lodsb
        cmp     al,'A'
        jb      stolwr
        cmp     al,'Z'
        ja      stolwr
        add     al,'a'-'A'
stolwr: stosb
        and     al,al
        jnz     strlwr

        mov     ax,dx
        mov     dx,es
        pop     ds
        pop     di
        pop     si
        pop     bp
        ret
_fstrlwr ENDP

        PUBLIC  _fstrupr
_fstrupr PROC    NEAR
        push    bp
        mov     bp,sp
        push    si
        push    di
        push    ds
        cld

        lds     si,[bp+8]
        les     di,[bp+4]
        mov     dx,di
strupr: lodsb
        cmp     al,'a'
        jb      stoupr
        cmp     al,'z'
        ja      stoupr
        sub     al,'a'-'A'
stoupr: stosb
        and     al,al
        jnz     strupr

        mov     ax,dx
        mov     dx,es
        pop     ds
        pop     di
        pop     si
        pop     bp
        ret
_fstrupr ENDP

_TEXT   ENDS
        END

