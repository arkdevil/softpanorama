;	BTet.asm
;	BackGround Tetris
;
;	Version with NewFigure
;
;	Written by Alex Yakovlev. (alex@asp.tixm.tambov.su)
;

	Ideal
	Model	Tiny
	CodeSeg
	Locals	@@
	Org	100h

Prcs	= 0DAh

Start:
	Jmp	Inst

Copr	Db	'BackGrTetris by Alex Yakovlev.', 0

Proc	Int10

	Cmp	[Byte cs: Active],0
	Je	@@Old

	Cmp	ah,0
	Je	@@Ok
	Cmp	ah,11h
	Jne	@@Old
@@Ok:
	PushF
	Call	[DWord cs: o10ofs]
	Call	Init
	IRet
@@Old:
	Db	0EAh
o10ofs	Dw	?
o10seg	Dw	?

EndP

GlLenY	= 21

PgOfs	= 8*1024

nxFig	Db	4*4 Dup( ? )
nxCol	Db	?

nxBX	Db	27
nxBY	Db	 4
nxLX	= 3+2*4+3
nxLY	= 1+4+1

Proc	inNext
	Push	bx
;
;	in box ?
;
	Sub	bl,[cs: nxBX]
	Jc	@@No
	Sub	bh,[cs: nxBY]
	Jc	@@No
	Cmp	bl,nxLX
	Jae	@@Sh
	Cmp	bh,nxLY
	Jae	@@Sh

	Mov	ah,3Fh

	Mov	al,' '
	Cmp	bl,0
	Je	@@Ok
	Cmp	bl,nxLX -1
	Je	@@Ok

	Cmp	bh,0
	Je	@@fTop
	Cmp	bh,nxLY -1
	Je	@@fBott
	Cmp	bl,2
	Je	@@Ok
	Cmp	bl,nxLX -3
	Je	@@Ok

	Mov	al,'║'
	Cmp	bl,1
	Je	@@Ok
	Cmp	bl,nxLX -2
	Je	@@Ok

	Mov	ah,0
	Sub	bl,3
	Mov	al,[cs: Chr1]
	Test	bl,1
	Jz	@@4
	Mov	al,[cs: Chr2]
@@4:	Shr	bl,1
	Dec	bh
	Shl	bh,1
	Shl	bh,1
	Add	bl,bh
	Xor	bh,bh
	Cmp	[cs: nxFig +bx],1
	Jne	@@Ok
	Mov	ah,[cs: nxCol]

@@Ok:	Stc
@@Ret:
	Pop	bx
	Ret

@@No:
	Clc
	Jmp	@@Ret

@@Sh:
;	Shadow
;
	Cmp	bh,1
	Jb	@@No
	Cmp	bl,2
	Jb	@@No
	Cmp	bh,nxLY+1
	Jae	@@No
	Cmp	bl,nxLX+2
	Jae	@@No

	Mov	ah,08
	Jmp	@@Ok
@@fTop:
	Mov	al,'╔'
	Cmp	bl,1
	Je	@@Ok
	Mov	al,'╗'
	Cmp	bl,nxLX -2
	Je	@@Ok
@@f1:	Mov	al,'═'
	Jmp	@@Ok

@@fBott:
	Mov	al,'╚'
	Cmp	bl,1
	Je	@@Ok
	Mov	al,'╝'
	Cmp	bl,nxLX -2
	Je	@@Ok
	Jmp	@@f1

EndP

ScrLenY	Db	?

Score	Dw	?
PrScore	Dw	0

GOver	Db	0
Drop	Db	0
Active	Db	0
Back	Db	0
Flag	Db	0
Alt	Db	0
Ctrl	Db	0

InitDly	Db	4
Dly	Db	?
Delay	Db	0

Ch1	= '╥'
Ch2	= 'ї'
Chr1	Db	?
Chr2	Db	?

VSeg	Dw	?
VPort	Dw	?
IsEGA	Db	?

Proc	Lines
	Push	ax cx si di ds es
	Std

	Push	cs cs
	Pop	ds es
	Mov	si,OffSet Glass + 10*glLenY -1
	Mov	di,si

