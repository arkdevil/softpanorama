VideoSeg        EQU     0B000h          ; HERCULES
;VideoSeg        EQU     0B800h         ; VGA

; ---------------------------------------------------------------------------
; Routines for the Hercules (2nd) screen.
;               Copyright (c) 1994 by Jannes Faber
; ---------------------------------------------------------------------------

Hcursor         WORD    0               ; default = upperleft corner
Hback           WORD    700h            ; char = 0, color = 7
Hstart          WORD    0               ; position where scrolling starts
                                        ; above this line is 'protected'

; ---------------------------------------------------------------------------
;  HsetBack         - Sets default char & color for background.
;                     Used by Hscroll, Hcls, Hcll, Hprintx
;  Input:
;       AL          - background character
;       AH          - Color attribute
; All registers are preserved !
; ---------------------------------------------------------------------------
HsetBack        PROC    FAR
                mov     Hback, ax
                ret
HsetBack        ENDP

; ---------------------------------------------------------------------------
;  HsetStart        - Sets Hstart. Tells Hscroll from where to scroll
;  Input:
;       BH          - Linenumber for Hstart (0-based)
; All registers are preserved !
; ---------------------------------------------------------------------------
HsetStart       PROC    FAR    USES    bx
                mov     bl, bh
                mov     bh, 0
                shl     bx, 1
                imul    bx, 80
                mov     Hstart, bx
                .IF     Hcursor < bx
                mov     Hcursor, bx
                .ENDIF
                ret
Hsetstart       ENDP

; ---------------------------------------------------------------------------
;  Hlocate          - Sets the virtual cursor position
;  Input:
;       BL          - X-coordinate
;       BH          - Y-coordinate
; All registers are preserved !
; ---------------------------------------------------------------------------
Hlocate         PROC    FAR    USES    ax bx
                shl     bx, 1
                movzx   ax, bh
                imul    ax, 80
                mov     bh, 0
                add     ax, bx
                .IF     ax < Hstart
                mov     ax, Hstart
                .ENDIF
                mov     Hcursor, ax
                ret
Hlocate         ENDP

; ---------------------------------------------------------------------------
;  Hcls             - Clears the screen, filling it with the current
;                     background values set by 'Hback'.
;  Input: none
; All registers are preserved !
; ---------------------------------------------------------------------------
Hcls            PROC    FAR     USES    es di ax cx
        
                ; ES initialiseren:
                mov     cx, VideoSeg
                mov     es, cx

                ; 2000 x Hback naar screen (v.a. positie 0) :
                mov     ax, Hback
                mov     cx, 2000
                mov     di, 0

HclsLus:        mov     word ptr es:[di], ax
                inc     di
                inc     di
                loop    HclsLus

                ret

Hcls            ENDP

; ---------------------------------------------------------------------------
;  Hcll             - Clears a line, filling it with the current
;                     background values set by 'Hback'.
;  Input:
;       BH          - linenr (0-based)
; All registers are preserved !
; ---------------------------------------------------------------------------
Hcll            PROC    FAR     USES    es di ax cx
        
                ; initialize ES:
                mov     cx, VideoSeg
                mov     es, cx

                ; 80 x Hback naar screen (v.a. positie bh * 160) :
                mov     ax, Hback
                mov     cx, 80
                movzx   di, bh
                shl     di, 1
                imul    di, 80

HcllLus:        mov     word ptr es:[di], ax
                inc     di
                inc     di
                loop    HcllLus

                ret

Hcll            ENDP

; ---------------------------------------------------------------------------
;  Hscroll          - Scrolls the screen one line up
;                     The last line will be erased using Hcll
;  Input:
; All registers are preserved !
; ---------------------------------------------------------------------------
Hscroll         PROC    FAR     USES es si di bx cx

                pushf
                push    ds

                
                ; bron en doel van te verplaatsen bytes
                mov     si, Hstart
                mov     di, si
                add     si, 160
                
                ; DS & ES initialiseren:
                mov     cx, VideoSeg
                mov     ds, cx
                mov     es, cx
                
                ; aantal te verplaatsen bytes
                mov     cx, 4000
                sub     cx, si
                cld                             ; ophogen

                ; Echte verplaatsen
                rep     movsw
                
                pop     ds
                popf
                
                ; nu nog onderste line opvullen
                mov     bh, 24
                call    Hcll

                ret
Hscroll         ENDP

; ---------------------------------------------------------------------------
;  Hstr0            - Put a NULL-terminated string on the screen
;  Input:
;       DS:SI       - Starting address of string
;       AH          - Color attribute
;       BL          - X-coordinate
;       BH          - Y-coordinate
; All other registers are preserved !
; ---------------------------------------------------------------------------
Hstr0           PROC    FAR
        
                mov     al, 0
                call    Hstr
                ret

Hstr0           ENDP

; ---------------------------------------------------------------------------
;  Hstr$            - Put a $-terminated string on the screen
;  Input:
;       DS:SI       - Starting address of string
;       AH          - Color attribute
;       BL          - X-coordinate
;       BH          - Y-coordinate
; All other registers are preserved !
; ---------------------------------------------------------------------------
Hstr$           PROC    FAR
        
                mov     al, '$'
                call    Hstr
                ret

Hstr$           ENDP

