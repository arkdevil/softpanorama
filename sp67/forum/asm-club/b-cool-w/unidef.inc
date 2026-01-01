;---------------------------------------------------------------------------
; UNIDEF.INC      Assembly Language Macro Definitions File
;
; Copyright(c) 1991,94 by Bobby Z.
;
; Last modified 04/07/94
;---------------------------------------------------------------------------

__INC__		EQU	1	; Do not redefine macros in include files

; Constants for Read- and WriteAbsoluteSectors macros

FirstHD		EQU	80h
SecondHD	EQU	81h
FirstFD		EQU	0
SecondFD	EQU	1

; File attribute constants

Archive		EQU	00h
Normal		EQU	20h
ReadOnly	EQU	01h
Hidden		EQU	02h
SysFile		EQU	04h
VolumeID	EQU	08h
Directory	EQU	10h
AnyFile		EQU	3Fh

; Open mode constants
fmRead		EQU	0
fmWrite		EQU	1
fmReadWrite	EQU	2

fmDenyReadWrite	EQU	10h
fmDenyWrite	EQU	20h
fmDenyRead	EQU	30h
fmDenyNone	EQU	40h
fmPrivate	EQU	80h

; Type conversion constants
_wp 		equ	<Word Ptr>
_bp     	equ	<Byte Ptr>
_dp		equ	<DWord Ptr>

_wpcs		equ	<word ptr cs:>
_bpcs		equ	<byte ptr cs:>
_dpcs		equ	<dword ptr cs:>
_wpds		equ	<word ptr ds:>
_bpds		equ	<byte ptr ds:>
_dpds		equ	<dword ptr ds:>
_wpes		equ	<word ptr es:>
_bpes		equ	<byte ptr es:>
_dpes		equ	<dword ptr es:>

; Useful processor commands prefixes

FarJump		EQU	0EAh	; followed by dword immediate address
FarCall		EQU	09Ah	; followed by dword immediate address
i386Break	EQU	0F1h	; Generates INT 01 on 386+ CPUs


;	DPMI 0.9 function abbrevs

; LDT management
AllocateLDTDesc	equ	0000h	; allocate LDT descriptors
FreeLDTDesc	equ	0001h	; free LDT descriptors
Segment2Desc	equ	0002h	; convert segment to descriptor
GetNextSelInc	equ	0003h	; get next selector increment value
dpmiReserved1	equ	0004h	; reserved, should not be called
dpmiReserved2	equ	0005h	; reserved, should not be called
GetSegmentBase	equ	0006h	; get segment base address
SetSegmentBase	equ	0007h	; set segment base address
SetSegmentLimit	equ	0008h	; set segment limit
SetAccessRights	equ	0009h	; set segment access rights
CreateCodeAlias	equ	000Ah	; create code segment alias descriptor
GetDescriptor	equ	000Bh	; get LDT descriptor
SetDescriptor	equ	000Ch	; set LDT descriptor
AllocSpecific	equ	000Dh	; allocate specific LDT descriptor

; DOS memory management
AllocDOSBlock	equ	0100h	; allocate DOS memory block
FreeDOSBlock	equ	0101h	; free DOS memory block
ResizeDOSBlock	equ	0102h	; resize DOS memory block

; Interrupt services
GetRMVector	equ	0200h	; get real mode interrupt vector
SetRMVector	equ	0201h	; set real mode interrupt vector
GetExceptionHnd	equ	0202h	; get exception handler address
SetExceptionHnd	equ	0203h	; set exception handler
GetPMVector	equ	0204h	; get protected mode interrupt vector
SetPMVector	equ	0205h	; set protected mode interrupt vector

; Translation services
SimulateRMInt	equ	0300h	; simulate Real Mode interrupt
CallRMFRoutine	equ	0301h	; call real mode routine with far ret frame
CallRMIRoutine	equ	0302h	; call real mode routine with iret frame
AllocRMCallBack	equ	0303h	; allocate real mode call-back address
FreeRMCallBack	equ	0304h	; free real mode call-back address
GetSaveRestAddr	equ	0305h	; get Save/Restore addresses
GetRawModeSw	equ	0306h	; get raw mode switch addresses

