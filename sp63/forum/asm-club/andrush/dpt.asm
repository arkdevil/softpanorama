;19930820пт DPT.com  MASM 5.0
;Запись в файл dpt.bin таблицы разделов диска (Disk Partition Table) и запись
;  из файла dpt.bin таблицы разделов на диск. Модифицирует системную область
;  диска. Будьте осторожны !
;Использование:
;DPT [/r][/w]
; /r - записать таблицу разделов диска в файл dpt.bin
; /w - записать таблицу разделов диска из файла dpt.bin на диск
codesg	segment para 'Code'
assume	cs:codesg,ds:codesg,ss:codesg
	org	100h
main	proc	near
	mov	bx,80h	;Анализируем командную строку. Просматриваем всю
	mov	cx,1Fh	;  командную строку в поисках опций /r или /w. Если
m01:	inc	bx	;  эти символы не найдены, выводим краткую справку
	cmp	byte ptr [bx],'/'       ;  и выходим в систему.
	jz	m02
	loop	m01
	mov	ah,09	;Выводим краткую справку
	lea	dx,Info
	int	21h
	int	20h
m02:	mov	al,[bx+1]	;Если опция задана маленькой латинской буквой,
	cmp	al,60h		;  преобразуем ее в большую
	js	m07
	sub	al,20h
m07:	cmp	al,'R'
	jnz	m03
	jmp	m04
m03:	cmp	al,'W'
	jnz	m01
m04:	mov	Regime,al
	cmp	Regime,'R'      ;Если задана опция "r", пишем таблицу разделов
	jnz	m05		;  в файл dpt.bin
	mov	ax,ds
	mov	es,ax	;Устанавливаем es на сегмент данных
	mov	ah,02	;Читаем в память таблицу разделов диска;
	mov	al,01	;  число секторов,
	lea	bx,EndPrg	;  адрес буфера,
	sub	ch,ch	;  дорожка 0,
	mov	cl,01	;  сектор 1,
	sub	dh,dh	;  сторона (головка) 0,
	mov	dl,80h	;  жесткий диск номер 1
	int	13h
	jnc	m17	;В случае ошибки сообщаем об этом и выходим в систему
	mov	ah,09
	mov	dx,offset Err7
	int	21h
	int	20h
m17:	mov	ah,3Ch	;Создаем файл dpt.bin
	sub	cx,cx
	lea	dx,FlNm
	int	21h
	jnc	m08	;В случае ошибки сообщаем об этом и выходим в систему
	mov	ah,09
	mov	dx,offset Err1
	int	21h
	int	20h
m08:	mov	bx,ax	;Пишем в него из памяти таблицу разделов
	mov	ah,40h
	mov	cx,200h
	lea	dx,EndPrg
	int	21h
	jnc	m09	;В случае ошибки сообщаем об этом и выходим в систему
	mov	ah,09
	mov	dx,offset Err2
	int	21h
	int	20h
m09:	cmp	ax,200h ;Если записаны не все байты, сообщаем об этом
	jz	m11	;  и выходим в систему
	mov	ah,09
	mov	dx,offset Msg2
	int	21h
	int	20h
m11:	mov	ah,3Eh	;Закрываем файл
	int	21h
	mov	ah,09	;Сообщаем об успешном создании файла dpt.bin
	mov	dx,offset Msg1
	int	21h
	int	20h	;Выходим в систему
m05:	cmp	Regime,'W'      ;Если задана опция "w", ищем файл dpt.bin
	jz	m06	;  и записывем его содержимое в таблицу разделов.
	int	20h	;  Т.к. программа имеет только две опции, то можно не
			;  проверять повторно, какая это опция, но для порядка
			;  я все же ввел проверку.
m06:	mov	ah,3Dh	;Открываем файл dpt.bin
	mov	al,00
	lea	dx,FlNm
	int	21h
	jnc	m10	;В случае ошибки сообщаем об этом и выходим в систему
	mov	ah,09
	mov	dx,offset Err3
	int	21h
	int	20h
m10:	mov	bx,ax
	mov	ah,42h	;Определяем размер файла
	mov	al,02
	sub	cx,cx
	sub	dx,dx
	int	21h
	jnc	m12	;В случае ошибки сообщаем об этом и выходим в систему
m19:	mov	ah,09
	mov	dx,offset Err4
	int	21h
	int	20h
m12:	cmp	dx,0000 ;Если размер dpt.bin не 512 байт, сообщаем об этом
	jz	m13	;  и выходим в систему
m14:	mov	ah,09
	mov	dx,offset Err5
	int	21h
	int	20h
m13:	cmp	ax,200h
	jnz	m14
	mov	ah,42h	;Устанавливаем файловый указатель на начало файла
	sub	al,al
	sub	cx,cx
	sub	dx,dx
	int	21h
	jc	m19	;В случае ошибки сообщаем об этом и выходим в систему
	mov	ah,3Fh	;Читаем dpt.bin  в память
	mov	cx,200h
	lea	dx,EndPrg
	int	21h
	jnc	m15	;В случае ошибки сообщаем об этом и выходим в систему
m16:	mov	ah,09
	mov	dx,offset Err6
	int	21h
	int	20h
m15:	cmp	ax,200h
	jnz	m16
	mov	ax,ds	;Записываем таблицу разделов из памяти на диск
	mov	es,ax
	mov	ah,03	;Функция записи на диск;
	mov	al,01	;  число секторов,
	lea	bx,EndPrg	;  адрес буфера,
	sub	ch,ch	;  дорожка 0,
	mov	cl,01	;  сектор 1,
	sub	dh,dh	;  сторона (головка) 0,
	mov	dl,80h	;  жесткий диск номер 1
	int	13h
	jnc	m18	;В случае ошибки сообщаем об этом и выходим в систему
	mov	ah,09
	mov	dx,offset Err8
	int	21h
	int	20h
m18:	mov	ah,09	;Сообщаем об успешной записи таблицы разделов из
	mov	dx,offset Msg3	;  файла на диск
	int	21h
	ret
main	endp
Info	db	0Dh,0Ah,'Read and Write Disk Partition Table. For special '
	db	'purpose. (c) AVN 1993.',0Dh,0Ah
	db	'Usage: DPT [/r][/w]',0Dh,0Ah
	db	'       r - read DPT to file',0Dh,0Ah
	db	'       w - write DPT to file',0Dh,0Ah
	db	'DPT modifyed sistem area. Be careful !',0Dh,0Ah,'$'
Msg1	db	'dpt.bin creating','$'
Msg2	db	'No space on disk','$'
Msg3	db	'DPT successfully writing to hard disk from dpt.bin','$'
Err1	db	'Error while creating dpt.bin','$'
Err2	db	'Error while writing to dpt.bin','$'
Err3	db	'Error while opening dpt.bin','$'
Err4	db	'Error while check size dpt.bin','$'
Err5	db	'dpt.bin must be 512 bytes','$'
Err6	db	'Error while reading dpt.bin','$'
Err7	db	'Error while reading DPT','$'
Err8	db	'Error while writing DPT','$'
FlNm	db	'dpt.bin',0
Regime	db	00
EndPrg	db	00
codesg	ends
	end	main
