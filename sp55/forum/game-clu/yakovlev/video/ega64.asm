;	EGA-64.asm
;	Displays 64 colors on EGA display in text mode!!!
;
;	Written by Alex Yakovlev. (alex@asp.tixm.tambov.su)
;

	Ideal
	Model	Tiny
	CodeSeg

	Org	100h

Start:
	Mov	ah,12h
	Mov	bl,10h
	Int	10h
	Cmp	bl,10h
	Jne	@@Ok

	Mov	ah,9
	Mov	dx,OffSet NoEGA
	Int	21h

	Ret

NoEGA	Db	'Sorry, EGA needed.', 13,10, '$'

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
;				Set palette register
	Mov	bl,8
Ll1:	Mov	dx,3C0h
	Mov	al,bl
	Out	dx,al
	Mov	al,bh
	Out	dx,al
;				Increase color number
	Inc	bl
	Inc	bh
	Cmp	bl,16
	Jb	Ll1
;				Skip line
	Mov	dx,3DAh
Lc4:	In	al,dx
	Test	al,1
	Jnz	Lc4
;				Wait for retrace end
Lc5:	In	al,dx
	Test	al,1
	Jz	Lc5
;				If all colors are already displayed
	Cmp	bh,64
	Ja	Loc3
;				Enable display
	Mov	dx,3C0h
	Mov	al,20h
	Out	dx,al

	Mov	ah,38			; ... Lines per color
	Mov	dx,3DAh

Lc1:	In	al,dx
	Test	al,1
	Jnz	Lc1			; Wait for retrace end

	Dec	ah
	Jz	Loc1

Lc2:	In	al,dx
	Test	al,1
	Jz	Lc2			; Wait for retrace

	Jmp	Lc1

Loc3:
;				Blank palette
	Mov	bl,8
	Mov	dx,3C0h
Ll3:
	Mov	al,bl
	Out	dx,al
	Mov	al,0
	Out	dx,al
	Inc	bl
	Cmp	bl,16
	Jb	Ll3
;				Enable display
	Mov	dx,3C0h
	Mov	al,20h
	Out	dx,al
;				Wait for vert retrace
	Mov	dx,3DAh
Lc3:	In	al,dx
	Test	al,1000b
	Jz	Lc3

	Mov	bh,0
	Jmp	Loc1

Int09:
	Add	sp,6
;				Restore old Int09 vector
	Mov	ax,[cs:OldOfs]
	Mov	[ds: 4*9+0],ax
	Mov	ax,[cs:OldSeg]
	Mov	[ds: 4*9+2],ax

	Push	cs
	Pop	ds
;				Initialize 3C0 port
	Mov	dx,3DAh
	In	al,dx
;				Set standard palette
	Mov	bl,8
	Mov	dx,3C0h
Ll4:
	Mov	al,bl
	Out	dx,al
	Mov	al,bl
	Add	al,38h-8
	Out	dx,al
	Inc	bl
	Cmp	bl,16
	Jb	Ll4
;				Enable display
	Mov	al,20h
	Out	dx,al
;				Enable all IRQs
	Mov	al,0
	Out	21h,al
	Sti
;				Call Old Int09 handler
	Int	09
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

	End	Start
