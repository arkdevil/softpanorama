.model large

comment |


 библиотека PCX для Боpланд Tasm 3.1
 используется в Клиппеp'е для показа VGA каpтинок
 с палитpой в pежиме 12h	640x480x16

 Clipper example:

 external pcxFD
 pcxFD("testname.pcx",1,2,3)

 to build an .EXE, type:

 clipper %1
 tlink /x %1.obj clip_pcx.obj ,,, clipper.lib extend.lib	> err
 type err
 pause

 |

locals

extrn	__parinfo: far, __parc: far, __parni: far, __retni: far
pcxType	equ 7

_wait macro
	push	ax
	xor	ax,ax
	int	16h
	pop	ax
endm

.code


Public	PCXFD

PCXFD proc far
	push	bp
	mov	bp,sp
	sub	sp,2
	sub	ax,ax
	push	ax
	call	__parinfo
	add	sp,2
	cmp	ax,4
	Jnz	@@bad_parm
	Mov	AX,1
	Push	AX
	Call	__parc
	Add	SP,2
		Push	DX ax
	Mov	AX,2
	Push	AX
	Call	__parni
	Add	SP,2
		Push	AX
	Mov	AX,3
	Push	AX
	Call	__parni
	Add	SP,2
		Push	AX
	Mov	AX,4
	Push	AX
	Call	__parni
	Add	SP,2
		Push	AX
	Call	far ptr PCX
	Mov	[BP-2],AX
	Jmp	short @@ret
@@bad_parm:
	Mov	[BP-2],0FFF1h
@@ret:
	Push	[BP-2]
	call	__retni
	mov	sp,bp
	pop	bp
	retf
endp


_DOS macro
	int	21h
endm

_VID macro
	int	10h
endm

__VID macro
	push	bp
	int	10h
	pop	bp
endm



pcx		proc	far
arg c, b, a, string:dword
	push	bp
	mov	bp,sp
		push	ds
		mov	ax,@data
		mov	ds,ax
		mov	ax,pcxType
		call	PcxSetDisplay
		or	ax,ax
		js	loc_7
		mov	ax,1
		push	ax cs
		call	PcxSetMode
		cmp	ax,0
		jae	loc_3
		jmp	short loc_7
loc_3:
		push	ds
		mov	ax,pcxType
		push	ax
		lds	ax, dword ptr string
		push	ds ax
		mov	ax,@data
		push	ax
		mov	ax,offset paletteBuffer
		push	ax
		call	far ptr PcxGetFilePalette
		pop	ds
		cmp	ax,0
		je	loc_4
		jmp	short loc_6
loc_4:
		push	ds
		mov	ax,offset paletteBuffer
		push	ax cs
		call	PcxSetDisplayPalette
		cmp	ax,0
		je	loc_5
		jmp	short loc_6
loc_5:
		push	ds
		lds	ax,dword ptr string
		push	ds
		push	ax
		mov	ax,0
		push	ax ax ax cs
		call	PcxFileDisplay
		pop	ds
		cmp	ax,0
		je	loc_6
loc_6:
		_wait

		mov	ax,0
		push	ax cs
		call	PcxSetMode
loc_7:
		pop	ds
		pop	bp
		retf	0Ah
pcx		endp




PcxDisp		dw	0FFFFh
PcxSetDisplay proc near
		push	ds cs
		pop	ds
		cmp	ax,0
		jb	@@1
		cmp	ax,15h
		jbe	@@2
@@1:
		mov	ax,0FFFAh
		jmp	short @@3
@@2:
		mov	PcxDisp,ax
		xor	ax,ax
@@3:
		pop	ds
		retn
PcxSetDisplay		endp




PcxSetMode proc near
		push	bp
		mov	bp,sp
		push	ds es si di
		mov	ax,@data
		mov	ds,ax
		mov	ax,cs:PcxDisp
		call	PcxGetDispStruc
		cmp	ax,0
		jae	@@1
		jmp	short @@done
@@1:
		mov	di,ax
		mov	es,dx
		mov	bx,[bp+6]	; 0 или 1
		cmp	bx,1
		jne	loc_13
		mov	PcxMode,bx
		mov	PcxPage,0
		mov	ax,2
		cmp	byte ptr es:[di],9
		je	@@to_ClrScreen
		push	bx
		mov	ah,0Fh
		__VID
						;	get state, al=mode, bh=page
						;	ah=columns on screen
		pop	bx
		cmp	al,es:[di+16h]
		je	@@done
		mov	al,es:[di+16h]
		mov	ah,0
		__VID
						;	set display mode in al
		jmp	short @@done
loc_13:
		cmp	bx,0
		jne	loc_15
		mov	PcxMode,bx
		mov	PcxPage,0
		mov	ax,20h
		cmp	byte ptr es:[di],9
		je	@@to_ClrScreen
		mov	ax,3
		__VID	;	set display mode in al
		jmp	short @@done
@@to_ClrScreen:
		call	far ptr ClrScreen
		jmp	short @@done
loc_15:
		mov	ax,0FFF9h
@@done:
		pop	di si es ds
		pop	bp
		retf	2
PcxSetMode		endp


PcxGetDisplay proc near
		mov	ax,cs:PcxDisp
		cmp	ax,0
		jl	@@1
		cmp	ax,15h
		jle	@@2
@@1:
		mov	ax,0FFFAh
@@2:
		retn
PcxGetDisplay endp


PcxGetDispStruc proc near
		push	ds es di
		cmp	ax,0
		jb	@@1
		cmp	ax,15h
		jbe	@@2
@@1:
		mov	ax,0FFFAh
		jmp	short @@4
@@2:
		mov	bl,al
		mov	cx,38h
		mul	cx
		add	ax,offset data_32
		mov	di,ax
		mov	dx,@data
		mov	es,dx
		cmp	bl,es:[di]
		je	@@4
		mov	ax,0FC19h
@@4:
		pop	di es ds
		retn
PcxGetDispStruc endp



ClrScreen	proc	far
push	ax
	cmp	al,2
	je	@@1
	mov	si,offset data_58-0Ch
	mov	bx,720h
	push	bx
	mov	bx,7D0h
	push	bx
	jmp	short loc_29
@@1:
	mov	si,offset data_58
	mov	bx,0
	push	bx
	mov	bx,4000h
	push	bx

loc_29:
		mov	dx,3B8h
		out	dx,al	; port 3B8h, MDA video control
		mov	cx,0Ch
		xor	ah,ah
		cld
locloop_30:
		mov	al,ah
		mov	dx,3B4h
		out	dx,al	; port 3B4h, MDA/EGA reg index
					;	al = 0, horiz char total
		lodsb
		mov	bl,al
		mov	dx,3B5h
		out	dx,al	; port 3B5h, MDA/EGA indxd data
		inc	ah
		loop	locloop_30

		pop	cx
		mov	ax,0B000h
		mov	es,ax
		xor	di,di
		pop	ax
		rep	stosw
		pop	bx
		add	bl,8
		mov	al,bl
		mov	dx,3B8h
		out	dx,al			; port 3B8h, MDA video control
		retf
ClrScreen	endp




PcxBufferDisplay		proc	far
		push	bp
		mov	bp,sp
		sub	sp,1Eh
		push	ds es si di
		mov	ax,@data
		mov	ds,ax
		cmp	byte ptr PcxDinit,1
		je	loc_33
		call	far ptr sub_7
loc_33:
		mov	ax,PcxMcheck
		mov	[bp-4],ax
		mov	ax,[bp+10h]
		mov	ds,ax
		mov	si,[bp+0Eh]
		mov	[bp-8],si
		mov	bx,[bp+0Ch]
		add	bx,[bp-8]
		dec	bx
		mov	[bp-0Ah],bx
		mov	al,[si]
		cmp	al,0Ah
		je	loc_34
		mov	word ptr [bp-2],0FFFBh
		jmp	short loc_38
