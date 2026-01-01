	Ideal
	Locals	@@
	Model	Tiny
	CodeSeg
	Org	100h
	Locals	@@

	P486


Proc	SInfo
	Mov	si,OffSet msBegin
	Call	PutStr
;
;	Display processor type
;
	Mov	si,OffSet msIntel
	Call	PutStr
	Call	Intel
;
;	Base memory size
;
	Push	ax				; PUSH AX
	Mov	si,OffSet msBaseMem
	Call	PutStr

;	Push	ds
;	Xor	ax,ax
;	Mov	ds,ax
;	Mov	ax,[Word ds: 413h]		; Was: 467h
;	Pop	ds

	Mov	al,16h
	Call	GetCMOS
	Mov	ah,al
	Mov	al,15h
	Call	GetCMOS

	Call	PutDNum
	Call	PutKb
;
;	Coprocessor info
;
	Mov	si,OffSet msCoProc
	Call	PutStr
	Pop	ax				; POP  AX
	Call	CoProc
;
;	Extended memory size
;
	Mov	si,OffSet msExtMem
	Call	PutStr

;	Mov	ah,88h
;	Int	15h

	Mov	al,18h
	Call	GetCMOS
	Mov	ah,al
	Mov	al,17h
	Call	GetCMOS

	Call	PutDNum
	Call	PutKb
;
;	Floppy Drive A:
;
	Mov	si,OffSet msDrvA
	Call	PutStr
	Mov	al,90h
	Call	GetCMOS
	Push	ax				; PUSH AX
	Shr	al,4
	Call	Floppy
;
;	Hard Drive C:
;
	Mov	si,OffSet msDrvC
	Call	PutStr
	Mov	al,92h
	Call	GetCMOS
	Push	ax				; PUSH AX
	Shr	al,4
	Mov	ah,99h
	Call	Hard
	Call	EndLn
;
;	Floppy Drive B:
;
	Mov	si,OffSet msDrvB
	Call	PutStr
	Pop	cx				; POP  CX
	Pop	ax				; POP  AX
	Push	cx				; PUSH CX
	Call	Floppy
;
;	Hard Drive D:
;
	Mov	si,OffSet msDrvD
	Call	PutStr
	Pop	ax				; POP  AX
	Mov	ah,9Ah
	Call	Hard
	Call	EndLn
;
;	Video Adapter type
;
	Mov	si,OffSet msDisplay
	Call	PutStr
	Mov	si,OffSet msVGA
	Push	ds
	Xor	ax,ax
	Mov	ds,ax
	Mov	ax,[Word ds: 10h*4+2]		;  Segment of Int10h
	Pop	ds
	Cmp	ax,0C800h
	Jb	@@2
	Cmp	ax,0E000h
	Jb	@@1
	Cmp	ax,0F000h
	Jb	@@2
@@1:
	Int	11h			; Put equipment bits in ax
	Mov	si,OffSet msMono
	And	al,30h
	Cmp	al,30h
	Je	@@2
	Mov	si,OffSet ms80x25
	Cmp	al,20h
	Je	@@2
	Mov	si,OffSet ms40x25
@@2:
	Call	PutStr
;
;	Serial I/O ports
;
	Mov	si,OffSet msSerial
	Call	PutStr
	Mov	cx,4
	Mov	si,400h
	Call	Ports
	Call	EndLn
;
;	Display ROM BIOS date - F000:FFF5
;
	Mov	si,OffSet msDate
	Call	PutStr

	Mov	cx,8
	Push	ds
	Mov	ax,0F000h
	Mov	ds,ax
	Mov	si,0FFF5h
@@3:
	LodSb
	Mov	ah,0Eh
	Int	10h
	Loop	@@3
	Pop	ds

	Mov	cx,7
@@4:
	Call	Space
	Loop	@@4
;
;	Parallel I/O ports
;
	Mov	si,OffSet msParallel
	Call	PutStr
	Mov	cx,3
	Mov	si,408h
	Call	Ports
	Call	EndLn

	Mov	si,OffSet msEnd
	Call	PutStr

	Call	Cache
	Ret
EndP


msCh0	Db	'512', 0
msCh1	Db	'64', 0
msCh2	Db	'128', 0
msCh3	Db	'256', 0

cTab	Dw	OffSet msCh0
	Dw	OffSet msCh1
	Dw	OffSet msCh2
	Dw	OffSet msCh3

msCache	Db	' Kb Cache', 13,10, 0

Proc	Cache
;
;	Method #1:
;
	Mov	al,9
	Out	22h,al
	Jmp	@@1
@@1:	Jmp	@@2
@@2:	In	al,23h

	Cmp	al,0FFh
	Je	@@m2

	Test	al,4
	Jz	@@NoCache

	And	ax,3
	Shl	ax,1
	Mov	si,ax
	Mov	si,[cTab+si]
	Call	PutStr
