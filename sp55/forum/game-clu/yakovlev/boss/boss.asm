;	Boss.asm
;	Shows previously saved screen by pressing a key
;
;	Features:
;	* Works with programs which hooks keyboard
;	* Save/restor screen properly
;
;	Written by Alex Yakovlev. (alex@asp.tixm.tambov.su)
;

	Ideal
	Model	Tiny
	CodeSeg
 	Org	100h

Start:	Jmp	Inst

SaveKey	= 87
ShowKey	= 58

IntVec	= 8
BrkVec	= 63h

ScrBuf	= 4000
FntBuf	= 256*16

O9Tit	Dw	?

On	Db	0

Sv	Db	0

Proc	CtrlInt
	Push	ax di ds

	Cmp	[cs: On],0
	Jne	@@Quit

	Cli
	Xor	ax,ax			; ES:BX <- Int09 adress
	Mov	ds,ax
	Lds	di,[DWord ds: 9*4]

	Mov	ax,ds
	Cmp	ax,[cs: O9Seg]
	Jne	@@1
	Cmp	di,[cs: O9Ofs]
	Je	@@Quit
@@1:
	Push	ds di
	Mov	ds,[cs: O9Seg]
	Mov	di,[cs: O9Ofs]
	Cmp	[Word ds: di],100h*BrkVec + 0CDh
	Jne	@@2
	Mov	ax,[cs: O9Tit]
	Mov	[ds: di],ax
@@2:	Pop	di ds

	Mov	[cs: O9Seg],ds
	Mov	[cs: O9Ofs],di

	Mov	ax,[ds: di]
	Mov	[cs: O9Tit],ax

	Mov	[Word ds: di],100h*BrkVec + 0CDh

@@Quit:
	Pop	ds di ax

	Db	0EAh			; Jump far OldInt
OIOfs	Dw	?
OISeg	Dw	?

EndP

Proc	CallO9
	Push	ax di ds

	Mov	ds,[cs: O9Seg]
	Mov	di,[cs: O9Ofs]

	Mov	ax,[cs: O9Tit]
	Mov	[ds: di],ax

	PushF
	Db	9Ah
O9Ofs	Dw	?
O9Seg	Dw	?

	Mov	[Word ds: di],100h*BrkVec + 0CDh

	Pop	ds di ax

	Ret

EndP

Proc	Int09
	Push	ax

	Cmp	[cs: On],2
	Jne	@@2
	In	al,60h
	Cmp	al,ShowKey
	Jne	@@3
	Mov	[cs: On],3
@@3:	Jmp	@@QQQ
@@2:
	Cmp	[cs: On],0
	Jne	@@3

	Mov	[cs: On],1

	In	al,60h
	Cmp	al,SaveKey
	Je	Save
	Cmp	al,ShowKey
	Je	Show
@@Old:
	Call	CallO9

	Jmp	@@Ret
@@Ret:
	Mov	[cs: On],0
@@QQQ:
	Mov	al,20h
	Out	20h,al

	Pop	ax
	Add	sp,6
	IRet

Show:
	Cmp	[cs: Sv],0
	Je	@@Old

	Push	bx cx dx si di ds es

	Mov	ah,1Ch
	Mov	al,1
	Mov	cx,7
	Push	cs
	Pop	es
	Mov	bx,OffSet Inst +ScrBuf +FntBuf
	Int	10h

	Call	SaveFnt

	Mov	ah,0
	Mov	al,83h
	Int	10h

	Call	Copy

	Mov	[cs: On],2
	Mov	al,20h
	Out	20h,al
	Sti
@@8:	Cmp	[cs: On],3
	Jne	@@8
	Cli

	Call	Copy

	Call	LoadFnt

	Mov	ah,1Ch
	Mov	al,2
	Mov	cx,7
	Push	cs
	Pop	es
	Mov	bx,OffSet Inst +ScrBuf +FntBuf
	Int	10h

	Pop	es ds di si dx cx bx
	Jmp	@@Ret

Save:	
	Push	bx cx dx si di ds es

	Mov	ah,0Fh
	Int	10h
	And	al,7Fh
	Cmp	al,3
	Ja	@@SvRet
	Cmp	al,2
	Jb	@@SvRet

	Mov	ax,0B800h
	Mov	es,ax
	Mov	bx,0
	Mov	si,OffSet Inst
	Mov	cx,ScrBuf
@@9:
	Mov	al,[es: bx]
	Mov	[cs: si],al
	Inc	si
	Inc	bx
	Loop	@@9

	Mov	[cs: Sv],1

@@SvRet:
	Pop	es ds di si dx cx bx
	Jmp	@@Ret

EndP

Proc	Copy
	Cld

	Mov	ax,0B800h
	Mov	es,ax
	Xor	di,di
	Mov	si,OffSet Inst
	Mov	cx,ScrBuf
@@1:
	Mov	al,[es: di]
	Xchg	al,[cs: si]
	StoSb
	Inc	si
	Loop	@@1

	Ret
EndP

Proc	SaveFnt

	Call	SetVGA

	Mov	ax,0B800h
	Mov	ds,ax
	Mov	ax,cs
	Mov	es,ax

	Xor	si,si
	Mov	di,OffSet Inst +ScrBuf
	Mov	cx,256
@@2:
	Push	cx
	Mov	cx,16
	Rep	MovSb
	Add	si,16
	Pop	cx
	Loop	@@2

	Ret
EndP

Proc	LoadFnt

	Call	SetVGA

	Mov	ax,0B800h
	Mov	es,ax
	Mov	ax,cs
	Mov	ds,ax

	Xor	di,di
	Mov	si,OffSet Inst +ScrBuf
	Mov	cx,256
@@2:
	Push	cx
	Mov	cx,16
	Rep	MovSb
	Add	di,16
	Pop	cx
	Loop	@@2

	Ret
EndP

Proc	SetVGA

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

	Mov	dx,3CEh	
	Mov	al,4
	Out	dx,al
	Inc	dx
	Mov	al,2
	Out	dx,al

	Mov	dx,3CEh	
	Mov	al,5
	Out	dx,al
	Inc	dx
	Mov	al,0
	Out	dx,al


	Ret
EndP

Inst:
	Mov	ah,1Ch
	Mov	al,0
	Mov	cx,7
	Int	10h
	Cmp	al,1Ch
	Je	@@Ok
	Mov	ah,9
	Mov	dx,OffSet NoVGA
	Int	21h

	Ret

NoVGA	Db	'Sorry, VGA needed.', 13,10, '$'

@@Ok:
	Mov	cl,6
	Shl	bx,cl
	Push	bx

	Mov	ah,9
	Mov	dx,OffSet Copr
	Int	21h

	Mov	ax,3500h + IntVec
	Int	21h	; Read old Int08 vector

	Mov	[cs: OISeg],es
	Mov	[cs: OIOfs],bx

	Mov	ax,2500h + BrkVec
	Mov	dx,OffSet Int09
	Int	21h

	Mov	dx,OffSet CtrlInt
	Mov	ax,2500h + IntVec
	Int	21h		; Set our Int08 vector

	Pop	dx
	Add	dx,OffSet Inst +ScrBuf +FntBuf
	Int	27h	; Became resident

Copr	Db	'"Идет начальник" by Rustam Kalko & Alex Yakovlev', 13,10
	Db	13,10
	Db	'Press:', 13,10
	Db	9, '<F11> to save screen,',13,10
	Db	9, '<Caps> to show saved screen.', 13,10, '$'

End	Start
