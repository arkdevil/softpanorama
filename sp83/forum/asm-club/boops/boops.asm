title	Boops -- Floppy Boot Bypasser
page	,132

comment	#


	BOOPS  Floppy Boot Bypasser  (c) 1992, Urmas Rahu
	
	This program modifies the boot sector of a diskette so that the
	floppy may be in the drive at bootup, and the PC would still boot
	from the hard drive.  The boot code simply loads the master boot
	sector of the first hard disk into memory and passes control to it.
	
	This program was inspired by Bill Gibson's similar product, BootThru.
	The problem with his program (ver 1.05, 1987) was that it supports
	360KB floppies only.  My program should work equally well on all
	floppy formats.  The only requirement is, that the disketts must
	have the standard 512-byte sectors.  You should not use this program
	to modify copy-protected floppies.

	Syntax:		BOOPS drive:

			The colon after the drive letter is required.


	Date:		Feb-01-1992

	#




SECSIZE		equ	512			; standard sector size
OFF_SECSIZE	equ	2			; offset of sec size field in
						;  disk info block


code segment
assume cs:code, ds:code, ss:code

org 100h
entry:		jmp	start	


bootsector:	jmp	short bootcode		; boot sector starts here
		nop

bootdata	db	1bH dup (?)		; near jump to boot code

comment #	this stuff was in BootThru, i couldn't figure its purpose
.radix 16
;		db	0,0,0a
;		db	0df,02,25,02,09,2a,0ff,50,0f6,0f,02
.radix 10 #


hdload:		mov	ax, 0201H		; this part of code will be
		mov	bx, 07c0H		;  copied to 07c0:0200, just
		mov	es, bx			;  above the boot sector image,
		xor	bx, bx			;  so that the hard disk boot
		mov	cx, 0001H		;  sector will fit right below
		mov	dx, 0080H		;  it.
		int	13H			; read hard drive's boot record

		db	0e9H			; jump to hard disk boot code
		dw	-SECSIZE - (hdload_end-hdload)	; (at 07c0:0000)
hdload_end	label	byte

bootcode:					; start of my boot code
		mov	bx, 07c0H
		mov	ds, bx			; set segment regs to 07c0
		mov	es, bx
		
		mov	bx, message - bootsector
		mov	ah, 0eH

dispmsg:	mov	al, [bx]		; show message of bypassing
		cmp	al, 0
		jz	copycode
		int	10H			; write teletype
		inc	bx
		jmp	short dispmsg	

copycode:	mov	si, hdload - bootsector	; copy the hard disk boot sector
		mov	di, SECSIZE		;  loader to 07c0:0200
		mov	cx, bootcode - hdload
		cld
	rep	movsb
		
		db	0e9H			; jump to hard disk boot sector
		dw	SECSIZE - (copycode_end - bootsector)	; loader
copycode_end	label	byte			; (at 07c0:0200)



message		db	13,"BOOPS  (c) 1992, Urmas Rahu:  "
		db	"Bypassing floppy boot . . .  ",13,10,0

		db	"                                                  "
		db	"   BOOPS -- Floppy Boot Bypasser   Version 1.0"
		db	"   (c) 1992, Urmas Rahu    My address is:"
		db	" Tammsaare 57-27, EE0034 Tallinn, Estonia.   "
		db	" Write for information about our products.   "

		db	"                    "
		db	' "For those about to rock / We salute you"   (AC/DC)  '

filler		db	SECSIZE - (filler-bootsector) dup (' ')



old_bootdata:	db	1eH dup (?)		; old boot sector will be 
old_bootcode:	db	(512-1eH) dup (?)	;  read here





start:		jmp	go

msg_title	db	"Boops  --  Floppy Boot Bypasser  (c) 1992, Urmas Rahu"
		db	13,10,'$'

msg_usage	db	13,10
		db	"Usage:     BOOPS drive:"
		db	13,10
		db	"Function:  This program will modify the boot sector of",13,10
		db	"           a floppy disk so that the computer will boot from",13,10
		db	"           the hard disk even if a floppy is in the drive.",13,10
		db	'$'

msg_run		db	"Writing boot sector of drive "
msg_run_drive	db	"@: . . . $"

msg_done	db	"OK, completed.   $"

msg_failed	db	"Disk access failed, aborted.   $"

msg_nonstdsec	db	"Non-standard sector size, aborted.   $"

msg_invalid_dr	db	"Invalid drive, aborted.   $"



drive		db	0

jmp2du:		jmp	disp_usage		; jmp-jmp


go:		mov	ah, 9
		mov	dx, offset msg_title
		int	21H			; show title

		mov	di, 81H			; point at UPA
		xor	ch, ch
		mov	cl, cs:80H		; count of chars at UPA
		jcxz	jmp2du			; empty command line
		mov	al, ':'			; search for colon at cmd line
		cld
	repne	scasb
		jnz	disp_usage		; no colon, no drive: disp help

		mov	dl, byte ptr [di-2]	; point at drive character
		and	dl, 0dfH		; convert to uppercase
		sub	dl, 41H			; convert to drive number
;		test	dl, 0feH		; only 0 and 1 allowed
;		jnz	disp_usage

		mov	msg_run_drive, dl	; insert drive letter
		add	msg_run_drive, 41H
		mov	drive, dl		; save drive number
		mov	dx, offset msg_run
		mov	ah, 9
		int	21H			; show message of running

		push	ds			; save ds
		mov	ah, 32H			; call undocumented DOS fn
		mov	dl, drive
		inc	dl			; (A: is 1, etc)
		int	21H			; get disk info !!DS destroyed!!
		cmp	al, 0			; ok?
		jnz	bad_drive		; invalid drive

		cmp	word ptr [bx+OFF_SECSIZE], SECSIZE
		jne	bad_secsize		; sector size not 512 bytes		

		pop	ds			; restore ds

		mov	ax, 0201H		; read boot sector with BIOS
		mov	dh, 0
		mov	dl, drive
		mov	cx, 0001H
		mov	bx, cs
		mov	es, bx
		mov	bx, offset old_bootdata
		push	es
		push	bx
		int	13H
		jc	disk_failed
				
		pop	si			; point at old boot sector
		add	si, 3			; skip the jmp instruction
		pop	bx			; segment
		mov	ds, bx
		mov	es, bx
		mov	di, offset bootdata
		mov	cx, 1bH			; copy old data from boot sector
		cld
	rep	movsb
		
		mov	bx, offset bootsector	; write new boot sector
		mov	ax, 0301H
		mov	dh, 0
		mov	dl, drive
		mov	cx, 0001H
		int	13H
		jc	disk_failed

		mov	dx, offset msg_done
		mov	ah, 9
		int	21H			; completed message

		mov	ax, 4c00H		; exit code 0
		int	21H

disp_usage:	mov	ah,9
		mov	dx, offset msg_usage
		int	21H

		mov	ax, 4c01H		; exit code 1
		int	21H


disk_failed:	mov	ah, 9
		mov	dx, offset msg_failed
		int	21H

exit_2:		mov	ax, 4c02H		; exit code 2
		int	21H

bad_drive:	pop	ds			; remember?
		mov	ah, 9
		mov	dx, offset msg_invalid_dr
		int	21H
		jmp	short exit_2

bad_secsize:	pop	ds			; remember ds?
		mov	ah, 9			
		mov	dx, offset msg_nonstdsec
		int	21H
		jmp	short exit_2


code ends

end entry

