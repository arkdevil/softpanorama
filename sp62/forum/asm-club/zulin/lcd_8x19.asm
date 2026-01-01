
PAGE  59,132

;==========================================================================
;==                                                                      ==
;==                          LCD_8X19                                    ==
;==                                                                      ==
;==      Created:   19-Jun-93                                            ==
;==      Version:   2.05L                                                ==
;==      Copyright (C) 1988 by Pete I. Kvitek                            ==
;==      Portion Copyright (C) 1993 by Boris Zulin                       ==
;==                                                                      ==
;==========================================================================
;   При работе в стандартном режиме 80x25 на жидкокристаллических
;  дисплеях с адаптерами VGA я не нашел нормально работающего
;  драйвера-русификатора из-за того, что один символ описывается не
;  8, 14, 16 байтами, а 19! Соответственно размер хранится в данных
;  DOS (0040:0085) и нормальные современные драйверы крутят носом,
;  проверяя этот байт. Некоторые старые драйверы работают, устанав-
;  ливая фонт 8x14, при этом затирая сверху фонт, загруженный из ПЗУ,
;  при этом также 14 байт, и у длинных символов появляются хвостики.
;  Рецепт приготовления был очень прост:
;  берем Фонт-генератор EVAfont { (C) Pete I. Kvitek, Moskow },
;  поставляемый с программой KEYRUS { (C) Д.Гуртяк, Донецк }
;  (спасибо им большое)
;  Генерим драйвер VGA.COM и 8x16.INC, из 8x16.INC делаем 8x19.INC,
;  добавляя где надо нули, или раздвигая символы...
;  На файл VGA.COM напускаем SOURCER, правда там писать-то нечего,
;  но времени всегда не хватает...
;  Для удобства исправляем .SDF, перименовываем в .DEF и запускаем
;  SR еще раз, теперь все OK.
;  Кое-где остались "лишние детали" - удаляем,
;  вставляем соответствующие проверки на режим 8x19, на наличие 
;  уже в памяти, подключаем фонт... компилируем... линкуем...
;  Получите драйвер. Для режима 8x19 устанавливается свой фонт,
;  а с остальными проблемами (читай - режимами) отличненько
;  справляется старый (? 7.30) добрый (!) KEYRUS.
;==========================================================================

video_sav_tbls_ equ     4A8h

seg_a           segment byte public
                assume  cs:seg_a, ds:seg_a


                org     100h

_8x19            proc    far


_8x19            endp

;==========================================================================
;
;                       External Entry Point
;
;==========================================================================

start           proc    far
                jmp     begin_proc
Proc_Title      db      'VGA/LCD (8x19) text font loader v2.05L', 0
                db      0Dh, 0Ah
copyright       db      'Copyright (C) 1988 by Pete I. Kvitek'
                db      0Dh, 0Ah
                db      'Portion Copyright (C) 1993 by Boris Zulin'
                db      0Dh, 0Ah, 24h
Inst            db      '8x19 font already installed', 0Dh, 0Ah, 24h
SaveInt10       dw      0
SaveInt10Seg    dw      9A3Fh
Font_Offs       dw      0
start           endp


;==========================================================================
;
;                       External Entry Point
;
;==========================================================================

int_10h_entry   proc    far
                cmp     ax, 0E000h
                je      Output
                or      ah,ah                   ; Zero ?
                jz      SetTextMode             ; Jump if zero
                jmp     dword ptr cs:SaveInt10
Output:
                mov     ah, 0FFh                ; installation check
                iret
SetTextMode:
                push    ax
                and     al,7Fh
                cmp     al,3
                jbe     SetFont                 ; Jump if below or =
                cmp     al,7
                je      SetFont                 ; Jump if equal
                pop     ax
                jmp     dword ptr cs:SaveInt10
SetFont:
                pop     ax
                push    ax
                push    bx
                push    cx
                push    dx
                push    es
                push    bp
                pushf                           ; Push flags
                call    dword ptr cs:SaveInt10
                xor     ax, ax
                mov     es, ax
                mov     bx, 0485h		; DOS data 0:485
                mov     ax, es:[bx]
                cmp     ax, 19			; 19 byte per char?
                jne     Quit_Int
                mov     ax,cs
                mov     es,ax
                mov     bp,cs:Font_Offs         ;mov     bp,24Bh
                mov     ax,1100h
                mov     bx,1300h
                mov     cx,100h
                mov     dx,0
                pushf                           ; Push flags
                call    dword ptr cs:SaveInt10
Quit_Int:
                pop     bp
                pop     es
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                iret                            ; Interrupt return
int_10h_entry   endp

begin_proc:
                mov     ax, 0E000h
                int     10h
                cmp     ah, 0FFh
                jne     Continue
                mov     dx,offset Inst          ;
                mov     ah,9
                int     21h                     ; DOS Services  ah=function 09h
                                                ;  display char string at ds:dx
                mov     ax, 4C00h               ; termimate
                int     21h
Continue:
;-----------------------------------------------------------------------------
                mov     ax, offset Font
                mov     Font_Offs, ax
                mov     ax,3510h
                int     21h                     ; DOS Services  ah=function 35h
                                                ;  get intrpt vector al in es:bx
                mov     ss:SaveInt10,bx
                mov     ss:SaveInt10Seg,es
                mov     dx,offset int_10h_entry
                mov     ax,2510h
                int     21h                     ; DOS Services  ah=function 25h
                                                ;  set intrpt vector al to ds:dx
                xor     ax, ax
                mov     es, ax
                mov     bx, 0485h
                mov     ax, es:[bx]
                cmp     ax, 19                  ; 19x8 ?
                jne     WriteText
                mov     ax,cs
                mov     es,ax
                mov     bp,Font_Offs
                mov     ax,1100h
                mov     bx,1300h
                mov     cx,100h
                mov     dx,0
                int     10h                     ; Video display   ah=functn 11h
                                                ;  font load bh=points, bl=block
                                                ;   cx=qty, dx=1st char code
                                                ;   es:bp=ptr to font table
WriteText:
                mov     dx,offset Proc_Title    ; ('VGA/LCD ...')
                mov     ah,9
                int     21h                     ; DOS Services  ah=function 09h
                                                ;  display char string at ds:dx
                mov     dx,5248
                mov     cl,4
                shr     dx,cl                   ; Shift w/zeros fill
                inc     dx
                mov     ax,3100h
                int     21h                     ; DOS Services  ah=function 31h
                                                ;  terminate & stay resident
                                                ;   al=return code,dx=paragraphs
