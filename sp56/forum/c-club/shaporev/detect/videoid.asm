		TITLE	'Listing C-1 - VideoID'
		NAME	VideoID
		PAGE	55,132
;
; Function:	Detects the presence of various video subsystems and
;		associated monitors.
;
; Caller:	MicroSoft C:
;
;			void VideoID(far VIDstruct);
;
;			struct
;			{
;				char VideoSubsystem;
;				char Display;
;			}
;				*VIDstruct[2];
;
;		Subsystem ID values:
;				 0  - (none)
;				 1  - MDA
;				 2  - CGA
;				 3  - EGA
;				 4  - PGA
;				 5  - MCGA
;				 6  - VGA
;				 7  - PC 3270
;				80h - HGC
;				81h - HGC+
;				82h - Hercules InColor
;				E0h - LCD
;				F0h - Tandy 1000
;
;		Display Types:	 0  - (none)
;				 1  - MDA-compatible monochrome
;				 2  - CGA-compatible color
;				 3  - EGA-compatible color
;				 4  - IBM professional
;				 5  - PS/2-compatible monochrome
;				 6  - PS/2-compatible color
;				 7  - PC 3270
;		Note!:	for LCD and Tandy 1000 the returned
;			display type is abstracse.
;
;	The values returned in VIDstruct[0].VideoSubsystem and
;	VIDstruct[0].Display indicate the currently active subsystem.
;
; Source algoriphm printed:
;	Richard Wilton "Programming Guige to PC & PS/2 Video Systems"
; Adapted & fixed bugs by T.V.Shaporev, Computer Center MTO MFTI

		ifdef	__NEAR__
prog		equ	near
quit		equ	ret
ArgOff		equ	4
		else
prog		equ	far
quit		equ	retf
ArgOff		equ	6
		endif

VIDstruct	STRUC			; corresponds to C data structure
Video0Type	db	?		; first subsystem type
Display0Type	db	?		; display attached to first susbsystem
Video1Type	db	?		; second susbsystem type
Display1Type	db	?		; display attached to second subsystem
VIDstruct	ENDS

Device0		EQU	word ptr es:Video0Type[di]
Device1		EQU	word ptr es:Video1Type[di]

MDA		EQU	1		; Subsystem types
CGA		EQU	2
EGA		EQU	3
PGA		EQU	4
MCGA		EQU	5
VGA		EQU	6
PC3270		EQU	7
HGC		EQU	80h
HGCPlus		EQU	81h
InColor		EQU	82h
LCD		EQU	0E0h
Tandy		EQU	0F0h

MDADisplay	EQU	1		; Display types
CGADisplay	EQU	2
EGAColorDisplay	EQU	3
IBMProfessional	EQU	4
PS2MonoDisplay	EQU	5
PS2ColorDisplay EQU	6
PC3270Display	EQU	7

MDASystem	EQU	0101h		; Display + Subsystem codes
CGASystem	EQU	0202h
PC3270System	EQU	0707h
HGCPlusSystem	EQU	0181h
InColorSystem	EQU	0382h
TandySystem	EQU	0F0F0h

DoneFlags	EQU	byte ptr ss:[bp-6]	; !!! depends on reg saving
No_LCD		EQU	000001b
No_Tan		EQU	000010b
No_EGA		EQU	000100b
No3270		EQU	001000b
No_CGA		EQU	010000b
NoMono		EQU	100000b

_TEXT		SEGMENT	byte public 'CODE'
		ASSUME	cs:_TEXT

		PUBLIC	_VideoID
_VideoID	PROC	prog

		push	bp		; preserve caller registers
		mov	bp,sp
		push	es
		push	di

; Initialise the data structures that will contain the results

		les	di,ss:[bp+ArgOff]	; es:di -> result structure
		mov	Device0,0		; zero these variables
		mov	Device1,0

; look for the various susbsystems using various subroutines

		xor	ax,ax		; zero AX
		push	ax		; reserve stack & clear DoneFlags
		call	FindPS2
		test	DoneFlags,No_LCD
		jnz	need_Tandy
		call	FindLCD
