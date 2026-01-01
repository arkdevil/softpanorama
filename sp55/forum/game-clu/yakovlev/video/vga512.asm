;	VGA Pal .asm
;	Displays 512 colors on VGA in text mode!!!
;
;	Written by Alex Yakovlev. (alex@asp.tixm.tambov.su)
;

	Ideal
	Model	Tiny
	CodeSeg

	Org	100h

Start:	Mov	ax,1A00h
	Int	10h
	Cmp	al,1Ah
	Je	@@Ok

	Mov	ah,9
	Mov	dx,OffSet NoVGA
	Int	21h

	Ret

NoVGA	Db	'Sorry, VGA needed.', 13,10, '$'

@@Ok:
;				Draw a picture
	Mov	ax,0B800h
	Mov	es,ax
	Xor	di,di

	Cld
	Mov	cx,23
Lp1:	Push	cx
	Mov	al,'█'
	Mov	ah,08h
Lp2:
	Mov	cx,10
	Rep	StoSw
	Inc	ah
	Cmp	ah,10h
	Jb	Lp2

	Pop	cx
	Loop	Lp1

	Mov	si,OffSet Msg
	Mov	ah,07h
Lf1:
	LodSb
	Or	al,al
	Jz	Lf2
	StoSw
	Jmp	Lf1
Lf2:
;				Show all colors
	Cli

	Xor	ax,ax
	Mov	ds,ax
;				Store old Int09 vector
	Mov	ax,[ds: 4*9+0]
	Mov	[cs:OldOfs],ax
	Mov	ax,[ds: 4*9+2]
	Mov	[cs:OldSeg],ax
;				Set my Int09
	Mov	[ds: 4*9+2],cs
	Mov	ax,OffSet Int09
	Mov	[ds: 4*9+0],ax

	Push	cs cs
	Pop	ds es
;				Mask all IRQs except Keyboard
	Mov	al,11111101b
	Out	21h,al

	Sti
	Jmp	Loc3

Msg	Db	"A Great program, isn't it ?...            "
	Db	"Copyright (c) by Alex Yakovlev.       ", 0

Loc1:
;				Wait for retrace
Lc7:	In	al,dx
	Test	al,1
	Jz	Lc7
Loc1a:
	Mov	si,OffSet Pal
;				Set palette register
	Mov	bl,38h
Ll1:	Mov	dx,3C8h
	Mov	al,bl
	Out	dx,al
	Inc	dx

	LodSb
	Out	dx,al
	LodSb
	Out	dx,al
	LodSb
	Out	dx,al
;				Increase color number
	Inc	bl
	Cmp	bl,40h
	Jb	Ll1
;				Increase pal.
	Mov	si,OffSet Pal
	Mov	di,si

	Mov	cx,24
@1:
	LodSb
	Add	al,[si- 25]
	StoSb
	Loop	@1

	Inc	bh
	Cmp	bh,64
	Je	Loc3
;				Wait during some lines

	Mov	ah,3			; ... Lines per color
	Mov	dx,3DAh

Lc1:	In	al,dx
	Test	al,1
	Jnz	Lc1			; Wait for retrace end

	Dec	ah
	Jz	Loc1a

Lc2:	In	al,dx
	Test	al,1
	Jz	Lc2			; Wait for retrace

	Jmp	Lc1

Loc3:
;				Initialize palette
	Mov	di,OffSet Pal
	Mov	al,0
	Mov	cx,8*3
	Rep	StoSb
;				Wait for vert retrace
	Mov	dx,3DAh
Lc3:	In	al,dx
	Test	al,1000b
	Jz	Lc3

	Mov	bh,0
	Jmp	Loc1a

Int09:
	Add	sp,6
;				Restore old Int09 vector
	Xor	ax,ax
	Mov	ds,ax

	Mov	ax,[cs:OldOfs]
	Mov	[ds: 4*9+0],ax
	Mov	ax,[cs:OldSeg]
	Mov	[ds: 4*9+2],ax

	Push	cs
	Pop	ds
;				Enable all IRQs
	Mov	al,0
	Out	21h,al
	Sti
;				Call Old Int09 handler
	Int	09
;				Reset palette registers
	Mov	bl,38h
Ll8:	Mov	dx,3C8h
	Mov	al,bl
	Out	dx,al
	Inc	dx
;				Red
	Mov	al,21
	Test	bl,100b
	Jz	@2
	Mov	al,63
@2:	Out	dx,al
;				Green
	Mov	al,21
	Test	bl,010b
	Jz	@3
	Mov	al,63
@3:	Out	dx,al
;				Blue
	Mov	al,21
	Test	bl,001b
	Jz	@4
	Mov	al,63
@4:	Out	dx,al

	Inc	bl
	Cmp	bl,40h
	Jb	Ll8
;				Cls
	Mov	ax,0B800h
	Mov	es,ax
	Mov	ax,0720h
	Xor	di,di
	Mov	cx,2000
	Rep Stosw
;				Get key, if any are entered
Loc7:	Mov	ah,1
	Int	16h
	Jz	Loc8
	Mov	ah,0
	Int	16h
	Jmp	Loc7
Loc8:
;				Leave ...
	Ret

OldOfs	Dw	?
OldSeg	Dw	?

PalInc	Db	 2,  2, -1
	Db	 0,  0,  1
	Db	 0,  1,  0
	Db	 0,  1,  1
	Db	 1,  0,  0
	Db	 1,  0,  1
	Db	 1,  1,  0
	Db	-1, -1, -1

Pal	Db	8*3 Dup( ? )

	End	Start
