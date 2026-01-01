;------------------------------------------------------------------
; Автор: А.В.Медведев.
; 220090, Республика Беларусь, Минск, ул.Широкая, 36, к.716а
; т. 64-51-52 (раб.)
;
; Программа для отображения текущего времени в правом верхнем углу
; экрана в текстовых режимах. Программа отслеживает изменение видео-
; режима и активной страницы. При переходе в графический режим вывод
; времени на экран прекращается, при восстановлении текстового -
; возобновляется. Счет времени не зависит от режима экрана.
; Занимает в памяти 432 байта. Можно загружать в UMB.
;
; Для получения выполнимого файла:
;	TASM showtime
;	TLINK /x/t showtime
;------------------------------------------------------------------

.MODEL TINY
.CODE
ORG    100h

COLOR	EQU	15		; цвет - ярко-белый на черном

Start:
	jmp	Install

_Save46C	db 0
_count_s	db 0
_count_m	db 5
_show		db 1

h2	db 0, 0
h1	db 0, 0
	db ':', COLOR
m2	db 0, 0
m1	db 0, 0
	db ':', COLOR
s2	db 0, 0
s1	db 0, 0

delta	EQU	(offset _save46C - 5Ch)
Save46C	EQU	byte ptr DS:[_save46C - delta]
count_s	EQU	byte ptr DS:[_count_s - delta]
count_m	EQU	byte ptr DS:[_count_m - delta]
show	EQU	byte ptr DS:[_show - delta]
HOUR2	EQU	byte ptr DS:[h2 - delta]
HOUR1	EQU	byte ptr DS:[h1 - delta]
MIN1	EQU	byte ptr DS:[m1 - delta]
MIN2	EQU	byte ptr DS:[m2 - delta]
SEC1	EQU	byte ptr DS:[s1 - delta]
SEC2	EQU	byte ptr DS:[s2 - delta]

; Обработчик int 10h (отслеживает изменения режима экрана) ------

int10:
	cmp	ax,0AFE7h	; функция проверки наличия программы в памяти
	jne	@@no_test
	mov	ax,64D9h	; ответ
	iret
@@no_test:
	or	ah,ah		; функция изменения режима ?
	je	@@mode_page
	cmp	ah,5		; функция изменения страницы ?
	je	@@mode_page
	db	0EAh		; JMP	far old_int10
ip_10	dw	0
CS_10	dw	0

@@mode_page:	; ----- отслеживание изменений видеорежима и страницы

	pushf			; выполняем функцию
	call	dword ptr CS:[ip_10-delta]
	push	ax
	push	bx
	mov	ah,0Fh		; проверяем текущий режим экрана
	int	10h
	cmp	al,3
	jbe	@@enable
	cmp	al,7
	je	@@enable
	xor	ax,ax		; запретить показ времени (графический режим)
	jmp	short @@set_flag
@@enable:
	mov	bx,72*2		; смещение в буфере для 80-колоночного режима
	cmp	al,2
	jae	@@80
	mov	bx,32*2		; -- для 40-колоночного режима
@@80:
	push	DS
	xor	ax,ax
	mov	DS,ax
	add	bx,DS:[44Eh]	; прибавить смещение начала видимой страницы
	mov	CS:[vid_off-delta-2],bx
	inc	ax
	pop	DS
@@set_flag:
	mov	CS:show,al
	pop	bx
	pop	ax
	iret

; Обработчик int 8 (показ текущего времени) ---------------------

timer:
	push	ax
	push	DS
	pushf
        db      9Ah             ;call far
ip_8    dw	0
CS_8    dw	0
        xor     ax,ax
        mov     DS,ax
        mov     al,DS:[046CH]
        cmp     al,CS:save46C
	jne	@@1
@@quit:
	pop	DS
	pop	ax
	iret
@@1:
	mov	ax,CS
	mov	DS,ax
	mov     save46C,al
   ;
   ;	  if (++count_s	!= 18) return;
   ;
        mov     al,count_s
        inc     ax
        mov     count_s,al
	cmp	al,18
        jne     @@quit
   ;
   ;	  sec1++; count_s=0;
   ;
        inc     SEC1
        mov     COUNT_S,0
   ;
   ;	  if (--count_m	== 0) {	count_m=5; count_s=255;	}
   ;
        dec     COUNT_M
        jne     @@314
        mov     COUNT_M,5
        mov     COUNT_S,-1
