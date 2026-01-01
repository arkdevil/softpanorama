
ExitOK:		xor	al,al
		jmp	short Exit
ExitBad:	mov	al,ERRORCODE
Exit:		mov	ah,4ch
		int	21h

 PurgeSP:	cmp	byte ptr es:[di],' '	; Is this SPACE ?
		jz	Delim
                cmp	byte ptr es:[di],9	; Is this TAB ?
                jz	Delim
                ret
 Delim:		inc	di
		jmp	PurgeSP

 CopyVar:	mov	al,es:[di]
 		mov	[si],al
 		inc	di
                inc	si
                or	al,al
                jnz	CopyVar
                ret

TmpStrLen	DB	5		; Length of TmpStr
TmpStr		DB	'TEMP='
D_stack		DB	'\DirStack.$$$',0
NO_Tmp		DB	'Environment does not contain TEMP variable',13,10,'$'
CantOpMes	DB	"Can't open or create file",13,10,'$'
CantClMes	DB	"Can't close file",13,10,'$'
CantLSeek	DB	"Can't lseek",13,10,'$'
CantCD		DB	"Can't change directory",13,10,'$'
Buf0		DB	'A'
Buf01		DB	':\'
Buf1		DB	64 DUP('B')
Start1:         mov	es,ds:2ch
		xor	di,di
 RepSetFou:     mov	si,Offset TmpStr
		cld
		mov	cl,cs:TmpStrLen
                xor	ch,ch
                rep	cmpsb
                jz	TmpFound
 FindZ:		xor	al,al
                mov	cx,-1
                repne	scasb
                cmp	byte ptr es:[di],0
                jnz	RepSetFou
                ;*Not	Found*
		mov	dx,Offset NO_Tmp
                mov	ah,9
                int	21h
                jmp	ExitBad
TmpFound:	call	PurgeSP
                ; ES:DI - points to temporary file
                mov	si,Offset Buf1
                call	CopyVar
                dec	si
                dec	si
		cmp	byte ptr [si],'\'
                jz	Sl
                inc	si
 Sl:            mov	ax,ds
                mov	es,ax
                mov	di,Offset D_stack
                call	CopyVar
                ; Temporary file name at Buf1
		mov	dx,Offset Buf1
                mov	ax,3d02h
                int	21h		; Try to open
;End of include file
