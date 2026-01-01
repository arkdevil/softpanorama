	.model tiny
	.code

	xor	ax,ax
	mov	ds,ax
	mov	word ptr ds:[472h],1234h
	db	0eah, 0f0h, 0ffh, 0, 0f0h ; jmp far 0f000h:0fff0h

	retf

	end
