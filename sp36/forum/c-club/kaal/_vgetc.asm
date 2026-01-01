	.model large,c
	.code

	public _vgetc

; V2.0x (DESQview aware)    (C) by MacSoft 1990
;
; unsigned int far __vgetc(int x,int y)
;
; Get single character with attribute from video memory.
; Character will be returned in 8 lsb bits, attribute in 8 msb bits.
;
_vgetc	proc
	arg	x:word,y:word
	uses	ds,si,di		;TASM does the job...
	xor	di,di		;BIOS data segment
	mov	ds,di
	mov	es,di		;get ready for DV
	mov	ah,0feh		;DV get video buffer
	int	10h		;must change if DV
	mov	dx,es
	or	di,dx		;if not, get video mode
	jz	nodv		;if not same, we have DV
	mov	ah,ds:[44ah]		;number of columns
	mov	bl,7		;and fake mono
	jmp short	r1		;on screen I/O
nodv:	mov	ax,ds:[449h]		;video mode
	mov	bl,al		;save for snow test
	mov	dx,0b000h		;prepare for mono
	cmp	al,7		;is it?
	jz	r1		;mono, go on
	mov	dx,0b800h		;else we're doing color
	test byte ptr ds:[487h],4		;test fast write flag
	jnz	r1		;set, we must test
	mov	bl,7		;else fake mono
r1:	mov	ds,dx		;set video segment
	mov	al,ah		;number of col's
	xor	ah,ah		;to word
	add	ax,ax		;mul 2
	mul	y		;to line start
	mov	si,x		;get column
	add	si,si		;mul 2
	add	si,ax		;add to start offset
	cmp	bl,7		;mono?
	jz	r2		;yep, skip wait
	mov	dx,3dah		;status port
	cli			;make sure nobody disturbes
r4:	in	al,dx		;get retrace bit
	and	al,1		;and wait it to go low
	jnz	r4		;to get full period
r3:	in	al,dx		;status flags...
	and	al,1		;in retrace?
	jz	r3		;nope, wait
r2:	lodsw			;get the char and attribute
	sti			;rolling again
	ret			;and go back
_vgetc	endp

	end
