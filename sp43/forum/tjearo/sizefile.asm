		title	'Длина файла DOS в Foxbase+'
.286c
code_seg_a	segment
		assume	cs:code_seg_a, ds:code_seg_a
		org	0
sizefile	proc	far
start:
		cmp	bx,00h			; bx = 0
		jz	err_parm		; параметров нет
		cmp	byte ptr ds:[bx],00h	; длина:NULL
		jz	err_parm
		mov	cx,4
		push	bx
eol:		cmp	byte ptr ds:[bx],00h	; EOL ?
		jz	err_len
		inc	bx
		loop	eol
		pop	bx
		jmp	short	open_file
err_parm:	mov	ah,02h			; сигнал на дисплей
		mov	dl,07h			; сигнал
		int	21h			; функции DOS
		ret				; выход
open_file:	push	bx			; сохранить адрес строки параметров
		mov	ah,3dh			; открыть описатель файла
		mov	dx,bx			; адрес строки ACSIIZ с именем файла
		mov	al,0h			; режим открытия по чтению
		int	21h			; вызов функции DOS
		jnc	handle_exits		; ошибка - файл не найден
err_file:	pop	bx			; восстан.адрес парам.
;		mov	ah,'n'
		mov	byte ptr ds:[bx],'n'	; сообщение в программу:'файл не найден'
		ret
handle_exits:					; файл найден
						; описатель файла создан в AX
		mov	bx,ax			; описат.файла в BX
		push	bx
		mov	ah,42h			; функция DOS LSEEK
		mov	al,02h			; переместить указатель в конец файла
		xor	cx,cx			; очистим CX
		xor	dx,dx			; очистим DX
		int	21h			; вызвать функцию DOS
		jc	err_file		; если ошибка - выход
		pop	bx			; описат.файла
		push	dx
		push	ax
		mov	ah,3eh			; закрыть файл
		int	21h			; функция DOS
		pop	ax			; в DX:AX длина файла =
		pop	dx			; (DX * 65536) + AX
		pop	bx			; восстан.адрес строки парам.
		mov	ds:[bx],dx		; запись DX
		mov	ds:[bx]+2,ax		; запись AX
		ret
err_len:	pop	bx
		mov	byte ptr ds:[bx],'*'	; результат не вошел в строку
		ret
copy_right	db	'SizeFile Fox+ КБ Исеть Тэаро А.Р.'
sizefile	endp
code_seg_a	ends
		end	start
