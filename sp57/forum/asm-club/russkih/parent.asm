CSEG	segment
	assume	cs:CSEG,ds:CSEG
	org	100h
START:
	jmp	BEGIN
	
INT21_VECT	dd	(?)
INT20_VECT	dd	(?)
INT27_VECT	dd	(?)
INT9_VECT	dd	(?)
INT10_VECT	dd	(?)
INT13_VECT	dd	(?)
INT16_VECT	dd	(?)
INT17_VECT	dd	(?)
INT8_VECT	dd	(?)
FIRSTBLOCK	dw	(?)
FLAG		db	 0
PARENT		db	'PARENT'
ID		db	10h,0
COMMAND		db	'COMMAND',0
MSDOS		db	'MSDOS',0
ONE		dw	 0
DOS		db	 0

NEW10_INT:
	call	ISONE
	call	ISHOTKEY
	jmp	cs:[INT10_VECT]
	
NEW13_INT:
	call	ISHOTKEY
	jmp	cs:[INT13_VECT]
	
NEW16_INT:
	call	ISHOTKEY
	pushf
	call	cs:[INT16_VECT]
	
	call	FLAGSINT
	call	ISHOTKEY
	iret
	
NEW17_INT:
	call	ISONE
	call	ISHOTKEY
	pushf
	call	cs:[INT17_VECT]

	call	FLAGSINT
	call	ISHOTKEY
	iret

; процедура проверяет можно ли использовать функции DOS
ISHOTKEY:
	cmp	byte ptr cs:DOS,0
	jne	I1
	call	ISFLAG
I1:
	ret

; ставит флаг входимости при первом обращении после запуска программы
ISONE:
	cmp	cs:ONE,0
	je	Ok50
	push	ax
	push	bx
	push	ds
	
	mov	ds,cs:ONE
	mov	cs:ONE,0	
	
	mov	ah,62h
	int	21h

	mov	word ptr ds:[400h],bx
	
	pop	ds
	pop	bx
	pop	ax
	
	mov	cs:DOS,0
Ok50:
	ret
	
NEW20_INT:
	call	EXIT
	jmp	cs:[INT20_VECT]
	
NEW27_INT:
	call	RESIDENT
	jmp	cs:[INT27_VECT]
	
; освобождает и-БЛОК при резидентном выходе
RESIDENT:
	jmp	EXIT

; проверяет флаг Ctrl-Alt-Esc
ISFLAG:
	cmp	cs:FLAG,0FFh
	jne	Ok30
	mov	cs:FLAG,0
	push	ax
	push	bx
	push	ds
	
; опустошить буффер клавиатуры
	sub	ax,ax
	mov	ds,ax
	mov	bx,ds:[41Ah]
	mov	ds:[41Ch],bx
	
	mov	ah,62h
	int	21h
	call	FINDPSP
	cmp	bx,0
	je	Ok40
; заткнуть динамик
	in	al,61h
	and	al,11111100b
	out	61h,al
; смыть картинку и перейти в нужный видеорежим
	mov	ah,0
	mov	al,ds:[402h]
	int	10h
	mov	ah,5
	mov	al,ds:[403h]
	int	10h
	mov	ah,1
	mov	cx,ds:[404h]
	int	10h
	
	mov	ah,0Dh
	int	21h
	
	call	CLEARMEM

	mov	ax,4C01h
	int	21h
Ok40:
	pop	ds
	pop	bx
	pop	ax
Ok30:
	ret
	
NEW21_INT:
	call	ISONE
	call	ISFLAG
	mov	cs:DOS,0FFh
; пройтись по номерам
	cmp	ah,0
	je	M21_0
	cmp	ah,31h
	je	M21_31
	cmp	ax,4B00h
	je	M21_4B
	cmp	ah,4Ch
	je	M21_0
	cmp	ah,0AFh
	je	M21_AF
	jmp	M21_1
M21_AF:
	push	es
	push	si
	push	di
	push	cx
	
	mov	si,dx
	lea	di,PARENT
	push	cs
	pop	es
	mov	cx,8
	repe	cmpsb
	jcxz	Ok98
	jmp	Ok99
