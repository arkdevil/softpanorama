	page	60,132
	title	*** ALT - display & keyboard driver. Version 1.4

Ctrl	equ	00000100b
Alt	equ	00001000b
Rus	equ	00000001b

biosdata	segment	at	40h
	org	17h
kb_flag		db	?
kb_flag_1	db	?
biosdata	ends

kb_data	equ	60h
kb_ctl	equ	61h
key_A	equ	1Eh
key_b	equ	30h

eoi	equ	20h

FAR_CALL equ	09Ah
FAR_JUMP equ	0EAh

TestNum	equ	4321h
Basic	equ	key_B
Altern	equ	key_A

space	equ	' '
tab	equ	9

ALTseg	segment
	assume	cs:ALTseg
	org	80h
strlen	db	?
string	label	byte
	org	100h
program:
testword label	word
	jmp	init		;Переход на программу инициализации

new09h	proc	far
	push	ds
	push	ax

	mov	ax, biosdata
	mov	ds, ax

	assume	ds:biosdata

	test	kb_flag, Ctrl
	jz	no_control
	test	kb_flag, Alt
	jz	no_control

	in	al, kb_data
	cmp	al, key_A
	je	set
	cmp	al, key_B
	jne	no_control
set:
	mov	cs:code, al
	cli
	in	al, kb_ctl
	mov	ah, al
	or	al, 80h
	out	kb_ctl, al
	mov	al, ah
	out	kb_ctl, al
	mov	al, eoi
	out	20h, al
	pop	ax
	pop	ds
	iret

no_control:
	mov	al, kb_flag_1
	and	al, Rus
	mov	cs:russian, al

	assume	ds:nothing

	pop	ax
	pop	ds

db	FAR_JUMP
	old09h	dd	?
new09h	endp

new10h	proc	far
	push	ds
	push	cs
	pop	ds
	
	assume	ds:ALTseg
	
	cmp	code, Basic
	je	quit10h

	cmp	ah, 9
	je	m2
	cmp	ah, 10
	je	m2
	cmp	ah, 14
	je	m2
	cmp	ah, 8
	jne	quit10h

	pushf
	call	dword ptr old10h

	call	BasToAlt
	pop	ds
	iret
	
m2:
	cmp	al, 0DFh	
	ja	quit10h
	cmp	al, 0B0h
	jb	m3
	push	bx
	mov	bx, offset maskAB-0B0h
	xlat
	pop	bx
	jmp	short quit10h
m3:
	cmp	al, 80h
	jb	quit10h
	add	al, 30h

quit10h:
	push	word ptr code
	mov	byte ptr code, Basic	;для исключения
					;повторного перекодирования
	pushf
db	FAR_CALL
	old10h	dd	?

	pop	word ptr code
	pop	ds
	iret
	assume	ds:nothing
new10h	endp

new16h	proc	far
	pushf

	cmp	ax, TestNum
	je	drvcall

	cmp	ah, 2
	je	quit16h

	popf

	push	ds
	push	cs
	pop	ds

	assume	ds:ALTseg

	pushf
	call	dword ptr old16h
	pushf

	cmp	code, Basic
	je	m7
	cmp	ah, 0		;набрано через ALT и перекодировать
	je	m7		;не нужно

	call	BasToAlt

	cmp	russian, 0	;когда русский режим выключен,
	je	m7		;все скан-коды совпадают

	cmp	al, 0		;скан-коды специальных клавиш
	je	m7		;так же совпадают

	xchg	al, ah

	cmp	al, 10h
	jb	m6
	cmp	al, 5Bh
	ja	m6

	push	bx
	mov	bx, offset maskSC-10h
	cmp	al, 38h
	jb	m4
	cmp	al, 54h
	jb	m5
	sub	bx, 1Ch
m4:
	xlat
m5:
	pop	bx
m6:
	xchg	al, ah
m7:
	popf
	pop	ds
	ret	2

	assume	ds:nothing

drvcall:
	cmp	bx, 0
	jne	quit16h
	cmp	ds:testword, ax
	jne	quit16h

	mov	bx, ax		;отзыв во второй раз запущеному драйверу
	push	cs
	pop	es
	popf
	iret

