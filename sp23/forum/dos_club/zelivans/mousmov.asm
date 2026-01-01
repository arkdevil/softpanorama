;╔════════════════════════════════════════════════════════════════╗
;║  Программа комплекса обеспечения работы с MOUSE из TURBO C 2.0 ║
;║  служит для получения координат мыши и признака нажатой клавиши║
;║  формат обращения:                                             ║
;║  void getmouse(int *x,int *y,struct PRESS *t);                 ║
;║  Где x,y -возвращаемые координаты мыши                         ║
;║      struct PRESS                                              ║
;║             {                                                  ║
;║              int l:1;    /* признак нажатия левой клавиши */   ║
;║              int m:1;    /*признак нажатия средней клавиши*/.  ║
;║              int r:1;    /*признак нажатия правой  клавиши*/.  ║
;║              int dummy:5;                                      ║
;║  возвращаемые значения - установка соответствующего поля струк-║ 
;║                          туры в -1 означает нажатие клавиши    ║
;╟────────────────────────────────────────────────────────────────╢
;║Программист Зеливянский Е.Б.     v.m.2.0  12/06/89 11:40am      ║
;╚════════════════════════════════════════════════════════════════╝
MOUSMOV_TEXT    segment byte public 'CODE'
DGROUP  group   _DATA,_BSS
        assume  cs:MOUSMOV_TEXT,ds:DGROUP
MOUSMOV_TEXT    ends
_DATA   segment word public 'DATA'
d@      label   byte
d@w     label   word
storbx  dw      0
_DATA   ends
_BSS    segment word public 'BSS'
b@      label   byte
b@w     label   word
_BSS    ends
MOUSMOV_TEXT    segment byte public 'CODE'
_mousmov        proc    far
        push    bp
        mov     bp,sp
; get mouse position and botton press------
getmous:mov     ax,3
        int     33h
        mov     ax,bx
        mov     storbx,ax
;---------------returned x-coordinate------
        mov     ax,cx
        les     bx,dword ptr [bp+6]
        mov     word ptr es:[bx],ax
;---------------returned y-coordinate------
        mov     ax,dx
        les     bx,dword ptr [bp+10]
        mov     word ptr es:[bx],ax
;---------------Return PRESS flags---------
        mov     ax,storbx
        les     bx,dword ptr [bp+14]
        mov     word ptr es:[bx],ax
;---------------Wait release booton--------
loop:   mov     ax,3
        xor     bx,bx
        int     33h
        cmp     bx,0
        jne     loop
exit:   mov     sp,bp
        pop     bp
        ret
_mousmov        endp
MOUSMOV_TEXT    ends
        public  _mousmov
        end
