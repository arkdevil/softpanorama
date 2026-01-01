; ╓────────────────────────────────────────────────────────────────────
; ║ ▌     Module name        : LTOA.ASM
; ║ ▌     Last revision date : 24.5.92
; ║ ▌     Subroutine(s)      : _L10TOA
; ║ ▌
; ║ ▌                        Description
; ║ ▌
; ║ ▌      Конвертирует long-число из CX:AX в строку (десятичный вид).
; ║ ▌ Адрес строки задается в DI. BP содержит правую границу для
; ║ ▌ выравнивания. Тысячные, миллионные и т.д. разряды разделяются 
; ║ ▌ запятыми. Длина получившейся строки возвращается в AX.
; ║ ▌
; ║ ▌      (C) Copyright by Al Snyatkov & Nick Velichko
; ╙────────────────────────────────────────────────────────────────────

	.Data

DigitsCnt	db	0
OutLength	dw	0

	.Code

_l10toa	proc	near
	push	di cx bp bx

	mov	DigitsCnt,0
	mov	OutLength,0
	mov	bx,10			; convert to decimal

	mov	si,di			
	
	cld				; no right margin 
	cmp	bp,0
	je	treat_number

	std
	add	di,bp		; right margin
	push	ax
	mov 	al,00
	stosb
	pop	ax

treat_number:
	jcxz	int_part

conv_high:
	xchg	cx,ax			; convert high word of long number
	sub	dx,dx
	div	bx
	xchg	cx,ax
	div	bx
	add	dl,'0'
	
	call	DigitsInc
	xchg	ax,dx			; store AL register
	stosb
	xchg	ax,dx
	jcxz	check_low		
	jmp	conv_high

int_part:
	sub	dx,dx			; convert low word of number
	div	bx			
	add	dl,'0'
	
	call	DigitsInc
	xchg	ax,dx			
	stosb
	xchg	ax,dx			
	
check_low:	
	or	ax,ax
	jnz	int_part

	cmp	bp,0
	jne	beg_fill
	xor	al,al
	mov	es:[di],al
	dec	di
	mov	al,32
rotate:
	mov	ah,es:[si]
	mov	al,es:[di]
	mov	es:[si],al
	mov	es:[di],ah
	inc	si
	dec	di
	cmp	si,di
	jb	rotate
	jmp	@@exit
	
beg_fill:
	sub	si,di
	neg	si
	inc	si
	jz	@@exit
	mov	cx,si
	mov	al,32
	rep stosb


@@exit:
	pop	bx bp cx di
	mov	ax,OutLength
	ret	

_l10toa	endp

DigitsInc	proc	near

	inc	DigitsCnt
	cmp	DigitsCnt,4
	jb	@@Cont
	push	ax
	mov	al,','
	stosb
	pop	ax
	mov	DigitsCnt,1
	inc	OutLength
@@Cont:
	inc	OutLength
	ret
	
DigitsInc	endp
