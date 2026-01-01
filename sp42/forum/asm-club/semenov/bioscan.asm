		.Model	Small
                .Code
                ORG	100h
 Start:		jmp	StartUp
 CopyRight	DB	'BIOS Scan Codes Viewer (C) 1992 by Yury Semenov 2:461/400.2@FidoNet$'
 StartUp:	mov	dx,Offset CopyRight
 		mov	ah,9
                int	21h
                mov	dx,Offset Mes1
                int	21h
 MainLoop:	xor	ah,ah
 		int	16h
		cmp	ah,1
                jnz	NoEscape
                dec	Count
                jz	Escape
		mov	ax,4c00h
 		int	21h
 NoEscape:	mov	Count,1
 Escape:	push	ax
 		call	TypeDec
 		pop	ax
                mov	al,ah
                call	TypeDec
                mov	ah,2
                mov	dl,13
                int	21h
                mov	dl,10
                int	21h
 		jmp	MainLoop

 TypeDec:	xor	ah,ah
 		mov	FirstZ,ah
 		mov	bl,10
                div	bl
                push	ax
                xor	ah,ah
                div	bl
                mov	dl,al
                push	ax
                call	TypeDigit
                pop	dx
                mov	dl,dh
                call	TypeDigit
                pop	dx
                mov	dl,dh
                mov	FirstZ,1
                call	TypeDigit
                mov	cx,10
                mov	dl,' '
                mov	ah,2
 Loop1:		int	21h
 		loop	Loop1
 		ret

 TypeDigit:	or	dl,dl
 		jz	Zero
		mov	FirstZ,1
 Zero:		or	dl,dl
 		jnz	AddZ
                cmp	FirstZ,0
                jnz	AddZ
                mov	dl,' '
                jmp	short DOSType
 AddZ:		add	dl,'0'
 DOSType:	mov	ah,2
                int	21h
 		ret

 Count		DB	1
 FirstZ		DB	0
 Mes1		DB	13,10,'Press <Escape> twice for exit ;-)',13,10
 		DB	'ASCII    Extended',13,10,'$'
                End	Start