@@4:	Push	si
	Mov	cx,10
@@2:	LodSb
	Cmp	al,0
	Je	@@1
	Loop	@@2
	Mov	ax,20
	Call	IncScore
	Pop	ax
	Jmp	@@3

@@1:	Pop	si
	Mov	cx,10
	Rep	MovSb

@@3:	Cmp	si,OffSet Glass
	Jae	@@4

	Mov	al,0
@@5:	Cmp	di,OffSet Glass
	Jb	@@6
	StoSb
	Jmp	@@5
@@6:
	Cld
	Pop	es ds di si cx ax
	Ret
EndP

Proc	Rotate
	Push	bx si di ds es

	Push	cs cs
	Pop	ds es

	Mov	si,OffSet CurFig +3
	Mov	di,OffSet TmpFig
	Mov	bh,0
@@1:	Mov	bl,0
@@2:	MovSb
	Add	si,3
	Inc	bl
	Cmp	bl,4
	Jb	@@2
	Sub	si,4*4+1
	Inc	bh
	Cmp	bh,4
	Jb	@@1

	Pop	es ds di si bx
	Ret
EndP

glBX	Db	47
glBY	Db	 2
glLX	= 3+2*10+3
glLY	= glLenY+1

Proc	inGlass
	Push	bx
;
;	in box ?
;
	Sub	bl,[cs: glBX]
	Jc	@@2
	Sub	bh,[cs: glBY]
	Jc	@@2
	Cmp	bl,glLX
	Jae	@@3
	Cmp	bh,glLY
	Jae	@@3
;
;	Figure ?
;
	Cmp	bh,glLenY
	Jae	@@Frame
	Cmp	bl,3
	Jb	@@Frame
	Cmp	bl,3+2*10
	Jae	@@Frame

	Jmp	@@Figures

@@3:
;	Shadow
;
	Cmp	bh,1
	Jb	@@2
	Cmp	bl,2
	Jb	@@2
	Cmp	bh,glLY+1
	Jae	@@2
	Cmp	bl,glLX+2
	Jae	@@2

	Mov	ah,08
@@Ok:
	Stc
	Jmp	@@Ret

@@2:	Clc
@@Ret:
	Pop	bx
	Ret

@@Frame:
	Mov	ah,2Fh

	Cmp	bl,0
	Je	@@f5
	Cmp	bl,3+2*10+2
	Je	@@f5
	Cmp	bh,glLenY
	Je	@@f6
	Cmp	bl,2
	Je	@@f5
	Cmp	bl,3+2*10+0
	Jne	@@f7
@@f5:	Mov	al,' '
	Jmp	@@Ok

@@f6:	Cmp	bl,1
	Jne	@@f8
	Mov	al,'╚'
	Jmp	@@Ok
@@f8:	Cmp	bl,3+2*10+1
	Jne	@@f9
	Mov	al,'╝'
	Jmp	@@Ok
@@f9:
	Sub	bl,10
	Jc	@@f2
	Cmp	bl,5
	Ja	@@f1
	Je	@@f5

	Push	ax cx dx
	Mov	ax,[cs: Score]
	Mov	cx,10
@@s1:	Xor	dx,dx
	Div	cx
	Inc	bl
	Cmp	bl,5
	Jb	@@s1
	Mov	bl,dl
	Add	bl,'0'
	Pop	dx cx ax
	Mov	al,bl

	Jmp	@@Ok
@@f2:	Xor	bh,bh
	Mov	al,[cs: msScore +bx+10-2 -256]
	Jmp	@@Ok
@@f1:	Mov	al,'═'
	Jmp	@@Ok
@@f7:	Mov	al,'║'
	Jmp	@@Ok

msScore	Db	' Score: '

@@Figures:
	Sub	bl,3
	Mov	al,[cs: Chr1]
	Test	bl,1
	Jz	@@4
	Mov	al,[cs: Chr2]
