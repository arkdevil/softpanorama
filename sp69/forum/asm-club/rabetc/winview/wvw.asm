;    WinVieW написан на основе исходников драйвера RConsole В.И. Брайченко
;    (СофтПанорама 41), который, в свою очередь, использовал идеи программ
;    AKBD А.В. Могилевца (СофтПанорама 37) и И.А. Свиридова (СофтПанорама 24),
;    в которых, в свою очередь, есть ссылки на классику предмета -
;    А.В. Козлов, PC World USSR, 2'88.

; TASM 3.2, 3 прохода
  P286

Release         equ    '1.00'   ; Версия программы
CALL_FAR        equ     09Ah	; OpCode CALL FAR
JMP_FAR	        equ	0EAh    ; OpCode  JMP FAR
JMP_SHORT       equ	0EBh    ; OpCode  JNP SHORT
RET_NEAR        equ     0C3h    ; OpCode  RET NEAR
CMP_AX_IMM      equ     03Dh    ; OpCode  CMP AX,immediate
INTERRUPT       equ     0CDh    ; OpCode  INT
PUSH_IMM        equ     068h    ; OpCode  PUSH immediate word
TRUE            equ     1
FALSE           equ     0

;
; Сегмент данных BIOS
;
LowMem  segment at 40h
           org 17h
   KbFlags label word                   ; Состояние флагов клавиатуры
   KbFlags17   label byte
           org 18h
   KbFlag18    label byte
           org 1Ah
   KB_head label word                   ; Указатель головы буфера клавиатуры
           org 1Ch
   KB_tail label word                   ; Указатель хвоста буфера клавиатуры
           org 49h
   VidMode label byte                   ; Текущий видеорежим
           org 4ah
   NCols   label byte                   ; Ширина экрана в столбцах
           org 4ch
   RegSize label word                   ; Размер буфера регенерации, байт
           org 84h
   NRows   label byte                   ; Число строк экрана - 1
           org 85h
   Points  label byte                   ; Высота символа в пикселах
           org 87h
   EGAinfo label byte                   ; Информация о EGA
           org 96h
   KbdAT   label byte                   ; AT keyboard flag (для клавиатуры 101
LowMem  ends                            ;                   бит 4(10h)=1 )
;
; Сегмент программы
;
Code    segment
        assume CS:Code,DS:Code
;
; Смещения в префиксе программного сегмента
;
        org 02Ch
EnvSeg  label word                      ; Адрес окружения
        org 05Ch
Scratch label byte                      ; Начало реальной раскладки клавиатуры
        org 080h
ParmLen label byte                      ; Длина строки параметров
        org 081h
ParmStr label byte                      ; Строка параметров
;
; Начало кода программы
;
        org 100h                        ; для .COM - файла
WinVieW:
        jmp Transient
            db  10 dup(13,10), 9,9,9
            db  'WinVieW  (C) V.S. Rabets, 1994', 13,10,13,10, 9,9,9,9
            db  'version ', Release
            db  12 dup(13,10)
        org 1D4h                        ; Место для раскладки клавиатуры
        assume DS:NOTHING

; ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀ Video ▀▀▀▀
                  ; Тип фонта:
FntROM EQU 0      ; ROM
FntKyr EQU 1      ; пользовательский фонт
FntWin EQU 2      ; кириллица в кодировке Windows
CurFnt db FntKyr  ; Текущий фонт. Может быть = 0,1,2 или 3.
                  ; бит 0: 1 - текущий фонт загружаемый, 0 - ROM.
                  ; бит 1: 1 - загружаемый фонт в кодировке 866, 0 - Win.
Old1Fh    label dword
Old1F_ofs dw ?    ; Исходный вектор 1Fh
Old1F_seg dw ?

CallOld10:               ; Вызов исходного обработчика int 10h.
          pushF
          db CALL_FAR
Old10h    label dword
Old10_ofs dw ?           ; Заполняются при
Old10_seg dw ?           ; установке программы
          retN

DetectGraphMode:
    ; Определение режима (текст или графика) по размеру буфера.
    ; Определение режима по форме курсора (в графике cursor=0) проще,
    ; однако надежно только непосредственно после установки видеорежима.
     push AX
        assume ES:LowMem   ; ES должен содержать seg LowMem !
        mov  AL,NRows
        inc  AX            ; Надеемся, что число строк <255
        mul  NCols         ; и число столбцов <256.
        shl  AX,2; AX*4      ;  RegSize - в тексте обычно число знакомест * 2
        cmp  AX,RegSize      ; (символы + их атрибуты), выровненное вверх до
        assume ES:NOTHING    ; границы килобайта. В графике на 1 знакоместо
     pop AX                  ; требуется как минимум 8 байт. Т.о., для текста
     ret                     ; DetectGraphMode возвращает условие ABOVE.

; Обработчик видеофункции 1130h (Информация о шрифтах).
; Вызывает BIOS, затем подставляет в возвращаемые характеристики
; адрес соответствующего собственного шрифта.
; Возвращаемый BIOS'ом статус (AX=0 - ф-ция поддерживается, AX=1100h - нет),
; if any, не изменяется.
;
GetInfo:
        call CallOld10
GI_g14: cmp BH,2
        jne GI_g08
        mov BP,offset Font_14
        jmp SHORT GI_do
GI_g08: cmp BH,3
        jne GI_1F
        mov BP,offset Font_08
        jmp SHORT GI_do
GI_1F:  cmp BH,4
        jne GI_16
 GI_ega label byte                    ; EGA: заменить jne GI_16 на jne GI_ret
        mov BP,offset Font_08 + 128*8
        jmp SHORT GI_do
GI_16:  cmp BH,6
        jne GI_ret
        mov BP,offset Font_16
GI_do:  push CS
        pop  ES
GI_ret: iret

; Обработчик видеофункций 11..h (Функции знакогенератора).
; Вызывается BIOS и запоминается возвращенный им в AX статус, затем
; Функции загрузки встроенных шрифтов (из видео-BIOS) заменяются на
; функции загрузки соответствующих по размеру пользовательских шрифтов,
; после их выполнения подставляется возвращенный BIOS'ом статус.
;
CharGen:
        cmp AL,30h
        je GetInfo
        push CX DX BX AX
        call CallOld10
        pop  CX        ; Исходное состояние AX
        pop  BX DX     ; Восстановили BX и DX
        push DX BX
        push AX        ; В вершине стека - статус выполнения функции
        xchg AX,CX     ; Восстановили исходное состояние AX
        mov  CH,AL     ; CH будет использоваться для обнаружения текст. ф-ций
        push ES BP
        and CH, not 10h       ; обнуляем бит 10h
CG_14:  mov CL,14
        mov BP,offset Font_14
        cmp CH,1              ; функция 1 или 11h ?
        je  CG_Tx
        cmp AL,22h
        je  CG_Gr
CG_08:  mov CL,8
        mov BP,offset Font_08
        cmp CH,2              ; функция 2 или 12h ?
        je  CG_Tx
        cmp AL,23h
        je  CG_Gr
CG_ega  label byte            ; EGA: вставить jmp short CG_end
CG_16:  mov CL,16
        mov BP,offset Font_16
        cmp CH,4              ; функция 4 или 14h ?
        je  CG_Tx
        cmp AL,24h
        jne CG_end
CG_Gr:  mov CH,0        ; Также точка входа из процедуры RefreshFont ========
        mov AL,21h
        stc             ; CF=1 - будет использован как признак граф. режима
        jmp SHORT CG_do
CG_Tx:  and AL,10h      ; Функции 1,2,4 заменяем на 0; 11,12,14 - на 10h
CG_Tx_RF:               ; Точка входа из процедуры RefreshFont ==============
        mov BH,CL
        mov CX,256
        xor DX,DX       ; CF=0 - будет использован как признак текст. режима
CG_do:  push CS
        pop  ES
        call CallOld10
        jnc CG_end      ; Для графических режимов - установка int 43h
         mov BX,ES      ; (нужна для некоторых EGA).
         xor AX,AX          ; Прерывания в этот момент запрещены;
         mov ES,AX          ; Прямая запись в таблицу быстрее, требует меньше
         mov ES:43h*4  ,BP  ; стека и безопаснее (т.к. смена шрифта может быть
         mov ES:43h*4+2,BX  ; вызвана в любой момент с клавиатуры),
                            ; чем DOS fn. 25h.
CG_end: pop  BP ES
        call SetBorder
        pop  AX BX DX CX
        iret

; Обработчик видеофункции  00..h (Установка видеорежима).
; Вызывает BIOS, затем в зависимости от установленного видеорежима
; вызывает ту или иную функцию установки пользовательского шрифта.
;
SetMode:
        call CallOld10
RefreshFont:          ;Точка входа из обработчика int 9 для обновления шрифта
        push CX DX BX AX ES BP
        push SEG LowMem
        pop  ES
        assume ES:LowMem
        mov  CL,VidMode
        cmp  CL,6
        ja   NotCGA
        cmp  CL,4
        jae  CG_end    ; CGA mode, 1Fh уже установлен при загрузке программы
