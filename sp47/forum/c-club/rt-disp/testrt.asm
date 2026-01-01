PAGE		64,132

		INCLUDE	rtdef.inc

DispAddr	MACRO
		LOCAL	d_1
		int	11h
		and	ax,30h
		cmp	ax,30h
		mov	ax,0B000h
		je	d_1
		add	ax,800h
d_1:
		ENDM


seg_a		segment
		assume	cs:seg_a, ds:seg_a

		org	100h

start:		jmp	begin

Pr_name		db	0

		.Create_PCB	P_block, 0, 1, Tp_Simple, St_Passive

		db	80h dup (?)
Stack		db	0
Display		dw	0
Msg		db	'H e l l o ,   M i c h a e l   ! ! !'
		db	45 dup (' ')
Char		dw	0

Proc_1:
		.Reset_Flag	10
		mov	ax,Display
		mov	es,ax
		mov 	cl,Pr_name
		xor	ch,ch
		dec 	cx
		xor	di,di
		jcxz	eee
mmm:
		add 	di,160
		loop	mmm
eee:
		mov	ah,0Fh
		cld
		mov	cx,80
		mov	si,OFFSET Msg
		add	si,Char
		inc	Char
		cmp	Char,80
		jb	p_1_2
		mov	Char,0
p_1_2:
		lodsb
		cmp	si,OFFSET Char
		jb	p_2
		mov	si,OFFSET Msg
p_2:
		stosw
		loop	p_1_2
p_1_1:
		.RunOnTime	Pr_name,1

begin:
		DispAddr
		mov	Display,ax

		.Install	P_block,cs,<OFFSET Proc_1>,cs,cs,<OFFSET Stack>,cs,cs

		or	al,al
		jz	Ok
		mov	dx,OFFSET Err
		mov	ah,9
		int	21h
		int	20h
Ok:
		mov	al,P_block+P_id
		mov	Pr_name,al
		.RunOnTime	Pr_name,18

		mov	dx,OFFSET Okm
		mov	ah,9
		int	21h

		int	34h
		int	34h
		int	34h
		int	34h
		int	34h
		int	34h
		int	34h

		mov	dx,OFFSET begin
		int	27h

Err		db	0Dh, 0Ah, 'Error', 0Dh, 0Ah, '$'
Okm		db	0Dh, 0Ah, 'Ok', 0Dh, 0Ah, '$'

seg_a		ends

		end	start