@@4:
	Shr	bl,1		; BL = X, BH = Y of Glass

	Push	bx
	Cmp	[cs: GOver],1
	Je	@@5

	Mov	ah,[cs: CFigCol]
	Sub	bh,[cs: CFigY]
	Cmp	bh,0
	Jl	@@5
	Cmp	bh,4
	Jge	@@5
	Sub	bl,[cs: CFigX]
	Cmp	bl,0
	Jl	@@5
	Cmp	bl,4
	Jge	@@5
	Shl	bh,1
	Shl	bh,1
	Add	bl,bh
	Xor	bh,bh
	Cmp	[cs: CurFig +bx],1
	Jne	@@5

	Pop	bx
	Jmp	@@Ok
@@5:
	Pop	bx

	Shl	bh,1		; BH = 2*Y
	Add	bl,bh		; BL = 2*Y + X
	Shl	bh,1
	Shl	bh,1		; BH = 8*Y
	Add	bl,bh		; BL = 8*Y + 2*Y + X = 10*Y + X
	Xor	bh,bh
	Mov	ah,[cs: Glass +bx]

	Jmp	@@Ok

EndP

LevScr	= 2000

Proc	IncScore
	Push	ax

	Add	ax,[cs: Score]
	Mov	[cs: Score],ax
	Sub	ax,[cs: PrScore]
	Cmp	ax,LevScr
	Jb	@@1
	Add	[cs: PrScore],LevScr

	Cmp	[cs: Dly],1
	Jbe	@@1

	Dec	[cs: Dly]
@@1:
	Pop	ax
	Ret
EndP

Proc	NewGame
	Push	ax cx di es

	Push	cs
	Pop	es
	Mov	di,OffSet Glass
	Mov	cx,glLenY*10
	Mov	al,0
	Rep	StoSb

	Mov	al,[cs: InitDly]
	Mov	[cs: Dly],al

	Mov	[cs: GOver],0
	Mov	[cs: Score],0
	Mov	[cs: PrScore],0

	Call	InitFig

	Pop	es di cx ax
	Ret
EndP

SLen	equ	32

Proc	Int09
	Push	ax
	Cld

	In	al,60h
	Mov	ah,1
	Test	al,80h
	Jz	@@1
	Mov	ah,0
	And	al,7Fh
@@1:
	Cmp	[cs: Active],1
	Je	@@2

	Cmp	al,88			; F12
	Jne	@@Old
	Cmp	ah,0
	Jne	@@Old

	Call	Init

	Jmp	@@Ret

@@Old:
	Pop	ax

	Db	0EAh
o09ofs	Dw	?
o09seg	Dw	?

@@2:
	Cmp	al,58			; Caps Lock
	Jne	@@3

	Mov	[cs: Back],ah
	Jmp	@@Ret
@@3:
	Cmp	[cs: Back],1
	Je	@@Old

	Cmp	al,56			; Alt
	Jne	@@a9
	Mov	[cs: Alt],ah
	Jmp	@@Ret
@@a9:
	Cmp	al,29			; Ctrl
	Jne	@@a6
	Mov	[cs: Ctrl],ah
	Jmp	@@Ret
@@a6:
	Cmp	ah,1
	Je	@@Press

@@Ret:
	Mov	al,20h
	Out	20h,al

	Pop	ax
	IRet

@@Press:
	Cmp	[cs: Alt],1
	Jne	@@a8
	Jmp	@@Alt
@@a8:
	Cmp	[cs: Ctrl],1
	Jne	@@a5
	Jmp	@@Ctrl
@@a5:
	Cmp	al,1			; ESC
	Jne	@@4

	Call	Restore
	Jmp	@@Ret
@@4:
	Cmp	al,78			; +
	Jne	@@a1
	Cmp	[cs: Dly],1
	Jbe	@@Ret
	Dec	[cs: Dly]
	Dec	[cs: InitDly]
	Jmp	@@Ret
@@a1:
	Cmp	al,74			; -
	Jne	@@a2
	Cmp	[cs: InitDly],250
	Ja	@@Ret
	Inc	[cs: Dly]
	Inc	[cs: InitDly]
	Jmp	@@Ret
@@a2:
	Cmp	[cs: GOver],1
	Je	@@n1
	Cmp	al,49			; 'N' - New Game
	Jne	@@5
@@n1:	Call	NewGame
	Jmp	@@Ret
