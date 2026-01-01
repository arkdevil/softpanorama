EXTRN                __parc:FAR,__retc:far,__ret:far,__parinfo:far
public               rupper

psr          SEGMENT 'CODE'
             ASSUME cs:psr

rupper       PROC    FAR

;            push    bp           Сохранить регистры,все не обязательно,
;            mov     bp,sp        только необходимые. AX,DX не сохранять.
             push    ds
;            push    es
             push    si
;            push    di
             pushf

             xor   ax,ax
             push  ax
             call  __parinfo      ; Получить число параметров.
             add   sp, 2
             or    ax,ax          ; Если меньше одного - выход.
             jnz   fdz
             jmp   cfs
fdz:         mov   ax, 1
             push  ax
             call  __parinfo      ; Получить тип первого параметра.
             add   sp, 2
             cmp   ax, 1          ; Если не строка - выход.
             je    fbv
             call  __ret          ; Выход без возврата значения.
             jmp   cfs

fbv:         mov     ax,1
             push    ax
             call    __parc       ; Адрес строки в DX:AX.
             add     sp, 2

             push  dx             ; Сразу возвратить.
             push  ax
             call  __retc
             add   sp,4

             mov     ds,dx        ; До метки cfn - перекодирование символов.
             mov     si,ax
             push    ax
             xor     ah,ah

mg:          mov     al,[si]
             or      ax,ax
             jz      cfn
             cmp     ax,'a'
             jl      vd
             cmp     ax,'z'
             jle     cumz
             cmp     ax,'а'
             jl      vd
             cmp     ax,'п'
             jg       cum2
cumz:        sub     ax,20h
             jmp     vg
cum2:        cmp     ax,'р'
             jl      vd
             cmp     ax,'я'
             jg      vv0
             sub     al,50h
             jmp     vg
vv0:         cmp     ax,'ё'
             jne     vv1
             mov     al,'Ё'
             jmp     vg
vv1:         cmp     ax,'є'
             jne     vv2
             mov     al,'Є'
             jmp     vg
vv2:         cmp     ax,'°'
             jne     vv3
             mov     al,'ў'
             jmp     vg
vv3:         cmp     ax,'№'
             jne     vv4
             mov     al,'√'
             jmp     vg
vv4:         cmp     ax,'■'
             jne     vd
             mov     al,'¤'
vg:          mov     [si],al
vd:          inc     si
             jmp     mg
cfn:         pop     ax
cfs:         popf                 ; Возвратить сохраненные регистры.
;            pop     di
             pop     si
;            pop     es
             pop     ds
;            pop     bp

             ret                  ; Выход. В DX:AX адрес значения.

rupper       endp
psr          ends
             end