NotCGA: mov AH,11h
        mov BL,0
        mov CL,Points
RF_14:  mov BP,offset Font_14
        mov AL,1          ; AL - # ф-ции установки шрифта из ROM в text mode
        cmp CL,14
        je  RF_do
RF_08:  mov BP,offset Font_08
        inc AX ; AL=2
        cmp CL,8
        je  RF_do
RF_ega  label byte              ; EGA: вставить jmp short CG_end
RF_16:  mov BP,offset Font_16
        mov AL,4
        cmp CL,16
        jne CG_end
RF_do:  call DetectGraphMode
        jna  RF_Gr
        test CurFnt,FntKyr       ; текущий фонт ROM (бит 0 = 0) ?
        jz   CG_Tx_RF            ; да
        mov AL,00h  ;# ф-ции установки пользовательского шрифта для text mode
        jmp CG_Tx_RF
RF_Gr:  mov DL,NRows
        inc DX
        jmp CG_Gr
        assume ES:NOTHING

; Обработчик видеопрерывания.
; Перехватывает функции установки видеорежима и знакогенератора,
; остальные переадресует в BIOS.
;
Int10h:
        test CurFnt,FntKyr              ; В режиме Font ROM - переход в BIOS
        jz   Jmp10
        or   AH,AH                      ; Установка видеорежима?
        jz   SetMode
        cmp  AX,6f05h
        je   SetMode
        cmp  AX,1C02h                   ; Восстановление экрана?
        je   SetMode
        cmp  AH,11h                     ; Функции знакогенератора?
        jne  Jmp10
        jmp  CharGen
Jmp10:  db   JMP_FAR                    ; OpCode JMP far
j10ofs  dw   ?                          ; offset         ; Заполняются при
j10seg  dw   ?                          ; segment        ; установке WinVieW

; ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀ KeyBoard ▀▀▀▀
        assume DS:Code
; Процедура преобразования шрифта из кодировки 866 в Win
; Псевдографика переносится во временный буфер fBuf_Tmp,
; кириллица переносится из колонок 8-A и E в колонки C-F,
; в колонки 8-B заносится шрифт из fBuf,
; псевдографика из fBuf_Tmp переносится в fBuf.
;
; На входе:
;    AX - адрес второй половины шрифта
;    BX - адрес буфера обмена fBuf соответствующего шрифта
;    DX - размер 1/2 колонки таблицы шрифта (т.е. 8 символов)
;    DF=0  DS=CS  ES=CS
;
Trans866toWin_Proc:
   imul SI,DX,6
   add  SI,AX                   ; колонка B - псевдографика 866
   mov  DI,offset fBuf_Tmp      ; во временный буфер
   imul CX,DX,3                 ; три колонки
   rep  movsW                   ; колонки B-D псевдографики 866 -------------
   push SI         ; col E
      add  SI,DX
      add  SI,DX
      push SI      ; col F
         mov CX,DX              ; одну колонку
         rep movsW              ; колонка F псевдографики 866 ---------------

      pop  DI      ; col F
   pop  SI         ; col E
   mov  CX,DX                   ; одну колонку
   rep  movsW                   ; колонка E кириллицы 866 - в F -------------
   imul DI,DX,8
   add  DI,AX                   ; в колонки C-E
   mov  SI,AX                   ; из колонок 8-A
   imul CX,DX,3                 ; три колонки
   rep  movsW                   ; колонки 8-A кириллицы 866 - в C-E ---------

   mov  DI,AX                   ; в колонки 8-B
   mov  SI,BX                   ; из буфера обмена шрифта
   imul CX,DX,4                 ; четыре колонки
   push CX         ; 4 col
    rep movsW                   ; Шрифт Win из буфера обмена в колонки 8-B --
   pop  CX         ; 4 col      ; четыре колонки
   mov  SI,offset fBuf_Tmp      ; из временного буфера
   mov  DI,BX                   ; в буфер обмена шрифта
   rep movsW                    ; Псевдографика перенесена в буфер обмена ---
ret

; Процедура, обратная Trans866toWin_Proc.
TransWinto866_Proc:
   mov  SI,AX                   ; col 8
   mov  DI,offset fBuf_Tmp
   imul CX,DX,4                 ; 4 столбца
   rep  movsW                   ; Шрифт Win - во временный буфер ............

   ;SI = col C
   mov  DI,AX                   ; col 8
   imul CX,DX,3                 ; три колонки
   rep  movsW                   ; кириллица - из колонок C-E в колонки 8-A ..
   push DI         ; col B
     ;SI = col F
     imul DI,DX,12
     add  DI,AX                 ; col E
     mov  CX,DX                 ; одну колонку
     rep  movsW                 ; кириллица из колоноки F - в E .............

   pop  DI         ; col B
   mov  SI,BX                   ; fBuf
   imul CX,DX,3                 ; три колонки
   rep  movsW                   ; псевдогр-ка из буфера обмена в колонки B-D..
   add  DI,DX
   add  DI,DX                   ; col F
   mov  CX,DX                   ; одну колонку
   rep  movsW                   ; псевдогр-ка из буфера обмена в колонку F ..

   mov  SI,offset fBuf_Tmp
   mov  DI,BX                   ; fBuf
   imul CX,DX,4                 ; четыре колонки
   rep  movsW                   ; Шрифт Win - в буфер обмена
ret

TransferFnt866toWin MACRO Font_XX, fBuf, CharSize
  mov  AX, offset Font_XX + 128*CharSize ; AX - адрес второй половины шрифта
  mov  BX, offset fBuf                 ; BX - адрес буфера соответств. шрифта
  mov  DX, CharSize*16/2             ; DX - размер 1/2 колонки таблицы шрифта
  call Trans866toWin_Proc
EndM

TransferFntWinTo866 MACRO Font_XX, fBuf, CharSize
  mov  AX, offset Font_XX + 128*CharSize ; AX - адрес второй половины шрифта
  mov  BX, offset fBuf                 ; BX - адрес буфера соответств. шрифта
  mov  DX, CharSize*16/2             ; DX - размер 1/2 колонки таблицы шрифта
  call TransWinto866_Proc
EndM

; Перенос таблицы UpperCase из UCsource в DOS.
; Если поддержка UpperCase не нужна, то установлено UCtableLen=0.
; Флаги сохраняются, DS сохраняется =CS, ES портится и устанавливается =CS.
;
SetUCtable MACRO UCsource
   mov  SI, UCsource
   call SetUCtable_Proc
EndM
SetUCtable_Proc:
   les  DI,UCtable_DOS
   mov  CX,UCtableLen
   rep movsW
   push CS
   pop  ES
ret

; Процедура генерации кодовой таблицы:  преобразование шрифта и
; перезапись таблицы UpperCase в соответствии с требуемой кодировкой.
; На входе AL - фонт, который нужно установить, AH - текущий фонт:
;                   бит 0: 1 - загружаемый фонт, 0 - ROM.
;                   бит 1: 1 - загружаемый фонт в кодировке 866, 0 - Win.
;          DS=CS  (ES=CS устанавливается в SetUCtable_Proc).
; Вызывается из обработчика int 9.
;
MakeCodeTable:
        mov  CurFnt, AL
        test AL, FntKyr                 ; требуется установка user's шрифта ?
        jnz  MC_User                    ; да
MC_ROM: SetUCtable UCtable_Save         ; Запись в DOS ее исходной таблицы
        ret

MC_User:test AL,FntWin
        jz   MC_866
MC_Win: test AH,FntWin                  ; загружаемый фонт был Win ?
        SetUCtable UCtable_Win
        jnz  MC_ret                     ; да, преобразование шрифта не нужно
        TransferFnt866toWin Font_08, fBuf_08, 08
        TransferFnt866toWin Font_14, fBuf_14, 14
MC_Win_ega label byte                                   ; EGA: вставить RET
        TransferFnt866toWin Font_16, fBuf_16, 16
        ret

MC_866: test AH,FntWin                  ; загружаемый фонт был Win ?
        SetUCtable UCtable_866
        jz  MC_ret                      ; нет, преобразование шрифта не нужно
        TransferFntWinTo866 Font_08, fBuf_08, 08
        TransferFntWinTo866 Font_14, fBuf_14, 14
MC_866_ega label byte                                   ; EGA: вставить RET
        TransferFntWinTo866 Font_16, fBuf_16, 16

MC_ret: ret
        assume DS:NOTHING

;===========================================================================
SetBorder:                      ; Установка рамки
        mov  AX,1001h
        mov  BH,CurBord
        int  10h
        ret

; ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
LS equ ES                   ; сегментный регистр LowMem
PS equ DS                   ; сегментный регистр программы