@@5:
	Cmp	al,75			; Left arrow
	Jne	@@6
@@6a:	Call	ShfLeft
	Jmp	@@Ret
@@6:	Cmp	al,71
	Je	@@6a

	Cmp	al,77			; Right arrow
	Jne	@@7
@@7a:	Call	ShfRight
	Jmp	@@Ret
@@7:	Cmp	al,73
	Je	@@7a

	Cmp	al,72			; Up arrow
	Jne	@@8

	Call	Rotate
	Call	DoesFit
	Jnc	@@r1
	Call	Tmp2Cur
	Jmp	@@Ret
@@8:
	Cmp	al,57			; Space
	Jne	@@r1
	Mov	[cs: Drop],1
@@r1:	Jmp	@@Ret

@@Alt:
	Cmp	al,72			; Up
	Jne	@@k1
	Cmp	[cs: glBY],1
	Jbe	@@r2
	Dec	[cs: glBY]
	Jmp	@@Ret
@@k1:
	Cmp	al,75			; Left
	Jne	@@k2
	Cmp	[cs: glBX],1
	Jbe	@@r2
	Dec	[cs: glBX]
	Jmp	@@Ret
@@k2:
	Cmp	al,77			; Right
	Jne	@@k3
	Cmp	[cs: glBX],80-glLX
	Ja	@@r2
	Inc	[cs: glBX]
	Jmp	@@Ret
@@k3:
	Cmp	al,80			; Down
	Jne	@@r2
	Mov	ah,[cs: ScrLenY]
	Sub	ah,glLY
	Cmp	[cs: glBY],ah
	Ja	@@r2
	Inc	[cs: glBY]
@@r2:	Jmp	@@Ret

@@Ctrl:
	Cmp	al,72			; Up
	Jne	@@c1
	Cmp	[cs: nxBY],1
	Jbe	@@r3
	Dec	[cs: nxBY]
	Jmp	@@Ret
@@c1:
	Cmp	al,75			; Left
	Jne	@@c2
	Cmp	[cs: nxBX],1
	Jbe	@@r3
	Dec	[cs: nxBX]
	Jmp	@@Ret
@@c2:
	Cmp	al,77			; Right
	Jne	@@c3
	Cmp	[cs: nxBX],80-nxLX
	Ja	@@r3
	Inc	[cs: nxBX]
	Jmp	@@Ret
@@c3:
	Cmp	al,80			; Down
	Jne	@@r3
	Mov	ah,[cs: ScrLenY]
	Sub	ah,nxLY
	Cmp	[cs: nxBY],ah
	Ja	@@r3
	Inc	[cs: nxBY]
@@r3:	Jmp	@@Ret

EndP

Proc	DoesFit
	Push	bx si di

	Push	ax
	Mov	di,OffSet Glass
	Mov	ah,[cs: TFigY]
	Mov	al,10
	IMul	ah
	Add	di,ax
	Mov	al,[cs: TFigX]
	Cbw
	Add	di,ax
	Pop	ax

	Mov	bh,0
	Mov	si,OffSet TmpFig
@@2:
	Mov	bl,0
@@3:
	Cmp	[Byte cs: si],1
	Jne	@@1

	Push	bx
	Add	bh,[cs: TFigY]
	Cmp	bh,0
	Jl	@@4
	Cmp	bh,glLenY
	Jge	@@4
	Add	bl,[cs: TFigX]
	Cmp	bl,0
	Jl	@@4
	Cmp	bl,10
	Jge	@@4
	Pop	bx
	Cmp	[Byte cs: di],0
	Jne	@@5
@@1:
	Inc	si
	Inc	di
	Inc	bl
	Cmp	bl,4
	Jb	@@3
	Add	di,10-4
	Inc	bh
	Cmp	bh,4
	Jb	@@2

	Stc
@@Ret:
	Pop	di si bx
	Ret

@@4:	Pop	bx
@@5:	Clc
	Jmp	@@Ret

EndP

