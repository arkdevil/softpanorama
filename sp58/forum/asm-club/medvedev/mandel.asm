;------------------------------------------------------------------
; Автор: А.В.Медведев.
; 220090, Республика Беларусь, Минск, ул.Широкая, 36, к.716а
; т. 64-51-52 (раб.)
;
; Описание выводится на экран при запуске (см. также текст программы).
; Для выполнения нужны: EGA/VGA, сопроцессор.
;
; Для получения выполнимого файла:
;	TASM ma
;	TLINK /x/t ma
;------------------------------------------------------------------

MODEL	TINY

LIMIT_K		EQU	64	; максимальное число итераций

WIDTH_		EQU	640	; ширина экрана в точках
HEIGHT		EQU	350	; число строк (заменить на 480 для VGA)
VMODE		EQU	10h	; заменить на 12h для VGA

				; 800 x 600, 1Fh - RealTek VGA

DATASEG

limit 	DQ	1000.
a0	DQ	0.4005345
b	DQ	0.321
delta_a	DQ	0.0001042
delta_b	DQ	0.0001042

x	DQ	?
y	DQ	?
a	DQ	?

tmp	DW	?

color_table	LABEL	BYTE
	DB   7,  6,  4,  5,  2,  3,  1,  9, 13, 14, 15, 12, 10, 11,  8,  0

palette	DB 0, 25, 1, 41, 49, 33, 20, 7, 56, 41, 58, 59, 60, 61, 62, 63, 0

msg	LABEL	BYTE
DB '╓#', 76, '─┐', 13
DB '║  Эта программа рисует на экране цветную картинку, проверяя  каждую  точку│'
DB '║  экрана на принадлежность множеству Мандельброта.  Для  этого  итеративно│'
DB '║  вычисляются координаты x, y по следующим формулам:│'
DB '║│'
DB '║      x[0] := 0;│'
DB '║      y[0] := 0;│'
DB '║│'
DB '║  и далее│'
DB '║│'
DB '║      x[i+1] := x[i]^2 - y[i]^2 + a;│'
DB '║      y[i+1] := 2*x[i]*y[i] + b.│'
DB '║│'
DB '║  Значения a и b определяются положением точки на экране и выбранными  на-│'
DB '║  чальными значениями.│'
DB '║│'
DB '║  Множество Мандельброта - это просто множество всех точек (a, b), в кото-│'
DB '║  рых (x[i], y[i]), вычисляемые по приведенным выше формулам,  остаются  в│'
DB '║  ограниченной зоне.│'
DB '║│'
DB '║  Для более подробной информации обратитесь к статье "Увлекательное  путе-│'
DB '║  шествие по множеству Мандельброта" ("В МИРЕ НАУКИ", N 4, 1989 г.), после│'
DB '║  прочтения которой написана эта программа.│'
DB '╚#', 26 ,'═ ~Copyright (C) 1992, Андрей Владимирович Медведев~ ╛', 13
DB '     @Нажмите любую клавишу для продолжения (<ESC> - выход в любой момент)', 0

coproc	DB 'Для работы этой программы нужен сопроцессор.', 13, 10, '$'
EGArq	DB 'Требуется адаптер EGA/VGA и цветной монитор.', 13, 10, '$'
no_mem	DB 'Нужно не менее 128К видеопамяти.', 13, 10, '$'

CODESEG

ORG	100h

START:
	xor	ax,ax
	mov	ES,ax
	test	BYTE PTR ES:[410h],2
	jnz	@@1
	mov	dx,offset coproc
@@quit:
	mov	ah,9
	int	21h
	int	20h
@@1:
	mov	al,ES:[487h]
	or	al,al
	jnz	@@2
@@no_EGA:
	mov	dx,offset EGArq
	jmp	@@quit
@@2:
	test	al,1010b
	jnz	@@no_EGA
	and	al,01100000b
	jnz	@@3
	mov	dx,offset no_mem
	jmp	@@quit
