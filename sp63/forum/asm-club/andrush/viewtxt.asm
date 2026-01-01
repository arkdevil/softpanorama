;19930911сб  ViewTxt.com  MASM 5.0
;Просмотрщик текстовых и бинарных файлов
codesg	segment para 'Code'
assume	cs:codesg,ds:codesg,ss:codesg,es:nothing
	org	100h
begin:	jmp	main
;---------------------------------------
;	Данные
Handl	dw	?	;Файловый номер
PntF	label	dword	;Указатель на символ в файле, который находится в
PntH	dw	0000	;  начале экрана; PntH - старшая часть, PntL - младшая
PntL	dw	0000	;
OffsF	label	dword	;Указатель смещения в файле (текущий)
OffsH	dw	0000	;Указатель смещения в файле, старшая часть
OffsL	dw	0000	;Указатель смещения в файле, младшая часть
SizeF	label	dword	;Размер файла
SizeH	dw	?	;Размер файла, старшая часть
SizeL	dw	?	;Размер файла, младшая часть
RecNum	dw	0000	;Номер записи, находящийся в буфере
Symb	db	?	;Читаемый из файла символ
LenRec	dw	2000h	;Длина записи в файле
PntVid	dw	0000h	;Указатель ячейки памяти в видеобуфере
Tmp	label	word
Tmp1	db	?	;Временная переменная
Tmp2	db	?	;Временная переменная
;---------------------------------------
main	proc	near
	call	SpDel	;Удаляем пробелы из командной строки
	call	Info	;Выводим краткую справку, если нужно
	call	ASCIIZ	;Преобразуем имя файла в ASCIIZ-строку
	call	OpenF	;Открываем файл
	mov	ax,0003 ;Устанавливаем текстовый режим экрана (80*25)
	int	10h
	mov	ah,01h	;Делаем курсор невидимым
	mov	ch,20h
	int	10h
	mov	ah,0Bh	;Делаем бордюр экрана зеленым
	mov	bx,0002h
	int	10h
m12:	call	PrintPage	;Выводим страницу
Menu:	mov	ax,0C08h;Ожидаем ввода символа с клавиатуры, предварительно
	int	21h	;  очистив буфер клавиатуры
	cmp	al,1Bh	;Если нажата клавиша "ESC", выходим в систему
	jnz	m13
	jmp	Quit
m13:	cmp	al,'l'  ;Если нажата клавиша "l" или "L", загружаем новый файл
	jnz	m10
m11:	call	LoadFl	;Загружаем новый файл
	jmp	m12
m10:	cmp	al,'L'
	jz	m11
	cmp	al,00	;Если не нажата клавиша, создающая расширенный код,
	jnz	Menu	;  возвращаемся к началу меню
	mov	ah,08	;В противном случае читаем второй символ, полученный
	int	21h	;  с клавиатуры
	cmp	al,'G'          ;Home ?
	jnz	m00
	mov	PntH,0000
	mov	PntL,0000
	jmp	m05
m00:	cmp	al,'P'          ;Down
	jnz	m01
	call	NextLine;Устанавливаем указатель PntF на следующую строку
	jmp	m05
m01:	cmp	al,'H'          ;Up
	jnz	m02
	call	BackLine;Устанавливаем указатель PntF на предидущую строку
	jmp	m05
m02:	cmp	al,'O'          ;End
	jnz	m03		;Если нажата клавиша End, устанавливаем
	mov	ax,SizeH	;  указатель в конец файла, 24 раза переводим
	mov	PntH,ax 	;  его на предидущую строку, выводим страницу
	mov	ax,SizeL	;  на экран и переходим к началу меню
	mov	PntL,ax
	mov	cx,0018h
m04:	push	cx
	call	BackLine	;  (перемещаем главный указатель на предидущую
	pop	cx		;  строку)
	loop	m04
	jmp	m05
m03:	cmp	al,'Q'          ;PgDn
	jnz	m06
	mov	cx,0018h
