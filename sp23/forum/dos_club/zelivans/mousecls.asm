;╔════════════════════════════════════════════════════════════════╗
;║  Программа комплекса обеспечения работы с MOUSE из TURBO C 2.0 ║
;║  служит для удаления маркера мыши с текстового экрана.         ║
;║  формат обращения:                                             ║
;║  void mousecls(void);                                          ║
;║  возвращаемые значения - нет.                                  ║
;╟────────────────────────────────────────────────────────────────╢
;║Программист Зеливянский Е.Б.     v.m.2.0  12/06/89 11:40am      ║
;╚════════════════════════════════════════════════════════════════╝
MOUSECLS_TEXT   segment byte public 'CODE'
DGROUP  group   _DATA,_BSS
        assume  cs:MOUSECLS_TEXT,ds:DGROUP,ss:DGROUP
MOUSECLS_TEXT   ends
_DATA   segment word public 'DATA'
d@      label   byte
d@w     label   word
_DATA   ends
_BSS    segment word public 'BSS'
b@      label   byte
b@w     label   word
_BSS    ends
MOUSECLS_TEXT   segment byte public 'CODE'
_mousecls       proc    far
        push    bp
        mov     bp,sp
        sub     sp,32
        mov     ax,02h
        int     33h
        mov     sp,bp
        pop     bp
        ret
_mousecls       endp
MOUSECLS_TEXT   ends
        public  _mousecls
        end
