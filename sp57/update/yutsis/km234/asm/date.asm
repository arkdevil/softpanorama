;
;	Пример встроенного кода, формирующего ASCII-строку.
;
;   Извлекает из CMOS-памяти текущее время, преобразует его
;	в строку и передает в KEYMAC.
;

	.model tiny
	.code

	call $+3
where:	pop ax		; ax = реальный адрес where

	add ax, offset mystring - offset where  ; ax = адрес mystring
	mov bx,sp
	mov ss:[bx+4],ax	; возвращаем адрес в KEYMAC

	push di			; di надо сохранять
	
	push cs
	pop  es
	mov di,ax	; Нельзя "offset mystring" !
	
	mov al,7	; День
	call getcmos
	mov al,8	; Месяц
	call getcmos
	mov al,9	; Год
	call getcmos
	
	pop di
	
	retf

getcmos:
	out 70h,al
	jmp $+2
	in  al,71h
	mov ah,al
	and ah,0fh
	shr al,4
	or  ax,3030h	; Преобразуем дв.-дес. в ASCII
	stosb		; Старшие полбайта
	mov al,ah
	stosb		; Младшие полбайта
	mov al,'.'
	stosb
	ret

mystring:
	db 10 dup(0)

	end
