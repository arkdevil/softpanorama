;-REXX88EX.ASM-----------------------------------------------------------------;
; Sample rexx extension program.                                               ;
;                                                                              ;
; This module provides a function named "uppercase" which returns its arguments;
; uppercased and concatenated into a single string.                            ;
;                                                                              ;
; To assemble, link, and install this module as an extension to rexx88r,       ;
; execute the following rexx program:                                          ;
;                                                                              ;
; /* make rexx extension */                                                    ;
; 'masm rexx88ex,rexx88ex,nul,nul'  /* assemble */                             ;
; 'link rexx88ex,rexx88ex,nul,nul'  /* link */                                 ;
; 'exe2bin rexx88ex rexx88ex.com'   /* convert into a com file */              ;
; 'erase rexx88ex.obj'              /* get rid of intermediate file */         ;
; 'erase rexx88ex.exe'              /* get rid of intermediate file */         ;
; 'rexx88ex'                        /* install */                              ;
;                                                                              ;
;       Original code by Derek Lieber                                          ;
;                                                                              ;
;       Updated 6/23/87 by Sam Detweiler                                       ;
;                                                                              ;
;       Added check for LOADED function request (ax==7)                        ;
;       Added code to check for first in chain and handle accordingly          ;
;                                                                              ;
;------------------------------------------------------------------------------;
PROGRAMSEG      segment para public
                assume cs:PROGRAMSEG, ds:PROGRAMSEG

                org 100H

begin:  jmp     start

;-----------------------------------------------------------------------------
; Data area
;-----------------------------------------------------------------------------
rexxchain       dd      0               ;link to next rexx extension in chain
myname          db      "uppercase",0   ;name of the function we're supplying
installed_byte  db      '1',0           ;used for ax=7 call
not_installed   db      '0',0           ;used for ax=7 call when we are first
save_call       dw      0               ; place to save request code
RESULT_BUF      equ     0               ;buffer for building result strings
                                        ;(we'll re-use our program segment
                                        ; prefix)

;-----------------------------------------------------------------------------
; Code area
;-----------------------------------------------------------------------------
REXX_VECTOR     equ     7CH             ;rexx communication vector
REXX_CALL       equ     5               ;rexx 'call an extension' subfunction
REXX_FUNCLOADED equ     7               ;rexx 'check for extension loaded

start:

        ;find current head of rexx control chain

        xor     ax,ax
        mov     es,ax
        mov     ax,es:[REXX_VECTOR * 4]
        mov     word ptr rexxchain,ax
        mov     ax,es:[REXX_VECTOR * 4 + 2]
        mov     word ptr rexxchain + 2,ax

        ;make ourself the new head

        mov     word ptr es:[REXX_VECTOR * 4],offset myfunction
        mov     word ptr es:[REXX_VECTOR * 4 + 2],cs

        ;terminate, but remain resident

        mov     dx,offset program_end   ;pick up our program size (bytes)
        mov     cl,4
        shr     dx,cl                   ;convert to paragraphs
        inc     dx                      ;round up
        mov     ax,3100H                ;terminate-but-remain-resident
        cld                             ;(<--- fix DOS bug)
        int     21H
        jmp     $                       ;should never get here

;
; Sample rexx extension
;
; This sample function simply concatenates its arguments into a string,
; shifting them to upper case in the process.
; It might be invoked from rexx via the statment:
;               say uppercase(one, two, three, ...)
;
; On entry:     <ax> == 5 if this is a call to a rexx extension
;               <ss:bp> points to a stackframe containing the function name,
;               the number of arguments, and a pointer to an array of pointers
;               to null terminated argument strings. This "argc, argv" structure
;               should be familiar to C programmers.
;               <ax> == 7 then this is a request to see if the function is
;                       loaded. if names match respond pointing to '1',0
;
;
;
;
; On exit:      <ax>==5 <ds:si> points to a null terminated result string
;               <ax>==7 <ds:si> points to '1',0
;
;               (we are installed BELOW REXX processor)
;
;               if previous vector 0:0 then for above
;
;               <ax>==5 ds:si equals 0:0
;               <ax>==7 ds:si points to '0',0
;               ax=-1 and carry set
;
; Notes:        1. if ax <> 5 or the function name isn't one we're interested
;                  in, we pass control up the rexx control chain
;               2. we don't check for string buffer overflow but we really
;                  should
;

