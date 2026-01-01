CODE	segment

	assume	cs:code

my		db	0
Cyrillic	db	0

Ordtbl		label	byte
	db	32 ,'1','Э','3','4','5','7','э','9','0'
	db	'8','+','б','-','ю','/',')','!','"','#'
	db	'$',':',',','.',';','(','Ж','ж','Б','='
	db	'Ю','?','2','Ф','И','С','В','У','А','П'
	db	'Р','Ш','О','Л','Д','Ь','Т','Щ','З','Й'
	db	'К','Ы','Е','Г','М','Ц','Ч','Н','Я','х'
	db	'\','ъ','6','_','`','ф','и','с','в','у'
	db	'а','п','р','ш','о','л','д','ь','т','щ'
	db	'з','й','к','ы','е','г','м','ц','ч','н'
	db	'я','Х','|','ъ','~',127

Cpstbl		label	byte
	db	32 ,'1','э','3','4','5','7','э','9','0'
	db	'8','+','Б','-','Ю','/',')','!','"','#'
	db	'$',':',',','.',';','(','ж','Ж','б','='
	db	'ю','?','2','Ф','И','С','В','У','А','П'
	db	'Р','Ш','О','Л','Д','Ь','Т','Щ','З','Й'
	db	'К','Ы','Е','Г','М','Ц','Ч','Н','Я','Х'
	db	'\','ъ','6','_','`','ф','и','с','в','у'
	db	'а','п','р','ш','о','л','д','ь','т','щ'
	db	'з','й','к','ы','е','г','м','ц','ч','н'
	db	'я','х','|','ъ','~',127

presence	dw	4376h

Int09	label	byte
	cli
	push	ax
	push	bx
	push	ds
	xor	bx,bx
	mov	ds,bx
	mov	bx,0417h
	mov	ah,[bx]
	pushf
	db	09ah
old9o	dw	0
old9s	dw	0

	cli
	mov	al,[bx]
	and	ax,0404h
	cmp	ax,0004h
	jnz	fut1
	
	mov	cs:my,1
	jmp	bye

fut1:	cmp	ax,0400h
	jnz	fut2
	
	cmp	cs:my,1
	jnz	fut2
	
	not	cs:Cyrillic
fut2:	mov	cs:my,0
bye:	pop	ds
	pop	bx
	pop	ax
	iret
	
Int16	label	byte
	or	ah,ah
	jz	func0
	cmp	ah,01
	jz	func1

	db	0eah
old16	label	dword
old16o	dw	0
old16s	dw	0

func0:
	pushf
	call	cs:[old16]
	cmp	cs:Cyrillic,0
	jz	bye16
	call	translate

bye16:	iret

func1:
	pushf
	call	cs:[old16]
	pushf
	cmp	cs:Cyrillic,0
	jz	by116
	call	translate

by116:
	popf
	retf	2

translate	proc	near
	push	bx
	push	ds
	xor	bx,bx
	mov	ds,bx
	mov	bx,0417h
	test	byte ptr [bx],040h
	jnz	capslock
	lea	bx,Ordtbl
	jmp	dotrans

capslock:
	lea	bx,Cpstbl
dotrans:
	or	ah,ah
	jz	notrans
	cmp	ah,035h
	ja	notrans
	cmp	al,127
	ja	notrans
	cmp	al,' '
	jbe	notrans
	add	bl,al
	adc	bh,0
	sub	bx,32
	mov	al,cs:[bx]
	xor	ah,ah
notrans:
	pop	ds
	pop	bx
	ret
translate	endp

INSTALL:
	mov	ax,3509h
	int	021h
	mov	ax,es:[bx-2]
	cmp	ax,cs:presence
	jz	already
	mov	cs:old9o,bx
	mov	cs:old9s,es
	mov	ax,3516h
	int	021h
	mov	cs:old16o,bx
	mov	cs:old16s,es
	mov	ax,cs
	mov	ds,ax
	cli
	lea	dx,Int09
	mov	ax,2509h
	int	021h
	lea	dx,Int16
	mov	ax,2516h
	int	021h
	sti
	lea	dx,Install
	mov	cl,4
	shr	dx,cl
	add	dx,20
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

loaded	db	'Keyboard driver already loaded ...',0dh,0ah,'$'
CODE	ends
	end	INSTALL

