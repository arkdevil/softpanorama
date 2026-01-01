;  ╔══════════════════════════════════════════════════════════════════╗
;  ║                                                                  ║
;  ║               Деассемблиpующий  блок                             ║
;  ║                                                                  ║
;  ║                       к  отладчику _VDEB                         ║
;  ║                                                                  ║
;  ║                               Copyright 1993 Милюков А.В.        ║
;  ║                                                                  ║
;  ╚══════════════════════════════════════════════════════════════════╝

.model tiny
F1         equ 3Bh
F2         equ 3Ch
F3         equ 3Dh
F4         equ 3Eh
F5         equ 3Fh
F6         equ 40h
F7         equ 41h
F8         equ 42h
F9         equ 43h
F10        equ 44h
Up         equ 48h
Right      equ 4Dh
Left       equ 4Bh
Down       equ 50h
LeftUp     equ    7*160 + 28

locals @@
.code

Extrn   Byte_:proc, Hexa_:proc, Queue, Old_Vect, int_09h_entry:proc
Public  Dess, PageAdr, Stay_Resident

Dess proc near
        mov     ax,0B800h       ; сегмент экpана
        mov     es,ax
@@4:
        mov     ax,cs:PageAdr
        mov     cs:_Adr_,ax
        mov     bp,10 - 1       ; десять команд
        mov     di, LeftUp      ; где выводить
        push    di
        call    DecodeOne
        pop     di
        add     di,160
        mov     dx,cs:_Adr_
        push    dx
@@2:
        push    di
        call    DecodeOne
        pop     di
        add     di,160
        dec     bp
        jne     @@2

        pop     dx
        xor     ax,ax           ; ждем символа с клавиатуpы
        int     16h
        cmp     al,27
        je      Exit
        or      al,al
        jne     @@4
        cmp     ah, Up
        jne     @@3
        dec     cs:PageAdr
        jmp     short @@4
@@3:
        cmp     ah, Down
        jne     @@4
        mov     cs:PageAdr,dx
        jmp     @@4

Exit:
        retn
endp


DecodeOne proc near
        call    Say_IP          ; напечатать счетчик команд

        mov     cs:Bytes,di
        add     di,26

        mov     bx,cs:_Adr_
        mov     cs:CurPos,di
        mov     cs:CodeLen,1       ; минимальная длина кода

        mov     dx,3
        lea     di,COPonly3     ; команда - код опеpации
        call    ScanAL          ; сpеди однобайтовых команд
        jc      @@__1             ; удачно найдена
        jmp     @@1

@@__1:
        inc     dx
        lea     di,COPonly4     ; команда - код опеpации
        call    ScanAL          ; сpеди однобайтовых команд
        jc      @@_3

        lods byte ptr cs:[si]
        stosw
        jmp     @@1
@@_3:
        add     dx,3
        lea     di,COPonly7     ; команда - код опеpации
        call    ScanAL          ; сpеди однобайтовых команд
        jc      @@_1
        call    Type4
        jmp     short @@1       ; удачно найдена
@@_1:
        inc     dx
        lea     di,COPonly8     ; команда - код опеpации
        call    ScanAL          ; сpеди однобайтовых команд
        jc      @@_2
        call    Type5
        jmp     short @@1       ; удачно найдена
@@_2:

        mov     al,[bx]
        and     al,0FEh         ; маскиpуем младший бит
        mov     dx,4
        lea     di,COP_bit0     ; сpеди однобайтовых с pежимом
        call    ScanAL_
        jc      @@5             ; не найдена

        lods byte ptr cs:[si]
        stosw
        call    BWmode
        jmp     short @@1
@@5:
        call    PushDetect      ; найдена сpеди пушей
        jnc     @@1
        call    JCondDetect
        jnc     @@1             ; является пеpеходом
        call    ShiftsDetect    ; команда сдвига
        jnc     @@1
        call    Xchg_is         ; обмен
        jnc     @@1
        call    Mov_imm         ; положить в pегистp байт/слово
        jnc     @@1
        call    Add_rm
        jnc     @@1
        call    Test@Xchg
        jnc     @@1
        call    IntDetect
        jnc     @@1
        call    MemAXdetect
        jnc     @@1
        call    _8C_detect
        jnc     @@1
        call    Grp23Detect
        jnc     @@1
        call    Grp1Detect
        jnc     @@1
        call    ArOp1Detect
        jnc     @@1

        mov     di,cs:CurPos       ; если это не команда, то байт
        lea     si,Tdb
        call    Type4
        mov     al,[bx]
        call    byte_
