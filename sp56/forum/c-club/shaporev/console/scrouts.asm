		TITLE	'BIOS output string'
		NAME	scrouts
		PAGE	55,132
;
; Function:	TTY-style output text string to given location on screen
;
; Caller:	Turbo C
;
;			void scrouts (short, short, char far *);

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

		extrn	_scrgoto:prog
                extrn	_scrputs:prog

_TEXT		SEGMENT	byte public 'CODE'
		ASSUME	cs:_TEXT

		PUBLIC	_scrouts
_scrouts	PROC	prog

		push	bp
		mov	bp,sp
		push	word ptr [bp+(ArgOff+2)]
		push	word ptr [bp+(ArgOff+0)]
		call	prog ptr _scrgoto
		mov	sp,bp
		push	word ptr [bp+(ArgOff+6)]
		push	word ptr [bp+(ArgOff+4)]
		call	prog ptr _scrputs
		mov	sp,bp
		pop	bp
		quit

_scrouts	ENDP
_TEXT		ENDS
		END
