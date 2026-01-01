;getmode() - Get the attributes of a specified file
;
;Syntax: int getmode (char *pathname);
;
;pathname = ASCIIZ pathname of file whose attributes are to be returned.
;
;Return value: -1 = file not found
;              Otherwise, high byte is zero and low byte holds attributes
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
;Version 1.0          July, 1989          MASM 5.1

        DOSSEG
        .MODEL small,C
        .CODE

getmode proc uses ds cx dx, pathname:ptr

;Get pointer to path name in DS:DX.

if @DataSize
        lds dx,pathname         ;Far pointer
else
        mov ax,@data            ;Near pointer
        mov ds,ax
        mov dx,pathname
endif

        mov ax,4300H            ;DOS "chmod" call.
        int 21H
        jnc @F
        mov ax,-1
        jmp short exit

@@:     mov ax,cx
        xor ah,ah

exit:
        ret
getmode endp
        end
