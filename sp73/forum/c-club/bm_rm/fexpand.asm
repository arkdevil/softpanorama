;fexpand() - Convert a relative pathname to a fully qualified name.
;
;Syntax: int fexpand (char *relname, char *absname);
;
;relname = ASCIIZ relative pathname to expand
;absname = ASCIIZ absolute pathname with drive I.D. and full directory path
;
;Return value: 0 = no errors detected (does not necessarily mean path is OK)
;              3 = invalid directory path
;             15 = invalid drive I.D.
;
;Letters in the pathname will be capitalized, and any occurrances of '/' will 
;be converted to '\'.  If the drive I.D. is missing, the current default 
;drive I.D. will be prepended.  Occurrances of '.' and '..' will be expanded 
;appropriately.  Directory and file names will be truncated to 8 characters, 
;file name extensions to 3 characters.  The absolute pathname will not be 
;allowed to exceed 80 characters, including the final zero byte.
;
;This function is similar to the undocumented DOS call INT 21H, AH = 60H, 
;but it may be used with DOS 2.0 and up whereas the DOS call was only 
;introduced with DOS 3.0.
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

outchars dw ?           ;Number of chars in output string so far.

;While we are in the process of copying a directory name, file name, or file 
;name extension from the relative pathname to the absolute pathname, trunc 
;tells us how many more characters to copy before we start truncating.

trunc    db ?

        .CODE

fexpand proc uses bx cx ds es si di, relname:ptr, absname:ptr

;Set up pointers to input and output buffers.

if @DataSize
        lds si,relname          ;Far pointers
        les di,absname
else
        mov si,relname          ;Near pointers
        mov di,absname
        push ds
        pop es
endif

        cld
        or [si], byte ptr 0     ;If input string is empty, quit.
        jnz @F
        jmp eos

@@:     mov trunc,8             ;Initial name will be directory or file name.

;If drive I.D. is given in the input string, copy it to the output string.
;Otherwise write the default drive I.D. to the output string.

        cmp [si+1], byte ptr ':' ;Look for drive I.D. 
        jne @F
        lodsw                    ;Found it: capitalize and copy it.
        and al,223
        stosw
        jmp short start

@@:     mov ah,19H      ;Get default drive ID.
        int 21H
        add al,'A'      ;Write it to the output string.
        mov ah,':'
        stosw

;If next character is not a path delimiter, we must insert the current default 
;directory name here.

start:  lodsb
        call fexchar
        cmp al,'\'
        jne nodir

;Starting directory was specified.

        stosb           ;Save the '\'.
        mov outchars,3  ;3 chars in output buffer so far.
        jmp short rdloop

;Starting directory was not specified, so insert default directory into output.

nodir:  dec si          ;We'll re-read this char later.
        mov al,'\'      ;Store leading backslash.
        stosb

        mov bx,absname  ;Get drive I.D. to find default path for.
        mov dl,[bx]
        sub dl,'@'
        push si
        mov si,di
        mov ah,47H      ;Get path in output buffer.
        int 21H
        pop si
        jnc @F          ;If we can't get it, the drive ID is invalid.
        mov ax,0FH
        jmp endstr

@@:     mov di,absname  ;Find the end of the output string.
        mov outchars,0
        xor al,al       ;String ends with a zero byte.
        mov cx,80
        repne scasb
        mov cx,di
        sub cx,absname
        mov outchars,cx
        dec di

gotend: cmp [di-1], byte ptr '\'  ;If appropriate, append '\' to directory path.
        je rdloop
        cmp [si], byte ptr 0
        jne @f
        jmp eos
@@:     mov al,'\'
        stosb
        inc outchars

;-------------------------------------------------------------------------------
;Expand and copy the rest of the directory path.

rdloop: lodsb           ;Get next character and normalize it.
        call fexchar

        or al,al        ;Watch for end of string.
        jnz @F
        jmp eos

@@:     cmp al,'\'      ;Watch for path delimiters.
        jne @F
        mov trunc,9     ;New name, so reset truncation counter.
        jmp short store

@@:     cmp al,'.'      ;Watch for '.' and '..' entries.
        jne store

;If it isn't the first char, and it doesn't follow a colon or path delimiter, 
;it prefixes a file name extension so reset the truncation counter and copy it.

        cmp [di-1], byte ptr ':'
        je @F
        cmp [di-1], byte ptr '\'
        je @F
        mov trunc,4
        jmp short store

@@:     lodsb           ;Get char following the dot.
        call fexchar
        or al,al        ;Watch out for end of string.
        jnz @F
        cmp [di-2], byte ptr ':'        ;'.',0: Remove slash at end of path.
        je eos
        dec di
        jmp short eos

@@:     cmp al,'\'      ;For '\.\' omit the '.\' after the '\'.
        je rdloop

        cmp al,'.'      ;Otherwise it must be '\..\' or '\..',0 or it's illegal.
        jne direrr
        lodsb
        or al,al
        jz @F
        call fexchar
        cmp al,'\'
        jne direrr

@@:     cmp [di-2], byte ptr ':'  ;If we're at the root, '..' is invalid.
        je direrr
        mov cx,14
        std
        mov al,'\'
        repne scasb
        repne scasb
        inc di          ;Point to the backslash.
        cld
@@:     dec si          ;Read the final '\' or '/' or 0 again and deal with it.
        jmp short rdloop

store:  cmp trunc,0     ;Check if we're truncating characters.
        jz @F
        dec trunc       ;Decrement truncation counter.

        cmp outchars,79 ;Check if we've exceeded the maximum legal path length.
        ja direrr
        inc outchars    ;Increment output character count.

        stosb           ;Copy char to output string.
@@:     jmp rdloop      ;Go back for next char.

direrr: mov ax,3
        jmp short endstr

;-------------------------------------------------------------------------------
;We've reached the end of [d:][path][\].

eos:    cmp [di-1], byte ptr ':'  ;If output ends in a colon, append '\'.
        jne @F
        mov al,'\'
        stosb
@@:     xor ax,ax       ;Return a zero to indicate success.

endstr: push ax
        xor al,al       ;Terminate output string and exit.
        stosb
        pop ax
        ret

fexpand endp

;-------------------------------------------------------------------------------
;fexchar() - Called by fexpand(): Normalize the character in AL.
;
;Convert '/' to '\' and capitalize letters.

fexchar proc
        cmp al,'/'      ;Normalize path delimiters.
        jne @F
        mov al,'\'
        jmp short exit

@@:     cmp al,'a'      ;Is it a lower case letter?
        jb exit
        cmp al,'z'
        ja exit
        and al,223      ;Capitalize the letter.
exit:
        ret
fexchar endp
        end
