	.model tiny
	.code

	xor ax,ax
	mov es,ax
	or  es:byte ptr[471h],80h
	mov ax,es:[41ah]
	mov es:[41ch],ax
	INT 1bh

	retf

	end