Proc	Cur2Glass
	Push	ax bx si di

	Mov	di,OffSet Glass
	Mov	ah,[cs: CFigY]
	Mov	al,10
	IMul	ah
	Add	di,ax
	Mov	al,[cs: CFigX]
	Cbw
	Add	di,ax

	Mov	ah,[cs: CFigCol]
	Mov	bh,0
	Mov	si,OffSet TmpFig
@@2:
	Mov	bl,0
@@3:
	Cmp	[Byte cs: si],1
	Jne	@@1

	Mov	[cs: di],ah
@@1:
	Inc	si
	Inc	di
	Inc	bl
	Cmp	bl,4
	Jb	@@3
	Add	di,10-4
	Inc	bh
	Cmp	bh,4
	Jb	@@2

	Call	Lines

	Pop	di si bx ax
	Ret
EndP

Proc	ShfDown
	Push	ax

	Call	Cur2Tmp
	Inc	[cs: TFigY]
	Call	DoesFit
	Jc	@@1

	Mov	ax,1
	Call	IncScore
	Call	Cur2Glass
	Call	InitFig
	Jmp	@@Ret
@@1:
	Call	Tmp2Cur
	Mov	al,[cs: Dly]
	Mov	[cs: Delay],al
@@Ret:
	Pop	ax
	Ret
EndP

Proc	ShfLeft

	Call	Cur2Tmp
	Dec	[cs: TFigX]
	Call	DoesFit
	Jnc	@@1

	Call	Tmp2Cur
@@1:
	Ret
EndP

Proc	ShfRight

	Call	Cur2Tmp
	Inc	[cs: TFigX]
	Call	DoesFit
	Jnc	@@1

	Call	Tmp2Cur
@@1:
	Ret
EndP

Proc	Int08

	Cld

	Cmp	[cs: Active],1
	Jne	@@Old

	Cmp	[cs: GOver],1
	Je	@@2
	Cmp	[cs: Back],1
	Je	@@2
	Cmp	[cs: Alt],1
	Je	@@2
	Cmp	[cs: Ctrl],1
	Je	@@2
	Cmp	[cs: Drop],1
	Jne	@@4
	Push	ax
	Mov	ax,1
	Call	IncScore
	Pop	ax
	Jmp	@@3
@@4:	Dec	[cs: Delay]
	Jnz	@@2
@@3:
	Call	ShfDown
@@2:
	Cmp	[cs: Flag],1
	Je	@@1

	PushF
	Call	[DWord cs: o08ofs]

	Mov	[cs: Flag],1
	Sti

	Call	CopyScr

	Mov	[cs: Flag],0
	IRet
@@1:

@@Old:
	Db	0EAh
o08ofs	Dw	?
o08seg	Dw	?

EndP

Proc	Init
	Push	ax dx ds

	Xor	ax,ax
	Mov	ds,ax
	Mov	al,[ds: 449h]
	Cmp	al,7
	Je	@@1
	Cmp	al,3
	Ja	@@Fail
@@1:
	Mov	ax,[ds: 463h]
	Mov	[cs: VPort],ax
	Mov	dx,0B800h
	And	ax,0F0h
	Cmp	ax,0B0h			; 3D4-Color / 3B4-MDA
	Jne	@@2
	Mov	dx,0B000h
@@2:
	Mov	[cs: VSeg],dx

	Mov	al,[ds: 484h]
	Inc	al
	Mov	[cs: ScrLenY],al

	Call	SetFont

	Call	CopyScr

	Mov	[cs: Active],1
@@Ret:
	Pop	ds dx ax
	Ret
@@Fail:
	Call	Restore
	Jmp	@@Ret

EndP

Proc	Restore
	Push	ax dx

	Mov	[cs: Active],0
;
;	Restore video screen
;
	Mov	dx,[cs: VPort]
	Mov	ah,0
	Mov	al,0Ch
	Out	dx,ax
	Mov	al,0Dh
	Out	dx,ax
;
;	Return cursor
;
	Mov	dx,[cs: VPort]
	Mov	al,0Eh
	Out	dx,al
	Inc	dx
	In	al,dx
	And	al,Not ( PgOfs shr 8 )
	Out	dx,al

	Pop	dx ax
	Ret
EndP

