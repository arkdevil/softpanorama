        .MODEL  TINY
        .386
        .CODE
        .STARTUP

        jmp     install
        
VideoSeg        EQU     0B000h

Target  WORD    0
Status  BYTE    0                       ; 0 = Nieuw doel
                                        ; 1 = Tracking
Ticks   BYTE    0
LastSeg WORD    0
CrossPos WORD   12 * 100h + 39

OldTimerInt      DWORD   0

TimerIntHandler  PROC    FAR

        pushf
        call    cs:OldTimerInt
        sti

        push    ax
        push    bx
        push    ds
        push    es

        mov     ax, cs        
        mov     ds, ax

        .IF     Status == 0
        push    di
        
        mov     ax, VideoSeg
        mov     es, ax
        mov     bx, CrossPos
        call    RemoveCross
        
        inc     LastSeg
        mov     bx, LastSeg
        mov     es, bx

        mov     bx, es:[bx]
        and     bx, 0001111100011111y
        shl     bl, 2
        dec     bl
        .IF     bh != 0 && bh <= 24 && bl != 0 && bl <= 78
        inc     Status
        mov     Target, bx
        
        mov     ax, VideoSeg
        mov     es, ax
        
        shl     bx, 1
        movzx   di, bh
        imul    di, 80
        mov     bh, 0
        add     di, bx
        inc     di
        mov     byte ptr es:[di], 112
        .ENDIF
        
        mov     ax, VideoSeg
        mov     es, ax
        mov     bx, CrossPos
        call    DrawCross

        pop     di
        .ELSE
        
        dec     Ticks
        .IF     !Zero?
        mov     Ticks, 4
        push    dx

        mov     ax, VideoSeg
        mov     es, ax
        
        mov     bx, CrossPos
        call    RemoveCross
        
        mov     dx, Target

        .IF     bh < dh
        inc     bh
        .ELSEIF bh > dh
        dec     bh
        .ENDIF

        .IF     bl < dl
        inc     bl
        inc     bl
        inc     bl
        inc     bl
        .ELSEIF bl > dl
        dec     bl
        dec     bl
        dec     bl
        dec     bl
        .ENDIF
        
        mov     CrossPos, bx
        call    DrawCross

        .IF     dx == bx        
        dec     Status
        .ENDIF
        
        pop     dx
        .ENDIF

        .ENDIF

        pop     es
        pop     ds
        pop     bx
        pop     ax

        iret
TimerIntHandler     ENDP

;----------------------------------------------------------------------------
; DrawCross
;
; Invoer        BL      Kolomnummer middelpunt
;               BH      Regelnummer middelpunt
;----------------------------------------------------------------------------
DrawCross       PROC    FAR uses ax bx cx di

                shl     bx, 1
                movzx   di, bh
                imul    di, 80
                mov     cx, 80
                
HorLus:         .IF     byte ptr es:[di] == '│'
                mov     byte ptr es:[di], '┼'
                .ELSE
                mov     byte ptr es:[di], '─'
                .ENDIF
                inc     di
                inc     di
                loop    HorLus

                movzx   di, bl
                mov     cx, 25
                
                mov     ax, 160
VerLus:         .IF     byte ptr es:[di] == '─'
                mov     byte ptr es:[di], '┼'
                .ELSE
                mov     byte ptr es:[di], '│'
                .ENDIF
                add     di, ax
                loop    VerLus
                
                movzx   di, bh
                imul    di, 80
                mov     bh, 0
                add     di, bx
                mov     byte ptr es:[di], '┼'
                
                ret
DrawCross       ENDP
        
;----------------------------------------------------------------------------
; RemoveCross
;
; Invoer        BL      Kolomnummer middelpunt
;               BH      Regelnummer middelpunt
;----------------------------------------------------------------------------
RemoveCross     PROC    FAR uses ax bx cx di

                shl     bx, 1
                movzx   di, bh
                imul    di, 80
                mov     cx, 80
                
HorLus:         .IF     byte ptr es:[di] == '┼'
                mov     byte ptr es:[di], '│'
                .ELSE
                mov     byte ptr es:[di], 0
                .ENDIF
                inc     di
                inc     di
                loop    HorLus

                movzx   di, bl
                mov     cx, 25
                
                mov     ax, 160
VerLus:         .IF     byte ptr es:[di] == '┼'
                mov     byte ptr es:[di], '─'
                .ELSE
                mov     byte ptr es:[di], 0
                .ENDIF
                add     di, ax
                loop    VerLus
                
                movzx   di, bh
                imul    di, 80
                mov     bh, 0
                add     di, bx
                mov     word ptr es:[di], 700h
                
                ret
RemoveCross     ENDP
        
Install:        call    Hcls

;nieuwe timer-interrupt handler installeren (om pauzes af te handelen)
                mov     ax, 3508h               ; int 8 (oude onthouden)
                int     21h
                mov     WORD PTR OldTimerInt[0], bx
                mov     WORD PTR OldTimerInt[2], es
                
                mov     ax, 2508h               ; int 8 (nieuwe instellen)
                mov     dx, OFFSET TimerIntHandler
                int     21h

; Environment uit geheugen verwijderen om ruimte te besparen:
                mov     bx, 2Ch
                mov     ax, [bx]
                mov     es, ax
                mov     ah, 49h
                int     21h

                mov     ah, 09
                mov     dx, offset Melding
                int     21h


;programma verlaten en resident blijven
                mov     dx, OFFSET Install
                mov     cl, 4
                shr     dx, cl
                inc     dx
                mov     ax, 3100h
                int     21h

Melding         BYTE    'H_SHOOT geladen !', 13, 10, '$'
        
        INCLUDE Hercules.inc

        
        END