; ---------------------------------------------------------------------------
;  Hstr             - Put a AL-terminated string on the screen
;  Input:
;       DS:SI       - Starting address of string
;       AL          - Char at end of string
;       AH          - Color attribute
;       BL          - X-coordinate
;       BH          - Y-coordinate
; All other registers are preserved !
;
; This routine is for internal use only !
; ---------------------------------------------------------------------------
Hstr            PROC    NEAR     USES    es cx di

                ; ES initialiseren:
                mov     cx, VideoSeg
                mov     es, cx

                ; doeladres in screengeheugen berekenen en in DI zetten:
                shl     bx, 1
                movzx   di, bh
                imul    di, 80
                mov     bh, 0
                add     di, bx
                
                ; Stopteken uit AL in BL zetten (niet meer nodig)
                mov     bl, al

                ; bytes op screen zetten :
HstrLus:        mov     al, byte ptr [si]
                cmp     al, bl
                je      HstrKlaar
                inc     si
                mov     es:word ptr [di], ax
                inc     di
                inc     di
                jmp short HstrLus

HstrKlaar:      ret

Hstr            ENDP

; ---------------------------------------------------------------------------
;  Hchar            - Put char on the screen
;  Input:
;       AL          - Char
;       AH          - Color attribute
;       BL          - X-coordinate
;       BH          - Y-coordinate
; All other registers are preserved !
; ---------------------------------------------------------------------------
Hchar           PROC    NEAR     USES    es cx di

                ; ES initialiseren:
                mov     cx, VideoSeg
                mov     es, cx

                ; doeladres in screengeheugen berekenen en in DI zetten:
                shl     bx, 1
                movzx   di, bh
                imul    di, 80
                mov     bh, 0
                add     di, bx
                
                ; byte op screen zetten :
                mov     es:word ptr [di], ax

                ret

Hchar           ENDP

; ---------------------------------------------------------------------------
;  Hprint0          - Put a NULL-terminated string on the screen
;                     This routine handles CR (13) (scrolling when needed)
;                     and updates the 'cursor'.
;  Input:
;       DS:SI       - Starting address of string
;       AH          - Color attribute
; All other registers are preserved !
; ---------------------------------------------------------------------------
Hprint0         PROC    FAR
        
                mov     al, 0
                call    Hprint
                ret

Hprint0         ENDP

; ---------------------------------------------------------------------------
;  Hprint$          - Put a $-terminated string on the screen
;                     This routine handles CR (13) (scrolling when needed)
;                     and updates the 'cursor'.
;  Input:
;       DS:SI       - Starting address of string
;       AH          - Color attribute
; All other registers are preserved !
; ---------------------------------------------------------------------------
Hprint$         PROC    FAR
        
                mov     al, '$'
                call    Hprint
                ret

Hprint$         ENDP

; ---------------------------------------------------------------------------
;  Hprint           - Put a AL-terminated string on the screen
;                     This routine handles CR (13) (scrolling when needed)
;                     and updates the 'cursor'.
;  Input:
;       DS:SI       - Starting address of string
;       AL          - Char at end of string
;       AH          - Color attribute
; All other registers are preserved !
;
; This routine is for internal use only !
; ---------------------------------------------------------------------------
Hprint          PROC    NEAR     USES    es bx cx di

                ; ES initialiseren:
                mov     cx, VideoSeg
                mov     es, cx

                ; doeladres in screengeheugen in DI zetten:
                mov     di, Hcursor
                
                ; Stopteken uit AL in BL zetten (niet meer nodig)
                mov     bl, al

                ; bytes op screen zetten :
HprintLus:      mov     al, byte ptr [si]
                cmp     al, bl
                je      HprintKlaar
                
                .IF     al == 13
                push    ax
                push    dx

                mov     dx, 0
                mov     cx, 160
                mov     ax, di
                div     cx
                inc     ax
                mul     cx
                mov     di, ax
                
                pop     dx
                pop     ax
                .ENDIF
                
                .IF     di >= 4000
                mov     di, 4000 - 160
                call    Hscroll
                .ENDIF
                
                inc     si
                .IF     al != 13
                mov     es:word ptr [di], ax
                inc     di
                inc     di
                .ENDIF
                jmp short HprintLus

HprintKlaar:    mov     Hcursor, di
                ret

Hprint          ENDP

; ---------------------------------------------------------------------------
;  Hval             - Converts the value of EDX/DX/DL into a hex string
;                     that is ready to be printed (NULL-terminated).
;  Input:
;       EDX/DX/DL   - number to convert
;       CX          - number of nibbles (1 - 8)
;  Output:
;       SI          - Address string ( NULL-terminated !!!!)
; All other registers (and EDX) are preserved !
; ---------------------------------------------------------------------------
Hwaarde         BYTE    8 dup (0)
Hwaarde2        BYTE    'h', 0
Hval            PROC    FAR     USES    ax edx

                ; Eerst integer BX omrekenen (gaat per 4 bits)
                mov     si, offset Hwaarde2     ; eerste 4 bits

HvalLus:        mov     al, dl
                and     al, 00001111y
        
                .IF     al <= 9
                add     al, 48
                .ELSE
                add     al, 55
                .ENDIF
                
                dec     si
                mov     [si], al
                shr     edx, 4
                loop    HvalLus

                ret

Hval            ENDP

; ---------------------------------------------------------------------------
;  HvalX            - Converts the value in (E)DX/DL into hex and puts it
;                     on the Hercules-screen at the given position.
;                     DS does not need to be set correctly !
;  Input:
;       AH          - Color attribute
;       BL          - X-coordinate
;       BH          - Y-coordinate
;       CX          - number of nibbles (1-8)
;    (E)DX/DL       - number to convert
; All other registers are preserved !
;
;  Added: Dec. 27th 1994
; ---------------------------------------------------------------------------
HvalX           PROC    FAR     USES  ds si
        
                push    cs
                pop     ds

                call    Hval    ; vereist CX en (E)DX/DL

                mov     al, 0   ; vereist AX BX SI
                call    Hstr
                ret

HvalX           ENDP


