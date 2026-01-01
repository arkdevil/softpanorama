;╔═══════════════════════════════════════════════════╗
;║ Программа установки границ перемещения            ║
;║ мыши.                                             ║
;║ Формат обращения:                                 ║
;║ mouseset(int x,int y);                            ║
;╟───────────────────────────────────────────────────╢
;║  Автор Зеливянский Е.Б. v.m.2.0 12/06/89 12:01pm  ║
;╩═══════════════════════════════════════════════════╝
MOUSSET_TEXT    segment byte public 'CODE'            
DGROUP  group   _DATA,_BSS
        assume  cs:MOUSSET_TEXT,ds:DGROUP
MOUSSET_TEXT    ends
_DATA   segment word public 'DATA'
d@      label   byte
d@w     label   word
_DATA   ends
_BSS    segment word public 'BSS'
b@      label   byte
b@w     label   word
_BSS    ends
MOUSSET_TEXT    segment byte public 'CODE'
_mousset        proc    far
        push    bp
        mov     bp,sp
        sub     sp,32
        mov     ax,word ptr [bp+6]
        mov     dx,ax
        xor     cx,cx
        mov     ax,7
        int     33h
        mov     ax,word ptr [bp+8]
        mov     dx,ax
        xor     cx,cx
        mov     ax,8
        int     33h
        mov     sp,bp
        pop     bp
        ret
_mousset        endp
MOUSSET_TEXT    ends
        public  _mousset
        end