Proc	CopyScr
	Push	ax bx cx dx si di ds es
;
;	Relocate video screen
;
	Mov	dx,[cs: VPort]
	Mov	bx,PgOfs
	Mov	al,0Ch
	Mov	ah,bh
	Out	dx,ax
	Mov	al,0Dh
	Mov	ah,bl
	Out	dx,ax
;
;	Relocate cursor to phantom-screen
;
	Mov	dx,[cs: VPort]
	Mov	al,0Eh
	Out	dx,al
	Inc	dx
	In	al,dx
	Or	al,PgOfs shr 8
	Out	dx,al
;
;	Copy normal screen into phantom
;
	Mov	ax,[cs: VSeg]
	Mov	ds,ax
	Mov	es,ax

	Xor	si,si
	Mov	di,PgOfs * 2

	Mov	bh,1
	Mov	bl,1
@@1:
	LodSw

	Call	inNext

	Call	inGlass

	StoSw

	Inc	bl
	Cmp	bl,80
	Jbe	@@1
	Mov	bl,1
	Inc	bh
	Cmp	bh,[cs: ScrLenY]
	Jbe	@@1

	Pop	es ds di si dx cx bx ax
	Ret
EndP

Proc	Cur2Tmp
	Push	cx si di ds es

	Push	cs cs
	Pop	ds es
	Mov	si,OffSet CurFig
	Mov	di,OffSet TmpFig
	Mov	cx,16
	Rep	MovSb

	Mov	cl,[cs: CFigX]
	Mov	[cs: TFigX],cl
	Mov	cl,[cs: CFigY]
	Mov	[cs: TFigY],cl

	Pop	es ds di si cx
	Ret
EndP

Proc	Tmp2Cur
	Push	cx si di ds es

	Push	cs cs
	Pop	ds es
	Mov	si,OffSet TmpFig
	Mov	di,OffSet CurFig
	Mov	cx,16
	Rep	MovSb

	Mov	cl,[cs: TFigX]
	Mov	[cs: CFigX],cl
	Mov	cl,[cs: TFigY]
	Mov	[cs: CFigY],cl

	Pop	es ds di si cx
	Ret
EndP

TmpFig	Db	16 Dup( ? )
TFigX	Db	?
TFigY	Db	?

CurFig	Db	16 Dup( ? )
CFigX	Db	?
CFigY	Db	?
CFigCol	Db	?

wRand	Dw	?

Proc	NextRnd
	Push	ax bx cx

	Mov	ax,[cs: WRand]
	Mov	bx,ax
	Add	ax,[ss: bx]		; 1. Rand Mem
	Shl	bx,1
	Shl	bx,1
	Add	ax,bx			; 2. X * 5
	Shr	bx,1
	Xor	bx,ax			; 3. Xor...
	Add	bx,1234*7+1		; 4. +Const
	In	al,40h
	Add	bl,al			; 5. Timer
	Mov	[cs: WRand],bx

	Pop	cx bx ax
	Ret
EndP

Proc	InitFig
	Push	ax cx si di ds es

	Push	cs cs
	Pop	ds es
;
;	NewFig -> Current
;
	Mov	al,[cs: nxCol]
	Mov	[cs: CFigCol],al

	Mov	si,OffSet nxFig
	Mov	di,OffSet CurFig
	Mov	cx,4*4
	Rep	MovSb

	Mov	[cs: CFigX],3
	Mov	[cs: CFigY],-1
;
;	Init NewFig
;

;	Call	NextRnd
;	Mov	ax,[cs: wRand]
;	And	ah,3
;	Mov	cl,7
;	Div	cl
;	Add	ah,9
;	Mov	[cs: nxCol],ah

	Call	NextRnd
	Mov	ax,[cs: wRand]
	And	ah,3
	Mov	cl,7
	Div	cl
	Mov	al,ah
	Add	ah,9
	Mov	[cs: nxCol],ah
	Mov	ah,0
	Mov	si,ax
	Mov	cl,4
	Shl	si,cl
	Add	si,OffSet Fig
	Mov	di,OffSet nxFig
	Mov	cx,4*4
	Rep	MovSb

	Call	Cur2Tmp
	Call	DoesFit
	Jc	@@2

	Mov	[cs: GOver],1
