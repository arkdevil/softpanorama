;
;       ReSizeable RAMDisk device driver for XMS memory
;
;       Copyright (c) 1992 Marko Kohtala
;
;       Some documentation and license available in accompanying file
;       SRDISK.DOC. If not, contact author by sending E-mail from
;
;               Internet, Bitnet etc. to 'Marko.Kohtala@hut.fi'
;               CompuServe to '>INTERNET:Marko.Kohtala@hut.fi'
;
;       or by calling Airline QBBS, 24H, HST, V.32, V.42, MNP,
;       +358-0-8725380, and leaving mail to me, Marko Kohtala.
;
;       This device driver is distributed as shareware. See SRDISK.DOC
;       for more information.
;
;       This file is included by the memory specific file! To compile,
;       compile the memory specific source file.
;
;       To compile with TASM: tasm /m2 srdisk.asm
;                             tlink /t srdisk.obj,srdisk.sys
;
; History:
; 1.00  Initial release
; 1.10  Added into IOCTL_msg media_change byte, that must be changed to
;       -1 by srdisk if media changed. Changed header version to SRD 1.10.
; 1.20  Fixed name of program by adding the missing 'Re' to 'Sizeable'.
;       Upgraded IOCTL_msg_s to version 1.20 by adding byte to tell usable
;       memory types.
;       Updated to work with DOS versions 2.x-5.x - not tested.
; 1.30
;       Major redesign of the reformatting system. Ioctl is no longer used.
;       New data structures of version V_FORMAT 0 (beta format).
;       Support for multiplex interrupt.
;       Support for chaining of drivers for different memory to same disk.
;       Support for DOS 4+ 32-bit sector addresses.
;       [Allow forcing drive to some drive letter (even replace DOS drives).]
;       Int 19 hooking is optional by defining HOOKINT19 to 0.
;       Added if ... endif around all memory specific code to ease
;        later adding of other memory support code.
;       Fixed parameter reading to abort on every ctrl-character other
;        than tab. DOS 5 could end line with LF if no parameters and CR if
;        there were parameters. Now even NUL can end the line.
; 1.40
;       Moved the allocation conditionally out from this device driver.
;        If C_NOALLOC in CAPABLE is set, the SRDISK.EXE is expected to do
;        the allocation by itself.
;       Changed multiplex interrupt interface to be more standardlike.
;       Changed XMS handle to default 0 as indication there is no handle
;        already allocated.
;       Made the default BPB to contain a valid disk layout. The zero sectors
;        in BPB made DR-DOS hang with divide error.
;       Added check for DR-DOS 6 since it tells the init request header is
;        not long enough to hold the drive letter, but the drive letter is
;        there anyway.
; 1.42
;       Split into three files: xmsdisk.asm, define.inc and this srdisk.asm
;       Made it not to allocate a handle before one is needed.
;       Removed drive forcing code - it had a bug since 1.40 and in any
;        case made things only worse.

SRD_VERSION     equ "1.42"      ; FOUR LETTER VERSION STRING

DR_ATTRIBUTES = 0800h                   ; Removable media

if CAPABLE and C_32BITSEC
DR_ATTRIBUTES = DR_ATTRIBUTES or 2      ; 32-bit addr
endif


d_seg           segment para public
                assume ds:d_seg, cs:d_seg

                org     0
; The following is to be considered as both a device driver header and
; as a starting point for the configuration table. This driver will be
; identified by its segment address and this structure must be at offset
; 0.

                ; Device driver header
drhdr_next      dd      -1              ; Pointer to next device (now last)
drhdr_attr      dw      DR_ATTRIBUTES
drhdr_strategy  dw      offset strategy ; Offset to strategy function
drhdr_commands  dw      offset commands ; Offset to commands function
drhdr_units     db      1               ; Number of units

; The rest has four functions to be considered
;  1) usable as device driver name if this driver is changed
;     into character device on init.
;  2) usable as a label to be returned in media check call
;  3) identifies this device driver as SRDISK driver by always having
;     the letters SRD at offset dr_ID
;  4) identifies the memory used by the 4 char string at offset dr_memory

dr_volume       label byte
dr_ID           db      'SRD'           ; SRDISK signature (3 char)
dr_memory       db      MEMSTR          ; Memory type identifier (4 char)
dr_version      db      SRD_VERSION     ; Device driver version (4 char)
                db      0               ; null to end volume label
dr_v_format     db      V_FORMAT        ; Configuration format version
dr_conf         dw      offset conf     ; Pointer to drive configuration

disk_IO         proc far
                mac_disk_IO             ; Disk access function
disk_IO         endp

