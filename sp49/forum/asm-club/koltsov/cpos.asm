;;  
;; Модуль		CPOS.ASM;
;; Транслятор		TASM 2.0;
;; Компоновщик		TLINK 3.0;
;; Транстировать:	path\tasm cpos,cpos,cpos /zi /N
;; Линковать:		path\tlink cpos /x /t
;;
;; Автор -	Владимир Кольцов.
;;
;; Адрес:	340009, г. Донецк, ул. Сенявина, 25.
;; Телефон:	23-70-33.
;;
;;
		.model tiny
		LOCALS	@@
		IDEAL

bptr		equ	byte ptr
wptr		equ	word ptr
bios_scr_width	equ	44Ah

K_Enter		equ	1C0Dh
K_Esc		equ	011Bh

K_Left		equ	4B00h
K_Right		equ	4D00h
K_Up		equ	4800h
K_Down		equ	5000h
K_End		equ	4F00h
K_Home		equ	4700h
K_PgDn		equ	5100h
K_PgUp		equ	4900h

Zerof		equ	01000000b

InMemoryCode	equ	0F1h
UnLoadingCode	equ	0F3h

str_key		equ	offset Usage + 16


SEGMENT		VOFFS_READER	BYTE
		Assume	cs:VOFFS_READER, ds:VOFFS_READER

		org	100h

Reader:
active		db	0E9h			;; jmp
videoseg	dw	offset end_prog - $ - 2	;; end_prog



sys_x		equ	70h	;;
sys_y		equ	71h	;;

c_x		equ	72h	;;
c_y		equ	73h	;;
voffs		equ	74h	;;

new_cursor	equ	76h
vpage		equ	byte ptr 78h

sbuffer		equ	80h + DecSize + HexSize + CalcSize
end_x		equ	5Ch + 18
end_y		equ	5Ch + 13

Proc		Int09	far
		cli
		push	ax
		in	al, 60h
cmp_al_code	db	3Ch
scan_code	db	39h
		je	Called
Jmp_old:
		pop	ax

jmp_far		db	0EAh
Off09_1		dw	0000h
Seg09_1		dw	0000h

Called:
		test	[bptr cs:active], 1
		jz	Jmp_old

		mov	ah, 02h
		int	16h
and_al_code	db	24h
key_flags	db	08h
		jz	Jmp_old

		cli
		pushf
call_far_09	db	09Ah
Off09_2		dw	0000h
Seg09_2		dw	0000h
		sti

		and	[bptr cs:active], 0
		jmp	CVReader
End_of_Work:
		cli
		or	[bptr cs:active], 1
		pop	ax
		iret
Endp		Int09



Proc		CVReader
		push	bp bx cx dx ds es di si
		push	cs
		pop	ds
		mov	[videoseg], 0B000h
		mov	ah, 0Fh
		int	10h
		mov	[vpage], bh
		cmp	al, 7
		ja	End_of_Work
		je	@@1
		add	[videoseg], 0800h
		mov	[bptr 5Eh], '8'
@@1:
		xor	ax, ax
		mov	es, ax
		mov	ax, [es:bios_scr_width]
		dec	al
		mov	[sys_x], al
		xor	dl, dl
		xor	bh, bh
		mov	ax, 1130h
		int	10h
		or	dl, dl	;; ?
		jnz	@@2
		mov	dl, 18h
@@2:
		mov	[sys_y], dl
		mov	di, [wptr voffs]
;; Save cursor

		mov	ah, 03h
		mov	bh, [vpage]
		int	10h
		mov	[cursor_xy], dx
		mov	[cursor_size], cx
;; Set new cursor
		mov	ah, 01h
		mov	cx, [new_cursor]
		int	10h

		mov	es, [videoseg]
Save_Buff:
		xor	si, si
		mov	di, sbuffer
		mov	cx, 20

@@3:
		mov	ax, [es:si]
		mov	[di], ax
		add	si, 2
		add	di, 2
		loop	@@3

		mov	bx, [wptr c_x]

Show_Info:

;; Calculate video offset

		db	0E8h
call_calc	dw	$	;	call CalvVOffs

;; Convert string

		mov	al, [bptr voffs + 1]
		mov	si, 62h
		db	0E8h
call_hts1	dw	$	;	call	HexToStr

		mov	al, [bptr voffs]
		mov	si, 64h
		db	0E8h
call_hts2	dw	$	;	call	HexToStr

		xor	ah, ah
		mov	al, bh		;; current Y
		mov	cx, 2
		mov	si, end_y
		db	0E8h
call_dts1	dw	$	;	call	DecToStr

		xor	ah, ah
		mov	al, bl		;; current X
		mov	cx, 2
		mov	si, end_x
		db	0E8h