loc_34:
		call	PcxGetDisplay
		cmp	ax,0
		jge	loc_35
		mov	[bp-2],ax
		jmp	short loc_38
loc_35:
		call	PcxGetDispStruc
		cmp	ax,0
		jae	loc_36
		mov	word ptr [bp-2],0FC19h
		jmp	short loc_38
loc_36:
		mov	di,ax
		mov	es,dx
		cmp	word ptr [bp-4],1
		jne	loc_37
		cmp	byte ptr es:[di],9
		je	loc_37
		mov	ah,0Fh
		__VID
						;	get state, al=mode, bh=page
						;	ah=columns on screen
		cmp	al,es:[di+16h]
		je	loc_37
		mov	word ptr [bp-2],0FFF9h
		jmp	short loc_38
loc_37:
		jmp	dword ptr es:[di+24h]	; уходим на соответствующую
						; пpоцедуpу вывода на экpан
loc_38:
		mov	ax,[bp-2]
		pop	di si es ds
		mov	sp,bp
		pop	bp
		retf	0Ch
PcxBufferDisplay		endp






sub_7		proc	far
		push	si
		mov	si,offset Code_1
		mov	ax,0
		call	p7

		mov	ax,1
		call	p7

		mov	si,offset Code_2
		mov	ax,2
		call	p7

		mov	ax,3
		call	p7

		mov	ax,4
		call	p7

		mov	ax,5
		call	p7

		mov	ax,6
		call	p7

		mov	ax,7
		call	p7

		mov	si,offset Code_3
		mov	ax,8
		call	p7

		mov	si,offset Code_4
		mov	ax,9
		call	p7

		mov	si,offset Code_2
		mov	ax,0Ah
		call	p7

		mov	si,offset Code_6
		mov	ax,0Bh
		call	p7

		mov	ax,0Ch
		call	p7

		mov	ax,0Dh
		call	p7

		mov	si,offset Code_2
		mov	ax,0Eh
		call	p7

		mov	ax,0Fh
		call	p7

		mov	si,offset Code_5
		mov	ax,10h
		call	p7

		mov	ax,11h
		call	p7

		mov	si,offset Code_2
		mov	ax,12h
		call	p7

		mov	si,offset Code_7
		mov	ax,13h
		call	p7
		mov	ax,14h
		call	p7
		mov	ax,15h
		call	p7
		mov	byte ptr PcxDinit,1
		pop	si
		retf
sub_7		endp

p7 proc near
		call	PcxGetDispStruc
		mov	bx,ax
		mov	word ptr [bx+24h],si
		mov	word ptr [bx+26h],cs
		retn
endp

Code_1:
		mov	ax,[si+8]
		sub	ax,[si+4]
		inc	ax
		mov	bx,[bp+0Ah]
		add	bx,ax
		cmp	bx,es:[di+18h]
		jbe	loc_39
		mov	ax,es:[di+18h]
		sub	ax,[bp+0Ah]
		inc	ax
loc_39:
		mov	bl,[si+3]
		xor	bh,bh
		mul	bx
		mov	bl,8
		div	bl
		mov	cl,ah
		xor	ah,ah
		mov	[bp-10h],ax
		dec	word ptr [bp-10h]
		mov	word ptr [bp-0Eh],0
		cmp	cl,0
		je	loc_40
		mov	word ptr [bp-0Eh],1
		mov	al,80h
		dec	cl
		sar	al,cl
		mov	[bp-0Ch],al
		inc	word ptr [bp-10h]
loc_40:
		mov	dx,[bp+0Ah]
		mov	cl,4
		sub	cl,es:[di+17h]
		shr	dx,cl
		mov	ax,[bp+8]
		shr	ax,1
		mov	cl,4
		shl	ax,cl
		add	dx,ax
		shl	ax,1
		shl	ax,1
		add	dx,ax
		mov	ax,[bp+8]
		and	ax,1
		mov	[bp-6],ax
		cmp	ax,1
		jne	loc_41
		add	dx,2000h
loc_41:
		mov	ax,[si+0Ah]
		sub	ax,[si+6]
		inc	ax
		mov	bx,[bp+8]
		add	bx,ax
		cmp	bx,es:[di+1Ah]
		jbe	loc_42
		mov	ax,es:[di+1Ah]
		sub	ax,[bp+8]
loc_42:
		mov	bh,al
		mov	bl,0
		mov	ax,es:[di+1Eh]
		mov	es,ax
		mov	di,dx
		mov	dx,[si+42h]
		mov	ax,[bp-6]
		mov	dh,al
		mov	ax,2000h
		sub	ax,[si+42h]
		mov	[bp-4],ax
		add	si,80h ; offset data_9
		cld
loc_43:
		xor	ch,ch
		mov	cl,1
		lodsb
		mov	ah,al
		and	ah,0C0h
		cmp	ah,0C0h
		jne	locloop_44
		mov	cl,al
		sub	cl,0C0h
		lodsb

locloop_44:
		cmp	bl,[bp-10h]
		jb	loc_45
		ja	loc_46
		cmp	word ptr [bp-0Eh],1
		jne	loc_45
		push	ax
		mov	ah,es:[di]
		or	ah,[bp-0Ch]
		sub	ah,[bp-0Ch]
		and	al,[bp-0Ch]
		or	al,ah
		mov	es:[di],al
		pop	ax
		jmp	short loc_46
loc_45:
		mov	es:[di],al
loc_46:
		inc	di
		inc	bl
		cmp	bl,dl
		jne	loc_48
		dec	bh
		xor	bl,bl
		cmp	bh,0
		je	loc_50
		xor	dh,1
		cmp	dh,1
		jne	loc_47
		add	di,[bp-4]
		jmp	short loc_48
loc_47:
		sub	di,1FB0h
		sub	di,dx
loc_48:
		loop	locloop_44

		cmp	si,[bp-0Ah]
		jbe	loc_49
		push	si
		call	far ptr PcxBufferFill
		mov	si,ax
		jnc	loc_49
		mov	word ptr [bp-2],0FFFDh
		jmp	short loc_51
loc_49:
		jmp	short loc_43
loc_50:
		mov	word ptr [bp-2],0
loc_51:
		mov	ax,[bp-2]
		pop	di si es ds
		mov	sp,bp
		pop	bp
		retf	0Ch


Code_2:
		mov	ax,es:[di+18h]
		mov	cl,3
		shr	ax,cl
		mov	[bp-16h],ax
		mov	word ptr [bp-0Eh],0
		mov	ax,[si+8]
		sub	ax,[si+4]
		inc	ax
		mov	bx,[bp+0Ah]
		add	bx,ax
		cmp	bx,es:[di+18h]
		jbe	loc_52
		mov	ax,es:[di+18h]
		sub	ax,[bp+0Ah]
		inc	ax
		test	al,7
		jz	loc_52
		inc	ax
		and	al,0F8h
loc_52:
		mov	bl,[si+3]
		xor	bh,bh
		mul	bx
		mov	bl,8
		div	bl
		mov	cl,ah
		xor	ah,ah
		mov	[bp-10h],ax
		dec	word ptr [bp-10h]
		cmp	cl,0
		je	loc_53
		mov	word ptr [bp-0Eh],1
		mov	al,80h
		dec	cl
		sar	al,cl
		mov	[bp-0Ch],al
		inc	word ptr [bp-10h]
loc_53:
		mov	al,5
		mov	dx,3CEh
		out	dx,al			; port 3CEh, EGA graphic index
						;	al = 5, mode
		inc	dx
		mov	al,0
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,8
		mov	dx,3CEh
		out	dx,al			; port 3CEh, EGA graphic index
						;	al = 8, data bit mask
		inc	dx
		mov	al,0FFh
		out	dx,al			; port 3CFh, EGA graphic func
		mov	byte ptr [bp-18h],1
		mov	al,2
		mov	dx,3C4h
		out	dx,al			; port 3C4h, EGA sequencr index
						;	al = 2, map mask register
		inc	dx
		mov	al,[bp-18h]
		out	dx,al			; port 3C5h, EGA sequencr func
		mov	word ptr [bp-1Ch],1
		mov	word ptr [bp-1Ah],8
		cmp	byte ptr [si+41h],3
		jne	loc_54
		mov	word ptr [bp-1Ah],4
