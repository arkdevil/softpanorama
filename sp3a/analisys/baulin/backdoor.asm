	TITLE - BACKDOOR.SYS - closes DOS's backdoors
	PAGE   60, 132
	.RADIX 16

; BACKDOOR.SYS closes two "backdoors" into the MS-DOS INT 21h function
; dispatcher that could be used by a virus or trojan horse to cause
; damage. It also filters INT 21h directly to reject a special case of
; function 13h which could destroy all data on a disk.
; For use with MASM 5.1
; MASM BACKDOOR
; LINK BACKDOOR
; EXE2BIN BACKDOOR.EXE BACKDOOR.SYS
;
;	Typewritten by Aleksey A.Baulin (PEGASUS Software), Yaroslavl city,
;		July 1991.
;	Excuse me possible misprints.

	assume	cs:cseg, ds:cseg
cseg	segment	para public 'code'
	
	org	0000h			; Device driver starts at 0

	dw	0FFFFh, 0FFFFh		; Far pointer to next device
	dw	8000h			; Character device driver
	dw	offset DevStratRout	; Pointer to the strategy routine
	dw	offset DevIntRout	; Pointer to the interrupt routine
	db	"B"+80h,"ACKDOOR"	; Device name with high bit set
					; will avoid any filename conflicts
InstallMsg	db	0Dh, 0Ah
		db	"BACKDOOR is installed at $"

DevHdrBX	dw	0000		; Pointer for ES:BX for device
DevHdrES	dw	0000            ; request header

OrigInt21Off	dw	0000
OrigInt21Seg	dw	0000

Temp		dw	0000		; Used for temporary starage

RefuseRequest	proc	far
		pop	ax		; Get rid of flags on stack
		pop	ax		; Get the return segment
		pop	cs:Temp		;    and save offset
		push	ax		; Save the return address in
		push	cs:Temp		;    order.
		stc			; Return STC for error
		mov	ax, 0FFFFh	; Return ax=-1
		ret			;    and do FAR RET back to caller
RefuseRequest	endp

NewInt21	proc	near
		push	ax		; Save original registers first
		push	bx		;    thing.
		cmp	ah, 13h		; Is this the DELETE FCB function?
		jnz	ContOrigInt21	; No, so continue on
		mov	bx, dx		; Point BX to the FCB
		cmp	byte ptr ds:[bx], 0FFh	   ; Got an extended FCB?
		jnz	ContOrigInt21	           ; No, so continue on
		cmp	byte ptr ds:[bx+6], 1Fh    ; Yes, so got the special attribute?
		jnz	ContOrigInt21	           ; No, so continue on
		cmp	word ptr ds:[bx+8], "??"   ; Yes, so filename starts with "??"?
		jnz	ContOrigInt21	           ; No, so continue on
		cmp	word ptr ds:[bx+0Ah], "??" ; Yes, so filename = "??"?
		jnz	ContOrigInt21	           ; No, so continue on
		cmp	word ptr ds:[bx+0Ch], "??" ; Yes, so filename = "??"?
		jnz	ContOrigInt21	           ; No, so continue on
		cmp	word ptr ds:[bx+0Eh], "??" ; Yes, so filename = "??"?
		jnz	ContOrigInt21	           ; No, so continue on
		cmp	word ptr ds:[bx+10h], "??" ; Yes, so filename = "??"?
		jnz	ContOrigInt21	           ; No, so continue on
		cmp	byte ptr ds:[bx+12h], "?"  ; Yes, so filename = "??"?
		jnz	ContOrigInt21
		pop	bx		; Yes, so reject it altogether
		pop	ax
		mov	al, 0FFh	; Return match not found
		stc			; STC just for the heck of it
		retf	0002		; And IRET with new flags

ContOrigInt21:
		pop	bx		; Restore original registers
		pop	ax
		jmp	dword ptr cs:OrigInt21Off  ; Continue with original  
NewInt21	endp				   ;    handler

DevStratRout	proc	far
		mov	cs:DevHdrBX, BX	; Save the ES:BX pointer to the
		mov	cs:DevHdrES, es ;    device request header
		ret
DevStratRout	endp

DevIntRout	proc	far
		push	ax		; Save all registers
		push	bx
		push	cx
		push	dx
		push	ds
		push	es
		push	di
		push	si
		push	bp
		push	cs
		pop	ds		; Point DS to local code
		les	di, dword ptr DevHdrBx	; ES:DI=device request header
		mov	bl, es:[di+02]	; Get the command code
		xor	bh, bh		; Clear out high byte
		cmp	bx, 00h		; Doing an INSTALL?
		jnz	DevIgnore	; No, so just ignore the call then
		call	InstallBackdoor ; Yes, so install code in memory