need_Tandy:	test	DoneFlags,No_Tan
		jnz	need_EGA
		call	FindTandy
need_EGA:	test	DoneFlags,No_EGA
		jnz	need_3270
		call	FindEGA
need_3270:	test	DoneFlags,No3270
		jnz	need_CGA
		call	Find3270
need_CGA:	test	DoneFlags,No_CGA
		jnz	need_Mono
		call	FindEGA
need_Mono:	test	DoneFlags,NoMono
		jnz	need_nothing
		call	FindMono
need_nothing:	pop	ax		; restore stack
		call	FindActive	; Determine which susbsystem is active
		pop	di		; restore caller registers and return
		pop	es
;		mov	sp,bp
		pop	bp
		quit

_VideoID	ENDP

;	This subroutine uses INT 10h function 1Ah to determine the video BIOS
;	Display Combination Code (DCC) for each video susbsystem present
;
FindPS2		PROC	near

		mov	ax,1A00h
		int	10h		; call video BIOS for info
		cmp	al,1Ah
; Exit if function not supported (i.e. no MCGA or VGA in system)
		jne	L13
; Convert BIOS DCCs into specific subsystems and displays
		mov	cx,bx
		mov	al,bl
		xor	ah,ah		; BX := DCC for active subsystem
		or	ch,ch
		jz	L11		; jump if the only subsystem present
		mov	al,ch		; AX := inactive DCC
		add	ax,ax
		lea	bx,cs:DCCtable
		add	bx,ax
		mov	ax,cs:[bx]
		mov	Device1,ax
		mov	al,cl
		xor	ah,ah		; AX := active DCC
L11:		add	ax,ax
		lea	bx,cs:DCCtable
		add	bx,ax
		mov	ax,cs:[bx]
		mov	Device0,ax
; reset flags for subsystems that have been ruled out
		or	DoneFlags,(No_LCD+No_Tan+No_EGA+No3270+No_CGA+NoMono)

		lea	bx,es:Video0Type[di]	; if the BIOS reporetd an MDA
		cmp	byte ptr es:[bx],MDA
		je	L12
		lea	bx,es:Video1Type[di]
		cmp	byte ptr es:[bx],MDA
		jne	L13
L12:		mov	word ptr es:[bx],0	; Hercules can't be ruled out
		and	DoneFlags,(0FFh-NoMono)
L13:		ret

FindPS2		ENDP

; Look for an LCD. This is done by making a call to an LCD BIOS function
; which doesn't exist in the default (MDA, CGA) BIOS.
;
FindLCD		PROC	near
		xor	ax,ax
		mov	es,ax		; es:di - illegal data pointer
		mov	di,ax
		mov	ah,15h
		int	10h
		mov	bx,es
		or	bx,di
		jz	QuitLCD
LCDhere:	or	DoneFlags,(No_Tan+No_EGA+No3270+No_CGA+NoMono)
		mov	bh,es:[di+3]	; LCD model type
		mov	bl,LCD		; Adapter type
		les	di,ss:[bp+ArgOff]	; restore es:di
		mov	Device0,bx
		cmp	ah,51h		; LCD subcode answer
		jne	AloneLCD
		cmp	al,40h		; LCD alternative?
		jne	LCDandCGA
		mov	al,LCD
		mov	ah,bh
		jmp	short EndLCD
LCDandCGA:	cmp	al,53h		; LCD answer for CGA
		jne	LCDandMDA
		mov	ax,CGASystem
		jmp	short EndLCD
LCDandMDA:	cmp	al,51h		; LCD answer for MDA
		jne	AloneLCD
		mov	ax,MDASystem
		and	DoneFlags,(0FFh-NoMono)
		jmp	short EndLCD
AloneLCD:	xor	ax,ax
EndLCD:		mov	Device1,ax
QuitLCD:	les	di,ss:[bp+ArgOff]	; restore es:di
		ret

