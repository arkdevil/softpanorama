;*******************************************************;
;                                                       ;
;       Turbo Pascal Version 7.0                        ;
;       Extended Strings Unit                           ;
;       Version 1.1                                     ;
;                                                       ;
;       Copyright (c) 1993 by RDA Software              ;
;                                                       ;
;*******************************************************;

.MODEL TPASCAL
.CODE
LOCALS @@


; Procedure StrToLower(Var Str: String);
; Процедура преобразует строку Str к нижнему регистру.

PUBLIC  StrToLower

	Str_	equ	DWord Ptr ss:[bx + 4]

    StrToLower	PROC	Far
	mov	bx, sp
	les	di, Str_
	xor	cx, cx
	mov	cl, es:[di]
	jcxz	@@4
	cld
	inc	di
   @@1: mov	al, es:[di]
	cmp	al, 'A'
	jb	@@3
	cmp	al, 'Z'
	jbe	@@2
	cmp	al, 'А'
	jb	@@3
	cmp	al, 'П'
	jbe	@@2
	cmp	al, 'Я'
	ja	@@3
	add	al, 80
	jmp	@@3
   @@2: add	al, 32
   @@3: stosb
	LOOP	@@1
   @@4: ret	4
    StrToLower	ENDP


; Procedure StrToUpper(Var Str: String);
; Процедура преобразует строку Str к верхнему регистру.

PUBLIC  StrToUpper

	Str_	equ	DWord Ptr ss:[bx + 4]

    StrToUpper	PROC	Far
	mov	bx, sp
	les	di, Str_
	xor	cx, cx
	mov	cl, es:[di]
	jcxz	@@4
	cld
	inc	di
   @@1: mov	al, es:[di]
	cmp	al, 'a'
	jb	@@3
	cmp	al, 'z'
	jbe	@@2
	cmp	al, 'а'
	jb	@@3
	cmp	al, 'п'
	jbe	@@2
	cmp	al, 'р'
	jb	@@3
	cmp	al, 'я'
	ja	@@3
	sub	al, 80
	jmp	@@3
   @@2: sub	al, 32
   @@3: stosb
	LOOP	@@1
   @@4: ret	4
    StrToUpper	ENDP


; Function  StrChr(Str: String; Sim: Char): Boolean;
; Функция проверяет вхождение символа Chr в строку Str.

PUBLIC	StrChr

	Str_	equ	DWord Ptr ss:[bx + 6]
	Sim	equ	ss:[bx + 4]

    StrChr	PROC	Far
	mov	bx, sp
	les	di, Str_
	mov	ax, Sim
	xor	cx, cx
	mov	cl, es:[di]
	jcxz	@@2
	inc	di
	cld
	REPNE	scasb
	je	@@1
	xor	al, al
	jmp	@@2
   @@1: mov	al, 1
   @@2: ret	6
    StrChr	ENDP


; Function  StrIChr(Str: String; Sim: Char): Boolean;
; Функция проверяет вхождение символа Chr в строку Str,
; считая при этом буквы верхнего и нижнего регистров
; эквивалентными.

PUBLIC	StrIChr

	Str_	equ	DWord Ptr ss:[bx + 8]
	Sim	equ	ss:[bx + 6]

    StrIChr	PROC	Far
	push	ds
	mov	bx, sp
	lds	si, Str_
	mov	ax, Sim
	call	@@5
	mov	bl, al
	cld
	lodsb
	or	al, al
	jz	@@2
	xor	cx, cx
	mov	cl, al
   @@1: lodsb
	call	@@5
	cmp	al, bl
	je	@@3
	LOOP	@@1
   @@2: xor	ax, ax
	jmp	@@4
   @@3: mov	al, 1
   @@4: pop	ds
	ret	6
   @@5: cmp	al, 'A'
	jb	@@8
	cmp	al, 'Z'
	ja	@@7
   @@6: add	al, 32
	retn
   @@7: cmp	al, 'А'
	jb	@@8
	cmp	al, 'П'
	jbe	@@6
	cmp	al, 'Я'
	ja	@@8
	add	al, 80
   @@8: retn
    StrIChr	ENDP


