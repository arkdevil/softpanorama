; Реконструкция части кода программы Norton Guides, отвечающей
; за активизацию резидентной части программы.
;
; Реконструкция выполнена в образовательных некоммерческих целях
; Олегом Петровичем Пилипенко, ст. преп. каф. выч. мат. ОГУ
; в сентябре - ноябре 1992 года.

FALSE                   equ     0
TRUE                    equ     1
MAX_ATTEMPT             equ     3
TEST_NEXT_CHAR          equ     1
READ_NEXT_CHAR_A        equ     10h
TEST_NEXT_CHAR_A        equ     11h
WRITE_BEEP              equ     0E07h
NG_ANCHOR               equ     0F398h
NG_REPLAY               equ     6A73h

int28h          proc    far
;; Обработчик прерывания 28h. 
;  Если выставлен флаг activate, вызывает процедуру guides

                sti
                cmp     cs:activate, TRUE
                jne     chainint28h

                mov     cs:inguides28, TRUE
                call    guides
                mov     cs:inguides28, FALSE
chainint28h:    cli

                jmp     cs:oldint28h
int28h          endp

int16h          proc    far
;; Обработчик прерывания 16h.
;  В случае получения пароля (NG_ANCHOR) выдает отзыв (NG_REPLAY).
;  Если к прерыванию обратились для чтения или проверки кода
;  клавиши в буфере клавиатуры, проверяется, не установлен ли флаг
;  activate. Если флаг установлен, вызывается процедура guides.
;  Затем проверяется, не совпадает ли выбираемый из буфера символ
;  с кодом горячей клавиши (hotkey). Если совпадает, вызывается 
;  процедура guides, а после возврата из нее делается вид,
;  что этого кода не было, и возвращается значение следующего кода 
;  или признак его отсутствия.

                cmp     cs:inguides, FALSE
                jne     chainint16h     ; Если мы уже в Norton Guides,
                                        ; передать управление дальше

                cmp     ah, TEST_NEXT_CHAR
                jbe     processfunc

                cmp     ah, READ_NEXT_CHAR_A
                je      processfunc

                cmp     ah, TEST_NEXT_CHAR_A
                je      processfunc

                cmp     ah, NG_ANCHOR
                jne     chainint16h

                mov     ax, NG_REPLAY
                mov     bx, cs:hotkey
                iret

chainint16h:    jmp     cs:oldint16h

processfunc:    cmp     cs:activate, TRUE
                jne     skipcall

                call    guides

skipcall:       or      ah, ah
                je      readkey

                cmp     ah, READ_NEXT_CHAR_A
                je      readkey

                cmp     ah, TEST_NEXT_CHAR
                je      testkey

;  Как ни странно, в этом месте в NG.EXE стояла константа 10h
;  (READ_NEXT_CHAR_A) - это явная ошибка (скорее, опечатка).

                cmp     ah, TEST_NEXT_CHAR_A
                je      testkey

                jmp     cs:oldint16h

readkey:        mov     cs:saveah, ah
                sti
                pushf
                cli
                call    cs:oldint16h
                cmp     ax, cs:hotkey
                je      callguides

                iret

callguides:     call    guides
                mov     ah, cs:saveah
                jmp     readkey

testkey:        mov     cs:saveah, ah
                dec     cs:saveah
                sti
                pushf
                cli
                call    cs:oldint16h
                je      exit

                cmp     ax, cs:hotkey
                jne     exit

                mov     ah, cs:saveah
                pushf
                cli
                call    cs:oldint16h
                call    guides
                retf    2
int16h          endp

guides          proc    near
;; Если флаг inguides не устанвлен, он устанавливается,
;  переключается стек и вызывается процедура mainshell.
;  После возврата из mainshell стек переключается назад и
;  сбрасывается флаг inguides.

                cli
                cmp     cs:inguides, FALSE
                jne     exitguides

                inc     cs:inguides
                jmp     doguides

exitguides:     sti
                ret

doguides:       cli
                mov     cs:savesp, sp
                mov     cs:savess, ss
                mov     ss, cs:ourss
                lea     sp, cs:oursp
                call    mainshell
                cli
                mov     ss, cs:savess
                mov     sp, cs:savesp
                dec     cs:inguides
                sti
                ret
guides          endp

mainshell       proc    near
;; Если есть возможность (позволяет In Dos Flag), вызывается
;  тело Norton Guides (popupbody), иначе устанавливается флаг
;  activate. Если число неудачных попыток превышает MAX_ATTEMPTS,
;  подается звуковой сигнал и флаг activate сбрасывается.

                push    ax
                push    bx
                push    cx
                push    dx
                push    si
                push    di
                push    bp
                push    ds
                push    es
                mov     ax, ss
                mov     ds, ax
                mov     es, ax
                sti
                call    cmpindosingds
                je      skippopupbody

                cld
                call    popupbody
                mov     activate, FALSE
                jmp     exitmainshell

skippopupbody:  cmp     cs:activate, TRUE
                jne     setactivate

                dec     cs:attempts
                jne     exitmainshell

                call    beep
                mov     cs:activate, FALSE
                jmp     exitmainshell

                mov     cs:activate, FALSE
                jmp     exitmainshell

setactivate:    mov     cs:activate, TRUE
                mov     cs:attempts, MAX_ATTEMPT

exitmainshell:  pop     es
                pop     ds
                pop     bp
                pop     di
                pop     si
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                ret
mainshell       endp

cmpindosingds:  proc    near
;; Сравниваются значения флагов In Dos Flag и inguides.
;  Результат возвращается в флаге процессора ZF.

                push    ax
                call    testindos
                cmp     al, cs:inguides
                jbe     clearzero

                xor     ax, ax
                jmp     exittest

clearzero:      xor     ax, ax
                inc     ax

exittest:       pop     ax
                ret
cmpindosingds   endp

testindos       proc    near
;; Проверяется In Dos Flag. Его значение возвращается в регистре AL.

                push    bx
                push    ds
                lds     bx, cs:indosptr
                mov     al, [bx]
                pop     ds
                pop     bx
testindos       endp

beep            proc    near
;; Звонок.
                push    ax
                mov     ax, WRITE_BEEP
                int     10h
                pop     ax
                ret
beep            endp
