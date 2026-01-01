title	19930830 Reg&CMOS.com (Registers and CMOS-memory). MASM 5.0
;Вывод на экран содержимого регистров процессора (кроме ip) в момент запуска
;  программы и содержимого CMOS.
;Заметим, что последние байты COM-файла со значением 0 можно удалить.
codesg	segment para 'Code'
assume	cs:codesg, ds:codesg, ss:codesg, es:codesg
	org	100h
Main	proc	near
;--------------------------------------
	mov	Rax,ax	;Запоминаем значения регистров в переменных
	mov	Rbx,bx
	mov	Rcx,cx
	mov	Rdx,dx
	mov	Rcs,cs
	mov	Rds,ds
	mov	Rss,ss
	mov	Res,es
	mov	Rsi,si
	mov	Rdi,di
	mov	Rsp,sp
	mov	Rbp,bp
	lahf
	sub	al,al
	mov	Rfl,ax
	mov	ah,09	;Выводим сообщение о назначении программы
	mov	dx,offset Msg
	int	21h

m01:	call	DispR	;Выводим на экран имя регистра
	call	DispV	;Выводим на экран значение регистра
	sub	Cycle,01
	jnz	m01

	mov	ah,02	;Удаляем последние две цифры содержимого флагового
	mov	dl,08	;  регистра, поскольку флаговый регистр имеет размер
	int	21h	;  1 байт
	int	21h
	int	21h
	mov	dl,' '
	int	21h
	int	21h

	mov	ah,09	;Выводим сообщение 'Contents of CMOS.'
	mov	dx,offset CMOSmsg
	int	21h
	mov	cx,0040h;Число читаемых из CMOS байт (64)
	sub	si,si	;В si - номер читаемого байта
m02:	mov	ax,si
	call	NumPrn	;Выводим на экран номер байта
	mov	ax,si	;Выводим в порт 70h смещение читаемого из CMOS байта
	out	70h,al
	mov	di,0FFFh;Делаем небольшую задержку времени (на всякий случай)
m03:	dec	di
	jnz	m03
	in	al,71h	;Принимаем в al значение из порта 71h
	call	NumPrn	;Выводим на экран это значение
	mov	ah,02	;Выводим два пробела
	mov	dl,20h
	int	21h
	int	21h
	inc	si	;Увеличиваем значение смещения байта, читаемого из CMOS
	loop	m02	;Повторяем процедуру чтения байта 64 раза

	mov	ah,09	;Переводим строку
	mov	dx,offset MsgPrt
	int	21h

	ret
Main	endp
;--------------------------------------
DispR	proc	near	;Процедура вывода на экран имени очередного регистра
	mov	ah,40h	;Выводим на экран очередное имя регистра
	mov	bx,0001
	mov	cx,0003
	mov	dx,offset Regs
	add	dx,PointR
	int	21h
	add	PointR,0003;Наращиваем значение указателя
	ret
DispR	endp
;--------------------------------------
DispV	proc	near	;Процедура вывода на экран значения регистра
	mov	bx,offset Rax	;Устанавливаем указатель на старший байт знач.
	add	bl,PointV;  очередного регистра
	mov	al,[bx] ;Помещаем это значение в al
	call	NumPrn	;Выводим на экран содержимое al в шестнадцатеричном виде
	mov	ah,02	;Стираем один символ перед курсором, т.к. процедура
	mov	dl,08	;  NumPrn выводит за числом пробел. Для стирания символа
	int	21h	;  выводим на экран символ 'BackSpace' ('Забой')
	dec	bx	;Устанавливаем указатель на младший байт значения
	mov	al,[bx]
	call	NumPrn	;Выводим на экран содержимое al в шестнадцатеричном виде
	add	PointV,02
	ret
DispV	endp
;---------------------------------------
NumPrn	proc	near	;Процедура вывода на экран шестнадцатеричного числа,
	push	ax	;  находящегося в регистре al, и пробела за ним
	mov	dl,al	;Выводим левую (старшую) цифру регистра al
	and	dl,11110000b
	shr	dl,1
	shr	dl,1
	shr	dl,1
	shr	dl,1
	cmp	dl,0Ah
	js	CP1
	add	dl,37h
	jmp	CP2
CP1:	add	dl,30h
CP2:	mov	ah,02
	int	21h
	pop	ax	;Выводим правую (младшую) цифру регистра al
	mov	dl,al
	and	dl,00001111b
	cmp	dl,0Ah
	js	CP3
	add	dl,37h
	jmp	CP4
CP3:	add	dl,30h
CP4:	mov	ah,02
	int	21h
	mov	dl,20h	;Выводим пробел
	int	21h
	ret
NumPrn	endp
;--------------------------------------
;	Данные
Regs	db	'ax bx cx dx cs ds ss es si di sp bp fl ';Имена регистров
Cycle	db	0Dh	;Число выводимых на экран регистров
Msg	db	0Dh,0Ah,'Some system information. For special purpose. '
	db	'(c) A!V!N 1990.',0Dh,0Ah,0Dh,0Ah
	db	'Registers in the moment of launching the programm.'
MsgPrt	db	0Dh,0Ah,'$'     ;Часть сообщ., используемая для перевода строки
CMOSmsg db	0Dh,0Ah,0Dh,0Ah,'Contents of CMOS.',0Dh,0Ah,'$'
PointR	dw	0000	;Указатель на имя регистра (ax, bx, cx, ...)
PointV	db	01	;Указатель на значение регистра
Tmp	db	00	;Временная переменная
Rax	dw	0000	;Регистры общего назначения
Rbx	dw	0000
Rcx	dw	0000
Rdx	dw	0000
Rcs	dw	0000	;Сегментные регистры
Rds	dw	0000
Rss	dw	0000
Res	dw	0000
Rsi	dw	0000	;Индексные регистры
Rdi	dw	0000
Rsp	dw	0000	;Регистровые указатели
Rbp	dw	0000
Rfl	dw	0000	;Флаговый регистр
;--------------------------------------
codesg	ends
	end	Main