@@3:
	Mov	si,OffSet msCache
	Call	PutStr

@@NoCache:
	Ret

@@m2:
;	Method #2
;
	Mov	al,21h
	Out	22h,al
	Jmp	@@4
@@4:	Jmp	@@5
@@5:	In	al,24h

	Cmp	al,0FFh
	Je	@@NoCache

	Test	al,10h
	Jz	@@NoCache

	Shr	ax,1
	Shr	ax,1
	And	ax,3
	Mov	cl,al
	Mov	ax,64
	Shl	ax,cl
	Call	PutDNum

	Jmp	@@3

EndP


Proc	Space
	Mov	ah,0Eh
	Mov	al,' '
	Int	10h
	Ret
EndP

Proc	Back
	Mov	ah,0Eh
	Mov	al,8
	Int	10h
	Ret
EndP


Proc	GetCMOS
	Out	70h,al
	Jmp	@@1
@@1:	Jmp	@@2
@@2:	In	al,71h
	Ret
EndP


Proc	PutStr
	Push	ax
@@1:
	LodSb
	Or	al,al
	Jz	@@Ret
	Mov	ah,0Eh
	Int	10h
	Jmp	@@1
@@Ret:
	Pop	ax
	Ret
EndP


Proc	PutHByte
	Push	ax
	Shr	al,4
	Call	PutHDig
	Pop	ax

PutHDig:
	And	al,0Fh
	Cmp	al,0Ah
	Jb	@@1
	Add	al,'A'-'0'-10
@@1:
	Add	al,'0'
	Mov	ah,0Eh
	Int	10h

	Ret
EndP


Proc	Ports
	Push	ds
	Xor	ax,ax
	Mov	ds,ax
@@1:
	LodSw
	Or	ax,ax
	Jz	@@2

	Push	ax
	Mov	al,ah
	Call	PutHDig
	Pop	ax
	Call	PutHByte

	Mov	ah,0Eh
	Mov	al,','
	Int	10h

	Mov	ch,'X'
@@2:
	Dec	cl
	Jnz	@@1
	Pop	ds
	Or	ch,ch
	Jnz	@@3
	Mov	si,OffSet msNo
	Call	PutStr
	Ret
@@3:
	Call	Back
	Ret
EndP


Proc	Hard
	Mov	si,OffSet msNo
	And	al,0Fh
	Jz	@@2
	Cmp	al,0Fh
	Jne	@@1
	Mov	al,ah
	Call	GetCMOS
@@1:	Xor	ah,ah
	Call	PutDNum
	Ret
@@2:
	Call	PutStr
	Ret
EndP


Proc	Floppy
	Mov	si,OffSet msNo
	Test	al,7
	Jz	@@1
	Mov	si,OffSet ms1440
	Test	al,3
	Jz	@@1
	Mov	si,OffSet ms1200
	Test	al,1
	Jz	@@1
	Mov	si,OffSet ms360
	Test	al,2
	Jz	@@1
	Mov	si,OffSet ms720
@@1:
	Call	PutStr
	Ret
EndP


Proc	EndLn
	Push	bx cx dx

	Mov	ah,3
	Mov	bh,0
	Int	10h			; Video display   ah=functn 03h
					;  get cursor Loc in dx, mode cx
	Xor	dh,dh
	Mov	cx,76
	Sub	cx,dx
	Jbe	@@2
@@1:
	Call	Space
	Loop	@@1

@@2:
	Mov	ah,0Eh
	Mov	al,'║'
	Int	10h
	Pop	dx cx bx

	Mov	ah,0Eh
	Mov	al,13
	Int	10h

	Mov	ah,0Eh
	Mov	al,10
	Int	10h

	Ret
EndP


Proc	PutKb
	Call	Space

	Mov	ah,0Eh
	Mov	al,'K'
	Int	10h

	Mov	ah,0Eh
	Mov	al,'b'
	Int	10h

	Call	EndLn

	Ret
EndP


Proc	PutDNum
	Mov	cx,10

PutDDig:
	Xor	dx,dx
	Div	cx
	Or	ax,ax
	Jz	@@1
	Push	dx
	Call	PutDDig
	Pop	dx
@@1:
	Mov	ax,dx
	Mov	ah,0Eh
	Add	al,'0'
	Int	10h

	Ret
EndP


