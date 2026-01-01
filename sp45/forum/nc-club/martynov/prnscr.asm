.model	tiny
; Print Screen utility
; Complie with MASM or Quick-C 2.01 into COM file
lowaddr	segment	at	0
	org	14h
int5off	dw	?
int5seg	dw	?
	org	40h
int10of dw	?
int10sg dw	?
	org	408h
lptbase dw	?
	org	484h
maxtrow	db	?
lowaddr	ends
code	segment	para
	assume	cs:code,ds:code
	org	2Ch
envseg	dw	?
	org	100h
start:	jmp	putmsg
old10of dw	?
old10sg dw	?
pagenum db	0
tcols	db	0
trows	db	0
outbyte	db	0
grows	dw	0
gcols	dw	0
x0	dw	0
lpt1	dw	?	;not nesessary for VPIX variant
initgr	db	27,"K"
prows	dw	0	;must follow initgr!
setspc	db	27,"A",8
restspc	db	27,'2'
feed	db	10,13
lpt1ini	proc	near
	push	ax
	push	dx
;We may use BIOS interrupt to initialize LPT1...
	mov	ah,01
	sub	dx,dx
	int	17h
;instead of following low-lewel manipulations described in Jourdain ch.6.1
;	mov	dx,lpt1
;	inc	dx
;	inc	dx
;	mov	al,12
;	cli
;	out	dx,al
;	mov	ax,800h
;delay:	dec	ax
;	jnz	delay
;	mov	al,8
;	out	dx,al
;	sti
	pop	dx
	pop	ax
	ret
lpt1ini	endp
lpt1out	proc	near	;al->LPT1 see Jourdain ch.6.3
	push	dx
	push	ax
	mov	dx,lpt1
	inc	dx
delay3: in	al,dx
	test	al,10h
	jnz	online3
	mov	ax,0FFFFh
	mov	trows,al
	mov	x0,ax
online3:test	al,80h	;ready?
	jz	delay3
	dec	dx
	pop	ax
	out	dx,al
	inc	dx
	inc	dx
	mov	al,13
	out	dx,al
	dec	al
	out	dx,al
	dec	dx
delay2: in	al,dx
	test	al,10h
	jnz	online2
	mov	ax,0FFFFh
	mov	trows,al
	mov	x0,ax
online2:test	al,80h	;free?
	jz	delay2
	pop	dx
	ret
lpt1out	endp
;Variant for VPIX users:
;Uses Esc-@ to initialize LPT1 and int 17h for output
;lpt1ini proc	near
;	push	ax
;	push	dx
;	mov	ax,1Bh
;	sub	dx,dx
;	int	17h
;	mov	ax,'@'
;	sub	dx,dx
;	int	17h
;	pop	dx
;	pop	ax
;	ret
;lpt1ini endp
;lpt1out proc	near	;al -> LPT1
;	push	dx
;	push	ax
;	sub	dx,dx
;	mov	ah,0
;	int	17h
;	test	ah,10h
;	jnz	online3
;	mov	ax,0FFFFh
;	mov	trows,al
;	mov	x0,ax
;online3:pop	ax
;	pop	dx
;	ret
;lpt1out endp
outstr	proc	near
prloop:	mov	al,[bx]
	call	lpt1out
	inc	bx
	loop	prloop
	ret
outstr	endp
handler:push	ax
	push	bx
	push	cx
	push	dx
	push	ds
	sub	ax,ax
	mov	ds,ax
	assume	ds:lowaddr
	mov	al,maxtrow
	push	cs
	pop	ds
	assume	ds:code
	mov	trows,al
	sti
	call	lpt1ini
	mov	ah,0Fh	;get videomode & page
	int	10h
	mov	pagenum,bh
	cmp	al,01h
	jg	v80x25
	mov	ax,39
	jmp	textpr
v80x25:	cmp	al,03h
	jg	v200
	mov	ax,79
textpr:	mov	tcols,al
	mov	ah,03h
	mov	bh,pagenum
	int	10h
	push	dx
	sub	dh,dh
tloop1:	sub	dl,dl
tloop2:	mov	ah,02h
	mov	bh,pagenum
	int	10h
	mov	ah,08h
	mov	bh,pagenum
	int	10h
	call	lpt1out
	cmp	dl,tcols
	jnb	endtl2
	inc	dl
	jmp	tloop2
