;------------------------------------------------------------------
; Автор: А.В.Медведев.
; 220090, Республика Беларусь, Минск, ул.Широкая, 36, к.716а
; т. 64-51-52 (раб.)
;
; Программа для отображения информации о диске. Она делалась 
; с использованием недокументированных структур ДОС (информация 
; из TechHelp!) версии 3.30, поэтому в столбце "DOS" при использовании
; более новых версий MSDOS некоторые поля содержат чушь. Столбец
; "BOOT" содержит корректную информацию.
;
; Запуск: MDI
; После запуска программа запрашивает букву диска.
;
; Для получения выполнимого файла использовался TURBO EDITASM 
; (TA.COM)
;------------------------------------------------------------------

BootInfo struc
        JmpInst  db 3 dup(?)
        NameVer  db 8 dup(?)
        SectSiz  dw ?
        ClustSiz db ?
        ResSecs  dw ?
        FatCnt   db ?
        RootSiz  dw ?
        TotSecs  dw ?
	Media    db ?
        FatSize  dw ?
        TrkSecs  dw ?
        HeadCnt  dw ?
        HidnSec  dw ?
BootInfo ends

DiskInfo struc
        DrvNum   db ?
                 db ?
        SecSiz   dw ?
        SecClust db ?
                 db ?
        BootSiz  dw ?
        NumFAT   db ?
        MaxDir   dw ?
        DataSec  dw ?
        HiClust  dw ?
        SizeFAT  db ?
        RootSec  dw ?
                 db 4 dup (?)
        FAT_ID   db ?
DiskInfo ends

;_________________________ START OF PROGRAM ________________________

        call    ClrScr
        mov     ah,19h
        int     21h
        mov     ah,0eh
        mov     dl,al
        int     21h             ;AL = total number of drive
        mov     MaxDrive,al
        mov     si,offset Quest
        xor     dx,dx
        call    WriteXY
ed1:    xor     ax,ax
        int     16h
        cmp     al,'a'
        jb      uc5
        cmp     al,'z'
        ja      uc5
        sub     al,32
uc5:    mov     DrvL+14,al
        cmp     al,'A'
        jb      ed1
        sub     al,'A'-1
        cmp     al,MaxDrive
        ja      ed1
        mov     Drive,al
        call    ClrScr
        mov     cx,19
        mov     di,sp
wa1:	push	cx
	mov	dx,PosXY
        inc     byte ptr PosXY+1
        mov     si,OfsMsg
        add     OfsMsg,46
        call    WriteXY
        cmp     byte ptr SS:[di-2],16
        jb      wa3
        je      wa2
        mov     dx,PosS
        inc     byte ptr PosS+1
        mov     si,OfsSpc
        mov     al,[si]
        xor     ah,ah
        inc     ax
        add     OfsSpc,ax
        call    WriteXY
        mov     si,offset Bs
        mov     dx,PosB
        inc     byte ptr PosB+1
        call    WriteXY
wa2:    mov     dx,PosC
        inc     byte ptr PosC+1
        mov     si,OfsCpr
        mov     al,[si]
        xor     ah,ah
        inc     ax
        add     OfsCpr,ax
        call    WriteXY
wa3:	pop	cx
        loop    wa1

        mov     Save_SP,sp
        mov     al,Drive
        dec     ax
        mov     bx,offset FreeSpace
        xor     dx,dx
        inc     cx
        int     25h
        mov     sp,Save_SP
        jnc     Read_Ok
	cmp	al,80h
	jne	rd1
	mov	si,offset Att
	jmp	short WrErr
rd1:	cmp	al,40h
	jne	rd2
	mov	si,offset Seek
	jmp	short WrErr
rd2:	cmp	al,8
	jne	rd3
	mov	si,offset CRC
	jmp	short WrErr
rd3:	cmp	al,4
	jne	rd4
	mov	si,offset NotFnd
	jmp	short WrErr
rd4:	mov	si,offset Crit
WrErr:	mov	dx,19*256+0
	call	WriteXY
        jmp     Err_Read
