;Write a character string to standard output.
;
;Syntax: int puts  (char *string); -- Write an ASCIIZ string and append newline
;        int putsc (char *string); -- Just write an ASCIIZ string as is
;        void putchar (char c);    -- Write a character
;        void newline (void);      -- Print carriage return and linefeed
;
;Note: putchar() does not expand '\n' to "\r\n" whereas puts() and putsc() do.
;
;Return value:  0 = no errors detected
;
;Copyright (C) 1989, 1990 Brian B. McGuinness
;                         15 Kevin Road
;                         Scotch Plains, NJ 07076
;
;These functions are free software; you can redistribute them and/or modify them
;under the terms of the GNU General Public License as published by the Free 
;Software Foundation; either version 1, or (at your option) any later version.
;
;These functions are distributed in the hope that they will be useful, but 
;WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
;FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more 
;details.
;
;You should have received a copy of the GNU General Public License along with 
;these functions; if not, write to the Free Software Foundation, Inc., 675 Mass 
;Ave, Cambridge, MA 02139, USA.
;
;Assemble this code with Microsoft Macro Assembler version 5.1 or higher:
;MASM /Mx puts;
;
;Version 1.0, August 1989 - Original version
;Version 1.1, May 1990    - Add putsc() and putchar() functions

        DOSSEG
        .MODEL small,C
        .DATA
crlf    db 13, 10, '$'  ;Carriage return and linefeed.
        .CODE


;-------------------------------------------------------------------------------
;puts() - Print an ASCIIZ string, then append a newline.

puts    proc proc uses si, string:ptr
if @DataSize
        lds si,string           ;Far pointer
else
        mov si,string           ;Near pointer
endif
        call doputs
        call newline
        ret
puts    endp

;-------------------------------------------------------------------------------
;putsc() - Print an ASCIIZ string, converting newline chars to CR, LF pairs.

putsc   proc uses si, string:ptr
if @DataSize
        lds si,string           ;Far pointer
else
        mov si,string           ;Near pointer
endif
        call doputs
        ret
putsc   endp

;-------------------------------------------------------------------------------
;doputs() - Print the ASCIIZ string pointed to by SI.

doputs  proc uses bx dx
        mov ax,4400H    ;Get device information for stdout.
        mov bx,1
        int 21H
        xor dh,dh       ;Save this information so we can restore it later.
        push dx

        test dl,80H     ;Check if it is a character device rather than a file.
        jz @F
        mov ax,4401H    ;It is (stdout wasn't redirected), so set raw mode on.
        or dl,00100000B
        int 21H

@@:     cld
prtloop:lodsb
        or al,al        ;Zero byte marks end of string.
        jz exit

        cmp al,10       ;Expand '\n' to "\r\n".
        jne normal
        call newline
        jmp short prtloop

normal: mov ah,2        ;Normal character: write it to stdout.
        mov dl,al
        int 21H
        jmp short prtloop

exit:   mov ax,4401H    ;Restore original mode for stdout.
        mov bx,1
        pop dx
        int 21H

        xor ax,ax       ;Exit with error code zero.
        ret
doputs  endp

;-------------------------------------------------------------------------------
;Print a carriage return and a linefeed.

newline proc uses dx
        mov dx,offset crlf
        mov ah,9
        int 21H
        ret
newline endp

;-------------------------------------------------------------------------------
;Print a single character.

putchar proc uses dx, c:word
        mov ah,2
        mov dx,c
        int 21H
        ret
putchar endp
        end
