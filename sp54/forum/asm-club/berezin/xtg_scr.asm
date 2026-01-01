	.model	tiny
	.code
	org	100h
Xtg_Scr:
	JMP		Start
RegenSize	EQU	44CH
VOffs	EQU	44EH
VideoPage	EQU	462H
VideoMode	EQU	449H
PopKey	EQU	24
CtrlMask	EQU	4
SavePage	DB	?
GetVSegm	PROC
	XOR	ax,	ax
	MOV	es,	ax
	MOV	al,	es:[VideoMode]
	CMP	al,	7
	JNE	@@L1
	clc
	MOV	ax,	0B000H
	MOV	es,	ax
	JMP	@@L2
@@L1:
	CMP	al,	2
	JE	@@L4
	CMP	al,	3
	JNE	@@L3
@@L4:
	clc
	MOV	ax,	0B800H
	MOV	es,	ax
	JMP	@@L2
@@L3:
	stc
@@L2:
	RET
GetVSegm	ENDP
Store	PROC
	CALL	GetVSegm
	JNC	@@L5
	RET
@@L5:
	PUSH	es
	PUSH	es
	XOR	ax,	ax
	MOV	es,	ax
	MOV	cx,	es:[RegenSize]
	MOV	si,	es:[VOffs]
	MOV	di,	si
	ADD	di,	cx
	MOV	al,	es:[VideoPage]
	MOV	cs:SavePage,	al
	INC	cs:SavePage
	SHR	cx,	1
	POP	ds
	POP	es
	cld
	rep	movsw
	RET
Store	ENDP
ShowOrg	PROC
	sti
	MOV	cs:Activity,	1
	MOV	cs:Activation,	00
	PUSH	ax
	PUSH	bx
	PUSH	cx
	PUSH	dx
	PUSH	si
	PUSH	di
	PUSH	ds
	PUSH	es
	CALL	CheckXTG
	JC		NoShow
	XOR	ax,	ax
	MOV	es,	ax
	MOV	cl,	es:[VideoPage]
	MOV	al,	cs:SavePage
	MOV	ah,	5
	int	10H
	XOR	ah,	ah
	int	16H
	MOV	ah,	5
	MOV	al,	cl
	int	10H
NoShow:
	POP	es
	POP	ds
	POP	di
	POP	si
	POP	dx
	POP	cx
	POP	bx
	POP	ax
	MOV	cs:Activity,	00
	RET
ShowOrg	ENDP
XTGmask	DB	'XTG.EXE',0
CheckName	PROC
@@L6:
	CMP	byte	ptr	[si],	00
	JE	@@L7
	INC	si
	JMP	@@L6
@@L7:
	SUB	si,	7
	MOV	cx,	4
	PUSH	cs
	POP	es
	MOV	di,	offset XTGmask
	cld
	repe	cmpsw
	jcxz	YesCheck
	stc
	RET
YesCheck:
	clc
	RET
CheckName	ENDP
CheckXTG	PROC
	MOV	ah,	62H
	int	21H
	MOV	ds,	bx
	MOV	ds,	ds:[2CH]
	XOR	si,	si
@@L8:
	CMP	word	ptr	[si],	00
	JE	@@L9
	INC	si
	JMP	@@L8
@@L9:
	ADD	si,	4
	CALL	CheckName
	RET
CheckXTG	ENDP
Activation	DB	?
Activity	DB	?
Original21	DD	?
Original9	DD	?
Original8	DD	?
Original28	DD	?
DosBusy	DD	?
Handler28	PROC
	pushf
	call	cs:Original28
	CMP	cs:Activation,	1
	JNE	@@L10
	CMP	cs:Activity,	00
	JNE	@@L10
	call	ShowOrg
@@L10:
	iret
Handler28	ENDP
Handler8	PROC
	pushf
	call	cs:Original8
	CMP	cs:Activation,	1
	JNE	@@L11
	CMP	cs:Activity,	00
	JNE	@@L11
	PUSH	ds
	PUSH	bx
	LDS	bx,	cs:DosBusy
	CMP	byte	ptr	[bx],	00
	JNE	@@L12
	call	ShowOrg
@@L12:
	POP	bx
	POP	ds
@@L11:
	iret
Handler8	ENDP
Handler9	PROC
	PUSH	ax
	in	al,60H
	CMP	al,	PopKey
	JNE	@@L13
	PUSH	ds
	XOR	ax,	ax
	MOV	ds,	ax
	MOV	al,	ds:[417H]
	AND	al,	CtrlMask
	OR	al,	al
	JE	@@L14
	CMP	cs:Activity,	00
	JNE	@@L14
	MOV	cs:Activation,	1
@@L14:
	POP	ds
@@L13:
	POP	ax
	JMP		cs:Original9
Handler9	ENDP
Handler21	PROC
	sti
	CMP	ah,	4BH
	JNE	@@L15
	PUSH	ax
	PUSH	bx
	PUSH	cx
	PUSH	si
	PUSH	di
	PUSH	ds
	PUSH	es
	MOV	si,	dx
	CALL	CheckName
	JC	@@L16
	CALL	Store
@@L16:
	POP	es
	POP	ds
	POP	di
	POP	si
	POP	cx
	POP	bx
	POP	ax
	pushf
	cli
	call	cs:Original21
	PUSH	bp
	MOV	bp,	sp
	PUSH	ax
	PUSH	bx
	PUSH	cx
	PUSH	si
	PUSH	di
	PUSH	ds
	PUSH	es
	pushf
	CALL	CheckXTG
	JC	@@L17
	CALL	Store
@@L17:
	pop	ax
	MOV	[bp+6],	ax
	POP	es
	POP	ds
	POP	di
	POP	si
	POP	cx
	POP	bx
	POP	ax
	POP	bp
	iret
@@L15:
	cli
	JMP		cs:Original21
Handler21	ENDP
Start:
	MOV	Activation,	00
	MOV	Activity,	00
	MOV	ah,	34H
	int	21h
	MOV	word ptr DosBusy,	bx
	MOV	word ptr DosBusy[2],	es
	XOR	ax,	ax
	MOV	es,	ax
	cli
	MOV	ax,	es:[(8*4)]
	MOV	bx,	es:[(8*4)+2]
	MOV	word ptr Original8,	ax
	MOV	word ptr Original8[2],	bx
	MOV	ax,	es:[(9*4)]
	MOV	bx,	es:[(9*4)+2]
	MOV	word ptr Original9,	ax
	MOV	word ptr Original9[2],	bx
	MOV	ax,	es:[(21H*4)]
	MOV	bx,	es:[(21H*4)+2]
	MOV	word ptr Original21,	ax
	MOV	word ptr Original21[2],	bx
	MOV	ax,	es:[(28H*4)]
	MOV	bx,	es:[(28H*4)+2]
	MOV	word ptr Original28,	ax
	MOV	word ptr Original28[2],	bx
	LEA	ax,	Handler8
	MOV	es:[(8*4)],	ax
	MOV	es:[(8*4)+2],	cs
	LEA	ax,	Handler9
	MOV	es:[(9*4)],	ax
	MOV	es:[(9*4)+2],	cs
	LEA	ax,	Handler21
	MOV	es:[(21H*4)],	ax
	MOV	es:[(21H*4)+2],	cs
	LEA	ax,	Handler28
	MOV	es:[(28H*4)],	ax
	MOV	es:[(28H*4)+2],	cs
	sti
	MOV	dx,	offset Start
	int	27h
END	Xtg_Scr
