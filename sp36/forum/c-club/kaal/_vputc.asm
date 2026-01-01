	.model large,c
	.code

	public _vputc

; V2.0x (DESQview aware)    (C) by MacSoft 1990
;
; void far __vputc(int x,int y,unsigned int charattr)
;
; Write single character/attribute to video location X,Y.
;
_vputc	proc
	arg	x:word,y:word,d:word
	uses	di		;TASM pushes
	xor	di,di
	mov	es,di		;get ready for DESQview
	mov	ah,0feh		;DV get video buffer
	int	10h		;must change if DV
	mov	dx,es
	or	di,dx		;offset
	jz	nodv		;if not same, we have DV
	mov	dx,es		;get ready for everything
	xor	di,di		;switch ES
	mov	es,di		;back to BIOS data
	mov	ah,es:[44ah]		;and get number of columns
	mov	bl,7		;and fake mono
	jmp short	w1		;on screen I/O
nodv:	mov	ax,es:[449h]		;get video mode
	mov	bl,al		;save it
	mov	dx,0b000h		;prepare for mono
	cmp	al,7		;is it?
	jz	w1		;yes, it's OK
	mov	dx,0b800h		;use mono instead
	test byte ptr es:[487h],4		;test fast write flag
	jnz	w1		;set, test snow
	mov	bl,7		;else fake mono
w1:	mov	es,dx		;ES=video segm.
	mov	al,ah		;number of col's
	xor	ah,ah		;to word
	add	ax,ax		;mul 2
	mul	y		;ax=line offset
	mov	di,x		;get column
	add	di,di		;mul 2
	add	di,ax		;to right offset
	cmp	bl,7		;mono?
	jz	w2		;yep, skip retrace wait
	mov	dx,3dah		;video status
	cli			;nasty little thing
w4:	in	al,dx		;get retrace bit
	and	al,1		;and wait for it to go low
	jnz	w4		;to get full period
w3:	in	al,dx		;status
	and	al,1		;in retrace?
	jz	w3		;nope, wait
w2:	mov	ax,d		;retrace now
	stosw			;time to do it
	sti			;rolling again
	ret
_vputc	endp

	end
