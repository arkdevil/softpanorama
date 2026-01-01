Print17 segment
        Assume CS:Print17,DS:Print17
        org 100h
Start:  jmp     Install

Save_17 dd      ?
Save_8  dd      ?
CFont   db      01h
Flag    db      00h
Step    dw      00h
Tab1    db      12H,1Bh,33h,1Fh,1Bh,54h        ;normal_6
Tab2    db      0Fh,1Bh,33h,1Fh,1Bh,54h        ;compress_6
Tab3    db      0Fh,1Bh,33h,0Fh,1Bh,53h,00h    ;small_7
TabEsc  db
        db      1bh,3ah,00h,00h,00h
        db      1bh,25h,01h,00
        db      1Bh,36h,1Bh,26h,00h,80h,0FFh
        db      088h,000h,002h,03Ch,042h,088h,000h,088h,042h,03Ch,002h,000h
        db      088h,000h,082h,07Ch,082h,010h,082h,010h,082h,050h,08Ch,000h
        db      088h,000h,082h,07Ch,082h,010h,082h,010h,082h,010h,06Ch,000h
        db      088h,000h,082h,07Ch,082h,000h,080h,000h,080h,040h,080h,000h
        db      088h,000h,003h,03Ch,042h,080h,002h,080h,042h,03Ch,003h,000h
        db      088h,000h,082h,07Ch,082h,010h,082h,010h,082h,044h,000h,000h
        db      088h,000h,0C6h,028h,000h,010h,0EEh,010h,000h,028h,0C6h,000h
        db      088h,000h,044h,082h,000h,092h,000h,092h,000h,092h,06Ch,000h
        db      088h,000h,082h,07Ch,082h,008h,010h,020h,082h,07Ch,082h,000h
        db      088h,000h,082h,07Ch,002h,088h,010h,0A0h,002h,07Ch,082h,000h
        db      088h,000h,082h,07Ch,082h,010h,000h,010h,0AAh,044h,082h,000h
        db      088h,000h,002h,000h,03Eh,040h,080h,000h,080h,000h,0FEh,000h
        db      088h,000h,082h,07Ch,082h,040h,020h,040h,082h,07Ch,082h,000h
        db      088h,000h,082h,07Ch,082h,010h,000h,010h,082h,07Ch,082h,000h
        db      088h,000h,038h,044h,082h,000h,082h,000h,082h,044h,038h,000h
        db      088h,000h,082h,07Ch,082h,000h,080h,000h,082h,07Ch,082h,000h
        db      088h,000h,082h,07Ch,082h,010h,080h,010h,080h,010h,060h,000h
        db      088h,000h,038h,044h,082h,000h,082h,000h,082h,044h,000h,000h
        db      088h,000h,0C0h,000h,080h,002h,0FCh,002h,080h,000h,0C0h,000h
        db      088h,000h,080h,072h,088h,002h,008h,002h,008h,002h,0FCh,000h
        db      088h,000h,070h,088h,000h,08Ah,074h,08Ah,000h,088h,070h,000h
        db      088h,000h,082h,044h,0AAh,010h,000h,010h,0AAh,044h,082h,000h
        db      088h,000h,082h,07Ch,082h,000h,002h,000h,082h,0FCh,083h,000h
        db      088h,000h,080h,078h,080h,008h,000h,008h,082h,07Eh,082h,000h
        db      088h,000h,0FEh,000h,002h,000h,0FEh,000h,002h,000h,0FEh,000h
        db      088h,000h,0FEh,000h,002h,000h,0FEh,000h,002h,000h,0FFh,000h
        db      088h,000h,080h,000h,0FEh,000h,012h,000h,012h,000h,00Ch,000h
        db      088h,000h,0FEh,000h,012h,000h,012h,00Ch,000h,000h,0FEh,000h
        db      088h,000h,000h,0FEh,000h,012h,000h,012h,000h,012h,00Ch,000h
        db      088h,000h,082h,000h,092h,000h,092h,000h,092h,044h,038h,000h
        db      088h,000h,0FEh,000h,010h,000h,07Ch,082h,000h,082h,07Ch,000h
        db      088h,000h,002h,060h,084h,010h,088h,010h,082h,07Ch,082h,000h
        db      088h,000h,000h,004h,00Ah,020h,00Ah,020h,00Ah,020h,01Eh,000h
        db      088h,000h,01Ch,022h,000h,052h,000h,052h,000h,052h,08Ch,000h
        db      088h,000h,022h,01Ch,022h,008h,022h,008h,022h,008h,014h,000h
        db      088h,000h,000h,03Eh,000h,020h,000h,020h,000h,020h,000h,000h
        db      088h,000h,003h,004h,00Ah,010h,002h,020h,002h,03Ch,003h,000h
        db      088h,000h,01Ch,022h,004h,022h,008h,022h,008h,022h,010h,000h
        db      088h,000h,022h,014h,000h,008h,036h,008h,000h,014h,022h,000h
        db      088h,000h,014h,022h,000h,022h,000h,02Ah,000h,02Ah,014h,000h
        db      088h,000h,03Eh,000h,004h,000h,008h,000h,010h,000h,03Eh,000h
        db      088h,000h,03Eh,000h,004h,040h,008h,040h,010h,000h,03Eh,000h
        db      088h,000h,000h,03Eh,000h,008h,000h,008h,014h,000h,022h,000h
        db      088h,000h,000h,002h,004h,008h,010h,000h,020h,000h,03Eh,000h
        db      088h,000h,03Eh,020h,010h,008h,004h,008h,010h,020h,03Eh,000h
        db      088h,000h,03Eh,000h,008h,000h,008h,000h,008h,000h,03Eh,000h
        db      088h,000h,008h,014h,022h,000h,022h,000h,022h,014h,008h,000h
        db      088h,000h,03Eh,000h,020h,000h,020h,000h,020h,000h,03Eh,000h
        db      08Ah,0AAh,000h,000h,000h,0AAh,000h,000h,000h,0AAh,000h,000h
        db      08Ah,0AAh,000h,055h,000h,0AAh,000h,055h,000h,0AAh,000h,000h
        db      08Ah,0AAh,055h,000h,0AAh,055h,000h,0AAh,055h,000h,000h,000h
        db      08Ah,000h,000h,000h,000h,000h,0FFh,000h,000h,000h,000h,000h
        db      08Ah,000h,010h,000h,010h,000h,0FFh,000h,000h,000h,000h,000h
        db      08Ah,000h,018h,000h,018h,000h,0FFh,000h,000h,000h,000h,000h
        db      08Ah,010h,000h,010h,000h,0FFh,000h,0FFh,000h,000h,000h,000h
        db      08Ah,010h,000h,010h,000h,01Fh,000h,01Fh,000h,000h,000h,000h
        db      08Ah,000h,018h,000h,018h,000h,01Fh,000h,000h,000h,000h,000h
        db      08Ah,018h,000h,018h,000h,0FFh,000h,0FFh,000h,000h,000h,000h
        db      08Ah,000h,000h,000h,000h,0FFh,000h,0FFh,000h,000h,000h,000h
        db      08Ah,018h,000h,018h,000h,01Fh,000h,01Fh,000h,000h,000h,000h
        db      08Ah,018h,000h,018h,000h,0F8h,000h,0F8h,000h,000h,000h,000h
        db      08Ah,010h,000h,010h,000h,0F0h,000h,0F0h,000h,000h,000h,000h
        db      08Ah,000h,018h,000h,018h,000h,0F8h,000h,000h,000h,000h,000h
        db      08Ah,000h,010h,000h,010h,000h,01Fh,000h,000h,000h,000h,000h
        db      08Ah,000h,000h,000h,000h,000h,0F0h,000h,010h,000h,010h,000h
        db      08Ah,000h,010h,000h,010h,000h,0F0h,000h,010h,000h,010h,000h
        db      08Ah,000h,010h,000h,010h,000h,01Fh,000h,010h,000h,010h,000h
        db      08Ah,000h,000h,000h,000h,000h,0FFh,000h,010h,000h,010h,000h
        db      08Ah,010h,000h,010h,000h,010h,000h,010h,000h,010h,000h,010h
        db      08Ah,000h,010h,000h,010h,000h,0FFh,000h,010h,000h,010h,000h
        db      08Ah,000h,000h,000h,000h,000h,0FFh,000h,018h,000h,018h,000h
        db      08Ah,000h,000h,000h,000h,0FFh,000h,0FFh,000h,010h,000h,010h
        db      08Ah,000h,000h,000h,000h,0F8h,000h,0F8h,000h,018h,000h,018h
        db      08Ah,000h,000h,000h,000h,01Fh,000h,01Fh,000h,018h,000h,018h
        db      08Ah,018h,000h,018h,000h,0F8h,000h,0F8h,000h,018h,000h,018h
        db      08Ah,018h,000h,018h,000h,01Fh,000h,01Fh,000h,018h,000h,018h
        db      08Ah,000h,000h,000h,000h,0FFh,000h,0FFh,000h,018h,000h,018h
        db      08Ah,018h,000h,018h,000h,018h,000h,018h,000h,018h,000h,018h
        db      08Ah,018h,000h,018h,000h,0FFh,000h,0FFh,000h,018h,000h,018h
        db      08Ah,018h,000h,018h,000h,018h,0E0h,018h,000h,018h,000h,018h
        db      08Ah,010h,000h,010h,000h,0F0h,000h,0F0h,000h,010h,000h,010h
        db      08Ah,018h,000h,018h,000h,018h,007h,018h,000h,018h,000h,018h
        db      08Ah,010h,000h,010h,000h,01Fh,000h,01Fh,000h,010h,000h,010h
        db      08Ah,000h,000h,000h,000h,0F0h,000h,0F0h,000h,010h,000h,010h
        db      08Ah,000h,000h,000h,000h,000h,0F8h,000h,018h,000h,018h,000h
        db      08Ah,000h,000h,000h,000h,000h,01Fh,000h,018h,000h,018h,000h
        db      08Ah,000h,000h,000h,000h,01Fh,000h,01Fh,000h,010h,000h,010h
        db      08Ah,020h,000h,020h,000h,0FFh,000h,0FFh,000h,020h,000h,020h
        db      08Ah,000h,018h,000h,018h,000h,0FFh,000h,018h,000h,018h,000h
        db      08Ah,000h,010h,000h,010h,000h,0F0h,000h,000h,000h,000h,000h
        db      088h,000h,000h,000h,000h,000h,01Fh,000h,010h,000h,010h,000h
        db      08Ah,0FFh,000h,0FFh,000h,0FFh,000h,0FFh,000h,0FFh,000h,0FFh
        db      08Ah,00Fh,000h,00Fh,000h,00Fh,000h,00Fh,000h,00Fh,000h,00Fh
        db      08Ah,0FFh,000h,0FFh,000h,0FFh,000h,000h,000h,000h,000h,000h
        db      08Ah,000h,000h,000h,000h,000h,000h,0FFh,000h,0FFh,000h,0FFh
        db      08Bh,0F0h,000h,0F0h,000h,0F0h,000h,0F0h,000h,0F0h,000h,0F0h
        db      088h,000h,021h,01Eh,021h,004h,020h,004h,020h,004h,018h,000h
        db      088h,000h,008h,014h,000h,022h,000h,022h,000h,022h,000h,000h
        db      088h,000h,020h,000h,020h,000h,03Eh,000h,020h,000h,020h,000h
        db      088h,000h,038h,004h,001h,004h,001h,004h,001h,03Eh,000h,000h
        db      088h,000h,018h,024h,000h,024h,01Bh,024h,000h,024h,018h,000h
        db      088h,000h,022h,014h,000h,008h,000h,008h,000h,014h,022h,000h
        db      088h,000h,03Eh,000h,002h,000h,002h,000h,002h,03Ch,003h,000h
        db      088h,000h,000h,030h,008h,000h,008h,000h,008h,000h,03Eh,000h
        db      088h,000h,03Eh,000h,002h,000h,03Eh,000h,002h,000h,03Eh,000h
        db      088h,000h,03Eh,000h,002h,000h,03Eh,000h,002h,000h,03Fh,000h
        db      088h,000h,020h,000h,03Eh,000h,00Ah,000h,00Ah,000h,004h,000h
        db      088h,000h,03Eh,000h,00Ah,000h,00Ah,004h,000h,000h,03Eh,000h
        db      088h,000h,03Eh,000h,00Ah,000h,00Ah,000h,00Ah,004h,000h,000h
        db      088h,000h,000h,022h,008h,022h,008h,022h,008h,022h,01Ch,000h
        db      088h,000h,03Eh,000h,008h,000h,01Ch,022h,000h,022h,01Ch,000h
        db      088h,000h,000h,012h,028h,004h,028h,000h,028h,000h,03Eh,000h
        db      088h,000h,042h,03Ch,0C2h,010h,042h,010h,0C2h,024h,000h,000h
        db      088h,000h,01Ch,022h,084h,022h,008h,022h,088h,022h,010h,000h
        db      08Ah,000h,000h,000h,000h,000h,001h,002h,004h,008h,000h,000h
        db      08Ah,000h,000h,008h,004h,002h,001h,000h,000h,000h,000h,000h
        db      08Ah,000h,000h,010h,020h,040h,080h,000h,000h,000h,000h,000h
        db      08Ah,000h,000h,000h,000h,000h,080h,040h,020h,010h,000h,000h
        db      08Ah,000h,010h,000h,010h,000h,010h,000h,054h,028h,010h,000h
        db      08Ah,000h,010h,028h,054h,000h,010h,000h,010h,000h,010h,000h
        db      08Ah,000h,000h,000h,020h,040h,0BEh,040h,020h,000h,000h,000h
        db      08Ah,000h,000h,000h,004h,002h,07Dh,002h,004h,000h,000h,000h
        db      08Ah,000h,010h,000h,010h,0D6h,010h,000h,0D6h,000h,010h,000h
        db      08Ah,000h,022h,000h,022h,000h,0FAh,000h,022h,000h,022h,000h
        db      08Ah,0FEh,000h,020h,010h,008h,000h,0FEh,000h,000h,0B0h,0B0h
        db      08Ah,000h,092h,028h,044h,000h,044h,000h,044h,028h,092h,000h
        db      08Ah,000h,000h,000h,038h,000h,038h,000h,038h,000h,000h,000h
        db      088h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h

