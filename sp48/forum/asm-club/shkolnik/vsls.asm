	org	100h
    	mov	dx,offset mes0
        call    avi
	mov	ax,cs
	mov	es,ax
	mov	di,81h
	mov	ch,0
	mov	cl,[80h]
	mov	al,20h
	cld
	repne	scasb
	jne	ams
	xor	ch,ch
	repe	scasb
	je  	ams
	mov	al,es:di[-1]
	cmp	al,'0'
	jae	vsl
	jmp	ams
vsl:	cmp	al,'3'
	ja	ams
	sub	al,'0'
	mov	ah,3
	int	10h
	push	bx
	push	cx
	push	dx
	mov	ah,12h
	mov	bl,30h
        int	10h
	mov	ax,83h
	int	10h
	pop	dx
	pop	cx
	pop	bx
	xor	ax,ax
	mov	es,ax
 	cmp	dh,es:[484h]
 	jbe	cps
 	mov	dh,es:[484h]
cps:    mov     ah,2
	int	10h
;	dec	ah
;	int	10h
	ret

ams:	mov	dx,offset mes1
avi:	mov	ah,9
    	int	21h
	ret

mes0	db	'VGA scan lines selector.',0dh,0ah
	db	'Yu.A.Shkolnikov, Kiev, 1992, (044) 411-41-26.',0dh,0ah,0ah,'$'
mes1	db	'Usage:  vsls <n>  , where <n> is',0dh,0ah
	db	'        0 - 200 scan lines  ( 25 x  8 x 8 ) ,',0dh,0ah
	db	'        1 - 350 scan lines  ( 25 x 14 x 8 ) ,',0dh,0ah
	db	'        2 - 400 scan lines  ( 25 x 16 x 8 ) ,',0dh,0ah
	db	'        3 - 480 scan lines  ( 30 x 16 x 8 ) .',0dh,0ah,'$'
