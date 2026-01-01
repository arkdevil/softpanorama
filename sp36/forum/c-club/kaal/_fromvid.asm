	.model large,c
	.code

	public _fromvid

; V2.0x (DESQview aware)     (C) by MacSoft 1990
;
; void far __fromvid(int x,int y,char far *data,unsigned int count)
;
; Move data from screen to memory buffer. Destination may be screen
; if buffers are not overlapped. Count is word count because on IBM
; screen characters are followed by attributes and we're dealing
; with colours...
;
_fromvid	proc
	arg	x:word,y:word,d:dword,c:word
	uses	si,di,ds		;TASM makes PUSHes
	xor	di,di		;0:40 is BIOS data segment
	mov	ds,di		;just be ready...
	mov	es,di		;get ready for DESQview
	mov	ah,0feh		;DV get video buffer
	int	10h		;must change if DV
	mov	dx,es		;get segment and
	or	di,dx		;if unchanged get video
	jz	nodv		;if not same, we have DV
	mov	ah,ds:[44ah]		;get number of columns
	mov	bl,7		;and fake mono
	jmp short	t1		;on screen I/O
nodv:	mov	ax,ds:[449h]		;get current video mode
	mov	bl,al		;save for snow test
	mov	dx,0b000h		;prepare for mono
	cmp	al,7		;if mono
	jz	t1		;then OK
	mov	dx,0b800h		;else switch to color
	test byte ptr ds:[487h],4		;test EGA retrace bit
	jnz	t1		;0 means write any time
	mov	bl,7		;so fake we have mono
t1:	mov	ds,dx		;DS=video segment
	mov	al,ah		;number of col's
	xor	ah,ah		;convert to word
	add	ax,ax		;mul 2
	mul	y		;offset to line start
	mov	si,x		;get x
	add	si,si		;mul 2
	add	si,ax		;DS:SI to right pos.
	les	di,d		;ES:DI to memory pos
	mov	dx,3dah		;get CGA status port
	mov	cx,c		;get WORD count
	jcxz	t5		;nothing to do!
	cld			;clear direction
t6:	cmp	bl,7		;do we need to test?
	jz	t2		;skip wait on mono
	cli			;nasty, but useful...
t4:	in	al,dx		;get retrace bit
	and	al,1		;and wait if set
	jnz	t4		;to get full period
t3:	in	al,dx		;get data
	and	al,1		;get retrace bit
	jz	t3		;not set, wait for it
t2:	movsw			;move the data
	sti			;and int's back on...
	loop	t6		;move them all
t5:				;TASM makes POPs here
	ret			;and we're done
_fromvid	endp

	end