FindLCD		ENDP

; Look for an Tandy 1000. This is done by making a call to an Tandy BIOS
; function which doesn't exist in the default (MDA, CGA) BIOS.
;
FindTandy	PROC	near

		sub	bx,bx		; cx:bx - invalid data pointer
		sub	cx,cx
		mov	ah,71h		; Get INCRAM address
		int	10h
		or	bx,cx
		jz	NoTandy
		mov	Device0,TandySystem
		or	DoneFlags,(No_EGA+No3270+No_CGA+NoMono)
NoTandy:	ret

FindTandy	ENDP

; Look for an EGA. This is done by making a call to an EGA BIOS function
; which doesn't e exist in the default (MDA, CGA) BIOS.
;
FindEGA		PROC	near		; Caller:	AH = flags
					; Returns:	AH = flags
					;		Video0Type and
					;		Display0Type updated
		mov	ah,12h		; EGA special function
		mov	bl,10h		; return EGA info
		int	10h
		cmp	bl,10h		; if EGA BIOS present, BL ne 10h
		je	L22		; jump if EGA BIOS absent
		shr	cl,1 		; CL := switches/2
		xor	ch,ch		; clear elder bits
		lea	bx,cs:EGADisplays
		add	bx,cx		; determine display type from switches
		mov	ah,cs:[bx]	; AH := display type
		mov	al,EGA		; AL := subsystem type
		call	FoundDevice
		cmp	ah,MDADisplay
		je	L21		; jump if EGA has a monochrome display
		or	DoneFlags,No3270+No_CGA
		jmp	short L22	; no CGA if EGA has color display
;	since EGA has a monochrome display, MDA and Hercules are ruled out
L21:		or	DoneFlags,NoMono+No3270
L22:		ret

FindEGA		ENDP

; Borland's detection for PC 3270 (what's it?)
Find3270	PROC	near
		xor	cx,cx
		xor	dx,dx
		mov	ax,3006h
		int	10h
		mov	bx,dx
		or	dx,cx
		jz	loc_237
		push	ds
		mov	ds,cx
		mov	al,ds:[bx+2]
		pop	ds
		or	al,al
		jz	loc_236
		cmp	al,2
		jne	loc_237
loc_236:
		mov	dx,188h
		in	al,dx
		test	al,4
		jz	loc_237
;	The following is mine. Is it correct?
		mov	ax,PC3270System
		call	FoundDevice
;		or	DoneFlags,No_CGA+NoMono
loc_237:
		ret
Find3270	ENDP

; This is find for CGA by looking for the CGA's 6845 CRTC at I/O port 3D4h.
;
FindCGA		PROC	near		; Returns:	VIDstruct updated

		mov	dx,3D4h		; DX := CRTC address port
		call	Find6845
		jc	L31		; jump if absent
		mov	ax,CGASystem
		call	FoundDevice
L31:		ret

FindCGA		ENDP

;	This is done by looking for the MDA's 6845 CRTC at I/O port 3B4h. If
;	a 6845 if found, the subroutine distinguishes between an MDA and
;	a Hercules adapter by monitoring bit 7 of the CRT status byte. This
;	bit changes on Hercules adapters and does not change on MDA. The
;	various Hercules adapters are identified by bits 4 through 6 of the
;	CRT status value:
;		001b = HGC+
;		101b = InColor card
;
FindMono	PROC	near		; Returns:	VIDstruct updated

		mov	dx,3B4h		; DX := CRTC address port
		call	Find6845
		jc	L44		; jump if absent
		mov	dl,0BAh		; DX := 3BAh (status port)
		in	al,dx
		and	al,80h
		mov	ah,al		; AH := bit 7 (vertical sync on HGC)
		mov	cx,8000h	; do this 32768 times
L41:		in	al,dx
		and	al,80h		; isolate bit 7
		cmp	ah,al
		loope	L41		; wait for bit 7 to change
		jne	L42		; if bit 7 changed, it's a Hercules
		mov	ax,MDASystem	; if bit 7 didn't change, it's a MDA
		call	FoundDevice
		jmp	short L44
