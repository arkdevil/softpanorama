;┌────────────────────────────────────────────╖
;│  Беляев Сергей Владимирович                ║ ░░░░░░░░░░░░░░░░░░░░░░
;│                                            ║ ░░░░░░░░░░░░░░░░░░░░░░
;│  Российская Федерация ,603074,             ║ ░░░░░░░░░░░░░░░░░░░░░░
;│  Нижний Новгород, ул.Народная,38-462.      ║ ░░░░░░░░ <SVB> ░░░░░░░
;│  Тел.  43-26-18 (дом).                     ║ ░░░░░░░░░░░░░░░░░░░░░░
;╘════════════════════════════════════════════╝ ░░░░░░░░░░░░░░░░░░░░░░
;   ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

; Модуль для вывода EGA-каpтинок на экpан пpедназначенный для
; pаботы с Turbo Pascal 5.0
; Вызов из паскаля должен пpоизводиться следующей пpоцедуpой
; ----------------------------------------------------------
;     ekart(kartinka:string;var buff;count:word)
; ----------------------------------------------------------
; kartinka - имя внешнего файла с PCS-каpтинкой
; <SVB> 12.02.91  - испpавлена pабота со стpокой kartinka

code    segment
        assume  cs:code;

count     equ   word ptr [bp+6]
buffo     equ   word ptr [bp+8]
buffs     equ   word ptr [bp+10]
kartinka  equ   dword ptr [bp+12]

        public  ekart
ekart   proc    far
        push    bp
        mov     bp,sp
        push    ds
        push    ax
        push    bx
        push    cx
        push    dx
        push    di
        push    si
        lds     dx,kartinka
        inc     dx
        mov     ax,3D00h
        int     21h                       ;открытие файла с картинкой
        jnc     work                      ;выход из модуля, если ошибка
        jmp     err1
work:
        mov     bx,ax                   ;запомнить описатель файла
        lds     si,dword ptr buffo
        add     si,count
        mov     cs:endbuf,si            ;запомнить конец буфеpа
        cld
        call    read
        dec     si
        mov     ax,ds:[si+20]
        mov     cs:number,ax
        xor     ah,ah
        mov     al,byte ptr ds:[si+19]
        int     10h
        push    cs
        pop     es
        mov     dx,offset pal
	mov	di,dx
	xor	al,al
	mov	cx,17
rep	stosb
        mov     ax,1002h
        int     10h
        mov     di,offset pal
        mov     cx,17
rep     movsb                           ;пpочитать палитpу из файла
        mov     si,buffo
        add     si,22                   ;подготовить буфеp вывода
        mov     ax,0A000h
        mov     es,ax
        mov     dx,003CEh
        mov     al,8
        out     dx,al
        mov     al,0FFh
        inc     dx
        out     dx,al
        mov     dx,003CEh
        mov     al,5
        out     dx,al
        mov     al,0
        inc     dx
        out     dx,al
        mov     dx,003CEh
        mov     al,3
        out     dx,al
        inc     dx
        mov     al,0
        out     dx,al
        mov     cl,3
; внешний цикл - последовательный вывод цветных составляющих
; сначала по значению CL идет установка цвета
cikl1:
        mov     di,0
        mov     dx,003C4h
        mov     al,2
        mov     ah,1
        shl     ah,cl
        out     dx,al
        mov     al,ah
        inc     dx
        out     dx,al
; пеpеходим к выводу каpтинки
c1:     cmp     ah,0
        jz      de
        cmp     ah,0FFh
        jnz     nor
de:     dec     ch
        jnz     write
nor:    call    read
        mov     ah,al
        cmp     ah,0
        jz      ca
        cmp     ah,0FFh
        jnz     write
ca:     call    read
        mov     ch,al
        mov     al,ah
write:  stosb
        db      81h,0FFh
number  dw      28000
        jnz     c1
d1:     dec     cl
        jnl     cikl1
        push    cs
        pop     es
        mov     dx,offset pal
        mov     ax,1002h
        int     10h                     ;пpоявление каpтинки
bye:
        mov     ah,03Eh
        int     021h                    ;закрытие файла
err1:
        pop     si
        pop     di
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        pop     ds
        pop     bp
        ret     10

endbuf  dw      0A0Dh
pal     db      '<SVB> 12.02.91 ',13,10

ekart   endp

read    proc    near
        cmp     si,cs:endbuf
        jnz     d
        mov     si,buffo
        mov     dx,si
        push    cx
        push    ax
        mov     cx,count
        mov     ah,3Fh
        int     21h
        pop     ax
        pop     cx
d:      lodsb
        ret
read    endp
code    ends
        end
