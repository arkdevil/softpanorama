;------------------------------------------------------------------
;
;     Enchanced Russian Driver for enhanced keyboard & EGA
;  (C) 1990 by Sia.  Thanks to Kozlov A.V. (PC World USSR, 2'88)
;         Свиридов И.А. , г.Киев, (044)-263-87-70
;
;                  v. 1.6         23.02.90
;------------------------------------------------------------------

code    segment	word

        assume  cs:code

        org     0100h

;------------------------------------------------------------------

Border  equ     1
Func    equ     'KE'
F_ret   equ     'Ok'
Delay	equ	035h

pushrs  macro
        push    ax
        push    bx
        push    cx
        push    dx
        push    es
        push    bp
endm

poprs   macro
        pop     bp
        pop     es
        pop     dx
        pop     cx
        pop     bx
        pop     ax
endm


;---------------------------------

Start:
        jmp     Install

;------------------------------------------------------------------
;
;       Keyboard int's 9 & 16 handlers & data
;
;------------------------------------------------------------------

Ext             db      0
Pressed         db      0
Cyrillic        db      0

Ordtbl          label   byte
        db      32 ,'!','Э','#','$',':','.','э','?','%'
        db      ';','+','б','-','ю','/','0','1','2','3'
        db      '4','5','6','7','8','9','Ж','ж','Б','='
        db      'Ю','?','"','Ф','И','С','В','У','А','П'
        db      'Р','Ш','О','Л','Д','Ь','Т','Щ','З','Й'
        db      'К','Ы','Е','Г','М','Ц','Ч','Н','Я','х'
        db      '\','ъ',',','_',')','ф','и','с','в','у'
        db      'а','п','р','ш','о','л','д','ь','т','щ'
        db      'з','й','к','ы','е','г','м','ц','ч','н'
        db      'я','Х','|','Ъ','(',127

Cpstbl          label   byte
        db      32 ,'!','э','#','$',':','.','Э','?','%'
        db      ';','+','Б','-','Ю','/','0','1','2','3'
        db      '4','5','6','7','8','9','ж','Ж','б','='
        db      'ю','?','"','Ф','И','С','В','У','А','П'
        db      'Р','Ш','О','Л','Д','Ь','Т','Щ','З','Й'
        db      'К','Ы','Е','Г','М','Ц','Ч','Н','Я','Х'
        db      '\','Ъ',',','_',')','ф','и','с','в','у'
        db      'а','п','р','ш','о','л','д','ь','т','щ'
        db      'з','й','к','ы','е','г','м','ц','ч','н'
        db      'я','х','|','ъ','(',127

;----------------------------------------

Int09:
        cli
        pushf
        push    ax
        in      al,060h
        cmp     al,0e0h                 ; Ext. Keyboard prefix
        jne     Cont

        mov     cs:Ext,1
        jmp     Bye

Cont:
        cmp     cs:Ext,1
        jne     Clear

        cmp     al,09dh                 ; Right Control released
        jz      Break
        cmp     al,01dh                 ; Right Control Pressed
        jne     Clear

Make:
        mov     cs:Pressed,1
        jmp     Cl_ext

Break:
        cmp     cs:Pressed,1
        jne     Cl_ext

        xor     cs:Cyrillic,Border

Use_border:
        mov     ax,1001h
        push    bx
        mov     bh,cs:Cyrillic
        int     010h
        pop     bx

Clear:
        mov     cs:Pressed,0

Cl_ext:
        mov     cs:Ext,0

Bye:
        pop     ax
        popf
        jmp     dword ptr cs:[old9]


old9    label   dword
old9o   dw      0
old9s   dw      0

;-------------------------------------

Int16:
        cmp     ax,Func
        jnz     Co_1
        mov     ax,F_ret
        iret

Co_1:
        or      ah,ah
        jz      func0
	cmp	ah,010h
	jz	func0

        cmp     ah,01
        jz      func1
	cmp	ah,011h
	jz	func1

        db      0eah

old16   label   dword
old16o  dw      0
old16s  dw      0


func0:
        pushf
        call    cs:[old16]
        cmp     cs:Cyrillic,0
        jz      bye16
        call    translate

bye16:  iret

func1:
        pushf
        call    cs:[old16]
        pushf
        cmp     cs:Cyrillic,0
        jz      by116
        call    translate

by116:
        popf
        retf    2

;-------------------------------------