otherfunction:
        cmp     cs:rexxchain,0                  ; previous link 0?
        jne     ok_to_go_on                     ; no, let it look up the answer
        cmp     ax,REXX_CALL                    ; was this a 'call request'?
        jne     try_loaded                      ; no try loaded
        mov     si,0                            ; no extesnion answered
        mov     ds,si                           ; the call
        jmp     otherdone                       ; done
try_loaded:
        cmp     ax,REXX_FUNCLOADED              ; extension loaded request?
        jne     otherdone                       ; no
        mov     si,offset cs:not_installed      ; say extension not installed
        push    cs                              ;
        pop     ds                              ;
otherdone:
        mov     ax,-1                           ; set error return code
        push    bp                              ; set carry flag
        mov     bp,sp                           ; in callers
        or      word ptr [bp+6],1               ; flags on stack
        pop     bp                              ;
        iret                                    ; and iret preserving int status
ok_to_go_on:
        jmp     cs:[rexxchain]          ;pass control up the rexx control chain

myfunction:

        ;see if this function call is for us

        cmp     ax,REXX_CALL            ;rexx 'call extension' subfunction?
        je      dofunc
        cmp     ax,REXX_FUNCLOADED      ;rexx 'extension loaded' subfunction?
        jne     otherfunction           ;no...
        mov     cs:save_call,ax         ; save function code
dofunc:
        push    ss
        pop     ds                      ;source segment
        mov     si,0[bp]                ;point to function name
        push    cs
        pop     es                      ;destination segment
        mov     di,offset myname        ;point to name we're looking for
        call    scompare                ;are they the same?
        mov     ax,save_call            ;(restore subfunction number)
        jc      otherfunction           ;no...
        cmp     ax,REXX_FUNCLOADED      ;loaded request?
        jne     dofunc1                 ; nope, must be call
        mov     si,offset installed_byte ; point to '1' answer
        push    cs                      ; in code segment
        pop     ds                      ;
        iret                            ; and done

        ;gather arguments into a list, upper casing them
dofunc1:
        mov     cx,2[bp]                ;argument count
        mov     bx,4[bp]                ;argument pointer array
        mov     di,RESULT_BUF           ;destination buffer
        jcxz    done                    ;if no arguments, we're done...
gather: mov     si,[bx]                 ;point to the argument string
        call    supper                  ;upper case it into destination buffer
        mov     al,' '
        stosb                           ;append a blank
        add     bx,2                    ;point to next argument pointer in array
        loop    gather                  ;continue
done:   cmp     di,RESULT_BUF           ;is string empty?
        je      done1                   ;yes...
        dec     di                      ;point to trailing space
done1:  mov     al,0
        stosb                           ;null terminate the string
        push    cs
        pop     ds
        mov     si,RESULT_BUF           ;point <ds:si> to result
        iret

;
;Compare strings for equality, ignoring case
;
;Taken:         <ds:si> points to string 1
;               <es:di> points to string 2
;Returned:      'nc' indicates "equal", 'c' indicates "not equal"
;
scompare:
                cld
scomp1:         lodsb                   ;al := *string1++
                cmp     al,'A'          ;upper case letter?
                jb      scomp2          ;no...
                cmp     al,'Z'          ;upper case letter?
                ja      scomp2          ;no...
                or      al,20H          ;convert to lower case
scomp2:         mov     ah,es:[di]
                inc     di              ;ah := *string2++
                cmp     ah,'A'          ;upper case letter?
                jb      scomp3          ;no...
                cmp     ah,'Z'          ;upper case letter?
                ja      scomp3          ;no...
                or      ah,20H          ;convert to lower case
scomp3:         cmp     ah,al           ;equal?
                jne     scomp4          ;no...
                cmp     al,0            ;end of both strings?
                jne     scomp1          ;no...
                clc                     ;"strings are equal"
                ret
scomp4:         stc                     ;"strings are not equal"
                ret

;
;Uppercase a null terminated string
;Taken:         <ds:si> points to source
;               <es:di> points to destination
;Returned:      <es:di> points to null terminator at destination
;
supper:         cld
sup:            lodsb                   ;get char
                cmp     al,'a'          ;lower case letter?
                jb      sup1            ;no...
                cmp     al,'z'          ;lower case letter?
                ja      sup1            ;no...
                and     al,not 20H      ;convert to upper case
sup1:           stosb                   ;put char
                or      al,al           ;null terminator?
                jnz     sup             ;no...
                dec     di              ;point to null terminator
                ret

program_end     label byte              ;<< end of program marker >>
PROGRAMSEG      ends
                end     begin
