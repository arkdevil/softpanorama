		.Model Small
                .Code
                ORG	100h
ERRORCODE	EQU	1
Start:		jmp	Start1

			;------------------------------------------------------------------------------------+
CopyRight	DB	'Unix like utilities. (C) 1992 by Yury Semenov, Odessa, 2:461/400.2@FidoNet',13,10,0;|
			;------------------------------------------------------------------------------------+

		INCLUDE PUSH&POP.INC

                ; It was try to open file
                jnc	FileOk
                mov	dx,Offset CantOpMes
CantSThg:	mov	ah,9
		int	21h
                jmp	ExitBad
FileOk:		mov	bx,ax
 		mov	ax,4202h
                xor	cx,cx
                mov	dx,cx
                int	21h		; Try to lseek to EOF
		mov	cx,dx
                mov	dx,Offset CantLSeek
                jc	CantSThg
                mov	dx,ax
                sub	dx,67
                sbb	cx,0
                jnc	PosOK
                xor	cx,cx
                mov	dx,cx
PosOK:          push	cx
		push	dx
		mov	ax,4200h
                int	21h		; Try to lseek to EOF-67
                mov	dx,Offset CantLSeek
                jc	CantSThg
		mov	ah,3fh
                mov	dx,Offset Buf0
                mov	cx,67
                int	21h		; Try to Read file
                mov	di,dx
                mov	dx,Offset CantRead
                jc	CantSThg
                or	ax,ax
                jz	CantSThg
                ; Byte counter in AX
		add	di,ax
                dec	di
                dec	di	;?
		mov	cx,ax
                dec	cx
                std
                xor	al,al
                repne	scasb
                inc	di
                cmp	byte ptr es:[di],0
                jnz	PtrOK
		inc	di
PtrOK:		mov	dx,di
		push	dx
                mov	ah,0eh
                mov	dl,es:[di]
                sub	dl,'A'
                int	21h
                mov	dx,Offset CantChD
CantSThg1:      jc	CantSThg
                pop	dx
		mov	ah,3bh
                int	21h
		mov	dx,Offset CantCD
                jc	CantSThg
                ; We must truncate file here!
		pop	dx
                pop	cx
                sub	di,Offset Buf0
                add	dx,di
                adc	cx,0
                mov	ax,4200h
                int	21h		; Try to lseek to new EOF
                mov	dx,Offset CantLSeek
                jc	CantSThg1
                mov	ah,40h
                xor	cx,cx
                int	21h		; Try to truncate file
                mov	dx,Offset CantTrunc
                jc	CantSThg1
		mov	ah,3eh
                int	21h		; Try to close
                mov	dx,Offset CantClMes
                jc	CantSThg1
		jmp	ExitOK
CantRead	DB	"Can't read the file",13,10,'$'
CantChD		DB	"Can't change drive",13,10,'$'
CantTrunc	DB	"Can't truncate file",13,10,'$'
                End	Start
