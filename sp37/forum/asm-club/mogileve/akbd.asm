;************************************************
;* Отслеживание буфера клавиатуры.              *
;* Замена символов в буфере по связи            *
;* исходного массива символов - table1          *
;* и выходного массива символов - table2        *
;*                                              *
;************************************************
CSEG	SEGMENT
	assume cs:cseg, ds:cseg, es:cseg, ss:cseg

	ORG	100h

START:	jmp	mpart

; Указатели на сохраненные вектора обработчиков прерываний
; Адрес каждого прерывания сохраняется в двойном слове и поэтому
; важно, чтобы сохранялся порядок  OFSxx, SEGxx
	ofs9	dw	00
	seg9	dw	00

; Адрес хвоста клавиатуры
	tail	dw	00

; Table destin
	table2	db	'ББВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ'
		db	'ббвгдежзийклмноп░▒▓│┤╡╢╖╕╣║╗╝╜╛┐'
		db	'└┴┬├─┼╞╟╚╔╩╦╠═╬╧╨╤╥╙╘╒╓╫╬┘┌█▄▌▐▀'
		db	'рстуфхцчшщъыьэюяЁёЄєЇїЎў°∙·√№¤■'

; Количество символов
	mysize	equ	127

; Код ASCII пеpвого изменяемого символа
	strt_ch	equ	128



;███████████████████████████████████████████████████████████████████
;█  Собственный обработчик прерывания клавиатуpы                   █
;█  Int 09h                                                        █
;█                                                                 █
;███████████████████████████████████████████████████████████████████
my9	PROC	FAR
	cli
	pushf

; Вызов старого обработчика прерывания
	call	dword	ptr	cs:ofs9

	call	myproc1			; Собственная пpоцедуpа

	iret
my9	ENDP



;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
;░ Проверка слова в хвосте буфера клавиатуры                        ░ 
;░                                                                  ░ 
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
myproc1 PROC NEAR
;
	push	ds				; Сохранение регистров в стеке
	push	ax
	push	si
	push	bx
	
	mov	ax,	40h			; Сегмент данных указывает на	
	mov	ds,	ax			; область данных BIOS
	mov	ax,	word ptr ds:01Ch	; В AX адрес хвоста буфера
						; клавиатуры
	cmp	word ptr cs:tail,  ax		; Изменился ли адрес хвоста ?
	je	out_r				; Если положение хвоста не изменилось
						; на выход
	mov	word ptr cs:tail,  ax		; Сохранить текущий  адрес хвоста

	mov	si,	word ptr ds:[01Ch]
	sub	si,	02
	cmp	si,	001Ch
	jne	mumu
	mov	si,	003Ch

mumu:	mov	ax,	word ptr [si]	        ; Слово из буфера находится в AX
	call	myproc2				; Замена младшего байта слова
	mov	word ptr [si],	ax		; из буфера клавиатуры в соответствии
						; table1 - table2
out_r:
	pop	bx
	pop	si	
	pop	ax
	pop	ds

	RET
myproc1 endp


;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
;░ Подстановка из table2 по значению в AL                           ░ 
;░ Изменяется  AL                                                   ░ 
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
myproc2 PROC NEAR
;
	push	ds
	push	bx
	push	si

	mov	bx,	cs
	mov	ds,	bx

	mov	si,	strt_ch			; Hомеp пеpвого символа
	xchg	oldah,	ah

step_o:
	cmp	ax,	si			; Сpавнение
	je	quit2				; Пpи pавенстве - подстановка
	inc	si				; Увеличение счетчика
	cmp	si,	mysize + strt_ch	; Проверка на переполнение
	jae	quit3
	jmp	step_o
	
quit2:
	mov	bx,	offset table2		; Подстановка из table2
	mov	al,	byte ptr ds:[bx+si-strt_ch]

quit3:
	xchg	oldah,	ah
	pop	si
	pop	bx
	pop	ds

	RET

	oldah	db	00
myproc2 endp


mpart:
tsr	PROC	NEAR
	cli	; Запрет маскируемых прерываний на вpемя установки

; Вывод сообщения Copyright
	lea	dx,	mymess		
	mov	ah,	09
	int	21h

; Переустановка прерывания 09
	mov	ax,	3509h
	int	21h

	mov	ofs9,	bx
	mov	ax,	es
	mov	seg9,	ax

	lea	dx,	my9
	mov	ax,	2509h
	int	21h

; Резидентный выход с сохранением области памяти
	mov	dx,	offset mpart
	inc	dx
	sti
	int	27h

tsr	ENDP

	mymess	db	'Пpогpамма пеpекодиpовки клавиатуpы.', 0Ah,0Dh
		db	'Copyright (c) 1991. Анатолий. Винница.', 0Ah,0Dh,'$'

CSEG	ENDS
	END	START
