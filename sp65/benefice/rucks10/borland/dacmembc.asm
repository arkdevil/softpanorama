PAGE 81,132
;dac$malloc
;dac$free
;-----------------------------------------------------------------------|
;    ScanSoft          (C)1993 Cornel H Huth     ALL RIGHTS RESERVED    |
;-----------------------------------------------------------------------|
;     date:      27-Feb-94                                              |
; function:      Memory routines for C compilers                        |
;                that do not allow DOS allocations to be mixed with     |
;                _malloc allocations (including _calloc, etc.)          |
;    notes:      This malady afflicts Borland C compilers               |
;                All registers saved since there's no telling what      |
;                registers the runtime code uses                        |
;                                                                       |
;                                                                       |
;The code below will work in either LARGE or HUGE memory modules.       |
;It will not, as written, work in the medium model. With minor changes, |
;the medium model could be supported. Not needed, however, in the       |
;medium model.                                                          |
;                                                                       |
;This code was written with MASM 5.10A in mind though TASM should       |
;handle it, too.                                                        |
;                                                                       |
;To assemble:                                                           |
;                                                                       |
;       C>masm dacmembc /mx; (/mx=preserve case on globals)             |
;                                                                       |
;Then do the following:                                                 |
;                                                                       |
; Replace DACMEM.OBJ in RUCKDAC.LIB:                                    |
;                                                                       |
;        C>lib RUCKDAC -dacmem +dacmembc;                               |
;  -or-                                                                 |
;        C>tlib RUCKDAC -dacmem +dacmembc                               |
;        (requires TLIB.EXE version 3.00 or earlier)                    |
;                                                                       |
;Before doing anything, read the BORLAND.FIX text file. It documents    |
;what and how to make a Borland-workable RUCKDAC.LIB.                   |
;                                                                       |
;Note: This replacement module does not enable DOS-controlled UMBs as   |
;      the normal dac$malloc does. A safety call since I don't know how |
;      Borland's memory manager would deal with it.                     |
;                                                                       |
;Important: Unlike allocation through DOS (INT48), _malloc and _free    |
;           require DS->DGROUP                                          |
;-----------------------------------------------------------------------|
WPTR EQU <WORD PTR>

                .MODEL LARGE,PASCAL

                .CODE

EXTRN _malloc:FAR
EXTRN _free:FAR

                ;MAXTRACKER is the number of allocations that can be open at
                ;any one time. Consider each open file to require one Track.
                ;A good MAXTRACKER value would be the total number of files you
                ;require to be open at one time plus 5. Each MAXTRACKER
                ;requires 6 bytes of code space. Unless you're starving for
                ;RAM, MAXTRACKER is fine at 254 (uses about 1.5K of code space.)
                ;A mod file load can use up to 40 or so allocations!

MAXTRACKER EQU 254

                ;TrackerFP stores far pointers as returned by _malloc
                ;so that _free can be used (_free requires exact FP match)
EVEN
TrackerFP       dd MAXTRACKER DUP (0)   ;32-bit segmented pointer of _malloc
                dd 0                    ;and required by _free

                ;TrackerSeg stores the 16-bit segment pointer converted from
                ;the far pointer returned by _malloc. See dac$malloc for how
                ;this is done. This is used as a lookup value in dac$free.

TrackerSeg      dw MAXTRACKER DUP (0)   ;thunk it to a 16-bit segment pointer
                dw -1

;-----------------------------------------------------------------------|
;     date:      31-Jan-93                                              |
; function:      allocate memory                                        |
;   caller:      FAR, ASSEMBLY                                          |
;    stack:      n/a                                                    |
;       in:      bx=paragraphs to allocate                              |
;      out:      NC=ax=seg                                              |
;                CY=ax=8=not enough memory                              |
;     uses:      ax (return)                                            |
;    notes:      call with bx=FFFF and bx returns w/ largest block free |
;                (according to DOS)                                     |
;                                                                       |
;06-Mar-93-chh                                                          |
;-Need to preserve bx if making allocation since bx used as size to     |
; on return.                                                            |
;-For Huge Model mode need to first push element size, the long count...|
; ...Large model just ignores the first two pushes. MS C7 anyway.       |
;-Added DS reload                                                       |
;                                                                       |
;-----------------------------------------------------------------------|
dac$malloc      PROC USES cx dx si di es ds

                cmp     bx,-1           ;just asking for available memory?
                jne     dac$malloc01    ;no
                mov ah,48h              ;yes, regular DOS check should do
                int 21h                 ;though RUCKDAC never makes a memory
                jmp     SHORT dac$mallocXit ;inquiry...currently

