; SRDISK - XMS memory device driver specific code
; Copyright (c) 1992 Marko Kohtala

MEMSTR  equ 'XMS '      ; Define 4 char memory type string
MEMORY_STR  equ 'XMS'   ; Define memory type string of any length

include define.inc

;**************************************************************************
;
;               I/O ROUTINE TO THE RAM DISK
;
; This routine will read a group of sectors inside this part of
; the ram disk. If starting sector is not on this part of the disk,
; return without error with 0 sectors transferred. If not all sectors
; are on this part of the disk, transfer as many as can and report the
; number of sectors transferred.
;
; On entry
;   bh - 0 then read, else write
;   cx - number of sectors
;   dx:ax - starting sector
;   es:di - transfer buffer
;
; Preserve
;   es, ds
;   si, di
;
; Return
;   - carry clear if no fatal error, transferred sector count in ax
;       (if starting sector not in this part of disk, return ax = 0)
;   - carry set and ax = 0 on fatal error
;
;**************************************************************************

mac_disk_IO     macro
                push ds
                push di
                push si

                push cs                         ; Make ds point to our data
                pop ds

                mov IO_startl,ax
                mov IO_starth,dx
                debug 'a',ax
                debug 'd',dx
                debug 'c',cx

                cmp     ax,conf.c_sectorsl      ; Starting sector on disk?
                sbb     dx,conf.c_sectorsh
                jb disk_IO4                     ; Yes

                debug 'O',ax
                xor ax,ax                       ; No, 0 sectors transferred
                clc                             ;  No fatal error
                jmp disk_IOx                    ;  Exit

disk_IO4:       mov dx,IO_starth
                add     ax,cx                   ; Count ending sector
                adc     dx,0
                cmp dx,conf.c_sectorsh          ; Ending sector on disk?
                jb disk_IO1                     ; Jump if is
                jne disk_IO5
                sub     ax,conf.c_sectorsl
                jbe     disk_IO1                ; Jump if is
disk_IO5:
                sub cx,ax                       ; Count how many we CAN transfer
                debug 'T',cx
disk_IO1:
                mov IO_sectors,cx               ; Report # of transferred
                mov     ax,cx                   ; Count number of bytes to move
                mul     conf.c_BPB_bps
                mov     si,offset XMS_alloc.XMS_cblk
                mov     [si].XMS_sizel,ax       ; Number of bytes to move
                mov     [si].XMS_sizeh,dx

                mov ax,IO_starth                ; Count starting byte
                mul conf.c_BPB_bps
                mov cx,ax
                mov ax,IO_startl
                mul conf.c_BPB_bps
                add dx,cx                       ; dx:ax is starting byte
  
                or      bh,bh                   ; Input/output?
                mov     bx,XMS_alloc.XMS_handle
                jnz     disk_IO2                ; Jump if write
                                                ; -- Read
                mov     [si].XMS_shandle,bx     ; Source in XMS
                mov     [si].XMS_soffl,ax
                mov     [si].XMS_soffh,dx
                mov     [si].XMS_dhandle,0      ; Destination in main memory
                mov     [si].XMS_doffl,di
                mov     [si].XMS_doffh,es
                jmp     disk_IO3
disk_IO2:                                       ; -- Write
                mov     [si].XMS_shandle,0      ; Destination in main memory
                mov     [si].XMS_soffl,di
                mov     [si].XMS_soffh,es
                mov     [si].XMS_dhandle,bx     ; Source in XMS
                mov     [si].XMS_doffl,ax
                mov     [si].XMS_doffh,dx
disk_IO3:
                mov     ah,0Bh                  ; Move XMS block
                call    dword ptr XMS_alloc.XMS_entry
                shr     ax,1
                cmc                             ; Carry set if err
                mov     ax,IO_sectors           ; Return # of sectors xferred
                jnc disk_IOx
                  xor ax,ax
disk_IOx:       debug 'T',ax
                pop si                          ; Restore original si,di,ds
                pop di                          ;  es was not changed
                pop ds
ret_far:
                ret
                endm

;**************************************************************************
;
;               EXTERNAL MEMORY ALLOCATION ROUTINE
;
; Allocate requested amount of memory. If memory is available in chunks,
; the amount can be rounded up. If not enough memory available, allocate
; as much as possible or just report the amount that was previously
; allocated. It is expected that at least as much memory can be allocated
; as there previously was. Reallocation should not destroy memory
; contents - it is essential to be able to resize a disk without loosing
; the contents (a feature under development).
;
; On entry
;   DWORD [sp+4] - Kbytes to allocate
;
; Preserve
;   es, ds
;   si, di
;
; Return dx:ax = Kbytes allocated
;
;**************************************************************************

