;██████████████████████████████████████████████████████████████████████████
;██								         ██
;██			        BIOS_286 			         ██
;██                          Diskette BIOS                               ██
;██								         ██
;██      Copyright 1985,1986 Phoenix Technologies Ltd.		         ██
;██      Copyright 1991 Gurtjak D.A. (Donetsk,Ukraine)                   ██
;██								         ██
;██████████████████████████████████████████████████████████████████████████


;                          Diskette Controller Ports
;══════════════════════════════════════════════════════════════════════════════
;      Diskette controller 1 decodes ports 3f0H through 3f7H
;      Diskette controller 2 decodes ports 370H through 377H (on ▌AT▐ only)
;
; The FDC generates interrupt level 6 (IRQ 6) after each operation (read,
; write, seek, recalibrate, etc.).IRQ 6 is vectored to INT 0eH and handled by
; BIOS.
;
;Port  Description
;▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;3f2H  Write: digital output register
;      ╓7┬6┬5┬4┬3┬2┬1┬0╖
;      ║D C B A│ │ │   ║
;      ╙─┴─┴─┴─┴╥┴╥┴─┴─╜ bit
;       ╚══╦══╝ ║ ║ ╚═╩═> 0-1: Drive to select 0-3 (AT: bit 1 not used)
;          ║    ║ ╚═════> 2: 0=reset diskette controller; 1=enable controller
;          ║    ╚═══════> 3: 1=enable diskette DMA and interrupts
;          ╚══════════> 4-7: drive motor enable.  Set bits to turn drive ON.
;                            (AT: bits 6-7 not used)
;3f4H  Read-only: main status register
;      ╓7┬6┬5┬4┬3┬2┬1┬0╖
;      ║ │ │ │ │D C B A║
;      ╙╥┴╥┴╥┴╥┴─┴─┴─┴─╜ bit
;       ║ ║ ║ ║ ╚═════╩═> 0: diskette drive busy (AT: bits 2-3 not used)
;       ║ ║ ║ ╚═════════> 4: 1=controller busy (read or write in progress)
;       ║ ║ ╚═══════════> 5: 1=non-DMA mode; 0=DMA mode active
;       ║ ╚═════════════> 6: Data direction: 1=controller to CPU; 0 = CPU═>FDC
;       ╚═══════════════> 7: Request for Master. 1=OK to send/recv cmd or data
;
;3f5H  Read/Write: FDC command/data register
;      This port is used for all controller command operations.   First, a
;      command byte is output, then one or more data parameters are output.
;      The operation is performed, then 0 or more inputs return the results of
;      the operation.  All of this I/O goes through this port and must take
;      place in the correct sequence.
;
;3f7H  Write: diskette control register
;      ╓7┬6┬5┬4┬3┬2┬1┬0╖
;      ║           │   ║
;      ╙─┴─┴─┴─┴─┴─┴─┴─╜ bit
;       ╚════╦════╝ ╚═╩═> 0-1: data transfer rate
;            ║                 00=500 KBS, 01=300 KBS, 10=250 KBS, 11=reserved
;            ╚══════════> 2-7: I can't find anything about these
;
;      Read: digital input register.  Used for diagnostics (except bit 7)
;      ╓7┬6┬5┬4┬3┬2┬1┬0╖
;      ║c│ │       │ │ ║
;      ╙╥┴╥┴─┴─┴─┴─┴╥┴╥╜ bit
;       ║ ║ ╚══╦══╝ ║ ╚═> 0: 1=select drive 0
;       ║ ║    ║    ╚═══> 1: 1=select drive 1
;       ║ ║    ╚══════> 2-5: Head select 0-3 (bit 2=head 0, bit 3=head 1, etc)
;       ║ ╚═════════════> 6: Write Gate
;       ╚═══════════════> 7: Change Line (1=diskette change line is ON)


dsk_recal_stat		equ	byte ptr ds:[3eh]
						; recalibrate floppy bits:
						;    3    2    1    0
						;   drv3 drv2 drv1 drv0
						; bit 7: interrupt flag
dsk_motor_stat          equ	byte ptr ds:[3fh]
						; bit 7: disk write in progress
						; 6&5  : drive selected 0..3
						; 3..0 : bit-drive (1=motor on)
dsk_motor_tmr		equ	byte ptr ds:[40h]
						; =0 - motor off
dsk_ret_code		equ	byte ptr ds:[41h]
dsk_status_1		equ	byte ptr ds:[42h]
dsk_status_2            equ	byte ptr ds:[43h]
dsk_status_3            equ	byte ptr ds:[44h]
dsk_status_4            equ	byte ptr ds:[45h]
dsk_status_5            equ	byte ptr ds:[46h]
dsk_status_6            equ	byte ptr ds:[47h]
dsk_status_7            equ	byte ptr ds:[48h]
dsk_data_rate		equ	byte ptr ds:[8bh]
hdsk_options		equ	byte ptr ds:[8fh]
						; AT FDC info
						; 6:dr1 determined
						; 5:dr1 is multi-rate, valid if device determin.
						; 4:dr1 support 80 tracks
						; 2:dr0 determined
						; 1:dr0 is multi-rate
						; 0:dr0 support 80 tracks
hdsk0_media_st		equ	byte ptr ds:[90h]
hdsk1_media_st		equ	byte ptr ds:[91h]
					        ; 7..6: data xfer rate
					        ; 		00=500K bit/s
					        ; 		01=300K bit/s
					        ; 		10=250K bit/s
						; 5   : Double stepping (360k in 1.2M)
						; 4   : media eshtablished
					        ; 2..0:
					        ; bits floppy  drive state
					        ;  000=  360K in 360K, ?
					        ;  001=  360K in 1.2M, ?
					        ;  010=  1.2M in 1.2M, ?
					        ;  011=  360K in 360K, ok
					        ;  100=  360K in 1.2M, ok
					        ;  101=  1.2M in 1.2M, ok
					        ;  111=  state not defined
hdsk0_start_st		equ	byte ptr ds:[92h]
hdsk1_start_st		equ	byte ptr ds:[93h]
						; start media for drives
hdsk0_cylinder		equ	byte ptr ds:[94h]
hdsk1_cylinder		equ	byte ptr ds:[95h]

