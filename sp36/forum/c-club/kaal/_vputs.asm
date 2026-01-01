	.model large,c
	.code

	public _vputs

; V2.0x (DESQview aware)    (C) by MacSoft 1990
;
; void far __vputs(int x,int y,char far *str,int attr)
;
; Write zero-terminated string to screen with given
; attribute starting at X,Y.
;
_vputs	proc
	arg	x:word,y:word,s:dword,a:word
	uses	si,di,ds		;TASM pushes
	xor	di,di		;BIOS data segment
	mov	ds,di		;at 0:40
	mov	es,di		;get ready for DESQview
	mov	ah,0feh		;DV get video buffer
	int	10h		;must change if DV
	mov	dx,es
	or	di,dx		;offset
	jz	nodv		;if not same, we have DV
	mov	ah,ds:[44ah]		;get number of columns
	mov	bl,7		;and fake mono
	jmp short	p1		;on screen I/O
nodv:	mov	ax,ds:[449h]		;get video mode
	mov	bl,al		;save it
	mov	dx,0b000h		;prepare for mono
	cmp	al,7		;how about it?
	jz	p1		;OK to go
	mov	dx,0b800h		;else switch to color
	test byte ptr ds:[487h],4		;test fast write flag
	jnz	p1		;set, must do it
	mov	bl,7		;else fake mono
p1:	mov	es,dx		;video segment
	mov	al,ah		;get # of col's
	xor	ah,ah		;word...
	add	ax,ax		;mul 2
	mul	y		;mul y, gives beg of line
	mov	di,x		;get column to begin with
	add	di,di		;mul 2
	add	di,ax		;ES:DI -> video location
	lds	si,s		;DS:SI -> string
	mov	ax,a		;get color
	mov	ah,al		;move to high byte
	cld			;prepare for string
	mov	dx,3dah		;video port
p5:	lodsb			;get byte
	or	al,al		;end of line?
	jz	p7		;yep, get out
	cmp	bl,7		;mono mode?
	jz	p6		;yep, skip snow test
	xchg	ax,cx		;keep character
	cli			;silence!
p2:	in	al,dx		;get retrace bit
	and	al,1		;and wait for it to go low
	jnz	p2		;to get full period
p4:	in	al,dx		;status again
	and	al,1		;in retrace?
	jz	p4		;nope, wait
	xchg	ax,cx		;recover character
p6:	stosw			;store one
	sti			;roll again
	jmp	p5		;else just put it
p7:	ret			;pop and back
_vputs	endp

	end