; Get Version
GetVersion	equ	0400h	; get DPMI version

; Memory management
GetMemFree	equ	0500h	; get free memory information
MemAlloc	equ	0501h	; allocate memory block
MemFree		equ	0502h	; free memory block
MemResize	equ	0503h	; resize memory block

; Page locking services
LockLinear	equ	0600h	; Lock linear region
UnlockLinear	equ	0601h	; unlock linear region
MarkRMPageable	equ	0602h	; mark real mode region as pageable
RelockRMRegion	equ	0603h	; relock real mode region
GetPageSize	equ	0604	; get page size

; Demand paging performance tuning services
dpmiReserved3	equ	0700h	; reserved, should not be called
dpmiReserved4	equ	0701h	; reserved, should not be called
MarkAsDMC	equ	0702h	; mark pageable as demand paging candidate
DiscardPage	equ	0703h	; discard page contents

; Physical address mapping
MapPhysical	equ	0800h	; map physical address to linear address

; Virtual interrupt state functions
GetDisableVIS	equ	0900h	; get and disable VIS
GetEnableVIS	equ	0901h	; get and enable VIS
GetVIS		equ	0902h	; get VIS

; Get vendor specific API entry point
GetVendorAPI	equ	0A00h	; get vendor specific API entry point

; Debug register support
SetWatchpoint	equ	0B00h	; set debug watchpoint
ClearWatchpoint	equ	0B01h	; clear debug watchpoint
GetWatchState	equ	0B02h	; get state of debug watchpoint
ResetWatchPoint	equ	0B03h	; reset debug watchpoint

; lxx macros : load register xx with offset to Source

lbx	macro	Source
	mov	bx,offset Source
	endm

ldx	macro	Source
	mov	dx,offset Source
	endm

ldi	macro	Source
	mov	di,offset Source
	endm

lsi	macro	Source
	mov	si,offset Source
	endm

; clr macro    Set register REG's value to 0

clr	macro	REG
	sub	REG,REG
	endm


; PUSHALL Save all registers on stack

PushAll	macro
ifdef	__use_286__
	push	ds es
	pusha
else
	push	ds es ax bx cx dx si di bp
endif
	endm

; POPALL  Restore all registers

PopAll	macro
ifdef	__use_286__
	popa
	pop	es ds
else
	pop	bp di si dx cx bx ax es ds
endif
	endm

; READCHAR	Read character from keyboard

ReadChar	macro
	clr	ax
	int	16h
	endm

UpcaseMac	macro
	LOCAL	@@Ex
	cmp	al,'a'
	jb	@@Ex
	cmp	al,'z'
	ja	@@Ex
	and	al,11011111B
@@Ex:
	endm

; UPCASESTRMAC	Converts string to uppercase.
; REG must be a register containing offset of string, DS should be a data seg
; MaxLen can be a register or an immediate value. The best usage is to define
; a proc with such text:
;
;	xxxx	proc
;	UpcaseStrMac	<somereg>,<lengthreg>
;	ret
;	endp
; and call it with parameters passed by registers or by stack if necessary.

UpcaseStrMac	macro	REG,MaxLen
	LOCAL	__LoopL

	push	si di cx
	mov	si,REG
	mov	di,si
ifdifi	<MaxLen>,<CX>
	mov	cx,MaxLen
endif
__LoopL:
	lodsb
	UpcaseMac
	stosb
	loop	__LoopL
	pop	cx si di
	endm

; Allocate_Memory Allocate memory block with size SizeInBytes

Allocate_Memory  macro SizeInBytes
ifdifi	<SizeInBytes>,<BX>
	mov	bx,SizeInBytes
