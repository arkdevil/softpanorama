		Page	97,

		Title	It Was Created By  E V E L G A R T E N

J		Segment

		Assume	Cs:J,Es:J,Ds:J,Ss:J

		Include	Macro.Fad
		Include	Macro.Hdt

		Org	100h
Letty:
		Hide4	0

		Bb	' Evelgarten Key Taker '

		Jmp	Initmod
Int16:
		Cmp	Ah,0
		Je	Int16b

		Cmp	Ah,10h
		Jne	Int16a
Int16b:
		Pushf

		Call	Cs: Dr Olda
Newgyk:
		Call	Gyk

		Sti

		Retf	2
Int16a:
		Db	0eah
Olda		Dw	0
Oldb		Dw	0

Gyk:
		Cmp	Cs: Oko,0
		Je	Gyk1

		Retn
Gyk1:
		Push	Ds

		Pushm

		Movtt	Ds,Cs

		Cli

		Mov	Bx,Abuf

		Cmp	Bx,500-1
		Jae	Nogyk

		Shl	Bx,1
		Shl	Bx,1
		Lea	Bx,Abuf+2 [Bx]
		Mov	[Bx],Ax
		Mov	Ax,Tyt
		Mov	Wr [Bx+2],Ax
		Mov	Tyt,0
		Inc	Bbuf
		Inc	Abuf
Nogyk:
		Sti

		Popm

		Pop	Ds

		Retn
Int8:
		Cmp	Cs: Veko,1
		Je	Int8b

		Cmp	Cs: Oko,0
		Je	Int8a

		Push	Cx Ax Bx

		Mov	Bx,Cs: Bbuf
		Sub	Bx,Cs: Abuf
		Shl	Bx,1
		Shl	Bx,1
		Add	Bx,Of Abuf+2

		Dec	Cs: Wr [Bx+2]
		Jnz	Int8d

		Cli

		Mov	Cx,Cs: Wr [Bx]
		Mov	Ah,5
		Int	16h

		Mov	Cs: Tyt,0

		Dec	Cs: Abuf
		Jnz	Int8f

		Mov	Cs: Veko,1
Int8f:
		Sti
Int8d:
		Pop	Bx Ax Cx
Int8a:
		Inc	Cs: Tyt
Int8b:
		Db	0eah
Oldaa		Dw	0
Oldbb		Dw	0

Setmod:
		Cli
		Mov	Ax,Cs
		Mov	Ds,Ax
		Mov	Es,Ax

		Pop	Bx

		Mov	Ss,Ax
		Mov	Sp,Of Outsys
		Sti

		Jmp	Bx
Forme:
		Call	Setmod

		Mov	Bx,Of Compl

		Call	Startmod

		Jmp	Outcom

Espb		Dw	0
D0		Dw	80h
D1		Dw	0
		Dw	5ch
D2		Dw	0
		Dw	6ch
D3		Dw	0
		Dw	14
Startmod:
		Mov	D0,Bx
		Mov	Bx,Of Espb
		Mov	Dx,Of Commod
		Mov	Veko,0
		Mov	Ax,4b00h
		Int	21h

		Retn
Outcom:
		Call	Setmod

		Mov	Ax,3516h
		Int	21h

		Mov	Ax,Es
		Mov	Dx,Cs

		Cmp	Ax,Dx
		Jne	Ti0

		Cmp	Bx,Of Int16
		Jne	Ti0

		Lds	Dx,Dr Olda
		Mov	Ax,2516h
		Int	21h

		Movtt	Ds,Cs

		Mov	Ax,3508h
		Int	21h

		Mov	Ax,Es
		Mov	Dx,Cs

		Cmp	Ax,Dx
		Jne	Ti0

		Cmp	Bx,Of Int8
		Jne	Ti0

		Lds	Dx,Dr Oldaa
		Mov	Ax,2508h
		Int	21h

		Cmp	Cs: Oko,1
		Je	Tiout

		Jmp	Outsys
Tiout:
		Return	00h
Ti0:
		Mov	Wr Newgyk,9090h
		Mov	Wr Newgyk+2,90h

		Mov	Dx,Of Setmod+15
		Mov	Cl,4
		Shr	Dx,Cl
		Movtt	Es,Cs
		Mov	Ah,31h
		Int	21h

Commod		Db	80 Dup (0)
Compl		Db	4,'/c ',79 Dup (0)

Initmod:
		Mov	Al,36
		Out	43h,Al
		Mov	Al,0ffh
		Out	40h,Al
		Out	40h,Al

		Mov	Al,Ds: [80h]

		Cmp	Al,1
		Ja	Initfar
Icv:
		Cmp	Oko,1
		Je	Jii

		Jmp	Commenty
Jii:
		Cip	Jiip
Tioutn:
		Return	00h

		Cb	Jiip,'FadyCrok child process of Fady'
Initfar:
		Call	Setmod

		Mov	D1,Ax
		Mov	D2,Ax
		Mov	D3,Ax

		Mov	Ax,3516h
		Int	21h

		Mov	Oldb,Es
		Mov	Olda,Bx

		Mov	Ax,3508h
		Int	21h

		Mov	Oldbb,Es
		Mov	Oldaa,Bx

		Mov	Si,81h
		Movtt	Es,Cs
		Mov	Di,Of Compl+4
		Xor	Cx,Cx
		Cld
