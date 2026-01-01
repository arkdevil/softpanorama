@INT	MACRO	Num, Func
	mov	ah, Func
	int	Num
ENDM

@MOV	MACRO	Dst, Src
	push	Src
	pop	Dst
ENDM

@IF	MACRO	Reg, Sign, Val, Label_
	cmp	Reg, Val
	IFIDN	<Sign>, <=>
	je	Label_
	ENDIF
	IFIDN	<Sign>, <{}>
	jne	Label_
	ENDIF
	IFIDN	<Sign>, <}>
	ja	Label_
	ENDIF
	IFIDN	<Sign>, <{>
	jb	Label_
	ENDIF
	IFIDN	<Sign>, <{=>
	jbe	Label_
	ENDIF
	IFIDN	<Sign>, <}=>
	jae	Label_
	ENDIF
ENDM

@JZ	MACRO	Reg, Label_
	or	Reg, Reg
	jz	Label_
ENDM

@JNZ	MACRO	Reg, Label_
	or	Reg, Reg
	jnz	Label_
ENDM

@JBT	MACRO	Reg, Bit, Label_
	test	Reg, 2 SHL Bit
	jnz	Label_
ENDM

@JNBT	MACRO	Reg, Bit, Label_
	test	Reg, 1 SHL Bit
	jz	Label_
ENDM
