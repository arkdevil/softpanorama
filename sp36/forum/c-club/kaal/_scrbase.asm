	.model large,c
	.code

	public _scrbase

; V2.0x (DESQview aware)    (C) by MacSoft 1990
;
; int far *__scrbase(void)
;
; Calculate screen base address.
;
; Note that DV will probably change virtual buffer address when task
; switches, so it's safe only if you stop task switching before getting
; screen base address.
;
_scrbase	proc
	uses	di,es		;TASM pushes
	xor	di,di
	mov	es,di		;get ready for DESQview
	mov	ah,0feh		;DV get video buffer
	int	10h		;must change if DV
	mov	dx,es
	or	di,dx		;offset
	jz	nodv		;if not same, we have DV
	mov	dx,es		;get ready for everything
	jmp short	w1		;on screen I/O
nodv:	mov	al,es:[449h]		;get video mode
	mov	dx,0b000h		;prepare for mono
	cmp	al,7		;is it?
	jz	w1		;yes, it's OK
	mov	dx,0b800h		;use mono instead
w1:	xor	ax,ax		;offset 0
	ret
_scrbase	endp

	end