DevIgnore:
		mov	ax, 0100h	; return STATUS of DONE
		lds	bx, dword ptr cs:DevHdrBX ; DS:BX=device request header
		mov	[bx+03], ax	; Return STATUS in the header
		pop	bp		; Restore original registers
		pop	si
		pop	di
		pop	es
		pop	ds
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		ret			; and RETF to DOS
DevIntRout	endp

InstallBackdoor proc	near
		call	CloseBackDoor	; Install new handler to close backdoor
		call	HookInt21	; Hook INT 21 filter
		mov	ah, 09h		; DOS display string
		mov	dx, offset InstallMsg	; Show installation message
		int	21h			;    via DOS
		mov	ax, cs		; Display current code segment
		call	OutputAXasHEX	; Output AX as two HEX digits
		mov	al, 3Ah		; Now output a colon
		call	DisplayTTY	;    to the screen
		mov	ax, offset RefuseRequest ; Show new handler's offset
		call	OutputAXasHEX	; Output AX as two HEX digits
		call	DisplayNewLine	; Output a newline to finish display
		les	di, dword ptr DevHdrBX ; ES:DI=device request header
				; This is the end of resident code
		mov	word ptr es:[di+0Eh], offset InstallBackdoor  ; This is
		mov	es:[di+10h], cs	; the end of resident code.
		ret
InstallBackdoor endp

CloseBackdoor	proc	near
		push	es		; Save original registers
		push	ax
		push	bx
		xor	ax, ax		; Point ES to the interrupt
		mov	es, ax          ;    vector table
		mov	bx, 00C1h       ; Install new handlet at INT 30h + 1
		mov	ax, offset RefuseRequest ; Get new offset for the
						 ;    handler
		mov	es:[bx], ax	; Save it in interrupt vector table
		mov	ax, cs		; Get the segment for the handler
		mov	es:[bx+02], ax	;    and save it, too
		pop	bx		; Restore original registers
		pop	ax
		pop	es
		ret			; and RET to caller
CloseBackdoor	endp

HookInt21	proc	near
		push	ax
		push	bx
		push	es
		mov	ax, 3521h	; Get current INT 21h vector
		int	21h		;    via DOS
		mov	cs:OrigInt21Off, bx	; Save the offset
		mov	bx, es
		mov	cs:OrigInt21Seg, bx	; and the segment
		push	cs
		pop	ds			; Make sure DS = local code
		mov	dx, offset NewInt21	; Point to new handler
		mov	ax, 2521h		; Install new handler
		int	21h			;    via DOS
		pop	es		; Restore original registers
		pop	bx
		pop	ax
		ret			; and RET to caller
HookInt21	endp

OutputAXasHEX	proc	near
		push	ax              ; Save original registers
		push	bx
		push	cx
		push	ax              ; Save number for output
		mov	al, ah		; Output high byte first
		call	OutputALasHEX	; Output AL as two HEX digits
		pop	ax		; Output low byte next
		call	OutputALasHEX	; Output AL as two HEX digits
		pop	cx
		pop	bx
		pop	ax
		ret
OutputAXasHEX	endp

OutputALasHEX	proc	near
		push	ax              ; Save original registers
		push	bx
		push	cx

		push	ax		; Save the number for output (in AL)
		mov	cl, 04h		; First output high nibble
		shr	al, cl		; Get digit into low nibble
		add	al, 30h		; Convert to ACSII
		cmp	al, 39h         ; Got a decimal digit?
		jbe	OutputFirstDigit; Yes, so continue
		add	al, 07h		; No, so convert to HEX ASCII

OutputFirstDigit:
		call	DisplayTTY	; Output it via BIOS
		pop	ax	    	; Get number back
		and	al, 0Fh		; Keep only low digit now
		add	al, 30h		; Convert to ASCII
		cmp	al, 39h		; Got a decimal digit?
		jbe	OutputSecondDigit ; Yes, so continue
		add	al, 07h         ;  No, so convert to HEX ASCII

OutputSecondDigit:
		call	DisplayTTY	; Output it via BIOS
		pop	cx		; Restore original registers
		pop	bx
		pop	ax
		ret			; and RET to caller
OutputALasHEX	endp

DisplayNewLine	proc	near
		push	ax		; Save original AX
		mov	al, 0Dh		; first do CR
		call	DisplayTTY	; Output it via the BIOS
		mov	al, 0Ah		; Do LF next
		call	DisplayTTY	; Output it via the BIOS
		pop	ax		; Restore original AX
		ret			;    and RET to caller
DisplayNewLine	endp

DisplayTTY	proc	near
		push	ax
		push	bx
		mov	ah, 0Eh		; Display TTY
		mov	bx, 0007h	;    on page 0, normal attribute
		int	10h		;    via BIOS
		pop	bx
		pop	ax
		ret
DisplayTTY	endp

cseg		ends
		end
