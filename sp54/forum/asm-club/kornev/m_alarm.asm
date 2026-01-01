;██████████████████████████████████████████████████████████████████
;      Multiple  alarm  - резидентный будильник на любое количество
;звонков. Висит на прерывании 1С. После очередного звонка номер те-
;кущего  увеличивается на 1,  пока не дойдет до конца таблицы звон-
;ков. При выполнении звонка производится "би - би" и выводится соо-
;бщение из второй таблицы . Считывание обеих таблиц из файла данных
;было писать лень (квалификация не позволяет сделать это достаточно
;быстро),  поэтому  предлагается  править  непосредственно  текст в
;строчках 268 -282.
;      Рассчитана на людей умеющих из .asm'a сделать .com. 
;▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

;        Корнев Александр (0832)- 91-12-89 (раб.  7.15 - 17.45)
;242024 Брянск п/о Мичуринское ул.Молодежная 4 кв.38.

;██████████████████████████████████████████████████████████████████
code    segment
	org	100h
	assume	cs:code,ds:code,ss:code,es:code
my_alarm: 	jmp	set_up
right		db	'Multiple alarm. (C) 1992. Kornev.',13,10,'$'
already_mes	db	'Already installed.','$'

process:                ; Это собственно и есть обработчик int 1С.

        push    ax      ;когда программа не работала наpushил на
        push    bx      ;всякий случай, пусть будет
	push	si
	push	cx
	push	dx
	push	es
	push	sp
	push	di
;▓▓▓▓▓▓▓ проверка условия выполнения активной части
	call	r_al_time	;считать значение звонка в cx
	call	r_time		;текущее время в ах
	cmp	ax,cx		;сравнить
	jne	do_not		;выйти, если неравно

;▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ активная часть
; По большому счету сюда желающие могут навставлять, чего их душа
; пожелает, например Л.М.Фрид может поставить перезагрузку машины на
; 3 часа ночи.
	call	play
	call	mes
;▒▒▒▒▒▒▒ установка следующего звонка
	inc	cs:alarm_cur
	call	r_al_time		;проверка не конец ли таблицы (0)
        jcxz    undo                    ;если конец - перейти на первый
	jmp	do_not
undo:	mov	cs:alarm_cur,0
;▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ конец активной части
do_not:
	pop	di
	pop	sp
	pop 	es
	pop	dx
	pop	cx
	pop	si
	pop	bx
	mov	ax,20h
	out	20h,ax
	pop	ax
	iret
;██████████████▓▓▓▓▓▓▓▓▓▓▓▓▓  считать в cx текущее время звонка
r_al_time	proc	near
	mov	si,cs:alarm_cur
	shl	si,1
	mov	bx,offset cs:alarms
	mov	cx,cs:[bx][si]
ret
r_al_time	endp
;▓▓▓▓▓▓▓▓▓▓▓▓▓▓█████████████
;██████████████▓▓▓▓▓▓▓▓▓▓▓▓▓	считать в ax время на часах
r_time	proc	near
	call	check_busy
	cli
	mov	al,4		;часы
	call	read_clock
	mov	ah,al
	mov	al,2		;минуты
	call	read_clock
	sti
ret
r_time	endp
;▓▓▓▓▓▓▓▓▓▓▓▓▓▓█████████████
;██████████████▓▓▓▓▓▓▓▓▓▓▓▓▓	адрес текущего сообщения в si
str_addr	proc	near
	mov	ax,cs:alarm_cur		;номер сообщения
	mov	si,ax
	shl	si,1
	mov	ax,cs:off_mes1[si]
	mov	si,ax
ret
str_addr	endp
;▓▓▓▓▓▓▓▓▓▓▓▓▓▓█████████████
;██████████████▓▓▓▓▓▓▓▓▓▓▓▓▓  процедура вывода сообщения
mes	proc	near
;▒▒▒▒▒▒▒▒▒▒▒▒▒▒		сначала измерим длину выводимой строки
	call	str_addr		;начало строки в si
	mov	cs:len,0		;обнулим длину
