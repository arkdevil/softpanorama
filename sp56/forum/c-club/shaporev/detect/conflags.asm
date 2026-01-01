		NAME	conflags
		PAGE	55,132

; Function:	returns system configuration byte.
;
; Caller:	Turbo C:
;			int conflags(void);
;
; Returns:	-1 if unsupported else
;		bit 7 (80h) - DMA channel 3 used by hard disk BIOS
;		bit 6 (40h) - 2nd 8259 installed
;		bit 5 (20h) - realtime clock installed
;		bit 4 (10h) - int 15h,fn 04h called upon int 09h
;		bit 3 (08h) - wait for external event supported
;		bit 2 (04h) - extended BIOS area allocated at 640k
;		bit 1 (02h) - bus is Micro Channel instead of PC

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

		PUBLIC	_conflags
_conflags	PROC	prog

		push	es
		xor	bx,bx
		mov	es,bx		; es:bx - invalid address
		mov	ah,0C0h
		int	15h
		jc	fail		; function unsupported
		mov	ax,es
		or	ax,bx		; es:bx changed?
		jz	fail		; no, function unsupported
		mov	al,es:[bx+5]	; features byte
		mov	ah,es:[bx+2]	; machine ID byte
		cmp	ah,0FEh		; check for XT
		je	xt
		cmp	ah,0FBh		; check for XT
		jne	success
xt:		mov	bx,0F000h
		mov	es,bx
		mov	bx,0FFF5h
		cmp	byte ptr es:[bx+6],'8'	; tenths of the years
		jne	success
		cmp	byte ptr es:[bx+7],'6'	; units of the years
		ja	success
		jb	fail
		cmp	byte ptr es:[bx+0],'0'	; month 1-st digit
		ja	success
		cmp	byte ptr es:[bx+1],'0'	; month 2-nd digit
		ja	success
		cmp	byte ptr es:[bx+3],'1'	; day 1-st digit
		ja	success
		jb	fail
		cmp	byte ptr es:[bx+4],'0'	; day 2-nd digit
		jna	fail
success:	xor	ah,ah
		jmp	short return
fail:		mov	ax,-1
return:		pop	es
		quit

_conflags	ENDP

_TEXT		ENDS

		END