ife C_NOALLOC
malloc          proc far
                mac_malloc              ; Memory allocation function
malloc          endp
endif   ; NOT C_NOALLOC

if HOOKINT19
int_19_entry    proc far
                mac_int_19              ; INT 19 boot function
int_19_entry    endp

old_int19       label dword             ; Address of old INT 19
old_int19_off   dw      -1
old_int19_seg   dw      -1
endif   ; HOOKINT19

mac_resident_data                       ; Memory specific resident data

;**************************************************************************
;
;                       Debugging code
;
; This code prints out a character and a word in hex. This code can be
; used using "debug char,word" macro in the code to give some output of
; the actions device driver is doing.
;
; A color display is assumed with 80 characters on a row and 25 rows.
;
;**************************************************************************

if DEBUGGING
                assume ds:nothing

debug_c         proc near
                push es
                push di

                mov ah,d_attr           ; Load color attribute
                mov di,0B800h           ; Load screen segment (assumes color)
                mov es,di
                mov di,d_loc            ; Load line
                cmp di,26*160           ; Below screen?
                jb debug_c1
                  mov di,2*160          ; Yes, move to third line (for scroll off)
                  mov d_loc,di
                  add ah,10h            ; Change color
                  cmp ah,70h
                  jb debug_c2
                    sub ah,60h
debug_c2:         mov d_attr,ah

                  push es               ; Wait if shift down
                  mov ax,40h
                  mov es,ax
debug_c3:         test byte ptr es:[17h],3
                  jnz debug_c3
                  pop es
debug_c1:
                add di,d_col            ; Advance to right column
                mov es:[di],ax          ; Print error letter

                call debug_x            ; Print high byte
                mov dh,dl
                call debug_x            ; Print low byte

                add d_loc,160           ; Next line

                pop di
                pop es
                ret
debug_c         endp

debug_x         proc near               ; Print a byte in hex
                mov al,dh
                shr al,1
                shr al,1
                shr al,1
                shr al,1
                call debug_x1
                mov al,dh
debug_x1:       and al,0Fh              ; Print a hex digit
                cmp al,10
                jae debug_x2
                  add al,'0'
                  jmp debug_x3
debug_x2:       add al,'A'-10
debug_x3:
                inc di
                inc di
                mov es:[di],ax
                ret
debug_x         endp

d_loc   dw 2*160
d_col   dw 150
d_attr  db 40h

                assume ds:d_seg

endif ; DEBUGGING


;**************************************************************************
;
;                       Configuration tables
;
; This structure holds all the formatting data used by the formatter.
; The formatter is passed a pointer to this data and it modifies it
; directly. For this arrangement to work THE BELOW TABLE MAY NOT BE
; MODIFIED WITHOUT PROPER CHANGES IN SRDISK.C. The table contains
; version number which is to be changed when a change is made to this
; structure.
;
; Only the first fields up to label appended_eor is resident and used in
; in every case. The rest is used only in the main driver in a chain of
; RAM disk drivers.
;
; !!! The formatter may use any initial values in this structure as
; default values i.e. set all needed values here !!!
; !!! A DR-DOS bug must be avoided by defining c_BPB_sectors and
; c_BPB_FATsectors so that they could be real !!!
;**************************************************************************

READ_ACCESS     equ     1       ; Bit masks for the RW_access
WRITE_ACCESS    equ     2

config_s struc
c_drive         db      ?               ; Drive letter
c_flags         db      CAPABLE         ; Misc capability flags
c_disk_IO       dd      disk_IO         ; disk_IO entry
c_malloc        dw      malloc          ; malloc entry offset (in DS/CS)
c_next          dw      0               ; Next driver in chain (segment)
c_maxK          dd      0FFFFh          ; Maximum allowed size
c_size          dd      0               ; Current allocated size in Kbytes
c_sectorsl      dw      0               ; Sectors in this driver (low word)
c_sectorsh      dw      0               ; Sectors in this driver (high word)

c_BPB_bps       dw      128             ; Sector size
c_BPB_spc       db      4               ; Cluster size in sectors
c_BPB_reserved  dw      1               ; The boot sector is reserved
c_BPB_FATs      db      1               ; One FAT copy
c_BPB_dir       dw      64              ; 64 entries in root directory
c_BPB_sectors   dw      100             ; BPB number of sectors on disk
c_BPB_media     db      0FAh            ; Media is RAM DISK
c_BPB_FATsectors dw     1               ; Sectors per one FAT
c_BPB_spt       dw      8               ; Sectors per track (imaginary)
c_BPB_heads     dw      1               ; Number of heads (imaginary)
c_BPB_hiddenl   dw      0               ; # of hidden sectors (low word) (imag)
c_BPB_hiddenh   dw      0               ; # of hidden sectors (high word)
c_BPB_tsectorsl dw      0               ; 32-bit # of sectors (low word)
c_BPB_tsectorsh dw      0               ; 32-bit # of sectors (high word)