loc_54:
		cmp	byte ptr [si+41h],1
		jne	loc_55
		mov	word ptr [bp-1Ch],0Fh
		mov	word ptr [bp-1Ah],1
		mov	al,2
		mov	dx,3C4h
		out	dx,al			; port 3C4h, EGA sequencr index
						;	al = 2, map mask register
		inc	dx
		mov	al,0Fh
		out	dx,al			; port 3C5h, EGA sequencr func
loc_55:
		mov	ax,es:[di+20h]
		mov	bx,[bp+6]
		mul	bx
		mov	dx,ax
		mov	ax,[bp+0Ah]
		mov	cl,3
		shr	ax,cl
		add	dx,ax
		mov	ax,[bp+8]
		cmp	word ptr [bp-16h],50h
		je	loc_56
		cmp	word ptr [bp-16h],64h
		je	loc_57
		mov	cl,3
		shl	ax,cl
		add	dx,ax
		shl	ax,1
		shl	ax,1
		add	dx,ax
		jmp	short loc_58
loc_56:
		mov	cl,4
		shl	ax,cl
		add	dx,ax
		shl	ax,1
		shl	ax,1
		add	dx,ax
		jmp	short loc_58
loc_57:
		shl	ax,1
		shl	ax,1
		add	dx,ax
		shl	ax,1
		shl	ax,1
		shl	ax,1
		add	dx,ax
		shl	ax,1
		add	dx,ax
loc_58:
		mov	ax,[si+0Ah]
		sub	ax,[si+6]
		inc	ax
		mov	[bp-12h],ax
		mov	bx,[bp+8]
		add	bx,ax
		cmp	bx,es:[di+1Ah]
		jbe	loc_59
		mov	ax,es:[di+1Ah]
		sub	ax,[bp+8]
		inc	ax
		mov	[bp-12h],ax
loc_59:
		mov	bx,0h
		mov	ax,es:[di+1Eh]
		mov	es,ax
		mov	di,dx
		mov	ax,[si+42h]
		mov	[bp-14h],ax
		add	si,80h ; offset data_9
		cld
loc_60:
		mov	cx,1
		lodsb
		mov	ah,al
		and	ah,0C0h
		cmp	ah,0C0h
		jne	locloop_61
		mov	cl,al
		sub	cl,0C0h
		lodsb

locloop_61:
		cmp	bx,[bp-10h]
		jb	loc_62
		ja	loc_63
		cmp	word ptr [bp-0Eh],1
		jne	loc_62
		push	ax
		mov	al,8
		mov	dx,3CEh
		out	dx,al			; port 3CEh, EGA graphic index
						;	al = 8, data bit mask
		inc	dx
		mov	al,[bp-0Ch]
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,es:[bx+di]
		pop	ax
		mov	es:[bx+di],al
		push	ax
		mov	al,8
		mov	dx,3CEh
		out	dx,al			; port 3CEh, EGA graphic index
						;	al = 8, data bit mask
		inc	dx
		mov	al,0FFh
		out	dx,al			; port 3CFh, EGA graphic func
		pop	ax
		jmp	short loc_63
loc_62:
		mov	es:[bx+di],al
loc_63:
		inc	bx
		cmp	bx,[bp-14h]
		jne	loc_65
		xor	bx,bx
		mov	dx,[bp-1Ah]
		shl	byte ptr [bp-18h],1
		cmp	[bp-18h],dl
		jbe	loc_64
		mov	dx,[bp-1Ch]
		mov	[bp-18h],dl
		add	di,[bp-16h]
		dec	word ptr [bp-12h]
		jz	loc_67
loc_64:
		push	ax
		mov	al,2
		mov	dx,3C4h
		out	dx,al			; port 3C4h, EGA sequencr index
						;	al = 2, map mask register
		inc	dx
		mov	al,[bp-18h]
		out	dx,al			; port 3C5h, EGA sequencr func
		pop	ax
loc_65:
		loop	locloop_61

		cmp	si,[bp-0Ah]
		jbe	loc_66
		push	si
		call	far ptr PcxBufferFill
		mov	si,ax
		jnc	loc_66
		mov	word ptr [bp-2],0FFFDh
		jmp	short loc_68
loc_66:
		jmp	loc_60
loc_67:
		mov	al,2
		mov	dx,3C4h
		out	dx,al			; port 3C4h, EGA sequencr index
						;	al = 2, map mask register
		inc	dx
		mov	al,0FFh
		out	dx,al			; port 3C5h, EGA sequencr func
		mov	word ptr [bp-2],0
loc_68:
		mov	ax,[bp-2]
		pop	di si es ds
		mov	sp,bp
		pop	bp
		retf	0Ch

Code_3:
		mov	ax,es:[di+18h]
		mov	[bp-16h],ax
		mov	ax,[si+8]
		sub	ax,[si+4]
		inc	ax
		mov	bx,[bp+0Ah]
		add	bx,ax
		cmp	bx,es:[di+18h]
		jbe	loc_69
		mov	ax,es:[di+18h]
		sub	ax,[bp+0Ah]
loc_69:
		dec	ax
		mov	[bp-10h],ax
		mov	ax,[bp+8]
		xchg	ah,al
		mov	dx,ax
		shr	ax,1
		shr	ax,1
		add	dx,ax
		mov	ax,[bp+0Ah]
		add	dx,ax
		mov	ax,[si+0Ah]
		sub	ax,[si+6]
		inc	ax
		mov	[bp-12h],ax
		mov	bx,[bp+8]
		add	bx,ax
		cmp	bx,es:[di+1Ah]
		jbe	loc_70
		mov	ax,es:[di+1Ah]
		sub	ax,[bp+8]
		inc	ax
		mov	[bp-12h],ax
loc_70:
		mov	bx,0h
		mov	ax,es:[di+1Eh]
		mov	es,ax
		mov	di,dx
		mov	ax,[si+42h]
		mov	[bp-14h],ax
		add	si,80h ; offset data_9
		cld
loc_71:
		mov	cx,1
		lodsb
		mov	ah,al
		and	ah,0C0h
		cmp	ah,0C0h
		jne	locloop_72
		mov	cl,al
		sub	cl,0C0h
		lodsb

locloop_72:
		cmp	bx,[bp-10h]
		ja	loc_73
		mov	es:[bx+di],al
loc_73:
		inc	bx
		cmp	bx,[bp-14h]
		jne	loc_74
		xor	bx,bx
		add	di,[bp-16h]
		dec	word ptr [bp-12h]
		jz	loc_76
loc_74:
		loop	locloop_72

		cmp	si,[bp-0Ah]
		jbe	loc_75
		push	si
		call	far ptr PcxBufferFill
		mov	si,ax
		jnc	loc_75
		mov	word ptr [bp-2],0FFFDh
		jmp	short loc_77
loc_75:
		jmp	short loc_71
loc_76:
		mov	word ptr [bp-2],0
loc_77:
		mov	ax,[bp-2]
		pop	di si es ds
		mov	sp,bp
		pop	bp
		retf	0Ch

Code_4:
		mov	ax,[si+8]
		sub	ax,[si+4]
		inc	ax
		mov	bx,[bp+0Ah]
		add	bx,ax
		cmp	bx,es:[di+18h]
		jbe	loc_78
		mov	ax,es:[di+18h]
		sub	ax,[bp+0Ah]
		inc	ax
loc_78:
		mov	bl,8
		div	bl
		mov	cl,ah
		xor	ah,ah
		mov	[bp-10h],ax
		dec	word ptr [bp-10h]
		mov	word ptr [bp-0Eh],0
		cmp	cl,0
		je	loc_79
		mov	word ptr [bp-0Eh],1
		mov	al,80h
		dec	cl
		sar	al,cl
		mov	[bp-0Ch],al
		inc	word ptr [bp-10h]
