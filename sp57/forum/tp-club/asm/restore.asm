seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	100h

init		proc	far

start:          mov     cx,     255
                mov     dx,     0
		mov 	ax,	0
                mov     es,     ax
                mov     bp,     0
                mov     bl,     0
                mov     bh,     8
                mov     al,     1
                mov     ah,     11H
                int     10H
		int 	20H
init 		endp	

seg_a		ends
		end	start
