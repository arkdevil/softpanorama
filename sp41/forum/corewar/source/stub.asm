.model compact
public _STUB
codeseg
	org 100h
PROC _STUB
	mov ah,09h
	mov dx,108h
	int 21h
	ret
db 'This program must be run under MARS supervisor only.',0Dh,0Ah,'$'
ENDP _STUB

end