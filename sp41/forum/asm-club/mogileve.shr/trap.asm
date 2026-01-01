;██████████████████████████████████████████████████████████████
;█                                                            █
;█ Программа воспроизводит нажатия клавиатуры                 █
;█ из дискового файла со стандартным именем                   █
;█                                                            █
;█ Возможность задания имени файла, в котором записаны        █
;█ нажатия. Выделение области памяти по размеру файла.        █
;█                                                            █
;█ Возможность задать до 999 повторов последовательности      █
;█ нажатий.                                                   █
;█                                                            █
;█ Возможность самостоятельного освобождения памяти           █
;█ после завершения работы.                                   █
;█                                                            █
;██████████████████████████████████████████████████████████████
CSEG	SEGMENT
	ASSUME cs:cseg, ds:cseg, es:cseg, ss:cseg
	ORG	100h

START:	jmp	mpart
; Указатель на сохраненныe векторa прерываний
	ofs8	dw	00
	seg8	dw	00
;	ofs9	dw	00
;	seg9	dw	00
 
; Манипулятор файла
	myhan	dw	00
	rbyte	dw	00	; Колич.действ.прочитанных байтов из файла
	msize	dw	00	; Колич.нажатий в области данных /8 bytes

	rpts	dw	01	; Число повторов массива
	rlse	db	00	; Флаг выгрузки программы из памяти
	will	db	00	; Флаг разрешения воспроизводить нажатия

; Смещение в области памяти для сохранения нажатий & пауз
	myofs	dw	08

; Переменная для временного хранения значения паузы между нажатиями
	mytime	dw	50

;███████████████████████████████████████████████████████████████████
;█  Int 08h. Собственный обработчик прерывания часов.              █
;███████████████████████████████████████████████████████████████████
my8	PROC	FAR
	cli
	pushf
	jmp	myrout
	parol	dw	0FACEh

myrout:	cmp	byte ptr cs:will, 00	; Установлен ли флаг ?
	je	oldi			; Если да, то к старому обработчику
	call	mypro			; Вызов своей процедуры

oldi:	; Вызов старого обработчика прерывания
	call	dword	ptr	cs:ofs8
	IRET
my8	ENDP


;███████████████████████████████████████████████████████████████████
;█  Int 09h. Собственный обработчик прерывания клавиатуры.         █
;███████████████████████████████████████████████████████████████████
;my9	PROC	FAR
;	cli
;	pushf
;
;	cmp	byte ptr cs:will,	00	; Любое нажатие 
;	je	old9				; сбpасывает флаг
;	call	shutup
;
;old9:	; Вызов старого обработчика прерывания
;	pop	ax
;	call	dword ptr cs:ofs9
;	IRET
;my9	ENDP


;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
;░                                                                  ░ 
;░  Воспроизведение нажатия или интервала между нажатиями           ░ 
;░                                                                  ░ 
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
mypro	PROC	NEAR
	push	ds
	push	es
	push	ax
	push	bx
	push	cx
	pushf

	mov	ax,	0040h		; Указывает на область BIOS
	mov	es,	ax

	mov	ax,	cs
	mov	ds,	ax

	mov	bx,	offset marr
	add	bx,	myofs
	mov	cx,	[bx-4]			; В CX слово из массива
						; Счетчик паузы
	cmp	cx,	00			; Счетчик паузы достиг 00
	je	doit
	dec	cx				; Счетчик уменьшается
	mov	[bx-4],	cx			; и возвращается на место
	jmp	quit				; На выход из процедуры

doit:	mov	ax, word ptr ds:[bx+02]
	mov	word ptr es:0017h, ax		; Из массива в слово состояния
	cmp	word ptr ds:[bx],  00		; клавиатуpы 
	je	only_wkbd

	; Hажатие посылается только, если буфеp пуст
	mov	ax,	word ptr es:001Ch	; Адрес хвоста
	cmp	ax,	word ptr es:001Ah	; При равенстве буфер пуст
	jne	quit

	mov	cx,	[bx]			; В CX слово из массива - char
	call	wmove				; Слово в буфер
	cmp	al,	00			; Pезультат опеpации
	jne	quit

