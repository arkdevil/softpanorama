;
;					ASCII Table Show Utility
;					Версия 4.0	от 19.12.93
;					Программист	Ратынский Д.А.
;					раб. тел. 238-00-23
;
;   За всю свою практику я видел около 10 подобных утилит, но все они имели
; слоноподобные размеры(самые маленькие занимали в памяти около 2K), что,
; согласитесь, не очень приятно на наших бедных памятью PC с процессором не
; выше 286(именно таких сейчас продолжает использоваться великое множество).
; Но необходимость такой утилиты ощущается постоянно.
;   Более ранние версии этой утилиты занимали еще меньше памяти, за счет
; полного освобождения PSP(минимальный объем памяти занимала версия 2.2 - 496
; байт), но в результате конфликта с 6 DOS от этой затеи пришлось отказаться.
;   Я очень признателен Милюкову А.В. за подброшенную идею сохранения экрана в
; области знакогенератора(ранее я использовал для этой цели видеостраницы, что
; могло привести к конфликтам).
;
;   ВЫ вправе свободно использовать утилиту и ее исходный текст в своих целях,
; при условии неизменности данного маленького вступления.
;
;       Компиляция: tasm /m /mx ascii
;       Линковка:   tlink /t ascii
;   При компиляции необходимо наличие файлов включения OPERATOR.INC, DOS.INC и
; BIOS.INC. Возможно Вам они пригодятся и в отдельности.
;

%PAGESIZE	, 132		; ширина страницы листинга = 132
%NOINCL				; листинг без файлов включения
.SALL				; и без подстановки MACRO
INCLUDE OPERATOR.INC		; псевдооператоры
INCLUDE DOS.INC			; сервис DOS и константы
INCLUDE BIOS.INC		; функции BIOS


.MODEL TINY
.CODE
ORG	100h
START:
	jmp	INIT

SaveVideo:
	mov	bx, 16		; смещение пеpвого свободного байта в ЗГ
	xor	si, si		; смещение в экpане
      SaveInMem:
	mov	cx, 8		; сколько слов за один пpием
	mov	ds, bp		; откуда сохpаняем
	@MOV	es, cs
	mov	di, OFFSET CHARGEN
	REP	movsw
	push	si
	call	OpenCharGen	; готовим видеопамять
	@MOV	ds, cs
	mov	ax, 0A000h
	mov	es, ax
	mov	si, OFFSET CHARGEN

	mov	cl, 8		; сколько слов за один пpием
	mov	di, bx
	REP	movsw
	call	CloseCharGen

	add	bx, 32
	pop	si
	cmp	si, 4000
	jb	SaveInMem
	retn

RestoreVideo:
	mov	bx, 16		; смещение пеpвого свободного байта в ЗГ
	xor	di, di		; смещение в экpане
      GetMem:
	push	di
	call	OpenCharGen      ; готовим видеопамять
	@MOV	es, cs
	mov	ax, 0A000h
	mov	ds, ax

	mov	cx, 8		; сколько слов за один пpием
	mov	si, bx
	mov	di, OFFSET CHARGEN
	push	di
	REP	movsw
	call	CloseCharGen

	mov	cl, 8		; сколько слов за один пpием
	mov	es, bp		; куда сохpаняем
	@MOV	ds, cs		; буфеp в сегменте кодa
	pop	si di
	REP	movsw

	add	bx, 32
	cmp	di, 4000
	jb	GetMem
	retn

OpenCharGen:
	mov	dx, 03C4h
	mov	ax, 0402h
	out	dx, ax
	mov	ax, 0704h
	out	dx, ax
	mov	dl, 0CEh
	mov	ax, 0005h
	out	dx, ax
	mov	ax, 0406h
	out	dx, ax
	mov	ax, 0204h
	out	dx, ax
	retn