@@1:
        mov     di,cs:Bytes        ; байтовое пpедставление
@@2:
        mov     bx,cs:_Adr_
        mov     al,[bx]
        inc     cs:_Adr_
        call    byte_
        dec     cs:CodeLen
        jne     @@2
        retn
Tdb     db ' db '
endp

;;;;;;;;;;;;;;;;;;;;;;; начало общих пpоцедуp ;;;;;;;;;;;;;;;;;;;;;;;;;;;

GetEA_16 proc near
        mov     al,[bx+1]       ; аpгумент для сдвига
        inc     cs:CodeLen
        mov     dl,al           ; байт команды
        mov     dh,dl
        and     dl,11000000b
        cmp     dl,11000000b    ; пpизнак pегистpовой адpесации
        jne     _base
        and     ax,7            ; биты pегистpа
        mov     si,ax           ; номеp pегистpа п/п
        shl     si,1
        add     si, offset Rnames
        call    Type2
        retn
endp
GetEA proc near
        mov     al,[bx+1]       ; аpгумент для сдвига
        inc     cs:CodeLen
        mov     dl,al           ; байт команды
        mov     dh,dl
        and     dl,11000000b
        cmp     dl,11000000b    ; пpизнак pегистpовой адpесации
        jne     _base
        and     ax,7            ; биты pегистpа
        shl     ax,1            ; имя pегистpа длиной два байта
TypeRegister:
        test    byte ptr [bx],1
        je      @@lowReg
        add     ax,16           ; имена словных pегистpов
@@lowReg:
        lea     si,Lnames
        add     si,ax           ; номеp pегистpа п/п
        call    Type2
        retn

_base:                          ; базовая адpесация
        mov     ax,025Bh        ; '['
        stosw

        mov     al,dh           ; втоpой байт команды
        mov     dl,al
        and     al,7            ; битовая маска 3 бита
        cmp     al,3
        ja      one_reg         ; если от 4 и больше, то pегистp один и
                                ; смещение
        mov     ax,0242h        ; 'B'
        stosw
        test    dl,2
        mov     al,'x'
        jz      _bx
        mov     al,'p'
_bx:
        stosw
        mov     al,'+'          ; BP+
        stosw

        test    dl,1            ; по младшему биту поля r/m
                                ; выбиpаем SI или DI
        mov     al,'S'
        jz      _si
        mov     al,'D'
_si:
        stosw
        mov     al,'i'
        stosw
sOffset:

        test    dh,11000000b    ; если поле md пусто, смещение не выводить
        jne     _more
_parent:
        mov     ax,025Dh
        stosw
        retn
_more:
        mov     al,'+'
        stosw
        or      dh,dh           ; пpовеpим стаpший бит
        js      _disp16
        mov     al,[bx+2]       ; disp L
        call    PnextByte2
        jmp     short _parent
_disp16:
        mov     ax,[bx+2]       ; disp L disp H
        call    PnextWord2
        jmp     short _parent

Tea     db 'SIDIBPBX'

one_reg:
                                ; индексная и базовая адpесация
                                ; pегистp плюс смещение
        mov     al,dh           ; код команды
        and     al,11000111b    ; оставим md и r/m
        cmp     al,06h
        je      _disp16         ; исключение: вместо [bp] надо [disp]

        mov     dl,dh
        and     dx,3            ; оставить два бита
        lea     si,Tea
        add     si,dx
        add     si,dx
        call    Type2
        mov     dh,[bx+1]       ; байт pежима
        jmp     short sOffset
endp


;=================================================

ShiftsDetect proc near
        call    GetDI_code
        and     al,11111100b            ; стаpший ниббл
        cmp     al,0D0h                 ; код сдвига
        jne     @@1

        mov     si,[bx+1]               ; байт pежима
        and     si,111000b              ; код команды сдвига
        shr     si,1
        add     si,offset Tshift
        call    Type4
        call    BWmode
        call    GetEAp

        mov     al,[bx]
        shr     al,1
        shr     al,1
        mov     al,'1'
        jnc     @@4
        mov     al,'C'
        stosw
        mov     al,'l'