measure:
	mov	al,cs:[si]
	cmp	al,'$'
	je	end_measure
	inc	si
	inc	cs:len
	jmp	measure
end_measure:
;▒▒▒▒▒▒▒▒▒▒▒▒▒▒		рисуем рамку
	mov	ax,0b800h	;адрес видеопамяти в es
 	mov	es,ax
	mov	al,cs:len
	cbw
	mov	cl,2
	div	cl
	xor	ah,ah
	mul	cl		;избавляемся от	нечетного len
                                ;иначе рамочка будет некрасивая (иногда)
	mov	cs:ev_len,al
	sub 	cs:cur_pos,ax	;начало вывода рамки '┌': 1680 - ev_len
	mov	ax,cs:cur_pos	;в di
	mov	di,ax
	mov	al,'┌'
	call	write_al
	mov	al,cs:len	;теперь рисуем горизонтальные линии
	cbw
	mov	cx,ax		;число повторов в cx
hor_ln:	mov	al,'─'
	call	write_al;<───────┐
	add	di,318		;│
	mov	al,'─'		;│
	call	write_al	;│
 	sub	di,320		;│
	loop	hor_ln	;────────┘
	mov	al,'┐'
	call	write_al
	mov	ax,cs:cur_pos	;	левая │
	add	ax,160
	mov	di,ax
	mov	al,'│'
	call	write_al
	call	str_addr	;собственно строка
	add	cs:attrib,128	;включить мигание
next_let:
	mov	al,cs:[si]
	cmp	al,'$'
	je	all_done
 	call	write_al
	inc	si
	jmp	next_let
all_done:
	sub	cs:attrib,128	;выключить мигание
	mov	al,'│'		;	правая │
	call	write_al
	mov	ax,cs:cur_pos
	mov	di,ax
	add	di,320
	mov	al,'└'
	call	write_al
	mov	al,cs:len
	cbw
	add	di,ax
	add	di,ax
	mov	al,'┘'
	call	write_al
;▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒	восстановим первоначальное значение
	mov	cs:cur_pos,1680
	ret
mes	endp
;▓▓▓▓▓▓▓▓▓▓▓▓▓▓█████████████
;██████████████▓▓▓▓▓▓▓▓▓▓▓▓▓	вывести символ из al с атрибутом attrib
write_al	proc		near
	mov	es:[di],al
	inc	di
	mov	al,cs:attrib
	mov	es:[di],al
	inc	di
ret
write_al	endp
;			     ┌──────────────────────────────┐
;██████████████▓▓▓▓▓▓▓▓▓▓▓▓▓ │	процедура обращения к часам │
;	 		     │  (зависит от al)             │
;			     │	al=00h - секунды            │
;			     │	al=02h - минуты             │
;			     │	al=04h - часы               │
;			     └──────────────────────────────┘
; Честно содрана из BIOS'а с помощью Sourcer'a. Спасибо всем.
read_clock		proc	near
	out	70h,al
	jmp	short $+2
	jmp	short $+2
	jmp	short $+2
	in	al,71h
	ret
read_clock		endp
;██████████████▓▓▓▓▓▓▓▓▓▓▓▓▓ 	проверить не идет ли изменение времени
; Это тоже из BIOS'a
check_busy	proc	near
	push	cx
	mov	cx,1168h
repeat:
	mov	al,0ah
	cli
	out	70h,al
	jmp	short $+2
	in	al,71h
	and	al,80h		;7 бит занятости
	jz	go_out
	sti
	loop	repeat
	mov	al,80h
go_out:
	pop	cx

	ret
check_busy	endp
;▓▓▓▓▓▓▓▓▓▓▓▓▓▓█████████████
;██████████████▓▓▓▓▓▓▓▓▓▓▓▓▓	гудок
; А это честно содрано у Джордэйна. Спасибо Роберт.
play	proc	neazr
	jmp	beep
num_cyc	equ	2			;количество циклов
num_ces	equ	200 			;количество колебаний
freq	dw	?
port_b	equ	61h
beep:	mov	cx,num_cyc
cycle:	cli
	mov	cs:freq,150
	call	signal
	mov	cs:freq,300
	call	signal
	sti
	loop	cycle
	ret