@@2:
	Mov	al,[cs: Dly]
	Mov	[cs: Delay],al
	Mov	[cs: Drop],0

	Pop	es ds di si cx ax
	Ret
EndP

Fig:
	Db	0, 0, 0, 0
	Db	0, 0, 1, 0
	Db	0, 1, 1, 0
	Db	0, 1, 0, 0

	Db	0, 0, 0, 0
	Db	0, 1, 0, 0
	Db	0, 1, 1, 0
	Db	0, 0, 1, 0

	Db	0, 0, 0, 0
	Db	0, 0, 1, 0
	Db	0, 1, 1, 1
	Db	0, 0, 0, 0

	Db	0, 0, 0, 0
	Db	0, 1, 1, 0
	Db	0, 1, 0, 0
	Db	0, 1, 0, 0

	Db	0, 0, 0, 0
	Db	0, 0, 0, 1
	Db	0, 1, 1, 1
	Db	0, 0, 0, 0

	Db	0, 0, 0, 0
	Db	0, 1, 1, 0
	Db	0, 1, 1, 0
	Db	0, 0, 0, 0

	Db	0, 0, 0, 0
	Db	1, 1, 1, 1
	Db	0, 0, 0, 0
	Db	0, 0, 0, 0

Glass	Db	10*glLenY Dup( 0 )

Proc	SetFont
	Push	ax cx dx si di ds es

	Cmp	[cs: IsEGA],1
	Jne	@@9

	Cmp	[Word cs: VSeg],0B800h
	Je	@@1
@@9:
	Mov	al,'█'
	Mov	[cs: Chr1],al
	Mov	[cs: Chr2],al

	Jmp	@@Ret
@@1:
	Mov	al,Ch1
	Mov	[cs: Chr1],al
	Mov	al,Ch2
	Mov	[cs: Chr2],al

	Cli
;
;	Program VGA controller
;
	Mov	dx,3C4h
	Mov	al,2
	Out	dx,al
	Inc	dx
	Mov	al,0100b
	Out	dx,al

	Mov	dx,3CEh
	Mov	al,8
	Out	dx,al
	Inc	al
	Mov	al,0FFh
	Out	dx,al

	Mov	dx,3C4h
	Mov	al,4
	Out	dx,al
	Inc	dx
	Mov	al,111b
	Out	dx,al

	Mov	dx,3CEh	
	Mov	al,6
	Out	dx,al
	Inc	dx
	Mov	al,1100b
	Out	dx,al
;
;	Patch font
;
	Xor	ax,ax
	Mov	es,ax
	Mov	cx,[es: 485h]

	Mov	ax,0B800h
	Mov	es,ax
	Push	cs
	Pop	ds

	Mov	si,Offset Char1
	Mov	di,Ch1*SLen
	MovSb
	MovSb
	LodSb
	Sub	cx,5
	Push	cx
	Rep	StoSb
	Pop	cx
	MovSb
	MovSb
	MovSb

	Mov	si,Offset Char2
	Mov	di,Ch2*SLen
	MovSb
	MovSb
	LodSb
	Rep	StoSb
	MovSb
	MovSb
	MovSb
;
;	Restore VGA ports
;
	Mov	dx,3C4h
	Mov	al,4
	Out	dx,al
	Inc	dx
	Mov	al,011b
	Out	dx,al

	Mov	dx,3C4h
	Mov	al,2
	Out	dx,al
	Inc	dx
	Mov	al,3
	Out	dx,al

	Mov	dx,3CEh	
	Mov	al,6
	Out	dx,al
	Inc	dx
	Mov	al,1110b
	Out	dx,al

	Sti
@@Ret:
	Pop	es ds di si dx cx ax
	Ret
EndP

Char1	Db	00111111b
	Db	01100000b

	Db	01100111b

	Db	01100000b
	Db	00111111b
	Db	00000000b

Char2	Db	11111110b
	Db	00000011b

	Db	11110011b

	Db	00000011b
	Db	11111110b
	Db	00000000b

