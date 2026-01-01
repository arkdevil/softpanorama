; Example.asm
; Copyright (c) 1992 by Serge N. Varjukha */
code   segment word
       assume cs:code, ds:code
       org    100h

       INCLUDE MICE.ASM

start:
       MouseInstalled
       cmp    al, 0
       je     Exit
       SetGraphMode
       mov    dx, offset Msg
       mov    ah, 09h
       int    21h
       SetMouseShape   ds, ExclaimMouse
       ShowMouse
       Getch
       HideMouse
       SetTextMode
Exit:  int    20h
Msg:   db     'Press any key to Exit.$'

       INCLUDE EXCLAIM.ASM

code   ends
       end    start
