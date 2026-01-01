@VID_SET_MODE	MACRO	Mode
	mov	ax, Mode
	int	10h
ENDM

@VID_PRINT_STR	MACRO	Str, Color, Length
	xor	bx, bx
	mov	ah, 3
	int	10h
	mov	ax, 1301h
	mov	bx, Color
	mov	cx, Length
	lea	bp, Str
	push	cs
	pop	es
	int	10h
ENDM

@VID_PrintStr	MACRO	Str, Color, Length
	mov	bx, Color
	mov	cx, Length
	lea	bp, Str
	call	PrintStr
ENDM

@VID_SET_CHAR	MACRO	Char, Count, SymbBuf
	xor	bl, bl
	xor	ax, ax
	mov	es, ax
	mov	ax, es:[485h]
	mov	bh, al
	push	cs
	pop	es
	mov	ax, 1100h
	mov	cx, Count
	mov	dx, Char
	lea	bp, SymbBuf
	int	10h
ENDM

@VID_GET_CURSOR	MACRO	Page
      IFNB	<Page>
	mov	bh, Page
      ELSE
	xor	bh, bh
      ENDIF
	mov	ah, 3
	int	10h
ENDM

@KBD_READ	MACRO
	xor	ah, ah
	int	16H
ENDM

@KBD_SHIFT	MACRO
	mov	ah, 2
	int	16H
ENDM

@KBD_EXT_READ	MACRO
	mov	ah, 10h
	int	16H
ENDM