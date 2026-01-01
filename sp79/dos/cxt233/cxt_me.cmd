;*****************************************************************************
;
;   CXT_ME.CMD - MicroEMACS MACRO FUNCTIONS FOR
;
;       CSTN (TM) C STRUCTURE TREE NAVIGATOR
;       CFTN (TM) C FUNCTION TREE NAVIGATOR
;
;   Copyright (C) Juergen Mueller (J.M.) 1992-1995
;   All rights reserved.
;
;   You are expressly prohibited from selling this software in any form,
;   distributing it with another product, or removing this notice.
;
;   Limited permission is given to registered CXT users to modify this
;   file for their own personal use only. This file may not be used for any
;   purpose other than in conjunction with the CXT software package.
;
;   THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
;   EITHER EXPRESSED OR IMPLIED, INCLUDING, WITHOUT LIMITATION, THE
;   IMPLIED WARRANTIES OF MERCHANTIBILITY OR FITNESS FOR A PARTICULAR
;   PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE
;   PROGRAM AND DOCUMENTATION IS WITH YOU.
;
;   written by: Juergen Mueller, Aldingerstrasse 22, D-70806 Kornwestheim,
;               GERMANY
;
;   FILE       : CXT_ME.CMD
;   REVISION   : 26-Mar-1995
;                12:43:59
;
;*****************************************************************************

; NOTE: for OS/2 you should exchange "cftn" with "cftn4os2"
; NOTE: for OS/2 you should exchange "cstn" with "cstn4os2"
; NOTE: for NT you should exchange "cftn" with "cftn4nt"
; NOTE: for NT you should exchange "cstn" with "cstn4nt"

;*****************************************************************************
;**** write initial message ****
;*****************************************************************************
write-message "Loading CXT macro package"

;*****************************************************************************
;**** macro package initialization section ****
;*****************************************************************************
set %cxt_item ""                ; set internal variables
set %cxt_file ""
set %cxt_line ""
set %cxtn_cmd ""
set %char_set "_$abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

set %cft_base &env "CFTNBASE"   ; get environment variables, if set
!if &seq &len %cft_base 0
  set %cft_base &env "CXTNBASE"

  !if &seq &len %cft_base 0
    set %cft_base ""
  !endif
!endif

set %cst_base &env "CSTNBASE"   ; get environment variables, if set
!if &seq &len %cst_base 0
  set %cst_base &env "CXTNBASE"

  !if &seq &len %cst_base 0
    set %cst_base ""
  !endif
!endif

;*****************************************************************************
;**** definition of user macros ****
;*****************************************************************************

;**** find function ****
store-procedure cft
        execute-procedure _extract_item         ; get tagged item
        execute-procedure _cxt_cft
!endm

;**** find data type ****
store-procedure cst
        execute-procedure _extract_item         ; get tagged item
        execute-procedure _cxt_cst
!endm

;**** find function ****
store-procedure cftmark
        execute-procedure _extract_marked_item  ; get marked item
        execute-procedure _cxt_cft
!endm

;**** find function ****
store-procedure cstmark
        execute-procedure _extract_marked_item  ; get marked item
        execute-procedure _cxt_cst
!endm

;**** find function ****
store-procedure cftfind
        set %cxt_item "CFT function name: "
        set %cxt_item @%cxt_item                ; get user input
        execute-procedure _cxt_cft
!endm

;**** find data type ****
store-procedure cstfind
        set %cxt_item "CST data type name: "
        set %cxt_item @%cxt_item                ; get user input
        execute-procedure _cxt_cst
!endm

;**** set CFT database name ****
store-procedure cftbase
        set %cft_base "CFT database name: "
        set %cft_base @%cft_base                ; get user input
!endm

;**** set CST database name ****
store-procedure cstbase
        set %cst_base "CST database name: "
        set %cst_base @%cst_base                ; get user input
!endm

;**** set CFT and CST database name ****
store-procedure cxtbase
        set %cxt_base "CFT and CST database name: "
        set %cxt_base @%cxt_base                ; get user input
        set %cft_base %cxt_base
        set %cst_base %cxt_base
!endm

;**** CFT file list
store-procedure cftfile
        write-message "Extracting CFT filelist"

        !if &not &seq &len %cft_base 0
          set %tmp &cat &cat "-f" %cft_base " "         ; database access path
        !else
          set %tmp ""
        !endif

        set %cxtn_cmd &cat "cftn -F " %tmp
        pipe-command %cxtn_cmd          ; perform database access, shell command
!endm

;**** CST file list
store-procedure cstfile
        write-message "Extracting CST filelist"

        !if &not &seq &len %cst_base 0
          set %tmp &cat &cat "-f" %cst_base " "         ; database access path
        !else
          set %tmp ""
        !endif

        set %cxtn_cmd &cat "cstn -F " %tmp
        pipe-command %cxtn_cmd          ; perform database access, shell command
!endm

;*****************************************************************************
;**** internal macro execution functions ****
;*****************************************************************************