loc_79:
		mov	ax,[bp+8]
		xor	ah,ah
		and	al,3
		mov	[bp-6],ax
		mov	ax,es:[di+20h]
		mov	bx,[bp+6]
		mul	bx
		mov	cx,ax
		mov	ax,[bp+8]
		mov	bx,[bp+0Ah]
		shr	ax,1
		rcr	bx,1
		shr	ax,1
		rcr	bx,1
		shr	bx,1
		mov	ah,5Ah			; 'Z'
		mul	ah
		add	bx,ax
		add	cx,bx
		mov	ax,[si+0Ah]
		sub	ax,[si+6]
		inc	ax
		mov	[bp-12h],ax
		mov	bx,[bp+8]
		add	bx,ax
		cmp	bx,es:[di+1Ah]
		jbe	loc_80
		mov	ax,es:[di+1Ah]
		sub	ax,[bp+8]
		inc	ax
		mov	[bp-12h],ax
loc_80:
		mov	bx,0h
		mov	dx,[bp-6]
		mov	ax,es:[di+1Eh]
		mov	es,ax
		mov	di,cx
		mov	ax,[si+42h]
		mov	[bp-14h],ax
		add	si,80h ; offset data_9
		cld
loc_81:
		mov	cx,1
		lodsb
		mov	ah,al
		and	ah,0C0h
		cmp	ah,0C0h
		jne	locloop_82
		mov	cl,al
		sub	cl,0C0h
		lodsb

locloop_82:
		cmp	bl,[bp-10h]
		jb	loc_83
		ja	loc_84
		cmp	word ptr [bp-0Eh],1
		jne	loc_83
		push	ax
		mov	ah,es:[bx+di]
		or	ah,[bp-0Ch]
		sub	ah,[bp-0Ch]
		and	al,[bp-0Ch]
		or	al,ah
		mov	es:[bx+di],al
		pop	ax
		jmp	short loc_84
loc_83:
		mov	es:[bx+di],al
loc_84:
		inc	bx
		cmp	bx,[bp-14h]
		jne	loc_86
		xor	bx,bx
		dec	word ptr [bp-12h]
		jz	loc_88
		inc	dx
		cmp	dx,4
		jb	loc_85
		sub	di,5FA6h
		xor	dx,dx
		jmp	short loc_86
loc_85:
		add	di,2000h
loc_86:
		loop	locloop_82

		cmp	si,[bp-0Ah]
		jbe	loc_87
		push	si
		call	far ptr PcxBufferFill
		mov	si,ax
		jnc	loc_87
		mov	word ptr [bp-2],0FFFDh
		jmp	short loc_89
loc_87:
		jmp	short loc_81
loc_88:
		mov	word ptr [bp-2],0
loc_89:
		mov	ax,[bp-2]
		pop	di si es ds
		mov	sp,bp
		pop	bp
		retf	0Ch

Code_5:
		mov	ax,es:[di+18h]
		mov	[bp-16h],ax
		mov	ax,[si+8]
		sub	ax,[si+4]
		inc	ax
		mov	bx,[bp+0Ah]
		add	bx,ax
		cmp	bx,es:[di+18h]
		jbe	loc_90
		mov	ax,es:[di+18h]
		sub	ax,[bp+0Ah]
loc_90:
		dec	ax
		mov	[bp-10h],ax
		mov	ax,[bp+8]
		mov	bx,ax
		mov	cl,5
		shr	bx,cl
		mov	[bp-1Eh],bl
		shl	bx,cl
		sub	ax,bx
		xchg	ah,al
		shl	ax,1
		mov	dx,ax
		shr	ax,1
		shr	ax,1
		add	dx,ax
		mov	ax,[bp+0Ah]
		add	dx,ax
		mov	ax,[si+0Ah]
		sub	ax,[si+6]
		inc	ax
		mov	[bp-12h],ax
		mov	bx,[bp+8]
		add	bx,ax
		cmp	bx,es:[di+1Ah]
		jbe	loc_91
		mov	ax,es:[di+1Ah]
		sub	ax,[bp+8]
		inc	ax
		mov	[bp-12h],ax
loc_91:
		mov	bx,0h
		mov	ax,es:[di+1Eh]
		mov	es,ax
		mov	di,dx
		mov	ax,[si+42h]
		mov	[bp-14h],ax
		add	si,80h ; offset data_9
		cld
		mov	al,0Fh
		mov	dx,3CEh
		out	dx,al			; port 3CEh, EGA graphic index
		inc	dx
		mov	al,5
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,[bp-1Eh]
		mov	ah,al
		shl	al,1
		shl	al,1
		add	al,ah
		mov	[bp-1Eh],al
		mov	al,9
		mov	dx,3CEh
		out	dx,al			; port 3CEh, EGA graphic index
		inc	dx
		mov	al,[bp-1Eh]
		out	dx,al			; port 3CFh, EGA graphic func
loc_92:
		mov	cx,1
		lodsb
		mov	ah,al
		and	ah,0C0h
		cmp	ah,0C0h
		jne	locloop_93
		mov	cl,al
		sub	cl,0C0h
		lodsb

locloop_93:
		cmp	bx,[bp-10h]
		ja	loc_94
		mov	es:[bx+di],al
loc_94:
		inc	bx
		cmp	bx,[bp-14h]
		jne	loc_95
		xor	bx,bx
		add	di,[bp-16h]
		dec	word ptr [bp-12h]
		jz	loc_97
		cmp	di,5000h
		jb	loc_95
		push	ax bx
		mov	bh,[bp-1Eh]
		add	bh,5
		mov	[bp-1Eh],bh
		mov	al,9
		mov	dx,3CEh
		out	dx,al			; port 3CEh, EGA graphic index
		inc	dx
		mov	al,bh
		out	dx,al			; port 3CFh, EGA graphic func
		pop	bx ax
		mov	di,[bp+0Ah]
loc_95:
		loop	locloop_93

		cmp	si,[bp-0Ah]
		jbe	loc_96
		push	si
		call	far ptr PcxBufferFill
		mov	si,ax
		jnc	loc_96
		mov	word ptr [bp-2],0FFFDh
		jmp	short loc_98
loc_96:
		jmp	short loc_92
loc_97:
		mov	word ptr [bp-2],0
loc_98:
		mov	al,9
		mov	dx,3CEh
		out	dx,al			; port 3CEh, EGA graphic index
		inc	dx
		mov	al,0
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,0Fh
		mov	dx,3CEh
		out	dx,al			; port 3CEh, EGA graphic index
		inc	dx
		mov	al,0
		out	dx,al			; port 3CFh, EGA graphic func
		mov	ax,[bp-2]
		pop	di si es ds
		mov	sp,bp
		pop	bp
		retf	0Ch

Code_6:
		mov	ax,[si+8]
		sub	ax,[si+4]
		inc	ax
		mov	bx,[bp+0Ah]
		add	bx,ax
		cmp	bx,es:[di+18h]
		jbe	loc_99
		mov	ax,es:[di+18h]
		sub	ax,[bp+0Ah]
loc_99:
		dec	ax
		mov	[bp-10h],ax
		mov	ax,es:[di+18h]
		mov	[bp-16h],ax
		mov	bx,[bp+8]
		mul	bx
		mov	bx,[bp+0Ah]
		add	ax,bx
		adc	dx,0
		mov	[bp-1Eh],dl
		mov	dx,ax
		mov	ax,[si+0Ah]
		sub	ax,[si+6]
		inc	ax
		mov	[bp-12h],ax
		mov	bx,[bp+8]
		add	bx,ax
		cmp	bx,es:[di+1Ah]
		jbe	loc_100
		mov	ax,es:[di+1Ah]
		sub	ax,[bp+8]
		inc	ax
		mov	[bp-12h],ax