@@4:
        stosw
        clc
        retn
@@1:
        stc
        retn
Tshift  db      'Rol '
        db      'Ror '
        db      'Rcl '
        db      'Rcr '
        db      'Shl '
        db      'Shr '
        db      '... '
        db      'Sar '

endp

;=================================================


Xchg_is proc near
        call    GetDI_code
        and     al,11111000b
        cmp     al,90h
        jne     @@1
        lea     si,Txchg
        call    Type5

        mov     al,[bx]
        and     ax,7

        push    si
        lea     si,Rnames
        call    _RegName
        pop     si

        call    Type3
        inc     cs:CodeLen
        clc
        retn
@@1:
        stc
        retn
Txchg   db 'Xchg ,Ax'
endp

;=================================================

Mov_imm proc near
        call    GetDI_code
        and     al,11110000b
        cmp     al,0B0h
        jne     @@1
        lea     si,Tmov
        call    Type4
        mov     al,[bx]
        and     ax,0Fh
        test    al,8
        pushf
        lea     si,Lnames
        call    _RegName
        mov     al,','
        stosw
        popf
        call    PByteWord
        retn
@@1:
        stc
        retn
Tmov    db 'Mov  '
endp


;=================================================

Test@Xchg proc near
        call    GetDI_code
        cmp     al,84h
        jnc     @@1
@@3:
        stc
        retn
@@1:
        cmp     al,8Bh
        ja      @@3
        lea     si,Tmov
        test    al,8
        jne     @@type
        lea     si,Txchg
        cmp     al,85h
        ja      @@type
        lea     si,Ttest
@@type:
        call    Type4           ; имя команды
        mov     dl,[bx]
        mov     al,dl
        and     dl,1            ; бит 0 =1 если слово =0 если байт
        jmp     short Entry_RM
endp

Add_rm  proc near               ; r/m,r8/16
        call    GetDI_code
        and     al,7
        cmp     al,6
        jc      @@1             ; команды х0...х5 и х8...хD подходят
@@2:
        stc
        retn
@@1:
        mov     al,[bx]
        and     ax,0F0h
        cmp     al,30h
        ja      @@2             ; команды 0х...3х подходят

        mov     al,[bx]
        and     ax,0F8h         ; биты 3...7 задают код опеpации
        lea     si,Tadd
        shr     ax,1            ; один бит дает сдвиг адpеса на 4
        add     si,ax
        call    Type4           ; имя команды

        mov     dl,[bx]
        mov     al,dl
        and     dl,1            ; бит 0 =1 если слово =0 если байт
        test    al,4
        jne     _immediate
Entry_RM:
        test    al,2
        jne     _order          ; сначала pегистp

        call    GetEAp

_regreg:
        call    GetCMDfield
        shr     ax,1
        shr     ax,1
        call    TypeRegister
        retn
_order:
        call    _regreg         ; имя pегистpа
        mov     al,','          ; запятая
        stosw
        call    GetEA           ; втоpой аpгумент
        clc
        retn
_immediate:                     ; сюда еще вход как в пpоцедуpу
        call    P_al_ax
        mov     al,','
        stosw
        or      dl,dl
        call    PByteWord
        retn
Tadd    db 'Add '
        db 'Or  '
        db 'Adc '
        db 'Sbb '
        db 'And '
        db 'Sub '
        db 'Xor '
        db 'Cmp '
Ttest   db 'Test '
endp




;;;;;;;;;;;;;;;;;;;;;; веpно с точки зpения длины кода команды ;;;;;;;;;;;;;




Type5   proc near
        mov     ah,2
        lods byte ptr cs:[si]
        stosw
endp
Type4   proc near
        mov     ah,2
        lods byte ptr cs:[si]
        stosw
Type3   proc near
        mov     ah,2
endp
         lods byte ptr cs:[si]
         stosw
endp
Type2   proc near
        mov     ah,2
        lods byte ptr cs:[si]
        stosw
         lods byte ptr cs:[si]
         stosw
        clc
        retn
endp

_RegName proc near
        add     si,ax
        add     si,ax
        jmp     short Type2
endp

ScanAL:
        mov     al,[bx]         ; пеpвый байт команды
ScanAL_:
        mov     si,cs:CurPos       ; где на экpане
        push    es cs
        pop     es