m07:	push	cx
	call	NextLine
	pop	cx
	loop	m07
	jmp	m05
m06:	cmp	al,'I'          ;PgUp
	jnz	m08
	mov	cx,0018h
m09:	push	cx
	call	BackLine
	pop	cx
	loop	m09
	jmp	m05
m08:

m05:	call	PrintPage
	jmp	Menu
Quit:	ret
main	endp
;---------------------------------------
SpDel	proc	near	;Удаление пробелов из командой строки
	push	ds	;Помещаем в es значение из ds
	pop	es
	mov	bx,0080h;Устанавливаем указатель на начало командной строки
SD01:	inc	bx	;Увеличиваем указатель
SD02:	cmp	byte ptr [bx],0Dh	;Если указатель показывает на символ
	jz	SD00			;  возврата каретки, выходим
	cmp	byte ptr [bx],20h	;Если указатель показывает на символ
	jnz	SD01	;  пробела, перемещаем всю командную строку на 1 символ
	mov	si,bx	;  влево, начиная с байта, следующего за пробелом.
	inc	si	;  Если указатель показывает не на "пробел", повторяем
	mov	di,bx	;  цикл (наращивая указатель).
	mov	cx,0100h
	sub	cx,si
	rep	movsb
	mov	al,ds:[80h]	;Уменьшаем байт по адресу 80h, показывающий,
	dec	al		;  сколько символов в командной строке
	mov	ds:[80h],al
	jmp	SD02	;Повторяем цикл, НЕ наращивая указатель
SD00:	ret
SpDel	endp
;---------------------------------------
Info	proc	near	;Вывод краткой справки, если командная строка пуста
	mov	bx,0080h;  или содержит подстроку "/?" или "/h"
	cmp	byte ptr [bx],00
	jnz	 MI00	;Если командная строка пуста, выводим справку и выходим
MI04:	mov	ah,09h	;Вывод справки
	mov	dx,offset InfMsg
	int	21h
	int	20h	;Выход в систему
MI00:	mov	cl,byte ptr [bx]	;Устаналиваем счетчик в cx равным длине
	sub	ch,ch			;  командной строки
MI03:	inc	bx	;Просматриваем командную строку. Если встретится
	cmp	byte ptr [bx],'/'       ;  соответствующая подстрока, выводим
	jnz	MI02			;  справку и выходим
	inc	bx
	cmp	byte ptr [bx],'?'
	jz	MI04
	cmp	byte ptr [bx],'h'
	jz	MI04
	cmp	byte ptr [bx],'H'
	jz	MI04
MI02:	loop	MI03
	ret
InfMsg	db	0Dh,0Ah,'ViewTxt  Copyright AVN 1993',0Dh,0Ah
	db	'String to 79 symbols',0Dh,0Ah,0Dh,0Ah
	db	'viewer [file] [/?] [/h]',0Dh,0Ah,0Dh,0Ah
	db	'l - load new file (after running programm)',0Dh,0Ah,'$'
Info	endp
;---------------------------------------
ASCIIZ	proc	near	;Преобразование имени файла, находящегося в командной
	mov	bx,0081h;  строке, в ASCIIZ-строку. Процедура делает очень
	add	bl,byte ptr ds:[80h]	;  просто: заменяет в командной строке
	mov	byte ptr [bx],00	;  символ возврата каретки на символ
	ret		;  00h. Тогда имя файла будет начинаться со смещ. 81h.
ASCIIZ	endp
;---------------------------------------
OpenF	proc	near	;Открытие файла
	mov	ax,3D00h;Открываем файл, имя которого задано в ASCIIZ формате
	mov	dx,0081h;  по адресу 81h
	int	21h
	jnc	OF00	;Если нет ошибки...
	mov	ah,09	;Если ошибка, сообщаем и выходим в систему
	mov	dx,offset OF01
	int	21h
	int	20h
