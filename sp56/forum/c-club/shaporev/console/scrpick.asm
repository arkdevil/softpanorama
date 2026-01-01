		TITLE	'BIOS read screen block'
		NAME	scrpick
		PAGE	55,132
;
; Function:	read screen block (characters with attribute) to destination
;               array

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
		ASSUME	cs:_TEXT, ds:DGROUP

		PUBLIC	_scrpick
_scrpick	PROC	prog

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

		les	di,ss:[bp+(ArgOff+8)]	; ES:DI -> destination

loop_row:	mov	al,top
		cmp	al,bottom	; if top > bottom
		jg	return

		mov	si,left		; i = left
loop_i:
		cmp	si,right   	; if i > right
		jg	endloop
		mov	dx,si		; column
		mov     dh,top
                mov	bh,DGROUP:__scrpage
		mov	ah,2		; address cursor
		int	10h
;		mov	bh,DGROUP:__scrpage
		mov	ax,0800h	; be careful! AL = 0!
		int	10h		; read character/attribute
		stosw			; store character/attribute
		inc	si
		jmp	short loop_i
endloop:
		inc	top
		jmp	short loop_row
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
                pop     es
        	pop     ds
		pop	bp
		quit

_scrpick	endp
_TEXT		ends
		end
