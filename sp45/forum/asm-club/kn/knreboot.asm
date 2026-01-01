seg_a		segment	byte public
                assume  cs:seg_a,ds:seg_a
		org	100h
start:          jmp	dword ptr cs:data_1
data_1		dd	0FFFF0000h
seg_a		ends
		end	start