OF01	db	0Dh,0Ah
OF02	db	'Error open file','$'
OF00:	mov	Handl,ax;Запоминаем фаловый номер
	mov	ax,4202h;Определяем размер файла
	mov	bx,Handl
	sub	cx,cx
	sub	dx,dx
	int	21h
	mov	SizeH,dx;Старшее слово четырехбайтового размера
	mov	SizeL,ax;Младшее слово
	mov	RecNum,0000	;Помещаем в буфер первую запись
	call	GetRec
	ret
OpenF	endp
;---------------------------------------
PrintPage proc	near	;Вывод на экран страницы, начиная со смещения PntF
	mov	si,offset SizeF ;Если указатель вышел за пределы или
	mov	di,offset PntF	;  находится в конце файла, выходим из процед.
	mov	cx,0002
	cld
	rep	cmpsw
	jbe	PP00
	mov	ax,PntH 	;Устанавливаем текущий указатель на смещение
	mov	OffsH,ax	;  символа в начале экрана
	mov	ax,PntL
	mov	OffsL,ax
	mov	ax,0600h	;Очищаем экран (кроме нижней информационной
	mov	bh,20h		;  строки)
	sub	cx,cx
	mov	dx,174Fh
	int	10h
	mov	PntVid,0000	;Устанавливаем указатель в начало экрана
PP01:	call	TakeByte	;Читаем из файла байт со смещением OffsF
	call	PrintSymb	;Выводим символ на экран
	cmp	PntVid,0F00h
	js	PP01
	call	InfoStr 	;Выводим внизу экрана справочную информацию
PP00:	ret
PrintPage endp
;---------------------------------------
TakeByte proc near	;Чтение из файла байта со смещением OffsF в перем. Symb
	mov	si,offset SizeF ;Если заданное смещение превышает или равно
	mov	di,offset OffsF ;  размеру файла, возвращаем в переменной Symb
	mov	cx,0002 	;  "перевод строки" и выходим из процедуры
	cld			;  (если смещение равно размеру файла, то оно
	rep	cmpsw		;  уже вышдо за его пределы, потомучто оно
	ja	TB01		;  считается с ноля, а размер файла с единицы)
	mov	al,0Ah
	mov	Symb,al
	jmp	TB00
TB01:	mov	dx,OffsH;Определяем, в какой записи находится требуемый байт
	mov	ax,OffsL
	mov	bx,LenRec
	div	bx
	push	dx
	cmp	ax,RecNum	;Если текущая запись не совпадает с этим
	jz	TB02		;  значением, помещаем в буфер требуемую запись
	mov	RecNum,ax	;Присваеваем новое значение текущей записи
	call	GetRec		;Помещаем в буфер запись номер RecNum
TB02:	pop	bx		;Помещаем прочитанный из файла символ в
	add	bx,offset Buffer;  переменную Symb
	mov	al,byte ptr [bx]
	mov	Symb,al
	add	OffsL,1 	;Наращиваем значение смещения
	jnc	TB00
	add	OffsH,1
TB00:	ret
TakeByte endp
;---------------------------------------
GetRec	proc	near		;Загрузка в буфер записи номер RecNum
	mov	ax,LenRec	;Устанавливаем файловый указатель на
	mul	RecNum		;  требуемое смещение
	mov	cx,dx
	mov	dx,ax
	mov	ax,4200h	;  Функция установки файлового указателя на
	mov	bx,Handl	;  требуемое смещение
	int	21h
	mov	ah,3Fh		;Помещаем запись в буфер
	mov	bx,Handl
	mov	cx,LenRec	;  (длина записи)
	mov	dx,offset Buffer
	int	21h
	ret
GetRec	endp
;---------------------------------------
NextLine proc near	;Установка главного указателя PntF на следующуй строку
	mov	si,offset SizeF ;Если заданное смещение превышает размер файла
	mov	di,offset PntF	;  или равно ему, выходим из процедуры
	mov	cx,0002
	cld
	rep	cmpsw
	jle	NL00
	mov	ax,PntH 	;Устанавливаем текущее смещение равным
	mov	OffsH,ax	;  основному смещению
	mov	ax,PntL
	mov	OffsL,ax
