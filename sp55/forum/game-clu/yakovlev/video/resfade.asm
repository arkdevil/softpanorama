;	ResFade.asm
;	Smooth screen fade for VGA!!!
;
;	Written by Alex Yakovlev. (alex@asp.tixm.tambov.su)
;

	Ideal
	Model	Tiny
	CodeSeg

	Org	100h

Start:	Jmp	Inst

MyInt:	Push	ax

	In	al,60h
	Cmp	al,57h or 80h
	Jne	iEnd

	Mov	al,20h
	Out	20h,al

	Push	bx cx dx si di ds es
	Cld
	Call	ScrFade
	Pop	es ds di si dx cx bx
iEnd:
	Pop	ax

	Db	0EAh
OiOfs	Dw	?
OiSeg	Dw	?

ScrFade:
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
;				Read palette
	Mov	si,OffSet thePal
	Mov	di,OffSet OrgPal
	Mov	bl,0
Loc1b:					; Loop for 16 colors
	Mov	dx,3DAh
	In	al,dx
	Mov	dx,3C0h
	Mov	al,bl
	Out	dx,al
	Inc	dx
	Jmp	$+2
	In	al,dx
	StoSb

	Mov	cx,64
	Push	si
Llk:	Mov	[si],al
	Add	si,16*4
	Loop	Llk
	Pop	si
	Inc	si

	Mov	dx,3C7h
	Out	dx,al
	Inc	dx
	Inc	dx

	Mov	cx,3
Lll:					; Loop for 3 R/G/B ingridients
	In	al,dx
	StoSb
	Shl	al,1
	Shl	al,1
	Mov	ah,al
	Xor	al,al
	Mov	bh,7Fh

	Push	cx
	Mov	cx,64
	Push	si

Llm:	Mov	[si],al
	Add	si,16*4
	Add	bh,ah
	Jnc	Llv
	Inc	al
Llv:	Loop	Llm

	Pop	si
	Pop	cx
	Inc	si
	Loop	Lll

	Inc	bl
	Cmp	bl,16
	Jb	Loc1b

	Mov	dx,3DAh
	In	al,dx
	Mov	dx,3C0h
	Mov	al,20h
	Out	dx,al
;				Mask all IRQs except Keyboard
	In	al,21h
	Push	ax
	Mov	al,11111101b
	Out	21h,al

	Sti
	Jmp	Loc3

Loc1:
;				Wait for retrace
Lc7:	In	al,dx
	Test	al,1
	Jz	Lc7
Loc1a:
	Mov	bl,16
;				Set palette register
Ll1:	Mov	dx,3C8h
	LodSb
	Out	dx,al
	Inc	dx
Rept 3
	LodSb
	Out	dx,al
EndM
;				Increase color number
	Dec	bl
	Jnz	Ll1
;				Increase Line#
	Inc	bh
	Cmp	bh,64
	Je	Loc3
;				Wait during some lines
	Mov	ah,2			; ... Lines per color
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
;				Wait for vert retrace
	Mov	dx,3DAh
Lc3:	In	al,dx
	Test	al,1000b
	Jz	Lc3

	Mov	bh,0
	Mov	si,OffSet thePal
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
	Pop	ax
	Out	21h,al
	Sti
;				IntController -> End of int
	Mov	al,20h
	Out	20h,al
;				Reset palette registers
	Mov	si,OffSet OrgPal
	Mov	cx,16
	Mov	dx,3C8h
Loc9:	LodSb
	Out	dx,al
	Inc	dx
Rept 3
	LodSb
	Out	dx,al
EndM
	Dec	dx
	Loop	Loc9
;				Leave ...
	Ret

OldSeg	Dw	?
OldOfs	Dw	?

OrgPal	Db	16*4 Dup( ? )
Label	thePal	Byte

Inst:	Mov	ax,1A00h
	Int	10h
	Cmp	al,1Ah
	Je	@@Ok

	Mov	ah,9
	Mov	dx,OffSet NoVGA
	Int	21h

	Ret

NoVGA	Db	'Sorry, VGA needed.', 13,10, '$'

@@Ok:
	Mov	ah,9
	Mov	dx,OffSet Copr
	Int	21h

	Mov	ah,35h
	Mov	al,09h
	Int	21h

	Mov	[cs: OiSeg ],es
	Mov	[cs: OiOfs ],bx

	Mov	ah,25h
	Mov	al,09h
	Mov	dx,OffSet MyInt
	Int	21h

	Mov	dx,OffSet Inst
	Add	dx,16*4*64
	Int	27h

Copr	Db	'Resident VGA Screen Fader by Alex Yakovlev.', 13,10
	Db	9, 'Press F11 to Activate.', 13,10, '$'

	End	Start
