;	Scan.asm
;	Display scan codes of keyboard
;
;	Features:
;	* Distinguish 'Extended' keys
;
;	Written by Alex Yakovlev. (alex@asp.tixm.tambov.su)
;


Code	Segment
Assume	CS:Code

 	Org	100h

Start:	Jmp	Inst

ScanC	Db	0

Ext	Db	0

Int09:
	Push	ax

	In	al,60h

	Cmp	al,0E0h
	Jb	I9a

	Inc	cs:Ext
	Jmp	I9Ret
I9a:

	Push	si
	Mov	si,OffSet MsgSpc
	Cmp	cs:Ext,0
	Je	I9b
	Mov	si,OffSet MsgExt
I9b:	Call	PutS
	Pop	si

	Push	si
	Mov	si,OffSet MsgSpc
	Test	al,80h
	Jz	I9x
	Mov	si,OffSet MsgRe
i9x:	Call	PutS
	Pop	si

	Mov	cs:[ScanC],al

	Push	ax
	And	ax,7Fh
	Call	PutNum
	Pop	ax

	Cmp	al,57 or 80h
	Jne	i9Cod

	Push	si
	Mov	si,OffSet MsgCrLf
	Call	PutS
	Pop	si

I9Cod:	Cmp	cs:Ext,0
	Je	I9Ret
	Dec	cs:Ext

I9Ret:
;	In	al,61h
;	Mov	ah,al
;	Or	al,80h
;	Out	61h,al
;	Mov	al,ah
;	Out	61h,al

	Mov	al,20h
	Out	20h,al

	Pop	ax

	Iret

Inst:
	Mov	si,OffSet MsgTitl
	Call	PutS

	Mov	ax,cs
	Mov	ds,ax	; DS <- CS

	Mov	ax,3509h
	Int	21h	; Read old Int09 vector

	Push	es
	Push	bx

	Lea	dx,Int09
	Mov	ax,2509h
	Int	21h	; Set our Int09 vector

EE:	Cmp	cs:[ScanC],1
	Jne	EE

	Pop	dx
	Pop	ds

	Mov	ax,2509h
	Int	21h	; Restore Int09

	Mov	si,OffSet MsgGdBy
	Call	PutS

	Int	20h

MsgTitl	Db	'Scan.com - display keyboard scan codes', 13,10
	Db	'Written by Alex Yakovlev.', 13,10, 13,10
	Db	'Press ESC exit program.', 13,10, 13,10, 0
MsgGdBy	Db	'Bye.', 13,10, 0

MsgExt	Db	'Extended: ', 0
MsgRe	Db	'Released: ', 0
MsgSpc	Db	'          ', 0
MsgCrLf	Db	13,10, 13,10, 0

PutC	Proc	; Type a char from AL
	Push	bx
	Mov	bh,al
	Push	ax
	Mov	ah,0Eh
	Mov	al,bh
	Mov	bl,07h
	Int	10h
	Pop	ax
    	Pop	bx
	Ret
PutC	EndP

PutS	Proc	; Write string DS:SI
	Push	ax
Nxt:
	SegCS
	LodSb
	Or	al,al
	Jz	EndPS
	Call	PutC
	Jmp	Nxt
EndPS:
;	Mov	al,13
;	Call	PutC
;	Mov	al,10
;	Call	PutC

	Pop	ax
	Ret
PutS	EndP

PutNum	Proc	near	; Print AX
	Push	ax
	Push	bx
	Push	dx

	Mov	bx,99
	Push	bx
	Cmp	ax,0
	Jne	Read
	Push	ax
	Jmp	OutPut
Read:
	Cmp	ax,0
	Je	OutPut
	Mov	dx,0
	Mov	bx,10
	Div	bx
	Push	dx
	Jmp	Read
OutPut:
	Pop	ax
	Cmp	ax,99
	Je	PNRet
	Add	ax,'0'
	Call	PutC
	Jmp	OutPut
PNRet:
	Mov	al,13
	Call	PutC
	Mov	al,10
	Call	PutC
	Pop	dx
	Pop	bx
	Pop	ax
	Ret
PutNum	EndP

Code	EndS
End	Start