Read_Ok:
        mov     byte ptr FreeSpace.NameVer-1,8
        mov     dx,3*256+24
        mov     si,offset FreeSpace.NameVer-1
        call    WriteXY
        mov     dx,4*256+25
        mov     ax,word ptr FreeSpace.SectSiz
        call    WrInt
        mov     dx,5*256+25
        mov     al,byte ptr FreeSpace.ClustSiz
        xor     ah,ah
        call    WrInt
        mov     dx,6*256+25
        mov     ax,word ptr FreeSpace.ResSecs
        call    WrInt
        mov     dx,7*256+25
        mov     al,byte ptr FreeSpace.FATCnt
        xor     ah,ah
        call    WrInt
        mov     dx,8*256+25
        mov     ax,word ptr FreeSpace.RootSiz
        call    WrInt
        mov     dx,9*256+25
        mov     ax,word ptr FreeSpace.TotSecs
        call    WrInt
        mov     dx,10*256+28
        mov     al,byte ptr FreeSpace.Media
        call    WrHex
        mov     dx,11*256+25
        mov     ax,word ptr FreeSpace.FatSize
        call    WrInt
        mov     dx,12*256+25
        mov     ax,word ptr FreeSpace.TrkSecs
        call    WrInt
        mov     dx,13*256+25
        mov     ax,word ptr FreeSpace.HeadCnt
        call    WrInt
        mov     dx,14*256+25
        mov     ax,word ptr FreeSpace.HidnSec
        call    WrInt
        mov     ax,word ptr FreeSpace.FATSize
        mov     bl,byte ptr FreeSpace.FATCnt
        xor     bh,bh
        mul     bx
        add     ax,word ptr FreeSpace.ResSecs
        push    ax
        mov     dx,16*256+25
        call    WrInt
        mov     ax,word ptr FreeSpace.RootSiz
        mov     cl,5
        shl     ax,cl
        xor     dx,dx
        mov     bx,word ptr FreeSpace.SectSiz
        add     ax,bx
        dec     ax
        div     bx
        pop     bx
        add     ax,bx
        mov     dx,17*256+25
        call    WrInt

        mov     ah,36h
        mov     dl,Drive
        int     21h
        mov     bp,dx
        mul     cx              ;(dx:)ax - bytes per cluster
        mov     cx,ax
        mul     bp              ;dx:ax - total
        push    dx
        push    ax
        push    bx
        push    cx
        push    bp
        call    WrLong
        pop     ax
        mov     dx,15*256+25
        call    WrInt
        pop     ax
        pop     bx
        mul     bx
        push    dx
        push    ax              ;dx:ax - available on volume in bytes
        call    WrLong
        pop     bx
        pop     cx              ;cx:bx - available
        pop     ax
        pop     dx              ;dx:ax - total
        sub     ax,bx
        sbb     dx,cx           ;dx:ax - used by files
        call    WrLong

        mov     ah,32h
        mov     dl,Drive
        int     21h
        push    DS
        push    CS
        pop     DS
        pop     ES
        mov     dx, 4*256+36
        mov     ax,ES:[bx].SecSiz
        call    WrInt
        mov     dx, 5*256+36
        mov     al,ES:[bx].SecClust
        inc     ax
        xor     ah,ah
        call    WrInt
        mov     dx, 6*256+36
        mov     ax,ES:[bx].BootSiz
        call    WrInt
        mov     dx, 7*256+36
        mov     al,ES:[bx].NumFAT
        xor     ah,ah
        call    WrInt
        mov     dx, 8*256+36
        mov     ax,ES:[bx].MaxDir
        call    WrInt
        mov     dx,10*256+39
        mov     al,ES:[bx].FAT_ID
        call    WrHex
        mov     dx,11*256+36
        mov     al,ES:[bx].SizeFAT
        xor     ah,ah
        call    WrInt
        mov     dx,15*256+36
        mov     ax,ES:[bx].HiClust
        dec     ax
        call    WrInt
        mov     dx,16*256+36
        mov     ax,ES:[bx].RootSec
        call    WrInt
        mov     dx,17*256+36
        mov     ax,ES:[bx].DataSec
        call    WrInt

Err_Read:
        mov     dx,20*256+0
        mov     ah,2
        xor     bh,bh
        int     10h
        xor     ax,ax
        int     16h
        int     20h

;____________________________ DATA AREA ____________________________

MaxDrive   db   0
Drive      db   0
PosXY      dw   0
PosC       dw   012Fh
PosS       dw   0F2Eh
PosB       dw   0F45h
PosK       dw   0F3Bh
OfsCpr     dw   offset Copr
OfsSpc     dw   offset Spc
OfsMsg     dw   offset Table
Save_SP    label word
StrValue   db   10 dup (0)

Quest   db 19,'Drive (A, B etc.) :'
Copr    db 21,'DI - Disk Information'
        db 11,'Version 1.1'
        db 18,'Copyright (C) 1990'
        db 26,'    by Andrey Vl. Medvedev'
Spc     db 11,'Total space'
        db  9,'Available'
        db 13,'Used by files'
Bs      db  5,'bytes'
Table   db 45,'┌─────────────────────┬──────────┬──────────┐'
DrvL    db 45,'│      Drive          │   BOOT   │   DOS    │'
        db 45,'├─────────────────────┼──────────┼──────────┤'
        db 45,'│ Version             │          │          │'
        db 45,'│ Bytes per sector    │          │          │'
        db 45,'│ Sectors per cluster │          │          │'
        db 45,'│ Offset to FAT       │          │          │'
        db 45,'│ Number of FAT       │          │          │'
        db 45,'│ Root directory entr.│          │          │'
        db 45,'│ Total sectors       │          │          │'
        db 45,'│ Media descriptor    │       h  │       h  │'
        db 45,'│ Sectors in one FAT  │          │          │'
        db 45,'│ Sectors per track   │          │          │'
        db 45,'│ Number of heads     │          │          │'
        db 45,'│ Hidden sectors      │          │          │'
        db 45,'│ Number of clusters  │          │          │'
        db 45,'│ Offset to directory │          │          │'
        db 45,'│ Offset to data      │          │          │'
        db 45,'└─────────────────────┴──────────┴──────────┘'

