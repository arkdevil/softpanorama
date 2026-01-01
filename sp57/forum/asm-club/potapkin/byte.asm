;		     Исходный текст утилиты BYTE.COM 1.4
;		       Автор - Потапкин Роман Сергеевич
;	        домашний телефон (095) 408-77-21 (21:00-23:00)
;
;    Эта программа для тех, кто при написании программ испытывает ужасные
;  муки в поисках единственного  байтика,  соответствующего  коду  нужной
;  клавиши, цветовому аттрибуту и тому подобное.  В  таблице  BYTE  можно
;  найти все возможные байты в  десятичной,  шестнадцатеричной,  двоичной
;  и  восьмеричной  системах,  соответствующий  символ  ASCII,   цветовой
;  аттрибут и можно узнать код  любой  клавиши.  Кроме  того,  Вы  можете
;  перенести на экран любой символ в любом количестве или его  десятичное
;  представление. И это все при 2К в памяти !
;
;    Для сокращения объема занимаемой памяти  я  пересылаю  часть  данных
;  в конец PSP (80h). В качестве буфера используется конец  видео  памяти
;  с сегмента 0BF00h (пока каких-либо побочных эффектов не  наблюдалось).
;  Для идентификации ранее загуженной BYTE  и  ее  выгрузки  используется
;  INT 17h.
;
;   В качестве недостатков замечены следующие бяки :
;     1. Программа не работает на машинах, по "железу" не совместимые
;        с IBM (в основном это русские аналоги типа EC и "Поиск");
;     2. На CGA при передвижении таблицы по экрану идет довольно обиль-
;        ный снегопад;
;     3. Несовершенный алгоритм передвижения таблицы по  экрану, в ре-
;        зультате чего наблюдается неприятное мерцание таблицы.
;
;    Я буду рад, если Вы сможете как-то улучшить  программу  или  сможете
;  придумать к ней какую-нибудь новую прибирюльку.

	.model tiny
	.code
	org 100h

v_seg	equ	0B800h			;Сегмент экрана
	;Адреса переменных в PSP
buf	equ	128			;Средняя строка
uninst	equ	178			;Запрос о выгрузке
beg	equ	210			;Текущее значение начала таблицы
curs	equ	211			;Текущее значение маркера
col	equ	byte ptr [ds:212]	;Цвет
x	equ	213			;Координата X
y	equ	byte ptr [ds:214]	;Координата Y
hy	equ	byte ptr [ds:215]	;Высота таблицы
in_tsr	equ	216			;Флажок активации
saveseg	equ	word ptr [cs:217]	;Сеегмент буфера
saveofs	equ	word ptr [cs:219]	;Смещение буфера
decnum	equ	221			;Строка для преобразования
temp	equ	byte ptr [cs:100h]	;Код клавиши для повторения
v_ofs	equ	word ptr [cs:101h]	;Смещение текущей видеостраницы

start:	jmp stay

;***** Процедура обработки прерывания 17h ********
; Используется для определения загрузки в память и выгрузки.
int17:	cmp ax,'BY'
	je my1
	db	0EAh			;JMP на старый обработчик
ofs17	dw	0
seg17	dw	0

my1:	cmp bx,'ID'
	jne my2
	mov ax,'YE'
	mov bx,0105h
	iret
my2:	cmp bx,'RE'
	je my3
	iret
my3:	push ds
	push cs
	pop ds
	call un1
	pop ds
	iret

;***** Процедура обработки 9-го INT'а ************
int_vec:
	push ax
	in al,60h			;Сохраним байт из порта для повтора
	mov temp,al
	pop ax
	pushf				;Позовем старый INT
	db	9Ah
old1	dw	0
old2	dw	0
	cmp byte ptr [cs:in_tsr],1	;Проверка активности программы
	ja loop_key			;Если IN_TSR==2, то повтор клавиши
	jb int1				;Если 0, то активация
	iret				;Если 1, то выходим

;***** Процедура повторения клавиши **************
loop_key:
	cmp temp,1Ch			;Повтор, пока давят на ENTER
	je loop_key1
	mov byte ptr [cs:in_tsr],0	;Иначе конец повтора и к выходу
	iret

loop_key1:
	push ax cx
	mov ah,0			;Пропустим ENTER
	int 16h
	mov cl,byte ptr [cs:beg]	;Вычисление байта для повтора
	add cl,byte ptr [cs:curs]
	xor ch,ch			;В CX - полный код клавиши
	mov ah,5			;Помещаем в буфер клавиатуры
	int 16h
	pop cx ax
	iret