;*****************************************************************************
;* CFT front-end *
;*****************************************************************************
store-procedure _cxt_cft
        !if &seq &len %cxt_item 0
          write-message "No function selected"
          !return
        !endif

        write-message &cat &cat "Searching for function: '" %cxt_item "'"

        !if &not &seq &len %cft_base 0
          set %tmp &cat &cat "-f" %cft_base " "         ; database access path
        !else
          set %tmp ""
        !endif

        set %cxtn_cmd &cat &cat "cftn -b " %tmp %cxt_item
        execute-procedure _cxt_search                   ; start search
!endm

;*****************************************************************************
;* CST front-end *
;*****************************************************************************
store-procedure _cxt_cst
        !if &seq &len %cxt_item 0
          write-message "No data type selected"
          !return
        !endif

        write-message &cat &cat "Searching for data type: '" %cxt_item "'"

        !if &not &seq &len %cst_base 0
          set %tmp &cat &cat "-f" %cst_base " "         ; database access path
        !else
          set %tmp ""
        !endif

        set %cxtn_cmd &cat &cat "cstn -b " %tmp %cxt_item
        execute-procedure _cxt_search                   ; start search
!endm

;*****************************************************************************
;* the database retrieval function *
;*****************************************************************************
store-procedure _cxt_search
        set %cxt_file ""                ; clear variables
        set %cxt_line ""

!force  pipe-command %cxtn_cmd          ; perform database access, shell command
        !if &seq $status FALSE
          !return
        !endif

!force  select-buffer command           ; get result buffer from pipe-command
        !if &seq $status FALSE
          !return
        !endif

!force  beginning-of-file               ; go to file begin
        !if &seq $status FALSE
          !return
        !endif

        set-mark                        ; extract target file name

!force  search-forward " "              ; search for first blank after file name
        !if &seq $status FALSE
          !return
        !endif

        backward-character
        copy-region
        set %cxt_file $kill             ; store target file name
        forward-character
        set-mark                        ; extract target file line
        end-of-line
        copy-region
        set %cxt_line $kill             ; store target file line

!force  delete-window                   ; delete command window
!force  delete-buffer command           ; delete command buffer
!force  next-buffer                     ; switch to next buffer just to hide command buf

        !if &not &exist %cxt_file       ; test if file exists
          write-message &cat &cat "Target file ~"" %cxt_file "~" not found"
          !return
        !endif

!force  find-file %cxt_file             ; open target file

        !if &seq $status TRUE
!force    goto-line %cxt_line           ; jump to target line

          !if &seq $status FALSE
            clear-message-line
            !return
          !endif

          delete-other-windows          ; just for safety
          redraw-display                ; center target line
          clear-message-line
        !endif
!endm

;*****************************************************************************
;* read search item from current buffer *
;*****************************************************************************
store-procedure _extract_item
        set %cxt_item ""                ; clear variable

        !if &seq &sindex %char_set &chr $curchar 0
          !return                       ; not on a valid character
        !endif

!force  end-of-word

        !while TRUE
!force  previous-word
!force  backward-character
        !if &seq &sindex %char_set &chr $curchar 0
!force    forward-character
          !break
        !endif
        !endwhile

        set-mark                        ; mark first item character

        !while TRUE
!force  end-of-word                     ; goto end of item
        !if &seq &sindex %char_set &chr $curchar 0
          !break
        !endif
        !endwhile

        copy-region
        set %cxt_item $kill             ; store item name
!endm

;*****************************************************************************
;* read marked search item *
;*****************************************************************************
store-procedure _extract_marked_item
        set %cxt_item ""                                ; clear variable
!force  copy-region
        set %cxt_item $kill                             ; store item name

        !if &not &seq &len %cxt_item 0
          set %cxt_item &cat &cat "~"" %cxt_item "~""   ; quote
        !endif
!endm

;*****************************************************************************
;* bind macros to WINDOWS menu, only if MicroEMACS for WINDOWS is present *
;*****************************************************************************
!if &seq $sres "MSWIN"          ; test, if this is running under MS Windows
  ; insert separator
  bind-to-menu  nop     ">&Miscellaneous>-@5"

  ; create a new underlying pop-up menu for the CFT macros
  macro-to-menu cft     ">&Miscellaneous>C&FT macros@6>CFT &function search@0"
  macro-to-menu cftmark "CFT function search &mark"
  macro-to-menu cftfind "CFT function search &prompt"
  macro-to-menu cftfile "CFT file&list"
  macro-to-menu cftbase "CFT data&base name"
  macro-to-menu cxtbase "CFT and CST database &name"

  ; create a new underlying pop-up menu for the CST macros
  macro-to-menu cst     ">&Miscellaneous>C&ST macros@7>CST &data type search@0"
  macro-to-menu cstmark "CST data type search &mark"
  macro-to-menu cstfind "CST data type search &prompt"
  macro-to-menu cstfile "CST file&list"
  macro-to-menu cstbase "CST data&base name"
  macro-to-menu cxtbase "CFT and CST database &name"
!endif

;*****************************************************************************
;**** write final message ****
;*****************************************************************************
write-message "CXT macro package loaded"

;**** THIS IS THE END THIS IS THE END THIS IS THE END THIS IS THE END ****