Font       db 000h,000h,000h,000h,000h,000h,000h,000h,000h
           db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h     ; 000
           db 000h,000h,000h,07Eh,081h,0A5h,081h,081h,0BDh
           db 099h,081h,081h,07Eh,000h,000h,000h,000h,000h,000h     ; 001
           db 000h,000h,000h,07Eh,0FFh,0DBh,0FFh,0FFh,0C3h
           db 0E7h,0FFh,0FFh,07Eh,000h,000h,000h,000h,000h,000h     ; 002
           db 000h,000h,000h,000h,000h,06Ch,0FEh,0FEh,0FEh
           db 0FEh,07Ch,038h,010h,000h,000h,000h,000h,000h,000h     ; 003
           db 000h,000h,000h,000h,000h,010h,038h,07Ch,0FEh
           db 07Ch,038h,010h,000h,000h,000h,000h,000h,000h,000h     ; 004
           db 000h,000h,000h,000h,018h,03Ch,03Ch,0E7h,0E7h
           db 0E7h,099h,018h,03Ch,000h,000h,000h,000h,000h,000h     ; 005
           db 000h,000h,000h,000h,018h,03Ch,07Eh,0FFh,0FFh
           db 07Eh,018h,018h,03Ch,000h,000h,000h,000h,000h,000h     ; 006
           db 000h,000h,000h,000h,000h,000h,000h,018h,03Ch
           db 03Ch,018h,000h,000h,000h,000h,000h,000h,000h,000h     ; 007
           db 000h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0E7h,0C3h
           db 0C3h,0E7h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,000h,000h     ; 008
           db 000h,000h,000h,000h,000h,000h,03Ch,066h,042h
           db 042h,066h,03Ch,000h,000h,000h,000h,000h,000h,000h     ; 009
           db 000h,0FFh,0FFh,0FFh,0FFh,0FFh,0C3h,099h,0BDh
           db 0BDh,099h,0C3h,0FFh,0FFh,0FFh,0FFh,0FFh,000h,000h     ; 00A
           db 000h,000h,000h,01Eh,00Eh,01Ah,032h,078h,0CCh
           db 0CCh,0CCh,0CCh,078h,000h,000h,000h,000h,000h,000h     ; 00B
           db 000h,000h,000h,03Ch,066h,066h,066h,066h,03Ch
           db 018h,07Eh,018h,018h,000h,000h,000h,000h,000h,000h     ; 00C
           db 000h,000h,000h,03Fh,033h,03Fh,030h,030h,030h
           db 030h,070h,0F0h,0E0h,000h,000h,000h,000h,000h,000h     ; 00D
           db 000h,000h,000h,07Fh,063h,07Fh,063h,063h,063h
           db 063h,067h,0E7h,0E6h,0C0h,000h,000h,000h,000h,000h     ; 00E
           db 000h,000h,000h,000h,018h,018h,0DBh,03Ch,0E7h
           db 03Ch,0DBh,018h,018h,000h,000h,000h,000h,000h,000h     ; 00F
           db 000h,000h,080h,0C0h,0E0h,0F0h,0F8h,0FEh,0F8h
           db 0F0h,0E0h,0C0h,080h,000h,000h,000h,000h,000h,000h     ; 010
           db 000h,000h,002h,006h,00Eh,01Eh,03Eh,0FEh,03Eh
           db 01Eh,00Eh,006h,002h,000h,000h,000h,000h,000h,000h     ; 011
           db 000h,000h,000h,018h,03Ch,07Eh,018h,018h,018h
           db 018h,07Eh,03Ch,018h,000h,000h,000h,000h,000h,000h     ; 012
           db 000h,000h,000h,066h,066h,066h,066h,066h,066h
           db 066h,000h,066h,066h,000h,000h,000h,000h,000h,000h     ; 013
           db 000h,000h,000h,07Fh,0DBh,0DBh,0DBh,07Bh,01Bh
           db 01Bh,01Bh,01Bh,01Bh,000h,000h,000h,000h,000h,000h     ; 014
           db 000h,000h,07Ch,0C6h,060h,038h,06Ch,0C6h,0C6h
           db 06Ch,038h,00Ch,0C6h,07Ch,000h,000h,000h,000h,000h     ; 015
           db 000h,000h,000h,000h,000h,000h,000h,000h,000h
           db 0FEh,0FEh,0FEh,0FEh,000h,000h,000h,000h,000h,000h     ; 016
           db 000h,000h,000h,018h,03Ch,07Eh,018h,018h,018h
           db 018h,07Eh,03Ch,018h,07Eh,000h,000h,000h,000h,000h     ; 017
           db 000h,000h,000h,018h,03Ch,07Eh,018h,018h,018h
           db 018h,018h,018h,018h,000h,000h,000h,000h,000h,000h     ; 018
           db 000h,000h,000h,018h,018h,018h,018h,018h,018h
           db 018h,07Eh,03Ch,018h,000h,000h,000h,000h,000h,000h     ; 019
           db 000h,000h,000h,000h,000h,000h,018h,00Ch,0FEh
           db 00Ch,018h,000h,000h,000h,000h,000h,000h,000h,000h     ; 01A
           db 000h,000h,000h,000h,000h,000h,030h,060h,0FEh
           db 060h,030h,000h,000h,000h,000h,000h,000h,000h,000h     ; 01B
           db 000h,000h,000h,000h,000h,000h,0C0h,0C0h,0C0h
           db 0C0h,0FEh,000h,000h,000h,000h,000h,000h,000h,000h     ; 01C
           db 000h,000h,000h,000h,000h,000h,028h,06Ch,0FEh
           db 06Ch,028h,000h,000h,000h,000h,000h,000h,000h,000h     ; 01D
           db 000h,000h,000h,000h,000h,010h,038h,038h,07Ch
           db 07Ch,0FEh,0FEh,000h,000h,000h,000h,000h,000h,000h     ; 01E
           db 000h,000h,000h,000h,000h,0FEh,0FEh,07Ch,07Ch
           db 038h,038h,010h,000h,000h,000h,000h,000h,000h,000h     ; 01F
           db 000h,000h,000h,000h,000h,000h,000h,000h,000h
           db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h     ; 020
           db 000h,000h,000h,018h,03Ch,03Ch,03Ch,018h,018h
           db 018h,000h,018h,018h,000h,000h,000h,000h,000h,000h     ; 021
           db 000h,000h,066h,066h,066h,024h,000h,000h,000h
           db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h     ; 022
           db 000h,000h,000h,000h,06Ch,06Ch,0FEh,06Ch,06Ch
           db 06Ch,0FEh,06Ch,06Ch,000h,000h,000h,000h,000h,000h     ; 023
           db 000h,018h,018h,07Ch,0C6h,0C2h,0C0h,07Ch,006h
           db 086h,0C6h,07Ch,018h,018h,000h,000h,000h,000h,000h     ; 024
           db 000h,000h,000h,000h,000h,0C2h,0C6h,00Ch,018h
           db 030h,060h,0C6h,086h,000h,000h,000h,000h,000h,000h     ; 025
           db 000h,000h,000h,038h,06Ch,06Ch,038h,076h,0DCh
           db 0CCh,0CCh,0CCh,076h,000h,000h,000h,000h,000h,000h     ; 026
           db 000h,000h,030h,030h,030h,060h,000h,000h,000h
           db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h     ; 027
           db 000h,000h,000h,00Ch,018h,030h,030h,030h,030h
           db 030h,030h,018h,00Ch,000h,000h,000h,000h,000h,000h     ; 028
           db 000h,000h,000h,030h,018h,00Ch,00Ch,00Ch,00Ch
           db 00Ch,00Ch,018h,030h,000h,000h,000h,000h,000h,000h     ; 029
           db 000h,000h,000h,000h,000h,000h,066h,03Ch,0FFh
           db 03Ch,066h,000h,000h,000h,000h,000h,000h,000h,000h     ; 02A
           db 000h,000h,000h,000h,000h,000h,018h,018h,07Eh
           db 018h,018h,000h,000h,000h,000h,000h,000h,000h,000h     ; 02B
           db 000h,000h,000h,000h,000h,000h,000h,000h,000h
           db 000h,018h,018h,018h,030h,000h,000h,000h,000h,000h     ; 02C
           db 000h,000h,000h,000h,000h,000h,000h,000h,0FEh
           db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h     ; 02D
           db 000h,000h,000h,000h,000h,000h,000h,000h,000h
           db 000h,000h,018h,018h,000h,000h,000h,000h,000h,000h     ; 02E
           db 000h,000h,000h,000h,000h,002h,006h,00Ch,018h
           db 030h,060h,0C0h,080h,000h,000h,000h,000h,000h,000h     ; 02F
           db 000h,000h,000h,07Ch,0C6h,0C6h,0CEh,0D6h,0D6h
           db 0E6h,0C6h,0C6h,07Ch,000h,000h,000h,000h,000h,000h     ; 030
           db 000h,000h,000h,018h,038h,078h,018h,018h,018h
           db 018h,018h,018h,07Eh,000h,000h,000h,000h,000h,000h     ; 031
           db 000h,000h,000h,07Ch,0C6h,006h,00Ch,018h,030h
           db 060h,0C0h,0C6h,0FEh,000h,000h,000h,000h,000h,000h     ; 032
           db 000h,000h,000h,07Ch,0C6h,006h,006h,03Ch,006h
           db 006h,006h,0C6h,07Ch,000h,000h,000h,000h,000h,000h     ; 033
           db 000h,000h,000h,00Ch,01Ch,03Ch,06Ch,0CCh,0FEh
           db 00Ch,00Ch,00Ch,01Eh,000h,000h,000h,000h,000h,000h     ; 034
           db 000h,000h,000h,0FEh,0C0h,0C0h,0C0h,0FCh,00Eh
           db 006h,006h,0C6h,07Ch,000h,000h,000h,000h,000h,000h     ; 035
           db 000h,000h,000h,038h,060h,0C0h,0C0h,0FCh,0C6h
           db 0C6h,0C6h,0C6h,07Ch,000h,000h,000h,000h,000h,000h     ; 036
           db 000h,000h,000h,0FEh,0C6h,006h,006h,00Ch,018h
           db 030h,030h,030h,030h,000h,000h,000h,000h,000h,000h     ; 037
           db 000h,000h,000h,07Ch,0C6h,0C6h,0C6h,07Ch,0C6h
           db 0C6h,0C6h,0C6h,07Ch,000h,000h,000h,000h,000h,000h     ; 038
           db 000h,000h,000h,07Ch,0C6h,0C6h,0C6h,07Eh,006h
           db 006h,006h,00Ch,078h,000h,000h,000h,000h,000h,000h     ; 039
           db 000h,000h,000h,000h,000h,018h,018h,000h,000h
           db 000h,018h,018h,000h,000h,000h,000h,000h,000h,000h     ; 03A
           db 000h,000h,000h,000h,000h,018h,018h,000h,000h
           db 000h,018h,018h,030h,000h,000h,000h,000h,000h,000h     ; 03B
           db 000h,000h,000h,000h,006h,00Ch,018h,030h,060h
           db 030h,018h,00Ch,006h,000h,000h,000h,000h,000h,000h     ; 03C
           db 000h,000h,000h,000h,000h,000h,000h,0FEh,000h
           db 000h,0FEh,000h,000h,000h,000h,000h,000h,000h,000h     ; 03D
           db 000h,000h,000h,000h,060h,030h,018h,00Ch,006h
           db 00Ch,018h,030h,060h,000h,000h,000h,000h,000h,000h     ; 03E
           db 000h,000h,000h,07Ch,0C6h,0C6h,00Ch,018h,018h
           db 018h,000h,018h,018h,000h,000h,000h,000h,000h,000h     ; 03F
           db 000h,000h,000h,000h,07Ch,0C6h,0C6h,0DEh,0DEh
           db 0DEh,0DCh,0C0h,07Ch,000h,000h,000h,000h,000h,000h     ; 040
           db 000h,000h,000h,010h,038h,06Ch,0C6h,0C6h,0FEh
           db 0C6h,0C6h,0C6h,0C6h,000h,000h,000h,000h,000h,000h     ; 041
           db 000h,000h,000h,0FCh,066h,066h,066h,07Ch,066h
           db 066h,066h,066h,0FCh,000h,000h,000h,000h,000h,000h     ; 042
           db 000h,000h,000h,03Ch,066h,0C2h,0C0h,0C0h,0C0h
           db 0C0h,0C2h,066h,03Ch,000h,000h,000h,000h,000h,000h     ; 043
           db 000h,000h,000h,0F8h,06Ch,066h,066h,066h,066h
           db 066h,066h,06Ch,0F8h,000h,000h,000h,000h,000h,000h     ; 044
           db 000h,000h,000h,0FEh,066h,062h,068h,078h,068h
           db 060h,062h,066h,0FEh,000h,000h,000h,000h,000h,000h     ; 045
           db 000h,000h,000h,0FEh,066h,062h,068h,078h,068h
           db 060h,060h,060h,0F0h,000h,000h,000h,000h,000h,000h     ; 046
           db 000h,000h,000h,03Ch,066h,0C2h,0C0h,0C0h,0DEh
           db 0C6h,0C6h,066h,03Ah,000h,000h,000h,000h,000h,000h     ; 047
           db 000h,000h,000h,0C6h,0C6h,0C6h,0C6h,0FEh,0C6h
           db 0C6h,0C6h,0C6h,0C6h,000h,000h,000h,000h,000h,000h     ; 048
           db 000h,000h,000h,03Ch,018h,018h,018h,018h,018h
           db 018h,018h,018h,03Ch,000h,000h,000h,000h,000h,000h     ; 049
           db 000h,000h,000h,01Eh,00Ch,00Ch,00Ch,00Ch,00Ch
           db 0CCh,0CCh,0CCh,078h,000h,000h,000h,000h,000h,000h     ; 04A
           db 000h,000h,000h,0E6h,066h,06Ch,06Ch,078h,078h
           db 06Ch,066h,066h,0E6h,000h,000h,000h,000h,000h,000h     ; 04B
           db 000h,000h,000h,0F0h,060h,060h,060h,060h,060h
           db 060h,062h,066h,0FEh,000h,000h,000h,000h,000h,000h     ; 04C
           db 000h,000h,000h,0C6h,0EEh,0FEh,0FEh,0D6h,0C6h
           db 0C6h,0C6h,0C6h,0C6h,000h,000h,000h,000h,000h,000h     ; 04D
           db 000h,000h,000h,0C6h,0E6h,0F6h,0FEh,0DEh,0CEh
           db 0C6h,0C6h,0C6h,0C6h,000h,000h,000h,000h,000h,000h     ; 04E
           db 000h,000h,000h,038h,06Ch,0C6h,0C6h,0C6h,0C6h
           db 0C6h,0C6h,06Ch,038h,000h,000h,000h,000h,000h,000h     ; 04F
           db 000h,000h,000h,0FCh,066h,066h,066h,07Ch,060h
           db 060h,060h,060h,0F0h,000h,000h,000h,000h,000h,000h     ; 050
           db 000h,000h,000h,07Ch,0C6h,0C6h,0C6h,0C6h,0C6h
           db 0C6h,0D6h,0DEh,07Ch,00Ch,00Eh,000h,000h,000h,000h     ; 051
           db 000h,000h,000h,0FCh,066h,066h,066h,07Ch,06Ch
           db 066h,066h,066h,0E6h,000h,000h,000h,000h,000h,000h     ; 052
           db 000h,000h,000h,07Ch,0C6h,0C6h,060h,038h,00Ch
           db 006h,0C6h,0C6h,07Ch,000h,000h,000h,000h,000h,000h     ; 053
           db 000h,000h,000h,07Eh,07Eh,05Ah,018h,018h,018h
           db 018h,018h,018h,03Ch,000h,000h,000h,000h,000h,000h     ; 054
           db 000h,000h,000h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h
           db 0C6h,0C6h,0C6h,07Ch,000h,000h,000h,000h,000h,000h     ; 055
           db 000h,000h,000h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h
           db 0C6h,06Ch,038h,010h,000h,000h,000h,000h,000h,000h     ; 056
           db 000h,000h,000h,0C6h,0C6h,0C6h,0C6h,0C6h,0D6h
           db 0D6h,0FEh,06Ch,06Ch,000h,000h,000h,000h,000h,000h     ; 057
           db 000h,000h,000h,0C6h,0C6h,06Ch,06Ch,038h,038h
           db 06Ch,06Ch,0C6h,0C6h,000h,000h,000h,000h,000h,000h     ; 058
           db 000h,000h,000h,066h,066h,066h,066h,03Ch,018h
           db 018h,018h,018h,03Ch,000h,000h,000h,000h,000h,000h     ; 059
           db 000h,000h,000h,0FEh,0C6h,086h,00Ch,018h,030h
           db 060h,0C2h,0C6h,0FEh,000h,000h,000h,000h,000h,000h     ; 05A
           db 000h,000h,000h,03Ch,030h,030h,030h,030h,030h
           db 030h,030h,030h,03Ch,000h,000h,000h,000h,000h,000h     ; 05B
           db 000h,000h,000h,000h,080h,0C0h,0E0h,070h,038h
           db 01Ch,00Eh,006h,002h,000h,000h,000h,000h,000h,000h     ; 05C
           db 000h,000h,000h,03Ch,00Ch,00Ch,00Ch,00Ch,00Ch
           db 00Ch,00Ch,00Ch,03Ch,000h,000h,000h,000h,000h,000h     ; 05D
           db 000h,010h,038h,06Ch,0C6h,000h,000h,000h,000h
           db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h     ; 05E
           db 000h,000h,000h,000h,000h,000h,000h,000h,000h
           db 000h,000h,000h,000h,000h,000h,000h,0FFh,000h,000h     ; 05F
           db 000h,030h,030h,018h,000h,000h,000h,000h,000h
           db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h     ; 060
           db 000h,000h,000h,000h,000h,000h,078h,00Ch,07Ch
           db 0CCh,0CCh,0CCh,076h,000h,000h,000h,000h,000h,000h     ; 061
           db 000h,000h,000h,0E0h,060h,060h,078h,06Ch,066h
           db 066h,066h,066h,0DCh,000h,000h,000h,000h,000h,000h     ; 062
           db 000h,000h,000h,000h,000h,000h,07Ch,0C6h,0C0h
           db 0C0h,0C0h,0C6h,07Ch,000h,000h,000h,000h,000h,000h     ; 063
           db 000h,000h,000h,01Ch,00Ch,00Ch,03Ch,06Ch,0CCh
           db 0CCh,0CCh,0CCh,076h,000h,000h,000h,000h,000h,000h     ; 064
           db 000h,000h,000h,000h,000h,000h,07Ch,0C6h,0FEh
           db 0C0h,0C0h,0C6h,07Ch,000h,000h,000h,000h,000h,000h     ; 065
           db 000h,000h,000h,038h,06Ch,064h,060h,0F0h,060h
           db 060h,060h,060h,0F0h,000h,000h,000h,000h,000h,000h     ; 066
           db 000h,000h,000h,000h,000h,000h,076h,0CCh,0CCh
           db 0CCh,0CCh,0CCh,07Ch,00Ch,0CCh,078h,000h,000h,000h     ; 067
           db 000h,000h,000h,0E0h,060h,060h,06Ch,076h,066h
           db 066h,066h,066h,0E6h,000h,000h,000h,000h,000h,000h     ; 068
           db 000h,000h,000h,018h,018h,000h,038h,018h,018h
           db 018h,018h,018h,03Ch,000h,000h,000h,000h,000h,000h     ; 069
           db 000h,000h,000h,006h,006h,000h,00Eh,006h,006h
           db 006h,006h,006h,006h,066h,066h,03Ch,000h,000h,000h     ; 06A
           db 000h,000h,000h,0E0h,060h,060h,066h,06Ch,078h
           db 078h,06Ch,066h,0E6h,000h,000h,000h,000h,000h,000h     ; 06B
           db 000h,000h,000h,038h,018h,018h,018h,018h,018h
           db 018h,018h,018h,03Ch,000h,000h,000h,000h,000h,000h     ; 06C
           db 000h,000h,000h,000h,000h,000h,0ECh,0FEh,0D6h
           db 0D6h,0D6h,0D6h,0D6h,000h,000h,000h,000h,000h,000h     ; 06D
           db 000h,000h,000h,000h,000h,000h,0DCh,066h,066h
           db 066h,066h,066h,066h,000h,000h,000h,000h,000h,000h     ; 06E
           db 000h,000h,000h,000h,000h,000h,07Ch,0C6h,0C6h
           db 0C6h,0C6h,0C6h,07Ch,000h,000h,000h,000h,000h,000h     ; 06F
           db 000h,000h,000h,000h,000h,000h,0DCh,066h,066h
           db 066h,066h,066h,07Ch,060h,060h,0F0h,000h,000h,000h     ; 070
           db 000h,000h,000h,000h,000h,000h,076h,0CCh,0CCh
           db 0CCh,0CCh,0CCh,07Ch,00Ch,00Ch,01Eh,000h,000h,000h     ; 071
           db 000h,000h,000h,000h,000h,000h,0DCh,076h,062h
           db 060h,060h,060h,0F0h,000h,000h,000h,000h,000h,000h     ; 072
           db 000h,000h,000h,000h,000h,000h,07Ch,0C6h,060h
           db 038h,00Ch,0C6h,07Ch,000h,000h,000h,000h,000h,000h     ; 073
           db 000h,000h,000h,010h,030h,030h,0FCh,030h,030h
           db 030h,030h,036h,01Ch,000h,000h,000h,000h,000h,000h     ; 074
           db 000h,000h,000h,000h,000h,000h,0CCh,0CCh,0CCh
           db 0CCh,0CCh,0CCh,076h,000h,000h,000h,000h,000h,000h     ; 075
           db 000h,000h,000h,000h,000h,000h,066h,066h,066h
           db 066h,066h,03Ch,018h,000h,000h,000h,000h,000h,000h     ; 076
           db 000h,000h,000h,000h,000h,000h,0C6h,0C6h,0C6h
           db 0D6h,0D6h,0FEh,06Ch,000h,000h,000h,000h,000h,000h     ; 077
           db 000h,000h,000h,000h,000h,000h,0C6h,06Ch,038h
           db 038h,038h,06Ch,0C6h,000h,000h,000h,000h,000h,000h     ; 078
           db 000h,000h,000h,000h,000h,000h,0C6h,0C6h,0C6h
           db 0C6h,0C6h,0C6h,07Eh,006h,00Ch,0F8h,000h,000h,000h     ; 079
           db 000h,000h,000h,000h,000h,000h,0FEh,0CCh,018h
           db 030h,060h,0C6h,0FEh,000h,000h,000h,000h,000h,000h     ; 07A
           db 000h,000h,000h,00Eh,018h,018h,018h,070h,018h
           db 018h,018h,018h,00Eh,000h,000h,000h,000h,000h,000h     ; 07B
           db 000h,000h,000h,018h,018h,018h,018h,018h,000h
           db 018h,018h,018h,018h,018h,018h,000h,000h,000h,000h     ; 07C
           db 000h,000h,000h,070h,018h,018h,018h,00Eh,018h
           db 018h,018h,018h,070h,000h,000h,000h,000h,000h,000h     ; 07D
           db 000h,000h,000h,076h,0DCh,000h,000h,000h,000h
           db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h     ; 07E
           db 000h,000h,000h,000h,000h,010h,038h,06Ch,0C6h
           db 0C6h,0C6h,0FEh,000h,000h,000h,000h,000h,000h,000h     ; 07F
           db 000h,000h,000h,01Eh,036h,066h,0C6h,0C6h,0FEh
           db 0C6h,0C6h,0C6h,0C6h,000h,000h,000h,000h,000h,000h     ; 080
           db 000h,000h,000h,0FEh,062h,062h,060h,07Ch,066h
           db 066h,066h,066h,0FCh,000h,000h,000h,000h,000h,000h     ; 081
           db 000h,000h,000h,0FCh,066h,066h,066h,07Ch,066h
           db 066h,066h,066h,0FCh,000h,000h,000h,000h,000h,000h     ; 082
           db 000h,000h,000h,0FEh,062h,062h,060h,060h,060h
           db 060h,060h,060h,0F0h,000h,000h,000h,000h,000h,000h     ; 083
           db 000h,000h,000h,01Eh,036h,066h,066h,066h,066h
           db 066h,066h,066h,0FFh,0C3h,081h,000h,000h,000h,000h     ; 084
           db 000h,000h,000h,0FEh,066h,062h,068h,078h,068h
           db 060h,062h,066h,0FEh,000h,000h,000h,000h,000h,000h     ; 085
           db 000h,000h,000h,0D6h,0D6h,054h,054h,07Ch,07Ch
           db 054h,0D6h,0D6h,0D6h,000h,000h,000h,000h,000h,000h     ; 086
           db 000h,000h,000h,07Ch,0C6h,006h,006h,03Ch,006h
           db 006h,006h,0C6h,07Ch,000h,000h,000h,000h,000h,000h     ; 087
           db 000h,000h,000h,0C6h,0C6h,0CEh,0CEh,0D6h,0E6h
           db 0E6h,0C6h,0C6h,0C6h,000h,000h,000h,000h,000h,000h     ; 088
           db 000h,038h,038h,0C6h,0C6h,0CEh,0CEh,0D6h,0E6h
           db 0E6h,0C6h,0C6h,0C6h,000h,000h,000h,000h,000h,000h     ; 089
           db 000h,000h,000h,0E6h,066h,06Ch,06Ch,078h,078h
           db 06Ch,06Ch,066h,0E6h,000h,000h,000h,000h,000h,000h     ; 08A
           db 000h,000h,000h,01Eh,036h,066h,0C6h,0C6h,0C6h
           db 0C6h,0C6h,0C6h,0C6h,000h,000h,000h,000h,000h,000h     ; 08B
           db 000h,000h,000h,0C6h,0EEh,0FEh,0FEh,0D6h,0C6h
           db 0C6h,0C6h,0C6h,0C6h,000h,000h,000h,000h,000h,000h     ; 08C
           db 000h,000h,000h,0C6h,0C6h,0C6h,0C6h,0FEh,0C6h
           db 0C6h,0C6h,0C6h,0C6h,000h,000h,000h,000h,000h,000h     ; 08D
           db 000h,000h,000h,07Ch,0C6h,0C6h,0C6h,0C6h,0C6h
           db 0C6h,0C6h,0C6h,07Ch,000h,000h,000h,000h,000h,000h     ; 08E
           db 000h,000h,000h,0FEh,0C6h,0C6h,0C6h,0C6h,0C6h
           db 0C6h,0C6h,0C6h,0C6h,000h,000h,000h,000h,000h,000h     ; 08F
           db 000h,000h,000h,0FCh,066h,066h,066h,07Ch,060h
           db 060h,060h,060h,0F0h,000h,000h,000h,000h,000h,000h     ; 090
           db 000h,000h,000h,03Ch,066h,0C2h,0C0h,0C0h,0C0h
           db 0C0h,0C2h,066h,03Ch,000h,000h,000h,000h,000h,000h     ; 091
           db 000h,000h,000h,07Eh,05Ah,018h,018h,018h,018h
           db 018h,018h,018h,03Ch,000h,000h,000h,000h,000h,000h     ; 092
           db 000h,000h,000h,0C6h,0C6h,0C6h,0C6h,0C6h,07Eh
           db 006h,006h,0C6h,07Ch,000h,000h,000h,000h,000h,000h     ; 093
           db 000h,000h,03Ch,018h,07Eh,0DBh,0DBh,0DBh,0DBh
           db 0DBh,07Eh,018h,03Ch,000h,000h,000h,000h,000h,000h     ; 094
           db 000h,000h,000h,0C6h,0C6h,06Ch,07Ch,038h,038h
           db 07Ch,06Ch,0C6h,0C6h,000h,000h,000h,000h,000h,000h     ; 095
           db 000h,000h,000h,0CCh,0CCh,0CCh,0CCh,0CCh,0CCh
           db 0CCh,0CCh,0CCh,0FEh,006h,006h,000h,000h,000h,000h     ; 096
           db 000h,000h,000h,0C6h,0C6h,0C6h,0C6h,0C6h,07Eh
           db 006h,006h,006h,006h,000h,000h,000h,000h,000h,000h     ; 097
           db 000h,000h,000h,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh
           db 0DBh,0DBh,0DBh,0FFh,000h,000h,000h,000h,000h,000h     ; 098
           db 000h,000h,000h,0DBh,0DBh,0DBh,0DBh,0DBh,0DBh
           db 0DBh,0DBh,0DBh,0FFh,003h,003h,000h,000h,000h,000h     ; 099
           db 000h,000h,000h,0F8h,0B0h,030h,030h,03Eh,033h
           db 033h,033h,033h,07Eh,000h,000h,000h,000h,000h,000h     ; 09A
           db 000h,000h,000h,0C3h,0C3h,0C3h,0C3h,0F3h,0DBh
           db 0DBh,0DBh,0DBh,0F3h,000h,000h,000h,000h,000h,000h     ; 09B
           db 000h,000h,000h,0F0h,060h,060h,060h,07Ch,066h
           db 066h,066h,066h,0FCh,000h,000h,000h,000h,000h,000h     ; 09C
           db 000h,000h,000h,07Ch,0C6h,006h,026h,03Eh,026h
           db 006h,006h,0C6h,07Ch,000h,000h,000h,000h,000h,000h     ; 09D
           db 000h,000h,000h,0CEh,0DBh,0DBh,0DBh,0FBh,0DBh
           db 0DBh,0DBh,0DBh,0CEh,000h,000h,000h,000h,000h,000h     ; 09E
           db 000h,000h,000h,03Fh,066h,066h,066h,03Eh,03Eh
           db 066h,066h,066h,0E7h,000h,000h,000h,000h,000h,000h     ; 09F
           db 000h,000h,000h,000h,000h,000h,078h,00Ch,07Ch
           db 0CCh,0CCh,0CCh,076h,000h,000h,000h,000h,000h,000h     ; 0A0
           db 000h,000h,002h,006h,03Ch,060h,060h,07Ch,066h
           db 066h,066h,066h,03Ch,000h,000h,000h,000h,000h,000h     ; 0A1
           db 000h,000h,000h,000h,000h,000h,0FCh,066h,066h
           db 07Ch,066h,066h,0FCh,000h,000h,000h,000h,000h,000h     ; 0A2
           db 000h,000h,000h,000h,000h,000h,07Eh,032h,032h
           db 030h,030h,030h,078h,000h,000h,000h,000h,000h,000h     ; 0A3
           db 000h,000h,000h,000h,000h,000h,01Eh,036h,036h
           db 066h,066h,066h,0FFh,0C3h,0C3h,000h,000h,000h,000h     ; 0A4
           db 000h,000h,000h,000h,000h,000h,07Ch,0C6h,0FEh
           db 0C0h,0C0h,0C6h,07Ch,000h,000h,000h,000h,000h,000h     ; 0A5
           db 000h,000h,000h,000h,000h,000h,0D6h,0D6h,054h
           db 07Ch,054h,0D6h,0D6h,000h,000h,000h,000h,000h,000h     ; 0A6
           db 000h,000h,000h,000h,000h,000h,03Ch,066h,006h
           db 00Ch,006h,066h,03Ch,000h,000h,000h,000h,000h,000h     ; 0A7
           db 000h,000h,000h,000h,000h,000h,0C6h,0C6h,0CEh
           db 0D6h,0E6h,0C6h,0C6h,000h,000h,000h,000h,000h,000h     ; 0A8
           db 000h,000h,000h,000h,038h,038h,0C6h,0C6h,0CEh
           db 0D6h,0E6h,0C6h,0C6h,000h,000h,000h,000h,000h,000h     ; 0A9
           db 000h,000h,000h,000h,000h,000h,0E6h,06Ch,078h
           db 078h,06Ch,066h,0E6h,000h,000h,000h,000h,000h,000h     ; 0AA
           db 000h,000h,000h,000h,000h,000h,01Eh,036h,066h
           db 066h,066h,066h,066h,000h,000h,000h,000h,000h,000h     ; 0AB
           db 000h,000h,000h,000h,000h,000h,0C6h,0EEh,0FEh
           db 0FEh,0D6h,0D6h,0C6h,000h,000h,000h,000h,000h,000h     ; 0AC
           db 000h,000h,000h,000h,000h,000h,0C6h,0C6h,0C6h
           db 0FEh,0C6h,0C6h,0C6h,000h,000h,000h,000h,000h,000h     ; 0AD
           db 000h,000h,000h,000h,000h,000h,07Ch,0C6h,0C6h
           db 0C6h,0C6h,0C6h,07Ch,000h,000h,000h,000h,000h,000h     ; 0AE
           db 000h,000h,000h,000h,000h,000h,0FEh,0C6h,0C6h
           db 0C6h,0C6h,0C6h,0C6h,000h,000h,000h,000h,000h,000h     ; 0AF
           db 044h,011h,044h,011h,044h,011h,044h,011h,044h
           db 011h,044h,011h,044h,011h,044h,011h,044h,011h,022h     ; 0B0
           db 0AAh,055h,0AAh,055h,0AAh,055h,0AAh,055h,0AAh
           db 055h,0AAh,055h,0AAh,055h,0AAh,055h,0AAh,055h,0AAh     ; 0B1
           db 077h,0DDh,077h,0DDh,077h,0DDh,077h,0DDh,077h
           db 0DDh,077h,0DDh,077h,0DDh,077h,0DDh,077h,0DDh,077h     ; 0B2
           db 018h,018h,018h,018h,018h,018h,018h,018h,018h
           db 018h,018h,018h,018h,018h,018h,018h,018h,018h,018h     ; 0B3
           db 018h,018h,018h,018h,018h,018h,018h,018h,0F8h
           db 018h,018h,018h,018h,018h,018h,018h,018h,018h,018h     ; 0B4
           db 018h,018h,018h,018h,018h,018h,0F8h,018h,0F8h
           db 018h,018h,018h,018h,018h,018h,018h,018h,018h,018h     ; 0B5
           db 036h,036h,036h,036h,036h,036h,036h,036h,0F6h
           db 036h,036h,036h,036h,036h,036h,036h,036h,036h,036h     ; 0B6
           db 000h,000h,000h,000h,000h,000h,000h,000h,0FEh
           db 036h,036h,036h,036h,036h,036h,036h,036h,036h,036h     ; 0B7
           db 000h,000h,000h,000h,000h,000h,0F8h,018h,0F8h
           db 018h,018h,018h,018h,018h,018h,018h,018h,018h,018h     ; 0B8
           db 036h,036h,036h,036h,036h,036h,0F6h,006h,0F6h
           db 036h,036h,036h,036h,036h,036h,036h,036h,036h,036h     ; 0B9
           db 036h,036h,036h,036h,036h,036h,036h,036h,036h
           db 036h,036h,036h,036h,036h,036h,036h,036h,036h,036h     ; 0BA
           db 000h,000h,000h,000h,000h,000h,0FEh,006h,0F6h
           db 036h,036h,036h,036h,036h,036h,036h,036h,036h,036h     ; 0BB
           db 036h,036h,036h,036h,036h,036h,0F6h,006h,0FEh
           db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h     ; 0BC
           db 036h,036h,036h,036h,036h,036h,036h,036h,0FEh
           db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h     ; 0BD
           db 018h,018h,018h,018h,018h,018h,0F8h,018h,0F8h
           db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h     ; 0BE
           db 000h,000h,000h,000h,000h,000h,000h,000h,0F8h
           db 018h,018h,018h,018h,018h,018h,018h,018h,018h,018h     ; 0BF
           db 018h,018h,018h,018h,018h,018h,018h,018h,01Fh
           db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h     ; 0C0
           db 018h,018h,018h,018h,018h,018h,018h,018h,0FFh
           db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h     ; 0C1
           db 000h,000h,000h,000h,000h,000h,000h,000h,0FFh
           db 018h,018h,018h,018h,018h,018h,018h,018h,018h,018h     ; 0C2
           db 018h,018h,018h,018h,018h,018h,018h,018h,01Fh
           db 018h,018h,018h,018h,018h,018h,018h,018h,018h,018h     ; 0C3
           db 000h,000h,000h,000h,000h,000h,000h,000h,0FFh
           db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h     ; 0C4
           db 018h,018h,018h,018h,018h,018h,018h,018h,0FFh
           db 018h,018h,018h,018h,018h,018h,018h,018h,018h,018h     ; 0C5
           db 018h,018h,018h,018h,018h,018h,01Fh,018h,01Fh
           db 018h,018h,018h,018h,018h,018h,018h,018h,018h,018h     ; 0C6
           db 036h,036h,036h,036h,036h,036h,036h,036h,037h
           db 036h,036h,036h,036h,036h,036h,036h,036h,036h,036h     ; 0C7
           db 036h,036h,036h,036h,036h,036h,037h,030h,03Fh
           db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h     ; 0C8
           db 000h,000h,000h,000h,000h,000h,03Fh,030h,037h
           db 036h,036h,036h,036h,036h,036h,036h,036h,036h,036h     ; 0C9
           db 036h,036h,036h,036h,036h,036h,0F7h,000h,0FFh
           db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h     ; 0CA
           db 000h,000h,000h,000h,000h,000h,0FFh,000h,0F7h
           db 036h,036h,036h,036h,036h,036h,036h,036h,036h,036h     ; 0CB
           db 036h,036h,036h,036h,036h,036h,037h,030h,037h
           db 036h,036h,036h,036h,036h,036h,036h,036h,036h,036h     ; 0CC
           db 000h,000h,000h,000h,000h,000h,0FFh,000h,0FFh
           db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h     ; 0CD
           db 036h,036h,036h,036h,036h,036h,0F7h,000h,0F7h
           db 036h,036h,036h,036h,036h,036h,036h,036h,036h,036h     ; 0CE
           db 018h,018h,018h,018h,018h,018h,0FFh,000h,0FFh
           db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h     ; 0CF
           db 036h,036h,036h,036h,036h,036h,036h,036h,0FFh
           db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h     ; 0D0
           db 000h,000h,000h,000h,000h,000h,0FFh,000h,0FFh
           db 018h,018h,018h,018h,018h,018h,018h,018h,018h,018h     ; 0D1
           db 000h,000h,000h,000h,000h,000h,000h,000h,0FFh
           db 036h,036h,036h,036h,036h,036h,036h,036h,036h,036h     ; 0D2
           db 036h,036h,036h,036h,036h,036h,036h,036h,03Fh
           db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h     ; 0D3
           db 018h,018h,018h,018h,018h,018h,01Fh,018h,01Fh
           db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h     ; 0D4
           db 000h,000h,000h,000h,000h,000h,01Fh,018h,01Fh
           db 018h,018h,018h,018h,018h,018h,018h,018h,018h,018h     ; 0D5
           db 000h,000h,000h,000h,000h,000h,000h,000h,03Fh
           db 036h,036h,036h,036h,036h,036h,036h,036h,036h,036h     ; 0D6
           db 036h,036h,036h,036h,036h,036h,036h,036h,0FFh
           db 036h,036h,036h,036h,036h,036h,036h,036h,036h,036h     ; 0D7
           db 018h,018h,018h,018h,018h,018h,0FFh,018h,0FFh
           db 018h,018h,018h,018h,018h,018h,018h,018h,018h,018h     ; 0D8
           db 018h,018h,018h,018h,018h,018h,018h,018h,0F8h
           db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h     ; 0D9
           db 000h,000h,000h,000h,000h,000h,000h,000h,01Fh
           db 018h,018h,018h,018h,018h,018h,018h,018h,018h,018h     ; 0DA
           db 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
           db 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh     ; 0DB
           db 000h,000h,000h,000h,000h,000h,000h,000h,0FFh
           db 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh     ; 0DC
           db 0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h
           db 0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h     ; 0DD
           db 00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh
           db 00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh     ; 0DE
           db 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,000h
           db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h     ; 0DF
           db 000h,000h,000h,000h,000h,000h,0DCh,066h,066h
           db 066h,066h,066h,07Ch,060h,060h,0F0h,000h,000h,000h     ; 0E0
           db 000h,000h,000h,000h,000h,000h,07Ch,0C6h,0C0h
           db 0C0h,0C0h,0C6h,07Ch,000h,000h,000h,000h,000h,000h     ; 0E1
           db 000h,000h,000h,000h,000h,000h,07Eh,05Ah,018h
           db 018h,018h,018h,03Ch,000h,000h,000h,000h,000h,000h     ; 0E2
           db 000h,000h,000h,000h,000h,000h,0C6h,0C6h,0C6h
           db 0C6h,0C6h,07Eh,006h,006h,0C6h,07Ch,000h,000h,000h     ; 0E3
           db 000h,000h,000h,000h,000h,03Ch,018h,07Eh,0DBh
           db 0DBh,0DBh,0DBh,07Eh,018h,018h,03Ch,000h,000h,000h     ; 0E4
           db 000h,000h,000h,000h,000h,000h,0C6h,06Ch,038h
           db 038h,038h,06Ch,0C6h,000h,000h,000h,000h,000h,000h     ; 0E5
           db 000h,000h,000h,000h,000h,000h,0CCh,0CCh,0CCh
           db 0CCh,0CCh,0CCh,0FEh,006h,006h,000h,000h,000h,000h     ; 0E6
           db 000h,000h,000h,000h,000h,000h,0C6h,0C6h,0C6h
           db 0C6h,07Eh,006h,006h,000h,000h,000h,000h,000h,000h     ; 0E7
           db 000h,000h,000h,000h,000h,000h,0D6h,0D6h,0D6h
           db 0D6h,0D6h,0D6h,0FEh,000h,000h,000h,000h,000h,000h     ; 0E8
           db 000h,000h,000h,000h,000h,000h,0D6h,0D6h,0D6h
           db 0D6h,0D6h,0D6h,0FEh,003h,003h,000h,000h,000h,000h     ; 0E9
           db 000h,000h,000h,000h,000h,000h,0F8h,0B0h,030h
           db 03Eh,033h,033h,07Eh,000h,000h,000h,000h,000h,000h     ; 0EA
           db 000h,000h,000h,000h,000h,000h,0C6h,0C6h,0C6h
           db 0F6h,0DEh,0DEh,0F6h,000h,000h,000h,000h,000h,000h     ; 0EB
           db 000h,000h,000h,000h,000h,000h,0F0h,060h,060h
           db 07Ch,066h,066h,0FCh,000h,000h,000h,000h,000h,000h     ; 0EC
           db 000h,000h,000h,000h,000h,000h,03Ch,066h,006h
           db 01Eh,006h,066h,03Ch,000h,000h,000h,000h,000h,000h     ; 0ED
           db 000h,000h,000h,000h,000h,000h,0CEh,0DBh,0DBh
           db 0FBh,0DBh,0DBh,0CEh,000h,000h,000h,000h,000h,000h     ; 0EE
           db 000h,000h,000h,000h,000h,000h,07Eh,0CCh,0CCh
           db 0FCh,06Ch,0CCh,0CEh,000h,000h,000h,000h,000h,000h     ; 0EF
           db 000h,06Ch,000h,0FEh,066h,062h,068h,078h,068h
           db 060h,062h,066h,0FEh,000h,000h,000h,000h,000h,000h     ; 0F0
           db 000h,000h,000h,000h,06Ch,000h,07Ch,0C6h,0FEh
           db 0C0h,0C0h,0C6h,07Ch,000h,000h,000h,000h,000h,000h     ; 0F1
           db 000h,000h,000h,07Ch,0C6h,0C0h,0C8h,0F8h,0C8h
           db 0C0h,0C0h,0C6h,07Ch,000h,000h,000h,000h,000h,000h     ; 0F2
           db 000h,000h,000h,000h,000h,000h,03Ch,066h,060h
           db 078h,060h,066h,03Ch,000h,000h,000h,000h,000h,000h     ; 0F3
           db 000h,066h,000h,03Ch,018h,018h,018h,018h,018h
           db 018h,018h,018h,03Ch,000h,000h,000h,000h,000h,000h     ; 0F4
           db 000h,000h,000h,028h,028h,000h,038h,018h,018h
           db 018h,018h,018h,03Ch,000h,000h,000h,000h,000h,000h     ; 0F5
           db 000h,000h,000h,000h,000h,018h,018h,000h,07Eh
           db 000h,018h,018h,000h,000h,000h,000h,000h,000h,000h     ; 0F6
           db 000h,000h,000h,000h,000h,000h,076h,0DCh,000h
           db 076h,0DCh,000h,000h,000h,000h,000h,000h,000h,000h     ; 0F7
           db 000h,000h,038h,06Ch,06Ch,038h,000h,000h,000h
           db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h     ; 0F8
           db 000h,000h,000h,000h,000h,000h,000h,000h,018h
           db 018h,000h,000h,000h,000h,000h,000h,000h,000h,000h     ; 0F9
           db 000h,000h,000h,000h,000h,000h,000h,000h,000h
           db 018h,000h,000h,000h,000h,000h,000h,000h,000h,000h     ; 0FA
           db 000h,00Fh,00Ch,00Ch,00Ch,00Ch,00Ch,00Ch,00Ch
           db 00Ch,00Ch,0ECh,06Ch,03Ch,01Ch,000h,000h,000h,000h     ; 0FB
           db 000h,0D8h,06Ch,06Ch,06Ch,06Ch,06Ch,000h,000h
           db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h     ; 0FC
           db 000h,070h,0D8h,030h,060h,0C8h,0F8h,000h,000h
           db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h     ; 0FD
           db 000h,000h,000h,000h,000h,000h,03Ch,03Ch,03Ch
           db 03Ch,03Ch,03Ch,000h,000h,000h,000h,000h,000h,000h     ; 0FE
           db 000h,000h,000h,000h,000h,000h,000h,000h,000h
           db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h     ; 0FF

seg_a           ends



                end     start
