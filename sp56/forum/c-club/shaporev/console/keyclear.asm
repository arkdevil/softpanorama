		TITLE	'clear keyboard buffer'
		NAME	keyclear
		PAGE	55,132
;
; Function:	clear keyboard buffer
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
		else
prog		equ	far
quit		equ	retf
		endif

		extrn	_oldkeyboard:byte
		extrn	_key_002:near

_TEXT		SEGMENT	byte public 'CODE'
		ASSUME	cs:_TEXT, ds:DGROUP

		PUBLIC	_keyclear
_keyclear	PROC	prog

                push    bp
                mov     bp,sp
                push    ds

		ifdef	__TINY__
		mov	ax,cs
		else
		mov     ax,DGROUP
		endif
                mov     ds,ax
		cmp	byte ptr DGROUP:_oldkeyboard,255
                jne	next			; keyboard aready checked
                call	near ptr _key_002
next:		test	byte ptr DGROUP:_oldkeyboard,255
		jz	new

old:		mov	ah,1
		int	16h
		jz	return
                xor     ah,ah
		int	16h
                jmp     short old

new:		mov	ah,11h
		int	16h
		jz	return
		mov	ah,10h
		int	16h
                jmp     short new

return:		pop	ds
                pop	bp
		quit

_keyclear	ENDP
_TEXT		ENDS
		END