endtl2:	mov	bx,offset feed
	mov	cx,2
	call	outstr
	cmp	dh,trows
	jnb	endtpr
	inc	dh
	jmp	tloop1
endtpr:	pop	dx
	mov	ah,02h
	mov	bh,pagenum
	int	10h
	jmp	exit
v200:	cmp	al,0Eh
	jg	v350
	mov	bx,640
	cmp	al,06h
	je	setrows
	cmp	al,0Eh
	je	setrows
	mov	bx,320
setrows:mov	ax,200
	jmp	graphpr
v350:	cmp	al,10h
	jg	vga480
	mov	bx,640
	mov	ax,350
	jmp	graphpr
vga480:	cmp	al,12h
	jg	vga200
	mov	bx,640
	mov	ax,480
	jmp	graphpr
vga200:	cmp	al,13h
	jg	unknown
	mov	bx,320
	mov	ax,200
	jmp	graphpr
unknown:jmp	exit	;Other videomodes not supported
graphpr:dec	bx
	mov	gcols,bx
	dec	ax
	mov	grows,ax
	inc	ax
	cmp	ah,0
	jne	single
	cmp	bx,320
	jng	single
	shl	ax,1
single:	mov	prows,ax
	mov	bx,offset setspc
	mov	cx,3
	call	outstr
	mov	ax,gcols
gloop1:	mov	x0,ax
	mov	bx,offset initgr
	mov	cx,4
	call	outstr
	sub	dx,dx
gloop2:	mov	bx,x0
	mov	cx,8
	sub	ax,ax
	mov	outbyte,al
gloop3:	push	cx
	push	bx
	mov	ah,0Dh	;get pixel
	mov	cx,bx
	mov	bh,pagenum
	int	10h
	mov	bl,outbyte
	shl	bl,1
	cmp	al,0
	je	black
	or	bl,01h
black:	mov	outbyte,bl
	pop	bx
	pop	cx
	dec	bx
	loop	gloop3
	mov	al,outbyte
	call	lpt1out
	mov	ax,grows
	cmp	ah,0	;200 or much more?
	jne	endgl2
	mov	ax,gcols
	cmp	ax,320
	jng	endgl2
	mov	al,outbyte
	call	lpt1out
endgl2:	inc	dx
	cmp	dx,grows
	jng	gloop2
	mov	ax,grows
	cmp	ax,480
	jnb	endgl1
	mov	bx,offset feed
	mov	cx,2
	call	outstr
endgl1:	mov	ax,x0
	sub	ax,8
	test	ah,80h
	jnz	endpr
	jmp	gloop1
endpr:	mov	bx,offset restspc
	mov	cx,2
	call	outstr
	mov	dx,offset feed
	mov	cx,2
	call	outstr
	mov	ax,gcols
	cmp	ax,320
	jng	exit
	mov	al,0Ch	;form feed
	call	lpt1out
exit:	pop	ds
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	iret
;disable selection alternative BIOS print screen routine
disab:	cmp	ah,12h
	jne	old10
	cmp	bl,20h
	jne	old10
	iret
old10:	jmp	dword ptr cs:[old10of]
putmsg: mov	dx,offset mesg
	mov	ah,09h
	int	21h
	cli
	sub	ax,ax
	mov	ds,ax
	assume	ds:lowaddr
	mov	ax,int10of
	mov	old10of,ax
	mov	ax,int10sg
	mov	old10sg,ax
	mov	ax,cs
	mov	int5seg,ax
	mov	int10sg,ax
	mov	ax,offset handler
	mov	int5off,ax
	mov	ax,offset disab
	mov	int10of,ax
	mov	ax,lptbase	;not nesessary
	mov	lpt1,ax		;for VPIX variant
	sti
	mov	ax,envseg
	mov	es,ax
	mov	ah,49h	;free environment area
	int	21h
	mov	ax,3100h
	mov	dx,(putmsg-code)/16+1
	int	21h
copr	db	'PRNSCR: Copyright(C) 1990-92 Martynoff D.A. (KIAE,Moscow)'
mesg	db	10,13,'PrintScreen Utility loaded.',10,13,10,13
	db	'This program prints screen contents on the'
	db	' EPSON compatible printer.',10,13
	db	'To cancel printing just switch printer off and on.',10,13,"$"
code	ends
	end	start
