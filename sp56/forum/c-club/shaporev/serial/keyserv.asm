		NAME	keyserv
		PAGE	55,132

; Function:	performs compatible BIOS keyboard service
;
; Caller:	Turbo C:
;			int keyserv(int n);
;		Depending on n:
;		4 - clears keyboard input buffer and waits for a key
;		any other - performs corresponding keyboard function

		ifdef	__TINY__
		ifndef	__NEAR__
__NEAR__	equ	0
		endif
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

		PUBLIC	_keyserv
_keyserv	PROC	prog

		mov	bx,sp
		mov	ax,ss:[bx+ArgOff]
		xchg	ah,al
		cmp	ah,4
		je	short clr
		cmp	ah,1
		je	short chk
		cmp	ah,11h
		jne	short end
chk:		int	16h
		jnz	short return
		xor	ax,ax
		jmp	short return
clr:		mov	ah,1
		int	16h
		mov	ah,0
		jz	short end
		int	16h
		jmp	short clr
end:		int	16h
return:		quit

_keyserv	ENDP

_TEXT		ENDS

		END

