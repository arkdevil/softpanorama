;
;	Пример встроенного кода, формирующего ASCII-строку.
;
;   Переводит символ под курсором в верхний регистр, а точнее:
;   берет с экрана символ, переводит в верхний регистр, загоняет
;	в свою строку mystring и передает в KEYMAC.
;

	.model tiny
	.code

	call $+3
where:	pop ax		; ax = реальный адрес where

	add ax, offset mystring - offset where  ; ax = адрес mystring
	mov bx,sp
	mov ss:[bx+4],ax	; возвращаем адрес в KEYMAC

	push	ax
	mov	ah,8	; читать символ под курсором
	mov	bh,0	; чтобы не усложнять, считаем, что страница = 0
	int	10h
	pop	bx	; bx = адрес

	cmp	al,'a'
	jb	nocvt	; no convert, значить
	cmp	al,'z'
	jbe	cvt
	cmp	al,'а'	; рус.
	jb	nocvt
	cmp	al,'п'
	jbe	cvt
	cmp	al,'р'
	jb	nocvt
sub30:	sub	al,30h
cvt:	sub	al,20h
nocvt:	mov	cs:[bx],al
	
	retf

mystring:
	db	0,0

	end
