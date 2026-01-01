codesg	segment para 'Code'
assume	cs:codesg,ds:codesg,ss:codesg,es:codesg
	org	100h
main	proc	near
	call	SpDel	;Удаляем пробелы из командной строки
	call	Info	;Выводим справку, если необходимо
	call	ModifyPassw
	call	LockSystem
	ret
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
			;Пароль расположен именно здесь, чтобы труднее было
Passw	db	'avn       '	;  обнаружить
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
InfMsg	db	0Dh,0Ah,'OBSTACLE  (C) AVN  November 1993',0Dh,0Ah,0Dh,0Ah
	db	'obstacle /l    - lock system',0Dh,0Ah
	db	'obstacle /m    - modify password',0Dh,0Ah,'$'
Info	endp
;---------------------------------------
ModifyPassw	proc	near
	mov	bx,0080h
	mov	cl,[bx]		;Длина командной строки
	xor	dl,dl		;Длина проверенной части командной строки
NextChar:
	inc	bl
	inc	dl
	cmp	byte ptr [bx],'/'
	jz	FindM
	cmp	dl,cl
	jnz	NextChar
	int	20h
FindM:
	inc	bx
	cmp	byte ptr [bx],'m'
	jz	EnterOldPassw
	cmp	byte ptr [bx],'M'
	jnz	ExitModify
EnterOldPassw:
	call	EnterPassw
        call	EnterNewPassw
ExitModify:
	ret
ModifyPassw	endp
;---------------------------------------
EnterPassw	proc	near
ReEnter:
	mov	ah,09h
	mov	dx,offset Msg1
	int	21h
	call	EnterString
	push	ds
	pop	es
	mov	si,offset Passw
	mov	di,offset EndPrg
	mov	cx,0Ah
	cld
	rep	cmpsb
	cmp	cx,0000
	jnz	ReEnter
        ret
Msg1	db	0Dh,0Ah,'Password: ','$'
EnterPassw	endp
;---------------------------------------
EnterNewPassw	proc	near
	mov	ah,09h
	mov	dx,offset Msg2
	int	21h
	call	EnterString
	push	ds
	pop	es
ReEnterPassw:
	mov	si,offset EndPrg
	mov	di,offset Passw
	mov	cx,000Ah
	cld
	rep	movsb
	mov	ah,09h
	mov	dx,offset Msg3
	int	21h
	call	EnterString
	mov	si,offset EndPrg
	mov	di,offset Passw
	mov	cx,000Ah
	cld
	rep	cmpsb
	jnz	ReEnterPassw
	call	WriteNewPassw
	mov	ah,09h
	mov	dx,offset Msg4
	int	21h
	int	20h
	ret
Msg2	db	0Dh,0Ah,'New password: ','$'
Msg3	db	0Dh,0Ah,'Re-enter password: $'
Msg4	db	0Dh,0Ah,'Password modified OK',0Dh,0Ah,'$'
EnterNewPassw	endp
;---------------------------------------
EnterString	proc	near	;Ввод строки с клавиатуры. Символы вводятся
	mov	di,offset EndPrg;  начиная со смещения EndPrg. Число символов
	xor	si,si		;  от 0 до 10. Ввод заканчивается при нажатии	
InpChar:			;  ENTER или при вводе 10 символов. Если
	mov	ah,06		;  символов введено меньше 10, то пустые места
	mov	dl,0FFh		;  заполняются пробелами.
	int	21h
	jz	InpChar
	cmp	al,0Dh
	jz	ExitEnterString
	mov	[di],al
	inc	di
	inc	si
	cmp	si,0Ah
	jz	ExitEnterString
	call	PrintAsterisk
	jmp	InpChar
ExitEnterString:
	mov	cx,000Ah
	sub	cx,si
	jnz	FillSpaces
	mov	cx,si
FillSpaces:
	mov	byte ptr [di],' '
	inc	di
	loop	FillSpaces
	ret
EnterString	endp
;---------------------------------------
PrintAsterisk	proc	near
	mov	ah,06h
	mov	dl,'*'
	int	21h
	ret
PrintAsterisk	endp
;---------------------------------------
WriteNewPassw	proc	near
	mov	ax,3D02h	;Открыть файл для ввода и вывода
	mov	dx,offset FileName
	int	21h
	jc	ErrFile
	mov	Handle,ax
	mov	ax,4202h	;Определяем размер файла
	mov	bx,Handle
	xor	cx,cx
	xor	dx,dx
	int	21h
	jc	ErrSizeCheck
	mov	dx,offset EndPrg
	inc	dx
	sub	dx,0100h
	cmp	dx,ax
	jnz     ErrSize
	mov	ax,4200h	;Устанавливаем файловый указатель на
	mov	bx,Handle	;  начало пароля
	xor	cx,cx
	mov	dx,offset Passw
	sub	dx,100h
	int	21h
	mov	ah,40h		;Пишем новый пароль в файл
	mov	bx,Handle
	mov	cx,000Ah
	mov	dx,offset Passw
	int	21h
	jc	ErrWriteFile
	cmp	al,0Ah
	jnz	ErrWriteFile
	mov	ah,09h		;Сообщаем об удачной смене пароля
	mov	dx,offset WriteOK
	int	21h
	int	20h
ErrFile:
	mov	ah,09h
	mov	dx,offset ErMsg
	int	21h
	int	20h
ErrSize:
	mov	ah,09h
	mov	dx,offset ErSizeMsg
	int	21h
	int	20h
ErrSizeCheck:
	mov	ah,09h
	mov	dx,offset ErSizeCheckMsg
	int	21h
	int	20h
ErrWriteFile:
	mov	ah,09h
	mov	dx,offset ErMsg4
	int	21h
	int	20
ErMsg   db	0Dh,0Ah,'Error open file$'
ErSizeMsg db	0Dh,0Ah,'Size incorrect$'
ErSizeCheckMsg	db	0Dh,0Ah,'Error size check$'
ErMsg4	db	0Dh,0Ah,'Error write file$'
FileName db	'OBSTACLE.COM',00h
WriteOK	db	0Dh,0Ah,'New password installed',0Dh,0Ah,'$'
Handle	dw	?
WriteNewPassw	endp
;---------------------------------------
LockSystem	proc	near
	mov	bx,80h
	mov	cl,[bx]
	xor	ch,ch
FindMark:
	inc	bx
	cmp	byte ptr [bx]	,'/'
	jz	Find_M
	loop	FindMark
ExitLock:
	int	20h
Find_M:
	inc	bx
	cmp	byte ptr [bx],'l'
	jz	LockSyst
	cmp	byte ptr [bx],'L'
	jnz	ExitLock
LockSyst:
	call	EnterPassw
	mov	ah,09h
	mov	dx,offset PasswOK
	int	21h
	ret
PasswOK	db	0Dh,0Ah,'Password OK',0Dh,0Ah,'$'
LockSystem	endp
;---------------------------------------
EndPrg	db	?
;---------------------------
codesg	ends
	end	main
