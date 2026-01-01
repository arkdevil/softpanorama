		.Model Small
                .Code
                ORG	100h
ERRORCODE	EQU	1
Start:		jmp	Start1

			;------------------------------------------------------------------------------------+
CopyRight	DB	'Unix like utilities. (C) 1992 by Yury Semenov, Odessa, 2:461/400.2@FidoNet',13,10,0;|
			;------------------------------------------------------------------------------------+

		INCLUDE PUSH&POP.INC

                jnc	FileOK
		cmp	ax,2
                jz	Create
 CantOpen:      ; *Can't open*
 		mov	dx,Offset CantOpMes
 CantSThg:      mov	ah,9
                int	21h
                jmp	ExitBad
 Create:	mov	ah,3ch
 		xor	cx,cx
                int	21h		; Try to create
		jc	CantOpen
 FileOK:	mov	bx,ax		; loading handle to bx
 		mov	ax,4202h
                xor	cx,cx
                mov	dx,cx
                int	21h		; Try to lseek to EOF
                mov	dx,Offset CantLSeek
                jc	CantSThg
                mov	ah,47h
                mov	si,Offset Buf1
                xor	dl,dl
                int	21h		; Try to PWD to Buf1
		mov	dx,Offset CantPWD
                jc	CantSThg
		mov	ah,19h
                int	21h		; Try to get current drive
                add	al,'A'
                mov	Buf0,al
		mov	di,Offset Buf1
                xor	al,al
                cld
                mov	cx,64
 		repne	scasb
                mov	cx,di
                sub	cx,Offset Buf0
                mov	ah,40h
                mov	dx,Offset Buf0
                int	21h		;Try to write
		mov	dx,Offset CantWr
                jc	CantSThg
                mov	ah,3eh
                int	21h		; Try to close
                mov	dx,Offset CantClMes
                jc	CantSThg
                ; And now we must to change directory...
                mov	bx,ds:80h
                xor	bh,bh
                mov	dx,81h
		add	bx,dx
                mov	di,dx
                call	PurgeSP
                mov	dx,di
                mov	byte ptr [bx],0
                mov	ah,3bh
                int	21h		;Try to change dir
                mov	dx,Offset CantCD
                jc	CantSThg
		jmp	ExitOK
CantPWD		DB	"Can't get work directory",13,10,'$'
CantWr		DB	"Can't write to file",13,10,'$'
                End	Start