Init    proc    far
        mov     CS:Flag,01h

        push    AX
        mov     AH, CS:CFont
        cmp     AH, 1
        jne     LL1_1
        mov     BX,offset Tab1
        mov     CX,6h
        jmp     LL1_3
LL1_1:
        cmp     AH, 2
        jne     LL1_2
        mov     BX,offset Tab2
        mov     CX,6h
        jmp     LL1_3
LL1_2:
        cmp     AH, 3
        jne     LL1_3
        mov     BX,offset Tab3
        mov     CX,7h
LL1_3:
        pop     AX
Loop2:  mov     AL,CS:[BX]
        push    AX DX
        pushf
        call    CS:Save_17
        pop     DX AX
        inc     BX
        loop    Loop2

        mov     BX,offset TabEsc
        mov     CX,611h
Loop1:  mov     AL,CS:[BX]
        push    AX DX
        pushf
        call    CS:Save_17
        pop     DX AX
        inc     BX
        loop    Loop1
        ret
Init    endp

        assume  DS:nothing
;-----------------------------------------------------------
Here17:
        push    BX CX DX DS AX
        cmp     AX,02FFh
        jne     prr
        mov     CS:CFont,BH
        mov     CS:Flag,00h
        pop     AX DS DX CX BX
        mov     AX,0FF02h
        iret