call_dts2	dw	$	;	call	DecToStr

;; Write string
		xor	di, di
		mov	si, 5Ch
		mov	ah, 15
		mov	cx, 20
WriteInfo:
		mov	al, [bptr si]
		mov	[es:di], ax
		add	di, 2
		inc	si
		loop	WriteInfo

;; new cursor positins

		mov	ah, 02h
		mov	bh, [vpage]
		mov	dh, [bptr c_y]
		mov	dl, [bptr c_x]
		int	10h

;; Wait key
		xor	ah, ah
		int	16h

		mov	bx, [wptr c_x]		;; BH - current Y
						;; BL - current X
		mov	dx, [wptr sys_x]	;; DH - max Y
						;; DL - max X

		cmp	ax, K_Esc
		jz	The_End
		cmp	ax, K_Left
		jz	Go_Left
		cmp	ax, K_Right
		jz	Go_Right
		cmp	ax, K_Up
		jz	Go_Up
		cmp	ax, K_Down
		jz	Go_Down
		cmp	ax, K_PgDn
		jz	Go_PgDn
		cmp	ax, K_PgUp
		jz	Go_PgUp
		cmp	ax, K_Home
		jz	Go_Home
		cmp	ax, K_End
		jz	Go_End
Go_SV:
		jmp	Show_Info
Go_Left:
		or	bl, bl
		jz	Go_SV
		dec	bl
		jmp	short Go_SV
Go_Right:
		cmp	bl, [sys_x]
		jz	GO_SV
		inc	bl
		jmp	short Go_SV
Go_Up:
		or	bh, bh
		jz	Go_SV
		dec	bh
		jmp	short Go_SV
Go_Down:
		cmp	bh, [sys_y]
		jz	Go_SV
		inc	bh
		jmp	short Go_SV
Go_PgDn:
		mov	bh, dh
		jmp	short Go_SV
Go_PgUp:
		xor	bh, bh
		jmp	short Go_SV
Go_Home:
		xor	bl, bl
		jmp	short Go_SV
Go_End:
		mov	bl, dl
		jmp	short Go_SV

The_End:

;; Restore screen

		xor	di, di
		mov	si, sbuffer
		mov	cx, 20
		rep	movsw

;; Restore cursor

		mov	ah, 02h
		mov	bh, [vpage]
		mov	dx, [cursor_xy]
		int	10h

		shr	ah, 1
		mov	cx, [cursor_size]
		int	10h

		pop	si di es ds dx cx bx bp
		jmp	End_of_Work
Endp		CVReader

Proc		Time_IO		far
		cmp	ah, InMemoryCode
		je	@@SayAlready
		cmp	ah, UnloadingCode
		je	@@Unloading
jmp_far_Time	db	0EAh
OffTime_1	dw	0000h
SegTime_1	dw	0000h
@@SayAlready:
		xchg	ah, al
		iret
@@Unloading:
		push	dx ds es

		db	0B8h
Seg09_3		dw	0
		db	0BAh
Off09_3		dw	0

		mov	ds, ax
		mov	ax, 2509h
		int	21h

		db	0B8h
SegTime_2	dw	0
		db	0BAh
OffTime_2	dw	0
		mov	ds, ax
		mov	ax, 251Ah

		int	21h
		push	cs
		pop	es
		mov	ah, 49h
		int	21h
		pop	es ds dx
		iret
Endp		Time_IO

end_prog:
		or	[bptr 80h], 0
		jz	NoParm
		mov	cl, [bptr 80h]
		mov	si, 81h
		call	StrUpr
@@RP:
		mov	ah, '?'
		call	FindChar
		jnz	@@U
		mov	ah, 09h
		mov	dx, offset Help
		int	21h
		mov	dx, offset Usage
		int	21h
		mov	dx, offset Keys
		int	21h
		mov	dx, offset ThankYou
		int	21h
		int	20h
@@U:
		mov	si, 81h
		mov	ah, 'U'
		call	FindChar
		jz	UnLoading
		jmp	short Loading
UnLoading:
		xor	ax, ax
		mov	ah, UnLoadingCode
		int	1Ah
		mov	ah, 09h
		mov	dx, offset UnLoaded
		int	21h
		int	20h
NoParm:
Loading:
		mov	ah, InMemoryCode
		int	1Ah
		cmp	al, InMemoryCode
		jne	IsParK
		mov	ah, 9
		mov	dx, offset Already
		int	21h
		int	20h
IsParK:
		or	[bptr 80h], 0
		jnz	FindKey
		jmp	Init
