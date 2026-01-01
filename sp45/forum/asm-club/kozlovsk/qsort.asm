;; Quick sort algorithm . Алгоритм быстрой сортировки .
;; ( Developed by C.A.R.Hoar )

;; Пример использования макроопределений структурного
;; программирования для сортировки символьной строки.
;; Юрий Козловский. 272630  г.Измаил. Тимирязева,9
;; 01-11-90.

cr	equ	0dh			;Возврат каретки
lf	equ	0ah			;Перевод строки
max	equ	40			;Максимальное число символов в строке
					;для сортировки

;; Порядок расположения параметров сортировки в стеке

right	equ	word ptr [bp+8] 	;Правый конец строки
left	equ	word ptr [bp+6] 	;Левый конец строки
base	equ	word ptr [bp+4] 	;Адрес первого элемента строки

;; Адреса элементов строки с которыми происходит сравнение

itemdi	equ	byte ptr [bx+di]	;По убыванию
itemsi	equ	byte ptr [bx+si]	;По возрастанию

;; Используемые макроопределения

;Сохранить регистры
push_regs	macro	reg_list
	irp	reg,<reg_list>
	push	reg
	endm
endm
;Восстановить регистры
pop_regs       macro   reg_list
	irp	reg,<reg_list>
	pop    reg
	endm
endm
;Выдать сообщение на экран с текущей позиции курсора
message 	macro msg
	mov	ah,09h
	lea	dx,ds:msg
	int	DOS
endm


.XLIST
include struc.mlb			;Подключить структурную макробиблиотеку
.LIST

code	segment  'CODE'
code	ends
data	segment  'DATAS'
data	ends
stack	segment para stack 'STACK'
stack	ends


data	segment
msg	db	cr,lf,'Введите строку для сортировки:',cr,lf,'$'
str	db	max,00h 			;Max,Len
inp	db	max dup(?)			;Буфер ввода
msg1	db	cr,lf,'Отсортированная строка:',cr,lf,'$'
data	ends
stack	segment
	dw	100h  dup(0)
stack	ends

code	segment
assume	cs:code,ds:data,ss:stack,es:nothing
main	proc far
start:
	push	ds			;Адрес возврата в DOS
	xor	ax,ax
	push	ax
	mov	ax,seg data
	mov	ds,ax
;
	mov	ah,09h			;Запрос на ввод строки для сортировки
	lea	dx,ds:msg
	int	21h

	mov	ah,0ah			;Чтение строки с клавиатуры
	lea	dx,ds:str
	int	21h

	lea	bx,ds:inp		;Получить адрес начала буфера ввода
	xor	ax,ax
	mov	al,byte ptr [bx-1]	;Длина полученной строки
	dec	ax			;Длина-1  (для сортировки)
;	Передача параметров
	push	ax			;Длина -1 (начальное right)
	xor	ax,ax			;
	push	ax			;0	  (начальное left)
	push	bx			;Указатель на первый символ строки
					;для сортировки.
	call	quick_sort		;Сортировка строки
	add	sp,6			;Подстройка стека на 3 параметра

	mov	ah,09h			;Сообщение о б отсортированной строке
	lea	dx,ds:msg1
	int	21h

;Выдать на дисплей отсортированную строку (при вводе она заканчивается
; кодом возврата каретки).
	cld
	lea	si,ds:inp
	xor	ax,ax
while	al ne cr			;Пока не конец строки.
	mov	ah,0eh
	lodsb
	int	10h
endwh
;
	ret
main	endp

quick_sort proc near
;     push right
;     push left
;     push base
;     call quick_sort
;     add  sp,6

	push	bp
	mov	bp,sp
	push_regs <cx,dx>
	mov	bx,base 		;Адрес начала строки
	mov	cx,left 		;Номер левого символа
	mov	dx,right		;Номер правого символа

	xor	ax,ax
	mov	al,dl			;  ah=item((left+right)/2)
	add	al,cl			;  Нахождение "среднего"
	shr	ax,1			;  элемента строки и помещение
	mov	si,ax			;  его в ah.
	mov	ah,itemsi

do
; until dx b cx 			;Пока левый номер меньше правого
;

	;; Нахождение символов строки для перестановки
		   mov di,cx
	while$and <cx,itemdi>,<b,b>,<right,ah>	;Пока левый номер меньше
		   inc cx			;правой границы и символ строки
		   inc di			;с этим номером меньше "среднего"
	endwh					;переходим к следующему символу.

		   mov si,dx
	while$and   <dx,ah>,<a,b>,<left,itemsi> ;Пока правый номер больше
						;левой границы и символ строки
		   dec dx			;с этим номером больше "среднего"
		   dec si			;переходим к следующему символу.
	endwh


	if$	cx be dx		;Если левый номер меньше или равен провому
		push ax
		mov al,itemdi		;произвести перестановку
		mov ah,itemsi
		mov itemsi,al
		mov itemdi,ah
		pop ax
		dec dx			;перейти к следующей паре
		inc cx			;
	endif$

Until dx b cx

	if$ left b dx			;Если левая граница меньше или равна
		push dx 		;правого номера, то сортируем левую
		push left		;часть строки.
		push base

		call quick_sort
		add  sp,6
	endif$
	if$	cx b right		;Если левый  номер меньше
		push right		;правой границы, то сортируем правую
		push cx 		;часть строки.
		push base

		call quick_sort
		add  sp,6
	 endif$
	pop_regs <dx,cx>
	pop	bp
	ret
quick_sort endp

code	ends
	end	start
