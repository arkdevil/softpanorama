seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a
		org	100h
start:          mov     ax,1003h
                mov     bl,01h
                int     10h
		retn
seg_a           ends
                end start
