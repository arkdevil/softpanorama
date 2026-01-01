;------------------------------------------------------------------
; Автор: А.В.Медведев.
; 220090, Республика Беларусь, Минск, ул.Широкая, 36, к.716а
; т. 64-51-52 (раб.)
;
; Простая программа защиты диска (дисков) от записи.
; Использование:
;	LDISK	[0]..[7]
; Если никакие параметры не указаны, то все диски в системе 
; зацищаются от записи. Если в качестве параметров указаны одна
; или несколько цифр (от 0 до 7), то соответствующие ФИЗИЧЕСКИЕ
; диски НЕ защищаются от записи (0 = диск A, 1 = диск B и т.д.).
; Все символы кроме цифр от 0 до 7 в строке параметров игнорируются.
; Жесткий диск защищается в любом случае.
; Сразу после загрузки программы все диски кроме указанных в
; командной строке защищены. Для включения/выключения защиты
; нажмите [левый Shift] + [ESC].
;
; Пример: 
;	LDISK 01
;	LDISK 0 1
;	LDISK 1-0	
; Диски A, B не защищаются от записи.
;
; Занимает в памяти 224 байтa. Можно загружать в UMB.
;
; ПРЕДУПРЕЖДЕНИЕ: конфликтует со SMARTDRV.EXE, который выдает
; "серьезную ошибку диска" при попытке записи на защищенный 
; винчестер. Снять зациту не удается, поскольку прерывание 
; от клавиатуры полностью перехвачено.
;
; Для получения выполнимого файла:
;	TASM ldisk
;	TLINK /x/t ldisk
;------------------------------------------------------------------

; Disk protect program. Copyright (c) 1990, 1991 by Andrey Vl.Medvedev.
; Usage :
;    [d:][path]LDISK [0]..[7]
; If there is no parameter line, then all disk in system are protected from
; writing. If there are any figure(s) as options, then accordingly disk(s)
; is not protected. (0=drive A, 1=B, etc.) Hard disk is always protected.

MODEL	TINY
CODESEG
ORG	100h

START:
        jmp     Install
;----------------------------------------------------------------
Locked  db      1  ;1 - disks are write protected
Disks   db      0  ;if any bit set, then according disk is not protected
;----------------------------------------------------------------
My_9:   push    ax
        in      al,60h
        cmp     al,1
        jne     Old_9
        push    bx
        push    ES
        xor     bx,bx
        mov     ES,bx
        test    byte ptr ES:[417h],2
        jnz     Int_9
        pop     ES
        pop     bx
Old_9:  pop     ax
        db      0EAh            ;jmp    far
ip_9    dw      0
CS_9    dw      0

Int_9:  in      al,61h
        mov     ah,al
        or      al,80h
        out     61h,al
        mov     al,ah
        out     61h,al
        mov     al,20h
        out     20h,al
        neg     byte ptr CS:[5Ch]
        pop     ES
        pop     bx
        pop     ax
        iret
;----------------------------------------------------------------
My_13:  cmp     ah,0EFh
        jne     a1
        mov     ax,5647h
        iret

a1:     cmp     ah,3            ;write sectors
        jb      Old_13
        ja      a5
Check:  cmp     byte ptr CS:[5Ch],0
        js      Old_13
        cmp     al,80h          ;Hard disk
        jae     Protect
        push    ax
        push    cx
        mov     cl,dl
        mov     al,1
        shl     al,cl
        test    byte ptr CS:[5Dh],al
        pop     cx
        pop     ax
        jnz     Old_13
Protect:
        push    bp
        mov     bp,sp
        or      byte ptr [bp+6],1 ;set carry flag to indicate error
        mov     ah,3            ;attempt to write on write-protected disk
        pop     bp
        iret

a5:     cmp     ah,5            ;format track
        je      Check
        cmp     ah,0Bh          ;write long
        je      Check
        cmp     ah,0Fh          ;*AT* write sector buffer
        je      Check

Old_13: db      0EAh            ;jmp    far
ip_13   dw      0
CS_13   dw      0
;----------------------------------------------------------------
Install:
        mov     ah,9
        mov     dx,offset Msg1
        int     21h
        mov     ah,0EFh
        int     13h
        cmp     ax,5647h
        jne     __1
        jmp     Already
__1:	mov	ES,DS:[2Ch]
	mov	ah,49h
	int	21h
        mov     si,80h
        cld
        lodsb
        or      al,al
        jz      NoPar
        mov     ch,al
ReadPar:
        lodsb
        cmp     al,'0'
        jb      Next
        cmp     al,'7'
        ja      Next
        sub     al,'0'
        mov     cl,al
        mov     al,1
        shl     al,cl
        or      Disks,al
Next:   dec     ch
        jnz     ReadPar
NoPar:  mov     si,offset Locked
        mov     di,5ch
        mov     cx,offset Install-offset Locked
        inc     cx
        shr     cx,1
	push	CS
	pop	ES
        rep     movsw
        xor     ax,ax
        mov     ES,ax
        mov     ax,ES:[4*9]
        mov     ip_9-0a4h-3,ax
        mov     ax,ES:[4*9+2]
        mov     CS_9-0a4h-3,ax
        mov     ax,ES:[4*13h]
        mov     ip_13-0a4h-3,ax
        mov     ax,ES:[4*13h+2]
        mov     CS_13-0a4h-3,ax
        cli
        mov     word ptr ES:[4*9],offset My_9-0a4h-3
        mov     ES:[4*9+2],CS
        mov     word ptr ES:[4*13h],offset My_13-0a4h-3
        mov     ES:[4*13h+2],CS
        sti
        mov     ah,9
        mov     dx,offset Msg3
        int     21h
        mov     dx,offset Install-0a4h-3
        int     27h

Already:
        mov     ah,9
        mov     dx,offset Msg2
        int     21h
        int     20h

Msg1    db 10,'LDISK.COM, Version 1.1, '
	db 'Copyright (C) 1990, 1991 by Andrey Vl. Medvedev',13,10
        db 'Lock/UnLock program $'
Msg2    db 'already '
Msg3    db 'installed.',13,10
        db 'Press [LeftShift+Esc] to turn on/off protection of disks from writing.',13,10,10,'$'

END	START