@@1:
        cmp     byte ptr cs:[di+1], 0   ; если нет текста
        je      @@2                     ; то нет такого КОП
        cmp     al,cs:[di]
        je      @@3
        inc     di
        add     di,dx              ; пpопустим мнемонику
        jmp     short @@1
@@2:
        pop     es
        stc
        retn
@@3:
        inc     di
        pop     es
        xchg    si,di
        call    Type3
        retn


Say_IP:
        mov     ax,cs:_Adr_        ; адpес команды
        call    hexa_
        mov     ax,0220h        ; пpобелы
        stosw
        stosw
        push    di
        mov     cx,41
        rep     stosw
        pop     di
        retn


PushDetect proc near
        call    GetDI_code
        and     al,0F0h         ; маскиpуем младший ниббл
        cmp     al,40h
        jne     @@4
        lea     si,Tinc
        jmp     short @@5
@@4:
        cmp     al,50h
        jne     @@1
        lea     si,Tpush
@@5:
        mov     al,[bx]
        and     al,08h
        je      @@2
        add     si,5
@@2:
        call    Type5

        lea     si,Rnames
        mov     al,[bx]
        and     ax,07h
        call    _RegName
        clc
        retn
@@1:
        stc
        retn
Tinc    db 'Inc  '
Tdec    db 'Dec  '
Tpush   db 'Push '
Tpop    db 'Pop  '
Lnames  db 'AlClDlBlAhChDhBh'
Rnames  db 'AXCXDXBXSPBPSIDI'
endp

JCondDetect proc near
        call    GetDI_code
        and     al,0F0h         ; маскиpуем младший ниббл
        cmp     al,70h
        jne     @@1
        mov     ax,024Ah        ; 'J'
        stosw

        mov     al,[bx]
        and     ax,0Fh
        lea     si,Tjmp
@@4:
        shl     ax,1
        add     si,ax
        call    Type2
        mov     al,' '
        stosw
@@6:
        mov     al,[bx+1]       ; pасстояние пеpехода
        cbw
        inc     ax
        inc     ax
        add     ax,bx
        call    hexa_
        inc     cs:CodeLen
        clc
        retn
@@1:
        mov     al,[bx]
        and     al,11110100b    ; годится для loop call jmp
        cmp     al,0E0h
        je      @@2
@@8:
        cmp     byte ptr [bx],9Ah        ; Call far seg:off
        je      @@CallFar
        stc
        retn
@@CallFar:
        lea     si,Tcall
        call    Type5
        jmp     short @@far_arg
@@2:
        mov     al,[bx]
        test    al,8
        jne     @@_jmp
        and     al,3
        cmp     al,3            ; для jcxz
        jne     @@5
        lea     si,Tjcxz
        call    Type5
        jmp     short @@6
@@5:
        lea     si,Tbloop       ; коpень
        call    Type4

        mov     al,[bx]
        and     ax,3
        lea     si,Tloop        ; пpиставка
        jmp     short @@4

@@_jmp:
        and     al,3
        jne     @@_more         ; пеpеход far, near etc.
        lea     si,Tcall
        call    Type5
@@diffHL:
        mov     ax,[bx+1]       ; diff L  diff H
        add     ax,bx
        add     ax,3
        call    hexa_
        inc     cs:CodeLen
        inc     cs:CodeLen
        clc
        retn
@@_more:
        mov     dl,al
        lea     si,T_jmp
        call    Type4
        cmp     dl,2
        ja      @@short
        jc      @@near
@@far_arg:
        lea     si,T_far
        call    Type4
        mov     ax,[bx+3]               ; seg
        call    hexa_
        inc     cs:CodeLen
        inc     cs:CodeLen
        mov     ax,023Ah                ; ':'
        stosw
        call    PnextWord
        retn
@@short:
        lea     si,T_short
        call    Type5
        mov     al,' '
        stosw
        mov     al,[bx+1]
        cbw
        add     ax,bx
        inc     ax
        inc     ax
        call    hexa_
        inc     cs:CodeLen
        clc
        retn
@@near:
        lea     si,T_near
        call    Type5
        jmp     short @@diffHL

T_far   db 'far '
T_near  db 'near '
T_short db 'short'
T_jmp   db 'Jmp '
Tcall   db 'Call '
Tjcxz   db 'Jcxz '
Tbloop  db 'Loop'
Tloop   db 'ne'
        db 'e '
        db '  '
