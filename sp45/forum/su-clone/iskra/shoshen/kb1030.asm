Comment * 12.12.90

	──────────────────────────────────────────────────────────────
	KB1030.ASM
	Драйвер клавиатуры ППЭВМ "Искра 1030.11"
				    Д.В.Шошенков
		            тел. (095) 272.25.35
	──────────────────────────────────────────────────────────────

	Допускает генерацию файла типа .COM. (При использовании Turbo-
	Assembler файл .OBJ следует линковать с ключем /t) *


	.MODEL	TINY		;64K
        .CODE                   ;assume cs: code, ds: code
        .SALL                   ;запpет pасшиpения macro в листинге

stderr	equ 2			;стандартное устройство сообщений об ошибках
stdout	equ 1			;стандартное устройство вывода
RusCol  equ 3                   ;выделение обрамления зеленым (серым)
LatCol  equ 0                   ;нормальное обрамление (черное)
ColMask equ 00100000b           ;альтернативная таблица + зеленый фон графики
TabMask equ 00000110b           ;альтернативная таблица + черный фон графики
Bed	equ 3Ch			;смещение начала резидентной части
ChkSum  equ 0D895h              ;контрольная сумма

output  macro what		;вывод на экран
        mov dx, offset what
        int 21h
        endm

Invert  macro what, mask        ;инвертировать бит, заданный маской
        local zero, quit
        test what, mask
	jz zero
        sub what, mask
        jmp short quit
zero:   add what, mask
quit:   endm

INTA	macro			;подтверждение прерывания
	in al, 61h		;прочитать регистр управления 
	or al, 10000000b	;установить его 7-й бит (enable kbd)
	out 61h, al		;записать его в тот же порт
	and al, 01111111b	;(опять) сбросить этот бит
	out 61h, al		;записать его в тот же порт
	endm

EOI     macro                	;конец аппаратного прерывания
        mov al, 20h
	out 20h, al
	endm

        org 0                   ;Переменная режимов размещается в ПСП
ScrMode db ?
        org 80h
leng    db ?                    ;Длина командной строки
	org 100h		;устанавливаем IP на конец PSP
begin:	jmp setup		;необходим для генеации файла типа .COM (?)

	;Резидентная часть драйвера Kb1030

	;Обработчик прерывания INT 09
bottom  equ $			;смещение начала драйвера
new09	proc far		;точка входа для INT 09
        push ax bx ds
	mov ax, 40h		;устанавливаем сегмнтный регистр DS на
	mov ds, ax		;область переменных BIOS 0040:0000
        mov bx, 18h		;второй байт статуса клавиатуры
	in al, 60h		;читаем порт клавиатуры
presence label word		;метка присутствия драйвера в ОЗУ
	cmp al, 7Fh             ;нажата клавиша 127 ?
	je nolock
        cmp al, 0FFh            ;отпущена клавиша 127 ?
	je nolock
    	cmp al, 5Ah             ;нажата клавиша 'Р/Л' ?
        je lock1
        jmp short tabs
nolock: mov ah, [bx]            ;AH = второй байт статуса клавиатуры
        Invert ah, 1            ;инвертируем его нулевой бит (режим рус/лат)
        mov [bx], ah		;записываем в область BIOS
lock1:  call Int09              ;оригинальное INT 09
        Invert cs:ScrMode, ColMask ;инвертируем бит цвета
	mov ah, 0Fh             ;определяем режим дисплея
        int 10h
        cmp al, 4
        jl text
        cmp al, 6
        jg text
        jmp short common
text:   call Border             ;окраска обрамления - только в текстовом
common: call MkScr              ;установка цвета фона
        pop ds bx ax
        iret
tabs:   cmp al, 62h		;нажата клавиша '─>' ?
        je fast
        cmp al, 5		;нажата клавиша > '4' ?
        jg usual
        cmp al, 2               ;нажата клавиша < '1' ?
        jl usual
        test byte ptr[bx-1], 00001000b ;нажата клавиша Аlt ?
        jz usual
        test byte ptr[bx-1], 00000100b ;нажата клавиша Ctrl ?
        jz usual
        push ax
        INTA
        pop ax
        sub al, 2               ;преобразовать скэн-код в номер таблицы:
        shl al, 1		;0 - осн., 2 - альт., 4 - болг. ...
        call SetTab		;установить номер таблицы в ScrМode
        call MkScr		;поменять таблицу на экране
        pop ds bx
        EOI
        pop ax
        iret
	;Быстрое переключение кодовых таблиц