NL02:	call	TakeByte	;Читаем из файла соответствующий байт
	cmp	Symb,0Dh	;Это "возврат каретки" ?
	jz	NL01		;Если нет, извлекаем следующий байт
NL03:	mov	si,offset SizeF ;Если текущее смещение превышает размер файла
	mov	di,offset OffsF ;  или равно ему, выходим из процедуры
	mov	cx,0002
	cld
	rep	cmpsw
	jle	NL00
	jmp	NL02
NL01:	mov	si,offset SizeF ;Если текущее смещение превышает размер файла
	mov	di,offset OffsF ;  или равно ему, выходим из процедуры
	mov	cx,0002
	cld
	rep	cmpsw
	jle	NL00
	call	TakeByte	;Читаем из файла соответствующий байт
	cmp	Symb,0Ah	;Это "перевод строки" ?
	jnz	NL03		;Если нет, извлекаем следующий байт
	mov	ax,OffsH	;Устанавливаем главный указатель PntF на начало
	mov	PntH,ax 	;  следующей строки и выходим из процедуры
	mov	ax,OffsL
	mov	PntL,ax
NL00:	ret
NextLine endp
;---------------------------------------
BackLine proc	near	;Установка главного указателя PntF на предидущую строку
	mov	ax,PntH 	;Выравниваем текущий и главный указатели
	mov	OffsH,ax
	mov	ax,PntL
	mov	OffsL,ax
	cmp	OffsH,0000	;Если текущий указатель находится в начале
	jnz	BL00		;  файла, выходим из процедуры
	cmp	OffsL,0000
	jz	BL01
BL00:	mov	cx,0003 	;Трижды уменьшаем текущий указатель на 1
BL02:	call	DecOffs
	loop	BL02
	cmp	OffsH,0FFFFh	;Если он становится меньше 0, даем главному
	jnz	BL03	       ;  указателю значение 0 и выходим из процедуры
	mov	PntH,0000
	mov	PntL,0000
	jmp	BL01
BL03:	call	TakeByte	;Читаем из файла байт со смещением OffsF
	cmp	Symb,0Ah	;Эти символ "перевод строки" ?
	jz	BL04
	mov	cx,0002h
	jmp	BL02
BL04:	mov	ax,OffsH	;Если это символ "перевод строки", присваеваем
	mov	PntH,ax 	;  главному указателю значение текущего,
	mov	ax,OffsL	;  котоый как раз стоит в начале следующей
	mov	PntL,ax 	;  строки, и выходим из процедуры
BL01:	ret
BackLine endp
;---------------------------------------
DecOffs proc	near	;Уменьшение текущего указателя на единицу
	cmp	OffsH,0000	;Если он уже равен 0, то даем ему значение
	jnz	D00		;  FFFFFFFFh
	cmp	OffsL,0000
	jnz	D00
	mov	OffsH,0FFFFh
	mov	OffsL,0FFFFh
	jmp	D01
D00:	mov	ax,OffsL	;Если он не равен нолю, уменьшаем его на 1
	dec	ax
	mov	OffsL,ax
	cmp	ax,0FFFFh
	jnz	D01
	mov	ax,OffsH
	dec	ax
	mov	OffsH,ax
D01:	ret
DecOffs endp
;---------------------------------------
InfoStr proc  near	;Вывод в нижнюю строку экрана имени файла, смещения в
	mov	ah,02h	;  файле символа, нах-ся в верхнем левом углу экрана,
	mov	bh,00h	;  и размера файла
	mov	dx,1800h
	int	10h	;Установили курсор в первую позицию нижней строки
	mov	ah,40h	;Выводим имя файла (и путь к нему, если он указан)
	mov	bx,0001h;  (стандартное устройство вывода (экран))
	mov	ch,00h
	mov	cl,ds:[80h]	;  (число символов, равное длине ком. строки)
	cmp	cl,28h
	js	Inf00
	mov	cl,28h
