	.model large,c
	.code

	public _vlwrite

; V2.0x (DESQview aware)    (C) by MacSoft 1990
;
; void far __vlwrite(int x,int y,unsigned int charattr,unsigned int count)
;
; Write count successive characters/attributes starting from
; screen location X,Y.
;
_vlwrite	proc
	arg	x:word,y:word,d:word,c:word
	uses	di		;TASM pushes
	xor	di,di
	mov	es,di		;get ready for DESQview
	mov	ah,0feh		;DV get bideo buffer
	int	10h		;must change if DV
	mov	dx,es
	or	di,dx		;if not, get video mode
	jz	nodv		;if not same, we have DV
	mov	dx,es		;get ready for everything
	xor	di,di		;switch ES
	mov	es,di		;back to BIOS data
	mov	ah,es:[44ah]		;get number of columns
	mov	bl,7		;and fake mono
	jmp short	l1		;on screen I/O
nodv:	mov	ax,es:[449h]		;get video mode
	mov	bl,al		;save it
	mov	dx,0b000h		;prepare for mono
	cmp	al,7		;mono?
	jz	l1		;yep, go on
	mov	dx,0b800h		;else set color segment
	test byte ptr es:[487h],4		;and look EGA flag
	jnz	l1		;set, test snow
	mov	bl,7		;else fake mono
l1:	mov	es,dx		;ES=video segment now
	mov	al,ah		;number of col's
	xor	ah,ah		;word...
	add	ax,ax		;mul 2
	mul	y		;to begin of line
	mov	di,x		;get x
	add	di,di		;mul 2
	add	di,ax		;ES:DI to memory pos
	mov	dx,3dah		;get CGA status port
	mov	ax,d		;get data
	mov	cx,c		;get WORD count
	jcxz	v5		;nothing to do!
	cld			;clear direction
v6:	cmp	bl,7		;mono?
	jz	v2		;skip wait if so
	push	ax		;save data
	cli			;silencio!
v4:	in	al,dx		;get retrace bit
	and	al,1		;and wait it to go low
	jnz	v4		;to get full period
v3:	in	al,dx		;get status
	and	al,1		;test retrace bit
	jz	v3		;not set, wait for it
	pop	ax		;recover data
v2:	stosw			;write char/attribute
	sti			;let us roll again
	loop	v6		;and do all words
v5:
	ret
_vlwrite	endp

	end
