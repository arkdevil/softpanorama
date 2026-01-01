;╔════════════════════════════════════════════════════════════════╗
;║  Программа комплекса обеспечения работы с MOUSE из TURBO C 2.0 ║
;║  служит для определения наличия загруженного mouse-driver'a    ║
;║  формат обращения:                                             ║
;║  int getmouse(void);                                           ║
;║  возвращаемые значения -                                       ║
;║       0  - драйвер не загружен;                                ║
;║       1  - драйвер загружен;                                   ║
;╟────────────────────────────────────────────────────────────────╢
;║Программист Зеливянский Е.Б.     v.m.2.0  12/06/89 11:40am      ║
;╚════════════════════════════════════════════════════════════════╝
GETMOUSE_TEXT   segment byte public 'CODE'
DGROUP  group   _DATA,_BSS
        assume  cs:GETMOUSE_TEXT,ds:DGROUP
GETMOUSE_TEXT   ends
_DATA   segment word public 'DATA'
d@      label   byte
d@w     label   word
_DATA   ends
_BSS    segment word public 'BSS'
b@      label   byte
b@w     label   word
_BSS    ends
GETMOUSE_TEXT   segment byte public 'CODE'
_getmouse       proc    far
        push    bp
        mov     bp,sp
        mov     ax,0
        int     33h
        cmp     ax,-1
        jne     nomouse
        xor     ax,ax
        jmp     exit
nomouse:mov     ax,-1
exit:   mov     sp,bp
        pop     bp
        ret
_getmouse       endp
GETMOUSE_TEXT   ends
        public  _getmouse
        end
