        org     100h
    	jmp	bgn

vpo0:   dw      00c11h
        dw      00b06h
        dw      03e07h
        dw      00f09h
        dw      0ea10h
        dw      0df12h
        dw      0e715h
 	dw	00016h

vpo8:   dw      0ea10h
        dw      0df12h

o10:	dw	?,?
btm 	db	0,'Vgr30'
ral	db	?

n10:	cmp	ah,12h
	jne	meo
    	cmp	bl,30h
	jne	mer
    	cmp	al,3
	je 	ie3
	jg	mer
	and	cs:[btm],11111110b
mer:	jmp	dword ptr cs:o10
ie3:    push	dx
	push	ax
	mov	dx,3d4h
	mov	al,7
	out	dx,al
	inc	dx
	in	al,dx
	test	al,10b
        jz      svs
	dec	dx
	mov	al,12h
	out	dx,al
	inc	dx
	in	al,dx
	cmp	al,0dfh
	jb	svs
nsv:	pop	ax
	pop	dx
	or	cs:[btm],1
	mov	al,ah
	iret
svs:	mov	ax,1202h
	call	phr
	jmp	nsv
meo:    test	cs:[btm],1
        jz	mer
	cmp	ax,1114h
	je 	vgp
met:	cmp	ax,1112h
	jne	mez
	call	phr
	push	ds
	push	ax
	push	dx
	mov	dx,3d4h
	mov	ax,word ptr cs:[vpo8]
	out	dx,ax
	mov	ax,word ptr cs:[vpo8+2]
	out	dx,ax
 	mov	byte ptr cs:[ssq-1],59
	jmp	avg
mez:    or      ah,ah
        jnz	mer
	mov	cs:[ral],al
	and	cs:[ral],7fh
	cmp	cs:[ral],3
	ja	mer
vgp:	call	phr
	push	ds
	push	ax
	push	dx
	mov	ax,cs
	mov	ds,ax
        mov     dx,3c2h
;       mov     al,00100111b
        mov     al,11100111b
        out     dx,al
        mov     dl,0d4h
	push	cx
        mov     cx,8
	cld
	mov	si,offset vpo0
lp:     lodsw
        out     dx,ax
        loop    lp
    	pop	cx
avg:	pop	dx
        xor     ax,ax
        mov     ds,ax
        mov     byte ptr [484h],29
ssq: 	mov	byte ptr cs:[ssq-1],29
    	and	byte ptr [487h],11111110b
	pop	ax
	pop	ds
        iret

phr:	pushf
	call	dword ptr cs:o10
	ret

mes	db	'Vgr30 resident compatible program for 30 lines on '
	db	'VGA is installed.',0dh,0ah
	db	'Yu.A.Shkolnikov after D.A.Gurtjak. Kiev, 1992.',0dh,0ah,'$'

mes2	db	'Vgr30 is already installed.',0dh,0ah,'$'

mes3	db	'Requires VGA only.',0dh,0ah,'$'

bgn:    mov	ax,1a00h
	int	10h
	cmp	al,1ah
	je	inid
	mov	dx,offset mes3
	jmp	avi
inid:	mov	ax,3510h
	int	21h
	cld
	mov	cx,5
	mov	di,bx
	sub	di,6
	mov	si,offset mes
	repe 	cmpsb
	or	cx,cx
	jnz	aini
	mov	dx,offset mes2
avi:	mov	ah,9
	int	21h
	ret

aini:	mov	word ptr cs:o10,bx
     	mov	word ptr cs:o10[2],es
	mov	cs:[btm],0
	mov	ax,2510h
	mov	dx,offset n10
	int	21h
	mov	dx,offset mes
	mov	ah,9
	int	21h
	int	27h