fast:   call Int09
	cli
        mov al, cs:ScrMode
        and al, TabMask         ;выделить из ScrMode текущую таблицу
        cmp al, 2               ;она альтернативная ?
        je mkmain
        mov al, 2		;установить альтернативную кодировку
        jmp short setit
mkmain: xor al, al              ;установить основную кодировку
setit:  call SetTab
        jmp short common
usual:  cli			;запpетить обаботку новых нажатий клавиатуpы
	push si
	mov bx, 1Ch		;BX = адрес хвоста буфера = адрес
	mov si, [bx]		;SI = адpес свободной ячейки буфеpа, в котоpую
        call Int09
        cli			;подтвердить запрет прерываний
	mov ax, [si]		;AX = последняя введенная клавиша: scan-ascii
	cmp ah, 0		;если символ получен Alt-вводом, его
	je nocod		;пеpекодиpовка не тpебуется
	cmp al, 0B0h		;выделяем символы, находящиеся в
	jb nocod		;тpех колонках кодовой таблицы - B0, C0, D0,
        mov bl, cs:ScrMode
        and bl, TabMask         ;BL = текущая таблица
        cmp bl, 2               ;альтернативная ?
        jne other
        cmp al, 0DFh            ;т.е. символы от B0h до DFh и уменьшаем их
	jg nocod		;ascii-код на 30h, т.е.
        jmp short cod
other:  cmp bl, 4               ;болгарская ?
        jne nocod
        cmp al, 0EFh		;т.е. символы от B0h до DFh
        jg nocod
cod:    sub al, 30h             ;сдвигаем символ на 3 колонки влево
nocod:				;перекодировка не нужна для осн. и четвертой
	;коррекция для раздельных клавиш
	cmp al, 0		;сравниваем ASCII-код с нулем
	je skip 		;для 'расширенных' кодов коррекция не нужна
	cmp ah, 54h		;сравниваем скэн-код с 54h
	jb skip 		;для совмещенных клавиш коррекция не нужна
        xor ah, ah              ;для раздельных клавиш обнулить скэн-код
skip:				;коррекция не нужна
	mov [si], ax		;помещаем новый код назад в буфер
	sti			;pабота с буфеpом BIOS закончена
        pop si ds bx ax
        iret

new09   endp

Int09   proc near 		;дальний вызов оригинального INT 09
        pushf                   ;для iret в INT 09
        db 9Ah
old9o   dw 0
old9s   dw 0
        ;popf			;осуществляется командой iret в INT 09
        ret
Int09   endp

Border  proc near		;окрашивание обрамления экрана в цвет
        test byte ptr cs:ScrMode, ColMask	;текущего режима
        jz lat
        mov bl, RusCol
        jmp short doit
lat:    mov bl, LatCol
doit:   mov ah, 0Bh
        mov bh, 0
        call int10
        ret
Border  endp

SetTab  proc near		;устанавливает номер таблицы в ScrMode
        and cs:ScrMode, 11111001b
        or cs:ScrMode, al
        ret
SetTab  endp

MkScr   proc near		;устанавливает кодовую таблицу для экрана и
        push dx			;цвет фона в графическом режиме
        mov al, cs:ScrMode
        mov dx, 3DEh		;порт регистра подрежимов МОИ
        out dx, al
        pop dx
        ret
MkScr   endp
top9    equ $

	;Обработчик прерывания INT 10:
	;отслеживает переход из графического режима в текстовый и при
	;необходимости подсвечивает обрамление экрана
new10   proc far
        pushf
	cmp ah, 10h		;10-я ф-ция ? (EGA)
	je exit10		;да - выход
        cmp ah, 0		;функция смены режимов ?
        jne do10
        cmp al, 4
        jl text10
        cmp al, 6
        jg text10
do10:   call Int10		;графический режим - ничего
exit10: popf
        iret
text10: call Int10              ;текстовый - вызвать оригинальное INT 10
        push ax bx
        call Border		;и окрасить обрамление в цвет текущего
        pop bx ax		;режима
        jmp short exit10
new10   endp

Int10   proc near		;дальний вызов оригинального INT 10
        pushf
        db 9Ah
old10o  dw 0
old10s  dw 0
        ;popf
        ret
Int10   endp
top     equ $

        ;Установка драйвера Kb1030

setup:  ;Проверка контрольной суммы сообщения
        xor ax, ax
        mov cx, msglen
        mov bx, ax              ;вычисление контрольной суммы
smm:    add ax, contr[bx]
        inc bx
        loop smm
        cmp ax, ChkSum
        je ok
        jmp exit
ok:     ;Проверка наличия драйвера в памяти
        mov ax, 3509h           ;получаем вектор оригинального INT 09
	int 21h			;в ES:BX
