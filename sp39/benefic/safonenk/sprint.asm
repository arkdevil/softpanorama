;==========================================================
; Утилита для изменения скорости компьютера посредством
; изменения скорости обновления памяти.
;
; Принципиально она ничем не отличается от одноименной
; утилиты Волынского, публиковавшейся в одной из Софтпанорам, 
; но имеет ряд преимуществ:
;	- возможность изменения скорости во время
;	  выполнения любой другой программы ( при условии,
;	  что она полностью не заменила int 9).
;	- является драйвером, поэтому практически не
;	  конфликтует с программами. Для этого вставьте
;	  в файл CONFIG.SYS следующую строку:
;	  DEVICE=SPRINT.SYS
;	  Лучше ее ПОСТАВИТЬ НА ПЕРВОЕ МЕСТО, чтобы
;	  SPRINT был первой программой, захватившей
;	  13 прерывание. В этом случае возможность
;	  конфликта с другими программами минимальна.
;
; Приблизительные пределы изменения скорости в % по
; отношению к нормальной:
; High: 105%
; Low:   57%
;
; Размер 436 байт
; Объем занимаемой памяти 0.21K
;
; Транслирование:
;	TASM/m/z sprint
;	TLINK/x sprint
;	EXE2BIN sprint sprint.sys
;==========================================================


	.model tiny
	.code
	org	0

beg:	; device driver header
	dw	-1,-1
	dw	8013h
	dw	offset strategy
	dw	offset interrupt
	db	'SPRINT'

;--------------------------------------

iodat	STRUC
cmdlen	db	?
unit	db	?
cmd	db	?
status	dw	?
	db	8 dup (?)
media	db	?
trans	dd	?
count	dw	?
start	dw	?
iodat	ENDS

iodat2	STRUC
	db	14 dup (?)
brkoff	dw	?
brkseg	dw	?
iodat2	ENDS

;-------------------------------

request_header	LABEL	DWORD
req_offs	dw	0
req_seg		dw	0

int13_process	db	0

;--------------------------------------

strategy:
	mov	cs:req_offs,bx
	mov	cs:req_seg,es
	retf

;--------------------------------------

interrupt:

	push	si
	push	ax
	push	cx
	push	dx
	push	di
	push	bp
	push	ds
	push	es
	push	bx
	;
	lds	bx,cs:request_header
	mov	al,[bx.cmd]
	or	al,al
	jnz	exit0

	call	install

	; reserve memory
	mov	ax,offset resident_end
	mov	cl,4
	shr	ax,cl
	inc	ax
	mov	cx,cs
	add	ax,cx
	lds	bx,cs:request_header
	mov	[bx.brkoff],0
	mov	[bx.brkseg],ax

exit0:	mov	ax,1
	clc
	jmp	short	exit1

bad_cmd:
	mov	ax,8103h	
	stc

exit1:	mov	[bx.status],ax
	;
	pop	bx
	pop	es
	pop	ds
	pop	bp
	pop	di
	pop	dx
	pop	cx
	pop	ax
	pop	si
	retf

;-------------------------------

newint9:
	push	ax
	pushf
	push	ds
	xor	ax,ax
	mov	ds,ax
	mov	ah,ds:[417h]
	and	ah,100b
	pop	ds
	in	al,60h
	or	ah,ah	;Ctrl
	jz	call9
	mov	ah,12h
	cmp	al,76
	je	ni9	;[5]
	mov	ah,0FFh
	cmp	al,72	;up
	je	ni9
	mov	ah,2h
	cmp	al,80	;down
	je	ni9

call9:	; calling original handler
	db	9Ah
orig9	dw	0,0
	pop	ax
	iret

ni9:	mov	byte ptr cs:[offset lab1+1],ah
	cmp	cs:int13_process,0
	jne	call9
        mov     al,ah
        out     41h,al
	jmp	short	call9

;-------------------------------

newint13:
        pushf
        cmp     ax,7777h
        jne     not_me
        popf
        mov     dx,ax
        iret
not_me: push    ax
        mov     al,12h
        out     41h,al
        pop     ax
        mov	cs:int13_process,-1

	; calling original handler
        db      9Ah
orig13  dw      0,0

        push    ax
lab1:   mov     al,0FFh
        out     41h,al
        pop     ax
        mov	cs:int13_process,0
        retf    2

;--------------------------------

resident_end:

mess	db	'Speed utility. (By changing memory refresh cycles)',13,10
	db	'Written by Alexander Safonenkov.',13,10
	db	'   Ctrl-[8]   High speed',13,10
	db	'   Ctrl-[5]   Normal speed',13,10
	db	'   Ctrl-[2]   Low speed.',13,10,'$' 

;--------------------------------

install	PROC

	push	cs
	pop	ds
	mov	dx,offset mess
	mov	ah,9
	int	21h
        mov     ax,3513h
        int     21h
        mov     orig13[0],bx
        mov     orig13[2],es
        mov     ax,2513h
        mov     dx,offset newint13
        int     21h
        mov     ax,3509h
        int     21h
        mov     orig9[0],bx
        mov     orig9[2],es
        mov     ax,2509h
        mov     dx,offset newint9
        int     21h
	mov     al,0FFh
        out     41h,al
	ret

install	ENDP

;--------------------------------

	end	beg
