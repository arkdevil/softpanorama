		.model	tiny,c

		.code
		.startup
		jmp	Install

Page		db	0
Rows		db	0
Columns		db	0
OldCursorPos	dw	0
Old09		dd	0

Int05		proc	far
		push	ax bx cx dx si di bp ds es
		mov	ah,0Fh
		int	10h
		mov	cs:Page,bh
		mov	cs:Columns,ah
		xor	ax,ax
		mov	ds,ax
		mov	ax,ds:[44Ch]
		div	byte ptr cs:Columns
		shr	al,1
		mov	cs:Rows,al
		mov	ah,03h
		int	10h
		mov	cs:OldCursorPos,dx
		xor	dx,dx
PrLoop:		mov	ah,02h
		int	10h
		mov	ah,08h
		int	10h
		mov	ah,00h
		push	dx
		xor	dx,dx
		cmp	al,' '
		jae	PrChar
		mov	al,'·'
PrChar:		int	17h
		pop	dx
		inc	dl
		cmp	dl,cs:Columns
		jb	PrLoop
		push	dx
		xor	dx,dx
		mov	ax,000Dh
		int	17h
		mov	ax,000Ah
		int	17h
		pop	dx
		mov	dl,0
		inc	dh
		cmp	dh,cs:Rows
		jb	PrLoop
		mov	ah,02h
		mov	dx,cs:OldCursorPos
		int	10h
		pop	es ds bp di si dx cx bx ax
		iret
Int05		endp

Int09		proc	far
		push	ax
		in	al,60h
		cmp	al,37h
		je	PrtScr
		pop	ax
		jmp	dword ptr cs:[Old09]
PrtScr:		in	al,61h
		mov	ah,al
		or	al,80h
		out	61h,al
		mov	al,ah
		out	61h,al
		mov	al,20h
		out	20h,al
		pop	ax
		cli
		jmp	Int05
Int09		endp

Install		proc
		mov	ah,09h
		mov	dx,offset MyTitle
		int	21h
		xor	ax,ax
		mov	ds,ax
		mov	ax,ds:[09h*4][0]
		mov	word ptr cs:Old09[0],ax
		mov	ax,ds:[09h*4][2]
		mov	word ptr cs:Old09[2],ax
		cli
		mov	word ptr ds:[09h*4][0],offset Int09
		mov	word ptr ds:[09h*4][2],cs
		mov	word ptr ds:[05h*4][0],offset Int05
		mov	word ptr ds:[05h*4][2],cs
		mov	dx,offset Install
		int	27h
Install		endp

MyTitle		db	'PRTSCR - Print Screen handler  Version 1.00  Copyright (c) 1991 7-Soft',0Dh,0Ah,'$'

		end