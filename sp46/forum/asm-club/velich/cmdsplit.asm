; ╓────────────────────────────────────────────────────────────────────
; ║ ▌     Module name        : CMDSPLIT.ASM
; ║ ▌     Last revision date : 24.5.92
; ║ ▌     Subroutine(s)      : CmdLSplit
; ║ ▌
; ║ ▌                        Description
; ║ ▌
; ║ ▌     Процедура осуществляет разбор командной строки, находящейся
; ║ ▌  в буфере PSP по адресу 80h, и помещает результат в SPLIT-буфер
; ║ ▌  в виде <Ptr>,<Len>,<Ptr>... , а количество параметров
; ║ ▌  возвращается в AX.
; ║ ▌
; ║ ▌ Expect:	
; ║ ▌	ES    - segment of the PSP
; ║ ▌	DS:DI - points to terminators table
; ║ ▌   CX    - amount of terminators in the table (zero if none)
; ║ ▌	DS:SI - points to SPLIT-buffer: array of {<Ptr>,<Len>}
; ║ ▌ Return:
; ║ ▌	AX    - number of parameters
; ║ ▌
; ║ ▌      (C) Copyright by Al Snyatkov & Nick Velichko
; ╙────────────────────────────────────────────────────────────────────

CmdLSplit	proc	near

	push	bx dx si
	
	sub	ax,ax			; AH = param.count = 0
	mov	bx,80h			; Set BX to command line
	mov	dh,es:[bx]		; sym.amount
	or	dh,dh			; =0 ?
	jz	$exit
before_start:
	sub	dl,dl			; param.length = 0
begin_cycle:
	inc	bx
	mov	al,es:[bx]
	cmp	al,' '
	ja	main_cycle
	dec	dh			; sym.amount--
	jz	$exit
	jmp	short	begin_cycle
; ---------------------------------------
main_cycle:
	mov	[si],bl			; param.ptr
	inc	si
	inc	ah			; param.count++
$cycle:	dec	dh			; sym.amount--
	jnz	$continue
	inc	dx			; ???
	mov	[si],dl			; param.length
	jmp	short	$exit
$continue:
	inc	dx			;param.length++
	inc	bx
	mov	al,es:[bx]
	cmp	al,' '
	jbe	default_terminator
	cmp	al,'/'
	je	terminator_found
	jcxz	$cycle			; no user's terminators
	push	cx di es ds
	pop	es
	cld
	repne	scasb
	pop	es di cx
	jne	$cycle
terminator_found:
	dec	bx
default_terminator:
	mov	[si],dl			; param.length
	inc	si
	jmp	short	before_start
	
$exit:	mov	al,ah
	cbw
	pop	si dx bx
	
	ret
	
CmdLSplit	endp
