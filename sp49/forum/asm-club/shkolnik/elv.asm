	org	100h

;	The VGA identification

	mov	ax,1a00h
	int	10h
	cmp	al,1ah
	je	eli
	mov	dx,offset mese
	mov	ah,9
	int	21h
	ret

;	The extra line installation

eli:	mov	ax,1212h
	mov	dx,3d4h
	out	dx,al
	inc	dx
	in	al,dx
        add     al,10h
	xchg	al,ah
	dec	dx
	out	dx,ax
 	add	ah,6
	mov	al,10h
	out	dx,ax
	mov	al,15h
	out	dx,ax

;	The demo string output

	xor	di,di
	mov	es,di
	mov	di,word ptr es:[44eh]
	mov	ax,word ptr es:[44ah]
	push	ax
 	mov	cl,es:[484h]
	inc	cl
  	mul	cl
	rol	ax,1
        add     di,ax
	mov	cx,0b800h
	mov	es,cx
	mov	cx,cs
	mov	si,offset mesw
	pop	cx
	mov	ah,4eh
	cld
av:	xor	al,al
	cmp	si,offset mese
	jae	vv
	lodsb
vv:     stosw
	loop	av
	ret

mesw	db	'This is an extra line on VGA. Yu.A.Shkolnikov. Kiev. 1992. '
	db	'Phone (044)411-41-26.'
mese 	db      0dh,0ah,'Designed only for VGA.',0dh,0ah,'$'
