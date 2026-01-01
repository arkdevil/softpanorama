		NAME	MathUnit
		PAGE	55,132
;
; Function:	determines math co-processor type.
;
; Caller:	Turbo C:
;			int MathUnit(void);
;
; Returns:	0 - no coprocessor detected
;		1 - Intel 8087
;		2 - Intel 80287
;		3 - Intel 80387
;		4 - Wietek 1167
;		5 - Weitek 1167 and 80387
;
; Source algorithm by Peter Norton, System Information,
;	Advanced Edition 4.50

.286p

		ifdef	__NEAR__
prog		equ	near
quit		equ	ret
		else
prog		equ	far
quit		equ	retf
		endif

_TEXT		SEGMENT	byte public 'CODE'
		ASSUME	cs:_TEXT

		PUBLIC	_MathUnit
_MathUnit	PROC	prog

		push	bp

		push	sp		; 86/186 or 286/386
		pop	ax		; 86/186 will push sp-2
		cmp	ax,sp		; others will push sp
		jne	short no_386	; no 80286/80386

		sub	sp,6
		mov	bp,sp		; allocate room for SGDT

		ifndef	PWORD
		sgdt	FWORD PTR ss:[bp]	; 286 assemblers
		else
		sgdt	PWORD PTR ss:[bp]	; 386 assemblers
		endif

		add	sp,4		; trash limit and base (low word)
		pop	ax
		inc	ah		; 286 stores -1, 386 stores 0 or 1
		jz	no_386

		db	66h		; xor	eax,eax
		xor	ax,ax

		int	11h

		db	66h
		test	ax,0		; test	eax,01000000h
		dw	0100h		; Weitek present?

		jz	no_386
		mov	al,4
		jmp	short CPU_ok
no_386:		mov	al,0
CPU_ok:
		mov	bp,sp
		sub	sp,18		; allocate working varibles
		mov	byte ptr ss:[bp-17],0

		db	0DBh,0E3h	; finit
		xor	cx,cx
		jmp	short $+2	; wait a moment
		db	0D9h,07Eh,0EEh	; fstcw word ptr ss:[bp-18]
		mov	cl,100		; CX = 100
		loop	$		; wait for response
		cmp	byte ptr ss:[bp-17],3
		jne	end
		cmp	al,4
		je	l1
		inc	al		; mov dl,1
l1:		wait
		db	0D9h,076h,0F0h	; fstenv word ptr ss:[bp-16]
		wait
		and	word ptr ss:[bp-18],0FF7Fh
		wait
		db	0D9h,06Eh,0EEh	; fldcw word ptr ss:[bp-18]
		wait
		db	0DBh,0E1h	; fdisi
		wait
		db	0D9h,07Eh,0EEh	; fstcw word ptr ss:[bp-18]
		wait
		test	word ptr ss:[bp-18],80h
		jnz	finish
		db	0DBh,0E3h	; finit
		cmp	al,4
		je	l2
		inc	al		; mov dl,2
l2:		wait
		db	0D9h,0E8h	; fld1
		wait
		db	0D9h,0EEh	; fldz
		wait
		db	0DEh,0F9h	; fdivp	  st(1),st
		wait
		db	0D9h,0C0h	; fld	  st(0)
		wait
		db	0D9h,0E0h	; fchs
		wait
		db	0DEh,0D9h	; fcompp  st(1)
		wait
		fstsw	word ptr ss:[bp-18]
		mov	ah,ss:[bp-17]	; mov ax,[bp-18]
		sahf
		je	finish
		cmp	al,4
		je	l3
		inc	al		; mov dl,3
		jmp	short finish
l3:		inc	al
finish:		wait
		fldenv	ss:[bp-16]
end:		cbw

		mov	sp,bp		; restore stack
		pop	bp
		quit

_MathUnit	ENDP

_TEXT		ENDS

		END

