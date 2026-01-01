ifndef ??version
%out This program may be compiled only by TASM 
endif
;╔════════════════════════════════════════════════════════╗
;║                  NCOMMAND.COM                          ║
;║                                                        ║
;║      command.com for The NORTON COMMANDER              ║
;║                                                        ║
;║      (ASM) Copyright(C) 1991, by Horns&Hoofs Corp.     ║
;║                                                        ║
;╚════════════════════════════════════════════════════════╝
assume  cs:csg,ds:csg,ss:csg
csg     segment
org 100h
start:
        mov     si,80h
        cmp     byte ptr [si+1],'/'
        jne     help
        mov     byte ptr [si+1],20h
        cmp     byte ptr [si+2],'c'
        jne     help
        mov     byte ptr [si+2],20h

        mov     bx,10h
        mov     ah,4ah
        int     21h
        mov     es,ds:[2ch]
        mov     ah,49h
        int     21h
        pushf
        push    cs
        xor     ax,ax
        push    ax
        mov     es,ax
        jmp     dword ptr es:[2eh*4]
help:
        mov     ah,9h
        mov     dx,offset mess
        int 21h
        ret
db 13,10
mess label near
db 'NCOMMAND.COM is COMMAND.COM For The Norton Commander.',13,10
db 'Copy(L)eft H&H.',13,10
db 'Exam: insert in autoexec.bat',13,10
db 'set comspec=c:\ncommand.com',13,10
db 'nc',13,10,'$'

h1:
csg     ends
        end     start