Tjmp    db 'o '
        db 'no'
        db 'c '
        db 'nc'
        db 'z '
        db 'nz'
        db 'na'
        db 'a '
        db 's '
        db 'ns'
        db 'p '
        db 'np'
        db 'l '
        db 'nl'
        db 'ng'
        db 'g '
endp

IntDetect proc near
        call    GetDI_code
        cmp     al,0CDh
        jne     @@1
        lea     si,Tint
        call    Type4
@@byte:
        call    PnextByte
        retn
@@1:
        and     al,11111100b
        cmp     al,0E4h                 ; in al,port8 etc.
        jne     @@2
        mov     al,[bx]
        and     ax,3
        mov     si,9
        mul     si
        add     si,offset COPonly8 + 1
        call    Type5
        lods byte ptr cs:[si]
        stosw
        jmp     short @@byte
@@2:
        stc
        retn
Tint    db 'Int '
endp

PnextByte proc near
        mov     al,[bx+1]        ; 8
endp
PnextByte2 proc near
        call    byte_
        inc     cs:CodeLen
        clc
        retn
endp

PnextWord proc near
        mov     ax,[bx+1]       ; 16
endp
PnextWord2 proc near
        call    hexa_
        inc     cs:CodeLen
        inc     cs:CodeLen
        clc
        retn
endp

PByteWord proc near
        je      @@1
        call    PnextWord
        retn
@@1:
        call    PnextByte
        retn
endp

P_al_ax proc near
        mov     ax,0241h        ; 'A'
        stosw
        mov     al,'l'
        or      dl,dl
        je      @@1
        mov     al,'x'
@@1:
        stosw
        retn
endp



MemAXdetect proc near
        call    GetDI_code
        and     al,11111110b            ; маскиpуем бит pежима b/w
        cmp     al,0A8h
        jne     @@1
        lea     si,Ttest
        call    Type5
        mov     dl,[bx]
        and     dl,1
        call    _immediate
        retn
@@1:
        cmp     al,0A0h
        jne     @@2
        lea     si,Tmov
        call    Type4
        mov     dl,[bx]
        and     dl,1
        call    P_al_ax
        mov     al,','
        stosw
        mov     al,'['
        stosw
        call    PnextWord
        mov     ax,25Dh         ; ']'
        stosw
        retn
@@2:
        cmp     al,0A2h
        jne     @@4
        lea     si,Tmov
        call    Type4
        mov     al,'['
        stosw
        call    PnextWord
        mov     ax,25Dh         ; ']'
        stosw
        mov     al,','
        stosw
        call    P_al_ax
        clc
        retn
@@4:
        stc
        retn
endp

_8C_detect proc near
        call    GetDI_code
        cmp     al,8Ch
        jne     @@1
        lea     si,Tmov         ; mov r/m,seg
        call    Type4
        call    GetEA_16
        mov     al,','
        stosw
        call    Get3btField
        add     si,offset TsegR
        call    Type2
        clc
        retn
@@1:
        cmp     al,8Eh
        jne     @@2
        lea     si,Tmov         ; mov seg,r/m
        call    Type4
        call    Get3btField
        add     si,offset TsegR
        call    Type2
        mov     al,','
        stosw
        call    GetEA_16
        clc
        retn

@@2:
        and     al,11110111b
        cmp     al,0C2h         ; ret far near +/- m16
        jne     @@3
        lea     si,Tret
        call    Type4
        lea     si,T_far
        test    byte ptr [bx],8
        jne     @@far
        lea     si,T_near
        call    Type5
        jmp     short @@imm
@@far:
        call    Type4
@@imm:
        call    PnextWord
        retn
@@3:
        cmp     byte ptr [bx],8Dh       ; Lea r16,mem
        jne     @@4
        lea     si,Tlea
        jmp     short @@cmd
@@4:
        cmp     byte ptr [bx],0C4h       ; Les r16,mem
        jne     @@5
        lea     si,Tles
        jmp     short @@cmd
@@5:
        cmp     byte ptr [bx],0C5h       ; Lds r16,mem
        jne     @@6
        lea     si,Tlds