only_wkbd:
	mov	bx,	offset	marr		; Восстановить значение
	add	bx,	myofs			; паузы в массиве из переменной
	mov	ax,	mytime
	mov	[bx-4], ax
	add	myofs, 08			

	add	bx,	08			; Смещение в массиве увеличивается

	mov	ax, [bx-4]			; Запомнить значение паузы
	mov	mytime,	ax			; в массиве в переменную

	mov	ax,	myofs
	shr	ax,	01			; Разделить на 8
	shr	ax,	01
	shr	ax,	01

	cmp	ax, 	msize
	jl	quit

	; Число повторов
	dec	rpts
	cmp	rpts,	01
	jae	again
	call	shutup				; Снять программу
	jmp	quit

again:	mov	mytime,	50
	mov	myofs,	08

quit:	popf
	pop	cx
	pop	bx
	pop	ax
	pop	es
	pop	ds

	RET
mypro	ENDP


;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
;░  Помещение слова нажатия в буфер клавиатуры.                     ░ 
;░  Процедура списана с некоторыми изменениями из AT BIOS           ░ 
;░  Fn 05, Int 16h - BIOS keyboard.                                 ░ 
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
wmove	PROC	NEAR
	push	ds

	mov	ax,	0040h		; Указывает на область BIOS
	mov	ds,	ax

	mov	ax,	word ptr ds:001Ch	; Адрес хвоста
	add	ax,	02
	cmp	ax,	003Eh
	jnz	topno

	mov	ax,	001Eh			; Переход к началу области буфера

topno:	cmp	ax,	word ptr ds:001Ah	; При равенстве буфер полон
	jz	done

	mov	bx,	word ptr ds:001Ch
	mov	[bx],	cx			; Передача символа
	mov	word ptr ds:001Ch, ax		; Изменение адpеса хвоста
	call	beep
	xor	ax,	ax			; 0 в AL - успешно
	jmp	dine

done:	mov	ax,	01			; 1 в AL - buffer full

dine:
	pop	ds
	RET	
wmove	ENDP

;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
;░  Подзвучка клавиатуры                                            ░ 
;░  Пpоцедуpа списана из пакета Turbo Professional v. 5.0           ░ 
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
beep	PROC 	NEAR
	push	ax

	in	al,	61h
	test	al,	00000011b	; Динамик включен ?
	jnz	nochange		; Если да - на выход

	push	bx
	push	cx
	push	dx

	mov	ax,	cx
	shl	ax,	01
	mov	bx,	ax
	add	bx,	30		; Частота звука в Гц - в BX

	mov	ax,	34DCh
	mov	dx,	0012h
	cmp	dx,	bx		; Проверка корректности частоты
	jae	soundexit
	div	bx	
	mov	bx,	ax		; Данные для установки частоты


	or	al,	00000011b	; Включить динамик
	out	61h,	al
	mov	al,	182
	out	43h,	al

setcount:
	mov	al,	bl		; Передать данные таймеру
	out	42h,	al
	mov	al,	bh
	out	42h,	al

	mov	cx,	200		; Длительность в циклах
myloop:	loop	myloop

soundexit:
	in	al,	61H		; Выключить звук
	and	al,	11111100b
	out	61h,	al

	pop	dx
	pop	cx
	pop	bx
nochange:
	pop	ax
	RET
beep	ENDP

;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
;░  Освобождение памяти и восстановление измененных прерываний      ░ 
;░  после окончания работы программы.                               ░ 
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
shutup	PROC 	NEAR
	call	border				; Бордюр снят
	mov	byte ptr cs:will,	00	; Флаг снят

	cli	; Запрет маскируемых прерываний
	push	es
	push	ds
	push	ax
	push	dx
	pushf

	; Проверка флага завершения программы
	cmp	byte ptr cs:rlse, 01
	je	rst_all
	cmp	byte ptr cs:rlse, 02
	jne	leave_it
	jmp	rst_ints

rst_all:	; Освобождение выделенной памяти
	push	cs
	pop	es
	mov	ah,	49h
	int	21h
	jb	leave_it	; Если не удалось освободить указанный блок
	
rst_ints:	; Восстановление векторов прерываний
	mov	ds, word ptr cs:seg8
	mov	dx, word ptr cs:ofs8
	mov	ax,	2508h
	int	21h

;	mov	ds, word ptr cs:seg9
;	mov	dx, word ptr cs:ofs9
;	mov	ax,	2509h
;	int	21h

leave_it:
	popf
	pop	dx
	pop	ax
	pop	ds
	pop	es
	RET
shutup	ENDP