Ti1:
		Lodsb

		Cmp	Al,20h
		Je	Ti1

		Cmp	Al,9
		Je	Ti1

		Cmp	Al,13
		Je	Icv

		Dec	Si
Ti2:
		Lodsb

		Cmp	Al,13
		Je	Ti3

		Stosb

		Inc	Cx

		Jmp	Short Ti2
Tiouta:
		Jmp	Tiout
Ti3:
		Stosb

		Inc	Si

		Mov	Al,Br Compl
		Cbw
		Add	Ax,Cx
		Mov	Br Compl,Al

		Mov	Ah,62h
		Int	21h

		Mov	Es,Bx
		Mov	Es,Es: [2ch]
		Mov	Al,'C'
		Xor	Di,Di
		Mov	Cx,500h
Ti7:
		Push	Cx

		Repne	Scasb

		Cmp	Cx,0
		Je	Tiouta

		Mov	Bx,Di
		Dec	Di
		Mov	Si,Of Mod3
		Mov	Cx,7

		Repe	Cmpsb

		Mov	Di,Bx

		Pop	Cx

		Jne	Ti7

		Mov	Si,Di
		Mov	Di,Of Commod
		Add	Si,6
		Cld
		Movtt	Ds,Es
		Movtt	Es,Cs
Hio1:
		Lodsb

		Cmp	Al,'='
		Jne	Hio1
Hio2:
		Lodsb

		Cmp	Al,20h
		Je	Hio2

		Dec	Si
Ti8:
		Lodsb

		Cmp	Al,0
		Je	Ti9

		Stosb

		Jmp	Short Ti8
Ti9:
		Movtt	Ds,Cs

		Mov	Dx,Of Int16
		Mov	Ax,2516h
		Int	21h

		Mov	Dx,Of Int8
		Mov	Ax,2508h
		Int	21h

		Mov	Bx,Of Commenty+15
		Mov	Cl,4
		Shr	Bx,Cl
		Mov	Ah,4ah
		Int	21h

		Jmp	Forme

Mod3		Db	'COMSPEC',0
Drivestr	Db	'FadyCrok.Com',0
Oko		Db	0
Veko		Db	1
Tyt		Dw	0,0
Bbuf		Dw	0
Abuf		Dw	0
		Dw	1000 Dup (203h)
		Dw	200 Dup (609h)
Outsys:
		Movtt	Ds,Cs
		Movtt	Es,Cs

		Mov	Ds: [16ch+1],Of Bbuf - 1cch - 1

		Mov	Ah,3ch
		Xor	Cx,Cx
		Mov	Dx,Of Drivestr
		Int	21h

		Jc	Erryt1

		Mov	Ax,3d01h
		Xor	Cx,Cx
		Mov	Dx,Of Drivestr
		Int	21h

		Jc	Erryt1

		Mov	Bx,Ax

		Mov	Oko,1
		Mov	Veko,1
		Xor	Ax,Ax
		Mov	Cx,Of Bbuf-1cch
		Mov	Tyt,0
		Mov	Si,1cch
		Mov	Di,Si
Poc:
		Lodsb

		Sub	Al,Ah
		Mov	Ah,Al

		Stosb

		Loop	Poc

		Mov	Ah,40h
		Mov	Cx,Of Outsys-100h
		Mov	Dx,100h
		Int	21h

		Jc	Erryt1

		Mov	Ah,3eh
		Int	21h

		Jc	Erryt1
Tiouts:
		Return	00h
Erryt1:
		Cip	Erro

		Jmp	Tiouts

		Cb	Erro,'File FadyCrok operaiting ERROR'
Commenty:
		Clr

		Mov	Cx,Of Endnew-Of New
		Mov	Dx,Of New
		Mov	Bx,1
		Mov	Ah,40h
		Int	21h

		Jmp	Tiout
New:
		Ed
		Db	'Fady { Subprogramme }'
		Ed
		Db	'	Subprogramme - Module for Start and Take Key'
		Ed
		Db	'	Fady makes module FadyCrok with stored key value'
		Ed
		Db	'	FadyCrok generates key during programme exucution'
		Ed
		Ed
		Ed
		Db	'eTn WwW		A L E X   O   E V E L G A R T E N	 eTn WwW'
		Ed
		Ed
		Db	'	Dos Key Taker Protocoler V 1.0	  30 March 1991'
		Ed
		Ed
		Db	'			(C) Argus Ltd.'
		Ed
		Db	'		Department of Computer Science'
		Ed
		Db	'	  Sverdlovsk National Pedagogical Institute'
		Ed
		Ed
		Db	'	  9, K.Liebkneht st. Sverdlovsk 620219 USSR'
		Ed
		Db	'	       Tel. (8-343-2) 51-52-55  51-95-07'
		Ed
		Db	'		    Telex   221 512  DIANA'
		Ed
		Db	'		       Telefax   511 015'
		Ed
		Ed
		Ed

Endnew		Equ	$

		Chi

J		Ends

		End	Letty