play	endp
;▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
signal	proc	near
	push	cx
	mov	dx,num_ces
	in	al,port_b
	and	al,11111110b		;отключить динамик от таймера
next_cle:	or	al,00000010b	;включить динамик
	out	port_b,al
	mov	cx,cs:freq
fir_half:	loop	fir_half
	and	al,11111101b		;выключить динамик
	out	port_b,al
	mov	cx,cs:freq
sec_half:	loop	sec_half
	dec	dx
	jnz	next_cle
	pop	cx
ret
signal	endp
;▓▓▓▓▓▓▓▓▓▓▓▓▓▓█████████████
;▒▒▒▒▒▒▒▒▒▒▒▒▒▒ область данных резидента  ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
alarm_cur       dw      0       ;номер текущего значения звонка (начиная с 0)
cur_pos		dw	1680	;начальный адрес в видеопамяти
len		db	0	;длина выводимой строки
ev_len		db	0	;ближайшее четное число для len
attrib          db      78      ;атрибут символов (желтый на красном -
                                ; - дело вкуса)
;▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐
; ВНИМАНИЕ! ВОТ ОНО ТО МЕСТО, ГДЕ НАДО ПОМЕНЯТЬ ВРЕМЕНА И ТЕКСТЫ СООБЩЕНИЙ !
;▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐▐
;таблица времени звонков ───────────────────────────────────────────────────┐
alarms          dw      935h,1000h,1155h,1435h,1500h,1555h,1655h,1750h,0;──┘
; 935h - соответствует 09 часам 35 минутам, не забудьте поставить h и 0 в
;                                                             конце таблицы
;▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒  таблица выводимых строк
; Количество звонков и строк должно соответствовать друг другу.
; При желании можно по аналогии убрать или добавить любое их количество
; (в разумных пределах, конечно).
mes1	db	' Не забудь поставить чайник ! ','$'
mes2	db	' 10:00 - Пора пить чай ! ','$'
mes3	db	' О Б Е Д ! ','$'
mes4	db	' Можно ставить чайник. ','$'
mes5	db	' 15:00 - Пора пить чай ! ','$'
mes6	db	' Конец женского рабочего дня. ','$'
mes7	db	' Конец мужского рабочего дня. ','$'
mes8	db	' Хватит вкалывать ! Пора домой !','$'
;  смещения выводимых строк
; приемчик из BIOS'а же (int 1ah) - очень понравилось
off_mes1	dw	offset mes1
off_mes2	dw	offset mes2
off_mes3	dw	offset mes3
off_mes4	dw	offset mes4
off_mes5	dw	offset mes5
off_mes6	dw	offset mes6
off_mes7	dw	offset mes7
off_mes8	dw	offset mes8

;▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒	конец области данных
;████████████████████████████████████████████████████████████████████████
;				ЗАГРУЗЧИК
;████████████████████████████████████████████████████████████████████████
;▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ при загрузке установить ближайший alarm
set_up:
	lea	dx,right
	mov	ah,09h
	int	21h
	mov     ax, 351ch		; проверка не установлен ли уже alarm
        int     21h                     ; (тоже не я придумал)
        cmp     bx, offset process      ; из Софтпанорамовского исходника
	jz      already
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░	считать время звонка в сх, если 0 - выход
next_time:	call	r_al_time
	jcxz	no_load
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░	считать время в ах
	call	r_time
	cmp 	ax,cx
	jl	loading			;если < загружать резидент
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
	inc	alarm_cur		;если нет, взять следующее время
	jmp	next_time
;▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒	ЗАГРУЗКА
loading:
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░   освобождение environment
	push	es
	mov	ax,ds:[2ch]
	mov	es,ax
	mov	ah,49h
	int 	21h
	pop 	es
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░	установка вектора 1ch
	mov	ax,251ch
	lea	dx,process
	int	21h
	lea	dx,set_up
	int	27h
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░	;уже загружен
already:	lea 	dx,already_mes
	mov 	ah,09h
	int 	21h
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░	;выход без резидента
no_load:	int	20h
code	ends
	end	my_alarm
