		NAME	bustype
		PAGE	55,132

; Function:	returns bus type flag
;
; Caller:	Turbo C:
;			int bustype(void);
;
; Returns:	2 = bus is MicroChannel
;		1 = bus is EISA
;		0 = any other (ISA or PC)
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

Find_MCA        proc    near
; Now let's try to find MicroChannel via int 15 function C0
		xor	bx,bx
		mov	es,bx		; es:bx - invalid address
		mov	ah,0C0h
		int	15h
		jc	no_MCA		; function unsupported
		mov	ax,es
		or	ax,bx		; es:bx changed?
		jz	no_MCA		; no, function unsupported
		test	byte ptr es:[bx+5],2
		jz	no_MCA		; no care if unsupported
; MicroChannel flag was found. Is the possibility supported?
		mov	ah,es:[bx+2]	; machine ID byte
		cmp	ah,0FEh		; check for XT
		je	xt
		cmp	ah,0FBh		; check for XT
		jne	found_MCA
xt:		mov	bx,0F000h
		mov	es,bx
		mov	bx,0FFF5h
		cmp	byte ptr es:[bx+6],'8'	; tenths of the years
		jne	found_MCA
		cmp	byte ptr es:[bx+7],'6'	; units of the years
		ja	found_MCA
		jb	no_MCA
		cmp	byte ptr es:[bx+0],'0'	; month 1-st digit
		ja	found_MCA
		cmp	byte ptr es:[bx+1],'0'	; month 2-nd digit
		ja	found_MCA
		cmp	byte ptr es:[bx+3],'1'	; day 1-st digit
		ja	found_MCA
		jb	no_MCA
		cmp	byte ptr es:[bx+4],'0'	; day 2-nd digit
		ja	found_MCA
no_MCA:		stc
		retn
found_MCA:	clc
                retn
Find_MCA        endp

Find_EISA	proc	near
		push	si
                push	di

		mov	al,0		; subfunction number
		mov	bx,sp
		pushf			; distinguish 32 or 16 bit operand
		mov	cx,sp		; if pushf pushed 2 bytes then
		popf			; 16 bit operand size
		inc	cx		; assume 2 bytes
		inc	cx
		cmp	cx,bx
		je	test_EISA
		or	al,80h		; EISA software assume 32-bit
test_EISA:	mov	ah,0D8h
                mov	cl,0		; slot number
		xor	bx,bx		; [e]bx = 0
		dec	bx		; [e]bx = -1 invalid rev.level
		int	15h		; read slot configuration
		inc	bx              ; [e]bx changed?
		jnz	found_EISA	; value changed - software present
		stc
		jmp	short end_EISA
found_EISA:	clc
end_EISA:
		pop	di
		pop	si
                retn
Find_EISA	endp

		PUBLIC	_bustype
_bustype	PROC	prog
                push    es
                call    near ptr Find_MCA
		jc      next
                mov     al,2
		jmp	short return
next:		call	near ptr Find_EISA
		jc	default
		mov	al,1
		jmp	short return
default:	xor	al,al
return:		cbw
                pop     es
_bustype	ENDP

_TEXT		ENDS

		END