Proc	Int2F

	Cmp	ah,Prcs
	Jne	@@Old

	Mov	al,0FFh
	Clc
	IRet
@@Old:
	Db	0EAh
o2Fofs	Dw	?
o2Fseg	Dw	?

EndP

Inst:
	Mov	ah,9
	Mov	dx,OffSet MsgTit
	Int	21h
;
;	Test: is EGA present?
;
	Mov	ah,12h
	Mov	bl,10h
	Int	10h
	Cmp	bl,10h
	Mov	al,1
	Jne	@@1
	Mov	al,0
@@1:	Mov	[cs: IsEGA],al
;
;	Test presence
;
	Mov	ah,Prcs
	Mov	al,0
	Int	2Fh
	Cmp	al,0FFh
	Je	@@Alrd

	Mov	ah,9
	Mov	dx,OffSet MsgKeys
	Int	21h
;
;	Hook int 08
;
	Mov	ah,35h
	Mov	al,08
	Int	21h

	Mov	[o08seg],es
	Mov	[o08ofs],bx

	Mov	ah,25h
	Mov	al,08
	Mov	dx,OffSet Int08
	Int	21h
;
;	Hook int 09
;
	Mov	ah,35h
	Mov	al,09
	Int	21h

	Mov	[o09seg],es
	Mov	[o09ofs],bx

	Mov	ah,25h
	Mov	al,09
	Mov	dx,OffSet Int09
	Int	21h
;
;	Hook int 10
;
	Mov	ah,35h
	Mov	al,10h
	Int	21h

	Mov	[o10seg],es
	Mov	[o10ofs],bx

	Mov	ah,25h
	Mov	al,10h
	Mov	dx,OffSet Int10
	Int	21h
;
;	Hook int 2F
;
	Mov	ah,35h
	Mov	al,2Fh
	Int	21h

	Mov	[o2Fseg],es
	Mov	[o2Fofs],bx

	Mov	ah,25h
	Mov	al,2Fh
	Mov	dx,OffSet Int2F
	Int	21h
;
;	Initialize...
;
	Xor	ax,ax
	Mov	es,ax
	Mov	ax,[es: 46Ch]
	Mov	[cs: wRand],ax

	Call	InitFig
	Call	NewGame
;
;	Stay resident
;
	Mov	dx,OffSet Inst
	Int	27h

;
;	Already installed...
;
@@Alrd:
	Mov	ah,9
	Mov	dx,OffSet MsgAlrd
	Int	21h

	Ret

MsgTit	Db	9, '╔═══════════════════════════════════════════════════════╗', 13,10
	Db	9, '║   BackGround Tetris by Alex Yakovlev. (c) AlexGraf.   ║', 13,10
	Db	9, '╟───────────────────────────────────────────────────────╢', 13,10
	Db	'$'
MsgAlrd	Db	9, '║      ... Already installed. Press F12 to activate.    ║', 13,10
	Db	9, '╚═══════════════════════════════════════════════════════╝', 13,10
	Db	'$'
MsgKeys	Db	9, '║   Press...                                            ║', 13,10
	Db	9, '║             F12 to activate;                          ║', 13,10
	Db	9, '║             Arrows to move figure,                    ║', 13,10
	Db	9, '║             Space to drop it,                         ║', 13,10
	Db	9, '║             +,- to change game speed,                 ║', 13,10
	Db	9, '║             N to clear field and score,               ║', 13,10
	Db	9, '║             ESC to leave Tetris.                      ║', 13,10
	Db	9, '║   Hold...                                             ║', 13,10
	Db	9, '║             Caps to send key to background process,   ║', 13,10
	Db	9, '║             Alt to move game field.                   ║', 13,10
	Db	9, '║             Ctrl to move new figure box.              ║', 13,10
	Db	9, '╟───────────────────────────────────────────────────────╢', 13,10
	Db	9, '║ Alex Yakovlev, Tambov; E-Mail alex@asp.tixm.tambov.su ║', 13,10
	Db	9, '║                Have a nice play!!!                    ║', 13,10
	Db	9, '╚═══════════════════════════════════════════════════════╝', 13,10
	Db	'$'

End	Start
