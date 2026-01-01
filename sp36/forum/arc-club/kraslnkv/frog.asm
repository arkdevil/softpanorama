; "Лягушка" - программа, которая сначала прыгает по памяти,
; потом распаковывает данные и наконец запускает полученный код
; Адаптация (C) Красильников 1991

CODE	SEGMENT	PARA	PUBLIC	'CODE'
	ASSUME CS:CODE,DS:CODE
	ORG	100H
begin:
				; Следующие две константы настраиваются
				; по длине сжатого и исходного файлов:
		mov	ax,0	; mem = исх.длина + длина кода + 200h
		mov	dx,0	; len - точная длина data
		cmp	sp,ax
		jae	memok

	        mov     ah,09h          ; функция вывода строки
		mov	dx,offset nomemsg
	        int     21h             ; выведем сообщение
err_exit:
	        mov     ax,4C01h        ; и завершим работу
	        int     21h             ; с кодом ошибки 1

memok:
		mov	bx,sp
		sub	bx,(offset data - offset go + 10h)
		and	bx,0FFF0h
		cld			; перенос кода
		mov	si,offset go
		mov	di,bx
		mov	cx,(offset data - offset go)
		rep	movsb

		mov	ax,bx
		mov	cl,4
		shr	ax,cl
		mov	cx,cs
		add	ax,cx		; новое значение CS
		push	ax
		xor	ax,ax
		push	ax
		retf			; Переход на CS:0

; Здесь начинается выполнения после retf (уже после перемещения кода)
go:
		std			; Перенос сжатых данных
		mov	di,bx
		dec	di
		add	si,dx
		dec	si
		mov	cx,dx
		rep	movsb

; Настройка и разжатие данных в памяти
		cld
		mov	si,di
		inc	si
		mov	di,100h
		mov	dx,10h
		lodsw
		mov	bp,ax
decompr_loop:
		shr	bp,1
		dec	dx
                jnz     buffer_not_empty
		lodsw
		mov	bp,ax
		mov	dl,10h
buffer_not_empty:
                jnc     expand_string

		movsb

                jmp     short decompr_loop
expand_string:
		xor	cx,cx
		shr	bp,1
		dec	dx
                jnz     buffer_not_empty2
		lodsw
		mov	bp,ax
		mov	dl,10h
buffer_not_empty2:
                jc      long_pointer
		shr	bp,1
		dec	dx
                jnz     buffer_not_empty3
		lodsw
		mov	bp,ax
		mov	dl,10h
buffer_not_empty3:
		rcl	cx,1
		shr	bp,1
		dec	dx
                jnz     buffer_not_empty4
		lodsw
		mov	bp,ax
		mov	dl,10h
buffer_not_empty4:
		rcl	cx,1
		inc	cx
		inc	cx
		lodsb
		mov	bh,0FFh
		mov	bl,al
                jmp     expand_loop
long_pointer:
		lodsw
		mov	bx,ax
		mov	cl,3
		shr	bh,cl
		or	bh,0E0h
		and	ah,7
                jz      very_long_pointer
		mov	cl,ah
		inc	cx
		inc	cx

expand_loop:
		mov	al,es:[bx+di]
		stosb
                loop    expand_loop

                jmp     short decompr_loop
very_long_pointer:
		lodsb
		or	al,al
                jz      all_done
		cmp	al,1
                je      all_done
		mov	cl,al
		inc	cx
                jmp     short expand_loop
all_done:

		push	ds
		mov	ax,100h
		push	ax
		retf		; "Возврат", на самом деле - переход
				; на старый CS:100h

nomemsg	db	'Not enough memory',10,13,'$'

data:			; Здесь должны находиться сжатые данные

CODE	ENDS
END	begin