Proc	Intel
	PushF
	Cli
	Mov	ax,0F000h
	Push	ax
	PopF
	PushF
	Pop	ax
	And	ah,0F0h
	Mov	si,OffSet ms286
	Jz	Loc_3B5F
	Smsw	ax
	Or	ah,ah
	Jz	Loc_3B45
	Mov	eax,cr0
	Push	eax
	And	al,0EFh
	Mov	cr0,eax
	Mov	eax,cr0
	Test	al,10h
	Pop	eax
	Mov	cr0,eax
	Mov	si,OffSet ms386dx
	Jz	Loc_3B5D
	Mov	si,OffSet ms386sx
	Jmp	Loc_3B5D
Loc_3B45:
	Int	11h			; Put equipment bits in ax
	Test	al,2
	Mov	si,OffSet ms486dx
	Jnz	Loc_3B5D

;		Mov	al,byte ptr cs:[0C0C7h]
;		Call	Sub_878A

	Call	Intel1

	Mov	si,OffSet ms486
	Jz	Loc_3B5D
	Mov	si,OffSet ms486sx
Loc_3B5D:
	Mov	ah,0FFh
Loc_3B5F:
	Call	PutStr
	PopF
	Ret
EndP

Proc	Intel1

	Mov	al,8Eh
	Call	GetCMOS
	Test	al,0C0h
	Jnz	@@1

	Mov	al,0B5h
	Call	GetCMOS
	Jmp	@@2
@@1:
	Mov	al,1
@@2:
	Mov	bl,1
	Mov	bh,8
	Mov	ah,0
@@3:
	Rol	bl,1
	Jnc	@@4

	Rol	ax,1
	Jmp	@@5
@@4:
	Rol	al,1
@@5:
	Dec	bh
	Jnz	@@3

	Or	ah,ah

	Ret
EndP


Proc	CoProc
	PushF
	Push	ax
	Int	11h			; Put equipment bits in ax
	Test	al,2
	Mov	si,OffSet msNo
	Jz	@@3
	Mov	si,OffSet msPresent
	Call	PutStr
	Pop	ax
	Call	Weitek
	Jnc	@@4
	Mov	cx,8
@@1:
	Call	Back
	Loop	@@1

	Mov	ah,0Eh
	Mov	al,','
	Int	10h

	Call	PutStr
	Mov	cx,8
@@2:
	Call	Back
	Loop	@@2

	Jmp	@@4
@@3:
	Pop	ax
	Call	Weitek
	Call	PutStr
@@4:
	PopF
	Ret
EndP

Proc	Weitek
	Or	ah,ah
	Jz	@@Ret
	Xor	eax,eax
	Int	11h			; Put equipment bits in ax
	Shl	eax,8
	Jnc	@@Ret
	Mov	si,OffSet msWeitek

@@Ret:
	Ret
EndP


msBegin	Db	'╔═══════════════════════════════════════════════════════════════════════════╗', 13,10
	Db	'║   AMIBIOS System Configuration (C) 1985-1991, American Megatrends Inc.,   ║', 13,10
	Db	'╠═════════════════════════════════════╤═════════════════════════════════════╣', 13,10, 0

msIntel		Db	'║ Main Processor     : ', 0
msCoProc	Db	'║ Numeric Processor  : ', 0
msDrvA		Db	'║ Floppy Drive A:    : ', 0
msDrvB		Db	'║ Floppy Drive B:    : ', 0
msDisplay	Db	'║ Display Type       : ', 0
msDate		Db	'║ ROM BIOS Date      : ', 0

msBaseMem	Db	'│ Base Memory Size   : ', 0
msExtMem	Db	'│ Ext. Memory Size   : ', 0
msDrvC		Db	'│ Hard Disk C: Type  : ', 0
msDrvD		Db	'│ Hard Disk D: Type  : ', 0
msSerial	Db	'│ Serial Port(s)     : ', 0
msParallel	Db	'│ Parallel Port(s)   : ', 0

ms486		Db	'80486          ', 0
ms486dx		Db	'486DX or 487SX ', 0
ms486sx		Db	'80486SX        ', 0
ms386dx		Db	'80386DX        ', 0
ms386sx		Db	'80386SX        ', 0
ms286		Db	'80286          ', 0

msPresent	Db	'Present        ', 0
msWeitek	Db	'Weitek         ', 0
ms360		Db	'360 Kb, 5м"    ', 0
ms1200		Db	'1.2 Mb, 5м"    ', 0
ms720		Db	'720 Kb, 3л"    ', 0
ms1440		Db	'1.44 Mb, 3л"   ', 0
msNo		Db	'None           ', 0
msMono		Db	'Monochrome     ', 0
ms80x25		Db	'Color 80x25    ', 0
ms40x25		Db	'Color 40x25    ', 0
msVGA		Db	'VGA/PGA/EGA    ', 0
msNone		Db	'NONE    ', 0

msEnd	Db	'╚═════════════════════════════════════╧═════════════════════════════════════╝', 13,10, 0

End	SInfo
