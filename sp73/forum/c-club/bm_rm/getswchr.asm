;getswchr() - Return the current system switch character (normally '/')
;
;Syntax: char getswchr (void);
;
;Requires DOS 2.0 or above.  An undocumented DOS call is used.
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

getswchr proc uses dx
        mov ax,3700H    ;Get current switch char in DL.
        int 21H
        xor ax,ax       ;Return it in AX, according to C calling conventions.
        mov al,dl
        ret
getswchr endp
        end