;***** Процедура обработки INT 9 *****************
int1:	inc byte ptr [cs:in_tsr]	;Поднимем флаг активации
	push ax
	cmp temp,35h			;Нажат ли '?'
	jne ext_int
	mov ah,2			;Проверим, может и Ctrl-Alt держат ?
	int 16h
	and al,12
	cmp al,12
	jne ext_int
	push ds
	push es
	push si
	push di
	push ax
	push bx
	push dx
	push cx
	mov ah,0Fh
	int 10h				;Проверяем видеорежим
	cmp al,3
	ja int4
	xor ax,ax			;Запомним смещение видеостраницы
	mov ds,ax
	mov ax,word ptr ds:[44Eh]
	mov v_ofs,ax

int3:	mov ah,1			;Очистка буфера клавиатуры
	int 16h
	jz int2
	mov ah,0
	int 16h
	jmp short int3

int2:	push cs
	push cs
	pop ds
	pop es
	call save_scr			;Положим часть экрана в буфер
	call pref			;Вызываем таблицу
	call restore_scr		;Восстанавливаем экран
int4:	pop cx
	pop dx
	pop bx
	pop ax
	pop di
	pop si
	pop es
	pop ds
ext_int:
	pop ax
	dec byte ptr [cs:in_tsr]	;Опустим флаг активации
	iret

;***** Процедура сохранения/восстановления экрана ******
restore_scr:
	inc cs:save4
	mov cs:save5,0
save_scr:
	push ds
	push es
	push ax
	push dx
	push cx
	mov dx,word ptr [ds:x]		;Вычисляем смещение по XY
	call xy_to_ofs
	mov si,dx			;SI - смещение в видеопамяти
	mov di,saveofs			;DI - смещение буфера
	mov ax,v_seg
	mov dx,saveseg
	db	0EBh			;Это команда JMP SHORT SAVE3
save5	db	3
	xchg ax,dx			;Если окно восстанавливается,
	xchg si,di			;меняем местами сегменты и смещения и
save3:	mov ds,ax
	mov es,dx
	mov cx,16
	mov dx,3DAh

save1:	push cx				;Длина одной строчечки
	mov cx,49

save2:	in al,dx			;Ждем, пока выпадет снег
	shr al,1
	jnc save2
	rep movsw

	pop cx
	db	83h
save4	db	0C6h,3Eh		;Здесь лежит команда add si,(80-49)*2
	loop save1

	mov cs:save4,0C6H
	mov cs:save5,3

	pop cx
	pop dx
	pop ax
	pop es
	pop ds

	ret

;***** Процедура работы таблицы ******************
pref:	mov dx,word ptr [ds:x]		;Выводим верх таблицы
	lea si,top
	mov cx,3
pref1:	push cx
	mov cl,col
	call write_str
	inc dh
	pop cx
	loop pref1

	add dh,hy			;И самую нижнюю строку
	mov cl,col
	call write_str

	call out_scr			;Теперь выводим среднюю часть

a0:	mov dx,word ptr [ds:x]		;Берем X и Y для вывода маркера
	inc dl
	add dh,3
	add dh,byte ptr [ds:curs]	;Прибавим к Y смещение курсора
	mov cx,41			;Длина маркера
	mov bl,112			;Цвет маркера
	call change_attr
	mov ah,0			;Заполучим клавишу
	int 16h
	push ax				;Вывод значения кода клавиши
	push dx
	push ds
	pop es

	mov cx,2			;Младший байт
	lea di,but+22
	mov dl,16
	call num_str

	mov al,ah			;Старший байт
	mov cx,2
	lea di,but+20
	call num_str

	lea si,but			;Выводим нижнюю строку с кодом клавиши
	mov dx,word ptr [ds:x]
	add dh,hy
	add dh,3
	mov cl,col
	call write_str

	pop dx				;Долой маркер !
	pop ax
	mov bl,col
	mov cx,41
	call change_attr

	cmp ax,011Bh			;Может, нажали ESC ?
	jne a1
	ret

a1:	cmp ah,50h			;Клавиша Down ?
	jne a2
	mov ah,2			;Проверим Shift'ы
	int 16h
	test al,3
	jnz a12				;Если без Shift'ов, маркер вниз
	mov al,hy
	dec al
	cmp byte ptr [ds:curs],al	;Маркер на нижней строке ?
	je a11
	inc byte ptr [ds:curs]		;Если нет, увеличим смещение
	jmp a0
