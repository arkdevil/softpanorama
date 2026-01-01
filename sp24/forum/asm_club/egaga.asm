;
;

pushrs	macro
	push	ax
	push	bx
	push	cx
	push	dx
	push	es
	push	bp
endm

poprs	macro
	pop	bp
	pop	es
	pop	dx
	pop	cx
	pop	bx
	pop	ax
endm


Code	segment	word
	assume	cs:Code
	
clstoggle	db	0
	even

presence	dw	1234h

myint10:
	or	ah,ah
	JZ	change_mode
	cmp	ah,011h
	JZ	chargen

jmprom:		db	0eah
old10	label	dword
oldoffs		dw	0
oldseg		dw	0

change_mode:
	mov	byte ptr cs:clstoggle,0
	TEST	AL,80h
	JZ	c1
	mov	byte ptr cs:clstoggle,0FFh
	and	al,7fh
c1:
	cmp	al,3
	jbe	sett8x14
	
	cmp	al,7
	jz	sett8x14
	cmp	al,0eh
	jbe	setg8x8
	cmp	al,10h
	jbe	setg8x14
	test	cs:clstoggle,0ffh
	jz	c2
	or	al,80h
c2:
	jmp	jmprom

chargen:
	cmp	al,30h
	jz	info
	cmp	al,02
	jnz	rr
	jmp	seta8x8

rr:	cmp	al,23h
	jz	nextchck
	cmp	al,12h
	jnz	jmprom
	jmp	sett8x8

nextchck:
	cmp	bl,3
	jnz	jmprom
	jmp	seta8x8

info:
	cmp	bh,2
	je	give8x14
	cmp	bh,3
	je	give8x8
	cmp	bh,4
	je	give8x8top
	jmp	jmprom

sett8x14:
	test	cs:clstoggle,0ffh
	jz	s1
	or	al,80h
s1:	pushf
	call	cs:[old10]
	pushrs
	mov	ax,1100h
	push	cs
	pop	es
	lea	bp,font8x14
	mov	cx,256
	mov	dx,0
	mov	bx,0e00h
	pushf
	call	cs:[old10]
	poprs
	iret

setg8x14:
	jmp	short mysetg
setg8x8:
	jmp	short mysetg8

give8x14:
	pushf
	call	cs:[old10]
	push	cs
	pop	es
	lea	bp,font8x14
	iret

give8x8:
	pushf
	call	cs:[old10]
	push	cs
	pop	es
	lea	bp,font8x18
	iret
	
give8x8top:
	pushf
	call	cs:[old10]
	push	cs
	pop	es
	lea	bp,font8x8
	add	bp,128*8
	iret

mysetg:
	pushf
	call	cs:[old10]
	pushrs
	mov	ax,1121h
	push	cs
	pop	es
	lea	bp,font8x14
	mov	cx,14
	mov	bl,25
	pushf
	call	cs:[old10]
	poprs
	iret

mysetg8:
	pushf
	call	cs:[old10]
	pushrs
	mov	ax,1121h
	push	cs
	pop	es
	lea	bp,font8x8
	mov	cx,8
	mov	bl,25
	pushf
	call	cs:[old10]
	poprs
	iret

seta8x8:
	pushrs
	mov	ax,1121h
	push	cs
	pop	es
	lea	bp,font8x8
	mov	cx,8
	mov	bx,3
	pushf
	call	cs:[old10]
	poprs
	iret

sett8x8:
	pushrs
	mov	ax,1110h
	push	cs
	pop	es
	lea	bp,font8x8
	mov	cx,100h
	mov	bx,800h
	mov	dx,0
	pushf
	call	cs:[old10]
	poprs
	iret


font8x8		label	byte

	INCLUDE		0808.asm	

font8x14	label	byte

	INCLUDE		0814.asm


install:
	mov	ax,3510h
	int	21h
	mov	ax,es:[bx-2]
	cmp	ax,presence
	jz	already
	mov	cs:oldoffs,bx
	mov	cs:oldseg,es
	push	cs
	pop	ds
	lea	dx,myint10
	mov	ax,2510h
	int	021h	
	lea	dx,font8x14
	mov	ax,2544h
	int	021h
	lea	dx,font8x8
	add	dx,128*8
	mov	ax,251fh
	int	21h
	mov	ax,03
	int	10h
	lea	dx,install
	mov	cl,4
	shr	dx,cl
	add	dx,11h
	mov	ax,3100h
	int	021h

already:
	push	cs
	pop	ds
	lea	dx,loaded
	mov	ax,0900h
	int	021h
	mov	ax,4c01h
	int	021h
	
loaded		db	'EGA Screen driver already loaded ...',0dh,0ah,'$'

Code	ends

	end	Install
	