@@314:
   ;
   ;	  if (sec1 == 58) { sec2++; sec1='0';
   ;
        cmp     SEC1,'9'+1
        jne     @@458
        inc     SEC2
        mov     SEC1,'0'
   ;
   ;	    if (sec2 ==	54) { min1++; sec2='0';
   ;
        cmp     SEC2,'6'
        jne     @@458
        inc     MIN1
        mov     SEC2,'0'
   ;
   ;	      if (min1 == 58) {	min2++;	min1='0';
   ;
        cmp     MIN1,'9'+1
        jne     @@458
        inc     MIN2
        mov     MIN1,'0'
   ;
   ;		if (min2 == 54)	{ hour1++; min2='0';
   ;
        cmp     MIN2,'6'
        jne     @@458
        inc     HOUR1
        mov     MIN2,'0'
   ;
   ;		  if (hour1 == 58) { hour2++; hour1='0'; }
   ;
        cmp     HOUR1,'9'+1
        jne     @@458
        inc     HOUR2
        mov     HOUR1,'0'
@@458:
	cmp	show,0
	jne	@@display
	pop	DS		; выход, если отображение на экране запрещено
	pop	ax
	iret

@@display:
        push    cx
	push	si
	push	di
	push	es
	cld
        mov     ax,0B800H

vid_seg	LABEL	BYTE

        mov     ES,ax
        mov     di,72*2

vid_off	LABEL	WORD

        mov     si,offset HOUR2
        mov     cx,8
        rep     movsw
	pop	es
	pop	di
	pop	si
        pop     cx
	pop	ds
	pop	ax
	iret

; Инициализационная часть ---------------------------

SPLIT2	proc	near
        xor     ah,ah
        div     bl
        add     ax,03030H
        mov     bh,ah
        mov     ah,COLOR
        stosw
        mov     al,bh
        stosw
        inc     di
        inc     di
        ret
SPLIT2	endp

Install:
	mov	ah,9
	mov	dx,offset Copyr
	int	21h

	mov	ax,0AFE7h	; проверить наличие в памяти
	int	10h
	cmp	ax,64D9h	; сравнить с ответом
	jne	@@set

	mov	ah,9		; программа уже установлена
	mov	dx,offset msg
	int	21h
	int	20h

@@set:
	mov	ah,0Fh
	int	10h
	cmp	al,7
	jne	@@no_mono
	mov	[vid_seg-1], 0B0h
	jmp	short @@cont
@@no_mono:
	cmp	al,3
	jbe	@@cont
	mov	ax,3		; экран в графическом режиме,
	int	10h		;  установить текстовый

@@cont:				; переместить резидентную часть кода
	mov	si,offset _save46C
	mov	di,5Ch
	mov	cx,(offset split2 - offset _save46C + 1) / 2
	cld
	rep movsw

        mov     ah,2Ch		; получить текущее время
        int     21h
        mov     bl,10
        mov     di,offset HOUR2
        mov     al,ch           ; часы
        call    SPLIT2
        mov     al,cl           ; минуты
        call    SPLIT2
        mov     al,dh           ; секунды
        call    SPLIT2

	mov	ah,49h		; освободить копию окружения ДОС
	mov	ES,DS:[2Ch]
	int	21h

        xor     ax,ax
        mov     DS,ax
	mov	al,DS:[46Ch]
	mov	CS:Save46C,al
        mov     ax,DS:[4*8]
        mov     CS:[ip_8-delta],ax
        mov     ax,DS:[4*8+2]
        mov     CS:[CS_8-delta],ax
        mov     ax,DS:[4*10h]
        mov     CS:[ip_10-delta],ax
        mov     ax,DS:[4*10h+2]
        mov     CS:[CS_10-delta],ax

        cli
        mov     word ptr DS:[32],offset timer - delta
        mov     DS:[34],CS
        mov     word ptr DS:[4*10h],offset int10 - delta
        mov     DS:[4*10h+2],CS
        sti
        mov     dx,offset SPLIT2 - delta
        int     27h

Copyr	db 13,10,'ShowTime - отображение текущего времени.',13,10
	db 'Copyright (C) 1991 Андрей Вл. Медведев',13,10,'$'
msg	db 'Программа уже загружена', 13,10,'$'

END START