loc_100:
		mov	ax,es:[di+1Eh]
		mov	es,ax
		mov	di,dx
		push	ax
		mov	al,[bp-1Eh]
		mov	ah,al
		shl	ah,1
		shl	ah,1
		shl	ah,1
		or	al,ah
		or	al,40h			; '@'
		mov	dx,3CDh
		out	dx,al			; port 3CDh ??I/O Non-standard
		pop	ax
		mov	ax,[si+42h]
		mov	[bp-14h],ax
		sub	[bp-16h],ax
		xor	bx,bx
		add	si,80h ; offset data_9
		cld
loc_101:
		mov	cx,1
		lodsb
		mov	ah,al
		and	ah,0C0h
		cmp	ah,0C0h
		jne	locloop_102
		mov	cl,al
		sub	cl,0C0h
		lodsb

locloop_102:
		cmp	bx,[bp-10h]
		ja	loc_103
		mov	es:[di],al
loc_103:
		inc	di
		jnz	loc_104
		inc	byte ptr [bp-1Eh]
		push	ax
		mov	al,[bp-1Eh]
		mov	ah,al
		shl	ah,1
		shl	ah,1
		shl	ah,1
		or	al,ah
		or	al,40h			; '@'
		mov	dx,3CDh
		out	dx,al			; port 3CDh ??I/O Non-standard
		pop	ax
loc_104:
		inc	bx
		cmp	bx,[bp-14h]
		jne	loc_106
		xor	bx,bx
		add	di,[bp-16h]
		jnc	loc_105
		inc	byte ptr [bp-1Eh]
		push	ax
		mov	al,[bp-1Eh]
		mov	ah,al
		shl	ah,1
		shl	ah,1
		shl	ah,1
		or	al,ah
		or	al,40h			; '@'
		mov	dx,3CDh
		out	dx,al			; port 3CDh ??I/O Non-standard
		pop	ax
loc_105:
		dec	word ptr [bp-12h]
		jz	loc_108
loc_106:
		loop	locloop_102

		cmp	si,[bp-0Ah]
		jbe	loc_107
		push	si
		call	far ptr PcxBufferFill
		mov	si,ax
		jnc	loc_107
		mov	word ptr [bp-2],0FFFDh
		jmp	short loc_109
loc_107:
		jmp	short loc_101
loc_108:
		push	ax
		mov	al,0
		mov	ah,al
		shl	ah,1
		shl	ah,1
		shl	ah,1
		or	al,ah
		or	al,40h			; '@'
		mov	dx,3CDh
		out	dx,al			; port 3CDh ??I/O Non-standard
		pop	ax
		mov	word ptr [bp-2],0
loc_109:
		mov	ax,[bp-2]
		pop	di si es ds
		mov	sp,bp
		pop	bp
		retf	0Ch

Code_7:
		mov	ax,es:[di+18h]
		mov	[bp-16h],ax
		mov	ax,[si+8]
		sub	ax,[si+4]
		inc	ax
		mov	bx,[bp+0Ah]
		add	bx,ax
		cmp	bx,es:[di+18h]
		jbe	loc_110
		mov	ax,es:[di+18h]
		sub	ax,[bp+0Ah]
loc_110:
		dec	ax
		mov	[bp-10h],ax
		mov	ax,es:[di+18h]
		mov	[bp-16h],ax
		mov	bx,[bp+8]
		mul	bx
		mov	bx,[bp+0Ah]
		add	ax,bx
		adc	dx,0
		mov	[bp-1Eh],dl
		mov	dx,ax
		mov	ax,[si+0Ah]
		sub	ax,[si+6]
		inc	ax
		mov	[bp-12h],ax
		mov	bx,[bp+8]
		add	bx,ax
		cmp	bx,es:[di+1Ah]
		jbe	loc_111
		mov	ax,es:[di+1Ah]
		sub	ax,[bp+8]
		inc	ax
		mov	[bp-12h],ax
loc_111:
		mov	ax,es:[di+1Eh]
		mov	es,ax
		mov	di,dx
		mov	al,6
		mov	dx,3C4h
		out	dx,al			; port 3C4h, EGA sequencr index
		inc	dx
		mov	al,0EAh
		out	dx,al			; port 3C5h, EGA sequencr func
		push	ax bx
		mov	bh,[bp-1Eh]
		mov	bl,bh
		and	bl,1
		mov	al,0F9h
		mov	dx,3C4h
		out	dx,al			; port 3C4h, EGA sequencr index
		inc	dx
		mov	al,bl
		out	dx,al			; port 3C5h, EGA sequencr func
		mov	bl,bh
		and	bl,2
		shl	bl,1
		shl	bl,1
		shl	bl,1
		shl	bl,1
		mov	dx,3CCh
		in	al,dx			; port 3CCh, EGA graphics 1 pos
		and	al,0DFh
		or	bl,al
		mov	al,bl
		mov	dx,3C2h
		out	dx,al			; port 3C2h, EGA misl out reg
		mov	al,0F6h
		mov	dx,3C4h
		out	dx,al			; port 3C4h, EGA sequencr index
		inc	dx
		in	al,dx			; port 3C5h, EGA sequencr func
		mov	bl,bh
		shr	bl,1
		shr	bl,1
		add	bl,7
		not	bl
		and	bl,5
		and	al,0F0h
		or	al,bl
		out	dx,al			; port 3C5h, EGA sequencr func
		pop	bx ax
		mov	ax,[si+42h]
		mov	[bp-14h],ax
		sub	[bp-16h],ax
		xor	bx,bx
		add	si,80h ; offset data_9
		cld
loc_112:
		mov	cx,1
		lodsb
		mov	ah,al
		and	ah,0C0h
		cmp	ah,0C0h
		jne	loc_113
		mov	cl,al
		sub	cl,0C0h
		lodsb
loc_113:
		cmp	bx,[bp-10h]
		ja	loc_114
		mov	es:[di],al
loc_114:
		inc	di
		jnz	loc_115
		inc	byte ptr [bp-1Eh]
		push	ax bx
		mov	bh,[bp-1Eh]
		mov	bl,bh
		and	bl,1
		mov	al,0F9h
		mov	dx,3C4h
		out	dx,al			; port 3C4h, EGA sequencr index
		inc	dx
		mov	al,bl
		out	dx,al			; port 3C5h, EGA sequencr func
		mov	bl,bh
		and	bl,2
		shl	bl,1
		shl	bl,1
		shl	bl,1
		shl	bl,1
		mov	dx,3CCh
		in	al,dx			; port 3CCh, EGA graphics 1 pos
		and	al,0DFh
		or	bl,al
		mov	al,bl
		mov	dx,3C2h
		out	dx,al			; port 3C2h, EGA misl out reg
		mov	al,0F6h
		mov	dx,3C4h
		out	dx,al			; port 3C4h, EGA sequencr index
		inc	dx
		in	al,dx			; port 3C5h, EGA sequencr func
		mov	bl,bh
		shr	bl,1
		shr	bl,1
		add	bl,7
		not	bl
		and	bl,5
		and	al,0F0h
		or	al,bl
		out	dx,al			; port 3C5h, EGA sequencr func
		pop	bx ax
loc_115:
		inc	bx
		cmp	bx,[bp-14h]
		jne	loc_117
		xor	bx,bx
		add	di,[bp-16h]
		jnc	loc_116
		inc	byte ptr [bp-1Eh]
		push	ax bx
		mov	bh,[bp-1Eh]
		mov	bl,bh
		and	bl,1
		mov	al,0F9h
		mov	dx,3C4h
		out	dx,al			; port 3C4h, EGA sequencr index
		inc	dx
		mov	al,bl
		out	dx,al			; port 3C5h, EGA sequencr func
		mov	bl,bh
		and	bl,2
		shl	bl,1
		shl	bl,1
		shl	bl,1
		shl	bl,1
		mov	dx,3CCh
		in	al,dx			; port 3CCh, EGA graphics 1 pos
		and	al,0DFh
		or	bl,al
		mov	al,bl
		mov	dx,3C2h
		out	dx,al			; port 3C2h, EGA misl out reg
		mov	al,0F6h
		mov	dx,3C4h
		out	dx,al			; port 3C4h, EGA sequencr index
		inc	dx
		in	al,dx			; port 3C5h, EGA sequencr func
		mov	bl,bh
		shr	bl,1
		shr	bl,1
		add	bl,7
		not	bl
		and	bl,5
		and	al,0F0h
		or	al,bl
		out	dx,al			; port 3C5h, EGA sequencr func
		pop	bx ax
