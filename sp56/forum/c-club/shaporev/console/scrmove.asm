		TITLE	'BIOS move screen block'
		NAME	scrmove
		PAGE	55,132
;
; Function:	move screen blok on desired number of rows and columns
;
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

left		equ	byte ptr ss:[bp+(ArgOff+00)]
left_w		equ	word ptr ss:[bp+(ArgOff+00)]
top		equ	byte ptr ss:[bp+(ArgOff+02)]
top_w		equ	word ptr ss:[bp+(ArgOff+02)]
right		equ	byte ptr ss:[bp+(ArgOff+04)]
right_w		equ	word ptr ss:[bp+(ArgOff+04)]
bottom		equ	byte ptr ss:[bp+(ArgOff+06)]
bottom_w	equ	word ptr ss:[bp+(ArgOff+06)]
deltaX          equ     byte ptr ss:[bp+(ArgOff+08)]
deltaY          equ     byte ptr ss:[bp+(ArgOff+10)]

		extrn	__scrpage:byte
		extrn	_scr_001:near

_TEXT		SEGMENT	byte public 'CODE'
		ASSUME	cs:_TEXT, ds:DGROUP

		PUBLIC	_scrmove
_scrmove	PROC	prog

                push    bp
                mov     bp,sp
                push    ds
		push	es
		push	di
		push	si

		ifdef	__TINY__
		mov	ax,cs
		else
		mov     ax,DGROUP
		endif
                mov     ds,ax
                test    byte ptr DGROUP:__scrpage,128
		jz      continue	; correct page already loaded
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

		test	deltaY,80h
		jnz	dr_1
		mov	di,bottom_w	; j = bottom
		jmp	short loop_row
dr_1:		mov	di,top_w	; j = top
loop_row:
		test    deltaY,80h
		jnz	dr_2
		cmp	di,top_w	; if j < top
		jge	cont_row
		jmp	return
dr_2:		cmp	di,bottom_w   	; if j > bottom
		jle	cont_row
		jmp	return
cont_row:
		test	deltaX,80h
		jnz	dc_1
		mov	si,right_w	; i = right
		jmp	short loop_i
dc_1:		mov	si,left_w	; i = left
loop_i:
		test    deltaX,80h
		jnz	dc_2
		cmp	si,left_w	; if i < left
                jge	cont_col
		jmp	short endloop
dc_2:		cmp	si,right_w   	; if i > right
		jg	endloop
cont_col:	mov	dx,si		; column
                mov     ax,di
		mov     dh,al           ; row
                mov	bh,DGROUP:__scrpage
		mov	ah,2		; address cursor
		int	10h

		mov	ax,0800h	; be careful! AL = 0!
		int	10h		; read character/attribute
		mov	es,ax		; save character/attribute
; does it need to clear source
; check vertical conditions
;		mov	ax,di
;		mov	ah,deltaY
;		test	ah,80h		; if deltaY >= 0
;		jz	pozdY
;		neg	ah
;		sub	al,bottom
;               neg     al
;		jmp	short checkver
;pozdY:
;		sub	al,top
;checkver:	cmp	al,ah
;		jbe	chrclear
; check horisontal conditions
;		mov	ax,si
;		mov	ah,deltaX
;		test	ah,80h	; if deltaX >= 0
;		jz	pozdX
;		neg	ah
;		sub	al,right
;               neg	al
;		jmp	short checkhor
;pozdX:
;		sub	al,left
;checkhor:	cmp	al,ah
;		jg	chr_move
;
;chrclear:      mov     cx,1		; repeat count
;		mov	bh,DGROUP:__scrpage
;		mov	al,' '
;		mov	ah,10		; write character
;		int	10h

chr_move:	add	dl,deltaX	; change column
		add     dh,deltaY	; change row
;		mov	bh,DGROUP:__scrpage
		mov	ah,2		; address cursor
		int	10h

		mov	ax,es		; restore character/attribute
		mov     bl,ah		; attribute
                mov     cx,1		; repeat count
;		mov	bh,DGROUP:__scrpage
		mov	ah,9		; write character/attribute
		int	10h

		test	deltaX,80h
		jnz	dc_3
		dec	si
		jmp	loop_i
dc_3:		inc	si
		jmp	loop_i
endloop:
		test	deltaY,80h
		jnz	dr_3
		dec	di
		jmp	loop_row
dr_3:		inc	di
		jmp	loop_row
return:
		mov	ah,2		; set cursor position
		mov     bh,DGROUP:__scrpage
		pop	dx		; restore cursor position
		int	10h
		mov	ah,1		; set cursor size
		pop	cx		; restore cursor size
		int	10h

		pop	si
                pop	di
		pop	es
        	pop     ds
		pop	bp
		quit

_scrmove	endp
_TEXT		ends
		end
