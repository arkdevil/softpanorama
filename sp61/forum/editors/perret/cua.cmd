; CUA-feel macros for MicroEMACS 3.11c
;
; Pierre Perret - April 1992

; Uses mark9 as CUA anchor and mark8 as a temporary (for mark swapping).
; Uses the Clipboard for CUA copy/cut/paste in MS-Windows version (MEWxx),
; uses the kill buffer for same in other implementations.

; NOTE:
; - some key sequences are not supported by MicroEMACS-DOS:
;     Shift+Arrow, Ctrl+Ins/Del and Shift+Ins/Del/Home/End/PageUp/PageDown.
; - Shift+Ctrl+Arrow/Home/End not supported by either MicroEMACS-DOS or MEW10.
; 
; To offset that, the special keys have been assigned equivalent function
; keys: Ins=F9, Del=F10, Home=F1, End=F2, PageUp=F3, PageDown=F4,
;       ArrowLeft=F5, ArrowUp=F6, ArrowDown=F7, ArrowRight=F8
; for Shift or Ctrl combinations (using Alt for Shift+Ctrl cases)

; set $hilite 9     ; for future MEW version that will be able to
;                   ; show region9 hilited

store-procedure CUA-cmdhook
; NOTE: unfortunately, %keepanchor is always set to FALSE for
;       M- and ^X prefixed keystrokes, regardless of the binding
    !if %keepanchor
        set %keepanchor FALSE
    !else
        set %discmd $discmd
        set $discmd FALSE
        ; previous command was not an anchor-preserving one
        !force 9 remove-mark
        set $discmd %discmd
    !endif
!endm
set $cmdhook CUA-cmdhook

store-procedure load-anchor
; loads the anchor (mark9) into the mark0, saving
; previous mark0 into mark8.
; flag %anchor is set if there is a non-empty selection
; used by most deletion/copying actions
    set %discmd $discmd
    set $discmd FALSE
    !force 0 exchange-point-and-mark
    !if $status
        8 set-mark
        0 exchange-point-and-mark
    !else
        !force 8 remove-mark
    !endif
    !force 9 exchange-point-and-mark
    !if $status
        0 set-mark
        9 exchange-point-and-mark
        !if &seq $region ""
            set %anchor FALSE
        !else
            set %anchor TRUE
        !endif
    !else
        !force 0 remove-mark
        set %anchor FALSE
    !endif
    set $discmd %discmd
!endm

store-procedure restore-mark
; restores mark0 from mark8 after a load-anchor call
    set %discmd $discmd
    set $discmd FALSE
    !force 8 exchange-point-and-mark
    !if $status
        0 set-mark
        8 exchange-point-and-mark
    !else
        !force 0 remove-mark
    !endif
    set $discmd %discmd
!endm

store-procedure CUA-Del
    run load-anchor
    !if %anchor
        kill-region
    !else
        !force 1 delete-next-character
    !endif
    run restore-mark
!endm
macro-to-key    CUA-Del     FND

store-procedure CUA-C-Ins
    run load-anchor
    !if %anchor
        set %keepanchor TRUE
        !if &seq $sres MSWIN
            clip-region
        !else
            copy-region
        !endif
    !endif
    run restore-mark
!endm
macro-to-key    CUA-C-Ins	FN^C
macro-to-key    CUA-C-Ins	FN^9
!if &seq $sres MSWIN
    unbind-menu     ">&Edit>&Clipboard>&Copy region"
    macro-to-menu   CUA-C-Ins	"&Copy@1"
!endif

store-procedure CUA-S-Del
    run load-anchor
    !if %anchor
        !if &seq $sres MSWIN
            cut-region
        !else
            kill-region
        !endif
    !endif
    run restore-mark
!endm
macro-to-key    CUA-S-Del	S-FND
macro-to-key    CUA-S-Del	S-FN0
!if &seq $sres MSWIN
    unbind-menu     ">&Edit>&Clipboard>Cu&t region"
    macro-to-menu   CUA-S-Del   "Cu&t@0"
!else

bind-to-key     yank            S-FNC   ; Shift+Ins
bind-to-key     yank            S-FN9
!endif


store-procedure CUA-case-upper
    run load-anchor
    !if %anchor
        set %keepanchor TRUE
        case-region-upper
    !endif
    run restore-mark
!endm
macro-to-key    CUA-case-upper  A-U ; Alt+U
!if &seq $sres MSWIN
    macro-to-menu   CUA-case-upper  ">&Edit>&Selection@4>&Upper case"
!endif

store-procedure CUA-case-lower
    run load-anchor
    !if %anchor
        set %keepanchor TRUE
        case-region-lower
    !endif
    run restore-mark
!endm
macro-to-key    CUA-case-lower  A-L ; Alt+L
!if &seq $sres MSWIN
    macro-to-menu   CUA-case-lower  "&Lower case"
!endif

store-procedure CUA-count-words
; this procedure is not really necessary but it demonstrates
; how to add CUA-based functionality
    run load-anchor
    !if %anchor
        set %keepanchor TRUE
        count-words
    !endif
    run restore-mark
!endm
macro-to-key    CUA-count-words A-W ; Alt+W
!if &seq $sres MSWIN
    macro-to-menu   CUA-count-words "Count &words"
!endif

store-procedure CUA-flip-selection
; a sort of exchange-point-and-anchor, could be used to
; visualize the selection by going back and forth to its
; boundaries
    !force 9 exchange-point-and-mark
    !if $status
        set %keepanchor TRUE
    !endif
