		TITLE	'BIOS put character'
		NAME	biosputc
		PAGE	55,132
;
; Function:	TTY-style output character to screen by BIOS
;
; Caller:	Turbo C
;
;			void biosputc (char);

		ifdef	__TINY__
__NEAR__	equ	0
		endif
		ifdef	__NEAR__
prog		equ	near
quit		equ	ret
ArgOff		equ	2
		else
prog		equ	far
quit		equ	retf
ArgOff		equ	4
		endif

_TEXT		SEGMENT	byte public 'CODE'
		ASSUME	cs:_TEXT

		PUBLIC	_biosputc
                PUBLIC	_scrputc

_biosputc	PROC	prog
_scrputc:

		mov	bx,sp
                mov	al,ss:[bx+ArgOff]
                mov	ah,0Eh
                mov	bl,0
                int	10h
		quit

_biosputc	ENDP
_TEXT		ENDS
		END
