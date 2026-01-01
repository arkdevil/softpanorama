.model tiny
.code
               org     100h
start:         jmp     main_part

SeqData        dw      00100h
               dw      00001h
               dw      00302h
               dw      00003h
               dw      00204h
               dw      00300h

               dw      00c11h
               dw      00b06h
               dw      03e07h
               dw      04d09h          ; 04d09h for 34 lines,
                                       ; 04f09h for 30 lines
               dw      0ea10h
               dw      08c11h
               dw      0db12h          ; 0db12h for 34 lines
                                       ; 0df12h for 30 lines
               dw      0e715h
               dw      00416h
clear_scr      db      0

res_part:      pushf
;               cmp     ah,0fh
;               je      false_info
               cmp     ah,0
               je      anal_mode
               jmp     end_res
anal_mode:     mov     cs:clear_scr,1
               cmp     al,3
               je      set_30
               cmp     al,2
               jne     without_cls
               jmp     set_30

without_cls:   cmp     al,82h
               je      set_30_wc
               cmp     al,83h
               je      set_30_wc
               jmp     end_res
set_30_wc:     mov     cs:clear_scr,0
               jmp     set_30

set_30:        push    ax
               push    bx
               push    cx
               push    dx
               push    si
               push    ds
               push    es

               mov     ax,cs
               mov     ds,ax

               mov     ax,0003h
               pushf
               call    dword ptr old_10

               mov     ax,1111h                ; 1111h for 34 lines
               mov     bl,0                    ; 1114h for 30 lines
               pushf
               call    dword ptr old_10

               lea     si,SeqData
               mov     dx,3c4h
               mov     cx,5
               cld
lp1:           lodsw
               out     dx,ax
               loop    lp1                     ; loop sequencer write
               mov     dl,0c2h
               mov     al,0e7h                 ; code for 480
               out     dx,al                   ; write misc register
               mov     dl,0c4h                 ; sequencer adr. again
               lodsw
               out     dx,ax
               mov     dl,0d4h                 ; 0b4h for mono
               mov     cx,9
lp2:           lodsw
               out     dx,ax
               loop    lp2                     ; loop CRTC write

               xor     ax,ax
               mov     es,ax
               mov     byte ptr es:484h,33     ; 33 for 34 lines
               and     byte ptr es:487h,not 1  ; for cursor emulate
               mov     byte ptr es:449h,3      ; set video mode 3
               mov     word ptr es:44Ch,1540h  ; 12C0 for 30 lines
                                               ; 1540 for 34 lines
               mov     bx,es:044eh
               mov     ax,0b800h
               mov     es,ax
               mov     byte ptr es:[bx],'#'

               cmp     cs:clear_scr,1
               jne     end_set
               mov     ax,0600h
               xor     cx,cx
               mov     dx,1D4Fh
               mov     bh,07h
               pushf
               call    dword ptr old_10

end_set:       pop     es
               pop     ds
               pop     si
               pop     dx
               pop     cx
               pop     bx
               pop     ax

               jmp     to_prog

end_res:       popf
               db      0eah
old_10         label   dword
offs           dw      ?
segm           dw      ?

;false_info:    push    es
;               push    bx
;               mov     bx,0
;               mov     es,bx
;               mov     bx,0449h
;               cmp     byte ptr es:[bx],1Eh
;               je      set_false
;               cmp     byte ptr es:[bx],9Eh
;               je      set_false
;               pop     bx
;               pop     es
;               jmp     end_res
;set_false:     mov     al,3
;               mov     bx,044ah
;               mov     ah,es:[bx]
;               mov     bx,0462h
;               mov     bh,es:[bx]
;               pop     bx
;               pop     es
to_prog:       popf
               iret
main_part:     mov     ax,cs
               mov     ds,ax
               mov     ah,35h
               mov     al,10h
               int     21h
               mov     segm,es
               mov     offs,bx

               lea     dx,res_part
               mov     al,10h
               mov     ah,25h
               int     21h

               mov     ah,0
               mov     al,3
               int     10h
               lea     dx,main_part
               int     27h
               end     start