; Function StrCmp(Str1, Str2: String): Integer;
; Функция возвращает результат сравнения двух строк:
;    -1, если Str1 < Str2;
;     0, если Str1 = Str2;
;     1, если Str1 > Str2.

PUBLIC StrCmp

	Str1	equ	DWord Ptr ss:[bx + 10]
	Str2	equ	DWord Ptr ss:[bx + 6]

    StrCmp	PROC	Far
	push	ds
	mov	bx, sp
	cld
	lds	si, Str1
	les	di, Str2
	xor	cx, cx
	mov	cl, [si]
	mov	dl, es:[di]
	mov	dh, cl
	cmp	dl, cl
	jae	@@0
	mov	cl, dl
   @@0: inc	si
	inc	di
	REPE	cmpsb
	jb	@@1
	ja	@@2
	cmp	dh, dl		; сравнить длины строк
	jb	@@2
	ja	@@3	
	xor	ax, ax
	jmp	@@3
   @@1: mov	ax, -1
	jmp	@@3
   @@2: mov	ax, 1
   @@3: pop	ds
	ret	8
    StrCmp	ENDP


; Function StrICmp(Str1, Str2: String): Integer;
; Функция возвращает результат сравнения двух строк,
; считая буквы верхнего и нижнего регистров эквивалентными:
;    -1, если Str1 < Str2;
;     0, если Str1 = Str2;
;     1, если Str1 > Str2.

PUBLIC StrICmp

	Str1	equ	DWord Ptr ss:[bx + 10]
	Str2	equ	DWord Ptr ss:[bx + 6]

    StrICmp	PROC	Far
	push	ds
	mov	bx, sp
	cld
	lds	si, Str1
	les	di, Str2
	xor	cx, cx
	mov	cl, [si]
	mov	dl, es:[di]
	mov	dh, cl
	cmp	dl, cl
	jae	@@0
	mov	cl, dl
   @@0: inc	si
	inc	di
   @@1: lodsb			; начало цикла сравнивания
	call	@@5		; преобразовать к UpCase символ из Str1
	mov	bl, al
	mov	al, es:[di]
	call	@@5		; преобразовать к UpCase символ из Str2
	cmp	bl, al
	jb	@@2
	ja	@@3
	inc	di
	LOOP	@@1
	cmp	dh, dl		; сравнить длины строк
	jb	@@2
	ja	@@3
	xor	ax, ax
	jmp	@@4
   @@2: mov	ax, -1
	jmp	@@4
   @@3: mov	ax, 1
   @@4: pop	ds
	ret	8
   @@5: cmp	al, 'A'		; преобразование символа к UpCase
	jb	@@8
	cmp	al, 'Z'
	ja	@@7
   @@6: add	al, 32
	retn
   @@7: cmp	al, 'А'
	jb	@@8
	cmp	al, 'П'
	jbe	@@6
	cmp	al, 'Я'
	ja	@@8
	add	al, 80
   @@8: retn
    StrICmp	ENDP


; Function StrNCmp(Str1, Str2: String; N: Byte): Integer;
; Функция возвращает результат сравнения двух строк,
; сравнивая не более, чем первые N символов:
;    -1, если Str1 < Str2;
;     0, если Str1 = Str2;
;     1, если Str1 > Str2.

PUBLIC StrNCmp

	N	equ	ss:[bx + 6]
	Str1	equ	DWord Ptr ss:[bx + 12]
	Str2	equ	DWord Ptr ss:[bx + 8]

    StrNCmp	PROC	Far
	push	ds
	mov	bx, sp
	cld
	lds	si, Str1
	les	di, Str2
	mov	dl, N
	xor	cx, cx
	cmp	dl, [si]
	jbe	@@1
	mov	cl, [si]
	inc	cx
	jmp	@@2
   @@1: mov	cl, dl
	inc	si
	inc	di
   @@2:	REPE	cmpsb
	jb	@@3
	ja	@@4
	xor	ax, ax
	jmp	@@5
   @@3: mov	ax, -1
	jmp	@@5
   @@4: mov	ax, 1
   @@5: pop	ds
	ret	10
    StrNCmp	ENDP