; 	Disk Table (Int 1e)
; 0: hi nibble = stepping rate in ms
;    lo nibble = head unload time, ms
; 1: bit 0 = 1 for DMA, bits 2-7 head load time
; 2: Delay after use for motor off
; 3: Bytes per sector  0 =  128 bytes
;                      1 =  256 bytes
;                      2 =  512 bytes
;                      3 = 1024 bytes
; 4: Last sector on track
; 5: Gap Length
; 6: Data Length
; 7: Format Gap Length
; 8: Format write byte
; 9: Head load time, in milliseconds
; A: Motor startup wait time * .125ms

;	---- User Stack
User_AX			equ	word ptr [bp+00h]
User_ES			equ	word ptr [bp+02h]
User_DS			equ	word ptr [bp+04h]
User_BP			equ	word ptr [bp+06h]
User_DI			equ	word ptr [bp+08h]
User_SI			equ	word ptr [bp+0Ah]
User_DX			equ	word ptr [bp+0Ch]
User_CX			equ	word ptr [bp+0Eh]
User_BX			equ	word ptr [bp+10h]
User_Seg		equ	word ptr [bp+12h]
User_Ofs		equ	word ptr [bp+14h]
User_Flags		equ	word ptr [bp+16h]

User_AL			equ	byte ptr [bp+00h]
User_AH			equ	byte ptr [bp+01h]
User_BL			equ	byte ptr [bp+10h]
User_BH			equ	byte ptr [bp+11h]
User_CL			equ	byte ptr [bp+0Eh]
User_CH			equ	byte ptr [bp+0Fh]
User_DL			equ	byte ptr [bp+0Ch]
User_DH			equ	byte ptr [bp+0Dh]

;------------------------------------------------------------------
code		segment	para public
		assume cs:code , ds:code

		org	100h
start:		jmp	install

; ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ int 40h ▒▒▒▒▒
;
;   FLOPPY DISK	SERVICES
;
int_13h_floppy	proc	near
		call	SaveRegisters
		push	ax
		mov	bp,sp
		mov	di,30h
		call	ConvNumber
		jc	loc_433
		cmp	User_DL,2
		cmc
		jmp	word ptr cs:Fun_Table[di]	;*25 entries

Fun_Table	dw	offset ResetDisk
		dw	offset GetErrorCode
		dw	offset ReadWriteVerify
		dw	offset ReadWriteVerify
		dw	offset ReadWriteVerify
		dw	offset FormatTrack
		dw	offset BadCommand
		dw	offset BadCommand
		dw	offset GetDriveParameters
		dw	offset BadCommand
		dw	offset BadCommand
		dw	offset BadCommand
		dw	offset BadCommand
		dw	offset BadCommand
		dw	offset BadCommand
		dw	offset BadCommand
		dw	offset BadCommand
		dw	offset BadCommand
		dw	offset BadCommand
		dw	offset BadCommand
		dw	offset BadCommand
		dw	offset GetType
		dw	offset Change_Disk_Status
		dw	offset SetType
		dw	offset SetMediaType_Format

loc_433:
		jmp	short Change_Disk_Status
;───── Indexed Entry Point ──────────────────(15) Get Type
    	            	  ; dl - drive
  			  ; return:	ah -disk type
			  ;		00:no disk
			  ;             01:diskette, change line logic no present
			  ;		02:diskette, present change logic
			  ;		03:hard disk
GetType:
		jc	Change_Disk_Status
		mov	dsk_ret_code,0
		push	ax
		call	Get_CMOSType
		test	hdsk_options,66h
		jz	loc_435
		mov	bl,dl
		xor	bh,bh
		mov	ah,hdsk0_media_st[bx]
		cmp	ah,80h
		jne	loc_437
		cmp	al,2
		jmp	short loc_436
loc_435:
		cmp	al,1
loc_436:
		jbe	loc_438
		xor	al,al
		jmp	short loc_438
loc_437:
		or	ah,ah
		mov	al,0
		jz	loc_438
		and	ah,7
		cmp	ah,3
		mov	al,1
		jz	loc_438
		mov	al,2
loc_438:
		mov	cl,al
		pop	ax
		mov	ah,cl
		clc
		jmp	loc_459
;───── Indexed Entry Point ──────────────────(16) read change-of-disk status
;						dl : drive
;					      return: 0 - no change, 1 - change
Change_Disk_Status:
		jc	SetType
		test	hdsk_options,66h
		jnz	loc_442
		call	Get_CMOSType
		mov	dsk_ret_code,80h
		jz	loc_441
		mov	al,0Eh
		call	Read_CMOS       	; POST diagn. status byte
		sti
		test	al,0C0h
		jnz	loc_441                 ; Power bad or lost ?
loc_440:
		mov	dsk_ret_code,6
loc_441:
		jmp	End_Work_40h
loc_442:
		mov	bl,User_dl
		xor	bh,bh
		call	Get_DriveOpns
		test	al,1
		nop
		nop
		jz	loc_440
		call	Set_Motor
		mov	dx,3F7h
		in	al,dx			; port 3F7h, dsk0 status C
		test	al,80h
		mov	dsk_ret_code,0
		jz	loc_444
		mov	al,hdsk0_media_st[bx]
		and	al,0EFh
		inc	al
		test	al,4
		jz	loc_443
		sub	al,3
loc_443:
		dec	al
		mov	hdsk0_media_st[bx],al
		mov	dsk_ret_code,6
loc_444:
		jmp	loc_456
;───── Indexed Entry Point ──────────────────(17) Set Type
;						dl - drive
;						al - disk type
;							0:no present
;							1:360k in 360k
;							2:360k in 1.2M
;							3:1.2M in 1.2M
;							4:720k in 720k
;							5:720k in 1.44M
;							6:1.44M in 1.44M
SetType:
		jc	loc_448
		mov	dsk_ret_code,0
		test	hdsk_options,66h
		jz	loc_441
		push	ax
		call	Set_Motor
		pop	ax
		dec	al
		mov	ah,93h
		jz	loc_447
		dec	al
		mov	ah,74h
		jz	loc_446
		dec	al
		mov	ah,15h
		jz	loc_446
		dec	al
		mov	ah,97h
