;findfile() - Find the first (or next) file matching a given specification.
;
;Syntax: int findfile (char *fspec, int attr, struct DTA *dta);
;
;fspec = ASCIIZ pathname, optionally including wildcard characters (find first)
;        or NULL pointer (find next)
;
;attr  = file attribute byte to use in the search
;
;dta   = pointer to a DTA structure to be filled in with directory information
;        for the next file which matches the pathname 
;
;Return value: Zero for success, or a DOS error code if no matching files found.
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
        .DATA

olddta  dw 2 dup (?)    ;Location of old DTA.
        .CODE

findfile proc uses bx cx dx ds es, fspec:ptr, attr:word, dta:ptr

        mov ax,@data
        mov ds,ax

        mov ah,2FH              ;Save the location of the existing DTA.
        int 21H
        mov olddta[2],es
        mov olddta,bx

;Get pointer to the DTA structure to be filled in.

if @DataSize                    ;Far pointer
        lds dx,dta
else                            ;Near pointer
        mov dx,dta
endif
        mov ah,1AH              ;Set up new DTA for file search.
        int 21H

        mov cx,attr             ;Get the search attribute in CX.

;Get pointer to file specification, if any.

if @DataSize                    ;Far pointer
        cmp fspec, word ptr 0   ;For null pointer, find next match, if any.
        jnz @F
        cmp fspec[2], word ptr 0
        jz getnext
@@:     lds dx,fspec
else                            ;Near pointer
        cmp fspec, word ptr 0   ;For null pointer, find next match, if any.
        jz getnext
        mov dx,fspec
endif

        mov ah,4EH              ;Search for first matching file.
        int 21H
        jmp short @F

getnext:mov ah,4FH              ;Search for next matching file.
        int 21H

@@:     pushf

        lds dx,dword ptr olddta ;Restore the old DTA.
        mov ah,1AH
        int 21H

        popf
        jc exit                 ;If we didn't find it, return error code.

        xor ax,ax               ;We found a file: return zero.
exit:
        ret
findfile endp
        end