dac$malloc01:   mov     cx,MAXTRACKER   ;scan for next free descriptor
                sub     ax,ax           ;0 indicates available
                push    cs
                mov     di,OFFSET TrackerSeg
                pop     es              ;es:di->TrackSeg start
                repne scasw
                jne     dac$mallocEx    ;none available
                mov     ax,di
                sub     ax,OFFSET TrackerSeg+2 ;ax=available slot (word)

                push    bx              ;RUCKUS needs this later
                push    ax              ;save slot

                sub     ax,ax
                inc     ax              ;(1) in case of huge model
                push    ax              ;put size on stack (char)
                dec     ax              ;(0) and high-word of elements
                push    ax              ;on stack (always 0 for RUCKUS)

                mov     ax,bx           ;paras requested
                inc     ax              ;bump para request so we can norm it
                shl     ax,1            ;(thunk it would be more like it)
                shl     ax,1
                shl     ax,1
                shl     ax,1            ;paras to bytes
                push    ax              ;low-word of request

                mov     ax,SEG DGROUP
                mov     ds,ax           ;_malloc runtime needs it

                call    _malloc         ;appease the Borland Gods
                add     sp,6            ;here dx:ax is far pointer to block

                pop     di              ;get back slot

                mov     bx,dx           ;check for null pointer return
                or      bx,ax           ;allocation okay?

                pop     bx              ;get size in paras back now
                jz      dac$mallocEx    ;no

                mov     si,di           ;word slot index for TrackerSeg
                shl     di,1            ;dword slot index for TrackerFP
                mov     WPTR cs:[TrackerFP+di],ax
                mov     WPTR cs:[TrackerFP+di+2],dx

                ;normalize the 32-bit pointer to a 16-bit segment pointer
                ;we can do this because we requested 1 additional paragraph
                ;so that we can just drop the normalized offset and start
                ;using the allocated memory block at the next paragraph

                ;;since we won't be using the fractional-para offset of the
                ;;norm'ed far pointer we can skip the overhead

                ;;mov     bx,ax           ;save full offset
                ;;and     ax,000Fh        ;non-paragraph portion
                ;;mov     cx,ax           ;ax is normalized offset
                ;;mov     ax,bx           ;get full offset back

                shr     ax,1            ;convert offset to full paras
                shr     ax,1
                shr     ax,1
                shr     ax,1
                add     ax,dx           ;add segment in
                inc     ax              ;bump to next paragraph
                mov     cs:[TrackerSeg+si],ax
                clc                     ;return 16-bit segment pointer in ax
dac$mallocXit:  ret                     ;that RUCKDAC will use

dac$mallocEx:   mov     ax,8
                stc
                jmp     SHORT dac$mallocXit

dac$malloc      ENDP

;-----------------------------------------------------------------------|
;     date:      31-Jan-93                                              |
; function:      free allocated memory                                  |
;   caller:      FAR, ASSEMBLY                                          |
;    stack:      n/a                                                    |
;       in:      es=segment pointer of block to free                    |
;      out:      NC=okay (at least this code, _free has not return code)|
;                CY=ax=9 invalid block (segment not in descriptor list  |
;     uses:      ax (return)                                            |
;    notes:      see dac$malloc above for more info                     |
;06-Mar-93-chh                                                          |
;-Added save of dword slot (di) before call to _free                    |
;-Added DS reload                                                       |
;-----------------------------------------------------------------------|
dac$free        PROC USES bx cx dx si di ds es

                mov     cx,MAXTRACKER   ;scan for matching descriptor
                mov     ax,es           ;search for this segment pointer
                push    cs
                mov     di,OFFSET TrackerSeg
                pop     es              ;es:di->TrackerSeg start
                repne scasw
                jne     dac$freeEx      ;not found, must be invalid block

                sub     ax,ax
                sub     di,OFFSET TrackerSeg+2  ;di=matched slot (word)

                push    di                      ;save word slot
                shl     di,1                    ;dword slot index
                push    di                      ;save dword slot

                push    WPTR cs:[TrackerFP+di+2];segment to block to release
                push    WPTR cs:[TrackerFP+di]  ;offset

                mov     ax,SEG DGROUP
                mov     ds,ax                   ;_free runtime needs it

                call    _free                   ;appease them some more
                add     sp,4

                sub     ax,ax
                pop     di                              ;get dword slot
                mov     WPTR cs:[TrackerFP+di+2],ax     ;clear descriptor info
                mov     WPTR cs:[TrackerFP+di],ax

                pop     di                              ;get word slot index
                mov     cs:[TrackerSeg+di],ax           ;make slot available
dac$freeXit:    ret

dac$freeEx:     mov     ax,9
                stc
                jmp     dac$freeXit
dac$free        ENDP

                END


