;  	*****************************************
;	* 	(C) Copyright 1989 Kiev 	*
;	*	    by Forsyuck V.		*
;	*****************************************
start   proc far
;
	mov	ax,3521h
	int	21h
	mov	word ptr cs:Off21,bx
	mov	word ptr cs:Seg21,es
	mov	ax,2521h
	push	cs
	pop	ds
	mov	dx,Offset myint
	int	21h
	mov	ah,31h
	mov	dx,210h
	mov	cl,4
	shr	dx,cl
	add	dx,10h
	int	21h
;
myint:	cmp	ah,43h
	je	Alarm
jmp21:	db	0EAh	;1 байт команды jmp
Off21:	dw	0
Seg21:	dw	0
Alarm:	push	ax
	push	bx
	push	cx
	push	dx
	push	ds
	push	es
;
        push    cs
	pop	ds
	mov	dx,Offset Alarmmes
	mov	ax,0900h
	int	21h
	mov	ah,08h
	int	21h
	cmp	al,2ah
	pop	es
	pop	ds
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	je	jmp21
	iret
Alarmmes db	'  Access denied !',13,10,'$'
;
start	endp
	 end	start
 