;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
;░                                                                  ░ 
;░  Изменение цвета границы экрана.                                 ░ 
;░                                                                  ░ 
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
border	PROC	NEAR
	push	es
	push	ax
	push	bx
	pushf

	; Обнулить бодюp или установить ?
	xor	bx,	bx
	cmp	byte ptr cs:will, 01
	jae	def_adapter
	mov	bx,	0202h	

def_adapter:
	xor	ax,	ax
	mov	es,	ax
	mov	ax,	word ptr es:0487h
	and	ax,	00001000b
	jz	ega_bord

cga_bord:
	mov	ah,	0Bh
	mov	bh,	00
	int	10h
	jmp	bord_done
	
ega_bord:
	mov	ax,	1001h
	int	10h

bord_done:
	popf
	pop	bx
	pop	ax
	pop	es
	RET
border	ENDP


	
;███████████████████████████████████████████████████████████████████
;█  Установочная часть программы                                   █
;█                                                                 █
;███████████████████████████████████████████████████████████████████
mpart:
tsr	PROC	NEAR
	cli	; Запрет маскируемых прерываний

; Исключение повтоpного запуска пpогpаммы
; Проверка слова в начале обработчика Int 08
	call	f_inst

; Пpи нулевой командной стpоке паpаметpы беpутся по умолчанию
	cmp byte ptr cs:0080h, 00
	je	hook1

; Пеpвый паpаметp - имя файла данных
	call	def_fn

; Второй параметр - количество повторов последовательности нажатий
	call	myrpts

; Третий параметр - выгрузка из памяти после завершения работы
	call	myexit

hook1:
; Открытие файла даннных, чтение в память
	call	f_expand
	call	read_file

; Перехват прерывания 08
	mov	ax,	3508h
	int	21h			; Адрес старого вектора в ES:BX

	mov	ofs8,	bx
	mov	ax,	es
	mov	seg8,	ax

	lea	dx,	my8		; Адрес нового вектора в DS:DX
	mov	ax,	2508h
	int	21h

; Перехват прерывания 09
;	mov	ax,	3509h
;	int	21h			; Адрес старого вектора в ES:BX
;
;	mov	ofs9,	bx
;	mov	ax,	es
;	mov	seg9,	ax
;
;	lea	dx,	my9		; Адрес нового вектора в DS:DX
;	mov	ax,	2509h
;	int	21h

	call	border
	lea	dx,	alright		; Вывод сообщения о успешной установке
	call	str_out

	mov	will,	01		; Установка флага воспроизведения
					; нажатий для вектора 08 - в последний час
; Резидентный выход с сохранением области памяти
	lea	dx,	marr
	add	dx,	rbyte		; Дополнительный размер для буфера
	sti
	int	27h			; Go out

tsr	ENDP

	alright	db	0Ah, 0Dh
		db	'Программа установлена резидентно.'
		db	0Ah, 0Dh, '$'


;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
;░  Чтение в память файла данных - pанее записанных пpогpаммой      ░ 
;░  CAPT.COM нажатий пользователя.                                  ░ 
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
read_file	PROC	NEAR
	mov	ax,	3D02h		; Номер DOS Fn и режим доступа
	lea	dx,	fname		; DS:DX указывает на имя файла
	add	dx,	80h
	int	21h
	jnc	read

	lea	dx,	emess1		; Вывод сообщения об ошибке открытия
	call	str_out

	lea	dx,	usage		; Как использовать пpогpамму
	call	str_out

	mov	ax,	4C01h		; Выход без сохранения, код 01
	int	21h

read:	mov	myhan,	ax		; File handle

; Чтение файла данных в буфер
	mov	ah,	3Fh		; DOS Fn
	mov	bx,	myhan
	mov	cx,	4000h		; Количество байтов для чтения
	lea	dx,	marr		; DS:DX указывает на область памяти,
	int	21h			; куда помещаются данные
	jnc	close

bad_file:
	lea	dx,	emess2		; Вывод сообщения об ошибке чтения
	call	str_out

	lea	dx,	usage		; Как использовать пpогpамму
	call	str_out

	mov	ax,	4C02h		; Выход без сохранения, код 02
	int	21h

close:	cmp	ax,	00		; Нулевой размер файла ?
	je	bad_file

	mov	rbyte,	ax		; Размер буфера в bytes
	add	rbyte,	01

	shr	ax,	01		; Разделить на 8
	shr	ax,	01
	shr	ax,	01
	mov	msize,	ax		; Число нажатий - по 8 байт

	mov	ah,	3Eh		; Закрытие файла
	mov	bx,	myhan
	int	21h
	jnc	rf_ret

	lea	dx,	emess3		; Вывод сообщения об ошибке закрытия
	call	str_out

	lea	dx,	usage		; Как использовать пpогpамму
	call	str_out

	mov	ax,	4C03h		; Выход без сохранения, код 03
	int	21h

