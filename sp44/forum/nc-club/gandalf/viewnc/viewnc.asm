		jumps
		.model  tiny,c
		.code
		.startup
		cld
		mov	cl,ds:[80h]
		mov	ch,al
		cmp	cx,3
		jnc     Use
		jmp     HowUse
Use:		mov	di,81h
		mov	al,' '
		rep	scasb
		mov	bx,di
		dec	bx
		mov	si,bx
		mov	ah,'.'
		xor	di,di
NLoop:		lodsb
		cmp	al,ah
		jne	NoPoint
		mov	di,si
		loop	NLoop
		jmp	short ENLoop
NoPoint:        or	al,al
		je	_ENLoop
		cmp	al,' '
		je	_ENLoop
		cmp	al,0Dh
		je	_ENLoop
		loop	NLoop
_ENLoop:	cmp	di,80h
		jnc	ENLoop
		jcxz	EC
		push	si
		dec	si
		jmp	short ECont
EC:		inc	si
		inc	si
		push	si
		jmp	short ECont
ENLoop:         mov	si,di			; di - ( last '.' or end of name ) + 1
		push	si
ECont:		mov	di,offset FExt
		mov	cx,3
N_Loop:		lodsb
		or	al,al
		je	EN_Loop
		cmp	al,' '
		je	EN_Loop
		cmp	al,0Dh
		je	EN_Loop
		cmp	al,60h
		jbe	NLC
		and	al,0DFh
NLC:		stosb
		loop	N_Loop
EN_Loop:	pop	cx
		mov	si,bx
		sub	cx,si
		dec	cx
		mov	di,offset FName
		rep	movsb
EELoop:		mov	es,ds:[2Ch]
		xor	di,di
		mov	ax,di
		mov	cx,ax
		dec	cx
Env:		repne	scasb
		scasb
		jne	Env
		scasw
		push	di
		repne	scasb
		dec	di
		dec	di
		mov	al,'T'
		stosb
		pop	dx
		push	ds ds es
		pop	ds
		mov	ax,3D00h
		int	21h
		pop	ds es
                jnc     Opened
                jmp     Exit
Opened:         mov     bx,ax
		mov	dx,offset Buf
SLoop:		call	GetChar
		cmp	al,' '
		je	SLoop
		mov	si,offset FExt
		mov	cx,3
S_Loop:		cmp	al,';'
		je	SkipLine
		cmp	al,'?'
		je	Wild
		cmp	al,'*'
		je	Found
		cmp	al,' '
		jne	SCont
		cmp	[si],al
		je	Found
		jne	SkipLine
SCont:		cmp	al,60h
		jbe	SC
		and	al,0DFh
SC:		cmp	al,[si]
		jne	SkipLine
Wild:		inc	si
		dec	cx
		jcxz	Found
		call	GetChar
		jmp	short S_Loop
SkipLine:	call	GetChar
		cmp	al,0Ah
		jne	SkipLine
		je	SLoop
Found:		call	SkipSp
		cmp	al,':'
		je	Found
		mov	di,offset ExePath
DoPath:		cmp	al,' '
		je	PathDone
		cmp	al,0Dh
		je	PathDone
		stosb
		call	GetChar
		jmp	short DoPath
PathDone:	call	FindProgram
		mov	di,81h
		cmp	al,0Dh
		je	Done
		call	SkipSp
		cmp	al,'~'
		jne	FLoop
		mov	Pause,1
		call	Cls
		call	GetChar
FLoop:		cmp	al,'!'
		je	Is1
		cmp	al,'.'
		je	Is2
		cmp	al,0Dh
		je	Done
		cmp	al,39
		je	NoSpec
		mov	Was,0
F_Cont:		stosb
FCont:		call	GetChar
		jmp	short FLoop
NoSpec:		mov	Was,0
		call	GetChar
		jmp	short F_Cont
Is1:		mov	si,offset FName
		cmp	Was,1
		jne	Is_1
		mov	si,offset FExt
Is_1:		mov	Was1,0
		lodsb
		cmp	al,' '
		je	FCont
		stosb
		jmp	short Is_1
Is2:		mov	Was,1
		jmp	short F_Cont
GetChar:	push	cx
		mov	ah,3Fh
		mov	cx,1
		int	21h
		cmp	cx,ax
		jne	AllGC
		mov	al,Buf
		pop	cx
		ret
SkipSp:		call	GetChar
		cmp	al,' '
		je	SkipSp
		ret
AllGC:		pop	cx cx
Done:		mov	al,0Dh
		stosb
		mov	ax,di
		sub	ax,81h
		dec	al
		mov	ds:[80h],al
		mov	cs:[EPB+04h],cs
		mov	cs:[EPB+08h],cs
		mov	cs:[EPB+0Ch],cs
		mov	di,100h
		push    di
		mov     si,offset Codes
		mov	cx,(offset EndOf-offset Codes)/2+1
		rep	movsw
		mov     ah,4Ah
		mov	bx,11h+(offset EndOf-offset Codes)/16
		int	21h
		mov     bx,offset EPB-offset Codes+100h
		mov	ax,4B00h
		mov	dx,offset ExePath-offset Codes+100h
		ret
HowUse:		mov	ah,9
		mov	dx,offset Usage
		int	21h
		jmp	Exit

