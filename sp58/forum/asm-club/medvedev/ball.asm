;------------------------------------------------------------------
; Автор: А.В.Медведев.
; 220090, Республика Беларусь, Минск, ул.Широкая, 36, к.716а
; т. 64-51-52 (раб.)
;
; Простая развлекательная программка - по экрану летает 6 
; разноцветных мячиков, скорость практически не зависит от 
; быстродействия машины (перемещение происходит с каждым "тиком"
; системных часов). Выход - по любой клавише.
;
; Для получения выполнимого файла:
;	TASM ball
;	TLINK /x/t ball
;------------------------------------------------------------------

.MODEL	TINY
CODESEG
ORG	100h

COUNT	EQU	6

START:
	jmp	Install

Video	DW	0B800h
maxCol	DB	78
maxRow	DB	23
col	DB	7, 16, 32, 48, 64, 40
row	DB	5, 5, 10, 15, 20, 13
delta_x	DB	-1, -2,  2, -1,  3, -2
delta_y	DB	2,  1, -2, -2,  2, -1
color	DB	10, 11, 12, 13, 14, 15
char	DW	6 dup ( 0 )

PROC	Int_8
	pushf
	DB	9Ah		; call far
ip_8	DW	0
CS_8	DW	0

	sti

	push	ax
	push	bx
	push	si
	push	bp
	push	DS
	push	ES

	push	CS
	pop	DS

	xor	ax,ax
	mov	ES,ax
	mov	bp,ES:[44Eh]
	mov	ES,Video
	mov	bx,COUNT-1

@@next_ball:
	call	calcAddr
	shl	bx,1
	mov	ax,char[bx]
	shr	bx,1
	mov	ES:[bp][si],ax
@@move:
	mov	al,col[bx]
	cmp	al,maxCol
	jb	@@_1
	neg	delta_x[bx]
	jmp	short @@_2
@@_1:
	or	al,al
	jnz	@@_2
	neg	delta_x[bx]
@@_2:
	add	al,delta_x[bx]
	mov	col[bx],al

   	mov	al,row[bx]
	cmp	al,maxRow
	jb	@@_3
	neg	delta_y[bx]
	jmp	short @@_4
@@_3:
	or	al,al
	jnz	@@_4
	neg	delta_y[bx]
@@_4:
	add	al,delta_y[bx]
	mov	row[bx],al

	call	calcAddr
	mov	ax,ES:[bp+si]
	cmp	al,7
	jne	@@show
	neg	delta_x
	neg	delta_y
	jmp	@@move
@@show:
	shl	bx,1
	mov	char[bx],ax
	shr	bx,1
	mov	al,7
	mov	ah,color[bx]
	mov	ES:[bp+si],ax

	dec	bx
	jns	@@next_ball

	pop	ES
	pop	DS
	pop	bp
	pop	si
	pop	bx
	pop	ax
	iret
ENDP

PROC	calcAddr
	mov	al,row[bx]
	cbw
	shl	ax,1
	shl	ax,1
	shl	ax,1
	shl	ax,1
	mov	si,ax
	shl	ax,1
	shl	ax,1
	add	si,ax
	mov	al,col[bx]
	cbw
	add	si,ax
	shl	si,1
	ret
ENDP

msg	DB	'Мячики. Copyright (c) 1993 by Andrey Vl.Medvedev.', 13, 10
	DB	'Для окончания нажмите любую клавишу.', 13, 10, '$'

Install:
	mov	ah,9
	mov	dx,offset msg
	int	21h
	mov	ah,0FH
	int	10h
	cmp	al,7
	jne	@@color
	mov	BYTE PTR Video+1,0B0h
@@color:
	xor	ax,ax
	mov	ES,ax
	mov	ax,ES:[32]
	mov	ip_8,ax
	mov	ax,ES:[34]
	mov	CS_8,ax
	cli
	mov	ES:[32],offset Int_8
	mov	ES:[34],CS
	sti
; нерезидентная версия ---------------------

	mov	bp,ES:[44Eh]
	mov	ES,Video
	mov	bx,COUNT-1
@@init_next:
	call	calcAddr
	mov	ax,ES:[bp+si]
	shl	bx,1
	mov	char[bx],ax
	shr	bx,1
	dec	bx
	jns	@@init_next

@@wait:			; ждать нажатия клавиши
	mov	ah,1
	int	16h
	jz	@@wait
	xor	ax,ax
	int	16h

	xor	ax,ax
	mov	DS,ax
	cli
	mov	ax,CS:ip_8
	mov	DS:[32],ax
	mov	ax,CS:CS_8
	mov	DS:[34],ax
	sti

	push	CS
	pop	DS
	mov	bx,COUNT-1
@@restore:
	call	calcAddr
	shl	bx,1
	mov	ax,char[bx]
	shr	bx,1
	mov	ES:[bp+si],ax
	dec	bx
	jns	@@restore

; конец ------------------------------------

	mov	dx,offset Install
	int	20h

END	START