Ok98:
	mov	ax,4C01h
	int	21h
Ok99:
	pop	cx
	pop	di
	pop	si
	pop	es
Ok78:
	jmp	M21_1
M21_4B:
	call	MEM
	jmp	M21_1
M21_0:
	call	EXIT
	jmp	M21_1
M21_31:
	call	RESIDENT
;	jmp	M21_1
M21_1:
	jmp	cs:[INT21_VECT]
	
; вставить в стеке тек. флаги
FLAGSINT:
	push	ax
	push	bp
	
	mov	bp,sp
	pushf
	pop	ax
	mov	[bp+10],ax
	
	pop	bp
	pop	ax
	ret
; заполнить и-БЛОК для запускающейся программы
MEM:
	push	ax
	push	bx
	push	cx
	push	dx
	push	ds
	push	es
	push	si
	push	di
	
	push	cs
	pop	ds
	
; подсчитываем к-во занятых блоков
	sub	bx,bx
	mov	es,FIRSTBLOCK
BLCNT1:
	cmp	word ptr es:[1],0
	je	BLCNT4
	inc	bx
BLCNT4:
	cmp	byte ptr es:[0],'Z'
	je	BLCNT2
BLCNT3:
	mov	cx,es
	add	cx,word ptr es:[3]
	inc	cx
	mov	es,cx
	jmp	BLCNT1
BLCNT2:
	mov	cl,3
	shr	bx,cl
	add	bx,43h
; выделяем память под и-БЛОК
	mov	ah,48h
	int	21h
	jc	Ok1
	dec	ax
	
	mov	es,ax
	lea	si,PARENT
	mov	di,8
	mov	cx,8
	rep	movsb
	
	inc	ax
	mov	es,ax
	sub	si,si
	mov	ds,si
	sub	di,di
	mov	cx,400h
	rep	movsb
	
	mov	ah,15
	int	10h
	mov	es:[402h],al
	mov	es:[403h],bh
	mov	ah,3
	int	10h
	mov	es:[404h],cx
	
	mov	cs:ONE,es
; переписываем сегменты блоков
	mov	bx,410h
	mov	ds,cs:FIRSTBLOCK
SAVBLK1:
	cmp	word ptr ds:[1],0
	je	SAVBLK4
	mov	cx,word ptr ds:[1]
	mov	word ptr es:[bx],cx
	add	bx,2
SAVBLK4:
	cmp	byte ptr ds:[0],'Z'
	je	SAVBLK2
SAVBLK3:
	mov	cx,ds
	add	cx,word ptr ds:[3]
	inc	cx
	mov	ds,cx
	jmp	SAVBLK1
SAVBLK2:
	mov	word ptr es:[bx],0FFFFh
Ok1:
	pop	di
	pop	si
	pop	es
	pop	ds
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	ret
; восстановить все при выходе
EXIT:
	push	ax
	push	bx
	push	ds
	push	es
	
	mov	ah,62h
	int	21h
	call	FINDPSP
	cmp	bx,0
	je	Ok16

	mov	ax,ds
	mov	es,ax
	dec	ax
	mov	ds,ax
	
	mov	word ptr ds:[8],0
	
	mov	ah,49h
	int	21h
Ok16:
	pop	es
	pop	ds
	pop	bx
	pop	ax
	ret

; чистит память
CLEARMEM:	
	push	ax
	push	bx
	push	cx
	push	dx
	push	ds
	push	es
	push	si
	push	di
	
	mov	ah,62h
	int	21h
	call	FINDPSP
	cmp	bx,0
	jne	CLM1
	jmp	CLM2
CLM1:
	mov	ax,ds
	dec	ax
	mov	es,ax
	mov	word ptr es:[8],0
	
	sub	si,si
	sub	di,di
	mov	es,di
	mov	cx,400h
	rep	movsb
; почистить память
	mov	es,cs:FIRSTBLOCK
TRASH1:
	push	ds
	
	push	cs
	pop	ds
	lea	si,COMMAND
	mov	di,8
	mov	cx,8
	repe	cmpsb
	jcxz	TRASH3