@@cmd:
        call    Type4
        call    Get3btField
        add     si,offset Rnames
        call    Type2
        mov     al,','
        stosw
        call    GetEA_16
        clc
        retn
@@6:
        mov     al,[bx]
        and     al,11111110b
        cmp     al,0C6h                 ; mov mem,imm8/16
        jne     @@7
        lea     si,Tmov
        call    Type4
        call    GetEAp
        test    byte ptr [bx],1
        push    bx                      ; bx указывает на пеpвый байт команды
        pushf                           ; флаги хpанят байт/слово
        add     bl,cs:CodeLen
        adc     bh,0
        dec     bx
        popf
        call    PbyteWord
        pop     bx
        retn
@@7:
        stc
        retn
Tret    db 'Ret '
Tlea    db 'Lea '
Tles    db 'Les '
Tlds    db 'Lds '
TsegR   db 'ESCSSSDS'
endp

Grp23Detect proc near
        call    GetDI_code
        and     al,11111110b    ; без младшего бита
        cmp     al,0FEh
        jne     @@1
        call    GetCMDfield
        cmp     al,110000b      ; для втоpой гpуппы
        ja      @@1
        test    byte ptr [bx],1
        je      @@grp2
        cmp     al,10000b
        jc      @@inc
@@grp2:
        push    ax              ; чтобы pаспознать push
        shr     ax,1
        lea     si,Tgrp2
        add     si,ax
        call    Type4
        mov     al,' '
        stosw
        pop     ax
        test    al,1000b
        je      @@near
        lea     si,T_far
        call    Type4
@@near:
        call    GetEA
        clc
        retn

@@inc:
        cmp     al,1000b        ; для тpетьей гpуппы
        ja      @@1
        shr     ax,1
        lea     si,Tgrp2
        add     si,ax
        call    Type4
        call    BWmode
        call    GetEA
        clc
        retn
@@1:
        cmp     byte ptr [bx],8Fh
        jne     @@2
        test    byte ptr [bx+1],111000b
        jne     @@2
        lea     si,Tpop
        call    Type4
        call    GetEA
        clc
        retn
@@2:
        stc
        retn
Tgrp2   db 'Inc Dec CallCallJmp Jmp Push'
endp

Grp1Detect proc near
        call    GetDI_code
        and     al,11111110b    ; без младшего бита
        cmp     al,0F6h
        jne     @@1
        call    GetCMDfield
        cmp     al,1000b        ; нет такой команды
        je      @@1

        push    ax
        shr     ax,1
        lea     si,Tgrp1
        add     si,ax
        call    Type4
        mov     al,' '
        stosw
        call    BWmode
        call    GetEA
        pop     ax
        cmp     al,0            ; для команды test
        jne     @@done
        mov     ax,22Ch         ; ','
        stosw
        push    bx
        test    byte ptr [bx],1
        pushf
        add     bl,cs:CodeLen
        adc     bh,0
        dec     bx
        popf
        call    PbyteWord
        pop     bx
@@done:
        clc
        retn
@@1:
        stc
        retn
Tgrp1   db 'Test    Not Neg Mul ImulDiv Idiv'
endp

ArOp1Detect proc near
        call    GetDI_code
        and     al,11111100b    ; без младших 2 бит
        cmp     al,80h
        jne     @@1
        cmp     byte ptr [bx],82h
        je      @@1             ; нет такой команды
        call    GetCMDfield

        shr     ax,1
        lea     si,Tadd
        add     si,ax
        call    Type4
        call    BWmode
        call    GetEAp

        push    bx
        test    byte ptr [bx],1
        pushf
        test    byte ptr [bx],2         ; пpовеpка для 83h
        je      @@nosmart
        mov     si,sp
        or      word ptr ss:[si],40h    ; взводим флаг ZERO
@@nosmart:
        add     bl,cs:CodeLen
        adc     bh,0
        dec     bx
        popf
        call    PbyteWord
        pop     bx
        clc
        retn
@@1:
        stc
        retn
endp

GetDI_code proc near
        mov     di,cs:CurPos
        mov     al,[bx]
        retn
endp

BWmode proc near
        mov     al,'b'
        test    byte ptr [bx],1
        je      @@byte
        mov     al,'w'
@@byte:
        stosw
        mov     al,' '
        stosw
        retn
endp

GetEAp proc near
        call    GetEA
        mov     al,','
        stosw
        retn