Cls		proc
		uses	ds,ax
		xor	ax,ax
		mov	ds,ax
		mov	al,ds:[449h]
		and	al,7Fh
		int	10h
		ret
Cls		endp


FindProgram	proc
		uses	si,di,es,bx,cx,dx
		mov     si,offset ExePath
		mov     di,offset AloneName
FPLoop:         lodsb
		cmp     al,'\'
		je      IsPath
		cmp     al,':'
		je      IsPath
		or	al,al
		je      FPDone
		stosb
		jmp     short FPLoop
IsPath:         call	TryComExe
		jmp	FPExit
FPDone:         mov     es,ds:[2Ch]
		xor     di,di
		mov     ax,di
		mov     cx,ax
		dec     cx
FPFind:         cmp     es:[di],'CN'
		jne     NFoundNC
		cmp     byte ptr es:[di+2],'='
		je      FoundNC
NFoundNC:       repne   scasb
		cmp     es:[di],al
		jne     FPFind
		xor	ax,ax
		mov     di,ax
		mov     cx,ax
		dec     cx
FP_Find:	cmp	es:[di],'AP'
		jne	NFoundPath
		cmp	es:[di+2],'HT'
		jne	NFoundPath
		cmp     byte ptr es:[di+4],'='
		je      FoundPath
NFoundPath:     repne   scasb
		cmp     es:[di],al
		jne     FP_Find
		lea	di,[di+3]
		push	di
		mov	bx,di
		repne	scasb
		xchg	di,bx
		mov	al,'\'
FindBSlash:	scasb
		je	IsBSlash
		cmp	di,bx
		jge	FoundBSlash
		jnge	FindBSlash
IsBSlash:	mov	si,di
		jmp	short FindBSlash
FoundBSlash:	mov	byte ptr es:[si],0
		pop	si
		call	TryPath
		jnc	IsPath
		mov	si,offset AloneName
		mov	di,offset ExePath
		mov	cx,13
		cld
		push	ds
		pop	es
		rep	movsb
		jmp	short IsPath
FoundNC:        lea	di,[di+3]
		mov	si,di
		call    TryPath
		jc	NFoundNC
		jnc	FPExit
FoundPath:	lea	di,[di+5]
PathNew:	mov	si,di
		xor	al,al
PathFind:	cmp	byte ptr es:[di],';'
		je	PathEnd
		scasb
		jne	PathFind
		dec	di
PathEnd:	mov	ah,es:[di]
		stosb
		call	TryPath
		mov	es:[di-1],ah
		jnc	FPExit
		or	ah,ah
		jne	PathNew
		jmp	NFoundPath
FPExit:		ret
FindProgram	endp

TryPath		proc
		uses	es,si,di,cx,ax,dx
		push	ds es
		pop	ds es
		mov	di,offset ExePath
TPDo1:		lodsb
		or	al,al
		je	TPDone1
		stosb
		jmp	short TPDo1
TPDone1:	cmp	byte ptr es:[di-1],'\'
		je	TPCont
		mov	al,'\'
		stosb
TPCont:		push	cs
		pop	ds
		mov	si,offset AloneName
		mov	cx,13
		cld
		rep	movsb
		call	TryComExe
		ret
TryPath		endp

TryComExe	proc
		uses    ax,bx,cx,dx,si,di,es,ds
		push	cs cs
		pop	es ds
		mov	di,offset ExePath
		mov	dx,di
		xor	ax,ax
		mov	cx,ax
		dec	cx
		repne	scasb
		dec	di
		mov	ax,3D00h
		mov	si,ax
		int	21h
		jnc	OkComExe
		mov	ax,si
		mov	si,offset TxtCom
		mov	cx,5
		push	di
		rep	movsb
		mov	si,ax
		int	21h
		jnc	OkComExe
		mov	ax,si
		mov	si,offset TxtExe
		mov	cx,4
		pop	di
		rep	movsb
		int	21h
		jc	FailComExe
OkComExe:       mov	bx,ax
		mov	ah,3Eh
		int	21h
		clc
FailComExe:	ret
TryComExe	endp


FName		db	61 dup (' ')
FExt		db	4 dup (' ')
AloneName       db      13 dup (0)
TxtCom		db	'.com',0
TxtExe		db	'.exe'
Buf             db      ?
Was		db	0
Was1		db	0
Usage		db	'NC viewers manager by Gandalf Software.',0Dh,0Ah
		db	'Usage : ViewNC <filename.ext>',0Dh,0Ah,'$'
Codes:		mov     si,cs
		mov     ss,si
		mov     sp,offset EndOf-offset Codes+100h
		int	21h
		cmp	byte ptr cs:[offset Pause-offset Codes+100h],0
		je	Xit
		xor	ax,ax
		int	16h
Xit:		mov	ax,cs
		mov	ds,ax
		mov	ah,4Dh
		int	21h
Exit:		mov	ah,4Ch
		int	21h
Pause		db	0
EPB		dw	0
		dw	80h,0
		dw	offset FCB1-offset Codes+100h,0
		dw	offset FCB2-offset Codes+100h,0
FCB1		db	0
		db	11 dup (' ')
		db	30 dup (0)
FCB2		db	0
		db	11 dup (' ')
		db	30 dup (0)
ExePath		db	64 dup (0)
Stack_		dw      30h dup (0)
EndOf		label	byte
end