a11:	inc byte ptr [ds:beg]		;Иначе сдвигаем строки вверх
	call out_scr
	jmp a0
a12:	mov al,25-4			;Проверим, не уперлась ли таблица
	sub al,hy			;в низ экрана ?
	cmp y,al
	jne a13
	jmp a0
a13:	call restore_scr		;Если нет, сдвигаем таблицу
	inc y
	call save_scr
	jmp pref

a2:	cmp ah,48h			;Клавиша Up
	jne a3
	mov ah,2			;Аналогично обработке DOWN
	int 16h
	test al,3
	jnz a22
	cmp byte ptr [ds:curs],0
	je a21
	dec byte ptr [ds:curs]
	jmp a0
a21:	dec byte ptr [ds:beg]
	call out_scr
	jmp a0
a22:	cmp y,0
	jne a23
	jmp a0
a23:	call restore_scr
	dec y
	call save_scr
	jmp pref

a3:	cmp ah,51h			;PgDn
	jne a4
	mov al,hy
	add byte ptr [ds:beg],al
	call out_scr
	jmp a0

a4:	cmp ah,49h			;PgUp
	jne a5
	mov al,hy
	sub byte ptr [ds:beg],al
	call out_scr
	jmp a0

a5:	cmp ah,47h			;Home
	jne a6
	mov byte ptr [ds:beg],0
	mov byte ptr [ds:curs],0
	call out_scr
	jmp a0

a6:	cmp ah,4Fh			;End
	jne a7
	mov byte ptr [ds:beg],255
	mov al,hy
	dec al
	sub byte ptr [ds:beg],al
	mov byte ptr [ds:curs],al
	call out_scr
	jmp a0

a7:	cmp ax,1C0Dh			;Enter
	jne a8
	mov cl,byte ptr [ds:beg]	;Вычисляем байт для вывода
	add cl,byte ptr [ds:curs]
	xor ch,ch
	mov ah,5
	int 16h
	mov byte ptr [ds:in_tsr],3	;Поставим флаг на повтор
	ret


a8:	cmp ah,4Bh			;Left
	jne a9				;Двинем таблицей по левому краю !
	cmp byte ptr [ds:x],0
	jne a81
	jmp a0
a81:	call restore_scr
	dec byte ptr [ds:x]
	call save_scr
	jmp pref

a9:	cmp ah,4Dh			;Rigth
	jne aa
	cmp byte ptr [ds:x],31
	jne a91
	jmp a0
a91:	call restore_scr
	inc byte ptr [ds:x]
	call save_scr
	jmp pref

aa:	cmp ah,53h			;Del
	jne ab
	push ax
	mov ah,3			;Берем курсор с экрана ...
	mov bh,0
	int 10h
	push dx				;... и положим его в стек
	mov si,uninst			;Выводим запрос
	mov dx,word ptr [ds:x]
	add dl,4
	add dh,hy
	add dh,3
	mov cl,112
	call write_str
	mov ah,2			;Устанавливаем курсор
	mov bh,0
	add dl,29
	int 10h

	mov ah,0			;Ищем клвишу Y
	int 16h
	cmp al,'y'
	je un
	cmp al,'Y'
	je un

	mov ah,2			;При любой другой клавише выходим
	pop dx
	int 10h
	pop ax
	jmp pref
	
un:	mov ah,2			;Восстанавливаем курсор
	pop dx
	int 10h
	pop ax
	call restore_scr
un1:	push ds
	mov dx,old1			;9-й вектор
	mov ax,old2
	mov ds,ax
	mov ax,2509h
	int 21h
	pop ds
	mov dx,ofs17			;17-й вектор
	mov ax,seg17
	mov ds,ax
	mov ax,2517h
	int 21h
	push ds
	push cs
	pop es
	mov ah,49h			;Освобождаем память
	int 21h
	pop ds
	ret

ab:	cmp ax,1C0Ah			;Ctrl-Enter
	jne ac
	mov al,byte ptr [ds:beg]
	add al,byte ptr [ds:curs]
	call make_str
	xor bh,bh
	mov bl,al
	mov si,buf+5
	mov cx,3
ab1:	lodsb
	cmp al,' '
	je ab2
	mov bl,al
	xchg cx,bx
	mov ah,5
	int 16h
	xchg cx,bx
ab2:	loop ab1
	ret