c_tsize         dd      0               ; Total size in Kbytes (all drivers)

c_RW_access     db      00b             ; B0 = read, B1 = write (disabled now)
c_media_change  db      1               ; -1 if media changed, 1 if not
c_open_files    dw      0               ; Files currently open on drive
c_next_drive    dw      0               ; Segment of next SRDISK drive
config_s ends

conf            config_s <>

appended_eor    equ offset conf.c_BPB_spc ; End of resident for appended driver


;**************************************************************************
;
;               Other internal and resident data
;
; The order of this data is not significant as it will not be used outside
;
;**************************************************************************

BPB             equ     byte ptr conf.c_BPB_bps
pBPB            dw      offset BPB      ; Pointer to BPB (for cmd_init)

old_multiplex   dd      ?               ; Multiplex hook

if CAPABLE and C_APPENDED
xaddr_off       dw      ?               ; Temp data for cmd_io
xaddr_seg       dw      ?
xsecl           dw      ?
xsech           dw      ?
endif

req_ptr         dd      ?               ; Request structure pointer

                ; Pointers to commands
command_tbl     dw      cmd_init             ;  0 Init
                dw      cmd_media            ;  1 Media
                dw      cmd_BPB              ;  2 Build BPB
                dw      cmd_unknown          ;  3 IOCTL input
                dw      cmd_input            ;  4 Input
                dw      cmd_unknown          ;  5 nondest input (char)
                dw      cmd_unknown          ;  6 input status (char)
                dw      cmd_unknown          ;  7 input flush (char)
                dw      cmd_output           ;  8 Output
                dw      cmd_output           ;  9 Output with verify
                dw      cmd_unknown          ; 10 output status (char)
                dw      cmd_unknown          ; 11 output flush (char)
                dw      cmd_unknown          ; 12 IOCTL output
                dw      cmd_open             ; 13 Open device
                dw      cmd_close            ; 14 Close device
                dw      cmd_removable        ; 15 Removable media check

HIGH_CMD        EQU ($-offset command_tbl)/2
  
;**************************************************************************
;
;                       Set request header address
;
; Called by DOS to set the request structure pointer
;
;**************************************************************************
  
strategy        proc far
                mov     word ptr cs:req_ptr,bx
                mov     word ptr cs:req_ptr+2,es
                ret
strategy	endp
  
  
;**************************************************************************
;
;                       Commands
;
; Called by DOS. Requested action defined in structure pointed by req_ptr.
;
;**************************************************************************
  
commands        proc far
                assume ds:nothing
		push	ax
                push    bx
		push	cx
		push	dx
                push    si
		push	di
		push	ds
		push	es
                cld
                lds     si,cs:req_ptr
                ; We trust Microsoft that the unit is right at [req_ptr]+1
                mov     cx,[si+12h]             ; Sectors/Cmd line/BPB pointer
                mov     dx,[si+14h]             ; Start sector/Device number
                mov     bl,[si+2]               ; Command
                cmp     bl,HIGH_CMD             ; Is command supported?
                ja      cmd_unknown             ; Jump if not
                xor     bh,bh                   ; Count index to command_tbl
                shl     bx,1
                les     di,dword ptr [si+0Eh]   ; ES:DI = transfer address
		push	cs
                pop     ds                      ; DS to local data segment
                assume ds:d_seg
                jmp     word ptr [command_tbl+bx] ; Do command
cmd_unknown:
                assume ds:nothing
                mov     al,3
                jmp     cmd_error
cmd_IOerr:
                lds     bx,req_ptr
                mov     word ptr [bx+12h],0     ; Sector count zero
