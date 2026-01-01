page    78, 124
title   WinMem - Windows memory copy/compare/set functions
;----------------------------------------------------------------------------
; Public domain
; Written by Michael Geary
;----------------------------------------------------------------------------

.xlist
include cmacros.inc
.list

;----------------------------------------------------------------------------

createSeg   MEMORY_TEXT,MEMORY,BYTE,PUBLIC,CODE

;----------------------------------------------------------------------------

sBegin  MEMORY
assumes CS, MEMORY

;----------------------------------------------------------------------------
; SHORT FAR PASCAL lmemcmp( LPVOID lpOne, LPVOID lpTwo, WORD cbMem );
; Far pointer version of memcmp().
; Compare blocks of memory at *lpOne and *lpTwo of length cbMem.
; Return  0 if blocks match (or if cbMem is 0).
; Return  1 if first mismatching byte in *lpOne > *lpTwo
; Return -1 if first mismatching byte in *lpOne < *lpTwo.
;----------------------------------------------------------------------------

cProc   lmemcmp,<PUBLIC,FAR>,<di,si>
        parmD   lpOne
        parmD   lpTwo
        parmW   cbMem
cBegin
        push    ds

        les     di, lpOne
        lds     si, lpTwo

        xor     ax, ax
        mov     cx, cbMem
        jcxz    lmemcmpDone

        repe    cmpsb
        jz      lmemcmpDone

        dec     ax
        dec     di
        dec     si
        mov     bl, byte ptr es:[di]
        cmp     bl, byte ptr ds:[si]
        jb      lmemcmpDone
        inc     ax
        inc     ax

    lmemcmpDone:

        pop     ds
cEnd

;----------------------------------------------------------------------------
; VOID FAR PASCAL lmemcpy( LPVOID lpDest, LPVOID lpSrc, WORD cbMem );
; Far pointer version of memcpy().
; Copy cbMem bytes of memory from *lpSrc to *lpDest.
; Do nothing if cbMem is 0.
;----------------------------------------------------------------------------

cProc   lmemcpy,<PUBLIC,FAR>,<di,si>
        parmD   lpDest
        parmD   lpSrc
        parmW   cbMem
cBegin
        push    ds

        les     di, lpDest
        push    es
        push    di

        lds     si, lpSrc
        mov     cx, cbMem
        jcxz    lmemcpyDone

        mov     ax, ds
        mov     bx, es
        cmp     ax, bx
        jne     lmemcpyDown

        cmp     si, di
        jb      lmemcpyUp

    lmemcpyDown:
        repne   movsb
        jmp short lmemcpyDone

    lmemcpyUp:
        STD
        add     si,cx
        add     di,cx
        dec     si
        dec     di
        repne   movsb
        CLD

    lmemcpyDone:
        pop     ax                      ; dx:ax return value
        pop     dx

        pop     ds
cEnd

;----------------------------------------------------------------------------
; VOID FAR PASCAL lmemset( LPVOID lpMem, SHORT chr, WORD cbMem );
; Far pointer version of memset().
; Fill cbMem bytes of memory at *lpMem with chr.
; Do nothing if cbMem is 0.
;----------------------------------------------------------------------------

cProc   lmemset,<PUBLIC,FAR>,<di,si>
        parmD   lpMem
        parmW   chr
        parmW   cbMem
cBegin
        push    ds

        les     di, lpMem
        push    es
        push    di

        mov     cx, cbMem
        jcxz    lmemsetDone

        mov     ax, chr

        rep     stosb

    lmemsetDone:
        pop     ax                      ; dx:ax return value
        pop     dx

        pop     ds
cEnd

;----------------------------------------------------------------------------

sEnd    MEMORY

;----------------------------------------------------------------------------

        end

;----------------------------------------------------------------------------

