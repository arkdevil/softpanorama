		TITLE	'BIOS write screen block'
		NAME	scrload
		PAGE	55,132
;
; Function:	load block (characters with attribute) from source array to
;               screen

_DATA		SEGMENT	word public 'DATA'
_DATA		ENDS

_TEXT		SEGMENT	byte public 'CODE'
_TEXT		ENDS

		ifdef	__TINY__
DGROUP		GROUP	_TEXT, _DATA
		else
DGROUP		GROUP	_DATA
		endif

		ifdef	__TINY__
__NEAR__	equ	0
		endif
		ifdef	__NEAR__
prog		equ	near
quit		equ	ret
ArgOff		equ	4
		else
prog		equ	far
quit		equ	retf
ArgOff		equ	6
		endif

left		equ	word ptr ss:[bp+(ArgOff+0)]
top		equ	byte ptr ss:[bp+(ArgOff+2)]
right		equ	word ptr ss:[bp+(ArgOff+4)]
bottom		equ	byte ptr ss:[bp+(ArgOff+6)]

		extrn	__scrpage:byte
		extrn	_scr_001:near

_TEXT		SEGMENT	byte public 'CODE'
		ASSUME	cs:_TEXT, es:DGROUP

gotodi          proc    near
		mov	dx,di		; column
		mov	dh,top		; row
gotodx:		mov	bh,DGROUP:__scrpage
		mov	ah,2		; set cursor position
		int	10h
		retn
gotodi          endp

		PUBLIC	_scrload
_scrload	PROC	prog

                push    bp
                mov     bp,sp
                push    ds
                push    es
		push	di
		push	si

		ifdef	__TINY__
		mov	ax,cs
		else
		mov     ax,DGROUP
		endif
                mov     es,ax
		test    byte ptr DGROUP:__scrpage,128
		jz      continue	; correct page already loaded
;		mov     ah,0Fh
;		int     10h
;		mov	byte ptr DGROUP:__scrpage,bh
		call	near ptr _scr_001
continue:
		mov	ah,3		; read cursor attributes
		mov     bh,DGROUP:__scrpage
		int	10h
		push	cx		; save cursor size
		push	dx		; save cursor position
		mov	ah,1		; set cursor size
		mov     cx,2020h	; cursor invisible
		int	10h

		lds	si,ss:[bp+(ArgOff+8)]	; DS:SI -> source

loop_row:	mov	al,top
		cmp	al,bottom	; if top > bottom
		jg	return

		mov	di,left		; i = left
loop_i:
		cmp	di,right   	; if i > right
		jg	endloop
		mov	cx,right
		sub	cx,di
		jz	slowload	; no reasons for the only column
		push	si		; save source pointer
		inc	cx
		push	cx		; save counter
		mov	bh,ds:[si+1]	; 1-st char attribute
test_row:
		lodsw   		; AL = character
		test	al,0E0h		; control code?
		jz	breakline	; yes, break
		cmp	ah,bh
		jne	breakline	; different attributes
		loop	test_row
breakline:
		pop	si		; saved value of the counter
		sub	si,cx		; number of continuos chars
		mov	ah,top
		mov	dx,di   	; left boundary
		add	dx,si		; add number of chars
		dec	dx		; left boundary
		cmp	dx,right	; last column?
		jl	endline_ok	; no, neendn't check
		cmp	ah,bottom   	; last line?
		jl	endline_ok	; no, needn't check
; bottom right corner - output must not move cursor to preserve scroll
		dec	si
;		dec     dx		; don't care
endline_ok:
		cmp	si,1
		jle	not_fast
fastload:
		mov	dh,ah		; row number, DL = right boundary
		mov	cx,di		; left boundary
		mov	ch,dh
		mov	ax,0600h	; clear window
		int	10h		; BH = attribute

                call    near ptr gotodi

		add	di,si		; increase pozition counter
		mov	cx,si
		pop	si		; restore pointer
ttyload:
		lodsw			; AL = character
;		mov	bh,DGROUP:__scrpage
		mov	ah,0Eh		; type character
		int	10h
		loop	ttyload
		jmp	short loop_i
not_fast:
		pop	si		; restore pointer
slowload:
		call	near ptr gotodi
		inc	di

		lodsw			; AL = character
		mov     bl,ah		; BL = attribute
                mov     cx,1		; repeat count
;		mov	bh,DGROUP:__scrpage
		mov	ah,9		; write character/attribute
		int	10h
		jmp	short loop_i
endloop:
		inc	top
		jmp	short loop_row
return:
		pop	dx		; restore cursor position
		call	near ptr gotodx
		mov	ah,1		; set cursor size
		pop	cx		; restore cursor size
		int	10h

		pop	si
                pop	di
                pop     es
        	pop     ds
		pop	bp
		quit

_scrload	endp
_TEXT		ends
		end
