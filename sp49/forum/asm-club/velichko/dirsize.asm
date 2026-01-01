; ╓────────────────────────────────────────────────────────────────────
; ║ ▌     Module name        : DIRSIZE.ASM
; ║ ▌     Last revision date : 24.5.92
; ║ ▌     Subroutine(s)      : DirSize
; ║ ▌
; ║ ▌                        Description
; ║ ▌
; ║ ▌     Определяет  размер  директории,  имя  которой  содержится
; ║ ▌ в переменной DirBuf. OffsEnd указывает на конец строки имени.
; ║ ▌ Длину  возвращает  в  регистрах   DX:AX  (если  CF  сброшен).
; ║ ▌ Если CF установлен, то директория не найдена.
; ║ ▌
; ║ ▌      (C) Copyright by Al Snyatkov & Nick Velichko
; ╙────────────────────────────────────────────────────────────────────

	.Data

SizeOfDir	dw	0		; Размер текущего каталога как файла

	.Code

DirSize	Proc	C

	Local	DTA:Byte:128		; Отводим в стеке место для 
					; локального DTA
FileAttr EQU	DTA[15h]
FileSize EQU	DTA[1Ah]
FileName EQU	DTA[1Eh]

	push	SizeOfDir ds es bx si
	
	mov	SizeOfDir,0
	
	mov	ah,2Fh			; --- Get DTA address
	int	21h
	push	es bx			; Сохраняем старый фдрес DTA
	
	sub	bx,bx			; Размер текущего каталога
	mov	si,bx			; держим в SI:BX = 0
	lea	dx,DTA			
	mov	ah,1Ah			; --- Set new DTA
	int	21h
	
	mov	di,OffsEnd		; Дописываем в конец строки пути
	mov	ax,'*\'			; '\*.*',0 для функций 4Eh-4Fh
	stosw				;		│
	mov	al,'.'			;		│
	stosw				;		│
	sub	ax,ax			;		│
	stosw				;		V
	
	lea	dx,DirBuf
	mov	cx,00110111b		; Искать все, кроме Volume labels
	mov	ah,4Eh			; --- Find 1st file
	jmp	short	@@Entry
Cycle:	
	mov	ah,4Fh			; --- Find 2nd file
@@Entry:
	int	21h			; Искать файл.
	jc	@@Exit			; Закончить просмотр каталога
	
	add	SizeOfDir,32		; Размер каталога как файла += 32 байта
	test	Byte Ptr FileAttr,00010000b	; Найден каталог ?
	jnz	SubDirFound		; Да.
	
	test	Flags,Wild		; Задана маска для поиска?
	jz	NoPresent		; Нет.
	
	push	si
	lea	si,FileName		; Приведем имя файла к FCB-виду
	mov	di,6Ch			; и поместим его по смещению 006Ch
	mov	ax,2901h		; --- Parse file name
	int	21h
	pop	si
	
	mov	dx,5Dh			; По смещению 005Dh хранится маска
	mov	cx,11			; Сравнить 11 байт по 005Dh c
	inc	di			; байтами по 006Dh
Compare:
	xchg	si,dx
	lodsb				; Получим байт маски
	xchg	si,dx
	cmp	al,'?'			; Это '?' ?
	je	@@Next			; Да, не сравнивать
	cmp	al,[di]			; Сравнить с байтом имени файла
	jne	Cycle			; Не совпадают - продолжить поиск
@@Next:	
	inc	di
	loop	Compare			; Сравнить следующие байты

NoPresent:
	add	bx,word ptr FileSize	; Увеличить размер каталога
	adc	si,word ptr FileSize+2

	inc	FileCount		; Увеличить число найденных файлов
	
	test	Flags,VERB		; Расшмренная информация ?
	jz	Cycle			; Нет, продолжить поиск.
	
	push	cx dx
	mov	al,Byte Ptr FileAttr	; AX - атрибуты файла
	mov	ah,0
	mov	dx,word ptr FileSize	; CX:DX - его длина
	mov	cx,word ptr FileSize+2

	push	cx dx			; сохраним ее
	
	shr	ax,1			; Это Read-Only файл ?
	jnc	@@1			; Нет.
	inc	ROFiles
	add	word ptr ROSize  ,dx
	adc	word ptr ROSize+2,cx


  @@1:	shr	ax,1			; Это Hidden файл ?
	jnc	@@2			; Нет.
	inc	HDFiles
	add	word ptr HDSize  ,dx
	adc	word ptr HDSize+2,cx


  @@2:	shr	ax,1			; Это System файл ?
	jnc	@@3			; Нет.
	inc	SYFiles
	add	word ptr SYSize  ,dx
	adc	word ptr SYSize+2,cx


  @@3:	pop	ax dx			; Восстановим длину файла
	add	ax,ClustSize		; и получим его размер
	adc	dx,0			; в кластерах по формуле
	sub	ax,1			; Int ( Size / ClustSize + 1)
	sbb	dx,0			;
	div	ClustSize		;
	add	ClustCnt,ax		; Увеличим общее число кластеров
	pop	dx cx
	
	jmp	Cycle			; Продолжить поиск
; --------------------------------------
SubDirFound:
	cmp	Byte Ptr FileName,'.'	; Это CurrentDir или ParentDir ?
	je	Cycle			; Да, продолжить поиск.
	
	inc	DirCount		; Увеличим число подкаталогов

	mov	di,OffsEnd
	push	di si			; Сохраним текущий OffsEnd
	mov	al,'\'			; Подсчитаем размер этого
	stosb				; подкаталога. Для этого
	lea	si,FileName		; создадим новое имя каталога
@@Loop:	SegSS				; из текущего и найденного.
	lodsb				;	     │
	stosb				;	     │
	or	al,al			;	     │
	jnz	@@Loop			;	     V
					;
	pop	si			;
	dec	di			;
	mov	OffsEnd,di		; Установим новый OffsEnd
	call	DirSize			; и вызовем рекурсивно DirSize
	
	add	bx,ax			; Увеличим размер каталога
	adc	si,dx

	pop	OffsEnd			; Восстановим старый OffsEnd
	jmp	Cycle			; Продолжим поиск
; --------------------------------------
@@Exit:	cmp	ax,3			; Код ошибки - 'Путь не найден' ?
	jne	@@4			; Нет

	stc				; Иначе установим признак ошибки
	jmp	short	@@5

@@4:	clc				; Сбросим признак ошибки
@@5:	pop	dx ds			; Восстановим старый DTA
	pushf
	mov	ah,1Ah			; --- Set new DTA
	int	21h
	
	mov	di,OffsEnd
	mov	Byte Ptr [di],0		; Восстановим старое имя каталога
		
	test	Flags,VERB
	jz	@@6
	
	mov	ax,SizeOfDir		; Рассчитаем число кластеров,
	sub	dx,dx			; занимаемых данным каталогом
	add	ax,ClustSize		; как файлом по формуле
	adc	dx,0			; Int ( Size / ClustSize + 1)
	sub	ax,1			;
	sbb	dx,0			;
	div	ClustSize		;
	add	ClustCnt,ax		; Увеличим общее число кластеров
	
@@6:	
	mov	dx,si			; Поместим результат
	mov	ax,bx			; из SI:BX в DX:AX
	popf
	pop	si bx es ds SizeOfDir
	
	ret
	
DirSize	Endp