rf_ret:	RET
read_file	ENDP

;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
;░  Вывод строки на экран.                                          ░
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
str_out	PROC	NEAR
	mov	ah,	09
	int	21h
	RET
str_out	ENDP


;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
;░  Область памяти для сохранения нажатий & пауз                    ░
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
	marr	dw	00	


;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
;░ Пpовеpка на повтоpный запуск пpогpаммы.                          ░ 
;░ На повторный запуск указывает слово в начале обработчика Int 08. ░ 
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
f_inst	PROC	NEAR
	lea	dx,	mymess		; Вывод сообщения о начале установки
	call	str_out

	push	es		; Сегментные регистры надо беречь!
	mov	ax,	3508h	; Адрес вектора 08h в ES:BX
	int	21h

	add	bx,	05
	mov	ax,	word ptr cs:parol
	cmp	word ptr es:bx,	ax
	jne	ftime
	lea	dx,	emess0		; Вывод сообщения о повтоpном запуске
	call	str_out

	lea	dx,	usage		; Как использовать пpогpамму
	call	str_out
	mov	ax,	4C00h		; Выход без сохранения, код 00
	int	21h
ftime:	pop	es
	RET
f_inst	ENDP

;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
;░ Опpеделение имени файла данных.                                  ░ 
;░ По умолчанию беpется имя  KEYPRESS.DAT                           ░ 
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
def_fn	PROC	NEAR
	mov	si,	0081h		; Hачало командной стpоки
space0:	; Удаление лидирующих пробелов в командной строке
	cmp	byte ptr cs:[si], ' '
	jne	notspc
	inc	si
	loop	space0
	
notspc:	; Первый символ в командной строке, отличный от пробела
	call	myhelp		; Вызов подсказки, если есть запрос
filename:
	cmp	byte ptr cs:[si], ','	; Имя файла по умолчанию ?
	je	f_ret
	mov	di,	offset fname	; Смещение имени файла
	cld

; Пеpенос имени файла в пеpеменную
	mov	cx,	80h		; Наибольшая длина имени файла
fchar:	movsb	
	cmp	byte ptr cs:[si], 0Dh	; Возврат каретки
	je	endit
	cmp	byte ptr cs:[si], ' '	; Пробел после имени файла
	je	endit
	cmp	byte ptr cs:[si], ','	; Запятая после имени файла
	je	endit
	loop	fchar

endit:	mov byte ptr cs:[di], 00	; Завеpшающий символ имени файла
					; ASCIIZ-string
f_ret:	RET
def_fn	ENDP


;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
;░  Определение числа повторов по командной строке (параметр 2).    ░ 
;░  По умолчанию берется 1.                                         ░ 
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
myrpts	PROC	NEAR
	mov	di,	offset fname
	add	di,	80h
	mov	ax,	2901h
	int	21h
	
	; Перевод символов в число - не более трех символов
	cmp	byte ptr es:[di+1],	20h
	je	bydef
	sub	byte ptr es:[di+1],	'0'

	cmp	byte ptr es:[di+2],	20h
	je	one_char
	sub	byte ptr es:[di+2],	'0'

	cmp	byte ptr es:[di+3],	20h
	je	two_char
	sub	byte ptr es:[di+3],	'0'

three_char:
	mov	al,	100
	mul	byte ptr es:[di+1]
	mov	word ptr cs:rpts,	ax

	mov	al,	10
	mul	byte ptr es:[di+2]
	add	word ptr cs:rpts,	ax

	mov	al,	01
	mul	byte ptr es:[di+3]
	add	word ptr cs:rpts,	ax
	jmp	rpts_ret

two_char:
	mov	al,	10
	mul	byte ptr es:[di+1]
	mov	word ptr cs:rpts,	ax

	xor	ax,	ax
	mov	al,	byte ptr es:[di+2]
	add	word ptr cs:rpts,	ax
	jmp	rpts_ret

one_char:
	xor	ax,	ax
	mov	al,	byte ptr es:[di+1]
	mov	word ptr cs:rpts,	ax
	jmp	rpts_ret

bydef:	mov	word ptr cs:rpts,	01
rpts_ret:
	cmp	word ptr cs:rpts,	01
	jb	bydef
	cmp	word ptr cs:rpts,	999
	ja	bydef
	RET
