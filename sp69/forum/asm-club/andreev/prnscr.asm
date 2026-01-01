
; PRINTSCREEN - процедура вывода на экран строки символов.
; Адрес строки передается в регистрах DS:DX.
; Строка должна заканчиваться байтом 00Н.
; Специальным образом обрабатываются следующие символы:
;  7 (07Н) - звонок;
;  8 (08Н) - возврат на шаг назад (кроме случая когда текущая позиция в
;            начале строки);
;  9 (09Н) - табуляция (текущая позиция перемещается в ближайшую позицию
;            с номером 8n+1, где n=0,1,2,...);
; 10 (0AH) - перевод строки (курсор перемещается на строку вниз, если он
;            занимал последнюю строку экрана, то экран смещается на одну
;            строку вверх, а последняя строка отчищается);
; 13 (0DH) - возврат каретки (курсор возвращается в первую позицию строки);
; 25 (19H) - перевод курсора в строку номер которой передается вслед за
;            байтом 25, строки при этом номеруются от 0 до 24 (например:
;            перемещение курсора в 10 строку экрана - db 25,9);
; 26 (1AH) - перевод курсора в позицию номер которой передается вслед за
;            байтом 26, позиции номеруются от 0 до 79 или 39;
; 27 (1ВН) - отчистка экрана (курсор при этом устанавливается в верхний
;            левый угол экрана);
;255 (FFH) - прием байта атрибутов из выводной строки (следующий за байтом
;            255 байт, будет использоваться в качестве байта атрибута до
;            следующей смены или конца процедуры, по умолчанию байт атри-
;            бутов равен 07Н светло-серый на черном ).
; Данная процедура должна использоваться в COM-программах.
printscreen     proc    near
        push    es
        push    si
        push    di
        push    bp
        push    ax
        push    bx
        push    cx
        push    dx
        mov     si,dx
        xor     ax,ax
        mov     es,ax
        mov     ax,0b800h
        add     ax,word ptr es:[044eh]
        xor     bx,bx
        mov     bl,byte ptr es:[0462h]
        mov     npage,bl
        shl     bx,1
        add     bx,0450h
        mov     dx,word ptr es:[bx]
        mov     bx,word ptr es:[044ah]
        mov     nchar,bl
        mov     es,ax
        push    dx
        mov     ah,02h
        mov     bh,npage
        mov     dx,1900h
        int     10h
        pop     dx
        xor     ax,ax
        mov     al,nchar
        shl     ax,1
        mov     cl,dh
        mul     cl
        mov     bp,ax
        xor     cx,cx
        mov     cl,dl
        shl     cx,1
        mov     di,cx
ps001:  lodsb
        cmp     al,0dh
        jne     ps002
        xor     di,di
        xor     dl,dl
        jmp     ps001
ps002:  cmp     al,0ah
        jne     ps004
        cmp     dh,18h
        je      ps003
        inc     dh
        xor     ax,ax
        mov     al,nchar
        shl     ax,1
        add     bp,ax
        jmp     ps001
ps003:  push    ds
        push    si
        push    di
        xor     di,di
        xor     ax,ax
        mov     al,nchar
        shl     ax,1
        mov     si,ax
        mov     cl,0ch
        mul     cl
        mov     cx,ax
        mov     ax,es
        mov     ds,ax
rep     movsw
        mov     ax,0720h
        mov     cl,cs:nchar
rep     stosw
        pop     di
        pop     si
        pop     ds
        jmp     ps001
ps004:  cmp     al,1bh
        jne     ps005
        xor     ax,ax
        mov     al,nchar
        mov     cl,19h
        mul     cl
        mov     cx,ax
        mov     ax,0720h
        push    di
        xor     di,di
rep     stosw
        pop     di
        xor     di,di
        xor     bp,bp
        xor     dx,dx
        jmp     ps001
ps005:  cmp     al,07h
        jne     ps006
        mov     ah,0eh
        mov     bh,npage
        int     10h
        jmp     ps001
ps006:  cmp     al,08h
        jne     ps008
        cmp     dl,00h
        jne     ps007
        jmp     ps001
ps007:  dec     dl
        dec     di
        dec     di
        jmp     ps001
ps008:  cmp     al,0ffh
        jne     ps009
        lodsb
        mov     attrib,al
        jmp     ps001
ps009:  cmp     al,00h
        jne     ps010
        mov     attrib,07h
        mov     ah,02h
        mov     bh,npage
        int     10h
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        pop     bp
        pop     di
        pop     si
        pop     es
        ret
ps010:  cmp     al,19h
        jne     ps011
        lodsb
        mov     dh,al
        xor     ah,ah
        xor     cx,cx
        mov     cl,nchar
        shl     cx,1
        mul     cl
        mov     bp,ax
        jmp     ps001
ps011:  cmp     al,1ah
        jne     ps012
        lodsb
        mov     dl,al
        shl     ax,1
        xor     ah,ah
        mov     di,ax
        jmp     ps001
ps012:  cmp     al,09h
        jne     ps015
        mov     cl,03h
        xor     ax,ax
        mov     al,dl
        shr     ax,cl
        mov     cl,03h
        shl     ax,cl
        add     ax,08h
        cmp     al,nchar
        jb      ps013
        jmp     ps001
ps013:  sub     al,dl
        xor     cx,cx
        mov     cl,al
        mov     al,20h
        mov     ah,attrib
ps014:  mov     word ptr es:[bp+di],ax
        inc     dl
        inc     di
        inc     di
        loop    ps014
        jmp     ps001
ps015:  mov     ah,attrib
        mov     word ptr es:[bp+di],ax
        inc     dl
        inc     di
        inc     di
        cmp     dl,nchar
        jz      ps016
        jmp     ps001
ps016:  cmp     dh,18h
        jz      ps017
        xor     dl,dl
        inc     dh
        xor     di,di
        xor     ax,ax
        mov     al,nchar
        shl     ax,1
        add     bp,ax
        jmp     ps001
ps017:  xor     dl,dl
        xor     di,di
        jmp     ps003
nchar   db      50h
npage   db      00h
attrib  db      07h
printscreen     endp