loc_116:
		dec	word ptr [bp-12h]
		jz	loc_120
loc_117:
		dec	cx
		jz	loc_118
		jmp	loc_113
loc_118:
		cmp	si,[bp-0Ah]
		jbe	loc_119
		push	si
		call	far ptr PcxBufferFill
		mov	si,ax
		jnc	loc_119
		mov	word ptr [bp-2],0FFFDh
		jmp	short loc_121
loc_119:
		jmp	loc_112
loc_120:
		push	ax bx
		mov	bh,0
		mov	bl,bh
		and	bl,1
		mov	al,0F9h
		mov	dx,3C4h
		out	dx,al			; port 3C4h, EGA sequencr index
		inc	dx
		mov	al,bl
		out	dx,al			; port 3C5h, EGA sequencr func
		mov	bl,bh
		and	bl,2
		shl	bl,1
		shl	bl,1
		shl	bl,1
		shl	bl,1
		mov	dx,3CCh
		in	al,dx			; port 3CCh, EGA graphics 1 pos
		and	al,0DFh
		or	bl,al
		mov	al,bl
		mov	dx,3C2h
		out	dx,al			; port 3C2h, EGA misl out reg
		mov	al,0F6h
		mov	dx,3C4h
		out	dx,al			; port 3C4h, EGA sequencr index
		inc	dx
		in	al,dx			; port 3C5h, EGA sequencr func
		mov	bl,bh
		shr	bl,1
		shr	bl,1
		add	bl,7
		not	bl
		and	bl,5
		and	al,0F0h
		or	al,bl
		out	dx,al			; port 3C5h, EGA sequencr func
		pop	bx ax
		mov	al,6
		mov	dx,3C4h
		out	dx,al			; port 3C4h, EGA sequencr index
		inc	dx
		mov	al,0AEh
		out	dx,al			; port 3C5h, EGA sequencr func
		mov	word ptr [bp-2],0
loc_121:
		mov	ax,[bp-2]
		pop	di si es ds
		mov	sp,bp
		pop	bp
		retf	0Ch




PcxFileDisplay		proc	near
		push	bp
		mov	bp,sp
		sub	sp,84h
		push	ds es si di
		mov	ax,@data
		mov	ds,ax
		push	ds
		cld
		mov	ax,[bp+0Eh]	; ds имени файла
		mov	ds,ax
		mov	ax,ss
		mov	es,ax	; es = ss
		mov	si,[bp+0Ch]	; offset filename
		mov	di,bp
		sub	di,84h
		mov	[bp+0Eh],es
		mov	[bp+0Ch],di
loc_168:
		movsb		; копиpуем имя в стек
		cmp	byte ptr [si-1],0
		jne	loc_168
		pop	ds
		push	ds
		mov	dx,[bp+0Ch]
		mov	ax,[bp+0Eh]
		mov	ds,ax
		mov	ax,3D00h
		_DOS		;	open file, al=mode,name@ds:dx
		pop	ds
		mov	PcxHandle,ax
		jnc	loc_169
		mov	word ptr [bp-2],0FFFFh
		jmp	short loc_173
loc_169:
		mov	ax,@data
		mov	es,ax
		mov	di,offset PcxFbuff
		cmp	PcxBufSeg,0FFFFh
		je	loc_170	; если был создан внешний буфеp
		mov	ax,PcxBufSeg	; то использовать его
		mov	es,ax
		mov	di,PcxBufOfs
loc_170:
		mov	PcxFile_h,0
		mov	PcxFile_l,0
		push	ds
		mov	bx,PcxHandle
		mov	cx,PcxBufMax
		mov	dx,di
		mov	ax,es
		mov	ds,ax
		mov	ah,3Fh
		_DOS		;	read file, bx=file handle
					;	cx=bytes to ds:dx buffer
		pop	ds
		jnc	loc_171
		mov	word ptr [bp-2],0FFFDh
		jmp	short loc_172
loc_171:
		mov	ax,es
		push	ax di	; location of buffer
		mov	ax,PcxBufMax
		sub	ax,0Ah
		push	ax	; size of buffer
		mov	ax,[bp+0Ah]
		push	ax
		mov	ax,[bp+8]
		push	ax
		mov	ax,[bp+6]
		push	ax
		call	far ptr PcxBufferDisplay
		mov	[bp-2],ax
loc_172:
		mov	bx,PcxHandle
		mov	ah,3Eh
		_DOS		;	close file, bx=file handle
loc_173:
		mov	PcxHandle,0FFFFh
		mov	ax,[bp-2]
		pop	di si es ds
		mov	sp,bp
		pop	bp
		retf	0Ah
PcxFileDisplay		endp






PcxBufferFill		proc	far
		push	bp
		mov	bp,sp
		sub	sp,2
		push	ds es si di
		mov	ax,@data
		mov	ds,ax
		push	bx cx dx
		cmp	PcxHandle,0FFFFh
		jne	loc_174
		stc
		jmp	short loc_177
loc_174:
		mov	ax,ds
		mov	es,ax
		mov	di,offset PcxFbuff
		cmp	PcxBufSeg,0FFFFh
		je	loc_175
		mov	ax,PcxBufSeg
		mov	es,ax
		mov	di,PcxBufOfs
loc_175:
		mov	ax,[bp+6]	; куда читать
		sub	ax,di
		add	PcxFile_l,ax
		jnc	loc_176
		add	PcxFile_h,1
loc_176:
		mov	bx,PcxHandle
		mov	cx,PcxFile_h
		mov	dx,PcxFile_l
		mov	ax,4200h	; сдвинемся к нужному месту файла
		_DOS		;	move file ptr, bx=file handle
					;	al=method, cx,dx=offset
		push	ds
		mov	bx,PcxHandle
		mov	cx,PcxBufMax
		mov	dx,di
		mov	ax,es
		mov	ds,ax
		mov	ah,3Fh
		_DOS
						;	read file, bx=file handle
						;	cx=bytes to ds:dx buffer
		pop	ds
		mov	[bp-2],di
loc_177:
		pop	dx cx bx
		mov	ax,[bp-2]
		pop	di si es ds
		mov	sp,bp
		pop	bp
		retf	2
PcxBufferFill		endp






PcxDecodePalette		proc	far
		push	bp
		mov	bp,sp
		push	ds es si di
		mov	ax,@data
		mov	ds,ax
		mov	ax,[bp+0Eh]
		call	PcxGetDispStruc
		cmp	ax,0
		jae	loc_178
		mov	ax,0FC19h
		jmp	loc_186
loc_178:
		mov	di,ax
		mov	ax,dx
		mov	es,ax
		mov	bx,es:[di+22h]
		mov	ax,[bp+0Ch]
		mov	ds,ax
		mov	si,[bp+0Ah]
		mov	ax,[bp+8]
		mov	es,ax
		mov	di,[bp+6]
		cmp	bx,1
		je	loc_179
		cmp	bx,2
		je	loc_180
		cmp	bx,3
		je	loc_181
		cmp	bx,4
		je	loc_183
		cmp	bx,5
		je	loc_185
		mov	ax,0FFF7h
		jmp	short loc_186
loc_179:
		mov	al,[si]
		mov	cl,4
		shr	al,cl
		mov	es:[di],al
		inc	di
		mov	al,[si+3]
		mov	cl,5
		shr	al,cl
		mov	es:[di],al
		jmp	short @@100
