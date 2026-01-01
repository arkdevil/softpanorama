; The following sorce code is derived from Info-Zip 'zip' 2.01
; distribution copyrighted by Mark Adler, Richard B. Wales,
; Jean-loup Gailly, Kai Uwe Rommel, Igor Mandrichenko and John Bush.

; match.asm by Jean-loup Gailly.

; match.asm, optimized version of longest_match() in deflate.c
; Must be assembled with masm -ml. To be used only with C compact model
; or large model. (For large model, assemble with -D__FAR__).
; This file is only optional. If you don't have masm or tasm, use the
; C version (add -DNO_ASM to CFLAGS in makefile.msc and remove match.obj
; from OBJI). If you have reduced WSIZE in zip.h, then change its value
; below.
;
; Turbo C 2.0 does not support static allocation of more than 64K bytes
; per file. So TC and BC++ users must use:
;   tasm -ml -DDYN_ALLOC match;
;
; To simplify the code, the option -DDYN_ALLOC is supported for OS/2 only
; if the arrays are guaranteed to have zero offset (allocated by halloc).

        ifdef   __FAR__
arglist         equ    ss:[bp+6]

program         macro   progname
                public  progname
progname        proc    far
                endm
        else
arglist         equ    ss:[bp+4]

program         macro   progname
                public  progname
progname        proc    near
                endm
        endif

ifndef DYN_ALLOC
        extrn   _prev         : word
        extrn   _window       : byte
        prev    equ  _prev    ; offset part
        window  equ  _window
endif

_DATA   segment  word public 'DATA'
ifdef DYN_ALLOC
        extrn   _prev         : word
        extrn   _window       : word
        prev    equ 0         ; offset forced to zero
        window  equ 0
        window_seg equ _window[2]
        window_off equ 0
        prev_seg   equ _prev[2]
else
        window_seg dw  seg _window
        window_off equ offset _window
        prev_seg   dw  seg _prev     ; pointer to the prev array
endif
        extrn   _nice_match   : word
        extrn   _match_start  : word
        extrn   _prev_length  : word
        extrn   _good_match   : word
        extrn   _strstart     : word
        extrn   _max_chain_length : word
_DATA   ends

DGROUP  group _DATA

_TEXT   segment word public 'CODE'
        assume  cs: _TEXT, ds: DGROUP

        MIN_MATCH     equ 3
        MAX_MATCH     equ 258
        WSIZE         equ 32768         ; keep in sync with zip.h !
        MIN_LOOKAHEAD equ (MAX_MATCH+MIN_MATCH+1)
        MAX_DIST      equ (WSIZE-MIN_LOOKAHEAD)

; initialize or check the variables used in match.asm.

        program _match_init
ifdef DYN_ALLOC
        mov     ax,_prev[0]
        or      ax,_window[0]   ; verify zero offset(s) - both in a turn
else
        xor     ax,ax
endif
        ret
_match_init endp

; Set match_start to the longest match starting at the given string and
; return its length. Matches shorter or equal to prev_length are discarded,
; in which case the result is equal to prev_length and match_start is
; garbage.
; IN assertions: cur_match is the head of the hash chain for the current
;   string (strstart) and its distance is <= MAX_DIST, and prev_length >= 1

; int longest_match(cur_match)

        program _longest_match

        push    bp
        mov     bp,sp
        push    di
        push    si
        push    ds

ifdef __FAR__
        cur_match    equ word ptr [bp+6] ; [bp+6] for large model
else
        cur_match    equ word ptr [bp+4] ; [bp+4] for compact model
endif

;       window       equ es:window (es:0 for DYN_ALLOC)
;       prev         equ ds:prev
;       match        equ es:si
;       scan         equ es:di
;       chain_length equ bp
;       best_len     equ bx
;       limit        equ dx

        mov     si,arglist[0]   ; = cur_match (use bp before it is destroyed)
        mov     bp,_max_chain_length    ; chain_length = max_chain_length
        mov     di,_strstart
        mov     dx,di
        sub     dx,MAX_DIST             ; limit = strstart-MAX_DIST
        jae     limit_ok
        sub     dx,dx                   ; limit = NIL
limit_ok:
        add     di,2+window_off         ; di = offset(window + strstart + 2)
        mov     bx,_prev_length         ; best_len = prev_length
        mov     es,window_seg
        mov     ax,es:[bx+di-3]         ; ax = scan[best_len-1..best_len]
        mov     cx,es:[di-2]            ; cx = scan[0..1]
        cmp     bx,_good_match          ; do we have a good match already?
; Note: DS still points to static data (DGROUP)
        mov     ds,prev_seg             ; (does not destroy the flags)
        jb      do_scan                 ; good match?
        shr     bp,1                    ; chain_length >>= 2
        shr     bp,1
        jmp     short do_scan

        even                            ; align destination of branch
long_loop:
; at this point, es:di == scan+2, es:si == cur_match
        mov     ax,es:[bx+di-3]         ; ax = scan[best_len-1..best_len]
        mov     cx,es:[di-2]            ; cx = scan[0..1]
; Note: DS always points to static data here
        mov     ds,prev_seg             ; reset ds to address the prev array
        assume  ds: nothing
short_loop:
; at this point, di == scan+2, si = cur_match,
; ax = scan[best_len-1..best_len] and cx = scan[0..1]
if (WSIZE-32768)
        and     si,WSIZE-1              ; not needed if WSIZE=32768
endif
        shl     si,1                    ; cur_match as word index
        mov     si,prev[si]             ; cur_match = prev[cur_match]
        cmp     si,dx                   ; cur_match <= limit ?
        jbe     the_end
        dec     bp                      ; --chain_length
        jz      the_end
do_scan:
        cmp     ax,word ptr es:window[bx+si-1] ; check match at best_len-1
        jne     short_loop
        cmp     cx,word ptr es:window[si]      ; check min_match_length match
        jne     short_loop

        lea     si,window[si+2]         ; si = match
        mov     ax,di                   ; ax = scan+2
        mov     cx,es
        mov     ds,cx                   ; ds = es = window
        mov     cx,(MAX_MATCH-2)/2      ; scan for at most MAX_MATCH bytes
        repe    cmpsw                   ; loop until mismatch
        je      maxmatch                ; match of length MAX_MATCH?
mismatch:
        mov     cl,[di-2]               ; mismatch on first or second byte?
        sub     cl,[si-2]               ; cl = 0 if first bytes equal
        xchg    ax,di                   ; di = scan+2, ax = end of scan
        sub     ax,di                   ; ax = len
        sub     si,ax                   ; si = cur_match + 2 + offset(window)
        sub     si,2+window_off         ; si = cur_match
        sub     cl,1                    ; set carry if cl == 0 (can't use DEC)
        adc     ax,0                    ; ax = carry ? len+1 : len
        pop     ds                      ; DS now points to static data
        assume  ds: DGROUP
        push    ds                      ; restore stack
        cmp     ax,bx                   ; len > best_len ?
        jle     long_loop
        mov     _match_start,si         ; match_start = cur_match
        mov     bx,ax                   ; bx = best_len = len
        cmp     ax,_nice_match          ; len >= nice_match ?
        jl      long_loop
the_end:
        pop     ds
        pop     si
        pop     di
        pop     bp
        mov     ax,bx                   ; result = ax = best_len
        ret

        even
maxmatch:                               ; come here if maximum match
        cmpsb                           ; increment si and di
        jmp     mismatch                ; force match_length = MAX_LENGTH

_longest_match  endp

_TEXT   ends
end
