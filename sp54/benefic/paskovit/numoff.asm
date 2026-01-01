name    NUMOFF
		.radix	16

codseg		segment
		assume	cs:codseg, ds:codseg, ss:codseg

		org	100
start:
		xor	ax,ax
		mov	es,ax
		and	byte ptr es:[417],0df
		push	es:[417]
		mov	al,0edh
		out	60,al		; ф-ия 0ed AT-клавиатуры -
		mov	cx,2000		; установка режимов
delay:		loop	delay		; задержка ~ 10 мс
		pop	ax
		mov	cl,4
		shr	al,cl
		and	al,5  		; погасить <NumLock>
		out	60,al
		mov	ax,4c00
		int	21		; EXIT

codseg		ends

		end	start
