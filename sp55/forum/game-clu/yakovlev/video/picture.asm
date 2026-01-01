;	Picture.asm
;	Two pictures at once without residents
;
;	Written by Alex Yakovlev. (alex@asp.tixm.tambov.su)
;


Code	Segment
Assume	CS:Code,DS:Code

	Org	100h

Start:	Cld

	Call	Init

	Call	Draw

	Ret


PicLenX	Equ	60
PicLenY	Equ	20

ForeGr	Db	'                                                            '
	Db	'                                                            '
	Db	'                                                            '
	Db	'                                                            '
	Db	'            *        **                                     '
	Db	'           ***       **                                     '
	Db	'          *****      **                                     '
	Db	'         *** ***     **      ******      ***     ***        '
	Db	'        ***   ***    **    ***    ***     ***   ***         '
	Db	'       ***     ***   **   ***      ***     *** ***          '
	Db	'       ***     ***   **   ***********       *****           '
	Db	'       ***********   **   ***              *** ***          '
	Db	'       ***     ***   **    ***            ***   ***         '
	Db	'       ***     ***   **      ********    ***     ***        ' 
	Db	'                                                            '
	Db	'                                                            '
	Db	'                                                            '
	Db	'                                                            '
	Db	'                                                            '
	Db	'                                                            '

BackGr	Db	'                                                            '
	Db	'                   ***                                      '
	Db	'                 *******                                    '
	Db	'               *** *** ***                                  '
	Db	'             ***   ***   ***                                '
	Db	'           ***     ***     ***                              '
	Db	'         *** *** *** *** *** ***                            '
	Db	'         ***   ***     ***   ***                            '
	Db	'         ***   ***     ***   ***                            '
	Db	'         ***   ***     ***   ***                            '
	Db	'         ***   ***     ***   ***                            '
	Db	'         ***   ***     ***   ***                            '
	Db	'         ***   ***     ***   ***                            '
	Db	'         *** *** *** *** *** ***                            '
	Db	'           ***     ***     ***                              '
	Db	'             ***   ***   ***                                '
	Db	'               *** *** ***                                  '
	Db	'                 *******                                    '
	Db	'                   ***                                      '
	Db	'                                                            '



;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;
;▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

DrBegX	Equ	10
DrBegY	Equ	 3
DrEndX	Equ	DrBegX+5   +PicLenX
DrEndY	Equ	DrBegY+1   +PicLenY

DrTitle	Db	' Picture ',0
DrTitLn	Equ	$-DrTitle

Draw	Proc

	Mov	ah,DrBegX
	Mov	al,DrBegY
	Mov	bh,DrEndX
	Mov	bl,DrEndY
	Mov	ch,47h

	Call	Window

	Mov	dh,(DrEndX+DrBegX-DrTitLn)/2+1
	Mov	dl,DrBegY
	Mov	si,OffSet DrTitle
	Mov	ch,70h
	Call	PutSt

	Mov	dh,DrBegX+3
	Mov	dl,DrBegY+1
	Mov	cl,'█'
	Mov	si,OffSet ForeGr

Lab4:	Call	VAdr
	Lea	bx,[di+2*PicLenX]

Lab3:	Mov	ch,80h

	LodSb			; Foreground
	Mov	ah,01h
	Cmp	al,'*'
	Jne	Lab1
	Mov	ah,0Eh
Lab1:	Or	ch,ah

	Xchg	si,VarSI	; BackGround
	LodSb
	Mov	ah,00h
	Cmp	al,'*'
	Jne	Lab2
	Mov	ah,02h
Lab2:	Push	cx
	Mov	cl,4
	Shl	ah,cl
	Pop	cx
	Or	ch,ah
	Xchg	si,VarSI	

	Call	OutCh
	Cmp	di,bx
	Jb	Lab3

	Inc	dl
	Cmp	dl,DrEndY-1
	Jbe	Lab4

	Ret
Draw	EndP

VarSI	Dw	OffSet BackGr

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;			VIDEO interface
;▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
  
VStr	Db	'╔═╗║║╚═╝'

VMask	Dw	0FFFFh

Init	Proc	; Mov video segment to ES
	Push	ax
	Push	bx

	Mov	ah,83h
	Int	10h
	Mov	ah,0Fh
	Int	10h
	Mov	bx,0B800h
	Cmp	al,7
	Jne	IEnd
	Mov	bx,0B000h