@@3:
	cmp	BYTE PTR ES:[449h],3
	je	@@mode_ok
	cmp	WORD PTR ES:[462h],0
	je	@@mode_ok
	mov	ax,3
	int	10h
@@mode_ok:
	mov	ax,0B800h
	mov	ES,ax
	mov	ax,1E20h
	xor	di,di
	mov	cx,2000
	cld
	rep stosw

	mov	di,2
	mov	si,offset msg
	mov	dx,156
	mov	bx,9A1Ch
@@next_char:
	lodsb
	or	al,al
	jz	@@end
	cmp	al,'│'
	jne	@@no_eol
	mov	di,dx
	stosw
@@eol:
	add	di,4
	add	dx,160
	jmp	@@next_char
@@no_eol:
	cmp	al,'#'
	jne	@@one_char
	lodsb
	mov	cl,al
	lodsb
	rep
@@type:
	stosw
	jmp	@@next_char
@@one_char:
	cmp	al,13
	je	@@eol
	cmp	al,'~'
	jne	@@5
	xchg	ah,bl
	jmp	@@next_char
@@5:	cmp	al,'@'
	jne	@@type
	xchg	ah,bh
	jmp	@@next_char
@@end:
	mov	ah,1
	mov	cx,2000h
	int	10h
	xor	ax,ax
	int	16h
	cmp	ax,011Bh
	jne	@@draw
	jmp	__quit
@@draw:
	finit
	mov	ax,VMODE
	int	10h

	mov	ax,1002h
	push	DS
	pop	ES
	mov	dx,offset palette	; в Tech Help! ошибка - указано ES:BX
	int	10h

	mov	dx,3CEh
	mov	ax,205h
	out	dx,ax
	mov	al,8
	out	dx,ax
	inc	dx
	mov	ax,0A000h
	mov	ES,ax
	xor	bp,bp
	mov	bx,offset color_table
	mov	ch,80h
	mov	di,HEIGHT	; счетчик строк
__loop_di:
	mov	si,WIDTH_	; счетчик столбцов
	fld	a0
	fst	a		; a = a0
__loop_si:
	xor	cl,cl
	fstp	x		; x = a
	fld	b
	fstp	y		; y = b
__loop_k:
	fld	x
	fmul	st,st
	fld	y
	fmul	st,st
	fsubp	st(1),st
	fadd	a		; st = x^2 - y^2 + a
	fld	x
	fmul	y
	fadd	st,st
	fadd	b		; st = 2*x*y + b
	fstp 	y

	inc	cx
	cmp	cl,LIMIT_K
	jae	short __exit_loop1
	fst	x
	fmul	st,st
	fld	y
	fmul	st,st
	faddp	st(1),st
	fcomp	limit		; x^2 + y^2 < limit ?
	fstsw	tmp
	mov	ax,tmp
	sahf
	jb      __loop_k
	jmp	short __exit_loop
__exit_loop1:
	fstp	x
__exit_loop:
	push	DS		; проверить, было ли нажатие клавиши
	xor	ax,ax
	mov	DS,ax
	cli
	mov	ax,DS:[41Ah]
	cmp	ax,DS:[41Ch]
	sti
	pop	DS
	je	__no_key
	xor	ax,ax
	int	16h
	cmp	ax,011Bh	; была нажата клавиша <ESC> ?
	je	__quit
__no_key:
	cmp	cl,LIMIT_K
	jae	__skip
	mov	al,cl
	shr	al,1
	shr	al,1
	xlat
	mov	cl,al
	mov	al,ch
	out	dx,al
	xchg	ES:[bp],cl
__skip:
	ror	ch,1
	adc	bp,0

	dec	si
	jz	__end_loop_si
	fld	a
	fadd	delta_a
	fst	a
	jmp	__loop_si
__end_loop_si:
	dec	di
	jz	__end_loop_di
	fld	b
	fadd	delta_b
	fstp	b
	jmp	__loop_di
__end_loop_di:
	xor	ax,ax
	int	16h
__quit:
	mov	ax,3
	int	10h
	int	20h

END	START
