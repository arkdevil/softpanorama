cod		segment
		assume	cs:cod, ds:cod

		org	100h

PRINTALT	proc	far
		jmp	beg
		
v17ofs		dw	?
v17seg		dw	?

;==========================================================================

int17		proc	far
		sti
		or	ah,ah
		jz	$20
$10:
		jmp	dword ptr cs:[v17ofs]
$20:
		cmp	al,80h
		jb	$10
		push	ds
		push	bx
		push	ax
		mov	ax,cs
		mov	ds,ax
		pop	ax
		sub	al,80h
		mov	bx,offset tabl
		xlat
		pop	bx
		pop	ds
		jmp	short $10
		
tabl:		db	0E1h, 0E2h, 0F7h, 0E7h, 0E4h, 0E5h
		db	0F6h, 0FAh, 0E9h, 0EAh, 0EBh, 0ECh
		db	0EDh, 0EEh, 0EFh, 0F0h, 0F2h, 0F3h
		db	0F4h, 0F5h, 0E6h, 0E8h, 0E3h, 0FEh
		db	0FBh, 0FDh, 27h, 0F9h, 0F8h, 0FCh
		db	0E0h, 0F1h, 0C1h, 0C2h, 0D7h, 0C7h
		db	0C4h, 0C5h, 0D6h, 0DAh, 0C9h, 0CAh
		db	0CBh, 0CCh, 0CDh, 0CEh, 0CFh, 0D0h
		db	0FFh
		db	'##|{{{..{|.""',27h,'.`^-}-+}}`,^-}=#^^'
		db	'=,"`,,H#',27h,','
		db	0FBh, 0DBh, 4Ch, 4Ah, 7Eh, 0D2h
		db	0D3h, 0D4h, 0D5h, 0C6h, 0C8h, 0C3h
		db	0DEh, 0DBh, 0DDh, 0DFh, 0D9h, 0D8h
		db	0DCh, 0C0h, 0D1h
		db	0e5h, 0c5h, ',\', 27h, '`><v^-+N$* '
int17		endp
;==========================================================================
beg:
		mov	ax,3517h
		int	21h
		
		mov	v17ofs,bx
		mov	v17seg,es
		mov	ax,2517h
		mov	dx,offset int17
		int	21h
		mov	dx,offset beg
		int	27h

PRINTALT	endp
cod		ends
		end	PRINTALT