cmd_error:
                mov     ah,81h                  ; ERROR and DONE (err #, in al)
                jmp     cmd_ret

cmd_removable:  ; Enough to return DONE without BUSY flag set
cmd_ok:
                mov     ax,100h                 ; DONE
cmd_ret:
                debug 'Q',ax
                lds     bx,req_ptr
                mov     [bx+3],ax               ; save status
		pop	es
		pop	ds
		pop	di
                pop     si
		pop	dx
		pop	cx
                pop     bx
		pop	ax
		retf				; Return far
                assume ds:d_seg
commands	endp

;**************************************************************************
;
;               Media Check command
;
;**************************************************************************

cmd_media       proc near
                les bx,req_ptr
                mov al,conf.c_media_change      ; Read the change return
                debug 'C',ax

                test conf.c_RW_access,READ_ACCESS
                jz dev_not_ready

                mov es:[bx+0Eh],al
                mov word ptr es:[bx+0Fh],offset dr_volume
                mov es:[bx+11h],cs
                jmp cmd_ok

dev_not_ready:
                mov al,02h                      ; "Device not ready" status
                jmp cmd_error

cmd_media       endp


;**************************************************************************
;
;               Build BPB command
;
;**************************************************************************

cmd_BPB         proc near
                debug 'B',<conf.c_RW_access>
                test conf.c_RW_access,READ_ACCESS
                jz dev_not_ready

                les     bx,req_ptr
                mov     word ptr es:[bx+12h],offset BPB
                mov     es:[bx+14h],cs
                mov     conf.c_open_files,0     ; Reset open files to 0
                mov     conf.c_media_change,1   ; Media not changed
                jmp     cmd_ok
cmd_BPB         endp


;**************************************************************************
;
;               Device Open command
;
;**************************************************************************

cmd_open        proc near
                debug 'O',-1
                inc     conf.c_open_files
                jmp     cmd_ok
cmd_open        endp


;**************************************************************************
;
;               Device Close command
;
;**************************************************************************

cmd_close       proc near
                cmp     conf.c_open_files,0
                jz      cmd_close1
                dec     conf.c_open_files
cmd_close1:
                jmp     cmd_ok
cmd_close       endp


;**************************************************************************
;
;               INPUT command
;
;**************************************************************************

cmd_input       proc near
                debug 'R',0
                test    conf.c_RW_access,READ_ACCESS
                jz      cmd_input1
                xor     bh,bh
                jmp     cmd_io
cmd_input1:
                mov     al,2                    ; "Device not ready"
                jmp     cmd_IOerr
cmd_input       endp


;**************************************************************************
;
;               OUTPUT command
;
;**************************************************************************

cmd_output      proc near
                debug 'W',0
                mov     al,0                    ; "Write protect violation"
                mov     bh,1
                test    conf.c_RW_access,WRITE_ACCESS
                jnz cmd_io
                  jmp cmd_output2
cmd_io:
                ; BH    - read/write
                ; CX    - sectors
                ; ES:DI - transfer address
                ; DS    = CS

                mov ax,cx                       ; Count number of bytes to move
                mul conf.c_BPB_bps
                jc cmd_output4                  ; Is it too much? (dx != 0)

                ; check transfer address and count that they do not
                ; exceed segment limit
                add ax,di                       ; (dx = 0 after the mul)
                jnc cmd_output5
cmd_output4:
                mov ax,di                       ; How many bytes CAN we move?
                xor ax,-1
                xor dx,dx                       ; How many sectors?
                div conf.c_BPB_bps
                mov cx,ax
cmd_output5:
                push es
                les si,req_ptr
                mov word ptr es:[si+12h],dx     ; Xferred 0 sectors so far
                cmp byte ptr es:[si],1Ah        ; Do we use 32-bit sec. address?
                jbe cmd_output3
                  debug '3',0
                  mov ax,es:[si+1Ah]            ; Load 32-bit sec. address
                  mov dx,es:[si+1Ch]
                  jmp cmd_output8
cmd_output3:
                mov ax,es:[si+14h]              ; Load 16-bit sec. address
                xor dx,dx
cmd_output8:
                pop es

if CAPABLE and C_APPENDED

                mov si,offset conf
                mov xaddr_off,di
                mov xaddr_seg,es
                mov xsecl,ax
                mov xsech,dx
                ; BH    - read/write
                ; CX    - sectors
                ; DS:SI - conf of current driver (main here)

cmd_output7:
                push bx
                push cx
                call [si].c_disk_IO
                pop cx
                pop bx

                les di,cs:req_ptr               ; Increment number of sectors
                add word ptr es:[di+12h],ax     ;  actually transferred

                jc cmd_output1                  ; I/O error

                sub cx,ax                       ; All transferred?
                jbe cmd_output6                 ;  yes, so exit

                debug 'N',ax
                push ax
                mul [si].c_BPB_bps              ; Increment transfer offset
                add cs:xaddr_off,ax             ;  which can not exceed 0FFFFh
                pop ax

                xor dx,dx
                add ax,cs:xsecl                 ; Count new starting sector
                adc dx,cs:xsech
                sub ax,conf.c_sectorsl          ; Subtract passed sectors
                sbb dx,conf.c_sectorsh
                mov cs:xsecl,ax                 ; And store the result
                mov cs:xsech,dx

                mov es,cs:xaddr_seg             ; Load these ready for disk_IO
                mov di,cs:xaddr_off
                mov si,[si].c_next              ; Find next driver
                or si,si
                mov ds,si
                mov si,dr_conf
                jnz cmd_output7
                ; there is no next driver - sectors not found!
                debug 'E',cx

else ;if CAPABLE and C_APPENDED

                push cx
                call disk_IO
                pop cx
                les si,cs:req_ptr               ; Return number of sectors
                mov word ptr es:[si+12h],ax     ;  actually transferred
                jc cmd_output1                  ; I/O error
                cmp ax,cx
                je cmd_output6
endif

cmd_output1:
                debug 'S',ax
                mov     al,8                    ; "Sector not found"
cmd_output2:
                jmp     cmd_IOerr
cmd_output6:
                jmp     cmd_ok
cmd_output      endp
  

;**************************************************************************
;
;               MULTIPLEX server
;
;**************************************************************************

multiplex       proc far
                cmp ah,MULTIPLEXAH
                jne mplex_old
                cmp al,0
                jz mplex_installed
                push cs                 ; Tell our segment
                pop es
mplex_installed:
                mov al,-1               ; Tell we are installed
                iret
mplex_old:
                jmp cs:old_multiplex
multiplex       endp


;**************************************************************************
;**************************************************************************
;**************************************************************************
;**************************************************************************
;
;               INITIALIZATION TIME CODE
;
; This code and data is removed from the memory after driver is
; initialized.
;**************************************************************************

end_of_resident EQU offset $    ; MARKS THE END OF RESIDENT PORTION OF DRIVER

def_drive       db 'C'                  ; Default drive, where to install

main_config     dd      ?               ; Pointer to main configuration table

FLAG_1ST        EQU 1                   ; First SRDISK driver
FLAG_FORCEDRIVE EQU 2                   ; Force drive letter (in s_drive)
FLAG_APPEND     EQU 4                   ; Append to other SRDISK driver
FLAG_APPENDED   EQU 8                   ; Appended to other SRDISK driver
FLAG_KNOWDRIVE  EQU 10h                 ; Drive letter known
FLAG_32BITS     EQU 20h                 ; Capable of 32 bit sector addressing
flags           db 0

;**************************************************************************
;
;                       prints macro
;
; This macro is used by initialization routines to display text.
; dx must point to the '$' terminated text about to be displayed.
;**************************************************************************
  
prints        macro
		mov	ah,9
                int     21h
              endm
  
if DEBUGINIT

print_x         proc near               ; Print a dword in hex
print_lx:       push ax
                mov ax,dx
                call print_sx
                mov ah,2
                mov dl,':'
                int 21h
                pop ax
print_sx:                               ; Print a word in hex
                push ax
                mov al,ah
                call print_cx
                pop ax
print_cx:                               ; Print a byte in hex
                push ax
                shr al,1
                shr al,1
                shr al,1
                shr al,1
                call print_x1
                pop ax
print_x1:       and al,0Fh              ; Print a hex digit
                cmp al,10
                jae print_x2
                  add al,'0'
                  jmp print_x3
print_x2:       add al,'A'-10
print_x3:       mov ah,2
                push dx
                mov dl,al
                int 21h
                pop dx
                ret
print_x         endp

idebugc  macro chr
        push ax
        mov al,chr
        call print_cx
        pop ax
endm

idebugs  macro wrd
        push ax
        mov ax,wrd
        call print_sx
        pop ax
endm

idebugl  macro high,low
        push ax
        push dx
        mov ax,low
        mov dx,high
        call print_lx
        mov ah,2
        mov dl,' '
        int 21h
        pop ax
        pop dx
endm

else

idebugc  macro chr
endm

idebugs  macro wrd
endm

idebugl  macro high,low
endm

endif ; DEBUGINIT

  
;**************************************************************************
;
;                       INIT command
;
; Init command does the following:
;  - displays sign-on message
;  - checks DOS version. This driver is built in a way that requires
;    at least dos version 2.00. I'm not sure whether even that is enough.
;  - determine which drive we are by default
;  - read command line
;    - abort on syntax errors
;  - initialize memory to 0K disk
;  - initialize multiplex interrupt
;  - do hooks to other SRDISK drivers (specified in command line)
;  - hook INT 19 bootstrap interrupt
;  - fills in the request header
;**************************************************************************
  
cmd_init        proc near
                mov     dx,offset s_sign_on     ; "ReSizeable RAMdisk ver..."
                prints

                call init_dos
                jnc cmd_init4
                  jmp cmd_init_err
cmd_init4:
                les si,req_ptr

                idebugl es,si
                idebugs <word ptr es:[si]>
                idebugs <word ptr es:[si+2]>
                idebugs <word ptr es:[si+16h]>

                mov al,'$'
                test flags,FLAG_KNOWDRIVE
                jz cmd_init1
                  mov al,es:[si+16h]            ; Get drive number
                  add al,'A'
cmd_init1:
                mov def_drive,al
                mov s_drive,al

                test flags,FLAG_32BITS
                jnz cmd_init2
                  and conf.c_flags,NOT C_32BITSEC
cmd_init2:

                call init_read_cmdline
                jc cmd_init_err

                call init_memory
                jc cmd_init_err

                call init_mplex
                jc cmd_init_err

                call init_hooks
                jc cmd_init_err
if HOOKINT19
                call set_int19
endif
                mov word ptr conf.c_disk_IO+2,cs

                mov al,s_drive
                mov conf.c_drive,al

                test flags,FLAG_APPENDED
                jz cmd_init7
                  mov s_appdrive,al     ; Report append
                  mov dx,offset s_appended
                  prints

                  mov bx,offset ret_far ; Strategy and commands short
                  mov drhdr_strategy,bx
                  mov drhdr_commands,bx
                  mov drhdr_attr,8000h  ; Plain character device
                  mov drhdr_units,'$'   ; Name for this driver '$SRD'MEMORY

                  lds bx,req_ptr
                  mov byte ptr [bx+0Dh],1       ; One drive
                  mov word ptr [bx+0Eh],appended_eor ; Ending address
                  jmp cmd_init3

cmd_init_err:
                prints
cmd_init_abort:
                call deinit                     ; Remove hooks
                xor ax,ax
                lds bx,req_ptr
                mov byte ptr [bx+0Dh],al        ; Zero the number of drives
                mov [bx+0Eh],ax                 ; Ending address
                jmp cmd_init3

cmd_init7:      ; Not appended to previously installed SRDISK driver
                mov al,s_drive
                cmp al,'$'                      ; Is the drive number known?
                jne cmd_init9
                  mov word ptr s_drive,2020h    ; Don't tell drive
cmd_init9:
                mov dx,offset s_installed       ; Report install
                prints

                lds bx,req_ptr
                assume ds:nothing
                mov byte ptr [bx+0Dh],1         ; Save number of drives
                mov word ptr [bx+0Eh],end_of_resident
cmd_init3:
                mov [bx+10h],cs

                mov     word ptr [bx+12h],offset pBPB
                mov     [bx+14h],cs
                jmp     cmd_ok

                assume ds:d_seg
cmd_init        endp

;**************************************************************************
;
;               CHECK DOS VERSION AND CAPABILITIES
;
;**************************************************************************

init_dos        proc near
                mov ax,4452h    ; DR-DOS?
                stc
                int 21h
                jc idos_notc
                cmp ax,dx
                jne idos_notc
                cmp ah,10h
                jne idos_notc   ; Not installed

                cmp al,67h      ; DR-DOS version 6.0 ?
                jne idos_notc   ; If not, treat it like MS-DOS

                  or flags,FLAG_32BITS or FLAG_KNOWDRIVE
                  jmp idos_x

idos_notc:      mov ah,30h
                int 21h         ; Get DOS version number

                xchg ah,al
                idebugs ax
                cmp ax,200h
                jb idos1
                cmp ax,700h
                jb idos2
idos1:
                  mov dx,offset errs_eDOS       ; Invalid DOS version
                  stc
                  ret
idos2:
                cmp ax,31Fh     ; DOS 3.31+ ?
                jb idos4

                  or flags,FLAG_32BITS
idos4:
                les si,req_ptr
                cmp byte ptr es:[si],16h        ; Device number supported?
                jbe idos_x                      ; No, make a guess
                  or flags,FLAG_KNOWDRIVE
idos_x:
                clc
                ret
init_dos        endp

  
;**************************************************************************
;
;               READ COMMAND LINE
;
; Return carry set if error
;**************************************************************************

init_read_cmdline proc near
                push ds

                les bx,req_ptr
                lds si,es:[bx+12h]              ; Pointer to cmd line
                assume ds:nothing

irc1:           lodsb                           ; Skip over the driver name
                cmp al,9 ;tab
                je irc2
                cmp al,' '
                je irc2
                ja irc1
                jmp irc_eol
irc2:
irc_narg:       call irc_skip_space

                cmp al,' '                      ; Every ctrl character ends
                jb irc_eol

                cmp al,'/'
                jz irc_switch

                and al,11011111b                ; Make lowercase to uppercase
                cmp al,'A'
                jb irc_syntax
                cmp al,'Z'
                ja irc_syntax

                cmp byte ptr [si],':'
                jne irc3
                inc si                          ; Skip ':'
irc3:           
                mov cs:s_drive,al
                test flags,FLAG_FORCEDRIVE
                jnz irc_syntax
                or flags,FLAG_FORCEDRIVE
                jmp irc_narg

irc_syntax:     mov dx,offset errs_syntax
                stc
                pop ds
                ret

irc_switch:     lodsb
                and al,11011111b                ; Make lowercase to uppercase
                cmp al,'A'
                jne irc_syntax

                or flags,FLAG_APPEND
                jmp irc_narg

irc_eol:        clc
                pop ds
                ret
init_read_cmdline endp

irc_skip_space  proc near
ircs1:          lodsb
                cmp al,' '
                je ircs1
                cmp al,9 ;tab
                je ircs1
                ret
irc_skip_space  endp

                assume ds:d_seg

  
;**************************************************************************
;
;                       Memory initialization
;
; Returns
;   carry set if error
;**************************************************************************
  
init_memory     proc near
                mac_init_memory
                ret
init_memory     endp

;**************************************************************************
;
;               Multiplex service initialization
;
; Queries multiplex interrupt to find out if SRDISK device drivers are
; already installed. If not  install the multiplex server.
;
; Return carry set if error.
;**************************************************************************

init_mplex      proc near
                push ds
                push es
                mov ax,MULTIPLEXAH * 100h
                xor bx,bx
                xor cx,cx
                xor dx,dx
                push ds
                int 2Fh         ; AL installed status
                pop ds

                cmp al,-1       ; Is something installed?
                je im_installed
                cmp al,0        ; Is it OK to install?
                je im_install

im_used:        ; Garbled return
                mov dx,offset errs_ml_used
im_err:         stc
                jmp imx

im_installed:   mov ax,MULTIPLEXAH * 100h + 1
                push ds
                int 2Fh         ; ES segmet of main SRDISK driver
                pop ds

                cmp word ptr es:dr_ID,'RS'      ; Is it SRDISK structure?
                jne im_used                     ; No, multiplex used elsewhere
                cmp byte ptr es:dr_ID+2,'D'
                jne im_used                     ; No, multiplex used elsewhere
                mov dx,offset errs_ml_version
                cmp byte ptr es:dr_v_format,V_FORMAT ; Proper version?
                jne im_err              ; No
                ; OK
                mov di,es:dr_conf
                mov word ptr main_config,di
                mov word ptr main_config+2,es
                jmp im_end

im_install:     mov word ptr main_config,offset conf
                mov word ptr main_config+2,ds
                or flags,FLAG_1ST

                mov ax,352Fh
                int 21h
                mov word ptr old_multiplex,bx
                mov word ptr old_multiplex+2,es

                mov dx,offset multiplex
                mov ax,252Fh
                int 21h

im_end:         clc
imx:            pop es
                pop ds
                ret
init_mplex      endp


;**************************************************************************
;
;               INIT HOOKS to previous SRDISK drivers
;
; Append this driver into the list of installed SRDISK drivers
; Return carry set if error
;**************************************************************************

init_hooks      proc near
                test flags,FLAG_1ST     ; If we are the first driver
                jnz ihxok               ;  no hooks are to be done

                les di,main_config      ; es:di point to a drive config
                mov al,s_drive          ; al is the drive to search
                cmp al,'$'              ; Is drive letter unknown?
                je ih_nodrive           ; Yes, do not check drive letter

                test flags,FLAG_APPEND          ; If we append
                jz ih_find_drive
                test flags,FLAG_FORCEDRIVE      ; but not specify drive
                jnz ih_find_drive
ih_nodrive:       mov al,-1                     ; make sure drive not found
ih_find_drive:
ih1:            cmp es:[di].c_drive,al          ; Is it the same drive?
                je ih_append
ih2:            test word ptr es:[di].c_next_drive,-1 ; Is there next drive
                jz ih_newdrive                  ; No (valid segment is nonzero)
                mov es,es:[di].c_next_drive     ; Yes, find the next drive
                mov di,es:dr_conf
                jmp ih1

ih_append_new:  ; Append this driver into previously installed drive
                mov al,es:[di].c_drive          ; Find the drive letter
                mov s_drive,al
                mov conf.c_drive,al

ih_append:      ; Append this driver into specified drive
                test es:[di].c_flags,C_APPENDED ; Append allowed?
                jz ih_appendfail                ; No, fail

                test word ptr es:[di].c_next,-1 ; Is there next driver
                jz ih_a1                        ; No, append here
                mov es,es:[di].c_next           ; Yes, find the next drive
                mov di,es:dr_conf
                jmp ih_append

ih_appendfail:  mov al,def_drive
                mov s_drive,al
                mov dx,offset errs_noappend
                stc
                ret

ihxok:          clc
ihx:            ret

ih_a1:          mov es:[di].c_next,ds
                or flags,FLAG_APPENDED  ; Remember to free extra memory
if DEBUGGING
                mov ax,es:d_col         ; Debug data display little left from
                sub ax,16               ;  main data display
                mov d_col,ax
endif ;DEBUGGING
                jmp ihxok

ih_newdrive:    test flags,FLAG_APPEND
                jnz ih_append_new
                ; This driver must be placed at the tail of list of
                ; SRDISK drivers
                mov es:[di].c_next_drive,ds

                jmp ihxok
init_hooks      endp


;**************************************************************************
;
;                       INT 19 hooking
;
; INT 19 is the bootstrap loader interrupt, which is invoked when user
; presses Ctrl-Alt-Del. We must hook it in order to release the
; extended memory allocated for RAM disk.
;**************************************************************************
  
if HOOKINT19

set_int19       proc near
		push	ax
		push	dx
		push	bx
		push	es

                mov     ax,3519h
                int     21h                     ; Get old int 19 handler
                mov     old_int19_off,bx
                mov     old_int19_seg,es
                mov     dx,offset int_19_entry
		mov	ax,2519h
                int     21h                     ; Set new int 19 handler

		pop	es
		pop	bx
		pop	dx
		pop	ax
		retn
set_int19       endp
  
endif

;**************************************************************************
;
;               Deinitialization in case of aborted install
;
;**************************************************************************

deinit          proc near
if HOOKINT19
                mov ax,old_int19_seg
                or ax,old_int19_off
                jz di_noint19

                push ds
                mov dx,old_int19_off
                mov ds,old_int19_seg
                mov ax,2519h
                int 21h                         ; Set old int 19 handler
                pop ds
di_noint19:
endif

                mac_deinit_memory

                mov ax,word ptr old_multiplex
                or ax,word ptr old_multiplex+2
                jz no_mplex

                push ds
                mov dx,word ptr old_multiplex
                mov ds,word ptr old_multiplex+2
                mov ax,252Fh
                int 21h                         ; Set old multiplex handler
                pop ds
no_mplex:

                ret
deinit          endp


;**************************************************************************
;
;                       Initialization strings
;
;**************************************************************************

mac_init_data

errs_eDOS       db      'RAMDisk: Incorrect DOS version.'
                db      0Dh, 0Ah, '$'

errs_ml_used    db      'RAMDisk: Multiplex interrupt already in use.'
                db      0Dh, 0Ah, '$'

errs_ml_version db      'RAMDisk: Driver of different version already '
                db      'installed.'
                db      0Dh, 0Ah, '$'

errs_noappend   db      'RAMDisk: Can not append to previously installed driver.'
                db      0Dh, 0Ah, '$'

errs_syntax     db      'RAMDisk: Syntax error', 0Dh, 0Ah, 0Dh, 0Ah
                db      'Syntax: RDISK.SYS [d:] [/A]', 0Dh, 0Ah, 0Dh, 0Ah
                db      ' d:', 9, 'Drive into which to append or tell the '
                db      'drive letter', 0Dh, 0Ah
                db      9, 'of this device if DOS does not report it.'
                db      0Dh, 0Ah
                db      ' /A', 9, 'Append this driver to previous SRDISK '
                db      'driver.'
                db      0Dh, 0Ah, '$'

s_sign_on       db      0Dh, 0Ah, 'ReSizeable RAMDisk '
                db      '(', MEMORY_STR, ')'
                db      ' version ', SRD_VERSION, '. '
                db      'Copyright (c) 1992 Marko Kohtala.'
                db      0Dh, 0Ah, '$'

s_installed     db      'Installed RAMDrive '
s_drive         db      'C:', 0Dh, 0Ah, '$'
  
s_appended      db      'Appended to RAMDrive '
s_appdrive      db      'C:', 0Dh, 0Ah, '$'



;**************************************************************************
;
;                       A note for binary debuggers
;
;**************************************************************************

db 0Dh, 0Ah, "Copyright (c) 1992 Marko Kohtala. "
db 0Dh, 0Ah, "Contact from Internet, Bitnet etc. to 'Marko.Kohtala@hut.fi', "
db 0Dh, 0Ah, "CompuServe to '>INTERNET:Marko.Kohtala@hut.fi'"
db 0Dh, 0Ah

d_seg           ends
                end
