		NAME	scrolld
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

		PUBLIC	_scrolld
_scrolld        PROC	prog

		push	bp		; preserve caller registers
		mov	bp,sp

		mov	cl,ss:[bp+(ArgOff+00)]	; left
		mov	ch,ss:[bp+(ArgOff+02)]	; top
		mov	dl,ss:[bp+(ArgOff+04)]	; right
		mov	dh,ss:[bp+(ArgOff+06)]	; bottom
		mov	bh,ss:[bp+(ArgOff+08)]	; attribute
		mov	al,ss:[bp+(ArgOff+10)]	; number of lines
                mov     ah,7			; scroll window
                int     10h

		pop	bp
		quit

_scrolld	ENDP
_TEXT		ENDS
		END