loc_446:
		push	ax
		call	Restore_Change
		pop	ax
		jnc	loc_447
		mov	ah,61h
loc_447:
		mov	bl,User_dl
		xor	bh,bh
		mov	hdsk0_media_st[bx],ah
		jmp	loc_456
loc_448:
		jmp	BadCommand

;───── Indexed Entry Point ──────────────────(2,3,4) Read, Write, Verify
;						     dl:drive; dh:head
;						     ch:track; cl:sector
;						     es:bx - bufer
;					     Output: al - number readen sect
ReadWriteVerify:
		jc	loc_448
		call	Set_Motor
		mov	dsk_ret_code,0
loc_450:
		call	Test_Change
		jc	Prepare_for_Exit
		call	Set_Media_St
		jc	Prepare_for_Exit
		call	Set_DataRate
		call	Set_DMA
		jc	Prepare_for_Exit
		mov	ch,User_ch
		call	Seek_ToTrackCH
		jc	Prepare_for_Exit
		call	Wait_Motor
		cmp	User_ah,3
		mov	al,0C5h
		jz	loc_451
		mov	al,0E6h
loc_451:    					; write:C5, read/verify:E6
		call	SendByte_toFDC  	; (byte1,byte2,c,h,r,n,eot,gpl,dtl~~~
						; ~~~st0,st1,st2,c,h,r,n)
		jc	Prepare_for_Exit
		call	Send_2ndByte
		mov	al,User_ch
		call	SendByteToFDC		; send cyl.
		mov	al,User_dh
		call	SendByteToFDC		; send head
		mov	al,User_cl
		call	SendByteToFDC		; send sector
		jc	Prepare_for_Exit
		mov	bx,3
		call	Send_2_From_TableBX	; send table[3],[4]
						; byte/sector, last sector on track
		jc	Prepare_for_Exit
		mov	bl,User_dl
		xor	bh,bh
		mov	bl,hdsk0_media_st[bx]
		test	bl,0C0h
		mov	al,1Bh
		jz	loc_452
		mov	al,2Ah
loc_452:                          		; send GPL
						; (***) WARNING! no read table!?
		call	SendByte_toFDC
		jc	Prepare_for_Exit
		mov	bx,6
		mov	cx,1
		call	Send_CX_From_TableBX	; table[6] - data length
		jc	Prepare_for_Exit
		call	Wait_End
		jnc	loc_453
		call	Reset_Disk
		jmp	short Prepare_for_Exit
loc_453:
		call	Get_Status
		call	Define_Dsk_Option
		jc	loc_450
		mov	cl,User_cl
Prepare_for_Exit:
		sti
		mov	al,dsk_status_6		; num sectors
		cmp	al,1
		jne	loc_455
		call	Get_DiskTable
		mov	al,es:[si+4]            ; last sector on track
		inc	al
loc_455:
		sub	al,cl
loc_456:
		call	Get_DiskTable
		mov	ah,es:[si+2]      	; delay after use for motor off
		cmp	dsk_motor_tmr,0EDh
		jbe	loc_457
		add	ah,dsk_motor_tmr
		sub	ah,0EDh
loc_457:
		mov	dsk_motor_tmr,ah
		and	dsk_recal_stat,7Fh

End_Work_40h:
		mov	ah,dsk_ret_code
		cmp	cs:Code_Ok,ah
loc_459:
		pushf
		pop	word ptr User_Flags
		add	sp,2
		jmp	End_Interrupt
;───── Indexed Entry Point ────────────────────────────────────────────────
BadCommand:
		mov	dsk_ret_code,1
		jmp	short End_Work_40h

;───── Indexed Entry Point ──────────────────(5) Format Track
						; al   - sectors/track
						; ch   - track
						; cl   - sector (1..eot)
						; dh   - head
						; dl   - drive
						; es:bx- bufer with format info
FormatTrack:
		jc	BadCommand
		mov	dsk_ret_code,0
		call	Set_Motor
		call	Test_Change
		jc	loc_463
		call	Set_DataRate
		call	Set_DMA
		jc	loc_463
		mov	ch,User_ch
		call	Seek_ToTrackCH
		jc	loc_463
		call	Wait_Motor
		mov	al,4Dh         	   	; 01001101 - format, MFM
		call	SendByte_toFDC          ; (byte1,byte2,n,sc,gpl,d~~~
						; ~~~st0,st1,st2,c,h,r,n)
		jc	loc_463
		call	Send_2ndByte
		jc	loc_463
		mov	bx,3
		call	Send_2_From_TableBX     ; Table[3],[4] - byte/sect, last sect/track
		jc	loc_463
		mov	bx,7
		call	Send_2_From_TableBX	; Table[7],[8] - format GPL, format char
		jc	loc_463
		call	Wait_End
		jnc	loc_462
		call	Reset_Disk
		jmp	short loc_463
loc_462:
		call	Get_Status
loc_463:
		mov	cl,1
		jmp	Prepare_for_Exit

;───── Indexed Entry Point ───────────────── (0) Reset Drive. dl:drive
ResetDisk:
		mov	dsk_ret_code,0
		call	Reset_Disk
		xor	al,al
loc_465:
		jmp	short End_Work_40h
;───── Indexed Entry Point ───────────────── (1) Get error status
;						 dl:drive
;						 Output - al:status
;	Error status:
;		00 : No error
;		01 : Bad command
;		02 : Bad address mark
;		03 : Write protect
;		04 : Sector ID bad or not found
;		05 : Reset failed
;		08 : DMA failure
;		09 : DMA overrun
;		0B : Bad track flag encountered
;		10 : Bad CRC
;		11 : Data corrected by ECC algr.
;		20 : FDC failure
;		40 : Track not found
;		80 : Time out
;		AA : Drive not ready
;		BB : Undef error
GetErrorCode:
		mov	al,dsk_ret_code
		jmp	short loc_465

;───── Indexed Entry Point ──────────────────(18) Set media type for format
						; dl : drive
						; ch : num tracks
						; cl : sect/track
						; return ah -
						;	00 - Ok
						;	01 - funk not avail.
						;	0C - not supported
						; 	80 - no disk in drive
