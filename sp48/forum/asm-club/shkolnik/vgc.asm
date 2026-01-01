	org	100h
 	xor	ax,ax
 	mov	es,ax
 	mov	al,es:[485h]
 	cmp	al,16
 	je 	to8
 	mov	es:[485h],10h
  	mov	dx,3d4h
 	mov	ax,0f09h
 	out	dx,ax
	xor	ah,ah
	mov	al,es:[484h]
	inc	ax
	ror	ax,1
	dec	ax
	mov	es:[484h],al
 	mov	al,14h
 	jmp	ivi
to8:	cmp	al,16
	jne	vih
	mov	al,12h
ivi:	mov	ah,11h
	xor	bl,bl
	int	10h
vih:	ret

vpo:    dw      0ea10h
        dw      0df12h
dpo:
