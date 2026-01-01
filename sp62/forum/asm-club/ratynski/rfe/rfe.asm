;
;					RFE - Resident Font Editor
;					Версия 1.2	от 15.12.93
;					Программист	Ратынский Д.А.
;					раб. тел. 238-00-23
;
;   За всю свою практику я не видел ни одной подобной утилиты, но необходимость
; таковой ощущалась, особенно при работе в ИС Turbo Pascal. Постоянно использую
; ее в своей работе, чего и Вам желаю.  С помощью этой утилиты можно, например,
; "ограбить" фонты у Пети Нортона.  А если Вам не хватит мощности - используйте
; EVAFONT или его аналог.
;   Я очень признателен Милюкову А.В. за подброшенную идею сохранения экрана в
; области знакогенератора(ранее я использовал для этой цели видеостраницы, что
; могло привести к конфликтам).
;
;   ВЫ вправе свободно использовать утилиту и ее исходный текст в своих целях,
; при условии неизменности данного маленького вступления.
;
;       Компиляция: tasm /m /mx rfe
;       Линковка:   tlink /t rfe bios
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

EXTRN	PrintStr: PROC		; внешняя процедура печати строки

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
	call	OpenSetFont	; готовим видеопамять

	mov	cl, 8		; сколько слов за один пpием
	mov	di, bx
	REP	movsw
	call	CloseCharGen	; закрываем ЗГ

	add	bx, 32
	pop	si
	cmp	si, 4000
	jb	SaveInMem
	retn

RestoreVideo:			; подпрограмма восстановления экрана
	mov	bx, 16		; смещение пеpвого свободного байта в ЗГ
	xor	di, di		; смещение в экpане
      GetMem:
	push	di
	call	OpenCharGen	; открываем знакогенератор

	mov	cx, 8		; сколько слов за один пpием
	mov	si, bx
	mov	di, OFFSET CHARGEN
	push	di
	REP	movsw
	call	CloseCharGen	; закрываем знакогенератор

	mov	cl, 8		; сколько слов за один пpием
	mov	es, bp		; куда сохpаняем
	@MOV	ds, cs		; буфеp в сегменте кодa
	pop	si di
	REP	movsw

	add	bx, 32
	cmp	di, 4000
	jb	GetMem
	retn

OpenCharGen:			; открытие ЗГ для чтения-записи
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
	@MOV	es, cs
	mov	ax, 0A000h
	mov	ds, ax
	retn

OpenSetFont:			; открытие ЗГ и подготовка памяти
	call	OpenCharGen
	@MOV	ds, cs
	mov	es, ax
	mov	si, OFFSET CHARGEN
	retn

CloseCharGen:			; подпрограмма закрывает доступ к ЗГ
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

Show_:
	lodsb
	stosw
	lodsb
	mov	cl, 50
	REP	stosw
	lodsb
	stosw
	add	di, 56
	retn

Print_Val:
	xor	ah, ah
	div	bh
	@JZ	al, Show
	push	ax
	call	Print_Val
	pop	ax
      Show:
	mov	al, ah
	call	Convert
	stosb
	inc	di
	retn

Select:
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
	retn

SelectEdit:
	mov	al, 160
	mul	dl
	add	ax, 397
	mov	di, ax
	mov	al, dh
	cbw
	add	di, ax
	mov	al, bh
	stosb
	inc	di
	stosb
	retn

DrawChar:
	push	bx cs
	pop	ds
	mov	es, bp
	mov	di, 396
	mov	cl, HIGHT
	mov	si, OFFSET CHARGEN
      Next_Ln_Ch:
	lodsb
	mov	bh, al
	push	cx
	mov	cl, 8
       Next_Bit:
	mov	ax, 0F20h
	mov	Word Ptr es:[di], ax
	mov	Word Ptr es:[di + 2], ax
	rol	bh, 1
	mov	bl, bh
	and	bl, 1
	@JZ	bl, Skip
	mov	al, 0DBh
       Skip:
	stosw
	stosw
       LOOP	Next_Bit
	pop	cx
	add	di, 128
      LOOP	Next_Ln_Ch
	pop	bx
	retn

GetCharByte:
	push	ax
	mov	si, OFFSET CHARGEN
	mov	al, dl
	cbw
	add	si, ax
	pop	ax
	retn

GetFont:
	push	dx
	call	OpenCharGen
	xor	ax, ax
	mov	al, bl
	mov	cl, 5
	shl	ax, cl
	mov	cl, cs:HIGHT
	mov	si, ax
	mov	di, OFFSET CHARGEN
	REP	movsb
	call	CloseCharGen
	pop	dx
	retn

SaveFont:
	push	dx
	call	OpenSetFont
	xor	ax, ax
	mov	al, SUMB
	mov	cl, 5
	shl	ax, cl
	mov	di, ax
	mov	cl, HIGHT
	REP	movsb
	call	CloseCharGen
	mov	es, bp
	pop	dx
	retn

InvertAllProc:
	xor	al, 0FFh
	retn

ClearAllProc:
	xor	al, al
	retn

FillAllProc:
	mov	al, 0FFh
	retn

RightAllProc:
	ror	al, 1
	retn

LeftAllProc:
	rol	al, 1
	retn

UpAllProc:
	cmp	si, OFFSET CHARGEN + 1
	jne	Skip__
	mov	bl, al
      Skip__:
	lodsb
	dec	si
	retn

InClipProc:
	mov	[bx], al
	inc	bx
	retn

FromClipProc:
	mov	al, [bx]
	inc	bx
	retn

MaskAll:
	push	dx
	xor	dl, dl
      Next_Inv:
	call	GetCharByte
	lodsb
	call	di
	mov	Byte Ptr [si - 1], al
	inc	dx
	@IF	dl {} HIGHT Next_Inv
	pop	dx
	retn

SaveOldFont:
	@MOV	es, cs
	mov	di, OFFSET OLDFONT
	mov	si, OFFSET CHARGEN
	mov	cl, HIGHT
	cld
	REP	movsb
	retn

Edit:
	push	dx bx
	xor	dx, dx
	mov	SUMB, bl
	call	SaveOldFont
      _Sel_:
	call	SaveFont
      _Select:
	mov	bh, 0B0h
	call	SelectEdit
      KeyRead:
	call	GetCharByte
	@KBD_READ
	@IF	al = 32 Invert
	@IF	al = '*' InvertLine
	@IF	al = '-' ClearLine
	@IF	al = '+' FillLine
	@IF	al {} 27 No_Esc
	jmp	_Esc
      No_Esc:
	@IF	al {} 13 No_Enter
      Go_Enter:
	jmp	_Enter
      No_Enter:
	@IF	al {} 9  No_Tab
	jmp	Go_Enter
      No_Tab:
	@JNZ	al, KeyRead
	jmp	ExtKey

      Invert:
	mov	al, dh
	shr	al, 1
	shr	al, 1
	mov	cl, al
	mov	al, 80h
	shr	al, cl
      _Draw:
	xor	Byte Ptr [si], al
      _Draw_:
	call	DrawChar
	jmp	_Sel_

      InvertLine:
	mov	al, 0FFh
	jmp	_Draw

      ClearLine:
	xor	al, al
      Draw_:
	mov	Byte Ptr [si], al
	jmp	_Draw_

      FillLine:
	mov	al, 0FFh
	jmp	Draw_

      ExtKey:
	mov	bh, 0Fh
	push	ax
	call	SelectEdit
	pop	ax
	mov	al, ah

	@IF	al = 82 _Insert
	@IF	al = 83 _Delete
	@IF	al = 72 _Up
	@IF	al = 77 _Right
	@IF	al = 75 _Left
	@IF	al = 80 _Down
	@IF	al = 23 InvertAll
	@IF	al = 46 ClearAll
	@IF	al = 33 FillAll
	@IF	al = 116 RightAll
	@IF	al = 115 LeftAll
	@IF	al = 118 DownAll
	@IF	al {} 132 NoUpAll
	jmp	UpAll
      NoUpAll:
	@IF	al {} 63 NoInClip
	jmp	InClip
      NoInClip:
	@IF	al {} 64 _Sel
	jmp	FromClip
      _Down:
	@IF	dl { _HIGHT _Line_1
	mov	dl, -1
      _Line_1:
	inc	dl
	jmp	_Select
      _Up:
	@JNZ	dl _Line_16
	mov	dl, HIGHT
      _Line_16:
	dec	dl
	jmp	_Select
      _Left:
	@JNZ	dh _Col_8
	mov	dh, 32
      _Col_8:
	sub	dh, 4
	jmp	_Select
      _Right:
	@IF	dh { 28 _Col_1
	mov	dh, -4
      _Col_1:
	add	dh, 4
      _Sel:
	jmp	_Select

      _Insert:
	ror	Byte Ptr [si], 1
	jmp	_Draw_

      _Delete:
	rol	Byte Ptr [si], 1
	jmp	_Draw_

      InvertAll:
	mov	di, OFFSET InvertAllProc
      All:
	call	MaskAll
	jmp	_Draw_

      ClearAll:
	mov	di, OFFSET ClearAllProc
	jmp	All

      FillAll:
	mov	di, OFFSET FillAllProc
	jmp	All

      RightAll:
	mov	di, OFFSET RightAllProc
	jmp	All

      LeftAll:
	mov	di, OFFSET LeftAllProc
	jmp	All

      DownAll:
	xor	cx, cx
	mov	cl, HIGHT
	mov	di, OFFSET CHARGEN
	add	di, cx
	mov	si, di
	dec	si
	mov	bl, Byte Ptr [si]
	@MOV	es, cs
	std
	REP	movsb
	mov	CHARGEN, bl
	cld
	mov	es, bp
	jmp	_Draw_

      UpAll:
	mov	di, OFFSET UpAllProc
	call	MaskAll
	mov	Byte Ptr [si - 1], bl
	jmp	_Draw_

      FromClip:
	mov	di, OFFSET FromClipProc
	jmp	All_

      InClip:
	mov	di, OFFSET InClipProc
      All_:
	mov	bx, OFFSET CLIPBOARD
	jmp	All

      _Esc:
	@MOV	es, cs
	mov	si, OFFSET OLDFONT
	mov	di, OFFSET CHARGEN
	mov	cl, HIGHT
	REP	movsb
	call	SaveFont
	
      _Enter:
	pop	bx dx
	retn

PRESENT		DB  0C7h

    New_Int_9  PROC  Far
	push	ax
	in	al, 60h
	@IF	al {} 33 Jmp_09h
	@KBD_SHIFT
	@JNBT	al 2 Jmp_09h
	@JNBT	al 3 Jmp_09h
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
	xor	ax, ax
	mov	es, ax
	mov	ax, es:[485h]
	mov	HIGHT, al
	mov	HIGHT2, al
	dec	al
	mov	_HIGHT, al
	mov	es, bp
	mov	di, 168
	lea	si, BORDER
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
	mov	cl, 16
	mov	ax, 0F20h
	REP	stosw
	pop	cx
	mov	ax, 1F20h
	stosw
	mov	al, 0BAh
	stosw
	add	di, 56
      LOOP Next_Line
	call	Show_
	mov	cl, 32
      Next_Sim:
	lodsb
	stosw
      LOOP Next_Sim
	mov	cl, 19
	REP	stosw
	lodsb
	stosw
	add	di, 56
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
	lea	si, TBL
	mov	cl, 3
      Next_S:
	lodsw
	mov	di, ax
	lodsb
	mov	bh, al
	mov	ax, 1D20h
	stosw
	stosw
	stosw
	sub	di, 6
	mov	al, bl
	call	Print_Val
      LOOP Next_S

	call	GetFont
	call	DrawChar

      ReadKey:
	@KBD_READ
	@IF	al = 9  Edit_
	@IF	al {} 13 NoEnter_
	jmp	Enter_
      NoEnter_:
	@IF	al {} 27 NoEsc_
	jmp	Esc_
      NoEsc_:
	@JNZ	al, ReadKey
	mov	bh, 1Fh
	push	ax
	call	Select
	pop	ax
	mov	al, ah
	@IF	al = 63 Insert_ASM
	@IF	al = 64 Insert_PAS
	@IF	al = 72 Up
	@IF	al = 77 Right
	@IF	al = 75 Left
	@IF	al = 80 Down
	@IF	al {} 60 ReadKey
	mov	SAVEFLAG, 1
	jmp	Sel

      Edit_:
	mov	bh, 0Eh
	call	Select
	call	Edit
	jmp	Sel

      Insert_ASM:
	mov	Byte Ptr STRBUF, ' '
	mov	PASCONV, 2C68h
	jmp	Insert

      Insert_PAS:
	mov	Byte Ptr STRBUF, '$'
	mov	PASCONV, 202Ch
	jmp	Insert

      Down:
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
	mov	cs:HIGHT, -1
	jmp	Rets
      Insert:
	mov	BUFS, 0
	call	SaveOldFont
      Rets:
	mov	SUMB, bl
	mov	OLDPOS, dx
	call	RestoreVideo
      _Ret_:
	dec	cs:FLAG
	pop	bp es ds di si dx cx bx ax
	iret
    New_Int_9  ENDP

    Convert:
	@IF	al { 10 Decimal
	add	al, 103
      Decimal:
	xor	al, 30h
	retn

    Buffers:
	push	si ds
	@MOV	ds, cs
	cld
	@IF	BUFS } 0 SimInBuf
	dec	HIGHT
	mov	OLDSI, OFFSET STRBUF
	mov	BUFS, 6
	mov	si, OFFSET OLDFONT + 15
	mov	al, HIGHT
	cbw
	sub	si, ax
	lodsb
	push	ax
	and	al, 0F0h
	shr	al, 4
	call	Convert
	mov	DIGIT1, al
	pop	ax
	and	al, 0Fh
	call	Convert
	mov	DIGIT2, al

      SimInBuf:
	xor	ah, ah
	mov	si, OLDSI
	lodsb
	mov	OLDSI, si
	dec	BUFS
	pop	ds si
	retn

    New_Int16  PROC  Far
	@IF	cs:FLAG } 0 Jmp16
	@IF	cs:HIGHT = -1 Jmp16
	@IF	ah = 1 Func1
	@JZ	ah Func0
      Jmp16:
	DB	0EAh
    Old_Vect16  DD 00000000h

      Func1:
	call	Buffers
	dec	cs:OLDSI
	inc	cs:BUFS
	retf	2

      Func0:
	call	Buffers
	iret
    New_Int16  ENDP

    New_Int_28  PROC  Far
	@IF	cs:SAVEFLAG = 0 Jmp_28h
	push	ax bx cx dx si di es ds
	@MOV	ds, cs
	mov	dx, OFFSET FILENAME
	mov	ah, 3Ch
	xor	cx, cx
	int	21h
	jc	Err_28h
	mov	bx, ax

	call	OpenCharGen
	xor	si, si
	mov	cx, 256
	cld

      Next_Sim_:
	mov	di, OFFSET CHARGEN
	push	si cx
	xor	cx, cx
	mov	cl, cs:HIGHT2
	REP	movsb
	push	ds
	@MOV	ds, cs
	mov	cl, HIGHT2
	mov	ah, 40h
	mov	dx, OFFSET CHARGEN
	int	21h
	pop	ds cx si
	jc	Err_28h
	add	si, 32
      LOOP	Next_Sim_
	call	CloseCharGen
	mov	ah, 3Eh
	int	21h
      Err_28h:
	pop	ds es di si dx cx bx ax
	mov	cs:SAVEFLAG, 0
      Jmp_28h:
	DB	0EAh
    Old_Vect28  DD 00000000h
    New_Int_28  ENDP

FLAG     	DB  0
SAVEFLAG	DB  0
SUMB		DB  0
OLDPOS		DW  0
HIGHT		DB  0
HIGHT2		DB  0
_HIGHT		DB  0
BORDER		DB  '╔═╗╟─╢║ Bin         Oct    Dec    Hex ║╚═╝'
TBL		DW  3082
		DB  8
		DW  3096
		DB  10
		DW  3110
		DB  16
CHARGEN		DB  17 DUP(0)
OLDFONT		DB  16 DUP(0)
CLIPBOARD	DB  16 DUP(0)
FILENAME	DB  'ASCII.FNT', 0
OLDSI		DW  0
BUFS		DB  0
STRBUF		DB  ' 0'
DIGIT1		DB  '0'
DIGIT2		DB  '0'
PASCONV		DW  0

END_RESIDENT:

INIT:
	@MOV	ds, cs
	mov	es, Word Ptr ds:[2Ch]
	xor	ax, ax
	xor	di, di
	cld
      Scan_Env:
	scasb
	jne	Scan_Env
	cmp	al, Byte Ptr es:[di]
	jne	Scan_Env
	add	di, 3
	@MOV	ds, es
	mov	dx, di
	mov	ax, 3D00h
	int	21h
	@MOV	ds, cs
	jnc	Get_Length
      IO_Error:
	@DOS_PRINT_STR	IOErrorMsg
	jmp	Quit
      Wrong_CRC:
	@DOS_PRINT_STR	BadCRCMsg
	jmp	Quit

      Get_Length:
	mov	bx, ax
	xor	cx, cx
	xor	dx, dx
	mov	ax, 4202h
	int	21h
	jc	IO_Error
	cmp	ax, Word Ptr FileLength
	jne	Wrong_CRC
	cmp	dx, Word Ptr FileLength + 2
	jne	Wrong_CRC
	mov	ah, 3Eh
	int	21h
	jc	IO_Error

	mov	ax, 1A00h
	int	10h
	@IF	al {} 1Ah Not_VGA
	jmp	TypeFound
      Not_VGA:
	xor	ax, ax
	mov	es, ax
	mov	al, 2
	test	Byte Ptr es:[487h], 8
	jz	TypeFound
	@DOS_PRINT_STR	NotMsg
	jmp	Quit
      TypeFound:
	@VID_SET_CHAR	0DDh 1 FONT1
	@VID_SET_CHAR	0DEh 1 FONT2
	@VID_PrintStr	StartMsg 0Dh StartMsgLen
	@VID_PrintStr	StartMsg1 0Ah StartMsg1Len

	mov	si, 81h
      Nexts_:
	lodsb
	@IF	al = ' ' Nexts_
	and	al, 0DFh
	@IF	al {} 'H' Test_Presents
	@VID_PrintStr	HelpMsg 0Ah HelpMsgLen
	@VID_PrintStr	PressMsg 0Ch PressMsgLen
	@KBD_READ
	@VID_PrintStr	HelpMsg2 0Ah HelpMsg2Len
	jmp	Quit

      Test_Presents:
	@DOS_GET_VECT 09h
	cmp	Byte Ptr es:[bx - 1], 0C7h
	jne	SetResident

	mov	si, 81h
      Nexts:
	lodsb
	@IF	al = ' ' Nexts
	and	al, 0DFh
	@IF	al {} 'U' Already
	jmp	Unload

      SetResident:
	mov	Word Ptr Old_Vect09, bx
	mov	Word Ptr Old_Vect09 + 2, es
	mov	ax, 3528h
	int	21h
	mov	Word Ptr Old_Vect28, bx
	mov	Word Ptr Old_Vect28 + 2, es
	mov	al, 16h
	int	21h
	mov	Word Ptr Old_Vect16, bx
	mov	Word Ptr Old_Vect16 + 2, es
	mov	ax, ds:[2Ch]
	cli
	@DOS_FREE_MEM	ax
	lea	dx, New_Int_9
	mov	ax, 2509h
	int	21h
	lea	dx, New_Int_28
	mov	al, 28h
	int	21h
	lea	dx, New_Int16
	mov	al, 16h
	int	21h
	sti
	@VID_PrintStr	InstMsg 0Bh InstMsgLen
	mov	dx, OFFSET END_RESIDENT
	int	27h

      Already:
	@VID_PrintStr	AlreadyMsg 0Bh AlreadyMsgLen
	@VID_PrintStr	AlreadyMsg2 0Bh AlreadyMsg2Len
      Quit:
	mov	ax, 4C00h
	int	21h

      Unload:
	cli
	lds	dx, DWord Ptr es:Old_Vect09
	mov	ax, 2509h
	int	21h
	lds	dx, DWord Ptr es:Old_Vect16
	mov	al, 16h
	int	21h
	lds	dx, DWord Ptr es:Old_Vect28
	mov	al, 28h
	int	21h
	@DOS_FREE_MEM
	sti
	@VID_PrintStr	UnloadMsg 0Bh UnloadMsgLen
	jmp	Quit

StartMsg	DB  'RFE - Resident Font Editor.  Version 1.2', CR, LF
StartMsgLen	=   $ - StartMsg
StartMsg1	DB  '▐▌ 15.12.93 by RDA Software', CR, LF
StartMsg1Len	=   $ - StartMsg1
AlreadyMsg	DB  'Already '
InstMsg		DB  'Installed.', CR, LF
		DB  'Use  Ctrl+Alt+F   for activate.', CR, LF
		DB  'Run  rfe[.com] h  for help.', CR, LF
AlreadyMsgLen   =   $ - AlreadyMsg
InstMsgLen      =   $ - InstMsg
AlreadyMsg2	DB  'Run  rfe[.com] u  for unload.', CR, LF
AlreadyMsg2Len  =   $ - AlreadyMsg2
UnloadMsg	DB  'Unloaded.', CR, LF
UnloadMsgLen    =   $ - UnloadMsg
HelpMsg		DB  '  УПРАВЛЯЮЩИЕ КЛАВИШИ:', CR, LF
		DB  'В режиме выбора символа:', CR, LF
		DB  'F2    - записать всю кодовую таблицу в файл ASCII.FNT', CR, LF
                DB  'F5    - скопировать описание символа в буфер клавиатуры в HEX формате,', CR, LF
		DB  '        следуя соглашениям Ассемблера', CR, LF
		DB  'F6    - скопировать описание символа в буфер клавиатуры в HEX формате,', CR, LF
		DB  '        следуя соглашениям Паскаля', CR, LF
		DB  'Tab   - перети в режим редактирования', CR, LF
		DB  'Enter - вставить подсвеченный символ в буфер клавиатуры', CR, LF
		DB  'Esc   - выйти из программы', CR, LF
HelpMsgLen	=   $ - HelpMsg
PressMsg	DB  'Press any key...', CR, LF
PressMsgLen	=   $ - PressMsg
HelpMsg2	DB  'В режиме редактирования:', CR, LF
		DB  'F5         - скопировать символ в Clipboard', CR, LF
		DB  'F6         - скопировать символ из Clipboard', CR, LF
		DB  'Space      - инвертировать пиксел', CR, LF
		DB  '*          - инвертировать строку', CR, LF
		DB  '-          - очистить строку', CR, LF
		DB  '+          - заполнить строку', CR, LF
		DB  'Insert     - сдвинуть строку вправо', CR, LF
		DB  'Delete     - сдвинуть строку влево', CR, LF
		DB  'Alt+I      - инвертировать весь символ', CR, LF
		DB  'Alt+C      - очистить весь символ', CR, LF
		DB  'Alt+F      - заполнить весь символ', CR, LF
		DB  'Ctrl+Right - сдвинуть весь символ вправо', CR, LF
		DB  'Ctrl+Left  - сдвинуть весь символ влево', CR, LF
		DB  'Ctrl+PgUp  - сдвинуть весь символ вверх', CR, LF
		DB  'Ctrl+PgDn  - сдвинуть весь символ вниз', CR, LF
		DB  'Tab, Enter - вернуться в режим выбора символа, сохранив изменения', CR, LF
		DB  'Esc        - вернуться в режим выбора символа, отменив изменения', CR, LF
HelpMsg2Len	=   $ - HelpMsg2
FileLength	DD  3568
NotMsg		DB  'EGA/VGA not found.', CR, LF, '$'
BadCRCMsg	DB  'File length incorrect.', CR, LF, '$'
IOErrorMsg	DB  'I/O Error.', CR, LF, '$'
FONT1		DB  000h, 0E0h, 038h, 00Ch, 0CCh, 066h, 006h, 006h
		DB  066h, 0CCh, 00Ch, 038h, 0E0h, 000h, 000h, 000h
FONT2		DB  000h, 007h, 01Ch, 030h, 033h, 066h, 066h, 066h
		DB  066h, 033h, 030h, 01Ch, 007h, 000h, 000h, 000h
END START