FindKey:
		mov	cl, [bptr 80h]
		mov	ah, 'K'
		mov	si, 81h
		call	FindChar
		jz	SetKey1
		jmp	Init
SetKey1:
		dec	si
		mov	cx, 3
		mov	di, str_key
		repe	cmpsb
		je	SetKey2
		jmp	Init

SetKey2:
		mov	bx, offset HexTable
		mov	cl, [bptr 80h]
SetKey3:
		mov	al, [bptr si]
		call	IsHex
		lahf
		inc	si
		sahf
		loopnz	SetKey3

		jz	SetKey4
		jmp	Init
SetKey4:
		dec	[count]
		dec	si
SK4:

		xchg	al, ah
		xor	al, al
		xor	dl, dl
@@FindHex:
		mov	al, dl
		xlat	[HexTable]
		cmp	al, ah
		jz	WriteKey
		inc	dl
		cmp	dl, 16
		jb	short @@FindHex
		inc	si
		jmp	short SetKey2
WriteKey:
		cmp	[count], 4
		jnz	@CL3
		mov	[scan_code], dl
		shl	[scan_code], 1
		shl	[scan_code], 1
		shl	[scan_code], 1
		shl	[scan_code], 1
		jmp	short LoopSK
@CL3:
		cmp	[count], 3
		jnz	@CL2
		or	[scan_code], dl
		jmp	short LoopSK
@CL2:
		cmp	[count], 2
		jnz	@CL1
		mov	[key_flags], dl
		shl	[key_flags], 1
		shl	[key_flags], 1
		shl	[key_flags], 1
		shl	[key_flags], 1
		jmp	short	LoopSK
@CL1:
		or	[key_flags], dl
LoopSK:

		inc	si
		jmp	SetKey2
Init:
		call	Int09Init
		mov	[wptr voffs], 07D0h

		mov	[bptr 5Ch + 6],  '0'
		mov	[bptr 5Ch + 7],  '7'
		mov	[bptr 5Ch + 8],  'D'
		mov	[bptr 5Ch + 9],  '0'

		mov	[bptr 5Ch + 12], '1'
		mov	[bptr 5Ch + 13], '2'
		mov	[bptr 5Ch + 16], '0'
		mov	[bptr 5Ch + 17], '4'
		mov	[bptr 5Ch + 18], '0'

		mov	[bptr c_x], 40
		mov	[bptr c_y], 12

		mov	dx, offset ActivateWith
		mov	ah, 09h
		int	21h



;;
;; Копирование в PSP DecToStr, HexToStr, CalcVOffs
;;
		mov	cx, PspProcSize
		mov	di, 80h
		mov	si, offset DecToStr
		rep	movsb

		mov	ax, 80h
		mov	bx, [call_dts1]
		call	SetAddr

		mov	bx, [call_dts2]
		call	SetAddr

		mov	ax, (80h + DecSize)
		mov	bx, [call_hts1]
		call	SetAddr

		mov	ax, (80h + DecSize)
		mov	bx, [call_hts2]
		call	SetAddr

		mov	ax, (80h + DecSize + HexSize)
		mov	bx, [call_calc]
		call	SetAddr

		mov	cx, 20
		mov	di, 0005Ch
		mov	si, offset inf_str
		rep	movsb

		mov	[wptr new_cursor], 001Fh



		mov	ah, 49h
		mov	es, [2Ch]
		int	21h

		mov	dx, offset end_prog
		int	27h

; DecToStr преобразует 16-битовое число без знака в символьную
; строку ASCII в десятичном формате.
;
; Вход:
;	AX	- число для преобразования;
;       DS:SI	- адрес конца строки для записи преобразованного числа;
;       CX	- количество преобразуемых цифр.
;
; Выход: DS:SI - перобразованная строка.
;
; Изменяемые регистры: AX, BP, CX, DX.
;
Proc		DecToStr
		mov	bp, 10		;used to divide by 10
@@ConvertLoop:
		sub	dx, dx		;convert AX to doubleword in DX:AX
		div	bp		;divide number by 10. Remainder is in
					; DX--this is a one-digit decimal
					; number. Number/10 is in AX
		add	dl, '0'		;convert remainder to a text character
		mov	[si], dl	;put this digit in the string
		dec	si		;point to the location for the
					; next most-significant digit
		loop	@@ConvertLoop	;do the next digit, if any

		ret
Label		EndDec	byte
DecSize		equ	EndDec - DecToStr
Endp		DecToStr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Имя:		HexToStr
;;
;; Преобразовывает 8-битовое шестнадцатиричное
;; в символьную строку.
;;
;; Вход:	AL	- число для преобразования;
;;		DS:SI	- адрес строки.
;;
Proc		HexToStr
		mov	ah, al
		shr	al, 1
		shr	al, 1
		shr	al, 1
		shr	al, 1
		add	al, 90h

		daa
		adc	al, 40h
		daa
		mov	[si], al
		mov	al, ah
		and	al, 0Fh
		add	al, 90h
		daa
		adc	al, 40h
		daa
		mov	[si+1], al
		ret
