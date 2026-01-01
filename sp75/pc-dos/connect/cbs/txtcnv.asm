; User prog for	CASIC
		model TINY
		JUMPS
cseg		SEGMENT	PARA PUBLIC 'CODE'
		ASSUME cs:cseg
		db 14,'Connect_User_1'
		jmp Start
ConvTable  db 00h,01h,02h,03h,04h,05h,06h,07h,08h,09h,20h,0bh,0ch,0dh,0eh,0fh
	   db 10h,11h,12h,13h,14h,15h,16h,17h,18h,19h,1ah,1bh,1ch,1dh,1eh,1fh
	   db 20h,21h,22h,23h,24h,25h,26h,27h,28h,29h,2Ah,2Bh,2Ch,2Dh,2Eh,2Fh
	   db 30h,31h,32h,33h,34h,35h,36h,37h,38h,39h,3Ah,3Bh,3Ch,3Dh,3Eh,3Fh
	   db 40h,41h,42h,43h,44h,45h,46h,47h,48h,49h,4Ah,4Bh,4Ch,4Dh,4Eh,4Fh
	   db 50h,51h,52h,53h,54h,55h,56h,57h,58h,59h,5Ah,5Bh,5Ch,5Dh,5Eh,5Fh
	   db 27h,41h,42h,43h,44h,45h,46h,47h,48h,49h,4Ah,4Bh,4Ch,4Dh,4Eh,4Fh
	   db 50h,51h,52h,53h,54h,55h,56h,57h,58h,59h,5Ah,28h,2Fh,29h,2Dh,2Ah
	   db 61h,62h,77h,67h,64h,65h,76h,7Ah,69h,6Ah,6Bh,6Ch,6Dh,6Eh,6Fh,70h
	   db 72h,73h,74h,75h,66h,68h,63h,7Eh,7Bh,7Dh,27h,79h,78h,7Ch,60h,71h
	   db 61h,62h,77h,67h,64h,65h,76h,7Ah,69h,6Ah,6Bh,6Ch,6Dh,6Eh,6Fh,70h
	   db 23h,23h,23h,23h,23h,23h,23h,23h,23h,23h,23h,23h,23h,23h,23h,23h
	   db 23h,23h,23h,23h,23h,23h,23h,23h,23h,23h,23h,23h,23h,23h,23h,23h
	   db 23h,23h,23h,23h,23h,23h,23h,23h,23h,23h,23h,23h,23h,23h,23h,23h
	   db 72h,73h,74h,75h,66h,68h,63h,7Eh,7Bh,7Dh,27h,79h,78h,7Ch,60h,71h
	   db 65h,65h,23h,23h,23h,23h,23h,23h,23h,23h,23h,23h,23h,23h,23h,23h
start:		push ds
		push es
		push di
		push si
		push bx
		push cx
		mov dx,di
		cld
		mov bx,offset ConvTable
L0:		lodsb
		cmp al,0ah
		je L1
		xlat ConvTable
		stosb
L1:		loop L0
		mov ax,di
		sub ax,dx
		xor dx,dx
		pop cx
		pop bx
		pop si
		pop di
		pop es
		pop ds
		retf
cseg		ENDS
		END


