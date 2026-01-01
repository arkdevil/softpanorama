		NAME	MathHere
		PAGE	55,132
;
; Function:	determines the presence of the math co-processor.
;
; Caller:	Turbo C:
;			int MathHere(void);
;
; Returns:	non-zero if coprocessor detected

		ifdef	__NEAR__
prog		equ	near
quit		equ	ret
		else
prog		equ	far
quit		equ	retf
		endif

_TEXT		SEGMENT	byte public 'CODE'
		ASSUME	cs:_TEXT

		PUBLIC	_MathHere
_MathHere	PROC	prog

		push	bp
		mov	bp,sp
                push    cx			; reserve stack

		db	0DBh,0E3h		; finit
		mov	word ptr ss:[bp-2],0
		db	0D9h,07Eh,0FEh		; fstcw word ptr ss:[bp-2]

		mov	cx,64h
l1:		jmp	short l2
l2:		loop	l1			; wait a moment

		and	word ptr ss:[bp-2],03BFh
		cmp	word ptr ss:[bp-2],03BFh
		jne	absent

		mov	word ptr ss:[bp-2],0
		db	0D9h,07Eh,0FEh		; fstcw word ptr ss:[bp-2]

		mov	cx,64h
l3:		jmp	short l4
l4:		loop	l3			; wait a moment

		and	word ptr ss:[bp-2],1F3Fh
		cmp	word ptr ss:[bp-2],033Fh
		jne	absent
		mov	ax,1
		jmp	short return
absent:		xor	ax,ax
return:
		pop	cx
		pop	bp
		quit

_MathHere	ENDP

_TEXT		ENDS

		END