ac:	cmp ax,4E2Bh			;Правый +
	jne ad
	cmp hy,12
	je ac1
	inc hy
	mov al,hy
	add al,y
	cmp al,22
	jne ac2
	call restore_scr
	dec y
	jmp short ac3
ac2:	call restore_scr
ac3:	call save_scr
	jmp pref
ac1:	jmp a0

ad:	cmp ax,4A2Dh			;Правый -
	jne ae
	cmp hy,1
	je ad1
	dec hy
	call restore_scr
	call save_scr
	mov al,byte ptr [ds:curs]
	cmp al,hy
	jne ad2
	inc byte ptr [ds:beg]
	dec byte ptr [ds:curs]
ad2:	jmp pref
ad1:	jmp a0

ae:	cmp ah,52h			;INS
	jne a
	mov al,byte ptr [ds:beg]
	add al,byte ptr [ds:curs]
	mov col,al
	jmp pref

a:	cmp al,0			;Любая другая клавиша
	jne a_1
	mov al,ah
a_1:	mov byte ptr [ds:beg],al
	mov byte ptr [ds:curs],0
	call out_scr
	jmp a0

;***** Процедура вывода таблицы на экран *********
out_scr:
	mov al,byte ptr [ds:beg]
	mov cl,hy				;Кол-во строк для вывода
	xor ch,ch
	mov dx,word ptr [ds:x]
	add dh,3
scr1:	push cx
	call make_str				;Формируем строку
	mov si,buf
	mov cl,col
	call write_str				;Пишем строку
	push dx
	mov cx,5
	mov bl,al
	mov dl,byte ptr [ds:x]
	add dl,43
	call change_attr			;Меняем аттрибуты
	pop dx
	inc dh
	inc al
	pop cx
	loop scr1
	ret

;***** Процедура, формирующая строку для вывода **
make_str:
	push dx
	push di
	push ax
	mov di,buf
	mov [di+2],al
	cmp al,0			;0 заменяем пробелом
	jne make2
	mov byte ptr [di+2],' '

make2:	add di,7			;Десятичное значение
	mov dl,10
	mov cx,3
	call num_str
	mov cx,2
	push di
make4:	inc di
	cmp byte ptr [di],'0'		;Убираем первые нули
	jne make3
	mov byte ptr [di],' '
	loop make4

make3:	pop di
	add di,7			;16р. значение
	mov dl,16
	mov cx,2
	call num_str

	mov dl,2			;Двоичное значение
	mov cx,8
	add di,12
	call num_str

	mov dl,8			;Восьмеричное значение
	mov cx,3
	add di,13
	call num_str

	push ax				;Цвет переднего плана
	and al,15
	mov cl,6
	mul cl
	lea si,colors
	add si,ax
	mov di,buf+29
	movsw
	movsw
	movsw
	pop ax

	push ax				;Цвет заднего плана
	mov cl,4
	shr al,cl
	and al,7
	mov cl,6
	mul cl
	lea si,colors
	add si,ax
	mov di,buf+36
	movsw
	movsw
	movsw
	pop ax

make0:
	pop ax
	pop di
	pop dx
	ret

;***** Процедура преобразования числа в строку ***
; AL - число
; DL - делитель (1..16)
; CX - длина строки
; DS:DI  - указатель на конец строки
num_str:
	push ax
	xor bh,bh
num1:	xor ah,ah			;Делим на делитель
	div dl
	mov bl,ah
	mov ah,decnum[bx]		;Преобразуем в ASCII-символ
	mov byte ptr [di],ah		;Сохраняем в строке
	dec di
	loop num1
	pop ax
	ret


;***** Процедура вывода ASCIIZ-строки на экран ***
; DS:SI - строка
; CL - цвет
; DL - x
; DH - y
write_str:
	push dx
	call xy_to_ofs			;Вычисляем смещение
	mov di,dx
	push cx
	push ax
	push es
	mov dx,v_seg			;Загружаем сегменты
	mov es,dx
	mov dx,3DAh
wr_str3:
	lodsb				;Берем байтик строки
	cmp al,0			;Проверим на конец строки
	je wr_str1
	mov ah,al
wr_str2:
	in al,dx			;Ждем снег
	shr al,1
	jnc wr_str2
	mov al,ah
	mov ah,cl
	stosw				;Пишем байт
	jmp short wr_str3
wr_str1:
	pop es
	pop ax
	pop cx
	pop dx
	ret

