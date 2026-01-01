;┌────────────────────────────────────────────╖
;│  Беляев Сергей Владимирович                ║ ░░░░░░░░░░░░░░░░░░░░░░
;│                                            ║ ░░░░░░░░░░░░░░░░░░░░░░
;│  Российская Федерация ,603074,             ║ ░░░░░░░░░░░░░░░░░░░░░░
;│  Нижний Новгород, ул.Народная,38-462.      ║ ░░░░░░░░ <SVB> ░░░░░░░
;│  Тел.  43-26-18 (дом).                     ║ ░░░░░░░░░░░░░░░░░░░░░░
;╘════════════════════════════════════════════╝ ░░░░░░░░░░░░░░░░░░░░░░
;   ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

;<SVB> 26.10.90
;программа работает совместно с программой
;ECR_ARC.COM и пpедназначена для создания COM-файлов
;из файлов каpтинок, котоpые должны быть пpиделаны
;к хвосту этой маленькой пpогpаммы

code	segment byte public
	assume	cs:code,ds:code
	org	100h
strt:
	mov	ax,cs
	mov	ds,ax
	mov	es,ax
	mov	ax,0010h
	int	10h
	mov	dx,offset pal
	mov	ax,1002h
	int	10h

	mov	si,offset pal+39
	mov	ax,0A000h
	mov	es,ax
	mov	dx,003CEh
	mov	al,8
	out	dx,al	
	mov	al,0FFh
	inc	dx
	out	dx,al	
	mov	dx,003CEh
	mov	al,5
	out	dx,al	
	mov	al,0
	inc	dx
	out	dx,al	
	mov	dx,003CEh
	mov	al,3
	out	dx,al	
	inc	dx
	mov	al,0
	out	dx,al	
	mov	cl,3
	cld
cikl1:
	mov	di,0
	mov	dx,003C4h
	mov	al,2
	mov	ah,1
	shl	ah,cl
	out	dx,al	
	mov	al,ah
	inc	dx
	out	dx,al
;----------------------------^ предварирительная подготовка
c1:	cmp	ah,0
	jz	de
	cmp	ah,0FFh
	jnz	nor
de:	dec	ch
	jnz	write
nor:	lodsb
	mov	ah,al
	cmp	ah,0
	jz	ca
	cmp	ah,0FFh
	jnz	write
ca:	lodsb
	mov	ch,al
	mov	al,ah
write:	stosb
	cmp	di,28000
	jnz	c1
d1:	dec	cl
	jnl	cikl1
	push	cs
	pop	es
	mov	dx,offset pal+17
	mov	ax,1002h
	int	10h		
bye:
	mov	ah,8
	int	21h			;ввод символа
	mov	ax,3
	int	10h			;текстовый pежим
	mov	ah,4Ch
	int	21h

pal	db	17 dup(0)

code	ends
end	strt