prr:    cmp     AH,00h
        jne     Pr
        cmp     CS:Flag,00h
        jne     Pr
        call    Init
pr:
        pop     AX DS DX CX BX
        jmp     CS:Save_17
;-----------------------------------------------------------
Here8:
        push    AX DX DS
        inc     CS:Step
        cmp     CS:Step,07h
        jne     Label1
        mov     CS:Step,0
        mov     AH,02h
        mov     DX,00h
        pushf
        call    CS:Save_17
        test    AH,0F0h
        jne     Label1
        test    AH,10h
        jne     Label1
        mov     CS:Flag,00h
Label1: pop     DS DX AX
        jmp     CS:Save_8
Top     label word
;-------------------------------------------------------------
Install:
        assume  DS:Print17
        mov     DX,offset Lab$
        mov     AH,09H
        int     21h
        mov     BX, 81h
        mov     CX, 7Fh
L1:
        mov     DL, byte ptr ES:[BX]
        inc     BX
        cmp     DL, 13                 ;DL = конец строки ?
        jne     LC0
        mov     DX,offset Help$
        mov     AH,09H
        int     21h
        mov     AX,4C00h
        int     21h

LC0:    cmp     DL, 'n'                ;DL = 'N'
        je      L_1
        cmp     DL, 'N'
        jne     LC1
