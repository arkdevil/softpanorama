; Этот файл был использован для написания EGA2COM.PAS
cseg	segment
	assume	cs:cseg,ds:cseg
	org	100h	
start:	push	ds
	mov	ax,0
	push	ax
	mov	dx,ds
	jmp	begin

head	db	69	
table	db	63,54,45,44,27,18,25,56,7,46,13,36,35,16,1,0

			
begin:	
	cld
	lea	si,table
	mov	cx,15
bloop:
	mov	bl,cl
	lodsb
	mov	bh,al
	mov	al,0
	mov	ah,10h
	int	10h
	loop	bloop
	
	mov	bl,0
	lodsb
	mov	bh,al
	mov	al,0
	mov	ah,10h
	int	10h
		
	retf
	ends	cseg
	
	END	start
