		NAME	scrwipe
		PAGE	55,132

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

_TEXT		SEGMENT	byte public 'CODE'
		ASSUME	cs:_TEXT

		PUBLIC	_scrwipe
_scrwipe        PROC	prog

		push	bp		; preserve caller registers
		mov	bp,sp

		mov	cl,ss:[bp+(ArgOff+0)]	; left
		mov	ch,ss:[bp+(ArgOff+2)]	; top
		mov	dl,ss:[bp+(ArgOff+4)]	; right
		mov	dh,ss:[bp+(ArgOff+6)]	; bottom
		mov	bh,ss:[bp+(ArgOff+8)]   ; attribute
                mov     ax,0600h		; clear window
                int     10h

		pop	bp
		quit

_scrwipe	ENDP
_TEXT		ENDS
		END