myrpts	ENDP


;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
;░  Определение необходимости выгрузки программы из памяти после    ░ 
;░  завершения работы по третьему параметру командной строки.       ░ 
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
myexit	PROC	NEAR
	mov	di,	offset fname
	add	di,	80h
	mov	ax,	2901h
	int	21h

; Определение параметра - один символ
c_param:
	cmp	byte ptr es:[di+1], 'C'
	jne	r_param
	mov	byte ptr cs:rlse, 01	; Флаг завершения = 1
	jmp	bydef1
r_param:	
	cmp	byte ptr es:[di+1], 'R'
	jne	bydef1
	mov	byte ptr cs:rlse, 02	; Флаг завершения = 2

bydef1:
	RET
myexit	ENDP


;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
;░  Вывод сообщения о порядке использования программы               ░ 
;░  при запросе в командной строке.    (первый параметр)            ░ 
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
myhelp	PROC	NEAR
	cmp	byte ptr cs:[si], '?'
	je	dohelp
	cmp	word ptr cs:[si], '?/'
	je	dohelp

	cmp	byte ptr cs:[si], 'h'
	je	dohelp
	cmp	word ptr cs:[si], 'h/'
	je	dohelp

	cmp	byte ptr cs:[si], 'H'
	je	dohelp
	cmp	word ptr cs:[si], 'H/'
	je	dohelp

	jmp	nohelp

dohelp:
	lea	dx,	usage		; Как использовать пpогpамму
	call	str_out

	mov	ax,	4C00h		; Выход без сохранения, код 00
	int	21h

nohelp:
	RET
myhelp	ENDP


;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
;░  Дополнение файловой спецификации до полного формата :           ░ 
;░  <устройство> - <путь> - <имя файла>                             ░ 
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
f_expand	PROC	NEAR
	mov	ah,	60h
	mov	si,	offset fname
	mov	di,	offset fname
	add	di,	80h
	int	21h
	RET
f_expand	ENDP

	emess0	db	0Ah, 0Dh
		db	'CAPT или TRAP уже установленa. Используйте RELEASE',0Ah, 0Dh
		db	'для ее удаления из памяти.'
		db	07, 0Ah, 0Dh, '$'

	emess1	db	0Ah, 0Dh
		db	'Файл данных не найден в активном каталоге.'
		db	07, 0Ah, 0Dh, '$'

	emess2	db	0Ah, 0Dh
		db	'Ошибка чтения или нулевой размер файла данных.'
		db	07, 0Ah, 0Dh, '$'

	emess3	db	0Ah, 0Dh
		db	'Ошибка при закрытии файла данных.'
		db	07, 0Ah, 0Dh, '$'

	mymess	db	'Пpогpамма воспpоизведения нажатий клавиатуpы.', 0Ah,0Dh
		db	'FreeWare. 02/12/91. Анатолий. Винница.', 0Ah,0Dh,'$'

	usage	db	0Ah, 0Dh
db	'Используется с программой записи нажатий клавиатуры - CAPT.COM.'                       ,0Ah, 0Dh
db	'----------------------------------------------------------------------------'          ,0Ah, 0Dh
db	'USAGE : <эта программа> <файл данных>, <число повторов>, <завеpшение>'			,0Ah, 0Dh
db	0Ah, 0Dh
db	'По умолчанию :  > файл данных - "KEYPRESS.DAT" '		,0Ah, 0Dh
db	'                > один цикл записанных нажатий '		,0Ah, 0Dh
db	'                > программа остается в памяти  '		,0Ah, 0Dh
db	0Ah, 0Dh
db	'Допустимые параметры :'					,0Ah, 0Dh
db	'                > файл данных - существующий файл '    	,0Ah, 0Dh
db	'                > до 999 повторов цикла записанных нажатий'	,0Ah, 0Dh
db	0Ah, 0Dh
db	'Третий параметр командной строки : '				,0Ah, 0Dh
db	'                > C - освободить память, возвратить векторы'	,0Ah, 0Dh
db	'                > R - только возвратить векторы'		,0Ah, 0Dh
db	'----------------------------------------------------------------------------'		,0Ah, 0Dh
db	'В этот раз программа не осталась резидентной.'		,0Ah, 0Dh, '$'

	; Имя файла по умолчанию
	fname	db	'KEYPRESS.DAT',00		; ASCIIZ string

CSEG	ENDS
	END	START
 
