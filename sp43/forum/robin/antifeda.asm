;	AntiFEDA
;	Вакцина от вирусочка FEDA
;	написана в режиме скорой помощи

        jumps
say     macro   str
        push    ax
        push    dx

        mov     ah,9
        mov     dx,offset str
        int     21h

        pop     dx
        pop     ax
        endm


cseg    segment 
        assume  CS:cseg,DS:cseg
        org     100h

start   proc	far
;───────────────Начало главной программы───────────────────────────────────────
	jmp	intr	; ПЕРЕХОД НА ИНСТАЛЛЯТОР
        db      'R&B soft, Kharkov ',0
;******* Начало резидентного участка ***********************	
r1:	jmp	enddata
	even
	OldVect	dd	? ; старый вектор - инициализируется при установке

enddata:	
        push    si
        push    bx
        push    DS

        push    CS
        pop     DS

        cmp     ax, 0FEDAh
        jne     exit

        mov     si, offset msg
a:
        mov     ah, 0Eh
        mov     al, byte ptr [si]
        cmp     al, 0
        je      cont1
        int     10h
        inc     si
        jmp     a

cont1:
        xor     ax,ax
        int     16h
        cmp     al,'Y'
        jmp     exit

        mov     ax, 0ADEFh


exit:
        pop     DS
        pop     bx
        pop     si
        jmp     dword ptr CS:[OldVect]  ; выход по старому вектору

msg     db      13,10,7,'В_Н_И_М_А_Н_И_Е_!  Было прерывание как у вируса FEDA!'
        db      13,10,'Продолжать работу без изменений (Y) или'
        db      13,10,'подсунуть вакцину, т.е. вирус размножаться не будет, любая другая клавиша? ',0

	re	db	0	; байт конца резидентного участка
;****** конец обработчика ******************************

        NumVect db      21h

intr:
;	Сюда лепить всякие проверки, обработку ком. строки etc.

	; инсталляция.
Instal:	
;---	сохранить старый вектор 
	mov	ah,35h	; function
	mov	al,NumVect; number
	int	21h
	mov	word ptr CS:[OldVect],bx ; offset
	mov	ax,ES
	mov	word ptr CS:[OldVect+2],ax ; segment

;---   установить новый вектоp пpеpывания 
	push	DS
	push	CS
	pop	DS
	mov	ah,25h	; номеp функции
	mov	al,NumVect	; номеp пpеpывания
	mov	dx,offset r1	; начало обработчика 
	int	21h
	pop	DS

;--- выйти и остаться резидентным
	say	copy	; сказать о инсталляции

ir:	mov     dx,offset re        ; exit
        int     27h


;	***** ДАННЫЕ ******

copy    db      13,10,'Вакцинка от вируса FEDA.'
        db      13,10,'Copyright (C) 1992 by Robin.  FREEWARE'
        db      13,10,'по просьбе MASLOV@VADIK.srcc.msu.su'
        db      13,10,'AntiFEDA installed.',13,10,'$'

;───────────────Конец главной программы────────────────────────────────────────
start   endp

cseg	ends
end	start
