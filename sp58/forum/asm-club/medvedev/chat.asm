;------------------------------------------------------------------
; Автор: А.В.Медведев.
; 220090, Республика Беларусь, Минск, ул.Широкая, 36, к.716а
; т. 64-51-52 (раб.)
;
; Простая резидентная программа для изменения цветов экрана.
; На некоторых "черно-белых" мониторах многие сочетания цветов
; неразличимы (например, на серо-зеленых мониторах "Искра-1030").
; При нажатии клавиш <Правый Shift> + <CapsLock> программа изменяет
; цвета, пытаясь сохранить выделенные символы.
; Программа была написана для машины "Искра-1030", чтобы можно было
; нормально работать с PcTools. (На клавиатуре "Искры" указанные
; клавиши расположены рядом; программа работает и с расширенной
; клавиатурой IBM.)
; Программа работает с активной страницей экрана в текстовых режимах.
; Для уменьшения занимаемой памяти программа перемещает резидентную
; часть кода в младшие адреса.
; Занимает в памяти 224 байта. Можно загружать в UMB.
;
; Для получения выполнимого файла:
;	TASM chat
;	TLINK /x/t chat
;------------------------------------------------------------------

MODEL	TINY
CODESEG
ORG	100h

START:
	jmp	short Install

My_10:	cmp	ax,0ae35h
	jne	Old_10
	dec	ax
	xchg	ah,al
	dec	ax
	iret

Old_10: db      0eah            ;jmp far
ip10	dw	0
cs10	dw	0

My_9:	push	ax
	in	al,60h
	cmp	al,3ah
	jne	Old_9
	push	ds
	xor	ax,ax
	mov	ds,ax
        test    byte ptr DS:[417h],1
	jnz	Ok_Change
	pop	ds
Old_9:	pop	ax
	db	0eah		;jmp far
ip9	dw	0
cs9	dw	0

Ok_Change:
	push	bx
	push	cx
	push	si
	push	di
	push	es
	in	al,61h
	mov	ah,al
	or	al,80h
	out	61h,al
	mov	al,ah
	out	61h,al
	mov	al,20h
	out	20h,al
	sti
	mov	bx,0b800h
        mov     al,DS:[449h]
	cmp	al,3
	jbe	a1
	cmp	al,7
	jne	Ex1
	mov	bh,0b0h
a1:
	mov	es,bx
	mov	si,DS:[44eh]
	mov	di,si
	mov	cx,DS:[44ch]
	shr	cx,1
	mov	ds,bx

a2:	inc	si
	inc	di
        lodsb
	test	al,01110000b
	jz	a4
	test	al,00000111b
	jz	a4
	and	al,10001111b
a4:	stosb
	loop	a2

	pop	es
	pop	di
	pop	si
	pop	cx
Ex1:	pop	bx
	pop	ds
	pop	ax
	iret

delta	EQU	(offset My_10) - 5Ch

Install:
	mov	ah,9
	mov	dx,offset Msg0
	int	21h
	mov	ax,0ae35h
	int	10h
	cmp	ax,34adh
	je	Already

	mov	di,5Ch
	mov	si,offset My_10
	mov	cx,( offset Install - offset My_10 + 1 ) / 2
	cld
	rep movsw

	mov	es,DS:[2Ch]
	mov	ah,49h
	int	21h

	xor	ax,ax
	mov	es,ax
	mov	ax,es:[9*4]
	mov	DS:[ip9 - delta], ax
	mov	ax,es:[9*4+2]
	mov	DS:[cs9 - delta], ax
	mov	ax,ES:[10h*4]
	mov	DS:[ip10 - delta], ax
	mov	ax,ES:[10h*4+2]
	mov	DS:[cs10 - delta], ax
	cli
	mov	word ptr es:[9*4],offset My_9 - delta
	mov	es:[9*4+2],cs
	mov	word ptr es:[10h*4],offset My_10 - delta
	mov	es:[10h*4+2],cs
	sti
	mov	ah,9
	mov	dx,offset Msg2
	int	21h
	mov	dx,Offset Install - delta
	int	27h

Already:
	mov	ah,9
	mov	dx,offset Msg1
	int	21h
	int	20h

Msg0    db 13,10,'Change screen attribute program.',13,10
	db 'Copyright (C) 1990 by Andrey V.Medvedev.',13,10,13,10

; Below is a russian text in alternate table.

	db 'Программа изменения атрибутов экрана$'
Msg1	db ' уже'
Msg2	db ' загружена.',13,10
	db 'Для изменения атрибутов нажмите [прав.Shift+CapsLock]',13,10
	db '------ Сначала нажмите Shift, затем CapsLock ! ------',13,10,'$'

; Below is a russian text in main (new) table.

;	db '┐р▐╙р╨▄▄╨ ╪╫▄╒▌╒▌╪я ╨тр╪╤ут▐╥ э┌р╨▌╨$'
;Msg1	db ' у╓╒'
;Msg2	db ' ╫╨╙ру╓╒▌╨.',13,10
;	db '┤█я ╪╫▄╒▌╒▌╪я ╨тр╪╤ут▐╥ ▌╨╓▄╪т╒ [▀р╨╥.°+CapsLock]',13,10
;	db '------ ┴▌╨ч╨█╨ ▌╨╓▄╪т╒ °, ╫╨т╒▄ CapsLock ! ------',13,10,'$'

END	START