cursor_xy	dw	0
cursor_size	dw	0
Label		EndHex	byte
HexSize		equ	EndHex - HexToStr
Endp		HexToStr

Proc		CalcVOffs
		mov	[wptr c_x], bx
		xor	si, si
		xor	ax, ax
		mov	al, [sys_x]
		inc	al
		shl	al, 1
		mul	bh
		xchg	si, ax
		mov	al, bl
		shl	al, 1
		add	si, ax
		mov	[wptr voffs], si
		ret

Label		EndCalc	byte
CalcSize	equ	EndCalc - CalcVOffs
Endp		CalcVOffs

PspProcSize	equ	SetAddr - DecToStr

;; ax - PSP address;
;; bx - current call

Proc		SetAddr		near
		push	ax
		sub	ax, [bx]
		sub	ax, 2
		mov	[bx], ax
		pop	ax
		retn
Endp		SetAddr

Proc		Int09Init	near
		push	es

		mov	ax, 3509h
		int	21h
		mov	[Off09_1], bx
		mov	[Off09_2], bx
		mov	[Off09_3], bx
		mov	[Seg09_1], es
		mov	[Seg09_2], es
		mov	[Seg09_3], es

		mov	dx, offset Int09
		mov	ax, 2509h
		int	21h

		mov	ax, 351Ah
		int	21h
		mov	[OffTime_1], bx
		mov	[OffTime_2], bx
		mov	[SegTime_1], es
		mov	[SegTime_2], es

		mov	dx, offset Time_IO
		mov	ax, 251Ah
		int	21h

		pop	es
		retn
Endp		Int09Init

Proc		FindChar	near
		push	cx
@@1:
		lodsb
		cmp	al, ah
		loopnz	@@1

		pop	cx
		retn
Endp		FindChar

Proc		IsHex		near
		cmp	al, '0'
		jb	@@ret
		cmp	al, '9'
		ja	@@Alpa
		jmp	short	@@stz
@@Alpa:
		cmp	al, 'A'
		jb	@@ret
		cmp	al, 'F'
		jbe	@@stz
@@stz:
		lahf
		or	ah, ZeroF
		sahf
@@ret:
		retn
Endp		IsHex

;;;		DS:SI	- string;
;;;		CX	- cuantity of chars for convert.

Proc		StrUpr	near
		push	ax cx si
@@1:
		lodsb
		cmp	al, 'a'
		jb	@@2
		cmp	al, 'z'
		ja	@@2
		sub	[bptr si - 1], 32
@@2:
		loop	@@1

		pop	si cx ax
		retn
Endp		StrUpr

inf_str		db	'[B000:0000, 00, 000]'
Already		db	13, 10, 'Cpos: already installed.', 13, 10, '$'
ActivateWith	db	13, 10, 'The cursor position & video offset, version 1.01'
		db	13, 10, 'Written by V. Koltsov, Donetsk (Ukraine), 1992', 13, 10
Usage		db	13, 10, 'Usage: CPOS [/KEY=<scancode(h)> [<flags(h)>]]'
		db	13, 10, 'Default: /KEY=39,08 (Alt-Spacebar for activate CPOS),'
		db	13, 10, 'type "CPOS /U" for unloading,'
		db	13, 10, 'type "CPOS /?" for help.', 13, 10, '$'
UnLoaded	db	13, 10, 'Cpos: removed from memory.'
ThankYou	db	13, 10, 'Thank you.', 13, 10, '$'
Help		db	13, 10, 'The Cpos help:', '$'
Keys		db	13, 10, 'Keys:'
		db	13, 10, ', , , ', 9, '    - left, right, up, down'
		db	13, 10, 'PgUp', 9, 9, '- first line'
		db	13, 10, 'PgDn', 9, 9, '- last line'
		db	13, 10, 'Home', 9, 9, '- first column'
		db	13, 10, 'End ', 9, 9, '- last column'
		db	13, 10, 'Esc ', 9, 9, '- exit', 13, 10
		db	13, 10, 'Address: Ukraine, 340009, Donetsk, Senyavina st., 25'
		db	13, 10, 9, ' Vladimir N. Koltsov'
		db	13, 10, 'Phone: (0622) 23-70-33$'

count		db	5
HexTable	db	'0123456789ABCDEF'

ENDS		VOFFS_READER

		END Reader