SetMediaType_Format:
		jc	BadCommand
		mov	bl,dl
		xor	bh,bh
		call	Get_FloppyType
		jc	loc_474
		jz	loc_474
		dec	al
		jz	loc_468                 ; 360k
		cmp	al,3
		sbb	al,0FEh
loc_468:
		mov	ah,0Dh
		mul	ah
		mov	di,offset Table_1
		add	di,ax
loc_469:
		cmp	ch,cs:[di+0Bh]   	; tracks
		jne	loc_472
		cmp	cl,cs:[di+4]		; EOT
		jne	loc_472
		mov	ah,cs:[di+0Ch]
		cmp	di,offset Table_0
		je	loc_470
		cmp	ch,40
		jae	loc_470
		or	ah,20h
loc_470:
		call	Establish_Media
		xor	ah,ah
		mov	User_di,di
		mov	User_es,cs
loc_471:
		jmp	loc_459
loc_472:
		cmp	di,offset Table_3
		je	loc_473
		cmp	di,offset Table_6
		jne	loc_474
loc_473:
		sub	di,0Dh
		jmp	short loc_469
loc_474:
		mov	ax,0C00h
		stc
		jmp	short loc_471

;───── Indexed Entry Point ──────────────────(8) Get Drive Parameters
						; dl  - drive
;					     Return: 	ah - status
						;	bl - Drive type
						;       dl - num drives
						;	dh - heads
						; 	cl - max sectors
						;	ch - max val of cylinder
						;	es:bx - drive par. table
GetDriveParameters:
		mov	bx,0
		jc	loc_479
		mov	dl,1
		call	Get_FloppyType
		mov	dh,0FFh			; dh = 0ffh, if not installed
		jc	loc_476
		mov	bl,al
		jz	loc_479
		cmp	al,ah
		adc	dl,0                    ; dl - num drives
		mov	dh,1                    ; dh = 1, if 360k
		dec	al
		jz	loc_476
		mov	dh,6   			; dh = 6, if 1.2M
		dec	al
		jz	loc_476
		mov	dh,8                    ; dh = 8, if 720k
		dec	al
		jz	loc_476
		mov	dh,30h                  ; dh = 30h, if 1.44M
		dec	al
		jz	loc_476
		mov	dh,0FFh
loc_476:
		mov	ah,3Fh
		call	Calculate_Parms
		and	dh,ah
		jz	loc_477
		and	ah,dh
loc_477:
		or	ah,ah
		jz	loc_479
		mov	di,offset Table_6 + 26
loc_478:
		sub	di,13
		rol	ah,1
		jnc	loc_478
		mov	ch,cs:[di+0Bh]		; num cylinders (UNDOCUMENDED)
		mov	dh,1
		mov	cl,cs:[di+4]            ; EOT
		mov	ax,cs
		jmp	short loc_482
loc_479:
		test	dl,80h
		jz	loc_480
		stc
		mov	ah,1
		jmp	short loc_471
loc_480:
		xor	dx,dx
		mov	byte ptr User_dl,0
		call	Get_CMOSType
		jz	loc_481
		mov	dl,1
		cmp	al,ah
		adc	dl,0
loc_481:
		xor	bx,bx
		xor	cx,cx
		xor	di,di
		xor	ax,ax
loc_482:
		mov	User_cx,cx
		mov	User_dx,dx
		mov	User_bx,bx
		mov	User_di,di
		mov	User_es,ax
		xor	ax,ax
		jmp	loc_471
int_13h_floppy	endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
Calculate_Parms	proc	near
		call	Get_DriveOpns
		shr	al,1
		jc	loc_483		; support 80 tracks ?
		and	ah,1
		jmp	short loc_484
loc_483:
		and	ah,3Eh
loc_484:
		or	al,al
		jnz	loc_485
		and	ah,9            ; &9 - dr. no determinate & no multi-rate
loc_485:
		dec	al
		jnz	loc_486
		and	ah,6		; &6 - dr. no determ. & multi-rate
loc_486:
		dec	al
		jnz	loc_ret_487
		and	ah,3Bh		; &3bh - dr. determ. & no multi-rate
loc_ret_487:
		retn
Calculate_Parms	endp

Table_0		db	0DFh, 02h, 25h, 02h, 09h, 2ah,0FFh, 50h,0F6h, 0Fh, 08h, 4Fh, 40h
Table_1		db	0DFh, 02h, 25h, 02h, 09h, 2Ah,0FFh, 50h,0F6h, 0Fh, 08h, 27h, 80h
Table_2		db	0DFh, 02h, 25h, 02h, 09h, 2Ah,0FFh, 50h,0F6h, 0Fh, 08h, 27h, 40h
Table_3		db	0DFh, 02h, 25h, 02h, 0Fh, 1Bh,0FFh, 54h,0F6h, 0Fh, 08h, 4Fh, 00h
Table_4		db	0DFh, 02h, 25h, 02h, 09h, 2Ah,0FFh, 50h,0F6h, 0Fh, 08h, 4Fh, 80h
Table_5		db	0DFh, 02h, 25h, 02h, 09h, 2Ah,0FFh, 50h,0F6h, 0Fh, 08h, 4Fh, 80h
Table_6		db	0DFh, 02h, 25h, 02h, 12h, 1Bh,0FFh, 6Ch,0F6h, 0Fh, 08h, 4Fh, 00h

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
Get_DriveOpns	proc	near                    ; al=drive options
						;    2:dr determined
						;    1:dr is multi-rate
						;    0:dr support 80 tracks
		mov	al,hdsk_options
		cmp	byte ptr User_dl,0
		je	loc_488
		mov	cl,4
		shr	al,cl
loc_488:
		and	al,0Fh
		retn
Get_DriveOpns	endp

;▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
Set_Dsk_Option	proc	near
		mov	cl,0F0h
		or	bl,bl
		jz	loc_489
		mov	cl,4
		shl	al,cl
		mov	cl,0Fh
loc_489:
		and	hdsk_options,cl
		or	hdsk_options,al
		retn
Set_Dsk_Option	endp

;▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
Test_Change	proc	near
		mov	bl,User_dl
		xor	bh,bh			; bx - drive
		test	hdsk_options,66h
		jz	loc_ret_491             ; if zf:no drives ???
		mov	dx,3F7h
		in	al,dx			; FDC control register
		or	al,al
		jns	loc_ret_491             ; bit 7:Change Line,
						; if 1 - changed diskette
		mov	al,hdsk0_media_st[bx]
		and	al,0EFh                 ; zero media eshtablished
		inc	al
		test	al,4                    ; drive state ok ?
		jz	loc_490
		sub	al,3
loc_490:
		dec	al			; 0:360k in 360k ?
						; 1:360k in 1.2M ?
						; 2:1.2M in 1.2M ?; bits 7..3 - no change
		mov	hdsk0_media_st[bx],al   ; set status ? need test
		call	Reset_Disk
		call	Restore_Change
		stc
loc_ret_491:
		retn
Test_Change	endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
Set_Media_St	proc	near
		mov	ah,hdsk0_media_st[bx]
		mov	cl,ah         		; cl=ah= media_st
		and	ah,0F0h
		test	ah,10h           	; media established ?
		jz	loc_492
		retn
loc_492:
		test	ah,40h                  ; 300k bit/s ?
		jz	loc_493
		cmp	hdsk0_cylinder[bx],0
		jne	loc_493
		mov	ah,60h                  ; 300k bit/s, double step
loc_493:
		mov	al,dsk_ret_code
		or	al,al
		jnz	loc_497
		push	ax
		call	Get_FloppyType
		jnc	loc_494
		pop	ax
		jmp	short loc_495
loc_494:
		cmp	al,3     		; 720k ?
		pop	ax
		jnz	loc_495
		mov	cl,80h
		mov	ah,80h
		jmp	short loc_496
loc_495:
		mov	cl,61h
		mov	ah,60h
loc_496:					; cl=80h,ah=80h for 720k
						; cl=61h,ah=60h for others
		mov	hdsk0_start_st[bx],cl
		jmp	short loc_503
loc_497:					; error_code <> 0
		and	al,1Fh
		cmp	al,2
		je	loc_500
		cmp	al,4
		je	loc_499
		cmp	al,10h
		je	loc_500
loc_498:
		mov	al,0
		xchg	al,hdsk0_start_st[bx]
		mov	hdsk0_media_st[bx],al
		stc
		retn
loc_499:
		cmp	ah,60h
		jne	loc_500
		cmp	hdsk0_cylinder[bx],0
		je	loc_500
		mov	ah,40h
		jmp	short loc_503
loc_500:
		or	ah,ah
		mov	ah,80h
		jz	loc_501
		mov	ah,60h
		js	loc_501
		mov	ah,0
loc_501:
		mov	al,hdsk0_start_st[bx]
		xor	al,ah
		and	al,0C0h
		jnz	loc_503
		cmp	dsk_ret_code,bh
		jne	loc_502
		mov	dsk_ret_code,2
loc_502:
		jmp	short loc_498
loc_503:
		mov	hdsk0_media_st[bx],ah
		call	Get_DriveOpns
		mov	cl,al
		and	al,6
		test	ah,0C0h
		jns	loc_504
		cmp	al,2   			; multi-rate, no dr.determined
		je	loc_500
		jmp	short loc_506
loc_504:
		jz	loc_505
		cmp	al,4
		je	loc_500
loc_505:
		cmp	al,0
		je	loc_500
loc_506:
		and	cl,1
		test	ah,20h
		jz	loc_507
		dec	cl
loc_507:
		cmp	byte ptr User_ch,28h
		adc	cl,0FFh
		jns	loc_508
		jmp	short loc_499
loc_508:
		and	dsk_ret_code,0
		mov	hdsk0_media_st[bx],ah
		retn
Set_Media_St	endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
Set_DataRate	proc	near
		mov	al,hdsk0_media_st[bx]
		and	al,0C0h
		cmp	dsk_data_rate,al
		je	loc_509
		mov	dsk_data_rate,al
		rol	al,1
		rol	al,1
		mov	dx,3F7h
		out	dx,al			; port 3F7h, dsk0 config ctrl
loc_509:
		clc
		retn
Set_DataRate	endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
Define_Dsk_Option	proc	near
						; return al = dsk option
		mov	bl,User_dl
		mov	bh,0
		test	hdsk0_media_st[bx],10h	; media established
		jnz	loc_ret_512
		cmp	bh,dsk_ret_code
		jb	loc_ret_512
		mov	ah,hdsk0_media_st[bx]
		call	Establish_Media
		call	Get_DriveOpns
		and	ah,0C0h
		jz	loc_ret_512
		jns	loc_510
		and	al,5
		jmp	short loc_511
loc_510:
		and	al,3
loc_511:
		push	ax
		call	Set_Dsk_Option
		pop	ax
loc_ret_512:
		retn
Define_Dsk_Option	endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
Establish_Media	proc	near
		add	ah,13h
		cmp	ah,93h
		je	loc_513		; old ah=80h
		inc	ah
		cmp	ah,74h
		je	loc_513		; old ah=60h
		inc	ah
		cmp	ah,15h
		je	loc_513		; old ah=00h
		or	ah,7