quit16h:
	popf
db	FAR_JUMP
	old16h	dd	?
new16h	endp

BasToAlt proc	near
	cmp	al, 80h
	jb	m9
	cmp	al, 0AFh
	ja	m8

	push	bx
	mov	bx, offset maskBA-80h
	xlat
	pop	bx
	jmp	short m9
m8:	
	cmp	al, 0DFh
	ja	m9
	
	sub	al, 30h
m9:	ret
BasToAlt endp	
	
russian	db	?	;отражает состояние клавиатуры
code	db	Basic	;текущая кодировка

maskAB	label	byte	;из альтернативной в основную кодировку

;	db	0B0h,0B1h,0B2h,0B3h,0B4h,0B5h,0B6h,0B7h
;	db	0B8h,0B9h,0BAh,0BBh,0BCh,0BDh,0BEh,0BFh
;	db	0C0h,0C1h,0C2h,0C3h,0C4h,0C5h,0C6h,0C7h
;	db	0C8h,0C9h,0CAh,0CBh,0CCh,0CDh,0CEh,0CFh
;	db	0D0h,0D1h,0D2h,0D3h,0D4h,0D5h,0D6h,0D7h
;	db	0D8h,0D9h,0DAh,0DBh,0DCh,0DDh,0DEh,0DFh
	db	09Bh,09Ch,09Dh,0A5h,0A7h,083h,084h,085h
	db	086h,097h,095h,091h,092h,08Bh,08Ch,0A1h
	db	0A3h,0A8h,0A6h,0A9h,0A4h,0AAh,08Dh,08Eh
	db	093h,090h,098h,096h,099h,094h,09Ah,080h
	db	081h,082h,087h,088h,089h,08Ah,08Fh,09Eh
	db	09Fh,0A2h,0A0h,0ABh,0ACh,0ADh,0AEh,0AFh
;	db	0E0h,0E1h,0E2h,0E3h,0E4h,0E5h,0E6h,0E7h
;	db	0E8h,0E9h,0EAh,0EBh,0ECh,0EDh,0EEh,0EFh
;	db	0F0h,0F1h,0F2h,0F3h,0F4h,0F5h,0F6h,0F7h
;	db	0F8h,0F9h,0FAh,0FBh,0FCh,0FDh,0FEh,0FFh

maskBA	label	byte	;из основной в альтернативную кодировку

	db	0CFh,0D0h,0D1h,0B5h,0B6h,0B7h,0B8h,0D2h
	db	0D3h,0D4h,0D5h,0BDh,0BEh,0C6h,0C7h,0D6h
	db	0C9h,0BBh,0BCh,0C8h,0CDh,0BAh,0CBh,0B9h
	db	0CAh,0CCh,0CEh,0B0h,0B1h,0B2h,0D7h,0D8h
	db	0DAh,0BFh,0D9h,0C0h,0C4h,0B3h,0C2h,0B4h
	db	0C1h,0C3h,0C5h,0DBh,0DCh,0DDh,0DEh,0DFh
;	db	080h,081h,082h,083h,084h,085h,086h,087h
;	db	088h,089h,08Ah,08Bh,08Ch,08Dh,08Eh,08Fh
;	db	090h,091h,092h,093h,094h,095h,096h,097h
;	db	098h,099h,09Ah,09Bh,09Ch,09Dh,09Eh,09Fh
;	db	0A0h,0A1h,0A2h,0A3h,0A4h,0A5h,0A6h,0A7h
;	db	0A8h,0A9h,0AAh,0ABh,0ACh,0ADh,0AEh,0AFh
;	db	0E0h,0E1h,0E2h,0E3h,0E4h,0E5h,0E6h,0E7h
;	db	0E8h,0E9h,0EAh,0EBh,0ECh,0EDh,0EEh,0EFh
;	db	0F0h,0F1h,0F2h,0F3h,0F4h,0F5h,0F6h,0F7h
;	db	0F8h,0F9h,0FAh,0FBh,0FCh,0FDh,0FEh,0FFh

maskSC	label	byte	;для скан-кодов

