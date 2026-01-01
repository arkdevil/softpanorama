		TITLE	'BIOS read keystroke'
		NAME	keyinput
		PAGE	55,132
;
; Function:	returns enhanced keystroke
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

		PUBLIC	_keyinput
_keyinput	PROC	prog

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

next:           test	byte ptr DGROUP:_oldkeyboard,255
		jz	newkeyb
		xor	ah,ah
		jmp	short inpkey
newkeyb:	mov	ah,10h
inpkey:		int	16h

                pop	ds
                pop	bp
		quit

_keyinput	ENDP
_TEXT		ENDS
		END