;***** Процедура смены цветовых аттрибутов *******
; CX - длина
; BL - новый цвет
; DL - X
; DH - Y
change_attr:
	push dx
	push es
	push di
	push ax
	call xy_to_ofs			;Вычисляем смещение
	mov di,dx
	mov ax,v_seg
	mov es,ax
	mov dx,3DAh
cng_attr2:
	in al,dx			;Ждем снег
	shr al,1
	jnc cng_attr2
	inc di
	mov es:[di],bl
	inc di
	loop cng_attr2

	pop ax
	pop di
	pop es
	pop dx
	ret

;***** Процедура преобразования координат в смещение ***
; DL - X
; DH - Y
; Возврат : DX - смещение
xy_to_ofs:
	push ax
	mov ax,80
	mul dh
	xor dh,dh
	add dx,ax
	shl dx,1
	pop ax
	add dx,v_ofs
	ret

;*** Данные, остающиеся в резиденте **************

colors	db	'ЧерныйСиний Зелен.Циан  Красн.ФиолетКоричнБелый '
	db	'Серый Голуб.Св-ЗелСвЦианСвКрасСвФиолЖелтыйЯркБел'
top	db	'╔═ BYTE V1.5 (C) SEEM Group, 1993 ═╤══════╤═════╗',0
	db	'║Смв│Дес│Шест│Двоичный│Восьм│ПерПлн│ЗаднПл│Цвет ║',0
	db	'╟───┼───┼────┼────────┼─────┼──────┼──────┼─────╢',0
but	db	'╚═══ Код клавиши : 0000h ═══╧══════╧══════╧═════╝',0

;*** Данные, пересылаемые в PSP ******************
mov_dat	db	'║   │   │    │        │     │      │      │ *** ║',0
	db	' Выгрузить из памяти (Y/N) ?   ',0
	db	0		;Начало таблицы
	db	0		;Значение маркера
	db	62		;Цвет
	db	14		;X
	db	5		;Y
	db	10		;Высота
	db	0		;Флаг TSR
	dw	0BF00h		;Сегмент буфера
	dw	0		;Смещение буфера
	db	'0123456789ABCDEF'

;*************************************************
;*** Установочная часть **************************

stay:	call param			;Разбираем параметры командной строки

	mov di,80h			;Пересылка данных в конец PSP
	lea si,mov_dat
	mov cx,128
	rep movsb

	lea di,tempbuf+68		;Установка CR,LF и $ для tempbuf
	mov ax,0D0Ah
	stosw
	mov ax,24h
	stosb

	call copyrigth			;Вывод верхней части сообщения

	test stat,4			;Есть ошибка в параметрах ?
	jz stay20			;Нет, продолжим

	mov bx,'╟╢'			;Выводим среднюю часть
	mov dl,'─'
	call tempms
	lea dx,err_p			;Выводим сообщение об ошибке
	mov ah,9
	int 21h
	call endmsg			;Выводим последнюю строку
	int 20h

stay20:	test stat,2			;Нужно выгрузить из памяти ?
	jz stay30

	mov bx,'╟╢'			;Средняя строка
	mov dl,'─'
	call tempms

	mov ax,'BY'			;Проверяем наличие в памяти
	mov bx,'ID'
	int 17h
	cmp ax,'YE'
	jne stay22

	mov ax,'BY'			;Функция выгрузки из памяти
	mov bx,'RE'
	int 17h
	lea dx,tw
	jmp short stay21

stay22:	lea dx,err_w			;Таблицы нет в памяти

stay21:
	mov ah,9
	int 21h
	call helper
	call endmsg
	int 20h

stay30:	mov ax,3509h			;Берем старый вектор 9
	int 21h
	mov old1,bx			;На всякий случай возьмем Seg:Ofs
	mov old2,es

	mov ax,'BY'			;Сидим в резиденте ?
	mov bx,'ID'
	int 17h
	cmp ax,'YE'
	jne stay1			;Нет, идем на установку

	mov bx,'╟╢'			;Выводим среднюю строку
	mov dl,'─'
	call tempms

	lea dx,alr			;Сообщаем, что больше не будем
	mov ah,9
	int 21h

	call helper			;Выводим HELP

	call endmsg			;Нижняя строка

	int 20h