!endm
macro-to-key    CUA-flip-selection A-=
!if &seq $sres MSWIN
    bind-to-menu    nop "-"
    macro-to-menu   CUA-flip-selection "&Flip"
!endif

store-procedure CUA-select-region
; makes the anchor equal to the mark
; (useful to build very large selections)
    set %discmd $discmd
    set $discmd FALSE
    !force 0 exchange-point-and-mark
    !if $status
        9 set-mark
        0 exchange-point-and-mark
        set %keepanchor TRUE
    !else
        9 remove-mark
    !endif
    set $discmd %discmd
!endm
macro-to-key    CUA-select-region A-^M  ; Alt+Enter
!if &seq $sres MSWIN
    macro-to-menu   CUA-select-region   "Select &region"
!endif

store-procedure CUA-anchor
; makes sure we have a CUA anchor point (i.e. a mark9)
; used internally by most extended selection keys
; always sets %keepanchor to TRUE
    set %discmd $discmd
    set $discmd FALSE
    !force 9 exchange-point-and-mark
    !if $status
        9 exchange-point-and-mark
    !else
        9 set-mark
    !endif
    set %keepanchor TRUE
    set $discmd %discmd
!endm

store-procedure CUA-S-home
    run CUA-anchor
    beginning-of-line
!endm
macro-to-key    CUA-S-home          S-FN<
macro-to-key    CUA-S-home          S-FN1

store-procedure CUA-S-end
    run CUA-anchor
    end-of-line
!endm
macro-to-key    CUA-S-end           S-FN>
macro-to-key    CUA-S-end           S-FN2

store-procedure CUA-SC-home
    run CUA-anchor
    beginning-of-file
!endm
macro-to-key    CUA-SC-home         S-FN^<
macro-to-key    CUA-SC-home         A-FN1

store-procedure CUA-SC-end
    run CUA-anchor
    end-of-file
!endm
macro-to-key    CUA-SC-end          S-FN^>
macro-to-key    CUA-SC-end          A-FN2

store-procedure CUA-S-pageup
    run CUA-anchor
    previous-page
!endm
macro-to-key    CUA-S-pageup        S-FNZ
macro-to-key    CUA-S-pageup        S-FN3

store-procedure CUA-S-pagedown
    run CUA-anchor
    next-page
!endm
macro-to-key    CUA-S-pagedown      S-FNV
macro-to-key    CUA-S-pagedown      S-FN4

store-procedure CUA-S-up
    run CUA-anchor
    !force previous-line
!endm
macro-to-key    CUA-S-up            S-FNP
macro-to-key    CUA-S-up            S-FN6

store-procedure CUA-S-down
    run CUA-anchor
    !force next-line
!endm
macro-to-key    CUA-S-down          S-FNN
macro-to-key    CUA-S-down          S-FN7

store-procedure CUA-S-left
    run CUA-anchor
    !force backward-character
!endm
macro-to-key    CUA-S-left          S-FNB
macro-to-key    CUA-S-left          S-FN5

store-procedure CUA-S-right
    run CUA-anchor
    !force forward-character
!endm
macro-to-key    CUA-S-right         S-FNF
macro-to-key    CUA-S-right         S-FN8

store-procedure CUA-SC-left
    run CUA-anchor
    !force previous-word
!endm
macro-to-key    CUA-SC-left         S-FN^B
macro-to-key    CUA-SC-left         A-FN5

store-procedure CUA-SC-right
    run CUA-anchor
    !force next-word
!endm
macro-to-key    CUA-SC-right        S-FN^F
macro-to-key    CUA-SC-right        A-FN8

bind-to-key     beginning-of-file   FN^<
bind-to-key     beginning-of-file   FN^1    ; for consistency only
bind-to-key     end-of-file         FN^>
bind-to-key     end-of-file         FN^2    ; for consistency only
bind-to-key     beginning-of-line   FN<
bind-to-key     end-of-line         FN>

; Transfer the standard MicroEMACS left mouse button commands onto the 
; right button (text scrolling, window resizing, screen move/resize...)
; and the old right button commands to Shift + right button
!force unbind-key  MS1  ; should have been MS^A anyway!
bind-to-key mouse-move-down     MSe     ; right_button_down
bind-to-key mouse-move-up       MSf     ; right_button_up
bind-to-key mouse-resize-screen MS^E    ; Ctrl + right_button_down
bind-to-key mouse-region-down   MSE     ; Shift + right_button_down
bind-to-key mouse-region-up     MSF     ; Shift + right_button_up

store-procedure MSleft-down
    set %discmd $discmd
    set $discmd FALSE
    !force mouse-move-down
    !if $status
        set %keepanchor TRUE
        9 set-mark
        set %msbuf $cbufname
    !else
        set %msbuf ""
        !force 9 remove-mark
    !endif
    set $discmd %discmd
!endm
macro-to-key MSleft-down    MSa

store-procedure MSleft-up
    set %discmd $discmd
    set $discmd FALSE
    !force mouse-move-down
    !if &and $status &seq %msbuf $cbufname
        set %keepanchor TRUE
    !else
        !force 9 remove-mark
    !endif
    set $discmd %discmd
!endm
macro-to-key MSleft-up      MSb

store-procedure S-MSleft
    run CUA-anchor
    !force mouse-move-down  
!endm
macro-to-key S-MSleft       MSA
macro-to-key S-MSleft       MSB