; Procedure StrSet(Var Str: String; Sim: Char);
; Процедура устанавливает все символы строки в значение,
; задаваемое параметром Sim.

PUBLIC	StrSet

	Str_	equ	DWord Ptr ss:[bx + 6]
	Sim	equ	ss:[bx + 4]

    StrSet	PROC	Far
	mov	bx, sp
	les	di, Str_
	mov	ax, Sim
	cld
	xor	cx, cx
	mov	cl, es:[di]
	jcxz	@@1
	inc	di
	REP	stosb
   @@1: ret	6
    StrSet	ENDP


; Procedure StrNSet(Var Str: String; Sim: Char; N: Byte);
; Процедура устанавливает N символов строки в значение,
; задаваемое параметром Sim. Длина строки устанавливается в N.

PUBLIC	StrNSet

	Str_	equ	DWord Ptr ss:[bx + 8]
	Sim	equ	ss:[bx + 6]
	N	equ	ss:[bx + 4]

    StrNSet	PROC	Far
	mov	bx, sp
	les	di, Str_
	cld
	xor	cx, cx
	mov	ax, N
	stosb
	mov	cl, al
	jcxz	@@1
	mov	ax, Sim
	REP	stosb
   @@1: ret	8
    StrNSet	ENDP


; Function Contains(Str1, Str2: String): Byte;
; Функция возвращает номер позиции первого символа из строки Str1,
; который содержится в строке Str2 или 0, если ни один символ из Str1
; не найден в Str2.

PUBLIC Contains

	Str1	equ	DWord Ptr ss:[bx + 10]
	Str2	equ	DWord Ptr ss:[bx + 6]

    Contains	PROC	Far
	push	ds
	mov	bx, sp
	cld
	lds	si, Str1
	les	di, Str2
	xor	ax, ax
	lodsb
	push	si
	or	ax, ax
	jz	@@2
	mov	bx, ax
	mov	al, es:[di]
	or	ax, ax
	jz	@@2
	inc	di
	mov	dx, di
	mov	cx, ax
   @@1: push	cx
	mov	di, dx
	lodsb
	REPNE	scasb
	pop	cx
	je	@@3
	dec	bx
	jnz	@@1
   @@2: xor	ax, ax
	pop	bx
	jmp	@@4
   @@3: mov	ax, si
	pop	bx
	sub	ax, bx
   @@4: pop	ds
	ret	8
    Contains	ENDP


; Procedure DelRightSpace(Var Str: String);
; Процедура удаляет завершающие пробелы в строке Str.

PUBLIC  DelRightSpace

	Str_	equ	DWord Ptr ss:[bx + 4]

    DelRightSpace	PROC	Far
	mov	bx, sp
	les	di, Str_
	xor	cx, cx
	mov	cl, es:[di]
	jcxz	@@2
	mov	bx, di
	add	di, cx
	mov	dx, cx
	mov	al, ' '
	std
	REPE	scasb
	jcxz	@@1
	inc	cl
   @@1: mov	es:[bx], cl
   @@2: ret	4
    DelRightSpace	ENDP


; Procedure DelLeftSpace(Var Str: String);
; Процедура удаляет лидирующие пробелы в строке Str.

PUBLIC  DelLeftSpace

	Str_	equ	DWord Ptr ss:[bx + 4]

    DelLeftSpace	PROC	Far
	mov	bx, sp
	les	di, Str_
	xor	cx, cx
	mov	cl, es:[di]
	jcxz	@@2
	mov	bx, di
	inc	di
	mov	si, di
	mov	al, ' '
	cld
	REPE	scasb
	mov	al, cl
	jcxz	@@1
	inc	al
	inc	cl
	dec	di
	push	ds es
	pop	ds
	xchg	di, si
	REP	movsb
	pop	ds
   @@1: mov	di, bx
	stosb
   @@2: ret	4
    DelLeftSpace	ENDP

END