endif
ifdef	__use_286__
	shr	bx,4
else
	mov	cl,4
	shr	bx,cl
endif
	inc	bx
	mov	ah,48h
	int	21h
	endm

; RELEASE_MEMORY	Release memory block allocated by Allocate_Memory

Release_Memory	macro AllocatedSeg
ifdifi	<AllocatedSeg>,<ES>
	push	es
ifdifi	<AllocatedSeg>,<AX>
	mov	ax,AllocatedSeg
endif
	mov	es,ax
endif
	mov	ah,49h
	int	21h
ifdifi	<AllocatedSeg>,<ES>
	pop	es
endif
	endm

; MODIFY_BLOCK	Modify memory block size

Modify_Block	macro BlockSeg,NewSizeInBytes
ifdifi	<BlockSeg>,<ES>
	push	es
	mov	ax,BlockSeg
	mov	es,ax
endif
	mov	bx,NewSizeInBytes
ifdef	__use_286__
	shr	bx,4
else
	mov	cl,4
	shr	bx,cl
endif
	inc	bx		;; Increasing to paragraph boundary
	mov	ah,4Ah
	int	21h
ifdifi	<BlockSeg>,<ES>
	pop	es
endif
	endm

OpenFile	macro	NamePtr,Mode
ifnb	<Mode>
if	&Mode
	mov	ax,3D00h+&Mode
else
	mov	ax,3D00h
endif
else
	mov	ax,3D00h
endif
ifdifi	<NamePtr>,<DX>
	ldx	<NamePtr>
endif
	int	21h
	endm

CreateFile	macro	NamePtr,Attribute
	mov	ah,3Ch
ifnb	<Attribute>
if	&Attribute
	mov	cx,Attribute
else
	clr	cx
endif
endif
ifdifi	<NamePtr>,<DX>
	ldx	<NamePtr>
endif
	int	21h
	endm

CloseFile	macro	Handle
ifdifi	<Handle>,<BX>
	mov	bx,Handle
endif
	mov	ah,3Eh
	int	21h
	endm

; New DOS 5.0 functions

GetUMBLink	EQU	5802h
; returns  AL = 0 UMB usage disabled 
;          AL = 1 UMB usage enabled

SetUMBLink	EQU	5803h
; requires BX = 0 UMB usage disabled
;          BX = 1 UMB usage enabled

GetMemStrategy	EQU	5800h
; returns strategy in AX ( see list below )

SetMemStrategy	EQU	5801h
; requires strategy in BX

; New to DOS 5.0
UMBEnabled	EQU	0001h
UMBDisabled	EQU	0000h


FIRST_FIT_LOW		EQU	0001h	; Allocate the lowest available block
BEST_FIT_LOW		EQU	0002h	; Allocate the best fitting block
LAST_FIT_LOW		EQU	0003h	; Allocate the highest available block

; New to DOS 5.0
FIRST_FIT_HIGHONLY	EQU	0040h	; same as 0000h but for UMB only
BEST_FIT_HIGHONLY	EQU	0041h	; --"--   0001h --"--
LAST_FIT_HIGHONLY	EQU	0042h	; --"--   0002h --"--
FIRST_FIT_HIGH		EQU	0080h	; tries UMB first and uses conventional
BEST_FIT_HIGH		EQU	0081h	; memory if failed. All the rest is as
LAST_FIT_HIGH		EQU	0082h	; for 0,1,2 strats.

GetUpperMemoryLink	macro
	mov	ax,GetUMBLink
	int	21h
	xchg	bx,ax
	endm

SetUpperMemoryLink	macro	Enable
	mov	ax,SetUMBLink
	mov	bx,Enable
	int	21h
	endm

GetMemoryStrategy	macro
	mov	ax,GetMemStrategy
	int	21h
	endm

SetMemoryStrategy	macro Strategy
	mov	ax,SetMemStrategy
	mov	bx,Strategy
	int	21h
	endm