translate       proc    near
        push    bx
        push    ds
        xor     bx,bx
        mov     ds,bx
        mov     bx,0417h
        test    byte ptr [bx],040h
        jnz     capslock
        lea     bx,Ordtbl
        jmp     dotrans

capslock:
        lea     bx,Cpstbl
dotrans:
        or      ah,ah
        jz      notrans
        cmp     ah,035h
        ja      notrans
        cmp     al,127
        ja      notrans
        cmp     al,' '
        jbe     notrans
        add     bl,al
        adc     bh,0
        sub     bx,32
        mov     al,cs:[bx]
        xor     ah,ah
notrans:
        pop     ds
        pop     bx
        ret
translate       endp

;------------------------------------------------------------------
;
;       Video int 10 handler & data
;
;------------------------------------------------------------------

mode    db      0

myint10:
        or      ah,ah
        JZ      change_mode
        cmp     ah,011h
        JZ      chargen

jmprom:         db      0eah
old10   label   dword
old10o          dw      0
old10s          dw      0

change_mode:
        mov     byte ptr cs:mode,al
        and     al,7fh

        cmp     al,3
        jbe     sett8x14

        cmp     al,7
        jz      sett8x14
        cmp     al,0eh
        jbe     setg8x8
        cmp     al,10h
        jbe     setg8x14
        mov     al,cs:mode

        jmp     jmprom

chargen:
        cmp     al,30h
        jz      info
        cmp     al,02
        jnz     rr
        jmp     seta8x8

rr:     cmp     al,23h
        jz      nextchck
        cmp     al,12h
        jnz     jmprom
        jmp     sett8x8

nextchck:
        cmp     bl,3
        jnz     jmprom
        jmp     seta8x8

info:
        cmp     bh,2
        je      give8x14
        cmp     bh,3
        je      give8x8
        cmp     bh,4
        je      give8x8top
        jmp     jmprom

sett8x14:

        mov     al,cs:mode
        pushf
        call    cs:[old10]
        pushrs
        mov     ax,1100h
        push    cs
        pop     es
        mov     bp,offset cs:font8x14
        mov     cx,256
        mov     dx,0
        mov     bx,0e00h
        pushf
        call    cs:[old10]
        poprs
        iret

setg8x14:
        jmp     short mysetg
setg8x8:
        jmp     short mysetg8

give8x14:
        pushf
        call    cs:[old10]
        push    cs
        pop     es
        mov     bp,offset cs:font8x14
        iret

give8x8:
        pushf
        call    cs:[old10]
        push    cs
        pop     es
        mov     bp,offset cs:font8x8
        iret

give8x8top:
        pushf
        call    cs:[old10]
        push    cs
        pop     es
        mov     bp,offset cs:font8x8
        add     bp,128*8
        iret

mysetg:
        mov     al,cs:mode
        pushf
        call    cs:[old10]
        pushrs
        mov     ax,1121h
        push    cs
        pop     es
        mov     bp,offset cs:font8x14
        mov     cx,14
        mov     bl,25
        pushf
        call    cs:[old10]
        poprs
        iret

mysetg8:
        mov     al,cs:mode
        pushf
        call    cs:[old10]
        pushrs
        mov     ax,1121h
        push    cs
        pop     es
        mov     bp,offset cs:font8x8
        mov     cx,8
        mov     bl,25
        pushf
        call    cs:[old10]
        poprs
        iret

seta8x8:
        pushrs
        mov     ax,1121h
        push    cs
        pop     es
        mov     bp,offset cs:font8x8
        mov     cx,8
        mov     bx,3
        pushf
        call    cs:[old10]
        poprs
        iret

sett8x8:
        pushrs
        mov     ax,1110h
        push    cs
        pop     es
        mov     bp,offset cs:font8x8
        mov     cx,100h
        mov     bx,800h
        mov     dx,0
        pushf
        call    cs:[old10]
        poprs
        iret
;------------------------------------------------------------------
;
;       Fonts - 8x8 & 8x14


font8x8         label   byte

        INCLUDE         0808.asm

font8x14        label   byte

        INCLUDE         0814.asm

;------------------------------------------------------------------


Install:
	mov	si,080h
	mov	cl,byte ptr ds:[si]
	xor	ch,ch
	or	cx,cx
	jz	Nocomline

	inc	si

Next:
	lodsb
	cmp	al,'/'
	jz	key		
	loop	Next
	jmp	Nocomline