disp equ offset presence - bottom ;смещение до метки присутствия
        mov ax, es:[bx+disp]    ;AX = первое слово, программы INT 09 в ОЗУ
        cmp ax, presence
        jne load
        jmp already             ;eсли одинаковы - драйвер уже загружен
        ;Проверка ключей командной строки
load:   push es
	mov ax, cs              ;восстановить ES
        mov es, ax
        mov di, 81h             ;DI = начало командной строки
        cld
        mov al, '/'		;ищем символ-разделитель ключей
        xor cx, cx
        mov cl, leng
        repne scasb
        jcxz setalt		;ключей нет - установим альтернативную
        mov al, [di]            ;ключ найден
        cmp al, 'm'             ;выбор действия
        je setmn
        cmp al, 'M'
        je setmn
        cmp al, '1'
        je setmn
        cmp al, 'a'
        je setalt
        cmp al, 'A'
        je setalt
        cmp al, '2'
        je setalt
        cmp al, 'b'
        je setbul
        cmp al, 'B'
        je setbul
        cmp al, '3'
        je setbul
        cmp al, 'k'
        je setkoi
        cmp al, 'K'
        je setkoi
        cmp al, '4'
        je setkoi
unknow: mov ah, 9        	;неизвестный ключ
        output titl
        output unknsw
        output switch
        output lin
        jmp exit
setmn:  mov ScrMode, 0          ;установить основную кодировку
        jmp short go_on
setkoi: mov ScrMode, 00000110b  ;установка четвертой таблицы
        jmp short go_on
setbul: mov ScrMode, 00000100b	;установка болгарской таблицы
        jmp short go_on
setalt: mov ScrMode, 00000010b  ;установка альтернативной таблицы
go_on:  call MkScr
        pop es                  ;восстановить ES для модификации адресов
        ;Установка программы для обработки INT 09
	cli			;запрет маскируемых прерываний и
	mov old9o, bx		;модификация кода программы: установка
	mov old9s, es		;смещения и сегмента для CALL в new09
        mov ax, 3510h		;опредеить вектор INT 10
        int 21h
        cli
        mov old10o, bx		;установить его в программе
        mov old10s, es
	;Сдвиг кода драйвера "вниз" в PSP на адрес Bed
	mov ax, cs              ;ES = CS
        mov es, ax
        mov di, Bed             ;Адрес назначения = Bed
        mov si, offset new09	;откуда
full_size equ top - bottom      ;размер всей резидентной части драйвера
        mov cx, full_size
        cld
        rep movsb		;перенос
        mov dx, Bed
        mov ax, 2509h           ;установить вектор 09 на Bed
        int 21h
int9_size equ top9 - bottom	;размер обработчика INT 09
int9_last equ Bed + int9_size   ;смещение последнего байта обработчика 09
        mov dx, int9_last
        mov ax, 2510h
        int 21h
        sti
        mov ah, 9
        output titl
        output msg
        output lin
kb1030_last equ Bed + full_size	;смещение последнего байта драйвера после
        mov dx, kb1030_last	;сдвига вниз
        mov cl, 4
        shr dx, cl
        inc dx
        mov ax, 3100h
        int 21h
	;Завершение программы без установки драйвера
already:mov ah, 9
        output titl
        output error
        output switch
        output lin
exit:   mov ax, 4C01h
        int 21h
	;Тексты сообщений
contr   label word
titl    db '───KB1030.1'
        db 29 dup ('─'), 10, 13, 24h
msg     db 'Дpайвеp клавиатуры ППЭВМ "Искpа 1030.11"', 10, 13
        db 24 dup (32), 'Дмитрий Шошенков', 10, 13
        db 20 dup (32), 'тел. (095) 272.25.35', 10, 13, 24h
msglen  equ $ - titl
lin     db 40 dup ('─'), 10, 13, 24h
error   db 'Драйвер клавиатуры KB1030 уже установлен', 10, 10, 13, 24h
unknsw  db '          * Неизвестный ключ *',10, 13, 24h
switch  db 'Для начальной установки кодовой таблицы', 10, 13
        db 'используйте ключи:', 10, 13
        db '  /m или /1 - "основная" кодировка', 10, 13
        db '  /a или /2 - "альтернативная" кодировка', 10, 13
        db '              (выбирается по умолчанию)', 10, 13
        db '  /b или /3 - "болгарская" кодировка', 10, 13
        db '  /k или /4 - четвертая кодовая таблица', 10, 13, 24h

	;code ends - обеспечивается диpективой .CODE
	end begin