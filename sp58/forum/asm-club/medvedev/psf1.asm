;------------------------------------------------------------------
; Автор: А.В.Медведев.
; 220090, Республика Беларусь, Минск, ул.Широкая, 36, к.716а
; т. 64-51-52 (раб.)
;
; Эта программа при нажатии [PrintScreen] записывает содержимое 
; экрана в файл с именем SCREEN.PRN в текущем каталоге. Если файл
; уже существует, то он дополняется, если нет, то файл создается.
; Программа предназначалась для "выдергивания" экранов из Tech Help!,
; поэтому она производит замену непечатаемых символов.
; Занимает в памяти 592 байта. Можно загружать в UMB.
;
; Для получения выполнимого файла:
;	TASM psf1
;	TLINK /x/t psf1
;------------------------------------------------------------------

.MODEL  TINY
.CODE
LOCALS
ORG     100h

Handle		equ	word ptr DS:[100h]
New_file	equ	byte ptr DS:[102h]

Start:
	jmp	Install

ActPage db 0
NumCol  db 0
Fname   db 'SCREEN.PRN',0

My_int_17:
	push	ax
	cmp	ax,1ae4h
	pop	ax
	jne	Old_17
	mov	ax,1225h
	iret
Old_17: db	0eah	;jmp far
ip_17	dw	0
cs_17	dw	0

My_int_5:
        sti
	push	ax
	push	bx
	mov	ah,0fh
	int	10h
	cmp	al,4
	jb	Text
	cmp	al,7
	je	Text
	pop	bx
	pop	ax
        db      0eah    ;jmp far
ip_5	dw	0
cs_5	dw	0

Text:   push    cx
        push    dx
        push    bp
        push    ds
        push    es
        push    di
	push	cs
	pop	ds
        mov     ActPage,bh  ;save active page
        mov     NumCol,ah   ;save number of columns
        mov     ah,3
        int     10h
        push    dx                 ;save cursor position
	mov	New_file,0
        mov     ax,3d01h
        lea     dx,Fname
File:   int     21h
	mov	Handle,ax	;Save file handle
        jnc     File_exist
	mov	New_file,1
        mov     ah,3ch
        xor     cx,cx
        jmp     File
File_Exist:
        cmp     New_file,1
        je      No_Error
        mov     ax,4202h
        mov     bx,Handle
        xor     cx,cx
        xor     dx,dx
        int     21h
No_Error:
	xor	di,di
        push    cs
        pop     es
        call    WriteEol
        mov     bh,ActPage
        xor     dx,dx
        mov     cx,25
Read_scr_col:
        push    cx
        mov     cl,NumCol
Read_scr_row:
        mov     ah,2            ;set cursor position
        int     10h
        mov     ah,8            ;read character at current cursor position
        int     10h
	cmp	al,127
	je	.4
	cmp	al,31
	ja	No_ctrl
	cmp	al,16
	jne	.1
	mov	al,'>'
	jmp	short No_ctrl
.1:	cmp	al,17
	jne	.2
	mov	al,'<'
	jmp	short No_ctrl
.2:	cmp	al,7
	jne	.3
	mov	al,'-'
	jmp	short No_Ctrl
.3:	cmp	al,30
	jne	.5
.4:	mov	al,'^'
	jmp	short No_Ctrl
.5:	mov	al,'+'
No_Ctrl:
        call    WriteChar
	inc	dl
        loop    Read_scr_row
        xor     dl,dl
        call    WriteEol
        inc     dh
        pop     cx
        loop    Read_scr_col
	call	Write
	mov	ah,3eh
	mov	bx,Handle
	int	21h
        pop     dx
        mov     ah,2
        int     10h
	pop	di
        pop     es
        pop     ds
        pop     bp
        pop     dx
        pop     cx
        pop     bx
        pop     ax
	iret

WriteChar proc near
        stosb
        cmp     di,256
        je      Write
        jmp     short E1
Write:  push    bx
        push    cx
        push    dx
        mov     ah,40h
        mov     bx,Handle
        mov     cx,di
        xor     dx,dx
        int     21h
        xor     di,di
        pop     dx
        pop     cx
        pop     bx
e1:     ret
WriteChar endp

WriteEol proc near
        mov     al,13
        call    WriteChar
        mov     al,10
        call    WriteChar
        ret
WriteEol endp

Install:
	mov	ax,1ae4h
	int	17h
	cmp	ax,1225h
	je	Already
	mov	ah,49h
	mov	ES,DS:[2Ch]
	int	21h
	xor	ax,ax
	mov	es,ax
	mov	ax,es:[17h*4]
	mov	ip_17,ax
	mov	ax,es:[17h*4+2]
	mov	cs_17,ax
	mov	es:[17h*4],offset My_int_17
	mov	es:[17h*4+2],cs
	mov	ax,es:[20]
	mov	ip_5,ax
	mov	ax,es:[22]
	mov	cs_5,ax
	mov	es:[20],offset My_int_5
	mov	es:[22],cs
	lea	dx,MsgI
	mov	ah,9
	int	21h
	add	dx,33
	int	21h
	lea	dx,Install
	int	27h
Already:
	mov	ah,9
	lea	dx,MsgI
	int	21h
        add     dx,25
	int	21h
	int	20h

MsgI	db 'Program "Screen to file"$'
	db ' already installed.',13,10
	db 'Copyright (c) 1989 by Andrey Vl. Medvedev.',13,10,'$'

END	Start