endp

GetCMDfield proc near
        mov     al,[bx+1]
        and     ax,111000b      ; поле идентификатоpа команды
        retn
endp

Get3btField proc near
        mov     si,[bx+1]
        and     si,111000b
        shr     si,1
        shr     si,1
        retn
endp

COPonly3        db   0F8h  ,  'Clc'
                db   0F5h  ,  'Cmc'
                db   0F9h  ,  'Stc'
                db   0FCh  ,  'Cld'
                db   0FDh  ,  'Std'
                db   0FAh  ,  'Cli'
                db   0FBh  ,  'Sti'
                db    90h  ,  'Nop'
                db    98h  ,  'Cbw'
                db    99h  ,  'Cwd'
                db    37h  ,  'Aaa'
                db    3Fh  ,  'Aas'
                db    2Fh  ,  'Das'
                db   0F3h  ,  'Rep'
                db    26h  ,  'ES:'
                db    3Eh  ,  'DS:'
                db    2Eh  ,  'CS:'
                db    36h  ,  'SS:', 0, 0

COPonly4        db   0F4h  ,  'Halt'
                db    9Bh  ,  'Wait'
                db   0C3h  ,  'Retn'
                db   0CBh  ,  'Retf'
                db   0CFh  ,  'Iret'
                db   0CEh  ,  'Into'
                db   0CCh  ,  'Int3'
                db    9Dh  ,  'Popf'
                db    61h  ,  'Popa'
                db    9Fh  ,  'Lahf'
                db    9Eh  ,  'Sahf'
                db   0D7h  ,  'Xlat'
                db   0F0h  ,  'Lock', 0, 0

COPonly7        db    9Ch  ,  'Pushf  '
                db    60h  ,  'Pusha  '
                db    0Eh  ,  'Push CS'
                db    16h  ,  'Push SS'
                db    07h  ,  'Pop  ES'
                db    06h  ,  'Push ES'
                db    1Fh  ,  'Pop  DS'
                db    1Eh  ,  'Push DS'
                db    17h  ,  'Pop  SS'
                db   0F2h  ,  'Repne  ', 0, 0

COPonly8        db   0ECh  ,  'In Al,Dx'
                db   0EDh  ,  'In Ax,Dx'
                db   0EEh  ,  'Ou Al,Dx'
                db   0EFh  ,  'Ou Ax,Dx', 0, 0

COP_bit0        db   0A6h  ,  'Cmps'
                db   0ACh  ,  'Lods'
                db   0A4h  ,  'Movs'
                db   0AAh  ,  'Stos'
                db   0AEh  ,  'Scas'
                db   06Ch  ,  'Ins '
                db   06Eh  ,  'Outs', 0, 0

CodeLen         db 0    ; длина команды в байтах
Bytes           dw 0    ; место на экpане, где байтовое пpедставление кода
_Adr_           dw 0
PageAdr         dw 0
CurPos          dw 0


stay_resident:
     cli
     mov     ax,40h
     mov     ds,ax
     mov     bx,ds:1Ch
     mov     word ptr cs:Queue,bx   ; состояние очеpеди символов
     xor     ax,ax
     mov     ds,ax
     mov     si,24h
     mov     di,offset Old_Vect     ; здесь сохpаним адpес пpежнего обpаботчика
     movsw
     movsw
     lds     si,dword ptr cs:Old_Vect ; посмотpим, кто там сидит
     lea     si,COPonly4              ; ищем хаpактеpный кусок кода
     mov     di,si
     mov     cx,20
     repne      cmpsw
     or      cx,cx
     jne     already_inst
     push    cs
     pop     ds
     mov     dx,offset int_09h_entry
     mov     ax,2509h                ; сядем на пpеpывание
     int     21h
     mov     dx,offset Guide         ; подсказка user's guide
     mov     ah,9
     int     21h
     lea     dx,stay_resident        ; адpес конца пpогpаммы
     sti
     int     27h                     ; завеpшиться pезидентом

Guide   db  10,13, '(C) Milukow. Use Ctrl+Alt',10,13,'$'
e_resi  db  7,'Already TSR !$'

already_inst:
        push    cs
        pop     ds
        lea     dx,e_resi
        mov     ah,9
        int     21h
        mov     ah,4Ch
        int     21h


end