IEnd:	Mov	es,bx

	Pop	bx
	Pop	ax
	Ret
Init	EndP

VAdr	Proc	; Return (ES:) DI - Address of symbol with x=dh y=dl
	Push	ax

	Mov	al,dl	; AL = y
	Mov	ah,80
	Mul	ah	; AX = 80*y
	Add	al,dh
	Adc	ah,0	; AX = 80*y+x
	Sub	ax,81	; AX = 80*(y-1)+(x-1)
	Shl	ax,1	; AX = ( 80*y+x )*2

	Mov	di,ax

	Pop	ax
	Ret
VAdr	EndP

PutCh	Proc	; Type symbol CL with atr CH coord.- (DH,DL)
	Push	di

	Call	VAdr

	Call	OutCh

	Pop	di
	Ret
PutCh	EndP

OutCh	Proc	; Store symbol CL with atr CH to ES:DI
	Push	ax
	Push	cx
	Push	dx

	Mov	dx,cs:[VMask]
	And	cx,dx
	Not	dx
	Mov	ax,es:[di]
	And	ax,dx
	Or	ax,cx
	StoSw

	Pop	dx
	Pop	cx
	Pop	ax
	Ret
OutCh	EndP

Box	Proc	; Fill a box (AH,AL)-(BH,BL) by char CL atr CH
	Push	dx
	Push	di

	Mov	dl,al
Box2:	Mov	dh,ah
	Call	VAdr
Box1:	Call	OutCh
	Inc	dh
	Cmp	dh,bh
	Jbe	Box1
	Inc	dl
	Cmp	dl,bl
	Jbe	Box2
	
	Pop	di
	Pop	dx
	Ret
Box	EndP

Frame	Proc	; Draw a frame (AH,AL)-(BH,BL) with symbols at CS:BP atr CH
	Push	dx
	Push	bp

	Mov	cl,cs:[bp]
	Mov	dx,ax
	Call	PutCh

	Mov	cl,cs:[bp+2]
	Mov	dh,bh
	Call	PutCh

	Mov	cl,cs:[bp+7]
	Mov	dl,bl
	Call	PutCh

	Mov	cl,cs:[bp+5]
	Mov	dh,ah
	Call	PutCh

	Mov	dh,ah
F1:	Inc	dh
	Cmp	dh,bh
	Jae	F2
	Mov	cl,cs:[bp+1]
	Mov	dl,al
	Call	PutCh
	Mov	cl,cs:[bp+6]
	Mov	dl,bl
	Call	PutCh
	Jmp	F1

F2:	Mov	dl,al
F3:	Inc	dl
	Cmp	dl,bl
	Jae	F4
	Mov	cl,cs:[bp+3]
	Mov	dh,ah
	Call	PutCh
	Mov	cl,cs:[bp+4]
	Mov	dh,bh
	Call	PutCh
	Jmp	F3
	
F4:	Pop	bp
	Pop	dx
	Ret
Frame	EndP

Window	Proc	; Draw a window (AH,AL)-(BH,BL) atr CH frame smb. CS:BP
	Push	bp
	Push	ax
	Push	bx
	Push	cx

	Push	VMask
	And	VMask,0FF00h
	Add	ah,2
	Add	bh,2
	Inc	al
	Inc	bl
	Mov	ch,08h
	Call	Box
	Pop	VMask

	Pop	cx
	Pop	bx
	Pop	ax
	Push	ax
	Push	bx
	Push	cx

	Mov	cl,' '
	Call	Box

	Inc	ah
	Dec	bh
	Mov	bp,OffSet VStr
	Call	Frame

	Pop	cx
	Pop	bx
	Pop	ax
	Pop	bp
	Ret
Window	EndP

OutSt	Proc	; Output string DS:SI to ES:DI
	Push	ax
	Push	cx
	Push	si

OsNxt:	LodSb
	Or	al,al
	Jz	EndOst
	Mov	cl,al
	Call	OutCh
	Jmp	OsNxt
EndOst:
	Pop	si
	Pop	cx
	Pop	ax
	Ret
OutSt	EndP

PutSt	Proc	; Пишем строку DS:SI в (DH,DL) атр CH
	Push	di

	Call	VAdr

	Call	OutSt

	Pop	di
	Ret
PutSt	EndP

Code	EndS
End	Start