CloseCharGen:
	mov	dx, 03C4h
	mov	ax, 0302h
	out	dx, ax
	mov	al, 04h
	out	dx, ax
	mov	dl, 0CEh
	mov	ax, 1005h
	out	dx, ax
	mov	ax, 0E06h
	out	dx, ax
	mov	ax, 0004h
	out	dx, ax
	retn

    Show_ PROC Near
	lodsb
	stosw
	lodsb
	mov	cl, 33
	REP	stosw
	lodsb
      Sho:
	stosw
	add	di, 90
	ret
    Show_ ENDP

    Print_Val PROC Near
	xor	ah, ah
	div	bh
	@JZ	al, Show
	push	ax
	call	Print_Val
	pop	ax
      Show:
	mov	al, ah
	@IF	al { 10 Decimal
	add	al, 67h
      Decimal:
	xor	al, 30h
	stosb
	inc	di
	ret
    Print_Val ENDP

    Select PROC Near
	mov	al, 160
	mul	dl
	add	ax, 331
	mov	di, ax
	mov	al, dh
	cbw
	add	di, ax
	mov	al, bh
	stosb
	inc	di
	stosb
	inc	di
	stosb
	ret
    Select ENDP

    New_Int_9  PROC  Far
	push	ax
	in	al, 60h
	@IF	al {} 30 Jmp_09h
	@KBD_SHIFT
	@JNBT	al, 2, Jmp_09h
	@JNBT	al, 3, Jmp_09h
	@IF	cs:FLAG = 0 Activate
      Jmp_09h:
	pop	ax
	DB	0EAh
    Old_Vect09  DD 00000000h
      Activate:
	in	al, 61h
	push	ax
	or	al, 80h
	out	61h, al
	pop	ax
	out	61h, al
	mov	al, 20h
	out	20h, al
	inc	cs:FLAG
	sti
	push	bx cx dx si di ds es bp
	mov	bp, 0B800h
	mov	ah, 0Fh
	int	10h
	@IF	al = 2 _Show
	@IF	al = 3 _Show
	@IF	al = 7 Mono_Seg
	jmp	_Ret_
      Mono_Seg:
	mov	bp, 0B000h

      _Show:
	cld
	call	SaveVideo
	@MOV	ds, cs
	mov	es, bp
	mov	di, 168
	mov	si, OFFSET LINE
	mov	ah, 1Fh
	call	Show_
	xor	bl, bl
	mov	al, 0BAh
	mov	cl, 16
      Next_Line:
	stosw
	mov	al, ' '
	stosw
	push	cx
	mov	cl, 16
       Next_Ch:
	xchg	al, bl
	stosw
	xchg	al, bl
	stosw
	inc	bl
       LOOP Next_Ch
	pop	cx
	mov	al, 0BAh
	call	Sho
      LOOP Next_Line
	call	Show_
	mov	cl, 35
      Next_Sim:
	lodsb
	stosw
      LOOP Next_Sim
	add	di, 90
	call	Show_

	mov	bl, SUMB
	mov	dx, OLDPOS
      Sel:
	mov	bh, 8Eh
	call	Select
	mov	di, 3058
	mov	cl, 8
	mov	ah, 1Dh
      Next_Bin:
	rol	bl, 1
	mov	al, bl
	and	al, 1
	or	al, 30h
	stosw
      LOOP Next_Bin
	mov	si, OFFSET TBL
	mov	cl, 3
      Next_S:
	lodsw
	mov	di, ax
	lodsb
	mov	bh, al
	mov	ax, 1D20h
	push	di
	stosw
	stosw
	stosw
	pop	di
	mov	al, bl
	call	Print_Val
      LOOP Next_S

      ReadKey:
	@KBD_READ
	@IF	al = 13 Enter_
	@IF	al = 27 Esc_
	@JNZ	al, ReadKey
	mov	bh, 1Fh
	push	ax
	call	Select
	pop	ax
	mov	al, ah
	@IF	al = 72 Up
	@IF	al = 77 Right
	@IF	al = 75 Left
	@IF	al {} 80 Sel
	@IF	dl { 15 Line_1

	mov	dl, -1
      Line_1:
	inc	dl
	add	bl, 16
      Sel_:
	jmp	Sel

      Up:
	@JNZ	dl, Line_16
	mov	dl, 10h
      Line_16:
	dec	dl
	sub	bl, 16
	jmp	Sel

      Left:
	@JNZ	dh, Col_16
	mov	dh, 64
	add	bl, 16
      Col_16:
	dec	bl
	sub	dh, 4
	jmp	Sel_

      Right:
	@IF	dh { 60 Col_1
	mov	dh, -4
	sub	bl, 16
      Col_1:
	inc	bl
	add	dh, 4
	jmp	Sel_

      Enter_:
	mov	ah, 5
	mov	cl, bl
	int	16h
      Esc_:
	mov	SUMB, bl
	mov	OLDPOS, dx
	xor	al, al
	call	RestoreVideo
      _Ret_:
	dec	cs:FLAG
	pop	bp es ds di si dx cx bx ax
	iret
    New_Int_9  ENDP

SUMB		DB  0
OLDPOS		DW  0
FLAG		DB  0
LINE		DB  '╔═╗╟─╢║ Bin         Oct    Dec    Hex   ║╚═╝'
TBL		DW  3082
		DB  8
		DW  3096
		DB  10
		DW  3110
		DB  16
CHARGEN		DB  16 DUP('?')

END_RESIDENT:

INIT:
	@MOV	ds, cs
	@DOS_PRINT_STR	Start_Msg
	cld

	mov	ax, 3509h
	int	21h
	cmp	Word Ptr es:[bx], 0E450h
	jne	Inst
	mov	si, 81h
      Next_:
	lodsb
	@IF	al = ' ' Next_
	and	al, 0DFh
	@IF	al = 'U' Unload
	@DOS_PRINT_STR	Already_Msg
	lea	dx, Key_Msg
	jmp	Quit

      Unload:
	push	ds
	lds	dx, DWord Ptr es:Old_Vect09
	mov	ax, 2509h
	int	21h
	@DOS_FREE_MEM
	pop	ds
	lea	dx, Uninst_Msg

      Quit:
	@DOS_PRINT_STR
	int	20h

      Inst:
	mov	Word Ptr Old_Vect09, bx
	mov	Word Ptr Old_Vect09 + 2, es
	mov	ax, 2509h
	lea	dx, New_Int_9
	int	21h
	mov	ax, ds:[2CH]
	@DOS_FREE_MEM	ax
	@DOS_PRINT_STR	Inst_Msg
	lea	dx, END_RESIDENT
	int	27h

Start_Msg	DB  'ASCII Table Show Utility.  Version 4.0', CR, LF
		DB  'Copyright (c) 19.12.93 by RDA Software', CR, LF, '$'
Already_Msg	DB  'Already Installed.', CR, LF
		DB  '  ■ Use  ASCII U     for unload.', CR, LF, '$'
Inst_Msg	DB  'Installed.', CR, LF
Key_Msg		DB  '  ■ Use  Ctrl+Alt+A  for activate.', CR, LF, '$'
Uninst_Msg	DB  'Unloaded.', CR, LF, '$'
END START