Inf00:	mov	dx,0081h;  (адрес имени файла)
	int	21h
	mov	ah,09h	;Выводим слово "Смещение"
	mov	dx,offset StrInf1
	int	21h
	mov	bx,PntH ;Выводим значение смещения
	call	RegPrn
	mov	bx,PntL
	call	RegPrn
	mov	ah,02h	;Выводим символ 'h', говорящий, что числа
	mov	dl,'h'  ;  шестнадцатеричные
	int	21h
	mov	ah,09h	;Выводим фразу "Размер файла"
	mov	dx,offset StrInf2
	int	21h
	mov	bx,SizeH;Выводим размер файла
	call	RegPrn
	mov	bx,SizeL
	call	RegPrn
	mov	ah,02h	;Выводим символ 'h', говорящий, что числа
	mov	dl,'h'  ;  шестнадцатеричные
	int	21h
	ret
Strinf1 db	'  Offset ','$'
StrInf2 db	'  File size ','$'
InfoStr endp
;---------------------------------------
RegPrn	proc	near	;Вывод на экран шестнадцатеричного числа,
	mov	dl,bh	;  находящегося в  регистре bx
	and	dl,11110000b
	mov	cl,04
	shr	dl,cl
	call	Conv	;Вывод на экран шестнадцатеричной цифры, находящейся
	mov	dl,bh	;  в правой (младшей) цифре регистра dl
	and	dl,00001111b
	call	Conv
	mov	dl,bl
	and	dl,11110000b
	mov	cl,04
	shr	dl,cl
	call	Conv
	mov	dl,bl
	and	dl,00001111b
	call	Conv
	ret
RegPrn	endp
;--------------------------------------
Conv	proc	near	;Вывод на экран шестнадцатеричной цифры, находящейся
	cmp	dl,0Ah	;  в правой (младшей) цифре регистра dl
	js	C01
	add	dl,37h
	jmp	C02
C01:	add	dl,30h
C02:	mov	ah,02
	int	21h
	ret
Conv	endp
;---------------------------------------
PrintSymb proc	near	;Вывод символа на экран с прямой записью в видеобуфер
	cmp	Symb,0Dh;Если это символ "возврат каретки", устанавливаем
	jnz	PS00	;  указатель на первую позицию экрана
	mov	ax,PntVid	;Делим указатель видеобуфера на 160 и получаем
	mov	bl,0A0h 	;  частное в al
	div	bl
	mul	bl
	mov	PntVid,ax
	jmp	PS01
PS00:	cmp	Symb,0Ah;Если символ "перевод строки", опускаем воображаемый
	jnz	PS02	;  курсор на строку ниже
	mov	ax,PntVid
	add	ax,0A0h
	mov	PntVid,ax
	jmp	PS01
PS02:	cmp	Symb,09h;Если это символ "табуляция", переводим указатель
	jnz	PS03	;  видеобуфера на соответствующий адрес
	call	PntTab
	jmp	PS01
PS03:	mov	bx,PntVid
	mov	ax,0B800h
	push	es	;Сохраняем значение es в стеке
	mov	es,ax
	mov	al,Symb
	mov	es:[bx],al
	add	PntVid,2	;Наращиваем указатель видеобуфера на 2 единицы
	pop	es	;Восстанавливаем значение es из стека
PS01:	ret
PrintSymb endp
;---------------------------------------
PntTab	proc	near	;Перевод указателя видеобуфера PntVid на адрес,
	mov	ax,PntVid	;указывающий на позицию на экране, где должен
	mov	bl,0A0h 	;находится курсор после символа табуляции
	div	bl
	mul	bl
	mov	bx,PntVid
	sub	bx,ax
	mov	ax,bx
	shr	ax,1
	inc	ax
	mov	Tmp1,al ;Нашли позицию на экране, соответствующую ячейке
	mov	bl,00h	;  памяти видеобуфера PntVid