TRASH2:
	lea	si,MSDOS
	mov	di,8
	mov	cx,6
	repe	cmpsb
	jcxz	TRASH3
TRASH4:
	pop	ds
	mov	bx,410h
TRASH6:
	mov	cx,word ptr ds:[bx]
	cmp	word ptr es:[1],cx
	je	TRASH5
	add	bx,2
	cmp	word ptr ds:[bx],0FFFFh
	jne	TRASH6
	mov	word ptr es:[1],0
	mov	word ptr es:[8],0
	jmp	TRASH5
TRASH3:
	pop	ds
TRASH5:
	cmp	byte ptr es:[0],'Z'
	je	TRASH7
	
	mov	cx,es
	add	cx,word ptr es:[3]
	inc	cx
	mov	es,cx
	jmp	TRASH1
TRASH7:
	push	ds
	pop	es
	mov	ah,49h
	int	21h
CLM2:
	pop	di
	pop	si
	pop	es
	pop	ds
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	ret
	
; ищет нужный и-БЛОК
FINDPSP:
	push	es
	push	cx
	push	si
	push	di
	
	mov	es,cs:FIRSTBLOCK
F2:
	mov	di,8
	push	cs
	pop	ds
	lea	si,PARENT
	mov	cx,8
	repe	cmpsb
	jcxz	F1
F3:
	cmp	byte ptr es:[0],'Z'
	je	NOF
	
	mov	cx,es
	add	cx,word ptr es:[3]
	inc	cx
	mov	es,cx
	jmp	F2
F1:
	cmp	word ptr es:[410h],bx
	jne	F3
	mov	bx,es
	inc	bx
	mov	ds,bx
	jmp	F4
NOF:
	sub	bx,bx
	mov	ds,bx
F4:
	pop	di	
	pop	si
	pop	cx
	pop	es
	ret
	
NEW9_INT:
	push	ax
	in	al,60h
	cmp	al,1
	je	POP_KEY
Ok10:
	pop	ax
	jmp	cs:[INT9_VECT]
POP_KEY:
	push	es
	sub	ax,ax
	mov	es,ax
	mov	ah,es:[417h]
	and	ah,1100b
	cmp	ah,1100b
	je	Ok11
	pop	es
	jmp	Ok10
Ok11:
	in	al,61h
	mov	ah,al
	or	al,80h
	out	61h,al
	xchg	ah,al
	out	61h,al
	
	mov	al,20h
	out	20h,al
	
	mov	cs:FLAG,0FFh
	
	mov	al,0B6h
	out	43h,al
	mov	al,80h
	out	42h,al
	mov	al,3
	out	42h,al
	
	in	al,61h
	mov	ah,al
	or	al,3
	out	61h,al
	
	push	cx
	mov	cx,6000
WAIT_L:	loop	WAIT_L
	pop	cx
	
	mov	al,ah
	out	61h,al
; вставить Enter
	push	bx
	mov	bx,es:[41Ch]
	add	word ptr es:[41Ch],2
	cmp	word ptr es:[41Ch],3Eh
	jne	Ok90
	mov	word ptr es:[41Ch],1Eh
Ok90:
	add	bx,400h
	mov	word ptr es:[bx],1C0Dh
	pop	bx
	
	pop	es
	pop	ax
	
	iret

NEW8_INT:
	pushf
	call	cs:[INT8_VECT]
	
	push	ax
	push	cx
	push	bp
	
	mov	bp,sp
	mov	ax,[bp+6]
	mov	cl,4
	shr	ax,cl
	add	ax,[bp+8]
	
	mov	cs:DOS,0FFh
	cmp	ax,cs:FIRSTBLOCK
	jb	INDOS
	mov	cs:DOS,0
INDOS:
	pop	bp
	pop	cx
	pop	ax
	iret
	
BEGIN:		; 402 bytes !!!

	mov	ax,60h
	mov	ds,ax
Ok101:
	mov	ax,ds
	inc	ax
	mov	ds,ax
	
	cmp	byte ptr ds:[0],'M'
	jne	Ok101
	mov	byte ptr ds:[0],0
	mov	ah,48h
	xor	bx,bx
	int	21h
	mov	byte ptr ds:[0],'M'
	jc	FOUND
	mov	es,ax
	mov	ah,49h
	int	21h
	jmp	Ok101
