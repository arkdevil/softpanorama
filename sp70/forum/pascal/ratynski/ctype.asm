;*******************************************************;
;                                                       ;
;       Turbo Pascal Version 7.0                        ;
;       Extended Unit                                   ;
;       Version 1.0                                     ;
;                                                       ;
;       Copyright (c) 1993 by RDA Software              ;
;                                                       ;
;*******************************************************;

.MODEL TPASCAL
.CODE
LOCALS	@@

Sim	equ	ss:[bx + 4]
True	equ	1

; Function ToLower(Sim: Char): Char;
; Функция преобразует символ Sim к нижнему регистру.

PUBLIC  ToLower

    ToLower	PROC	Far
	mov	bx, sp
	mov	ax, Sim
	cmp	al, 'A'
	jb	@@3
	cmp	al, 'Z'
	ja	@@2
   @@1: add	al, 32
	ret	2
   @@2: cmp	al, 'А'
	jb	@@3
	cmp	al, 'П'
	jbe	@@1
	cmp	al, 'Я'
	ja	@@3
	add	al, 80
   @@3: ret	2
    ToLower	ENDP


; Function ToUpper(Sim: Char): Char;
; Функция преобразует символ Sim к верхнему регистру.

PUBLIC  ToUpper

    ToUpper	PROC	Far
	mov	bx, sp
	mov	ax, Sim
	cmp	al, 'a'
	jb	@@3
	cmp	al, 'z'
	ja	@@2
   @@1: sub	al, 32
	ret	2
   @@2: cmp	al, 'а'
	jb	@@3
	cmp	al, 'п'
	jbe	@@1
	cmp	al, 'р'
	jb	@@3
	cmp	al, 'я'
	ja	@@3
	sub	al, 80
   @@3: ret	2
    ToUpper	ENDP


; Function  IsDigit(Sim: Char): Boolean;
; Функция возвращает TRUE, если Sim является десятичной цифрой.

PUBLIC  IsDigit

    IsDigit	PROC	Far
	mov	bx, sp
	mov	ax, Sim
	cmp	al, '0'
	jb	@@1
	cmp	al, '9'
	ja	@@1
	mov	al, True
	ret	2
   @@1: xor	ax, ax
	ret	2
    IsDigit	ENDP


; Function  IsHexDigit(Sim: Char): Boolean;
; Функция возвращает TRUE, если Sim является шестнадцатиричной цифрой.

PUBLIC  IsHexDigit

    IsHexDigit	PROC	Far
	mov	bx, sp
	mov	ax, Sim
	cmp	al, '0'
	jb	@@3
	cmp	al, '9'
	ja	@@2
   @@1: mov	al, True
	ret	2
   @@2: and	al, 0DFh
	cmp	al, 'A'
	jb	@@3
	cmp	al, 'F'
	jbe	@@1
   @@3: xor	ax, ax
	ret	2
    IsHexDigit	ENDP


; Function  IsLatChar(Sim: Char): Boolean;
; Функция возвращает TRUE, если Sim является буквой латинского алфавита.

PUBLIC  IsLatChar

    IsLatChar	PROC	Far
	mov	bx, sp
	mov	ax, Sim
        and     al, 0DFh
	cmp	al, 'A'
	jb	@@1
	cmp	al, 'Z'
	ja	@@1
        mov     al, True
        ret     2
   @@1: xor     ax, ax
	ret	2
    IsLatChar	ENDP


; Function  IsRusChar(Sim: Char): Boolean;
; Функция возвращает TRUE, если Sim является буквой русского алфавита.

PUBLIC  IsRusChar

    IsRusChar	PROC	Far
	mov	bx, sp
	mov	ax, Sim
	cmp	al, 'А'
	jb	@@3
	cmp	al, 'п'
	ja	@@2
   @@1: mov	al, True
	ret	2
   @@2: cmp	al, 'р'
	jb	@@3
	cmp	al, 'я'
	jbe	@@1
   @@3: xor	ax, ax
	ret	2
    IsRusChar	ENDP


; Function  IsAlpha(Sim: Char): Boolean;
; Функция возвращает TRUE, если Sim является русской или латинской буквой.

PUBLIC  IsAlpha

    IsAlpha	PROC	Far
	mov	bx, sp
	mov	ax, Sim
	mov	dx, ax
	and	al, 0DFh
	cmp	al, 'A'
	jb	@@3
	cmp	al, 'Z'
	ja	@@2
   @@1: mov	al, True
	ret	2
   @@2: mov	ax, dx
	cmp	al, 'А'
	jb	@@3
	cmp	al, 'п'
	jbe	@@1
	cmp	al, 'р'
	jb	@@3
	cmp	al, 'я'
	jbe	@@1
   @@3: xor	ax, ax
	ret	2
    IsAlpha	ENDP


; Function  IsAlNum(Sim: Char): Boolean;
; Функция возвращает TRUE, если Sim является русской
; или латинской буквой или цифрой.

PUBLIC  IsAlNum

    IsAlNum	PROC	Far
	mov	bx, sp
	mov	ax, Sim
	cmp	al, '0'
	jb	@@3
	cmp	al, '9'
	ja	@@2
   @@1: mov	al, True
	ret	2
   @@2: mov	dx, ax
	and	al, 0DFh
	cmp	al, 'A'
	jb	@@3
	cmp	al, 'Z'
	jbe	@@1
	mov	ax, dx
	cmp	al, 'А'
	jb	@@3
	cmp	al, 'п'
	jbe	@@1
	cmp	al, 'р'
	jb	@@3
	cmp	al, 'я'
	jbe	@@1
   @@3: xor	ax, ax
	ret	2
    IsAlNum	ENDP

; Function  IsAlfa(Sim: Char): Boolean;
; Функция возвращает TRUE, если Sim является печатной буквой
; (символом с кодом в диапазоне 20h..7Fh).

PUBLIC  IsAlfa

    IsAlfa	PROC	Far
	mov	bx, sp
	mov	ax, Sim
	cmp	al, ' '
	jb	@@1
	cmp	al, 7Fh
	ja	@@1
	mov	al, True
	ret	2
   @@1: xor	ax, ax
	ret	2
    IsAlfa	ENDP


; Function  IsLower(Sim: Char): Boolean;
; Функция возвращает TRUE, если Sim является буквой нижнего регистра.

PUBLIC  IsLower

    IsLower	PROC	Far
	mov	bx, sp
	mov	ax, Sim
	cmp	al, 'a'
	jb	@@3
	cmp	al, 'z'
	ja	@@2
   @@1: mov	al, True
	ret	2
   @@2: cmp	al, 'а'
	jb	@@3
	cmp	al, 'п'
	jbe	@@1
	cmp	al, 'р'
	jb	@@3
	cmp	al, 'я'
	jbe	@@1
   @@3: xor	ax, ax
	ret	2
    IsLower	ENDP


; Function  IsUpper(Sim: Char): Boolean;
; Функция возвращает TRUE, если Sim является буквой верхнего регистра.

PUBLIC  IsUpper

    IsUpper	PROC	Far
	mov	bx, sp
	mov	ax, Sim
	cmp	al, 'A'
	jb	@@3
	cmp	al, 'Z'
	ja	@@2
   @@1: mov	al, True
	ret	2
   @@2: cmp	al, 'А'
	jb	@@3
	cmp	al, 'Я'
	jbe	@@1
   @@3: xor	ax, ax
	ret	2
    IsUpper	ENDP

END