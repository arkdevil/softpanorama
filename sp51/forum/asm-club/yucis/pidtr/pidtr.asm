;
;	PID Tracker - программа для отслеживания DOS PID
;	Автор: Михаил Юцис  (037-22) 2-55-51 (д.)
;	Turbo Assembler 2.5 (можно и ниже)

		.model	tiny
		.code
		jumps
		org	0f0h
pidptr		label	dword
		org	0f4h
vidseg		label	word
		org	0f6h
ver		label	byte
		org	0f7h
color		label	byte
		org	100h
pidtrack:
		jmp	inst
		nop
new8:		push	ax ds
		xor	ax,ax
		mov	ds,ax
;		test	byte ptr ds:[467h],1
;		jz	ee
		push	di si es cx bx
		cld
		lds	di,cs:pidptr
		mov	bx,ds:[di]
		xor	di,di
		mov	cl,4
		mov	ax,cs:vidseg
		mov	es,ax
		mov	ah,cs:color
		mov	al,bh
		shr	al,cl
		call	itoa
		mov	al,bh
		and	al,0fh
		call	itoa
		mov	al,bl
		shr	al,cl
		call	itoa
		mov	al,bl
		and	al,0fh
		call	itoa
		cmp	cs:[ver],4
		jb	no5
		mov	al,' '
		stosw
		dec	bx
		mov	ds,bx
		mov	si,8
		mov	cx,si
	lp:	lodsb
		or	al,al
		jz	el
		stosw
		loop	lp
	el:	jcxz	no5
		mov	al,' '
		rep	stosw
	no5:	pop	bx cx es si di
ee:		pop	ds ax
		db	0eah
old8:		dw	0,0

itoa		proc	near
		add	al,'0'
		cmp	al,3ah
		jb	ok
		add	al,'@'-'9'
	ok:	stosw
		ret
		endp
		
inst:		mov	ah,30h
		int	21h
		cmp	al,3
		jb	oldver
		mov	ver,al
		mov	ah,9
		mov	dx,offset logo
		int	21h
		mov	ah,62h
		int	21h
		mov	ax,1203h
		int	2fh
		mov	word ptr cs:pidptr+2,ds
		xor	di,di
		push	ds
		pop	es
		mov	ax,bx
		mov	dx,bx
		mov	cx,0ffffh
	sca:	repne	scasw	;di=pitptr?+2
		jcxz	er
		mov	ah,50h
		mov	bx,cs:testpsp
		inc	cs:testpsp
		int	21h
		cmp	bx,es:[di-2]
		mov	ax,bx
		jne	sca
		push	cs
		pop	ds
		lea	ax,[di-2]
		mov	word ptr pidptr,ax
		mov	bx,dx
		mov	ah,50h
		int	21h
		mov	ax,3508h
		int	21h
		mov	word ptr [old8],bx
		mov	word ptr [old8+2],es
		mov	dx,offset new8
		mov	ah,25h
		int	21h
		mov	ah,0fh
		int	10h
		cmp	al,7
		mov	cs:vidseg,0b800h
		mov	cs:color,47h
		jne	nomda
		mov	cs:vidseg,0b000h
		mov	cs:color,0fh
nomda:		mov	dx,offset inst
		int	27h
		
oldver:		mov	dx,offset vermsg
		jmp	msg
er:		mov	bx,dx
		mov	dx,offset errmsg
msg:		push	cs
		pop	ds
		mov	ah,50h
		int	21h
		mov	ah,9
		int	21h
		ret
logo		db	'PID Tracker   V1.01   by M.Yutsis, Jun 1992',13,10,'$'
testpsp		dw	4321h
errmsg		db	'Cannot find DOS PID pointer!$'
vermsg		db	'DOS 3.0 or later required!$'

		end	pidtrack
