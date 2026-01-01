	org	100h
	mov	ax,055h
	int	10h
	xor	al,al
	mov	es,ax
	mov	al,3
	mov	es:[449h],al
	int	20h