loc_513:
		mov	hdsk0_media_st[bx],ah
		call	Get_FloppyType
		jc	loc_514
		cmp	al,2
		jbe	loc_514		; 1.2M, 360k
		or	hdsk0_media_st[bx],7	; Undef. (***) (3" ???)
loc_514:
		mov	hdsk0_start_st[bx],bh
		retn
Establish_Media	endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
Seek_ToTrackCH  proc	near
		mov	bl,User_dl
		xor	bh,bh
		test	hdsk0_media_st[bx],20h	; double stepping ?
		jz	loc_515
		shl	ch,1
loc_515:
		mov	ah,User_ah
		shl	ah,1       		; ah:7 = 1, if motor off
		jnc	loc_517
		push	cx
		mov	ch,0Ah
locloop_516:
		call	Delay_on_ms
		loop	locloop_516
		pop	cx
loc_517:
		xor	dx,dx
		mov	al,User_dl
		inc	al
		and	al,dsk_recal_stat
		jnz	loc_518			; need recalibrate
		push	cx
		call	Recalibr
		pop	cx
		jc	loc_ret_521
loc_518:
		mov	bl,User_dl
		xor	bh,bh
		cmp	hdsk0_cylinder[bx],ch
		je	loc_ret_521
;▀▀▀▀ External Entry into Subroutine ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
Seek_toCH:
		mov	al,0Fh
		call	SendByte_toFDC          ; Seek (0f,hds+ds1ds0,cyl~~~)
		jc	loc_ret_521
		call	Send_2ndByte
		jc	loc_ret_521
		mov	al,ch
		mov	bl,User_dl
		xor	bh,bh
		mov	hdsk0_cylinder[bx],ch
		call	SendByte_toFDC         ; send cyl.
		jc	loc_ret_521
;▀▀▀▀ External Entry into Subroutine ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
Wait_OkEnd:
loc_519:
		call	Wait_End
		jc	loc_ret_521
		call	Read_StateIntr		; ah=ST0
		jc	loc_ret_521
		mov	al,ah
		and	al,3			; code drive of intr
		cmp	al,User_dl
		jne	loc_519
		test	ah,0C0h                 ; test error
		jz	loc_ret_521
		or	dsk_ret_code,40h
loc_520:
		stc
loc_ret_521:
		retn
Seek_ToTrackCH  endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
Recalibr	proc	near			; recalibration
		mov	al,7
		call	SendByte_toFDC		; Seek (7,2ndbyte,cyl~~~)
		jc	loc_ret_521
		call	Send_2ndByte
		jc	loc_ret_521
		call	Wait_OkEnd		; ah=st0
		jnc	loc_522
		cmp	dsk_ret_code,40h        ; track not found
		jne	loc_520
		and	ah,11010000b
		cmp	ah,50h			; error & command start, but break
		jne	loc_520
		mov	dsk_ret_code,0
		mov	al,7
		call	SendByte_toFDC          ; Seek
		jc	loc_ret_521
		call	Send_2ndByte
		jc	loc_ret_521
		call	Wait_OkEnd              ; ah=st0
		jc	loc_ret_521
loc_522:
		test	ah,10h			; error ?
		jz	loc_523
		or	dsk_ret_code,40h
		stc
		retn
loc_523:
		mov	al,User_dl
		inc	al
		or	dsk_recal_stat,al       ; disk need recalibr.
		mov	bl,User_dl
		xor	bh,bh
		mov	hdsk0_cylinder[bx],0    ; track0
		retn
Recalibr	endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
Read_StateIntr	proc	near
						; Return:
						; ah:ST0;
						; al:num cyl after read
						;     state of intrps
		mov	al,8
		call	SendByte_toFDC		; send 8 (read state of intr'ps)
		jc	loc_ret_525
		mov	cx,2
;▀▀▀▀ External Entry into Subroutine ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
Get_2_StBytes:
						; get ah:1st stbyte, al:2nd stbyte
		mov	si,42h
		push	word ptr [si]
		call	Get_Status_Bytes	; get 2 status bytes
		jc	loc_524
		mov	ax,[si]
		xchg	ah,al			; ah -1st byte; al -2nd byte
loc_524:
		pop	word ptr [si]
loc_ret_525:
		retn
Read_StateIntr	endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
Get_Status	proc	near			; get status, if error - get code

		call	Get_7_Status_Bytes	; ah = ST0
		jc	loc_ret_530
		and	ah,0C0h
		jz	loc_ret_530		; no errors
		cmp	ah,40h			; coomand start, but break
		jne	loc_528
		mov	ah,dsk_status_2
		and	ah,0B7h
		mov	bx,8
loc_527:
		dec	bx
		shr	ah,1
		jc	loc_531
		jnz	loc_527
loc_528:
		mov	al,20h
loc_529:
		or	dsk_ret_code,al
		stc
loc_ret_530:
		retn
CodeError_Table	db	 04h,20h,10h,08h,20h,04h,03h,02h
loc_531:
		mov	al,cs:CodeError_Table[bx]
		jmp	short loc_529
Get_Status	endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
Restore_Change proc	near
		mov	dx,3F7h
		in	al,dx			; FDC control register
		or	al,al
		jns	loc_ret_534		; bit7=1, if Change diskette
		mov	bl,User_dl
		xor	bh,bh			; bx=disk
		call	Delay_on_ms
		mov	cx,0Ah
locloop_532:
		call	Delay_on_ms
		loop	locloop_532
		mov	ch,1
		call	Seek_toCH 		; seek to 1st cylinder
		call	Recalibr
		mov	dx,3F7h
		in	al,dx
		or	al,al
		mov	al,6
		jns	loc_533			; no change diskette
		mov	al,80h
		stc
loc_533:                                        ; al=80, if change disk, else =6
		mov	dsk_ret_code,al
loc_ret_534:
		retn
Restore_Change	endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
Wait_Motor	proc	near			; wait - motor start &
						; head load

		call	Get_DiskTable
		or	dx,dx
		jz	loc_538
		mov	al,es:[si+9]		; table[9] - head load time (ms)
		or	al,al
		jnz	loc_536
		mov	al,0Fh
		mov	bl,User_dl
		xor	bh,bh
		mov	cl,hdsk0_media_st[bx]
		and	cl,7
		jz	loc_535
		cmp	cl,3
		jne	loc_536
loc_535:
		mov	al,14h
loc_536:
		mov	ah,0Ah
		mul	ah
		mov	cx,ax
locloop_537:
		call	Delay_on_ms
		loop	locloop_537
loc_538:
		mov	ax,90FDh
		int	15h			; General services, ah=func 90h
						;  device busy, al=diskette motor start
		jc	loc_543
		mov	al,es:[si+0Ah]		; motor startup time (in 1/8 sec)
		mov	ah,User_ah
		shl	ah,1
		jnc	loc_543			; cf, if motor off
		test	ah,2
		jz	loc_539			; zf=0, if write
		cmp	al,8
		jae	loc_540
		mov	al,8
loc_539:
		cmp	al,5
		jae	loc_540
		mov	al,5
loc_540:
		push	ax
		mov	ah,125
		mul	ah
		mov	dx,1000
		mul	dx
		mov	cx,dx
		mov	dx,ax
		mov	ah,86h
		int	15h			; General services, ah=func 86h
						;  wait cx,dx u seconds
		pop	ax
		jnc	loc_543
loc_541:
		mov	cx,1250
locloop_542:
		call	Delay_on_ms
		loop	locloop_542
		dec	al
		jnz	loc_541
loc_543:
		and	byte ptr User_ah,7Fh
		retn
Wait_Motor	endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
Get_FloppyType	proc	near                    ; get floppy type
						; 0:not installed
						; 1:360k;      2:1.2M
						; 3:720k(3");  4:1.44M(3")
		mov	al,0Eh
		call	Read_CMOS		; POST status byte
		sti
		cmp	al,0C0h                 ; CMOS invalid ?
		cmc
		jc	loc_ret_545
;▀▀▀▀ External Entry into Subroutine ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
Get_CMOSType:
		mov	al,10h
		call	Read_CMOS     		; floppy types
		sti
		cmp	byte ptr User_dl,0
		jne	loc_544
		push	cx
		mov	cl,4
		ror	al,cl
		pop	cx
loc_544:
		mov	ah,al
		and	al,0Fh              	; al=floppy type
loc_ret_545:
		retn
Get_FloppyType	endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
Reset_Disk	proc	near
		cli
		and	dsk_recal_stat,70h	; set interrupt flag
		mov	al,dsk_motor_stat
		mov	ah,al
		mov	cl,4
		shl	al,cl
		or	al,0Ah
		test	ah,40h
		jnz	loc_546
		dec	ax
		test	ah,20h
		jnz	loc_546
		dec	ax
loc_546:
		mov	dx,3F2h
		out	dx,al			; Enable int. reset FDC. bit 0 -drive
		mov	cx,4
locloop_547:
		loop	locloop_547		; delay for reset FDC
		or	al,4
		out	dx,al			; End of reset
		sti
		call	Wait_End		; wait end operation
		call	Read_StateIntr          ; ah=ST0
		jc	loc_ret_549
		and	ah,0C0h
		xor	ah,0C0h
		test	ah,0C0h
		jz	loc_548                 ; Change state of Ready line
		or	dsk_ret_code,20h
		jmp	short loc_ret_549
loc_548:
		mov	al,3
		call	SendByte_toFDC          ; Define (3,SRT+HUT,HLT+ND~~~)
		jc	loc_ret_549
		xor	bx,bx
		call	Send_2_From_TableBX	; send Table[0],Table[1]
loc_ret_549:
		retn
Reset_Disk	endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
Set_Motor	proc	near
		cli
		mov	cl,User_dl
		mov	dh,1
		shl	dh,cl    		; dh: 1-A:,2-B: ...
		mov	ch,dsk_motor_stat
		mov	al,0FFh
		test	ch,dh
		jz	loc_550                 ; if zf, motor of the needed
						; drive off
		call	Get_DiskTable
		mov	ah,es:[si+2]            ; motor off time
		mov	al,0EDh
		cmp	dsk_motor_tmr,ah
		jbe	loc_551
		sub	al,ah
		add	al,dsk_motor_tmr
loc_550:
		or	byte ptr User_ah,80h    ; Bit7 of User_ah =1, if motor off
loc_551:
		mov	dsk_motor_tmr,al
		and	ch,8Fh
		or	ch,dh
		mov	al,ch
		mov	cl,4
		shl	al,cl
		shl	dh,cl
		or	ch,dh
		or	al,0Ch
		or	al,User_dl
		mov	dx,3F2h
		out	dx,al			; Set motors
		mov	dsk_motor_stat,ch
		sti
		retn
Set_Motor	endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
Get_DiskTable   proc	near			; es:si - Disk Table (Int 1Eh)
		xor	si,si
		mov	es,si
		les	si,dword ptr es:[78h]
		retn
Get_DiskTable   endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
Set_DMA		proc	near
		mov	ah,User_ah
		shr	ah,1
		mov	al,4Ah
		jc	loc_552                 ; 01001010 - Write, Format
						; can 2, read cycle, inc, single
		shr	ah,1
		mov	al,46h                  ; 01000110 - Read
						; can 2, write cycle, inc, single
		jc	loc_552
		mov	al,42h                  ; 01000010 - Verify
						; can 2, ver. cycle, inc, single
loc_552:
		mov	dx,0Bh
		out	dx,al			; Write DMA-1 mode reg
		mov	dx,User_es
		call	Get_DiskTable           ; es:si
		mov	cl,4
		rol	dx,cl
		mov	ch,dl
		and	ch,0Fh                  ; ch - page addr.
		and	dl,0F0h
		add	dx,User_bx              ; dx - offset
		adc	ch,0
		mov	al,User_al              ; sectors or sect/track for format
		xor	ah,ah
		mov	cl,es:[si+3]		; sector size
		shl	ax,cl                   ; ax = sectors*128*2^sect_size
		cmp	ax,200h
		ja	DMA_Overrun
		mov	cl,7
		shl	ax,cl
		dec	ax                      ; ax - num bytes for transfer -1
		mov	bx,dx			; bx - ofs
		add	dx,ax
		jc	DMA_Overrun
		cli
		mov	dx,0Ch
		out	dx,al	    		; clear
		mov	dx,5
		jmp	short $+2
		jmp	short $+2
		out	dx,al	                ; write Count (lo)
		xchg	al,ah
		jmp	short $+2
		jmp	short $+2
		out	dx,al			; write Count (Hi)
		mov	dx,4
		xchg	ax,bx
		jmp	short $+2
		jmp	short $+2
		out	dx,al			; Write addr. (lo)
		xchg	al,ah
		jmp	short $+2
		jmp	short $+2
		out	dx,al			; Write addr. (Hi)
		sti
		xchg	al,ch
		mov	dx,81h
		out	dx,al			; port 81h, DMA page reg ch 2
		mov	dx,0Ah
		mov	al,2
		jmp	short $+2
		out	dx,al			; port 0Ah, DMA-1 mask reg bit
		clc
loc_ret_553:
		retn
DMA_Overrun:
		mov	dsk_ret_code,9
		stc
		jmp	short loc_ret_553
Set_DMA		endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
Wait_Ok_to_Send	proc	near
						; wait for OK to send/resend
						; command/data, else cf=1, error
						; return main status register
						; dx = 3f4h
		mov	dx,3F4h
		push	cx
		mov	cx,0Dh
locloop_555:
		loop	locloop_555

locloop_556:
		in	al,dx			; Read main status register
		test	al,80h                  ; bit 7 =1, if OK to send command/data
		loopz	locloop_556
		jnz	loc_557                 ; wait ok
		or	dsk_ret_code,80h        ;
		stc
loc_557:
		pop	cx
		retn
Wait_Ok_to_Send	endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
Send_2ndByte		proc	near                    ; send 2nd byte of command
		mov	al,User_dh
		shl	al,1
		shl	al,1
		or	al,User_dl
		clc                             ; al = Hds+ds1ds0
;▀▀▀▀ External Entry into Subroutine ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
SendByteToFDC:
		jc	loc_ret_559
;▀▀▀▀ External Entry into Subroutine ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
SendByte_toFDC:
		mov	ah,al
		call	Wait_Ok_to_Send		; al = main status register
		jc	loc_ret_559
		test	al,40h                  ; b6: data direction,
						; 1= FDC->CPU, 0= FDC<-CPU
		jnz	loc_558
		inc	dx                      ; dx=3f5h,  FDC<-CPU
		mov	al,ah
		out	dx,al                   ; send byte to FDC
		retn
loc_558:                                        ; FDC->CPU
		call	Get_7_Status_Bytes
		or	dsk_ret_code,20h        ; set error 20h
		stc
loc_ret_559:
		retn
Send_2ndByte	endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
Send_2_From_TableBX	proc	near
		mov	cx,2                    ; send 2 bytes from Table[bx]
						; to FDC
;▀▀▀▀ External Entry into Subroutine ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
Send_CX_From_TableBX:                           ; send cx bytes from
						; DiskTable[bx]... to FDC
		call	Get_DiskTable
locloop_560:
		mov	al,es:[bx+si]		; DiskTable[bx]
		call	SendByteToFDC   	; send byte
		jc	loc_ret_561
		inc	bx
		loop	locloop_560
		clc
loc_ret_561:
		retn
Send_2_From_TableBX	endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
Get_7_Status_Bytes 	proc	near
		mov	cx,7
;▀▀▀▀ External Entry into Subroutine ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
Get_Status_Bytes:
						; get cx status bytes
						; to dsk_status_1...

		mov	bx,42h 			; offset dsk_status_1
locloop_562:
		call	Wait_Ok_to_Send		; al= main status reg
		jc	loc_564
		and	al,50h
		cmp	al,50h                  ; FDC->CPU & FDC busy ?
		jne	loc_563
		inc	dx                      ; 3f5h
		in	al,dx
		mov	[bx],al
		inc	bx
		loop	locloop_562             ; get cx status's to bx...
		clc
		jmp	short loc_564
loc_563:
		stc
loc_564:
		mov	ah,dsk_status_1
		retn
Get_7_Status_Bytes	endp



;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
Wait_End	proc	near
;						; Wait end operation
		mov	ax,9001h
		int	15h			; General services, ah=func 90h
						;  device busy, al=1 (floppy)
		jc	loc_566
		mov	cx,13000
locloop_565:
		call	Delay_on_ms
		test	dsk_recal_stat,80h      ; wait to int flag = 1
		loopz	locloop_565
		jnz	loc_567
loc_566:
		mov	dsk_ret_code,80h
		stc
		retn
loc_567:
		and	dsk_recal_stat,7Fh
		retn
Wait_End	endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
SaveRegisters	proc	near
		sti
		push	cx
		push	dx
		push	si
		push	di
		push	bp
		push	ds
		push	es
		mov	bp,sp
		push	word ptr [bp+0Eh]
		mov	[bp+0Eh],bx
		mov	bp,[bp+4]
		retn
SaveRegisters	endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
ConvNumber	proc	near

;	di:=ah*2, cf if di> primary_di ; ds:= BiosSeg
		push	ax
		mov	al,ah
		xor	ah,ah
		shl	ax,1
		cmp	di,ax
		jb	loc_793
		mov	di,ax
loc_793:
		pop	ax
;▀▀▀▀ External Entry into Subroutine ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
SetBiosSeg:
		mov	ds,cs:BIOS_Seg
		retn
ConvNumber	endp

;▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
Delay_on_ms	proc	near

;						; delay
		push	cx
		push	bx
		mov	bl,ds:[72h]		; warm boot flag ?? (84h on my computer)
		and	bx,0Ch
		shr	bx,1                    ; bx = 0,2,4,6
		mov	cx,cs:Delays[bx]
		pop	bx
locloop_801:
		loop	locloop_801
		pop	cx
		retn
Delay_on_ms	endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
End_Interrupt:
		pop	es
		pop	ds
		pop	bp
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		iret

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
Read_CMOS	proc	near			; al=CMOS[al]
		push	dx
		mov	dx,70h
		cli
		out	dx,al
		inc	dx
		jmp	short $+2
		jmp	short $+2
		in	al,dx
		pop	dx
		retn
Read_CMOS	endp

; ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ int 0Eh ▒▒▒▒▒
;
;   FLOPPY DISK	CONTROLLER (called by hardware 8259-1, IRQ 6)

int_0Eh_floppy	proc	near
		push	ax
		push	dx
		push	ds
		call	SetBiosSeg
		or	dsk_recal_stat,80h	; set int flag
		mov	al,20h
		mov	dx,20h
		out	dx,al			; port 20h, 8259-1 int command
						;  al = 20h, end of interrupt
		pop	ds
		pop	dx
		mov	ax,9101h
		int	15h			; General services, ah=func 91h
						;  interrupt complete, al=type
		pop	ax
		iret
int_0Eh_floppy	endp
;▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

Code_Ok		db	0

BIOS_Seg	dw	40h
Delays		dw	4Fh, 46h, 00h, 37h

;▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄



install:	mov	ax,2540h
		lea	dx,int_13h_floppy
		int	21h
		mov	ax,250Eh
		lea	dx,int_0Eh_floppy
		int	21h
		mov	ah,9
		lea	dx,Mess
		int	21h
		lea	dx,install
		int	27h

Mess		db	'Diskette BIOS',13,10
		db	'Copyright 1985,1986 Phoenix Technologies Ltd.',13,10
		db	'Copyright 1991 Gurtjak D.A. (Donetsk,Ukraine)',13,10,'$'


code		ends
		end	start