FOUND:
	mov	cs:FIRSTBLOCK,ds
	push	cs
	pop	ds
	
	mov	ah,0AFh
	lea	dx,PARENT
	int	21h
	
	push	cs
	pop	es
	mov	ds,cs:FIRSTBLOCK
FF1:
	cmp	byte ptr ds:[0],'Z'
	je	FF2
	lea	di,PARENT
	mov	si,8
	mov	cx,8
	repe	cmpsb
	jcxz	FF3
FF4:
	mov	ax,ds
	add	ax,word ptr ds:[3]
	inc	ax
	mov	ds,ax
	jmp	FF1
FF3:
	mov	word ptr ds:[1],0
	mov	word ptr ds:[8],0
	jmp	FF4
FF2:
	push	cs
	pop	ds
	
	push	word ptr ds:[2Ch]
	pop	es
	mov	ah,49h
	int	21h

	mov	ax,3521h
	int	21h
	push	es
	push	bx
	pop	dword ptr INT21_VECT
	mov	ax,2521h
	lea	dx,NEW21_INT
	int	21h
	
	mov	ax,3509h
	int	21h
	push	es
	push	bx
	pop	dword ptr INT9_VECT
	mov	ax,2509h
	lea	dx,NEW9_INT
	int	21h

	mov	ax,3520h
	int	21h
	push	es
	push	bx
	pop	dword ptr INT20_VECT
	mov	ax,2520h
	lea	dx,NEW20_INT
	int	21h
	
	mov	ax,3527h
	int	21h
	push	es
	push	bx
	pop	dword ptr INT27_VECT
	mov	ax,2527h
	lea	dx,NEW27_INT
	int	21h

	mov	ax,3510h
	int	21h
	push	es
	push	bx
	pop	dword ptr INT10_VECT
	mov	ax,2510h
	lea	dx,NEW10_INT
	int	21h

	mov	ax,3513h
	int	21h
	push	es
	push	bx
	pop	dword ptr INT13_VECT
	mov	ax,2513h
	lea	dx,NEW13_INT
	int	21h
	
	mov	ax,3516h
	int	21h
	push	es
	push	bx
	pop	dword ptr INT16_VECT
	mov	ax,2516h
	lea	dx,NEW16_INT
	int	21h
	
	mov	ax,3517h
	int	21h
	push	es
	push	bx
	pop	dword ptr INT17_VECT
	mov	ax,2517h
	lea	dx,NEW17_INT
	int	21h
	
	mov	ax,3508h
	int	21h
	push	es
	push	bx
	pop	dword ptr INT8_VECT
	mov	ax,2508h
	lea	dx,NEW8_INT
	int	21h
	
	lea	bx,Copyright
	mov	cx,44
LB1:
	mov	al,[bx]
	xor	al,80h
	mov	[bx],al
	inc	bx
	loop	LB1
	
	mov	ah,9
	lea	dx,Copyright
	int	21h
	
	mov	ax,3100h
	mov	dx,78
	int	21h
	
Copyright	db	'P'+80h,'a'+80h,'r'+80h,'e'+80h
		db	'n'+80h,'t'+80h,' '+80h,'R'+80h
		db	'e'+80h,'t'+80h,'u'+80h,'r'+80h
		db	'n'+80h,'e'+80h,'r'+80h,'.'+80h
		db	' '+80h,'1'+80h,'9'+80h,'9'+80h
		db	'3'+80h,' '+80h,'('+80h,'R'+80h
		db	')'+80h,' '+80h,'V'+80h,'a'+80h
		db	's'+80h,'i'+80h,'l'+80h,'y'+80h
		db	' '+80h,'R'+80h,'u'+80h,'s'+80h
		db	's'+80h,'k'+80h,'i'+80h,'k'+80h
		db	'h'+80h,'.'+80h,0Dh+80h,0Ah+80h,'$'	; 44
CSEG	ends
	end	START
