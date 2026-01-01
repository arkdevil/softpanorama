;getkeyn() - Get the next keystroke, echo it, and print a newline.
;
;Syntax: int getkeyn (void);
;
;We return the high byte as 0 for normal characters, 0xFF for special chars.
;The character itself is returned in the low byte.
;
;Copyright (C) 1989 Brian B. McGuinness
;                   15 Kevin Road
;                   Scotch Plains, NJ 07076
;
;This function is free software; you can redistribute it and/or modify it under 
;the terms of the GNU General Public License as published by the Free Software 
;Foundation; either version 1, or (at your option) any later version.
;
;This function is distributed in the hope that it will be useful, but WITHOUT 
;ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
;FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more 
;details.
;
;You should have received a copy of the GNU General Public License along with 
;this function; if not, write to the Free Software Foundation, Inc., 675 Mass 
;Ave, Cambridge, MA 02139, USA.
;
;Version 1.01          August, 1989          MASM 5.1

        DOSSEG
        .MODEL small,C 
        .CODE

getkeyn proc uses dx
        mov ah,8        ;Get keystroke in AL.
        int 21H
        xor ah,ah
        mov dl,al

        or al,al        ;Is it an extended keycode?
        jnz @F

        mov ah,8        ;Yes, so get second half.
        int 21H
        mov ah,0FFH     ;Flag it as a special character.

@@:     push ax         ;If nonprinting char, don't print it.
        cmp ax,32
        jb crlf
        cmp ax,127
        jae crlf

@@:     mov ah,2        ;Print character (or blank for a special char).
        int 21H

crlf:   mov ah,2        ;Print CR, LF.
        mov dl,13
        int 21H
        mov dl,10
        int 21H
        pop ax
        ret
getkeyn endp
        end