keyRCpress   EQU  0E01Dh                ; нажатие правого Ctrl
keyRCbreak   EQU  0E09Dh                ;   отпускание его
keyECbreak   EQU  09Dh                  ; отпускание любого Ctrl
keyRSpress   EQU  036h                  ; нажатие правого Shift
keyRSbreak   EQU  0B6h                  ;   отпускание его
keyLSpress   EQU  02Ah                  ; нажатие левого Shift
keyLSbreak   EQU  0AAh                  ;   отпускание его
keyF12       EQU  058D8h                ; нажатие-отпускание F12
keyF11       EQU  057D7h                ;                    F11
keyF10       EQU  044C4h                ;                    F10
keyF09       EQU  043C3h                ;                    F9
keyF08       EQU  042C2h                ;                    F8
keyF07       EQU  041C1h                ;                    F7
keyF12press  EQU  058h                  ;         нажатие F12
keyF11press  EQU  057h                  ;                 F11
keyF10press  EQU  044h                  ;                 F10
keyF09press  EQU  043h                  ;                 F9
keyF08press  EQU  042h                  ;                 F8
keyF07press  EQU  041h                  ;                 F7

keyCapsBreak EQU  0BAh                  ; отпускание CapsLock
ShMask       EQU  0100001100001111b     ; Маска, оставляющая в слове статуса
                      ; кл-ры только удерживание Shift, Ctrl, Alt и CapsLock
ExtKey          db 0        ; =0E0h после поступления префикса расшир. кл-ры
PredKey         label byte
PredKeyWord     dw 0        ; код предыдущей клавиши (low-ScanCode,hi-ExtKey)

KyrKb           EQU 1           ; Кириллица (русская или альтернативная)
AltKb           EQU 2           ; Альтернативная клавиатура (Кир. или Лат.)
CurKb           db  0           ; Текущая клавиатура (бит 1- +-Kyr, 2- +-Alt)
PsWas           db  FALSE       ; Признак использования псевдографики

CurBord db  0FFh  ; Текущая рамка. >F0 задает перезагрузку шрифта,
                  ;                =F0 - удаление символа из буфера клав-ры.
Border label byte ; Рамка:
;    Kbd:      Лат         Кир      Лат+Альт    Кир+Альт    ;   Fnt
        db  0,          0,          0,          0           ; CurFnt=0 (ROM)
        db  00000000b,  00111000b,  00001000b,  00000001b   ; FntKyr   (866)
        db  0,          0,          0,          0           ; FntWin   (ROM)
        db  00000100b,  00100100b,  00000101b,  00101101b   ; FntWin+FntKyr
      ; Для (CurFnt and FntKyr)=0 лучше оставить Border=0, т.к. в этом режиме
      ; все видеовызовы перенаправляются в BIOS, ===> рамка не поддерживается.
KyrAltBord    EQU offset Border + 6     ; ofs рамки для FntKyr, KyrKb+AltKb
KyrAltBordBel EQU 0100h+00001000b       ; белорусская рамка для этого режима
KyrAltBordUkr EQU 0200h+00010000b       ; украинская

PsTable         db 'і,ґ│/─└┴┘├┼┤┌┬┐'    ; Таблица перекодировки псевдографики
PsTableSize EQU                         $ - offset PsTable
                db 'І,Ґ║/═╚╩╝╠╬╣╔╦╗'    ; Shift
                db '·,є│/═╘╧╛╞╪╡╒╤╕'    ; Ctrl
                db 'ї,Є║/─╙╨╜╟╫╢╓╥╖'    ; Ctrl-Shift
                db 'Ї,√■/¤ ▄░▌▒▐▓▀█'    ; Alt
                ;   +,-./0123456789

; Таблицы преобразования раскладки клавиатуры Рус-Бел-Укр:
; пятерки байт:   замещаемая позиция,
;                 замещающий символ без CapsLock, с CapsLock - для 866,
;                 замещающий символ без CapsLock, с CapsLock - для Win.

