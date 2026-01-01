	IDEAL
	P286
	MODEL TINY

	SEGMENT Data AT 0
        LABEL  IntTable  DWORD
	ENDS
ASSUME DS:Data

CODESEG
ORG 100h

START:

	mov ax,2501h
	mov dx,offset TRAP
	int 21h

	pop ds

        push 303h
        popf
        call [IntTable+13h*4]
ABORT:
        int 20h

TRAP:
        push bp
        mov bp,sp
        cmp [byte bp+5h],0F0h
        jne EXIT_TRAP

	lds dx,[bp+02h]
	mov ax,2513h
	int 21h

        jmp ABORT

EXIT_TRAP:
        pop bp
        iret

END START