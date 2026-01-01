code    segment
        assume  cs:code,ds:code
        org     100h

start:
        mov     ax,1111h                ; 1114h- 30 lines; 1111h- 34 lines
        int     10h

        lea     si,SeqData
        mov     dx,3c4h
        mov     cx,5
        cld
lp1:    lodsw
        out     dx,ax
        loop    lp1                     ; loop sequencer write
        mov     dl,0c2h
        mov     al,0e7h                 ; code for 480
        out     dx,al                   ; write misc register
        mov     dl,0c4h                 ; sequencer adr. again
        lodsw   
        out     dx,ax
        mov     dl,0d4h                 ; 0b4h for mono
        mov     cx,9
lp2:    lodsw
        out     dx,ax
        loop    lp2                     ; loop CRTC write

        xor     ax,ax
        mov     es,ax
        mov     byte ptr es:484h,33     ; 33 for 34 lines
	and	byte ptr es:487h,not 1	; for cursor emulate
	


	mov	ah,9
	lea	dx,mes
	int	21h
        ret


Mes	db	'VGA: 480 scan lines',13,10
	db	'(c) 1992 Dmitry A. Gurtjak',13,10,'$'

SeqData dw      00100h
        dw      00001h
        dw      00302h
        dw      00003h
        dw      00204h
        dw      00300h

        dw      00c11h
        dw      00b06h;
        dw      03e07h
        dw      04d09h          ; 04d09h for 34 lines
        dw      0ea10h
        dw      08c11h
        dw      0db12h		; 0db12h for 34 lines
        dw      0e715h
        dw      00416h

code    ends
        end     start