PatchRus      db  'OЩЩ┘┘oщщїї', ']ъЪ·┌}Ъъ┌·', 'SЫЫ██sыы√√', '''эЭ¤▌"Ээ▌¤'
PatchBel      db  'OII▓▓oii││', ']іІвб}Іібв', 'SЫЫ██sыы√√', '''эЭ¤▌"Ээ▌¤'
PatchUkr      db  'OЩЩ┘┘oщщїї', ']єЄ┐п}Єєп┐', 'SII▓▓sii││', '''ґҐ║к"Ґґк║'
PatchSize     EQU $ - offset PatchUkr

PatchKb MACRO
        local PatchL,PatchLoop2
; Преобразование раскладки. На входе AX=offset PatchXXX, DS=CS
        push CX SI
             xchg AX,SI
             mov  CX,PatchSize/5
   PatchL:   lodsB
             cbw                ; Перекодируются символы <128 ==> AH=0
             xchg AX,BX
             add  BX,offset Scratch - KB_frst
             push CX
                  mov  CL,4     ; для раскладок 866 и Win, с CapsLock и без.
   PatchLoop2:    lodsB
                  mov  PS:[BX],AL
                  add  BX,KB_size
                  loop PatchLoop2
             pop  CX
             loop PatchL
        pop  SI CX
endM

Check2Shifts:              ; Проверка переключения двумя шифтами.
        cmp  BL,3               ; 2 шифта нажато ?
        jne  C2S_ret
        cmp  AH,keyRSpress      ; предыдущий код - Right Shift нажат ?
        je   C2S_ret
        cmp  AH,keyLSpress      ; предыдущий код - Left Shift нажат ?
C2S_ret:
ret                             ; на выходе EQUAL, если есть переключение.
;
; Обработчик прерывания 09h.  Проверяется нажатие переключателей,
; [переустанавливается кодировка и режим клавиатуры], вызывается
; исходный обработчик int 09h, [перекодируется появившийся в буфере символ],
; обновляется история скан-кодов, [перезагружается шрифт].
;
Int09h:
        cld                             ; DF=0 во всем обработчике
        push AX
        in   AL,60h
        push BX DS ES
        push CS SEG LowMem
        pop  ES DS
    assume DS:code,ES:LowMem
        mov  BX,KbFlags                 ; BX - копия слова 0:417h
        mov  AH,FALSE
O9_CapsLockBreak:
        cmp  AL,keyCapsBreak            ; отпущен CapsLock ?
        jne  O9_CapsLockDown
        cmp  PsWas,AH                   ; AH=FALSE
        je   O9_CapsLockDown
        mov  PsWas,AH                   ; если ввод псевдографики был, то
        xor  KbFlags,40h                ; инвертирование бита CapsLock ON
O9_CapsLockDown:
        mov  AH,ExtKey
        test BH,40h             ; CapsLock удерживается?
        jz   O9_swch            ; нет
        cmp  AX,53h             ; Нажаты "0"-"9" "." "-" "+" на малой
        ja   j_ord              ; цифровой клавиатуре ?
        cmp  AL,47h             ; нет - переход на O9_ord (вызов Old09h)
        jb   j_ord
        mov  PsWas,00001001b    ; Отметка об использовании псевдографики
        mov  KbFlags,20h        ; Якобы NumLock ON, все кл-ши сдвига отпущены
        stc                     ; CF=1 - признак режима псевдографики
        jmp  O9_call            ; в BX остались исходные KbFlags
; на все последующие проверки управление передается только при CapsLock=UP

O9_swch:and  BX,ShMask          ; в BX - info только о кл-шах сдвига и CpsLck
        test CurFnt,FntKyr      ; В режиме Font ROM клав-ра не переключается
        jz   O9_FF
                                ; Проверка Right Ctrl doun-up
O9_noRC label byte     ; Если Right Ctrl не нужен - вставить jmp short O9_RS
        cmp  BX,4                       ; только Right Ctrl down ?
        jne  O9_RS
        cmp  AX,keyRCbreak              ; отпускание Right Ctrl ?
        jne  j_ord
        cmp  PredKeyWord,keyRCpress     ; предыдущий код - Right Ctrl down ?
        je   XchgKb
O9_RS:  mov  AH,PredKey         ; Проверка 2 шифта, Ctrl-RightShift
        cmp  AL,keyECbreak              ; любой Ctrl отпущен ?
        je   O9_RS1
        cmp  AL,keyRSbreak              ; правый Shift отпущен ?
        jne  O9_LfS
        call Check2Shifts               ; переключение двумя шифтами ?
        je   XchgKb
O9_RS1: cmp  BL,4+1                     ; either Ctrl + Right-Shift down ?
        jne  O9_LfS
        cmp  AH,keyRSpress              ; предыдущий код - Right Shift down ?
        jne  j_ord
        or   CurKb,KyrKb                ; Ctrl-RightShift ===> клав-ра КИР
O9_LfS:                         ; Проверка 2 шифта, Ctrl-LeftShift
        cmp  AL,keyECbreak              ; любой Ctrl отпущен ?
        je   O9_LS1
        cmp  AL,keyLSbreak              ; левый Shift отпущен ?
        jne  O9_FF
        call Check2Shifts               ; переключение двумя шифтами ?
        je   XchgKb
O9_LS1: cmp  BL,4+2                     ; either Ctrl + Left-Shift down ?
        jne  j_ord
        cmp  AH,keyLSpress              ; предыдущий код - Left Shift down ?
        jne  j_ord
        or   CurKb,KyrKb                ; Ctrl-LeftShift ===> клав-ра ЛАТ
XchgKb: xor  CurKb,KyrKb                ; переключение КИР<-->ЛАТ
j_ord:  jmp  O9_ord            ; Промежуточная точка для SHORT jmps на O9_ord

O9_FF:  ; Обработка F07-F12    ; Проверка F7-F9 нужна независимо от Font ROM
                                            ; для удаления символа из буфера.
        mov  AH,PredKey        ; Для перехода из O9_swch
        mov  BH,CurFnt                  ; Для дальнейших проверок

        cmp  BL,4+8                     ; Ctrl + Alt down ?
        je   O9_alF
        cmp  BL,4+1                     ; Ctrl + Right-Shift down ?
        je   O9_shF
        cmp  BL,4+2                     ; Ctrl + Left-Shift down ?
        jne  j_ord
O9_shF:                        ; Переключение шрифтов (только в text mode)
        cmp  AL,keyF10press
        je   KeepBuf                    ; Нажатие Ctrl-Shift F10-F12 -
        cmp  AL,keyF11press             ; удалить этот символ из буфера.
        je   KeepBuf
        cmp  AL,keyF12press
        je   KeepBuf
        mov  BL,BH                      ; в BL - CurFnt
        and  BL,not FntKyr
        cmp  AX,keyF10                  ; font ROM ?
        je   SetFEnd
        mov  BL,FntKyr+FntWin
        cmp  AX,keyF11                  ; font Win ?
        je   SetFEnd
        mov  BL,FntKyr
        cmp  AX,keyF12                  ; font 866 ?
        jne  j_ord
SetFEnd:xchg AX,BX               ; AL - устанавливаемый фонт, AH - текущий
        call DetectGraphMode     ; в графическом режиме фонт не переключается
        jna  O9_ord
        push CX DX SI DI
             call MakeCodeTable
        pop  DI SI DX CX
        push seg LowMem
        pop  ES
        mov  CurBord,0FFh       ; CurBord>0F0h - признак обновления шрифта
        jmp  SHORT O9_xor

KeepBuf:mov  CurBord,0F0h       ; CurBord=0F0h - признак удаления символа
        jmp SHORT O9_ord        ;                    из буфера клавиатуры

O9_alF:                         ; Переключение клавиатуры РУС-БЕЛ-УКР
        cmp  AL,keyF07press
        jb   O9_ord                     ; Нажатие Ctrl-Alt F7-F9 -
        cmp  AL,keyF09press             ; удалить этот символ из буфера.
        jbe  KeepBuf
        test BH,FntKyr              ; текущий фонт ROM ?
        jz   O9_ord                     ; да, клавиатура не переключается
        cmp  AX,keyF07
        je   O9_aF7
        cmp  AX,keyF08
        je   O9_aF8
        cmp  AX,keyF09
        jne  O9_ord
        mov  AX,offset PatchUkr
        mov  word ptr PS:KyrAltBord,KyrAltBordUkr
        org  $-2                ; значение KyrAltBordUkr вынесено в отдельную
BordUkr dw KyrAltBordUkr        ; переменную для облегчения настройки WVW.com
        jmp  SHORT O9_aF79
O9_aF8: and  CurKb,not AltKb
        mov  AX,offset PatchRus
        jmp  SHORT O9_aSet
O9_aF7: mov  AX,offset PatchBel
        mov  word ptr PS:KyrAltBord,KyrAltBordBel
        org  $-2
BordBel dw KyrAltBordBel
O9_aF79:or   CurKb,Altkb
O9_aSet:     PatchKb

O9_xor: xor  AX,AX                      ; т.к. AL запишется в историю кодов
O9_ord: clc               ; CF=0 - признак обычного режима (НЕ псевдографика)
O9_call:
     pushF                              ; сохранили состояние CF
        mov  AH,ExtKey
        cmp  AL,0E0h                    ; Префикс расширенной клавиатуры ?
        je   O9_Ext                     ; Да, история кодов не обновляется
        mov  PredKeyWord,AX             ; Нет, обновляется
        mov  AL,0                       ;                 и обнуляется ExtKey
O9_Ext: mov  ExtKey,AL
   ; popF                               ; восстановили состояние CF
        xchg BX,AX            ; AX: для пс-графики - копия правильных KbFlags
        mov BX,KB_tail                  ; запомнили адрес конца буфера
   ;    pushF                 ; флаги - в стек для вызова прерывания
    db CALL_FAR               ; Вызов старого обработчика int 09h
Old09h    label dword
Old09_ofs dw ?
Old09_seg dw ?
        jnc  O9_NoPseudo
        mov  KbFlags,AX
        push BX
          mov  BX,LS:[BX]               ; BX - перекодируемый символ
          and  AH,3                     ; из флагов оставляем Left Ctrtl&Alt
          shl  AL,6                     ; и Left Shift
          shr  AX,7
          test AL,4                     ; Left-Alt pressed ?
          jz   ps_CH
          mov  AL,4
ps_CH:    imul AX,PsTableSize
          add  AX,offset PsTable - '+'  ; AX - смещение таблицы перекодировки
          xchg AX,BX                    ; AX - символ, BX - смещение таблицы
          jmp  SHORT O9_do
O9_NoPseudo:
      cmp  CurBord,0F0h
      jne  NoKeepB
      mov  KB_tail,BX
NoKeepB:
        mov  AL,CurFnt                  ; для FntKyr бит 0 = 1
        and  AL,CurKb                   ; для KyrKb  бит 0 = 1
        test AL,KyrKb                   ; для font ROM или Kbd ЛАТ перекоди-
        jz   O9_bord                    ;                          ровки нет
        cmp  BX,KB_tail                 ; записан ли новый символ?
        je   O9_bord                    ; нет
        mov  AX,LS:[BX]                 ; взять его для анализа
        or   AH,AH                      ; есть ли SCAN код?
        jz   O9_bord
        cmp  AH,35h                     ; введен ли он с основной клавиатуры?
        ja   O9_bord                    ; нет
        cmp  AL,KB_frst                 ; подлежит ли перекодировке?
        jb   O9_bord                    ; нет
        cmp  AL,KB_last
        ja   O9_bord                    ; нет
      push BX
        mov  BX,offset Scratch - KB_frst  ; раскладка для CapsLock OFF, 866
        test CurFnt,FntWin
        jz   O9_cap
        add  BX,KB_size*2               ; раскладка для FntWin
O9_cap: test KbFlags17,40h              ; проверить Caps Lock
        jz   O9_do                      ; Caps Lock = 0!
        add  BX,KB_size                 ; раскладка для CapsLock ON
O9_do:  xlat Scratch            ; xlat Scratch или PsTable - обе в одном сег.
      pop  BX
O9_scan label byte                     ; замена mov AH,0 на JMP SHORT $+2
        mov  AH,0                      ; стереть SCAN код
        mov  LS:[BX],AX                ; и вернуть символ в буфер клавиатуры

O9_bord:             ; Вход для обновления рамки. Должно быть DS=CS,ES=LowMem
RefreshBord:         ;    в стеке: Flags,CS,IP - для iret, и push AX BX DS ES
        test KbFlag18,40h              ; CapsLock down (Псевдографика) ?
        jz   O9_b1
        mov  AL,00111111b              ; ярко-белая рамка
        sub  AL,PsWas                  ; желтая, если пс-графика вводилась
        jmp  SHORT O9_b2
O9_b1:  mov  AL,CurFnt
        cbw
        shl  AL,2
        add  AL,CurKb
        xchg AX,BX
        mov  AL,PS:[Border+BX]          ; цвет рамки для обычного режима
O9_b2:  cmp  AL,CurBord
        je   O9_end
        cmp  CurBord,0F0h               ; перезагружать шрифт ?
        mov  CurBord,AL
        call SetBorder
O9_end:
        pop  ES DS BX AX
        jbe  O9_quit                    ; флаги после  cmp CurBord,0F0h
        jmp  RefreshFont
O9_quit:
    iret
    assume DS:NOTHING,ES:NOTHING

; ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀ Program  eXit ▀▀▀▀▀
;
Int20h:
        pushF                   ; Подготовка возврата по iret из RefreshBord
    db  PUSH_IMM                ; в исходный обработчик int 20h:
Old20_seg  dw 0                 ; в стек - Flags, seg и offset возврата.
    db  PUSH_IMM
Old20_ofs  dw 0
j_RB:   push AX BX DS ES                ; подготовка стека для RefreshBord
        push CS seg LowMem
        pop  ES DS                      ; подготовка DS и ES для RefreshBord
    assume DS:code
        and  CurKb,not KyrKb            ; клавиатура ЛАТ
        mov  CurBord,0EFh               ; для обязательной перерисовки рамки
        jmp  SHORT RefreshBord          ; На обновление рамки
    assume DS:NOTHING

Int21h:
        or   AH,AH              ; DOS function Terminate ?
        jz   i21do
        cmp  AH,4Ch             ; DOS function EXIT ?
        jne  Int21h_ret
i21do:  pushF                   ; Подготовка возврата по iret из RefreshBord
        push Old21h             ;            в исходный обработчик int 21h
        jmp  SHORT j_RB         ; на установку kbd=ЛАТ и обновление рамки
Int21h_ret:
     db JMP_FAR                 ; переход в исходный обработчик int 21h
Old21h  label dword
Old21_ofs     dw 0
Old21_seg     dw 0

; ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀ ComInt ▀▀▀▀▀▀
; Обработчик прерывания ComInt (2Fh или любого другого, назначенного для
; связи с резидентом ключом /0,255,1,2,#int).
; Если вызвана функция ComFn прерывания ComInt, AL=0 и строка DS:SI совпадает
; с WVWname, то устанавливается AL=FFh, ES:DI и SI устанавливается на свое
; WVWver, CX=0.

WVWname    db 'WinVieW'          ; строка для распознавания резидентной копии
WVWnameLen EQU $ - offset WVWname
WVWver     db  Release           ; версия программы
WVWverLen  EQU $ - offset WVWver

Int2f:
        db   CMP_AX_IMM, 0    ; AL сравнивается с 0, AH - с ComFn.
ComFn   db   0                ; Функция для связи с резидентной копией
        jne  F2_jmp           ; (инициализируется при установке программы)
        push ES
             push CS
             pop  ES
        push CX SI DI
             mov  DI,offset WVWname
             mov  CX,WVWnameLen
             repE cmpsB
             jne  F2_end
             mov  AL,0FFh       ; WVWname совпадает
        add  SP,8
             iret
F2_end: pop  ES DI SI CX
F2_jmp:        db  JMP_FAR
OldComInt      label dword
OldComInt_ofs  dw ?             ; адрес исходного обработчика
OldComInt_seg  dw ?

; ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀ Fonts & UpperCase ▀▀▀▀
; Шрифты и таблицы UpperCase
;
        even
UCtableLen      dw 130/2                      ; длина таблицы UpperCase, слов
UCtable_866     dw offset UpCaseTable_866     ; таблица UpCase для 866
UCtable_Win     dw offset UpCaseTable_Win     ; таблица UpCase для Win
UCtable_Save    dw offset UpCaseTable_Save    ; место для DOS'овской таблицы
UCtable_DOS     label dword
UCtable_DOS_ofs dw ?                          ; Заполняются при
UCtable_DOS_seg dw ?                          ; установке программы

Font_08 label byte
        .xlist
        include Font_08.inc     ; Шрифт (изначально - в 866 кодировке)
        .list
fBuf_08 label byte              ; Буфер обмена шрифта: изначально -
        .xlist                  ; символы 80h-0BFh в кодировке Win,
        include fBuf_08.inc     ; при смене кодировки они обмениваются
        .list                   ; с символами псевдографики в Font_XX
Font_14 label byte
        .xlist
        include Font_14.inc
        .list
fBuf_14 label byte
        .xlist
        include fBuf_14.inc
        .list
fBuf_Tmp label byte
        .xlist                  ; Буфер для временного хранения
         db 64*14 dup (0)       ; заменяемой части шрифта
        .list
FNTend_EGA:
        .xlist
        db 64*(16-14) dup (0)
        .list
Font_16 label byte
        .xlist
        include Font_16.inc
        .list
fBuf_16 label byte
        .xlist
        include fBuf_16.inc
        .list
FNTend_VGA:

; Таблицы UpperCase:
UpCaseTable_866:
        .xlist
        include UC_866.inc
        .list
UpCaseTable_Win:
        .xlist
        include UC_Win.inc
        .list
UCtable_DOS_Len label word  ; В первом слове таблицы UpCase записана ее длина
UpCaseTable_Save:               ; Место для хранения исходной DOS'овской
        .xlist                  ; таблицы UpperCase
        db 130 dup (0)
        .list
AllUCtablesLen  EQU $ - offset UpCaseTable_866      ; длина всех таблиц UCase
VGA_EGA_Shift   EQU offset FNTend_VGA - offset FNTend_EGA
TSR_end         dw $                                ; конец резидента для VGA

; Раскладки клавиатуры (во время установки копируются в Scratch).
;
KB_x866 db  '!Э№;%?э()*+б-ю.'
        db '0123456789ЖжБ=Ю,'
        db '"ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯх\ъ:_'
        db 'ёфисвуапршолдьтщзйкыегмцчняХ/ЪЁ'
KB_c866 db  '!э№;%?Э()*+Б-Ю.'
        db '0123456789жЖб=ю,'
        db '"ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯХ\Ъ:_'
        db 'Ёфисвуапршолдьтщзйкыегмцчнях/ъё'
KB_xLtW db  '!▌╣;%?¤()*+с-■.'
        db '0123456789╞ц┴=▐,'
        db '"╘╚╤┬╙└╧╨╪╬╦─▄╥┘╟╔╩█┼├╠╓╫═▀є\·:_'
        db '╕ЄшётґряЁЇюыф№Ґїчщъ√хуьІіэ ╒/┌и'
KB_cpsW db  '!¤╣;%?▌()*+┴-▐.'
        db '0123456789ц╞с=■,'
        db '"╘╚╤┬╙└╧╨╪╬╦─▄╥┘╟╔╩█┼├╠╓╫═▀╒\┌:_'
        db 'иЄшётґряЁЇюыф№Ґїчщъ√хуьІіэ є/·╕'
KB_size = KB_c866 - KB_x866         ; размер раскладки  (94 символа)
KB_frst = 33                        ; первый перекодируемый символ    ('!')
KB_last = 126                       ; последний перекодируемый символ ('~')

; ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀ Transient ▀▀▀▀
; Нерезидентная часть программы - производит установку и настройку.
;
        assume DS:Code
EGAyes     db ?            ; <>0 если есть активный EGA
Kbd101     db ?            ; <>0 если клавиатура 101-клавишная
SystError  db 0            ; <>0 если обнаружено несоответствие системы
ResPSP     dw 0            ; Адрес PSP резидента. Если резидент найден, то >0
VerSame    db FALSE        ; У резидентной копии та же версия ?
ComFnOrg   db 80h          ; Начальное значение ComFn
SupportUC  db TRUE         ; Поддерживать таблицы UpperCase?
Hook1F     db FALSE        ; Вектор 1Fh перехвачен другой программой ?

CountryInfo   db ?            ; Буфер для DOS ф-ции 6502h, 5 байт:
CurUC_ofs     dw ?            ; Адрес текущей таблицы UpperCase
CurUC_seg     dw ?

        ; таблица имен ключей командной строки
Sw_Name db   '?',        'H',        'E',        '^',        'S'
        db    'B',        'C',        'I',        'L',        'K'
        db     'X',        'R',        'U'
Sw_Len  equ  $ - Sw_Name
        ; таблица значений ключей командной строки
Sw_Val  db Sw_Len-3 dup (FALSE)
NoTerm  db FALSE  ; НЕ отслеживать завершение программ ? (часть табл. Sw_Val)
Resto   db FALSE  ; Восстанавливать фонт ROM после выгрузки ?  (часть Sw_Val)
UnLoad  db FALSE  ;                   Выгружать TSR ?  (часть таблицы Sw_Val)
        ; таблица адресов обработчиков ключей командной строки
ofs equ offset
Sw_Proc dw   ofs prHelp, ofs prHelp, ofs prEHlp, ofs prRCtl, ofs prScan
        dw    ofs prBlan, ofs prUC,   ofs prInBrd,ofs prBeLo, ofs prUKr
        dw     ofs prEXit, ofs prResto,ofs prUnLd

CtrlBreak:  iret                            ; Обработчик Ctrl-Break

FillMem MACRO Font, Char, CharSize          ; Затирание изображения 1 символа
        mov DI,offset Font + Char*CharSize
        mov CX,CharSize/2
        rep stosW
       EndM
Message MACRO S                             ; Вывод сообщения S
        mov AH,9
        mov DX,offset S
        int 21h
       EndM
Error   MACRO S        ; Вывод сообщения S о несоответствии системы программе
        Message S
        inc SystError
       EndM
Beep    db 7,'$'
ExitErr:Message Beep                        ; Выход в случае ошибки
        int 20h
;
; Подпрограммы обработки ключей командной строки
;
KeyTempl  db '  · · · · · · · · ·',13,' ComInt '
ComIntHex db '..h',13,'$'
                ; Вывод всегда активных ключей, установленных настройщиком,
OutKeys:        ; и текущего ComInt. Важно расположение ключей в Sw_Name.
        mov  DI,offset KeyTempl + 2
        mov  BX,3               ; начиная с ключа с '^'
OKloop: test [Sw_Val+BX],80h    ; для установленных настройщиком ключей
        jz   OKrep              ;                       старший бит = 1.
        mov  AL,[Sw_Name+BX]
        stosB                   ; запись имени ключа в KeyTempl
        inc  DI
OKrep:  inc  BX
        cmp  BX,11              ; последний ключ - 'R'
        jbe  OKloop

        mov  AL,ComInt          ; представление ComInt в Hex-виде
        mov  AH,AL
        and  AH,0Fh
        shr  AL,4
        add  AX,3030h
        cmp  AH,'9'
        jbe  OK_1
        add  AH,'@'-'9'
OK_1:   cmp  AL,'9'
        jbe  OK_2
        add  AL,'@'-'9'
OK_2:   mov  word ptr ComIntHex,AX
        Message KeyTempl
        int  20h

prHelp: Message Help                    ; /?,/H: русский справочный экран
        jmp  OutKeys
prEHlp: Message HelpEng                 ; /E: английский справочный экран
        jmp  OutKeys
prRCtl: mov O9_noRC    ,JMP_SHORT       ; /^: не использовать Right Ctrl
        mov O9_noRC + 1,offset O9_RS - (offset O9_noRC + 2)
        ret
prScan: mov  O9_scan,JMP_SHORT          ; /S: сохранять scan-код -
        ret                             ;   заменить 'mov AH,' на 'jmp SHORT'
prBlan: xor AX,AX                       ; /B: изображать коды 0 и FF пробелом
        FillMem Font_08,  00, 08
        FillMem Font_08, 255, 08
        FillMem Font_14,  00, 14
        FillMem Font_14, 255, 14
        FillMem Font_16,  00, 16
        FillMem Font_16, 255, 16
        ret
prUC:   mov  SupportUC,FALSE   ; /C: не поддерживать таблицы UpperCase -
        mov  UCtableLen,0      ;     установить длину перемещаемого блока =0
        ret
prInBrd:mov  byte ptr SetBorder,RET_NEAR   ; /I: не индицировать режим рамкой
prEXit: ret                                ; /X: не отслеживать конец программ
prBeLo: mov  AX,BordBel                    ; /L: установить белорусскую кл-ру
        mov  word ptr KyrAltBord,AX
        mov  AX,offset PatchBel
        jmp  prWest
prUKr:  mov  AX,BordUkr                    ; /K: украинскую
        mov  word ptr KyrAltBord,AX
        mov  AX,offset PatchUkr
 prWest:or   CurKb,Altkb
        PatchKb
        ret
prResto:mov  UnLoad,TRUE       ; /R: выгрузка WVW с восстановлением фонта ROM
prUnLd: ret                    ; /U: выгрузка WinVieW

;===========================================================================
  JUMPS
Transient:

; Запрет Cntrl-Break.
        mov AX,2523h                 ; int 23h - адрес обработчика Ctrl-Break
        mov DX,offset CtrlBreak
        int 21h

; Вывод сообщения о себе и ревизия системы.
        mov  AX,seg LowMem
        mov  ES,AX
      assume ES:LowMem
        mov  AL,KbdAT          ; для AT (бит 4)=1 - есть 101-кл. клавиатура
        and  AL,10h            ; (работает только на AT и не слишком надежно,
        mov  Kbd101,AL         ;  зато просто и не опустошает буфер клав-ры).
        mov  AL,EGAinfo
        mov  EGAyes,AL
        cmp  AL,0              ; есть EGA ?
        je   OutCopyR_DOS      ; нет - вывод имени через DOS, EGAyes=0
        not  AL
        and  AL,8              ; EGA активно ?
        mov  EGAyes,AL
        jz   OutCopyR_DOS      ; нет - вывод имени через DOS, EGAyes=0
        call DetectGraphMode
        push CS
        pop  ES
      assume ES:NOTHING
        jna  OutCopyR_DOS      ; в графическом режиме - вывод имени через DOS
OutCopyR_BIOS:                 ; вывод цветного имени через BIOS
        mov  AH, 3
        int  10h  ; DH,DL - cursor row,col
        mov  BP, offset CopyR
        mov  CX, CopyRLen / 2
        mov  BH, 0
        mov  AX, 1303h
        int  10h
        jmp  short Rev286
OutCopyR_DOS:
        Message CopyR_DOS
Rev286: push SP                ; Ревизия процессора командой PUSH SP:
        pop  AX                ; 086 делает сначала SP:=SP-2, затем [SP]:=SP;
        cmp  AX,SP             ; 286+  -  сначала [SP-2]:=SP, затем SP:=SP-2
        je   RevEGA
        Error Err286
RevEGA: cmp  EGAyes,0          ; есть активный EGA?
        jne  RevKbd
        Error ErrEGA
RevKbd: cmp  Kbd101,0
        jne  VerDOS
        Error ErrKbd
VerDOS: mov  AH,30h            ; версия DOS - должна быть не ниже 3.3
        int  21h
        xchg AL,AH
        cmp  AX,031Eh          ; 1Eh=30
        jae  RevEnd
        Error ErrDOS
RevEnd: cmp SystError,0
        jne ExitErr
;
; Обработка командной строки
        cld
        mov  SI,offset ParmStr
CLloop: lodsB
        cmp  AL,0Dh                     ; строка закончилась ?
        je   CmdLnEnd
        cmp  AL,'/'                     ; ключи начинаются с '/'
        je   ParFound
        cmp  AL,'-'                     ; или с '-'
        je   ParFound
        cmp  AL,' '                     ; разделитель ?
        jbe  CLloop
CLerr:  Message ErrPar                  ; Сообщение о неправильном параметре
        mov  BX,offset ParmStr
        add  BL,ParmLen
        mov  byte ptr [BX],'$'
        dec  SI
        mov  DX,SI
        mov  AH,9            ; вывод нераспознанного остатка командной строки
        int  21h
        jmp  ExitErr
ParFound:                       ; Обработка параметра
        lodsB
        cmp  AL,0                       ; ключ /0... - многосимвольный,
        je   sw_Int                     ; обрабатывается индивидуально
        cmp  AL,'a'
        jb   sw_NoUC
        and  AL,0DFh                    ; в верхний регистр
sw_NoUC:mov  CX,Sw_Len
sw_Loop:mov  BX,CX
        dec  BX
        cmp  AL,[Sw_Name+BX]            ; поиск ключа в таблице имен
        jne  sw_rep
        or   [Sw_Val+BX],TRUE           ; отметка в таблице значений
        jmp  CLloop
sw_rep: loop sw_Loop
        jmp  ClErr                      ; ключ не опознан

sw_Int: lodsW                   ; Обработка ключа /0,255,1,2,#ComInt -
        cmp  AX,01FFh           ;     задание вектора для связи с резидентом
        jne  CLerr
        lodsW
        cmp  AL,2
        jne  CLerr
        mov  ComInt,AH
        cmp  AH,16h
        jae  CLloop
        Message ErrComInt
        jmp  ExitErr
CmdLnEnd:
;
; Скопировать раскладки клавиатуры в резидентную часть - в уже ненужный PSP
        push CS
        pop  ES
        mov  CX,KB_size*2
        mov  SI,offset KB_x866
        mov  DI,offset Scratch
        rep  movsW
;
; Обработка параметров командной строки
        mov  CX,Sw_Len
sw_StLp:mov  BX,Sw_Len
        sub  BX,CX
        cmp  [Sw_Val+BX],FALSE          ; параметр не установлен ?
        je   sw_SRep
        mov  [Sw_Val+BX],TRUE  ; для всегда активных ключей старший бит был=1
        shl  BX,1                       ; длина элемента таблицы Sw_Proc - 2
        push CX
             call [sw_Proc+BX]          ; вызов процедуры обработки параметра
        pop  CX
sw_SRep:loop sw_StLp
;
; Найти свою резидентную копию
;
FindRes:mov  AH,ComFnOrg          ; просмотр функций начинаем с 80h
        mov  AL,0
        mov  SI,offset WVWname
        db   INTERRUPT            ; int ComInt
ComInt  db   2Fh                  ; прерывание для связи с резидентной копией
        push CS
        pop  DS                   ; на всякий случай
        cmp  AL,0
        jne  FunBusy
        mov  AH,ComFnOrg
        mov  ComFn,AH             ; найдена незанятая функция
FunBusy:cmp  AL,0FFh              ; есть ответ ?
        jne  NoRepl
        dec  SI                   ; резидентная копия устанавливает SI и DI
        dec  DI                   ; на следующий за WVWname символ.
        mov  CX,WVWnameLen
        std
        repE cmpsB                ; WVWname совпадает ?
        cld
        jne  NoRepl               ; Нет
        mov  ResPSP,ES            ; Да, запомнили адрес PSP резидента
        inc  SI                   ; Проверяем версию
        inc  DI
        mov  CX,WVWnameLen + WVWverLen
        repE cmpsB                ; Имя + версия совпадают ?
        jne  FindResEnd           ; VerSame остается FALSE
        mov  VerSame,TRUE
        jmp  FindResEnd
NoRepl: inc  ComFnOrg
        jnz  FindRes       ; если не прошли еще 255, то возврат в цикл
FindResEnd:
;
; Найти текущую таблицу UpperCase и проверить возможность ее перезаписи
;
MCBtype      EQU 0           ; смещения в Memory Control Block
MCBowner     EQU 1
MCBsize      EQU 3
        cmp  SupportUC,TRUE  ; нужна поддержка таблиц UpperCase ?
        jne  FindUCend
        mov  AX,6502h        ; Get UpperCase table
        mov  DX,-1           ; для текущей страны
        mov  BX,DX           ; для текущей страницы
        mov  CX,5
        push CS
        pop  ES
        mov  DI,offset CountryInfo
        int  21h
        jc   FUCerr
        mov  SI,CurUC_ofs          ; заполнение в резидентной части адреса
        mov  UCtable_DOS_ofs,SI    ; DOS'овской таблицы UpperCase.
        mov  DX,SI                 ; DX - ofs. DOS'овской таблицы UpperCase
        mov  AX,CurUC_seg          ; AX - seg  DOS'овской таблицы UpperCase
        mov  UCtable_DOS_seg,AX
        mov  DS,AX                 ; DS:SI - адрес текущей таблицы UpperCase
        mov  DI,offset UpCaseTable_Save; ES:DI - адрес ее копии в рез. части
        mov  CX,130/2              ; длина таблицы - 130 байт
        cld
        rep  movsW                 ; переписали таблицу в резидентную часть
        push CS
        pop  DS                    ; восстановили DS
        cmp  UCtable_DOS_Len,128   ; нужная длина ?
        jne  FUCerr
; Проверка, не находится ли таблица в какой-нибудь программе:
        inc  AX
        jz   FUCerr
        dec  AX
        shr  DX,4        ; DX/16  (ofs --> seg)
        add  DX,AX       ; DX - приведенный сегментный адрес DOS's UpperCase
        mov  AH,52h                     ; Get DOS vars
        int  21h
        mov  ES,ES:[BX-2]               ; ES - первый MCB
MCBbeg: mov  AX,ES                      ; AX - адрес текущего блока
        mov  BX,ES
        inc  BX
        add  BX,ES:MCBsize              ; BX - адрес следующего блока
        cmp  word ptr ES:MCBowner,8     ; принадлежит DOS ?
        je   MCBnext
        cmp  DX,AX                      ; таблица ниже текущего блока ?
        jb   FindUCend
        cmp  DX,BX                      ; таблица UpperCase в блоке ?
        jbe  FUCerr
MCBnext:cmp  byte ptr ES:MCBtype,'M'    ; не последний блок ?
        jne  FindUCend
        mov  ES,BX                      ; ES - адрес следующего блока
        jmp  MCBbeg
FUCerr: mov  UCtableLen,0           ; запретить перемещение таблиц резидентом
FindUCend:
;
; Получить текущие вектора прерываний и записать их в резидентную часть
;
        mov AX,3510h              ; вектор видеопрерывания (10h)
        int 21h
        mov Old10_ofs,BX
        mov Old10_seg,ES
        mov j10ofs,BX
        mov j10seg,ES
        mov AX,3509h              ; вектор клавиатурного прерывания (09h)
        int 21h
        mov Old09_ofs,BX
        mov Old09_seg,ES
        mov AH,35h
        mov AL,ComInt             ; вектор для связи с резидентной копией
        int 21h
        mov OldComInt_ofs,BX
        mov OldComInt_seg,ES
        mov AX,351Fh              ; 1Fh - указатель на графические символы
        int 21h
        mov Old1F_ofs,BX
        mov Old1F_seg,ES
        cmp UnLoad,TRUE           ; Old20h и Old21h не заполняются только
        je  GetTerm               ;      если задана загрузка с ключом /X
        cmp Noterm,TRUE
        je  GetVectEnd
GetTerm:mov AX,3520h              ; 20h - Program terminate
        int 21h
        mov Old20_ofs,BX
        mov Old20_seg,ES
        mov AX,3521h              ; 21h - для DOS fn EXIT
        int 21h
        mov Old21_ofs,BX
        mov Old21_seg,ES
GetVectEnd:
;
; Если адаптер не VGA, а EGA, то можно значительно уменьшить размер резидента
;
        mov  AX,1A00h                    ; проверить наличие VGA
        int  10h
        cmp  AL,1Ah                      ; есть ли VGA?
        je   EGA_skip                    ; да, есть, корректировки не нужны.
        sub  TSR_end, VGA_EGA_Shift      ; Конец резидента для EGA
        mov  SI,offset FNTend_VGA
        mov  DI,offset FNTend_EGA
        mov  CX,AllUCtablesLen
        push CS
        pop  ES
        rep  movsB                       ; Перенос таблиц UpperCase
        sub  UCtable_866 ,VGA_EGA_Shift  ; Изменение их адресов
        sub  UCtable_Win ,VGA_EGA_Shift
        sub  UCtable_Save,VGA_EGA_Shift
        mov GI_ega - 1,offset GI_ret - offset GI_ega        ; произвести
        mov CG_ega    , JMP_SHORT                           ; необходимые
        mov CG_ega + 1,offset CG_end - (offset CG_ega + 2)  ; исправления
        mov RF_ega    , JMP_SHORT                           ; в резидентной
        mov RF_ega + 1,offset CG_end - (offset RF_ega + 2)  ; части программы
        mov MC_Win_ega, RET_NEAR
        mov MC_866_ega, RET_NEAR
EGA_skip:
        cmp  UCtableLen,0
        jne  ReduceEnd                ; если поддержки таблиц UpperCase нет,
        sub  TSR_end,AllUCtablesLen   ; то исключаем их из резидента
ReduceEnd:
; -------------------------------------------------------------- UnLoad ----
; Загружаться или выгружаться ?
;
        cmp  UnLoad,TRUE                ; выгрузка ?
        jne  Load
        cmp  ResPSP,0                   ; резидент обнаружен ?
        je   NotFound
        cmp  VerSame,TRUE               ; резидентна эта же версия ?
        jne  DifferVer
      ; Проверка, не перехвачены ли вектора прерываний:
        mov  AX,ResPSP
        mov  ES,AX                      ; ES и AX указывают на PSP резидента
        cmp  AX,Old10_seg               ; сегменты совпадают ?
        jne  Hook
        cmp  AX,Old09_seg
        jne  Hook
        cmp  AX,OldComInt_seg
        jne  Hook
        cmp  ES:Old20_seg,0     ; резидент не перехватывал int 20h и int 21h
        je   Seg20ok
        cmp  AX,Old20_seg
        jne  Hook
        cmp  AX,Old21_seg
        jne  Hook
Seg20ok:cmp  AX,Old1F_seg
        je   Seg1Fok
        mov  Hook1F,TRUE
Seg1Fok:cmp  Old10_ofs,    offset Int10h   ; смещения совпадают ?
        jne  Hook
        cmp  Old09_ofs,    offset Int09h
        jne  Hook
        cmp  OldComInt_ofs,offset Int2F
        jne  Hook
        cmp  ES:Old20_seg,0     ; резидент не перехватывал int 20h и int 21h
        je   Ofs20ok
        cmp  Old20_ofs,    offset Int20h
        jne  Hook
        cmp  Old21_ofs,    offset Int21h
        jne  Hook
Ofs20ok:cmp  Old1F_ofs,    offset Font_08 + 128*8
        je   Ofs1Fok
        mov  Hook1F,TRUE
Ofs1Fok:
      ; Восстановление векторов         ; ES уже указывает на PSP резидента
        mov  AH,25h
        mov  AL,ComInt                  ; ComInt - в нерезидентной части
        lds  DX,ES:OldComInt
        int  21h
        mov  AX,2509h
        lds  DX,ES:Old09h
        int  21h
        mov  AX,2510h
        lds  DX,ES:Old10h
        int  21h
        cmp  ES:Old20_seg,0     ; резидент не перехватывал int 20h и int 21h
        je   Rest1F
        mov  AX,2520h
        mov  DS,ES:Old20_seg
        mov  DX,ES:Old20_ofs
        int  21h
        mov  AX,2521h
        lds  DX,ES:Old21h
        int  21h
Rest1F: cmp  CS:Hook1F,TRUE                ; 1F восстанавливается только если
        je   RestoIntEnd                   ; он не был перехвачен другой
        mov  AX,251Fh                      ; программой (например, GrafTabl)
        lds  DX,ES:Old1Fh
        int  21h
RestoIntEnd:
      ; Восстановление таблицы Upper Case
        push ES
        pop  DS                         ; ES и DS указывют на PSP резидента
        ; Вызов своей SetUCtable с переменными резидента для восстановления
        ; UpCase table. Если UCtableLen резидента =0, то ничего не происходит.
        SetUCtable UCtable_Save   ; на входе SetUCtable: DS=сегмент программы
        mov  CurFnt,0             ; установили CurFnt резидента =ROM
        push CS
        pop  DS                         ; Восстановили DS
      ; Восстановление [шрифта ROM и] рамки
        mov  CurBord,0
        cmp  Resto,TRUE
        jne  ResBord
        mov  CurFnt,0
        ; установка шрифта ROM подпрограммой из своей резидентной части,
        ; которая через OldInt10h обращается к обработчику int 10h резидента,
        ; для которого мы установили CurFnt=0.
        pushF                           ; для iret
        push CS                         ; для iret
        call RefreshFont
ResBord:call SetBorder                  ; устранение рамки

      ; Удаление резидента из памяти
        mov  AH,49h
        mov  ES,ResPSP
        int  21H
        jc   CantUnLd
        Message MesUnLoaded
        int 20h

NotFound: Message ErrNotFound
          jmp     ExitErr
DifferVer:Message ErrDifVer
          jmp     ExitErr
Hook:     Message ErrHook
          jmp     ExitErr
CantUnLd: Message ErrRemove
          jmp     ExitErr

; ---------------------------------------------------------------- Load ----
Load:   cmp  ResPSP,0
        je   Install
        Message ErrAlready
        jmp     ExitErr
Install:
        mov  ES,EnvSeg          ; Освобождаемся от Environment
        mov  AH,49h
        int  21h
;
; Установить таблицу Upper Case
;
        cmp  SupportUC,TRUE     ; нужна поддержка таблиц UpperCase ?
        jne  SetUCend
        cmp  UCtableLen,0       ; возможна поддержка таблиц UpperCase ?
        jne  InitUC
        Message ErrUCtable
InitUC: mov  AH,CurFnt          
        mov  AL,AH
        call MakeCodeTable      ; Если UCtableLen=0, то ничего не происходит.
SetUCend:
;
; Установить текущие шрифт и рамку подпрограммой из резидентной части
;
        push seg LowMem
        pop  ES
        pushF                           ; для IRET
        push CS  offset InitBordFontRet ; для IRET
        push AX BX DS ES                ; подготовка стека для RefreshBord
        jmp  RefreshBord                ;        (CurBord=0FFh изначально)
InitBordFontRet:
;
; Установить шрифт GRAFTABL
        push CS
        pop  ES
        mov  AX,1120h
        mov  BP,offset Font_08 + 128*8
        int  10h
;
; Установить новые вектора прерываний
;
        mov AX,2510h                  ; видео
        mov DX,offset Int10h
        int 21h
        mov AX,2509h                  ; клавиатура
        mov DX,offset Int09h
        int 21h
        mov AH,25h
        mov AL,ComInt                 ; вектор для связи с резидентной копией
        mov DX,offset Int2f
        int 21h
        cmp NoTerm,TRUE               ; перехватывать int 20h и int 21h ?
        je  SetVectEnd
        mov AX,2520h                  ; int 20h - program terminate
        mov DX,offset Int20h
        int 21h
        mov AX,2521h                  ; int 21h - для DOS fn EXIT
        mov DX,offset Int21h
        int 21h
SetVectEnd:
;
; Оставить в памяти резидентную часть и вернуться в DOS.
;
        Message MesInstalled
        mov DX,TSR_end
        int 27h

CopyR db   13,10, 32,7, 32,7
      db 32,40h,32,40h,32,40h,32,40h,32,40h,32,40h,32,40h,32,40h,32,40h
      db 13,10, 32,10h, 32,10h
      db ' ',41h,'W',41h,'i',4Bh,'n',4Bh,'V',43h,'i',4Bh,'e',4Bh,'W',40h
      db 32,40h, 32,12h,32,12h,32,18h
      db '(',12h,'C',12h,')',12h,' ',12h,'V',12h,'.',12h,'S',12h,'.',12h
      db ' ',12h,'R',12h,'a',12h,'b',12h,'e',12h,'t',12h,'s',12h
      db ',',12h,' ',12h,'1',12h,'9',12h,'9',12h,'4',12h,' ',12h,' ',12h
      db 32,12h, 10,13, 32,7, 32,7h
      db 32,40h,32,40h,32,40h,32,40h,32,40h,32,40h,32,40h,32,40h,32,40h
      db 13,10
CopyRLen EQU $ - offset CopyR + 8

CrLf    equ 13,10
Marg    equ  9,'    ',4,32
MesTail equ 32,4, CrLf, '$'
Err286  db Marg, 'i286+ required',            MesTail
ErrEGA  db Marg, 'EGA or VGA required',       MesTail
ErrKbd  db Marg, '101-key keyboard required', MesTail
ErrDOS  db Marg, 'DOS 3.3+ required',         MesTail
ErrPar  db Marg, 'Invalid command line tail: ', '$'
ErrComInt   db Marg, 'Interrupt for communication with TSR must be above 15h'
            db MesTail
ErrUCtable  db Marg, 'Can''t support Upper Case table', 7,           MesTail
ErrNotFound db Marg, 'Nothing to unload: resident WinVieW not found',MesTail
ErrDifVer   db Marg, 'Can''t unload. Resident WinVieW has different version'
            db MesTail
ErrHook     db Marg, 'Can''t unload. Please remove TSRs loaded after WinVieW'
            db MesTail
ErrRemove   db Marg, 'WinVieW deactivated. Can''t remove it from memory. '
            db 'Sorry',                   MesTail
MesUnLoaded db Marg, 'Unloaded',          MesTail
ErrAlready  db Marg, 'Already installed', MesTail
MesInstalled db Marg,'Installed',         MesTail

HelpEng:
   db Marg, 'Version ', Release                                         ,CrLf
   db Marg                                                              ,CrLf
db '╒══════════  Command line options: ══════════════════════════════════════════╕',CrLf
db '│ /? or /H - Russian Help              /E - English help                      │',CrLf
db '│ /^ - DO NOT use Right Ctrl           /B - Blank characters 00 and FF        │',CrLf
db '│ /C - DO NOT support upper Case table /I - DO NOT Indicate the mode by border│',CrLf
db '│ /K - set uKranian keyboard           /L - set byeLorussian keyboard         │',CrLf
db '│ /R - unload and Restore ROM font     /U - Unload                            │',CrLf
db '│ /S - keep key''s Scan code            /X - DO NOT trace programs eXit        │',CrLf
db '└─────────────────────────────────────────────────────────────────────────────┘',CrLf
   db Marg, 'Hot keys:'                                                 ,CrLf
   db Marg, '  Ctrl-Shift: F12 - 866, F11 - Windows, F10 - ROM mode'    ,CrLf
   db Marg, '  Ctrl-Alt:   F7-Byelorussian, F8-Russian, F9-Ukranian keyboard',CrLf
   db Marg, '  Ctrl-RightShift - Cyrillic keyboard'                     ,CrLf
   db Marg, '  Ctrl-LeftShift  - Latin keyboard'                        ,CrLf
   db Marg, '  Both Shifts - switch between cyrillic and latin keyboard',CrLf
   db Marg, '  Right Ctrl (optional) - same as Both Shifts'             ,CrLf
   db Marg, '  pressed CapsLock [Shift,Ctrl,Alt] - graphic symbols'     ,CrLf
db '──────────────────────────────────────────────────────────────────────────────',CrLf
db ' ComInt 2Fh ',4 ,' Tuned permanently active options:$'

CopyR_DOS    db CrLf, 'WinVieW  (C) V.S. Rabets, 1994', CrLf, '$'

Help:
   db Marg, 'Версия ', Release                                          ,CrLf
   db Marg                                                              ,CrLf
db '╒══════════  Опции командной строки: ════════════════════════════════════════╕',CrLf
db '│ /? или /H - этот экран               /E - English help                      │',CrLf
db '│ /^ - НЕ использовать Правый_Ctrl     /B - изображать символы 0 и FF пробелом│',CrLf
db '│ /C - НЕ поддерживать таблицу UpCase  /I - НЕ индицировать режим рамкой      │',CrLf
db '│ /K -установить украинскую клавиатуру /L - установить белорусскую клавиатуру │',CrLf
db '│ /R - /U + установить фонт ROM        /U - выгрузить резидент                │',CrLf
db '│ /S - сохранять скан-коды клавиш      /X - НЕ отслеживать завершение программ│',CrLf
db '└─────────────────────────────────────────────────────────────────────────────┘',CrLf
   db Marg, 'Клавиши-переключатели:'                                    ,CrLf
   db Marg, '  Ctrl-Shift: F12 - 866, F11 - Windows, F10 - ROM режим'   ,CrLf
   db Marg, '  Ctrl-Alt:  F7-белорусская, F8-русская, F9-украинская клавиатуры',CrLf
   db Marg, '  Ctrl-Правый_Shift - клавиатура с кириллицей'             ,CrLf
   db Marg, '  Ctrl-Левый_Shift  - латинская клавиатура'                ,CrLf
   db Marg, '  Два Шифта - переключение клавиатуры КИР-LAT'             ,CrLf
   db Marg, '  Правый_Ctrl (факультативно) - то же, что Два Шифта'      ,CrLf
   db Marg, '  удерживаемый CapsLock [+ Shift,Ctrl,Alt] - псевдографика',CrLf
db '──────────────────────────────────────────────────────────────────────────────',CrLf
db ' ComInt 2Fh ',4 ,' Настроенные постоянно активные опции:$'

Code    ends
        end WinVieW
