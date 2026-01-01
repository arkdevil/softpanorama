;╔═══════════════════════════════════════════════════╗
;║ Программа установки положения маркера             ║
;║ мыши.                                             ║
;║ Формат обращения:                                 ║
;║ mousepos(int x,int y);                            ║
;╟───────────────────────────────────────────────────╢
;║  Автор Зеливянский Е.Б. v.m.2.0 12/07/89 03:32pm  ║
;╩═══════════════════════════════════════════════════╝
MOUSPOS_TEXT    segment byte public 'CODE'            
DGROUP  group   _DATA,_BSS
        assume  cs:MOUSPOS_TEXT,ds:DGROUP
MOUSPOS_TEXT    ends
_DATA   segment word public 'DATA'
d@      label   byte
d@w     label   word
_DATA   ends
_BSS    segment word public 'BSS'
b@      label   byte
b@w     label   word
_BSS    ends
MOUSPOS_TEXT    segment byte public 'CODE'
_mouspos        proc    far
        push    bp
        mov     bp,sp
        sub     sp,32
        mov     ax,word ptr [bp+6]
        mov     cx,ax
        mov     dx,ax
        mov     ax,4
        int     33h
        mov     sp,bp
        pop     bp
        ret
_mouspos        endp
MOUSPOS_TEXT    ends
        public  _mouspos
        end
