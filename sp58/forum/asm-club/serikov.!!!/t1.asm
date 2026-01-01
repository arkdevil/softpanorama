
x0		=	10
y0		=	20
x1		=	630
ega_y1		=	340
vga_y1		=	470

delay_time	=	28

code		segment byte public 'code'
		assume	ds: code
		org	100h

t1:
		mov	ax, 1c00h
		int	10h

		.IF	al != 1ch
			mov	ax, 0010h
		.ELSE
			mov	y1, vga_y1
			mov	ax, 0012h
		.ENDIF

		int	10h

		mov	dx, 3ceh
		mov	al, 05h
		out	dx, al
		inc	dx
		mov	al, 2
		out	dx, al

		mov	ax, 0a000h
		mov	es, ax

;───────────────────────────────────────────────────────────────────────────────
		xor	si, si
		mov	bp, 2

		.REPEAT
			mov	dx, 2

			.REPEAT
				mov	bl, h [si]
				mov	di, 8
				mov	cx, bp

				.REPEAT
					mov	al, 0
					shl	bl, 1
					rcl	al, 1
					shl	al, 1
					shl	al, 1
					call	point
					inc	cx
					dec	di
				.UNTIL	zero?

				inc	dx
				inc	si
			.UNTIL	! (si & 7)

			add	bp, 11
		.UNTIL	si >= e_h - h
;───────────────────────────────────────────────────────────────────────────────
		mov	ah, 0
		int	1ah
		mov	word ptr cf1, dx

main:
		mov	dx, y0
		mov	cx, x0

		.REPEAT
			push	cx
			.REPEAT
				push	dx
				.REPEAT
					push	cx
					.REPEAT
						call	dr_point
						add	cx, 8
					.UNTIL	cx > x1
					pop	cx
					add	dx, 8
				.UNTIL	dx > y1
				pop	dx
				inc	cx
			.UNTIL	cx == x0 + 8
			pop	cx
			inc	dx
		.UNTIL	dx == y0 + 8
;───────────────────────────────────────────────────────────────────────────────
		mov	al, cf1
		inc	al
		mov	cl, cf2
		dec	cl
		mul	cl
		xor	cl, ah
		mov	cf1, cl
		mov	cf2, al
;───────────────────────────────────────────────────────────────────────────────
		mov	ah, 0h
		int	1ah
		mov	bp, dx
		add	bp, delay_time

		.REPEAT
			mov	ah, 1
			int	16h
			jnz	get_k
			mov	ah, 0h
			int	1ah
		.UNTIL	dx == bp

		jmp	main


get_k:
		mov	ah, 0
		int	16h

		mov	ax, 0003h
		int	10h

		int	20h

;───────────────────────────────────────────────────────────────────────────────

dr_point:
		push	bx
		push	dx
		push	cx

		mov	ax, dx

		mov	cl, cf1
		and	cl, 0fh
		rol	ax, cl

		mul	ax

		mov	bx, ax

		pop	ax
		push	ax

		mov	cl, cf2
		and	cl, 0fh
		rol	ax, cl

		mul	ax

		add	ax, bx

		add	al, ah

		pop	cx
		pop	dx
		pop	bx


point:
		push	dx
		push	cx
		push	bx
		push	ax

		add	dx, dx
		add	dx, dx
		add	dx, dx
		add	dx, dx
		mov	ax, dx
		add	ax, ax
		add	ax, ax
		add	ax, dx

		mov	bx, cx
		and	cl, 07h
		shr	bx, 1
		shr	bx, 1
		shr	bx, 1
		add	bx, ax

		mov	dx, 3ceh
		mov	al, 08h
		out	dx, al
		inc	dx
		mov	al, 80h
		shr	al, cl
		out	dx, al

		pop	ax
		xchg	al, es: [bx]

		pop	bx
		pop	cx
		pop	dx
		ret
;───────────────────────────────────────────────────────────────────────────────
cf1		byte	0
cf2		byte	0
y1		word	ega_y1

h		byte	11111110b
		byte	11000011b
		byte	11000011b
		byte	11111110b
		byte	11111110b
		byte	11010011b
		byte	11000011b
		byte	11111110b

		byte	11111111b
		byte	11011011b
		byte	00011000b
		byte	00011000b
		byte	00011000b
		byte	00011000b
		byte	11011011b
		byte	11111111b

		byte	11111111b
		byte	11111111b
		byte	11000011b
		byte	11000000b
		byte	11000000b
		byte	11000011b
		byte	11111111b
		byte	11100011b

		byte	00000000b
		byte	00000000b
		byte	00000000b
		byte	00011000b
		byte	00000000b
		byte	00000000b
		byte	00000000b
		byte	00000000b

		byte	11111110b
		byte	11011101b
		byte	00011000b
		byte	00011000b
		byte	00011000b
		byte	00011000b
		byte	00011000b
		byte	00011000b

		byte	11000011b
		byte	11000011b
		byte	11000011b
		byte	11000011b
		byte	11000011b
		byte	11000011b
		byte	11111111b
		byte	01111110b

		byte	11111110b
		byte	11111111b
		byte	11000011b
		byte	11111110b
		byte	11111110b
		byte	11000011b
		byte	11000011b
		byte	11000011b

		byte	11111110b
		byte	11011011b
		byte	00011000b
		byte	00011000b
		byte	00011000b
		byte	00011000b
		byte	00011000b
		byte	00011000b

		byte	11000000b
		byte	11000000b
		byte	11000000b
		byte	11000000b
		byte	11000000b
		byte	11000000b
		byte	11111111b
		byte	11111111b

		byte	11111110b
		byte	11000011b
		byte	11000000b
		byte	11111110b
		byte	11111110b
		byte	11000000b
		byte	11000011b
		byte	11111110b

e_h		label	byte

code		ends
		end	t1
