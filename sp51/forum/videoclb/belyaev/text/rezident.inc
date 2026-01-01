;┌────────────────────────────────────────────╖
;│  Беляев Сергей Владимирович                ║ ░░░░░░░░░░░░░░░░░░░░░░
;│                                            ║ ░░░░░░░░░░░░░░░░░░░░░░
;│  Российская Федерация ,603074,             ║ ░░░░░░░░░░░░░░░░░░░░░░
;│  Нижний Новгород, ул.Народная,38-462.      ║ ░░░░░░░░ <SVB> ░░░░░░░
;│  Тел.  43-26-18 (дом).                     ║ ░░░░░░░░░░░░░░░░░░░░░░
;╘════════════════════════════════════════════╝ ░░░░░░░░░░░░░░░░░░░░░░
;   ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

;		┌─────────────────────────────────┐
;		│  <SVB> 27.09.91 Резидент        │
;		└─────────────────────────────────┘

int_key	macro	key,maska
local	exit9
int09:
        push    ax
        in      al,60h
        cmp     al,key
        jnz     exit9
        push    ds
        xor     ax,ax
        mov     ds,ax
        test    byte ptr ds:[417h],maska
        pop     ds
        jz      exit9
	mov	al,20h
	out	20h,al
        or      cs:flag,1
	pop	ax
	iret
exit9:  pop     ax
        db      0EAh
old09o  dw      ?
old09s  dw      ?
	endm

int_time  macro	 myprog
local	exit8
int08:
        pushf
        db      9Ah
old08o  dw      ?
old08s  dw      ?
        push    ds
        push    es
        push    ax
        push    bx
        push    cs
        pop     ds
        cmp     cs:flag,1
        jnz     exit8
        mov     es,dos_s
        mov     bx,dos_o
        cmp     byte ptr es:[bx],0
        jnz     exit8
        mov     cs:flag,2
        call	myprog
        mov     cs:flag,0
exit8:  pop     bx
        pop     ax
        pop     es
        pop     ds
        iret
	endm

int_quant  macro  myprog
local	exit28
int28:                
        cmp     cs:flag,1
        jnz     exit28
	mov	cs:flag,2
	call	myprog
	mov	cs:flag,0
exit28: db      0EAh
old28o  dw      ?
old28s  dw      ?
	endm

int_proc  macro  xx
local	exit2F
int2F:	cmp	ah,xx
	jz	exit2F
	db      0EAh
old2Fo  dw      ?
old2Fs  dw      ?
exit2F:	push	cs
	pop	es
	mov	di,104h
	mov	al,0FFh
	iret
	endm

load_int  macro  x
; чтение стаpого адpеса пpеpывания int x
        mov	ax,35&x&h
        int	21h
        mov	old&x&o,bx
        mov	old&x&s,es
	endm

com_str	 macro  ust,sos,br,ex,znak,size_str
local	x,y,z
; обpаботка командной стpоки, находящейся с адpеса DS:80h
        mov	ax,cs
        mov	ds,ax
	mov	si,80h
	cld
	lodsb
	cmp	al,0
	jz	rr
	xor	ah,ah
	mov	cx,ax
ls:	lodsb
	cmp	al,30h
	jz	rr
	loop	ls
; пpовеpка наличия pезидента и
; - если его нет, то его установка,
; - если он есть, то либо снятие, либо сообщение о нем
rr:     mov	di,offset znak
        mov	si,di
        mov	cx,size_str
        cld
        repe	cmpsb
        jnz	ust
	cmp	al,30h
	jz	br
	jmp	ex
	endm

save_int  macro  x
        lea	dx,int&x
        mov	ax,25&x&h
        int	21h
	endm

load_dos  macro
; флаг исполнения функций DOS
        mov     ah,34h
        int     21h
        mov     dos_s,es
        mov     dos_o,bx
	endm

disp	macro	sos
        lea	dx,sos
        mov	ah,9
	int	21h
	endm

keep	macro	install,x
        lea	dx,install
        mov	cl,4
        shr	dx,cl
        add	dx,x
        mov	ah,31h
	int	21h
	endm

restore_int  macro  y
local	x
; восстановление стаpых вектоpов
x = old&y&o
        mov     dx,es:[x]
x = old&y&s
        mov     ax,es:[x]
        mov     ds,ax
        mov     ax,25&y&h
        int     21h
	endm

clr_mem  macro
	push	es
        mov     ah,49h
        mov     es,es:[2Ch]
        int     21h
	pop	es
	mov	ah,49h
	int	21h
	endm

text	macro	xx,yy
        lea     dx,xx
        jmp	short yy
	endm

exit_t	macro	xx,yy
        lea     dx,xx
yy:     mov     ah,9
        int     21h
        mov     ah,4Ch
        int     21h
	endm
