		NAME	VGAChipset
		PAGE	55,132

; Function:	returns VGA chips set code
;
; Caller:	Turbo C:
;			int VGAChipset(void);
;
; Returns:	0 - unknown
;		1 - Tseng Labs
;		2 - Paradise
;		3 - Video 7

		ifdef	__NEAR__
prog		equ	near
quit		equ	ret
		else
prog		equ	far
quit		equ	retf
		endif

chipUNKNOWN	equ	0
chipTSENG	equ	1
chipPARA	equ	2
chipV7		equ	3

_TEXT		SEGMENT	byte public 'CODE'
		ASSUME	cs:_TEXT

		PUBLIC	_VGAChipset
_VGAChipset	PROC	prog

		push	ds
		push	es
		push	di
		mov	ax,6F00h	; Video 7 installation check
		xor	bx,bx
		int	10h
		mov	al,chipV7
		cmp	bx,5637h	; 'V7'
		je	end
		mov	ax,0C000h
		mov	ds,ax
		mov	es,ax
		sub	di,di
		mov	cx,500
		mov	al,'P'
search_para:
		repnz	scasb
		jcxz	test_tseng
		cmp	byte ptr ds:[ di ],'A'
		jne	search_para
		cmp	byte ptr ds:[di+1],'R'
		jne	search_para
		cmp	byte ptr ds:[di+2],'A'
		jne	search_para
		cmp	byte ptr ds:[di+3],'D'
		jne	search_para
		cmp	byte ptr ds:[di+4],'I'
		jne	search_para
		cmp	byte ptr ds:[di+5],'S'
		jne	search_para
		cmp	byte ptr ds:[di+6],'E'
		jne	search_para
		mov	al,chipPARA
		jmp	short end
test_tseng:
		sub	di,di
		mov	cx,500
		mov	al,'T'
search_tseng:
		repnz	scasb
		jcxz	unknown
		cmp	byte ptr ds:[ di ],'s'
		jne	search_tseng
		cmp	byte ptr ds:[di+1],'e'
		jne	search_tseng
		cmp	byte ptr ds:[di+2],'n'
		jne	search_tseng
		cmp	byte ptr ds:[di+3],'g'
		jne	search_tseng
		mov	al,chipTSENG
		jmp	short end
unknown:
		mov	al,chipUNKNOWN
end:
		cbw
		pop	di
		pop	es
		pop	ds
		quit

_VGAChipset	ENDP

_TEXT		ENDS

		END
