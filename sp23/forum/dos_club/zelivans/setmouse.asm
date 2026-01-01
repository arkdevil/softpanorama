;╔════════════════════════════════════════════════════════════════╗
;║  Программа комплекса обеспечения работы с MOUSE из TURBO C 2.0 ║
;║  служит для установки отображения маркера мыши на текстовом    ║
;║  экране после отработки программы mousecur.                    ║
;║  формат обращения:                                             ║
;║  void setmouse(void);                                          ║
;║  возвращаемые значения - нет.                                  ║
;╟────────────────────────────────────────────────────────────────╢
;║Программист Зеливянский Е.Б.     v.m.2.0  12/06/89 11:40am      ║
;╚════════════════════════════════════════════════════════════════╝
SETMOUSE_TEXT   segment byte public 'CODE'
DGROUP  group   _DATA,_BSS
        assume  cs:SETMOUSE_TEXT,ds:DGROUP
SETMOUSE_TEXT   ends
_DATA   segment word public 'DATA'
d@      label   byte
d@w     label   word
_DATA   ends
_BSS    segment word public 'BSS'
b@      label   byte
b@w     label   word
_BSS    ends
SETMOUSE_TEXT   segment byte public 'CODE'
_setmouse       proc    far
        push    bp
        mov     bp,sp
        sub     sp,32
        mov     ax,1               ;set mouse function
        int     33h
        mov     sp,bp
        pop     bp
        ret
_setmouse       endp
SETMOUSE_TEXT   ends
        public  _setmouse
        end
