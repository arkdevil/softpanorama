		TITLE	'BIOS put string'
		NAME	biosputs
		PAGE	55,132
;
; Function:	TTY-style output text string to screen by BIOS
;
; Caller:	Turbo C
;
;			void biosputs (char far *);

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

		PUBLIC	_biosputs
		PUBLIC	_scrputs

_biosputs	PROC	prog
_scrputs:

		push	bp		; preserve caller registers
		mov	bp,sp
		push	ds
		push	si

		lds	si,ss:[bp+ArgOff]	; DS:SI -> text

print:		lodsb
		or	al,al
		jz	return
		mov	bl,0
		mov	ah,0Eh
		int	10h
		jmp	short print

return:		pop	si
		pop	ds
		pop	bp
		quit

_biosputs	ENDP
_TEXT		ENDS
		END