L_1:    mov     AH,1
        mov     DX,offset FontN$
        jmp     LOK
LC1:
        cmp     DL, 's'                ;DL = 'S'
        je      L_2
        cmp     DL, 'S'
        jne     LC2
L_2:    mov     AH,3
        mov     DX,offset FontS$
        jmp     LOK
LC2:
        cmp     DL, 'c'                ;DL = 'C'
        je      L_3
        cmp     DL, 'C'
        jne     LC3
L_3:    mov     AH,2
        mov     DX,offset FontC$
        jmp     LOK
LC3:
        loop    L1
LOK:
        mov     CFont,AH
        mov     BH,AH
        mov     AH,09H
        int     21h

        mov     AX,02FFh               ;уже в памяти?
        int     17h
        cmp     AX,0FF02h
        jne     Cont                   ;есть в памяти
        mov     AX,4C00h
        int     21h

Cont:   mov     AX,3517h               ;нет в памяти
        int     21h
        mov     word ptr Save_17,BX
        mov     word ptr Save_17+2,ES
        mov     DX,offset Here17
        mov     AX,2517h
        int     21h

        mov     AX,3508h
        int     21h
        mov     word ptr Save_8,BX
        mov     word ptr Save_8+2,ES
        mov     DX,offset Here8
        mov     AX,2508h
        int     21h
        mov     DX,offset Top
        int     27h

Lab$    db      'PrnLoad  V 2.51  (C) 1990,1991 Trouble Pro ,  by V.Tsing',13,10
        db      'Print Font Loader - print utility',13,10,13,10,'$'
Help$   db      ' Use : PrnLoad  <mode>',13,10
        db      '  where  <mode> is :',13,10
        db      '     N - normal font',13,10
        db      '     S - small font',13,10
        db      '     C - compress font',13,10
        db      '$'
FontN$  db      ' Current font is ''normal''',13,10,'$'
FontC$  db      ' Current font is ''compress''',13,10,'$'
FontS$  db      ' Current font is ''small''',13,10,'$'
Print17 ends
        end start
Print17 ends
        end start