mac_malloc      macro
                arg kbytes:dword
                local fail, ok, alloc
                assume ds:nothing
                test word ptr kbytes+2,-1       ; Over 0FFFFh K is impossible
                jnz fail
                mov bx,word ptr kbytes          ; New disk size
                mov dx,XMS_alloc.XMS_handle     ; Handle to the memory
                mov ah,0Fh                      ; Reallocate
                or dx,dx
                jnz alloc                       ; If no handle, then
                  mov dx,bx                     ; allocate
                  mov ah,9
                call XMS_alloc.XMS_entry
                xor dx,dx                       ; Zero the high word of return
                or ax,ax
                jnz ok

fail:           mov ax,word ptr conf.c_size     ; Fail, return current
                ret

ok:             mov ax,word ptr kbytes          ; Ok, return requested
                ret
                assume ds:d_seg
                endm

;**************************************************************************
;
;                       Warm Boot of Machine
;
; Release used XMS memory on warm boot.
;
; I guess this may be important if some virtual machine (VM) in some
; multitasking system has installed this driver and the VM is ended.
; Without this the other VMs would loose the space reserved for RAM disk
; in this VM.
;**************************************************************************
  
if HOOKINT19

mac_int_19      macro
                assume ds:nothing
                pusha   ; If XMS used, it must be 286 or above
                mov     dx,XMS_alloc.XMS_handle
                or      dx,dx
                jz      int19_1                 ; Jump if no XMS handle
		mov	ah,0Ah
                call    XMS_alloc.XMS_entry     ; Free XMS memory
                mov     XMS_alloc.XMS_handle,0
int19_1:
                xor     ax,ax
		mov	ds,ax
                mov     ax,old_int19_off
		cli				; Disable interrupts
                mov     ds:[19h*4],ax           ; for the time to write
                mov     ax,old_int19_seg        ; old interrupt vector back
                mov     ds:[19h*4+2],ax
                popa                            ; Enable interrupts
                jmp     old_int19
                assume ds:d_seg
                endm
endif

;**************************************************************************
;
;                       Local data
;
; This data is used by the two above routines that are needed
; resident in any case.
;
;**************************************************************************

XMS_block       struc
XMS_sizel       dw ?
XMS_sizeh       dw ?
XMS_shandle     dw ?
XMS_soffl       dw ?
XMS_soffh       dw ?
XMS_dhandle     dw ?
XMS_doffl       dw ?
XMS_doffh       dw ?
XMS_block       ends

XMS_alloc_s struc       ; Changing this structure needs changes in srdisk.exe
XMS_handle      dw      0       ; XMS handle to disk memory (0=no handle)
XMS_entry       dd      ?       ; XMS driver entry point
XMS_cblk        XMS_block <>    ; XMS move command data structure
XMS_alloc_s ends

mac_resident_data macro
XMS_alloc XMS_alloc_s <>

IO_sectors      dw      ?       ; Temp storage for # of sec xferred
IO_startl       dw      ?       ; Temp storage for starting sector
IO_starth       dw      ?       ; Temp storage for starting sector

if C_NOALLOC
malloc EQU offset XMS_alloc
endif
                endm


;**************************************************************************
;
;                       Memory initialization
;
; Returns
;   carry set if error
;**************************************************************************
  
; Get XMS driver API address and allocates 0K to get a memory handle
; for RAM disk

mac_init_memory macro
                push    es
                mov     ax,4300h
                int     2Fh                     ; Get XMS installed status
                cmp     al,80h
                jne     init_XMS1               ; Jump if not installed
                mov     ax,4310h
                int     2Fh                     ; Get XMS entry point
                jnc     init_XMS2               ; Jump if no error
init_XMS1:
                mov     dx,offset errs_noXMS    ; "No extended mem driver"
                jmp     init_XMS4
init_XMS2:
                mov     word ptr XMS_alloc.XMS_entry,bx
                mov     word ptr XMS_alloc.XMS_entry+2,es

;               xor     dx,dx                   ; Allocate 0K to get a handle
;               mov     ah,9
;               call    XMS_alloc.XMS_entry
;               or      ax,ax
;               jz      init_XMS3               ; Zero for failure
;               mov     XMS_alloc.XMS_handle,dx

                mov     XMS_alloc.XMS_handle,0  ; Zero handle for no handle

                clc
                jmp     init_XMS_ret
init_XMS3:
                mov     dx,offset errs_ealloc   ; "Error in ext mem alloc"
init_XMS4:
                stc
init_XMS_ret:
                pop     es
                endm

;**************************************************************************
;
;                       Memory deinitialization
;
; Returns
;   carry set if error
;**************************************************************************

mac_deinit_memory macro
                local done
                cmp XMS_alloc.XMS_handle,0
                je done

                mov dx,XMS_alloc.XMS_handle
                mov ah,0Ah
                call XMS_alloc.XMS_entry        ; Free XMS memory
done:
                endm

;**************************************************************************
;
;                       Initialization time data
;
;**************************************************************************

mac_init_data   macro
errs_noXMS      db      'RAMDisk: Extended Memory Manager not present.'
                db      0Dh, 0Ah, '$'

errs_ealloc     db      'RAMDisk: Error in extended memory allocation.'
                db      0Dh, 0Ah, '$'
                endm

include rdisk.asm       ; Create the code itself