stay1:	mov ax,2509h			;Нас нет в резиденте, остаемся
	lea dx,int_vec
	int 21h

	mov ax,3517h			;Получаем 17 вектор
	int 21h
	mov ofs17,bx
	mov seg17,es

	mov ax,2517h			;Перехват 17-го
	lea dx,int17
	int 21h

	mov bx,'╟╢'			;Средняя часть
	mov dl,'─'
	call tempms

	lea dx,ok			;Сообщение об установке
	mov ah,9
	int 21h

	call helper

	call endmsg			;Нижняя строка			

	lea dx,mov_dat			;Конец резидента
	test stat,8			;Нужен внутреенний буфер ?
	jz stay10
	mov saveseg,cs
	mov saveofs,dx
	add dx,49*16*2			;Резервируем буфер

stay10:
	int 27h				;Я - TSR !

;***** Вывод последней строки ********************
endmsg:
	mov bx,'╚╝'
	mov dl,'═'
	call tempms
	ret

;***** Разбор параметров *************************
param:
	mov si,80h
	lodsb
	cmp al,0
	jne param0			;Нет параметров, выходим
	ret

param0:
	lodsb
	cmp al,13
	je param4
	cmp al,'z'
	ja param0
	cmp al,'a'
	jb param0
	sub byte ptr [si-1],32
	jmp short param0

param4:
	mov si,81h

param1:
	lodsb				;Пропускаем пробелы
	cmp al,' '
	je param1
	cmp al,13
	jne param2
	ret
param2:
	cmp al,'/'			;Начало ключа
	jne par_err
	lodsb

	cmp al,'?'
	jne param3
	or stat,1
	jmp short param1

param3:
	cmp al,'U'
	jne param5
	or stat,2
	jmp short param1

param5:
	cmp al,'B'
	jne par_err
	or stat,8
	jmp short param1

par_err:
	or stat,4			;Устанавливаем бит ошибки
	ret

;************************************
copyrigth:
	mov bx,'╔╗'			;Верхняя часть
	mov dl,'═'
	call tempms
	lea dx,copyr
	mov ah,9
	int 21h
	ret

;************************************
helper:
	test stat,1			;Нужен HELP ?
	jnz helper1
	ret
helper1:
	mov bx,'╟╢'			;Средняя линия
	mov dl,'─'
	call tempms
	lea dx,help			;Текст
	mov ah,9
	int 21h
	ret

;***** Процедура вывода линии ********************
; bh - символ начала
; bl - символ конца
; dl - середина
tempms:
	push cs
	pop es
	lea di,tempbuf
	mov al,bh
	stosb
	mov al,dl
	mov ah,dl
	mov cx,33
	rep stosw
	mov al,bl
	stosb
	lea dx,tempbuf
	mov ah,9
	int 21h
	ret

stat	db	0			;Байт состояния

copyr	db	'║ BYTE V1.5 (C) Copyright SEEM Group, 1993.			   ║',13,10
	db	'║ Потапкин Р.С., тел(дом) (095) 408-77-21			   ║',13,10,'$'
ok	db	'║ Таблица загружена. Вызов по Ctrl-Alt-?. Справка - BYTE /?	   ║',13,10,'$'
err_p	db	'║ Указаны неверные параметры. Справка - BYTE /?			   ║',13,10,'$'
tw	db	'║ Таблица выгружена.						   ║',13,10,'$'
err_w	db	'║ Таблицы нет в памяти.						   ║',13,10,'$'
help	db	'║ Вызов : BYTE [/B][/U][/?]					   ║',13,10
	db	'║   /B - использовать внутренний буфер;				   ║',13,10
	db	'║   /U - выгрузить из памяти;					   ║',13,10
	db	'║   /? - эта помощь.						   ║',13,10
	db	'║ Управление :							   ║',13,10
	db	'║   Up, Down, PgUp, PgDn, Home и End - перемещение по таблице;     ║',13,10
	db	'║   Shift + <Клавиши курсора> - перемещение таблицы по экрану;     ║',13,10
	db	'║   "Серые" плюс и минус - изменение размера таблицы;		   ║',13,10
	db	'║   INS - изменение цвета на текущий;				   ║',13,10
	db	'║   Enter - перенос символа на экран ( для повтора символа не      ║',13,10
	db	'║   отпускайте Enter );						   ║',13,10
	db	'║   Ctrl-Enter - перенос на экран десятичного значения;		   ║',13,10
	db	'║   Del - удаление из памяти.					   ║',13,10,'$'
alr	db	'║ Таблица уже загружена. Вызов по Ctrl-Alt-?. Справка - BYTE /?    ║',13,10,'$'
tempbuf	db	0

end start