key:
	lodsb
	dec	cx
	cmp	al,'N'
	jz	Nomess
	cmp	al,'n'
	jz	Nomess

;	cmp	al,'S'
;	jz	Scroll
;	cmp	al,'s'
;	jz	Scroll

	mov	si,offset ok_mess
	call	puts
	mov	si,offset help_mess
	jmp	Exit

Nomess:
	mov	byte ptr cs:@nomess,1
	jmp	Next

;Scroll:
;	mov	byte ptr cs:@scroll,1
;	jmp	Next

Nocomline:
	mov	ax,3300h
	int	021h
	mov	word ptr cs:saveb,dx
	mov	dl,0
	mov	ax,3301h
	int	021h 

        mov     ax,Func
        int     016h
        cmp     ax,F_ret
        jnz     Try
	jmp	already

Try:
        cli
        mov     al,0eeh
        out     060h,al
        mov     cx,1000h
Check:
        in      al,060h
        cmp     al,0eeh
        jz      Ok_keyb
        loop    Check

        sti
        mov     si,offset not_keyb
        jmp     Exit

Ok_keyb:
        sti
        xor     ax,ax
        mov     es,ax
        mov     ah,byte ptr es:[487]
        push    cs
        pop     es
        and     ah,1000b
        jz      Ok_ega

        mov     si,offset not_ega
        jmp     Exit

Ok_ega:
        mov     ax,3509h
        int     021h

        mov     old9o,bx
        mov     old9s,es

        mov     ax,3516h
        int     021h

        mov     old16o,bx
        mov     old16s,es

        mov     ax,3510h
        int     21h

        mov     cs:old10o,bx
        mov     cs:old10s,es

        cli
        mov     dx,offset Int09
        mov     ax,2509h
        int     021h

        mov     dx,offset Int16
        mov     ax,2516h
        int     021h

        mov     dx,offset myint10
        mov     ax,2510h
        int     021h

        mov     dx,offset font8x14
        mov     ax,2544h
        int     021h

        mov     dx,offset font8x8
        add     dx,128*8
        mov     ax,251fh
        int     21h

	mov	dx,offset Int23
	mov	ax,2523h
	int	021h

        sti

        mov     ax,03
        int     10h

	mov	al,byte ptr cs:@nomess
	or	al,al
	jnz	Co_5
	mov	si,offset ok_mess
	call	puts

Co_5:
	xor	ax,ax
	mov	es,ax
	and	byte ptr es:[0471h],07fh		; Clear Break
	push	cs
	pop	es

	cli
	mov	dx,word ptr cs:saveb
	mov	ax,3301h
	int	021h 
	
	cli
        mov     dx,(Install-Start)/010h+011h
        mov     ax,3100h
        int     021h

already:
	mov	si,offset loaded

Exit:
	call	puts

	mov	dx,word ptr cs:saveb
	mov	ax,3301h
	int	021h 

        mov     ax,4c01h
        int     021h


puts	proc	near		;ds:si - string
	cld
	xor	bh,bh	;page
	mov	cx,1	;count
	mov	ah,0eh
	
Cont_put:
	lodsb
	or	al,al
	jz	toret
	int	010h	
	jmp	Cont_put

toret:	ret

puts	endp

Int23:
	iret


saveb		dw	0
@nomess		db	0

ok_mess         db      0dh,0ah,'     ╔═══════════════════════════════════════════════════════════╗'
                db      0dh,0ah,'     ║  Encahnced Russian Driver for EGA and Enchanced Keyboard. ║'
                db      0dh,0ah,'     ║               (C) 1990 by Sia.  v. 1.6                    ║'
                db      0dh,0ah,'     ╚═══════════════════════════════════════════════════════════╝'
                db      0dh,0ah,0

help_mess	db	0dh,0ah,'      Usage :'
		db	0dh,0ah,'               EN_DRV {[/Help] | [/No_message_during_loading]}'
		db	0dh,0ah
		db	    0ah,'               After loading driver use right Control key to toglle'
		db	0dh,0ah,'               russian and english keyboard.'
		db	0dh,0ah,0ah,0

loaded          db      0dh,0ah,'Enchanced Driver already loaded.',0dh,0ah,0
not_keyb        db      0dh,0ah,'Enchanced Keyboard not present.',0dh,0ah,0
not_ega         db      0dh,0ah,'Enchanced Graphic Adapter not present.',0dh,0ah,0

Code    ends

        end     Start

