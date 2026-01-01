	org	100h
	jmp	gma

nn10:	cmp	ah,10h
	jge	gup
        cmp     ah,0
	jne	pup
gup:	push	ds
	push	cs
	pop	ds
	push	dx
	push	ax
	push	si
	lea	si,gagl
	call	toh
	mov	ax,bx
	call	toh
	mov	ax,cx
	call	toh
	mov	ax,dx
	call	toh
	mov	ax,es
	call	toh
	mov	ax,bp
	call	toh
	lea	dx,gagr
	mov	ah,9
	int	21h
	mov	ah,0
	int	16h
	pop	si
	pop	ax
	pop	dx
	pop	ds
pup:	jmp	dword ptr cs:oo10

toh	proc	near
	push	ax
	mov	al,ah
	call	tob
	pop	ax
	call	tob
	ret
toh     endp

tob     proc    near
	mov	ah,al
	and	ah,00001111b
	and	al,11110000b
	push	cx
	mov	cl,4
        ror     al,cl
	pop	cx
	call	pcp
	mov	al,ah
        call    pcp
	inc	si
	ret
tob	endp

pcp	proc	near
	cmp	al,9
	jg	ia
	add	al,30h
	jmp	vyv
ia:	add	al,55
vyv:	mov	cs:[si],al
	inc	si
        ret
pcp	endp

oo10    dw      ?,?
gagr	db	'AH AL BH BL CH CL DH DL {E S} {B P}',0DH,0AH
gagl    db      40 dup(20h),0dh,0ah
gaga	db	'Subfunction of 10h int is used.Press a key.',0dh,0ah,'$'
gagi	db	'10h int is cached.',0dh,0ah,'$'
gma:    mov     ax,3510h
	int	21h
        mov     cs:oo10,bx
	mov	bx,es
	mov	cs:oo10[2],bx
	lea	dx,nn10
	mov	ah,25h
	int	21h
	lea	dx,gagi
	mov	ah,9
	int	21h
	int	27h