Att     db 28,'Attachment failed to respond'
Seek    db 11,'Seek error'
CRC     db 24,'Bad CRC on diskette read'
NotFnd  db 16,'Sector not found'
Crit    db 14,'Critical error'

;___________________________________________________________________

ClrScr  proc near
        xor     cx,cx
        mov     dx,184fh
        mov     bh,7
        mov     ax,600h
        int     10h
        mov     ah,2
        xor     bh,bh
        xor     dx,dx
        int     10h
        ret
ClrScr  endp

;________________________________________________________________

WriteXY   proc near               ;SI = offset of string to write
        mov     ah,2              ;DX = position to set cursor
        xor     bh,bh
        int     10h
        mov     dx,si
        mov     ah,40h
        mov     bl,1
        mov     cl,[si]
        mov     ch,bh
        inc     dx
        int     21h
        ret
WriteXY   endp

;________________________________________________________________

WrInt   proc    near            ;ax - word to write
        push    bx
        push    dx
        xor     dx,dx
        mov     dl,5
        push    dx
        mov     di,offset StrValue
        push    di
        mov     dl,5
        push    dx
        xor     dl,dl
        call    StrL
        mov     si,offset StrValue
        pop     dx
        call    WriteXY
        pop     bx
        ret
WrInt   endp

;_________________________________________________________________________

WrLong  proc near
        xor     bx,bx
        mov     bl,9
        push    bx
        mov     di,offset StrValue
        push    di
        mov     bl,9
        push    bx
        call    StrL
        mov     si,offset StrValue
        mov     dx,PosK
        inc     byte ptr PosK+1
        jmp     WriteXY
WrLong  endp

;_________________________________________________________________________

StrL    proc    near  ;(Field: Word; var S: String; LenS: Word)
        mov     bp,sp
        sub     sp,32
        push    ES
        push    DS
        pop     ES
        lea     di,[bp-32]
        call    InStr           ;Convert to string
        mov     si,di
        mov     di,[bp+4]       ;address of resulting string
        mov     dx,[bp+2]       ;Maximum length of string
        mov     ax,[bp+6]       ;count of field to result
        cmp     ax,dx
        jle     StrL1
        mov     ax,dx
StrL1:  cmp     cx,dx
        jle     StrL2
        mov     cx,dx
StrL2:  cmp     ax,cx
        jnl     StrL3
        mov     ax,cx
StrL3:  cld
        stosb
        sub     ax,cx
        je      StrL4
        push    cx
        mov     cx,ax
        mov     al,' '
        rep stosb
        pop     cx
StrL4:  rep movsb
        pop     ES
        mov     sp,bp
        ret     6
StrL    endp

;________________________________________________________________

InStr   proc   near
; Converts a long integer value to string
; Input : ES:di - pointer to string buffer
;         dx:ax - value to convert
; Output: cx - length of string

        push   di
        cld
        mov    bx,ax
        or     dx,dx
        jnl    Positive
        not    bx
        not    dx
        add    bx,1
        adc    dx,0
        mov    al,'-'
        stosb
Positive:
        mov    si,offset Masks
        mov    cl,9
Str0:   cmp    dx,[si+2]
        jb     Str1
        ja     Str2
        cmp    bx,[si]
        jnb    Str2
str1:   add    si,4
        dec    cl
        jne    Str0
Str2:   inc    cl
Str4:   mov    al,2Fh           ;'0'-1
Str3:   inc    al
        sub    bx,[si]
        sbb    dx,[si+2]
        jnb    Str3
        add    bx,[si]
        adc    dx,[si+2]
        add    si,4
        stosb
        dec    cl
        jne    Str4
        mov    cx,di
        pop    di
        sub    cx,di
        ret
InStr   endp

Masks   dd      3B9ACA00h       ;1000000000
        dd      5F5E100h        ;100000000
        dd      989680h         ;10000000
        dd      F4240h          ;1000000
        dd      186A0h          ;100000
        dd      2710h           ;10000
        dd      3E8h            ;1000
        dd      64h             ;100
        dd      0Ah             ;10
        dd      1               ;1

;_________________________________________________________________________

WrHex   proc    near
        push    bx
        xor     ah,ah
        mov     StrValue,2
        mov     cl,4
        shl     ax,cl
        shr     al,cl
        cmp     al,9
        jbe     wh1
        add     al,7
wh1:    add     al,'0'
        cmp     ah,9
        jbe     wh2
        add     ah,7
wh2:    add     ah,'0'
        xchg    ah,al
        mov     word ptr StrValue+1,ax
        mov     si,offset StrValue
        call    WriteXY
        pop     bx
        ret
WrHex   endp

;_________________________________________________________________________

FreeSpace label byte
