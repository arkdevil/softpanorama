		Title		Evelgarten EGA\VGA symbol generation

		Page	64,

Smile		Segment	Byte Public

Br		Equ	Byte Ptr
Wr		Equ	Word Ptr
Of		Equ	Offset
Inpsp		Equ	5ch

Movtt		Macro	A,B

		Push	B
		Pop	A

		Endm

		Assume	Cs: Smile, Ds: Smile

		Org	100h
Start:
		Jmp	Ito
Int8:
		Push	Ds Ax Bx Cx Dx Si Di

		Movtt	Ds,Cs
		Mov	Si,(Of Tau - Of Int8) + Inpsp

		Dec	Ds: Br [Si]
		Jnz	Outint8

		Cli				; Не обязательно, но
						; следует использовать
		Cld
		Xor	Cx,Cx
		Mov	Br [Si],20h
		Inc	Si

		Call	En_set			; Разрешение генерации

		Mov	Ds,Cx

		Mov	Dx,Ds: [485h]		; Размер символа
		Dec	Dx			; из области BIOS-а

		Jmp	Short Cik
						; Для PSP, область параметра
		Db	0,0dh			; В программе смещение 27h
Cik:
		Xor	Si,Si			; Начальное смещение
		Mov	Ch,0a0h			; Графическая область,
		Mov	Ds,Cx			; используемая для генерации

		Mov	Ch,1			; Один набор (256 символов),
Ci:						; а вообще-то их до 8
		Mov	Bx,Si
		Mov	Di,Si			; Начало символа
		Add	Di,Dx			; Конец символа
Sy:
		Lodsb
Simo:
		Call	Sink			; Переворачивание символа

		Cmp	Si,Di			; Конец символа ?
		Jbe	Sy

		Mov	Si,Bx
		Add	Si,20h			; Следующий символ

		Loop	Ci

		Movtt	Ds,Cs
		Mov	Si,(Of Set2 - Of Int8) + Inpsp

		Call	En_set			; Завершение генерации

		Xor	Br Ds: (Of Simo+1 - Of Int8) + Inpsp,2

		Sti
Outint8:
		Pop	Di Si Dx Cx Bx Ax Ds

		Db	0eah
Oldint8		Dd	0

Tau		Db	20h

Set1		Db	2,4			; Параметры включения
		Db	4,7			; генерации
		Db	4,2
		Db	5,0
		Db	6,4

Set2		Db	2,3			; Параметры завершения
		Db	4,3			; генерации
		Db	4,0
		Db	5,10h
		Db	6

Set3		Db	0eh			; Зависит от типа дисплея

En_set:
		Mov	Cl,2
		Mov	Dx,3c4h

		Call	Porty

		Mov	Cl,3
		Mov	Dl,0ceh
Porty:
;		Lodsb				; I метод
;                                       
;		Out	Dx,Al           
;
;		Inc	Dx			; Эти два  куска  текста
;                                               ; аналогичны и представ-
;		Lodsb                           ; ляют два различных ме-
;                                               ; тода общения с портами
;		Out	Dx,Al
;
;		Dec	Dx

		Lodsw				; II метод

		Out	Dx,Ax

		Loop	Porty

		Retn
Sim1:
		Push	Cx			; Вращение символа
						; относительно
		Mov	Cl,8			; вертикальной оси
T:
		Rcr	Al,1
		Rcl	Ah,1

		Loop	T

		Pop	Cx

		Mov	[Si-1],Ah

		Retn
Sim2:
		Xchg	Al,[Di]			; Вращение символа
		Mov	[Si-1],Al		; относительно
						; горизонтальной оси
		Dec	Di

		Retn

		Jmp	Short Sim1	       ; Разветвление
Sink:
		Jmp	Short Sim2

		Jmp	Short Sim1             ; Страховка при трансляции

Lint8		Equ	$ - Of Int8

Kito:
		Mov	Ax,Ds
		Inc	Ax
		Add	Ax,Ds: [3]

		Retn
Ito:
		Xor	Ax,Ax
		Mov	Ds,Ax

		Mov	Al,Ds: [487h]		; 0 - EGA/VGA отсутствует

		Cmp	Al,0
		Je	Nega

		Test	Al,2

		Movtt	Ds,Cs

		Jz	Yega

		Mov	Br Set3,0ah		; Монохромный дисплей
Yega:
		Mov	Ax,3508h
		Int	21h

		Mov	Wr Oldint8,Bx
		Mov	Wr Oldint8+2,Es

		Mov	Ah,52h
		Int	21h

		Mov	Ds,Es: [Bx-2]

		Call	Kito
Ito0:
		Mov	Ds,Ax

		Call	Kito

		Cmp	Wr Ds: [1],50h
		Jbe	Ito0

		Mov	Dx,Ax
		Inc	Dx
Ito1:
		Mov	Ds,Ax

		Call	Kito

		Mov	Bx,Ds: [1]

		Cmp	Dx,Bx
		Jae	Ito1

		Mov	Es,Bx
		Movtt	Ds,Cs

		Cld
		Mov	Di,Inpsp
		Mov	Dx,Di
		Mov	Si,Of Int8
		Mov	Cx,Lint8

		Rep	Movsb

		Movtt	Ds,Es

		Mov	Ax,2508h
		Int	21h
Nega:
		Mov	Ax,4c00h
		Int	21h

Smile		Ends

		End	Start