;	db	000h,001h,002h,003h,004h,005h,006h,007h
;	db	008h,009h,00Ah,00Bh,00Ch,00Dh,00Eh,00Fh
	db	02Ch,020h,014h,023h,031h,01Fh,012h,030h
	db	024h,022h,000h,000h,01Ch,01Dh,021h,02Eh
	db	026h,01Eh,016h,01Ah,010h,013h,025h,000h
	db	000h,000h,02Ah,000h,019h,032h,011h,027h
	db	033h,015h,02Fh,000h,000h,035h,036h,000h

;	db	038h,039h,03Ah,03Bh,03Ch,03Dh,03Eh,03Fh
;	db	040h,041h,042h,043h,044h,045h,046h,047h
;	db	048h,049h,04Ah,04Bh,04Ch,04Dh,04Eh,04Fh
;	db	050h,051h,052h,053h

	db	017h,018h,029h,028h,02Dh,034h,05Ah,02Bh

;	db			    05Ch 05Dh,05Eh,05Fh
;	db	060h,061h,062h,063h,064h,065h,066h,067h
;	db	068h,069h,06Ah,06Bh,06Ch,06Dh,06Eh,06Fh
;	db	070h,071h,072h,073h,074h,075h,076h,077h
;	db	078h,079h,07Ah,07Bh,07Ch,07Dh,07Eh,07Fh

_end_	label	byte	;конец pезидентной части пpогpаммы


	assume	ds:ALTseg

ttl	db	13,10
	db	'ALT - ISKRA display & keyboard driver. Version 1.4',13,10
	db	'Copyright (C) 1991 by Alexander V. Lukyanov',13,10
	db	'Yaroslavl, USSR, (0852) 11-18-08',13,10,10,'$'

curcode	db	'Current code is $'
a_msg	db	'alternative$'
b_msg	db	'basic$'

help	db	13,10,10
	db	'Use Ctrl+Alt+A or parameter /A to set alternative code,',13,10
	db	'    Ctrl+Alt+B or parameter /B to set basic code.',13,10,10,'$'

errormsg db	'Invalid parameter !',13,10,7,'$'

init:
	mov	dx, offset ttl		;
	mov	ah, 9			;Напечатать заголовок
	int	21h			;

	xor	bx, bx
	mov	ax, TestNum
	mov	testword, ax
	int	16h

	mov	cl, strlen
	xor	ch, ch
	jcxz	continue
	mov	si, offset string
search_parameter:
	lodsb
	cmp	al, space
	je	next
	cmp	al, tab
	je	next
	cmp	al, '/'
	je	found
error:
	mov	dx, offset errormsg
	mov	ah, 9
	int	21h
	jmp	short continue
found:
	lodsb
	cmp	al, 'A'
	je	a_set
	cmp	al, 'B'
	jne	error
	mov	es:code, Basic
	jmp	short continue
a_set:	mov	es:code, Altern
	jmp	short continue
next:
	loop	search_parameter

continue:
	mov	dx, offset curcode
	mov	ah, 9
	int	21h
	cmp	es:code, Basic
	jne	alternative
	mov	dx, offset b_msg
	jmp	short print
alternative:
	mov	dx, offset a_msg
print:	mov	ah, 9
	int	21h

	mov	dx, offset help
	mov	ah, 9
	int	21h

	cmp	bx, TestNum
	jne	no_installed		;если драйвер уже установлен,
	int	20h			;выйти нерезидентно

no_installed:
	mov	ax, 3516h		;
	int	21h			;
	mov	word ptr old16h, bx	;
	mov	word ptr old16h+2, es	;
	mov	ax, 3510h		;
	int	21h			;сохранить векторы
	mov	word ptr old10h, bx	;
	mov	word ptr old10h+2, es	;
	mov	ax, 3509h		;
	int	21h			;
	mov	word ptr old09h, bx	;
	mov	word ptr old09h+2, es	;

	mov	dx, offset new16h	;
	mov	ax, 2516h		;
	int	21h			;
	mov	dx, offset new10h	;
	mov	ax, 2510h		;установить новые векторы
	int	21h			;
	mov	dx, offset new09h	;
	mov	ax, 2509h		;
	int	21h			;

	mov	dx, offset _end_	;
	int	27h			;и выйти с сохранением в памяти

ALTseg	ends
	end	program
