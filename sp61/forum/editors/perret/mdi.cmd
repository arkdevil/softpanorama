; Screen juggling macros for MicroEMACS 3.11c for Windows
;
; Pierre Perret - October 1992

rename-screen $cbufname
restore-screen
set %scrwidth 80    ; 75 is more appropriate for 640x480
%scrwidth  change-screen-width

set %filename ""
set %dropbuf "Dropped files"    ; special buffer used for drag'n drop
set %altbname 0     ; used to supply a replacement buffer name if duplicate

store-procedure open-file
; Reads files in separate screens, thus allowing efficient use of
; the MDI feature
    set %prevscr $scrname
    set %prevbuf $cbufname
    find-screen "Relay screen"
    select-buffer %prevbuf  ; to make sure we have the right working dir
    delete-other-windows
    !if &seq %filename ""
        !force execute-named-command find-file
    !else
        !force find-file %filename &cat "*" %altbname
        ; the second argument is there to supply an alternate buffer name
    !endif
    !if $status
*FileFound
        !if &seq $cbufname &cat "*" %altbname
            set %altbname &add %altbname 1  ; need a new one for next time...
        !endif
        set %tmp $cbufname
        set $scrname %tmp   ; switches screens only if named one exists
        !if &seq $scrname %tmp
            ; that screen already exists (we are now in it)
            set $curwind 1
            !while &not &seq $cbufname %tmp
                !if &equ $numwind $curwind
                    ; we cannot find the desired buffer in any window!
                    set $scrname "Relay screen"
                    set %tmp &cat %tmp "."
                    !force rename-screen %tmp
                    !while &not $status
                        set %tmp &cat %tmp "."
                        !force rename-screen %tmp
                    !endwhile
                    clear-message-line
                    !return
                !endif
                next-window
            !endwhile
            ; we found the right window within the existing screen
            !force delete-screen "Relay screen"
        !else
            ; that screen does not exist yet
            rename-screen $cbufname
            %scrwidth change-screen-width
        !endif
    !else
        ; find-file failed
        !if &seq $cbufname %prevbuf
            ; buf name did not change ==> file-find was canceled
            find-screen %prevscr
            !force delete-screen "Relay screen"
        !else
            ; buf name changed ==> it is a new file
            !goto FileFound
        !endif
    !endif
    set %filename ""
!endm
macro-to-key    open-file   ^X^F
unbind-menu     ">&File>&Open..."
macro-to-menu   open-file   "&Open...@0"

store-procedure rebuild-screens
; makes sure there is one screen per visible buffer
; does not affect screens whose name do not match an existing buffer
    find-screen "Relay screen"
    select-buffer "Relay screen"
    delete-other-windows
    minimize-screen
    !goto BufLoop
    !while &not &seq $cbufname "Relay screen"
*BufLoop
        find-screen "Relay screen"
        next-buffer
        !if &not &sin "Relay screenBinding listFunction listVariable list" $cbufname
            find-screen $cbufname
            select-buffer $scrname
            delete-other-windows
            restore-screen
        !endif
    !endwhile
    cascade-screens
    !if &seq $scrname "Relay screen"
        cycle-screens
    !endif
    !force delete-screen "Relay screen"
!endm
macro-to-menu   rebuild-screens ">S&creen>&Rebuild@0"

store-procedure kill-screen
    set %prevscr $scrname
    set %prevbuf $cbufname
    cycle-screens
    !force delete-screen %prevscr
    !if $status
        !force delete-buffer %prevbuf
    !endif
!endm
macro-to-key    kill-screen A-K
macro-to-menu   kill-screen     ">S&creen>&Kill@6"

store-procedure drop-files
    ; note that we pay no attention to the location of the drop
    set %prevbuf $cbufname
    select-buffer %dropbuf
    goto-line 2
    select-buffer %prevbuf
    set %filename #%dropbuf
    !while &not &seq %filename %dropbuf
        run open-file
        set %filename #%dropbuf
    !endwhile
    set %filename ""
!endm
macro-to-key    drop-files  MS!