L42:		in	al,dx
		mov	dl,al		; DL := value from status port
		and	dl,70h		; mask off bits 4 thru 6
		mov	ax,HGCPlusSystem; assume it's a monochrome display
		cmp	dl,10h		; look for an HGC+
		je	L43		; jump if it's an HGC+
		mov	al,HGC
		cmp	dl,50h		; look for an HGC
		jne	L43
		mov	ax,InColorSystem
L43:		call	FoundDevice
L44:		ret

FindMono	ENDP

;	The following routine detects the presence of the CRTC on MDA, CGA or
;	HGC. The technique is to write and read register 0Fh of this chip
;	(Cursor Location Low). If the same value is read as written, assume
;	the chip is present at the specified address.
;
Find6845	PROC	near		; Caller:	DX = port addr
					; Returns:	CF set to CY if absent
		mov	al,0Fh
		out	dx,al		; select 6845 reg 0Fh (Cursor Low)
		inc	dx
		in	al,dx		; AL := Cursor Low value
		mov	ah,al		; preserve in AH
		mov	al,66h		; AL := arbitrary value
		out	dx,al		; try to write to 6845
		mov	cx,100h
L51:		loop	L51		; wait for 6845 to respond
		in	al,dx
		xchg	ah,al
		out	dx,al		; restore original value
		cmp	ah,66h		; test whether 6845 respond
		je	L52		; jump if did (CF is reset)
		stc
L52:		ret

Find6845	ENDP

;	The following subroutine stores the currently active device as Device0
;	The current video mode determines which subsystem is active.
;
FindActive	PROC	near

		cmp	word ptr Device1,0
		je	L63			; exit if the only subsystem
		cmp	es:Video0Type[di],4	; exit if MCGA or VGA present
		jge	L63			; (INT 10h function 1Ah
		cmp	es:Video1Type[di],4	; already did the work)
		jge	L63
		mov	ah,0Fh
		int	10h			; AL := current video mode
		and	al,7
		cmp	al,7			; mode 7 or 0Fh
		je	L61			; jump if monochrome
		cmp	es:Display0Type[di],MDADisplay
		jne	L63			; exit if Display0 is color
		jmp	short L62
L61:		cmp	es:Display0Type[di],MDADisplay
		je	L63			; exit if Display0 is mono
L62:		mov	ax,Device0
		xchg	ax,Device1		; make Device0 active
		mov	Device0,ax
L63:		ret

FindActive	ENDP

;	The following routine updates the list of subsystems
;
FoundDevice	PROC	near	; Caller:	AH = display & AL = subsystem
				; Destroys:	BX
		lea	bx,es:Video0Type[di]
		test	byte ptr es:[bx],0FFh
		jz	L71			; jump if 1st subsystem
		lea	bx,es:Video1Type[di]	; must be 2nd subsystem
L71:		mov	es:[bx],ax		; update list entry
		ret

FoundDevice	ENDP

EGADisplays	db	CGADisplay	; 00h 01h (EGA switch values)
		db	EGAColorDisplay	; 02h 03h
		db	MDADisplay	; 04h 05h
		db	CGADisplay	; 06h 07h
		db	EGAColorDisplay ; 08h 09h
		db	MDADisplay	; 0Ah 0Bh

DCCtable	db	0,0		; translate table for INT 10h func 1Ah
		db	MDA,MDADisplay
		db	CGA,CGADisplay
		db	0,0
		db	EGA,EGAColorDisplay
		db	EGA,MDADisplay
		db	PGA,IBMProfessional
		db	VGA,PS2MonoDisplay
		db	VGA,PS2ColorDisplay
		db	0,0
		db	MCGA,EGAColorDisplay
		db	MCGA,PS2MonoDisplay
		db	MCGA,PS2ColorDisplay

_TEXT		ENDS

		END