loc_180:
		mov	al,[si]
		mov	cl,4
		shr	al,cl
		mov	es:[di],al
		jmp	short @@100
loc_181:
		mov	cx,10h

locloop_182:
		lodsb
		and	al,48h
		mov	ah,al

		lodsb
		and	al,48h
		shr	al,1
		or	ah,al

		lodsb
		and	al,48h
		shr	al,1
		shr	al,1
		or	ah,al

		shr	ah,1
		mov	es:[di],ah
		inc	di
		loop	locloop_182

		mov	byte ptr es:[di],0
		jmp	short @@100
loc_185:
		mov	cx,300h
		jmp	short loc_184
loc_183:
		mov	cx,30h
loc_184:
		lodsb
		shr	al,1
		shr	al,1
		stosb
		loop	loc_184
@@100:
		xor	ax,ax
loc_186:
		pop	di si es ds
		pop	bp
		retf	0Ah
PcxDecodePalette endp




PcxSetDisplayPalette		proc	near
		push	bp
		mov	bp,sp
		sub	sp,2
		push	ds es si di
		call	PcxGetDisplay
		cmp	ax,0
		jge	@@1
		jmp	@@done
@@1:
		call	PcxGetDispStruc
		cmp	ax,0
		jae	loc_204
		mov	ax,0FC19h
		jmp	@@done
loc_204:
		mov	di,ax
		mov	es,dx
		mov	bx,es:[di+22h]
		mov	ax,[bp+8]
		mov	ds,ax
		mov	es,ax
		mov	si,[bp+6]
		cmp	bx,1
		je	loc_206
		cmp	bx,2
		je	loc_206
		cmp	bx,3
		je	loc_212
		cmp	bx,4
		je	loc_213
		cmp	bx,5
		je	loc_215
		mov	ax,0FFF7h
		jmp	@@done
loc_206:
		mov	dh,[si]
		mov	al,[si+1]
		cmp	al,4
		jl	loc_207
		sub	al,4
loc_207:
		cmp	al,0
		jne	loc_208
		mov	dl,0
		jmp	short loc_211
loc_208:
		cmp	al,1
		jne	loc_209
		mov	dl,0
		or	dh,10h
		jmp	short loc_211
loc_209:
		cmp	al,2
		jne	loc_210
		mov	dl,1
		jmp	short loc_211
loc_210:
		mov	dl,1
		or	dh,10h
loc_211:
		mov	bh,1
		mov	bl,dl
		mov	ah,0Bh
		__VID
						;	set color from bx (CGA modes)
		mov	bh,0
		mov	bl,dh
		mov	ah,0Bh	;	set color from bx (CGA modes)
		jmp	short @@_vid
						;* No entry
		mov	bl,[si]
		mov	bh,0
		mov	ah,0Bh	;	set color from bx (CGA modes)
		jmp	short @@_vid
loc_212:
		mov	dx,si
		mov	ax,1002h	;	set palette regs from es:dx
		jmp	short @@_vid
loc_213:
		mov	bx,15
		mov	di,si
		add	di,1Eh
loc_214:
		mov	dh,es:[bx+di]
		mov	ch,es:[bx+di+1]
		mov	cl,es:[bx+di+2]
		push	bx bp
		mov	ax,1007h
		_VID	;	get palette reg bl into bh

		mov	bl,bh
		xor	bh,bh
		mov	ax,1010h
		_VID	;	set color reg bx with colors
					;	dh=red, ch=green, cl=blue
		pop	bp bx
		dec	di
		dec	di
		dec	bx
		jns	loc_214
		jmp	short @@done_Ok
loc_215:
		mov	dx,si
		mov	cx,256
		mov	bx,0
		mov	ax,1012h
@@_vid:
		__VID		;	set cx color registers from
					;	ptr es:dx, bx=first reg
@@done_Ok:
		mov	ax,0
@@done:
		pop	di si es ds
		mov	sp,bp
		pop	bp
		retf	4
PcxSetDisplayPalette		endp





PcxGetFilePalette	proc far
nameDS equ [bp+0Ch]
		push	bp
		mov	bp,sp
		sub	sp,86h
		push	ds es si di
		mov	ax,@data
		mov	ds,ax
		push	ds
		cld
		mov	ax,nameDS
		mov	ds,ax
		mov	ax,ss
		mov	es,ax
		mov	si,[bp+0Ah]
		mov	di,bp
		sub	di,86h
		mov	nameDS,es
		mov	[bp+0Ah],di
loc_239:
		movsb
		cmp	byte ptr [si-1],0
		jne	loc_239
		pop	ds
		push	ds
		lds	dx,[bp+0Ah]
		mov	ax,3D00h
		_DOS
						;	open file, al=mode,name@ds:dx
		pop	ds
		mov	[bp-4],ax
		jnc	loc_240
		mov	word ptr [bp-2],0FFFFh
		jmp	loc_249
loc_240:
		mov	ax,[bp+0Eh]
		call	PcxGetDispStruc
		cmp	ax,0
		jae	loc_241
		mov	word ptr [bp-2],0FC19h
		jmp	loc_249
loc_241:
		mov	di,ax
		mov	ax,dx
		mov	es,ax
		mov	bx,es:[di+22h]
		cmp	bx,5
		je	loc_242
		jmp	loc_246
loc_242:
		mov	ax,@data
		mov	ds,ax
		mov	si,offset PcxFbuff
		mov	ax,[bp+8]
		mov	es,ax
		mov	di,[bp+6]
		push	ds
		mov	bx,[bp-4]
		mov	cx,0Ah
		mov	dx,si
		mov	ah,3Fh
		_DOS
						;	read file, bx=file handle
						;	cx=bytes to ds:dx buffer
		pop	ds
		cmp	byte ptr [si+1],5
		je	loc_243
		mov	word ptr [bp-2],0FFF6h
		jmp	loc_248
loc_243:
		mov	bx,[bp-4]
		sub	cx,cx
		sub	dx,dx
		mov	ax,4202h	; в конец файла
		_DOS

		push	dx ax
		mov	ax,4200h
		_DOS
						;	move file ptr, bx=file handle
						;	al=method, cx,dx=offset
		pop	ax dx
		mov	bx,[bp-4]
		mov	cx,dx
		mov	dx,ax
		mov	ax,4200h
		_DOS
						;	move file ptr, bx=file handle
						;	al=method, cx,dx=offset
		mov	bx,[bp-4]
		mov	cx,0FFFFh
		mov	dx,0FCFFh
		mov	ax,4201h
		_DOS
						;	move file ptr, bx=file handle
						;	al=method, cx,dx=offset
		push	ds
		mov	bx,[bp-4]
		mov	cx,1
		mov	dx,si
		mov	ax,ds
		mov	ds,ax
		mov	ah,3Fh
		_DOS
						;	read file, bx=file handle
						;	cx=bytes to ds:dx buffer
		pop	ds
		mov	bl,[si]
		mov	[bp-6],bx
		cmp	bl,0Ah
		je	loc_244
		cmp	bl,0Ch
		je	loc_244
		mov	word ptr [bp-2],0FFF7h
		jmp	loc_248
loc_244:
		push	ds
		mov	bx,[bp-4]
		mov	cx,300h
		mov	dx,di
		mov	ax,es
		mov	ds,ax
		mov	ah,3Fh
		_DOS
						;	read file, bx=file handle
						;	cx=bytes to ds:dx buffer
		pop	ds
		cmp	ax,300h
		je	loc_245
		mov	word ptr [bp-2],0FFFDh
		jmp	short loc_248
loc_245:
		mov	ax,es
		mov	ds,ax
		mov	si,di
		mov	bx,[bp-6]
		cmp	bl,0Ch
		je	loc_247
		mov	word ptr [bp-2],0
		jmp	short loc_248
