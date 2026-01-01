	.model large,c
	.code

	public _tovid

; V2.0x (DESQview aware)     (C) by MacSoft 1990
;
; void far __tovid(int x,int y,char far *data,unsigned int count)
;
; Move data from memory to video memory. Source may be screen if
; buffers are not overlapped. Count is word count.
;
_tovid	proc
	arg	x:word,y:word,d:dword,c:word
	uses	si,di,ds		;TASM pushes
	xor	di,di		;BIOS data at 0:40
	mov	ds,di
	mov	es,di		;get ready for DESQview
	mov	ah,0feh		;DV get video buffer
	int	10h		;must change if DV
	mov	dx,es
	or	di,dx		;no, then go get mode
	jz	nodv		;if not same, we have DV
	mov	dx,es		;get ready for everything
	mov	ah,ds:[44ah]		;get number of columns
	mov	bl,7		;and fake mono
	jmp short	o1		;on screen I/O
nodv:	mov	ax,ds:[449h]		;get video mode
	mov	bl,al		;save for snow test
	mov	dx,0b000h		;prepare for mono
	cmp	al,7		;is it?
	jz	o1		;yep, go on
	mov	dx,0b800h		;else set to color
	test byte ptr ds:[487h],4		;EGA nosnow?
	jnz	o1		;nope, go on
	mov	bl,7		;else fake mono
o1:	mov	es,dx		;ES=video segment
	mov	al,ah		;number of col's
	xor	ah,ah		;to word
	add	ax,ax		;mul 2
	mul	y		;at line begin now
	mov	di,x		;get x
	add	di,di		;mul 2
	add	di,ax		;ES:DI to right pos
	lds	si,d		;DS:SI to memory pos
	mov	dx,3dah		;CGA status port
	mov	cx,c		;get WORD count
	jcxz	o5		;nothing to do!
	cld			;clear direction
o6:	cmp	bl,7		;no snow on mono...
	jz	o2		;skip wait on mono
	cli			;nasty thing ...
o4:	in	al,dx		;get retrace bit
	and	al,1		;and wait it to go low
	jnz	o4		;to get full period
o3:	in	al,dx		;get data
	and	al,1		;get retrace bit
	jz	o3		;not set, wait for it
o2:	movsw			;move the data
	sti			;ints back on
	loop	o6		;move 'em all
o5:				;TASM POPs
	ret			;and we're done
_tovid	endp

	end
