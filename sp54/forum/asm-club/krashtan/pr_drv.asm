	.model small, C
	jumps
	locals

SIO	equ	3f8h

	.code

	org	100h
begin:
	jmp	main

;-------------------------------

newint	proc	near

	and	dx, dx
	je	com1			; if dx = 0 then com1 selected
        cmp     dx, 1
        je      decoder         ; if ASCII -> KOI7 selected
	jmp	dword ptr cs:[OldVect]

decoder:
        cmp     ah, 1
        je	@@deco
	push	dx
	xor	dx, dx
	int	14h
	pop 	dx
	iret
@@deco:
        push    bx
        test    al, 80h
        jne     @@tran
        cmp     prev, 0
        je      @@output
        push    ax
        mov     al, 15          ; send SI
	mov	prev, 0
        jmp     @@sendS
@@tran:
        and     al, 7fh
        lea     bx, tabl
        xlat    cs:tabl
        cmp     prev, 0
        jne     @@output

        push    ax
        mov     al, 14          ; send SO
	mov	prev, 1
@@sendS:
        xor     dx, dx
        int     14h
        pop     ax
@@output:
        pop     bx
        xor     dx, dx
        jmp     newint                  ; int 14h

com1:
	push	bx cx dx
	or	ah, ah
	je	@@init
	cmp	ah, 3
	jne	@@2
@@init:
	mov	dx, SIO + 5
	in	al, dx
	mov	ah, al
	inc	dx
	in	al, dx
	jmp	@@quit

@@2:
	cmp	ah, 2
	jne	@@1
	
	jmp	@@init			; ??? not used

@@1:
	cmp	ah, 1
	jne	@@quit

	push	ax
	mov	ah, 200	
@@more:
	mov	cx, 0ffffh		; waiting CTS
	mov	dx, SIO + 6
@@CTS:
	in	al, dx
	test	al, 00010000b
	jnz	@@CTS_OK
	loop	@@CTS
	dec	ah
	jne	@@more
	
	dec	dx
	in	al, dx
	or	al, 80h			; timeout
	mov	cl, al
	pop	ax
	mov	ah, cl
	jmp	@@quit

@@CTS_OK:
	mov	cx, 0ffffh		; 
	dec	dx
@@w_send:
	in	al, dx
	test	al, 00100000b
	jne	@@send
	loop	@@w_send
	or	al, 80h			; timeout
@@send:
	mov	cl, al
	pop	ax
	sub	dx, 5
	out	dx, al
	mov	ah, cl

@@quit:
	pop	dx cx bx
	iret
newint	endp

prnint	proc
        and     dx, dx
        je      @@prcom
	jmp	dword ptr cs:[oldprn]

@@prcom:
        push    ax dx
        mov     ah, 1
        xor     dx, dx
        int     14h
        test    ah, 80h
        mov     ah, 10h
        je      @@endpr
        or      ah, 1
@@endpr:
        pop     dx ax
        iret
prnint	endp

OldVect	dw	?, ?
oldprn	dw	?, ?
prev    db      0

;--- Translate ASCII -> KOI7(printable)-----

tabl	db	"abwgdevzijklmnop"
	db	"rstufhc~{}_yx|", 60h
	db	"qABWGDEVZIJKLMNOP"
	db	"###!!!!++!!+++++"
	db	"+++!-+!!++==!==="
	db	"-=-++++!=++#####"
	db	"RSTUFHC^[]_YX\@Q"
	db	"eEiIjJeEgG-+#$* "

;-------------------------------

main:
	cli
	xor	ax, ax
	mov	ds, ax
	mov	ax, ds:[4*14h]
	mov	bx, ds:[4*14h+2]	; old vector
	mov	cs:[OldVect], ax
	mov	cs:[OldVect+2], bx

        mov     ax, ds:[4*17h]
        mov     bx, ds:[4*17h+2]        ; old vector
        mov     cs:[Oldprn], ax
        mov     cs:[Oldprn+2], bx

	lea	ax, newint
	mov	ds:[4*14h], ax
	mov	ax, cs
	mov	ds:[4*14h+2], ax	; new vector

        lea     ax, prnint
        mov     ds:[4*17h], ax
	mov	ax, cs
        mov     ds:[4*17h+2], ax        ; new vector

	mov	word ptr ds:[400h], SIO	; COM1 base addres
	mov	word ptr ds:[402h], SIO - 100h ; COM2

;--------------- COM1 init ------------	

	mov	dx, SIO + 3		; 3fbh
	mov	al, 80h
	out	dx, al
	dec	dx
	dec	dx
	xor	al, al			; 3f9h = 0
	out	dx, al
	mov	al, 0ch			; 3f8h = 0ch
	dec	dx
	out	dx, al			; 9600 baud

	add	dx, 3
	mov	al, 00000111b		; no parity, 8 bit, 2 stop
	out	dx, al	
	inc	dx
	mov	al, 3
	out	dx, al

	sub	dx, 3
	xor	al, al
	out	dx, al			; no interrupts

	sti

	lea	si, hello
	push	cs
	pop	ds
@@header:
	mov	ah, 0eh
	mov	bx, 15
	lodsb
	or	al, al
	je	@@exit
	int	10h
	jmp	@@header
@@exit:	
	mov	ax, cs:[2ch]		; clear enviroment
	mov	es, ax
	mov	ah, 49h
	int	21h
	lea	dx, main
	int	27h			; exit & stay resident


hello	db	10,13,"Serial printer driver, (C) Eugene Krashtan, Kiev, 1993"
	db	10,13,"---------------------"
	db	10,13,"Printer driver installed on COM1:, COM2:, LPT1:",10,13,0

	end begin