PT01:	mov	al,08h
	mul	bl
	inc	al
	cmp	Tmp1,al
	js	PT00
	inc	bl
	jmp	PT01
PT00:	mov	Tmp2,al ;Нашли позицию на экране, куда будет выводиться
	sub	al,Tmp1 ;  следующий символ, если в предидущую позицию,
	mov	ah,00h	;  определенную значением PntVid, будет выведен символ
	shl	ax,1	;  "табуляция"
	add	PntVid,ax	;Нашли соответствующий этой позиции адрес
	ret			;  видеобуфера
PntTab	endp
;---------------------------------------
LoadFl	proc	near	;Загрузка нового файла
	call	CleanI	;Очищаем нижнюю строку и устанавливаем в нее курсор
	mov	ah,09h	;Выводим сообщение "Введите имя файла"
	mov	dx,offset MsgLoad
	int	21h
	mov	byte ptr ds:[0BFh],40h	;Наибольшая длина имени файла 64 симв.
	mov	ah,0Ah	;Вводим имя файла			(вместе с 0Dh)
	mov	dx,0BFh
	int	21h
	cmp	byte ptr ds:[0C0h],0	;Если введено 0 символов, выходим
	jz	LF01			;  из процедуры
	mov	bx,00C1h;Заменяем символ 0Dh ("Ввод") нулем, получая в
	add	bl,byte ptr ds:[0C0h]	;  результате ASCIIZ-строку
	mov	byte ptr [bx],00
	mov	ax,3D00h;Открываем файл только для чтения
	mov	dx,0C1h
	int	21h
	jnc	LF00	;Если нет ошибки, продолжаем, иначе сообщаем об этом
	call	CleanI	;Очищаем нижнюю строку и устанавливаем в нее курсор
	mov	ah,09h
	mov	dx,offset OF02
	int	21h
	mov	ah,08h	;Ожидаем нажатия любой клавиши и после нажатия
	int	21h	;  выходим из процедуры
	jmp	LF01
LF00:	mov	Tmp,ax	;Запоминаем файловый номер
	mov	ah,3Eh	;Закрываем прежний файл
	mov	bx,Handl
	int	21h
	mov	ax,Tmp	;Указываем новый файловый номер
	mov	Handl,ax
	push	ds	;Копируем новое имя файла на место прежнего имени. Для
	pop	es	;  этого сравниваем значения es и ds, устанавливаем
	mov	si,0C0h ;  адреса источника и приемника и число пересылаемых
	mov	di,080h ;  байт и копируем строку на место прежней строки
	mov	ch,00h
	mov	cl,ds:[0C0h]
	inc	cx
	inc	cx
	rep	movsb
	mov	ax,4202h;Определяем размер файла
	mov	bx,Handl
	sub	cx,cx
	sub	dx,dx
	int	21h
	mov	SizeH,dx;Старшее слово четырехбайтового размера
	mov	SizeL,ax;Младшее слово
	mov	RecNum,0000	;Помещаем в буфер первую запись
	call	GetRec
	mov	PntH,0000h	;Устанавливаем указатель на начало файла
	mov	PntL,0000h
LF01:	ret
MsgLoad db	'Enter filename: ','$'
LoadFl	endp
;---------------------------------------
CleanI	proc	near	;Очистка нижней строки и установка в нее курсора
	mov	ax,0701h;Очищаем нижнюю строку
	mov	bh,07h
	mov	cx,1800h
	mov	dx,18FFh
	int	10h
	mov	ah,02	;Устанавливаем курсор в нижнюю строку экрана
	mov	bh,00
	mov	dx,1800h
	int	10h
	ret
CleanI	endp
;---------------------------------------
Buffer	db	00	;Файловый буфер, длина которого определяется LenRec
;---------------------------------------
codesg	ends
	end	begin