loc_246:
		mov	ax,@data
		mov	ds,ax
		mov	si,offset PcxFbuff
		mov	ax,[bp+8]
		mov	es,ax
		mov	di,[bp+6]
		mov	bx,[bp-4]
		mov	cx,0
		mov	dx,10h
		mov	ax,4200h
		_DOS
						;	move file ptr, bx=file handle
						;	al=method, cx,dx=offset
		push	ds
		mov	bx,[bp-4]
		mov	cx,30h
		mov	dx,si
		mov	ah,3Fh
		_DOS			;	read file, bx=file handle
						;	cx=bytes to ds:dx buffer
		pop	ds
		cmp	ax,30h
		je	loc_247
		mov	word ptr [bp-2],0FFFDh
		jmp	short loc_248
loc_247:
		mov	ax,[bp+0Eh]
		push	ax ds si es di
		call	far ptr PcxDecodePalette
		mov	word ptr [bp-2],0
loc_248:
		mov	bx,[bp-4]
		mov	ah,3Eh
		_DOS
loc_249:
		mov	ax,[bp-2]
		pop	di si es ds
		mov	sp,bp
		pop	bp
		retf	0Ah
PcxGetFilePalette		endp


.data
paletteBuffer	db	22 dup (0)
		dw	0, 0
		db	88 dup (0)
data_9	db	687 dup (0)
                db      ' PCX Programmer', 27h, 's Toolkit '
                db      '3.53 '
copyright       db      'Copyright (c) Genus Microprogramming, Inc. 1988-89 All Right'
                db      's Reserved. Christopher A. Howard '
		db	0
PcxMode		dw	0FFFFh
PcxPage		dw	0FFFFh
PcxMcheck		dw	1
PcxHbuff		dw	1104 dup (0)
PcxFbuff equ PcxHbuff+96h
PcxBufMax	dw	800h
PcxBufSeg		dw	0FFFFh
PcxBufOfs		dw	0FFFFh
PcxHandle		dw	0FFFFh
PcxFile_h		dw	0
PcxFile_l		dw	0
PcxDinit		db	0
PcxBinit		db	0
PcxVinit		db	0
PcxPinit		db	0
PcxGinit		db	0

data_32         db      0, 'CGA 320x200x4'
		db	7 dup (20h)
		db	00h, 04h, 02h, 40h, 01h,0C8h
		db	00h, 01h, 01h, 00h,0B8h, 00h
		db	00h, 01h, 00h
		db	20 dup (0)

                db      1, 'CGA 640x200x2'
		db	7 dup (20h)
		db	00h, 06h, 01h, 80h, 02h,0C8h
		db	00h, 01h, 01h, 00h,0B8h, 00h
		db	00h, 02h, 00h
		db	20 dup (0)

                db      2, 'EGA 320x200x16      '
		db	00h, 0Dh, 01h, 40h, 01h,0C8h
		db	00h, 04h, 08h, 00h,0A0h, 00h
		db	20h, 03h, 00h
		db	20 dup (0)

                db      3, 'EGA 640x200x16      '
		db	00h, 0Eh, 01h, 80h, 02h,0C8h
		db	00h, 04h, 04h, 00h,0A0h, 00h
		db	40h, 03h, 00h
		db	20 dup (0)

                db      4, 'EGA 640x350x2       '
		db	00h, 0Fh, 01h, 80h, 02h, 5Eh
		db	01h, 01h, 02h, 00h,0A0h, 00h
		db	80h
		db	22 dup (0)

                db      5, 'EGA 640x350x16      '
		db	00h, 10h, 01h, 80h, 02h, 5Eh
		db	01h, 04h, 02h, 00h,0A0h, 00h
		db	80h, 03h, 00h
		db	20 dup (0)

                db       6, 'VGA 640x480x2'
		db	7 dup (20h)
		db	00h, 11h, 01h, 80h, 02h,0E0h
		db	01h, 01h, 01h, 00h,0A0h, 00h
		db	00h
		db	22 dup (0)

                db      7, 'VGA 640x480x16      '
		db	00h, 12h, 01h, 80h, 02h,0E0h
		db	01h, 04h, 01h, 00h,0A0h, 00h
		db	00h, 04h, 00h
		db	20 dup (0)

                db      8, 'VGA 320x200x256     '
		db	00h, 13h, 08h, 40h, 01h,0C8h
		db	00h, 01h, 01h, 00h,0A0h, 00h
		db	00h, 05h, 00h, 00h
		db	19 dup (0)

                db      9, 'Hercules 720x348x2  '
		db	00h, 00h, 01h,0D0h, 02h, 5Ch
		db	01h, 01h, 02h, 00h,0B0h, 00h
		db	80h
		db	22 dup (0)

                db      0Ah, 'Tseng 800x600x16    '
		db	00h, 29h, 01h, 20h, 03h, 58h
		db	02h, 04h, 01h, 00h,0A0h, 00h
		db	00h, 04h, 00h
		db	20 dup (0)

                db      0Bh, 'Tseng 640x350x256   '
		db	00h, 2Dh, 08h, 80h, 02h, 5Eh
		db	01h, 01h, 01h, 00h,0A0h, 00h
		db	00h, 05h, 00h, 00h
		db	19 dup (0)

                db      0Ch, 'Tseng 640x480x256   '
		db	00h, 2Eh, 08h, 80h, 02h,0E0h
		db	01h, 01h, 01h, 00h,0A0h, 00h
		db	00h, 05h, 00h, 00h
		db	19 dup (0)

                db      0Dh, 'Tseng 800x600x256   '
		db	00h, 30h, 08h, 20h, 03h, 58h
		db	02h, 01h, 01h, 00h,0A0h, 00h
		db	00h, 05h, 00h, 00h
		db	19 dup (0)

                db      0Eh, 'Paradise 800x600x16 '
		db	00h, 58h, 01h, 20h, 03h, 58h
		db	02h, 04h, 01h, 00h,0A0h, 00h
		db	00h, 04h, 00h
		db	20 dup (0)

                db      0Fh, 'Paradise 800x600x2  '
		db	00h, 59h, 01h, 20h, 03h, 58h
		db	02h, 01h, 01h, 00h,0A0h, 00h
		db	00h
		db	22 dup (0)

                db      10h, 'Paradise 640x400x256'
		db	00h, 5Eh, 08h, 80h, 02h, 90h
		db	01h, 01h, 01h, 00h,0A0h, 00h
		db	00h, 05h, 00h, 00h
		db	19 dup (0)

                db      11h, 'Paradise 640x480x256'
		db	00h, 5Fh, 08h, 80h, 02h,0E0h
		db	01h, 01h, 01h, 00h,0A0h, 00h
		db	00h, 05h, 00h, 00h
		db	19 dup (0)

                db      12h, 'Video7 800x600x16   '
		db	00h, 16h, 01h, 20h, 03h, 58h
		db	02h, 04h, 01h, 00h,0A0h, 00h
		db	00h, 04h, 00h
		db	20 dup (0)

                db      13h, 'Video7 640x400x256  '
		db	00h, 1Ah, 08h, 80h, 02h, 90h
		db	01h, 01h, 01h, 00h,0A0h, 00h
		db	00h, 05h, 00h, 00h
		db	19 dup (0)

                db      14h, 'Video7 640x480x256  '
		db	00h, 1Bh, 08h, 80h, 02h,0E0h
		db	01h, 01h, 01h, 00h,0A0h, 00h
		db	00h, 05h, 00h, 00h
		db	19 dup (0)

                db      15h, 'Video7 800x600x256  '
		db	00h, 1Dh, 08h, 20h, 03h, 58h
		db	02h, 01h, 01h, 00h,0A0h, 00h
		db	00h, 05h, 00h, 00h
		db	19 dup (0)

data_58	db	35h, 2Dh, 2Eh, 07h, 5Bh, 02h, 57h, 57h, 02h
		db	03h, 00h, 00h
		db	61h, 50h, 52h, 0Fh, 19h, 06h, 19h, 19h, 02h
		db	0Dh, 0Bh, 0Ch
		db	0
data_60		dw	0
data_61		dw	0
data_62		db	14h
		db	90h
		db	21 dup (0)


end

