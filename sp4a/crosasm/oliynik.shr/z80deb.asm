	.title Zilog Z-80 DEBUGGER
/
/ Tiny debugger for the Zilog Z-80
/ microprocessor. This version uses the
/ memory and port assignments of the
/ code reader hardware.
/
/	DECUS 'Structured Languages Special Interest Group'
/ Author:
/	???
/
	.hlist

CR	=	015		/ ASCII return
LF	=	012		/ ASCII newline
SP	=	040		/ ASCII space
RST1	=	0317		/ For patching
OP	=	0		/ Break table `struct'
LOW	=	1		/
HIGH	=	2		/
NBTAB	=	10		/ Number of breakpoints
RESET	=	0		/ RST 0 is RESET
BPT	=	1		/ RST 1 is break trap
PUTC	=	2		/ RST 2 is put character

/
/ Port definitions.
/

STATUS	=	0		/ Input 0 is status port.
TBMT	=	0		/ Transmit buffer empty
RDA	=	1		/ Receive data available
TDATA	=	4		/ Transmit data is output 4
RDATA	=	2		/ Receive data is input 2

/
/ State bits. Kept in `c'
/

OPEN	=	0		/ Location currently open
BYTE	=	1		/ Open location is a byte
DE	=	2		/ An address has been typed (into `de')
SPEC	=	4		/ Address is a special register
LB	=	5		/ Address is a legal byte
LW	=	6		/ Address is a legal word

BOPEN	=	01		/ Bit masks
BBYTE	=	02		/ for the
BDE	=	04		/ above
BSPEC	=	020		/ to be
BLB	=	040		/ used by
BLW	=	0100		/ ands and ors.
	.page
/
/ Restart handlers.
/
rst0:
	mov $iysave,sp		/ Set up a stack
	mov $btab,hl		/ Set up to clear `btab'
	br	rst0a		/
.if 0
rst1:
	mov hl,nlsave		/ Save the `hl'
	pop hl			/ Pick up user's `pc'
	br	rst1a		/ Go to rest of handler.
	nop			/ Pad
	nop			/
.else
	.ascii	"DUMMY"
.endif

rst2:
	push	af		/ Save character
0:	in	STATUS,a	/ Read status port
	rrc a			/ Wait for TBMT
	bcs 0b			/
	br	rst2a		/ Br to rest.

rst3:	.blkb	8	/ Unused
rst4:	.blkb	8	/
rst5:	.blkb	8	/
rst6:	.blkb	8	/
rst7:	.blkb	8	/

/
/ NMI trap.
/

.	=	0x66

nmi:
	mov hl,nlsave		/ Save the `hl'
	pop hl			/ Get `pc' and
	br	rst1a		/ Jump into breakpoint code

/
/ Restart continuations.
/

rst0a:
	mov $3*NBTAB*256,bc	/ Count to `b', 0 to `c'
0:	mov c,(hl)		/ Clear
	inc hl			/ breakpoint
	sob b,0b		/ table.
	mov sp,spsave		/ Give him a default stack.
	mov $imsg,hl		/ Hello msg. to `hl'
	br  cmdmsg		/ Go print.

rst2a:
	pop af			/ Restore character
	out a,TDATA		/ Send to UAR/T
	ret			/ Done

/
/ This is the rest of the breakpoint code.
/ Pull out the breakpoints and set the pseudo
/ `pc' correctly.
/

rst1a:
	mov hl,pcsave		/ Save user `pc'
	call	save		/ Save regs
	mov $btab,ix		/ Point at breakpoint table
	mov pcsave,de		/ Copy `pc'
	dec de			/ Point at the restart
	mov $NBTAB*256,bc	/ Count to `b', 0 to `c'

1:	mov HIGH(ix),a		/ Get high loc.
	or	a,a		/ Null slot if zero.
	beq 0f			/
	mov a,h			/ Move to `hl'
	mov LOW(ix),l		/
	mov OP(ix),a		/ Replace byte.
	mov a,(hl)		/

	mov h,a			/ Compare high half to `pc'
	cmp a,d			/
	bne 0f			/ Nope
	mov l,a			/ Compare low half to `pc'
	cmp a,e			/
	bne 0f			/ Nope
	inc c			/ Set flag on hit !

0:	call	incix3		/ Advance to next
	sob b,1b		/ Do them all

	mov $rmsg,hl		/ Default to `rst 1 at'
	dec c			/ Correct ?
	bne 0f			/ Yes.
	mov de,pcsave		/ Back up `pc'
	mov $bmsg,hl		/ Get correct msg

0:	call	puts		/ Say it
	ex	de,hl		/ Say the address
	call	putw		/
	call	crlf		/ Say newline and
	br	cmd		/ Go to command loop.
	.page
/
/ Command loop.
/ This code just runs around reading commands
/ from the user and executing them. On any
/ kind of error a jump is made to the error
/ processing logic at `cmderr', which prints
/ a question mark and returns to the loop.
/

cmderr:
	mov $iysave,sp		/ Reset `sp'
	mov $emsg,hl		/ Make a snarly sound in
cmdmsg:
	call	puts		/ the user's direction

cmd:
	mov $0,c		/ Clear all flags
cmd10:
	call	getc		/ Get a character.
cmd20:
	cmp a,$SP		/ Ignore spaces
	beq cmd10

/
/ Octal address
/
	cmp a,$'0		/ Address
	bcs cmd30
	cmp a,$'8
	bcc cmd30

	mov $0,hl		/ Read address to de

1:	add hl,hl		/ hl= 8*hl
	add hl,hl
	add hl,hl
	sub $'0,a
	add l,a
	mov a,l
	bcc 0f
	inc h

0:	call	getc
	cmp a,$'0
	bcs 0f
	cmp a,$'8
	bcs 1b

0:	ex	de,hl		/ Copy address to `de'
	push	af		/ Save delimiter
	mov c,a			/ Get flags
	and $!BSPEC,a		/ Turn off special flags
	or	$BDE+BLB+BLW,a	/ All legal
	mov a,c			/ Put the flags back
	pop af			/ Restore delimiter
	br	cmd20		/ Again

/
/ Special names.
/

cmd30:
	cmp a,$'$		/ Special name flag ?
	bne cmd40		/ Nope.
	call	getc		/ Get register name.

	mov $sntab,hl		/ Set up search the
	mov $NSNTAB,b		/ special name tables.

0:	cmp a,(hl)		/ Well ?
	inc hl			/
	beq 0f			/ Found it.
	inc hl			/ Skip info. byte
	sob b,0b		/ Loop if not all done.
	br	cmderr		/ Unknown name

0:	mov (hl),b		/ Grab info. byte

	mov $iysave,de		/ Point at saved regs
	call	getc		/ Grab next.
	cmp a,$''		/ Alternate regs ?
	bne 0f			/ Nope
	bit Q,b			/ Alternate allowed ?
	beq cmderr		/ Nope
	mov $iysave-8,de	/ Get new reg. base
	call	getc		/ Next char.

0:	push	af		/ Save the opcode.
	mov b,a			/ Move the
	and $BD,a		/ displacement
	mov a,l			/ to
	mov $0,h		/ the `hl'
	add de,hl		/ then compute the
	ex	de,hl		/ address

	mov c,a			/ Grab state
	and $![BLB+BLW],a	/ Clear legal address flags
	or	$BDE+BSPEC,a	/ Have address and special

	bit B,b			/ Legal byte
	beq 0f			/ Nope
	or	$BLB,a		/ Yes, add flag

0:	bit W,b			/ Legal word
	beq 0f			/ Nope
	or	$BLW,a		/ Yes, add flag

0:	mov a,c			/ Restore flags
	pop af			/ Get the delimiter back and
	br	cmd20		/ continue

/
/ Decode command.
/

cmd40:
	mov $cmtab,hl		/ Set up to search the
	mov $NCMTAB,b		/ command table

0:	cmp a,(hl)		/ Well ?
	inc hl			/
	beq 0f			/ Yes, go do it
	inc hl			/ Skip over
	inc hl			/ the address and
	sob b,0b		/ loop back if more
9:	jmp cmderr		/

0:	mov (hl),b		/ Get the address
	inc hl			/
	mov (hl),h		/
	mov b,l			/
	jmp (hl)		/ Go for it !!!!
	.page
/
/ `/' - Open word.
/

slash:
	bit DE,c		/ Address typed ?
	beq 0f			/ No.

	bit LW,c		/ Yes, is it usable ?
	beq 9b			/ No.
	bit SPEC,c		/ Special name ?
	beq 0f			/ Nope
	dec de			/ Yes, adjust address.

0:	mov de,dot		/ Reset `.'

slash1:
	mov $BOPEN,c		/ Flag open and word
	mov dot,hl		/ Get address
	mov (hl),a
	inc hl
	mov (hl),h
	mov a,l
	call	putw
	br	0f

/
/ `\' - open byte.
/

bslsh:
	bit DE,c		/ Address typed ?
	beq bslsh1		/ Nope

	bit LB,c		/ Is the address usable ?
	beq 9f			/ No

	mov de,dot		/ Fix `.'

bslsh1:
	mov $BOPEN+BBYTE,c	/ Fix flags
	mov dot,hl		/ Get the byte.
	mov (hl),a		/
	call	putb		/ Print it

0:	mov $SP,a		/ Print space
	rst PUTC		/ and
	jmp cmd10		/ go back for more.
	.page
/
/ <CR> - Close current location.
/ <LF> - Close current location, open next.
/	^	- Close current location, open previous.
/

close:
	bit DE,c		/ Was a number typed ?
	beq 1f			/ Nope.
	bit OPEN,c		/ Is a cell open ?
	beq 9f			/ No.

	mov dot,hl		/ Pick up current address.
	mov e,(hl)		/ Patch !
	bit BYTE,c		/ Is this a byte open ?
	bne 1f			/ Yes, all done.
	inc hl			/ No, fix the address and
	mov d,(hl)		/ patch the high byte.

1:	call	crlf		/ Send CR-LF
	cmp a,$CR		/ If the command was a CR then
	jeq cmd			/ go clear flags.

	bit OPEN,c		/ There must be an open cell
	beq 9f			/ or it's an error.

	mov dot,hl		/ Get current cell.
	cmp a,$LF		/ Next ?
	bne 0f			/ Nope, must be previous.
	inc hl			/ Move to next byte.
	bit BYTE,c		/ Done ?
	bne 1f			/ Yes.
	inc hl			/ Advance to next word.
	br	1f		/

0:	dec hl			/ Move to prev. byte
	bit BYTE,c		/ Done ?
	bne 1f			/ Yes.
	dec hl			/ Previous word.

1:	mov hl,dot		/ Reset current location.
	call	puta		/ Print address

	bit BYTE,c		/ Byte open ?
	bne 0f			/ Yes.
	mov $'/,a		/ No type out slash
	rst PUTC		/
	jmp slash1		/ Go open word.

0:	mov $'\,a		/ Type out backslash
	rst PUTC		/
	jmp bslsh1		/ Go open byte.
	.page
/
/ `b' - Set a breakpoint
/

bcom:
	bit DE,c		/ Must have an address
	beq 9f			/

	call	ccom1		/ Rip out existing breakpoint

	mov $btab+HIGH,hl	/ Set up to search the
	mov $NBTAB,b		/ break table

1:	mov (hl),a		/ Is this a free slot ?
	or	a,a		/
	bne 0f			/ No
	mov d,(hl)		/ Save loc. high
	dec hl			/
	mov e,(hl)		/ Save loc. low
	br	7f		/ Done

0:	inc hl			/ Move to next
	inc hl			/
	inc hl			/
	sob b,1b		/ Do them all

9:	jmp cmderr		/ Gak
	.page
/
/ `c' - Clear a breakpoint
/

ccom:
	bit DE,c		/ Must have address
	beq 9b			/
	call	ccom1		/ Rip breakpoint
7:	bic DE,c		/ No address
	call	crlf		/
8:	jmp cmd10		/ Done

ccom1:
	mov $btab,ix		/ Set up to search table
	mov $NBTAB,b		/

1:	mov HIGH(ix),a		/ Is this slot empty ?
	or	a,a		/
	beq 0f			/ Yes
	cmp a,d			/ High half match ?
	bne 0f			/ Nope
	mov LOW(ix),a		/ Low half match ?
	cmp a,e			/
	bne 0f			/ Nope
	xor a,a			/ Clear the slot
	mov a,HIGH(ix)		/

0:	call	incix3		/ Do them all
	sob b,1b		/
	ret			/ Finis
	.page
/
/ `g' - Go.
/

go: bit DE,c			/ Do we have an address ?
	beq 0f			/ No
	mov de,pcsave		/ Reset the user `pc'

0:	call	crlf		/ Newline

/
/ Instruction step.
/

	mov pcsave,hl		/ Pick up user `pc'
	mov (hl),a		/ and op.
	inc hl			/ Anticipate prefix.

	cmp a,$0xCB		/ Bit op prefix ?
	bne 1f			/ No
	mov $2,c		/ All are two byte, ordinary
	jmp 3f			/

1:	cmp a,$0xED		/ Misc. prefix ?
	bne 1f			/ No
	mov (hl),a		/ Get next opcode byte

	mov $xret,hl		/ Get ready for a `ret'
	cmp a,$0x4D		/ `reti'
	bne 0f			/ No
	push	hl		/ Execute a `reti' and go
	reti			/ off to simulator.

0:	cmp a,$0x45		/ `retn' ?
	bne 0f			/ No
	push	hl		/ Execute a `retn' and
	retn			/ go simulate.

0:	mov $2,c		/ Default 2 byte, ord.
	and $0xC7,a		/ Well ?
	cmp a,$0x43		/
	bne 3f			/ Yes
	mov $4,c		/ Must be 4 byte, ord.
	br	3f		/

1:	cmp a,$0xDD		/ `ix' prefix ?
	beq 0f			/ Yes
	cmp a,$0xFD		/ `iy' prefix ?
	bne 2f			/ No

0:	mov a,b			/ Save the prefix byte
	mov (hl),a		/ Get opcode
	cmp a,$0xE9		/ `jmp (ix)' or `jmp (iy)'
	bne 1f			/ No
	mov ixsave,hl		/ Assume `ix'
	bit 5,b			/ Well ?
	beq 0f			/ Yes
	mov iysave,hl		/ Must be `iy'
0:	jmp xnewpc		/

1:	mov $2,c		/ Assume 2 byte, ord.
	cmp a,$0xE1		/ Well ?
	bcc 3f			/ Ok
	mov $4,c		/ Assume 4 byte, ord.
	cmp a,$0xCB		/ Well ?
	beq 3f			/ Ok
	dec c			/ Assume 3 byte, ord.
	cmp a,$0x40		/ Well ?
	bcc 3f			/ Ok
	mov $pltab,hl		/ Look up
	call	ilen1		/ the
	inc c			/ length
	br	3f		/ Do it.

/
/ One byte
/

2:	mov $sctab,hl		/ Set up to search the
	mov $NSCTAB,b		/ special case table

0:	cmp a,(hl)		/ Well ?
	inc hl			/
	beq 2f			/ Yes
	inc hl			/ Skip over the address
	inc hl			/
	sob b,0b		/ Loop until done

	cmp a,$0xC0		/ Transfer ?
	bcs 1f			/ No
	and $0x07,a		/ Index into correct simulator
	rlc a			/
	mov a,c			/ `sob' set `b' to 0 !
	mov $0f,hl		/
	add bc,hl		/

2:	mov (hl),a		/ Low byte
	inc hl			/
	mov (hl),h		/ High byte
	mov a,l			/
	push	hl		/ Save transfer address
	mov pcsave,hl		/ Set up registers
	mov (hl),a		/
	ret			/ Call handler

0:	.word	xcret		/ 03X0 - Conditional return
	.word	1f		/ 03X1 - Pops
	.word	xcjmp		/ 03X2 - Conditional jumps
	.word	1f		/ 03X3 - Misc.
	.word	xccal		/ 03X4 - Conditional calls
	.word	1f		/ 03X5 - Pushes
	.word	1f		/ 03X6 - Immediate ops
	.word	xrst		/ 03X7 - Restarts

/
/ Absolutely ordinary.
/

1:	mov pcsave,hl		/ Compute
	mov (hl),a		/ op
	call	ilen		/ length

3:	mov pcsave,hl		/ Source
	mov $xbuf,de		/ Destination
	mov $0,b		/ Length to `bc'
	movir			/ Copy opcode to buffer
	mov hl,pcsave		/ Update user `pc'
	mov $0f,hl		/ Point at a jump to get us back
	mov $3,c		/ Copy it to
	movir			/ buffer

	call	restor		/ Restore all but the `pc'
	mov nlsave,hl		/ and go execute the
	jmp xbuf		/ instruction.

0:	jmp 0f			/ Copied ....

0:	mov hl,nlsave		/ Save
	call	save		/ registers and
	jmp go10

/
/ Emulation routines.
/ All are called (with the exception of `xret')
/ with the user `pc' in the `hl' and the opcode
/ in the `a'
/

xdjnz:
	mov nbsave,a		/ Decrement
	dec a			/ user `b'
	mov a,nbsave		/ register and
	beq xnop2		/ continue on zero.

xjr:
	inc hl			/ Point at disp.
	mov (hl),e		/ Get disp.
	inc hl			/ `hl' is the `pc'
	mov $0,d		/ Sign extend the disp.
	bit 7,e			/
	beq 0f			/
	dec d			/
0:	add de,hl		/ Compute new `pc'
	br	xnewpc		/

xcjr:
	mov $0f,hl		/ Pick up stuff to copy
	mov $7,bc		/ and its length.
	br	2f		/

0:	.byte	3		/ Disp
	jmp xnop2		/ Not taken
	jmp xjr			/ Taken

xcret:
	add $2,a		/ Return becomes jump
	mov $0f,hl		/ Stuff to copy
	br	1f		/

0:	.word	xret		/ Taken
	jmp xnop1		/ Not taken

xccal:	sub $2,a		/ Call becomes jump
	mov $0f,hl		/ Stuff to copy
	br	1f		/

0:	.word	xcall		/ Taken
	jmp xnop3		/ Not taken

0:	.word	xjmp		/ Taken
	jmp xnop3		/ Not taken

xcjmp:
	mov $0b,hl		/ Stuff to copy

1:	mov $5,bc		/ and its length
2:	mov $xbuf,de		/ Destination
	mov a,(de)		/ Store opcode
	inc de			/
	movir			/ Copy code

	mov nfsave,hl		/ Set flags and
	push	hl		/
	pop af			/
	mov pcsave,hl		/ Grab user `pc' again
	jmp xbuf		/ Go execute

xret:
	mov spsave,hl		/ Grab `sp'
	mov (hl),e		/ Pop lower half
	inc hl			/
	mov (hl),d		/ Pop upper half
	inc hl			/
	mov hl,spsave		/ Replace `sp'
	ex	de,hl		/ Send address to `hl' and
	br	xnewpc		/ jump

xrst:
	call	pushra		/ Push return address
	and $0x38,a		/ Get call address
	mov a,l			/
	mov $0,h		/
	br	xnewpc		/ and jump.

xcall:
	inc hl			/ Push return address
	inc hl			/
	call	pushra		/

xjmp:
	inc hl			/ Grab jump address
	mov (hl),a		/
	inc hl			/
	mov (hl),h		/
	mov a,l			/
	br	xnewpc		/

xpchl:
	mov nlsave,hl		/ `hl' -> `pc'
	br	xnewpc		/

xnop3:	inc hl			/ Nops
xnop2:	inc hl			/
xnop1:	inc hl			/

xnewpc:
	mov hl,pcsave		/ Store new `pc' and

go10:
	mov $btab,ix		/ Set up to plug breakpoints
	mov $NBTAB,b		/

1:	mov HIGH(ix),a		/ Grab address
	or	a,a		/
	beq 0f			/ Empty
	mov a,h			/ Copy address to `hl'
	mov LOW(ix),l		/
	mov (hl),a		/ Save old byte
	mov a,OP(ix)		/
	mov $RST1,(hl)		/ Patch in restart

0:	call	incix3		/ Do them all
	sob b,1b		/

	call	restor		/ restore (most) of the registers
	mov pcsave,hl		/ Save `pc' on stack.
	push	hl		/
	mov nlsave,hl		/ Reload `hl' and
	ret			/ Go .....
	.page
/
/ Intel format loader. Reads from the port
/ attached to the PDP-11. All characters that
/ are less than a blank are thrown away.
/ A record with a length of zero is the end
/ of file mark; to be compatable with the
/ loader in the Xitan all bytes up to the
/ (unused) type are read.
/

rcom:
	call	rcom30		/ Read until `:'
	cmp a,$':		/
	bne rcom		/

	mov $0,d		/ Clear out checksum

	call	rcom10		/ Get byte count
	mov e,b			/
	call	rcom10		/ Get address
	mov e,h			/
	call	rcom10		/
	mov e,l			/
	call	rcom10		/ Get (unused) type

	mov b,a			/ If the length is zero
	or	a,a		/ then we are
	beq 1f			/ all done.

0:	call	rcom10		/ Grab a data byte
	mov e,(hl)		/ Store it down
	inc hl			/ Step the store pointer and
	sob b,0b		/ Loop until all done

	call	rcom10		/ Get checksum
	beq rcom		/ Br if good checksum
	mov $cmsg,hl		/ Complain about it
	call	puts		/

1:	call	crlf		/ Send a newline (be neat)
	bic DE,c		/ Kill address
	br	8f		/

rcom10:
	call	rcom20		/ Get digit
	rlc a			/ << 4
	rlc a			/
	rlc a			/
	rlc a			/
	mov a,e			/ Save the high half
	call	rcom20		/ Get digit
	add e,a			/ Put hex byte in `e'
	mov a,e			/
	add d,a			/ Checksum to `d'
	mov a,d			/
	ret			/

rcom20:
	call	rcom30		/ Get char.
	sub $'0,a		/ Is it `0' - `9'
	cmp a,$10		/
	rcs			/ Yes
	sub $7,a		/ Must be `A' to `F'
	ret			/

rcom30:
	in	STATUS,a	/ Wait for a byte
	bit RDA,a		/
	bne rcom30		/
	in	RDATA,a		/ Read it in
	and $0177,a		/
	cmp a,$SP		/ Keep it ?
	bcs rcom30		/
	ret			/
	.page
/
/ `w' - Display breakpoints
/

wcom:
	call	crlf		/ Send newline
	mov $btab,ix		/ Set up
	mov $NBTAB,b		/

1:	mov HIGH(ix),a		/ Grab address
	or	a,a		/
	beq 0f			/ Empty slot
	mov a,h			/ Print it
	mov LOW(ix),l		/
	call	putw		/
	call	crlf		/

0:	call	incix3		/ Do them all
	sob b,1b		/
8:	jmp cmd10		/ Done

	.page
/
/ Add 3 to the `ix'
/

incix3:
	inc ix		/ Makes the code smaller
	inc ix		/
	inc ix		/
	ret		/

/
/ This subroutine pushes `hl'+1 onto the
/ simulated stack.
/

pushra:
	inc hl			/ Make `hl' + 1
	ex	de,hl		/ and copy it to the `de'
	mov spsave,hl		/ Grab `sp'
	dec hl			/ Push upper half
	mov d,(hl)		/
	dec hl			/ Push lower half
	mov e,(hl)		/
	mov hl,spsave		/ Store `sp' and
	ret			/ return

/
/ This subroutine computes the length (in bytes)
/ of an instruction. All funny Z-80 prefix type
/ instructions have been detected. The opcode is
/ passed in `a'; the length is returned in `c'.
/ The special entry `ilen1' is used by the code
/ for `DD' and `FD' prefixes.
/

ilen:
	mov $hltab,hl		/ Default to `C0' - `FF'
	cmp a,$0xC0		/ Right ?
	bcc ilen1		/ Yes.

	mov $1,c		/ Default to 1 byte.
	cmp a,$0x40		/ Right ?
	rcc			/ Yes, return.

	mov $lltab,hl		/ Use `00' to `3F' table.

ilen1:
	and $0x3F,a		/ Mask opcode to 7 bits.

0:	cmp a,$4		/ Right byte ?
	bcs 0f			/ Yes
	sub $4,a		/ Bring into range.
	inc hl			/ Bump table ptr
	br	0b		/

0:	mov a,c			/ `c' is opcode mod 4
	mov (hl),a		/ `a' is table byte

0:	dec c		/ Done ?
	jmi 0f		/ Yes
	rrc a		/ Slide down 1 entry
	rrc a		/
	br	0b	/

0:	and $0x03,a	/ Mask of result and
	mov a,c		/ move it to `c'
	ret		/ Done.

/
/ These two routines save and restore the state
/ of the machine. `save' switches to the debug
/ stack and saves all the registers except `hl',
/ `sp' and `pc' which must be saved by the
/ caller. `restor' restores all of the registers
/ except the `hl' and the `pc' which must be
/ restored by the caller.
/

save:
	pop hl		/ Get return address.
	mov sp,spsave	/ Save `sp'
	mov $nlsave,sp	/ Switch stacks.
	push	de	/ Save normal registers.
	push	bc	/
	push	af	/
	exx		/ Switch to alternate set and
	push	hl	/ Save them.
	push	de	/
	push	bc	/
	ex	af,af'	/ Do the accumulator too.
	push	af	/
	push	ix	/ Save index registers.
	push	iy	/
	exx		/ Return
	jmp (hl)	/

restor:
	pop hl		/ Get return address.
	exx		/ Switch sets.
	pop iy		/ Restore index registers.
	pop ix		/
	pop af		/ Restore alternate `af'
	ex	af,af'	/ Switch accum.
	pop bc		/ Restore alternate regs.
	pop de		/
	pop hl		/
	exx		/ Switch to normal.
	pop af		/ Restore normal regs.
	pop bc		/
	pop de		/
	mov spsave,sp	/ Restore `sp'
	jmp (hl)	/ Return.

/
/ Print a carriage return/linefeed.
/

crlf:
	push	af		/ Save the accumulator.
	mov $CR,a		/ Send
	rst PUTC		/ carriage return
	mov $LF,a		/ Send
	rst PUTC		/ line feed
	pop af			/ Restore accumulator and
	ret			/ return.

/
/ Output a NUL terminated string of characters
/ pointed to by the `hl'. The `a' is clobbered
/ by this routine.
/

puts:
	mov (hl),a		/ Get character
	or	a,a		/ Check for the end
	req			/ and return.
	rst PUTC		/ Type it
	inc hl			/ Advance to next and
	br	puts		/ continue.

/
/ Get a character. If the character is not
/ a control character it is printed. Any upper
/ case letters are converted to lower case.
/ The character is passed back in the `a'.
/

getc:
	in	STATUS,a	/ Wait for receive data
	bit RDA,a		/
	bne getc		/
	in	RDATA,a		/ Read data, reset UAR/T
	and $0177,a		/ Clear crap
	cmp a,$SP		/ Control ?
	bcs 0f			/ Yes.
	rst PUTC		/ No, echo.

0:	cmp a,$'A		/ Upper case ?
	bcs 0f			/ No.
	cmp a,$'Z+1		/ Perhaps ?
	bcc 0f			/ No.
	add $'a-'A,a		/ Make lower.

0:	ret			/ Done.

/
/ Put out an address. The address is in the
/ `hl'. If the address points into the register
/ save area interpret it as the appropriate
/ special name.
/

puta:
	push	hl		/ Save the address

	mov $-iysave,de		/ Compute distance into the
	add de,hl		/ Special area
	mov h,a			/ See if
	or	a,a		/ it is
	bne 1f			/ one of
	mov l,a			/ the
	cmp a,$24		/ special
	bcc 1f			/ names.

	cmp a,$4		/ Test if
	bcs 0f			/ the
	cmp a,$12		/ displacement is
	bcc 0f			/ in alternate reg.
	inc h			/ Set flag if yes
	add $8,a		/ and fix displacement

0:	bit BYTE,c		/ If special word
	bne 0f			/ then
	inc a			/ Fix disp.

0:	mov a,l			/ Set up to
	mov $sntab+1,de		/ search the special
	mov $NSNTAB,b		/ names list

4:	mov (de),a		/ Get the displacement

	bit BYTE,c		/ Doing bytes ?
	beq 2f			/ No
	bit B,a			/ Must be usable
	beq 3f			/ It isn't

2:	and $BD,a		/ It this me ?
	cmp a,l			/
	beq 0f			/ Yes.

3:	inc de			/ Advance to next
	inc de			/
	sob b,4b		/ Loop until done

1:	pop hl			/ Ugh, print in octal
	call	putw		/
	ret			/

0:	mov $'$,a		/ Print `$'
	rst PUTC		/
	dec de			/ Print register name
	mov (de),a		/
	rst PUTC		/
	dec h			/ Alternate ?
	bne 0f			/ Nope
	mov $'',a		/ Print `''
	rst PUTC		/

0:	pop hl			/ Clear stack
	ret			/ Done

/
/ Convert the sixteen bit value in the `hl' to
/ octal ASCII and send it out to the terminal
/ via calls to `putc'. The `hl' and the `a'
/ get clobbered.
/

putw:
	push	bc		/ Save `bc'

	mov $'0,a		/ Do the top bit
	add hl,hl		/
	adc $0,a		/ Make `0' into a `1'
	rst PUTC		/

	mov $5,b		/ Set loop count.

0:	add hl,hl		/ Get
	rol a			/ next
	add hl,hl		/ octal
	rol a			/ digit
	add hl,hl		/ into
	rol a			/ the `a'.
	call	1f		/ Output digit
	sob b,0b		/ Do all 5

	pop bc			/ Restore and
	ret			/ return

/
/ Convert the byte in the `a' to octal asciii
/ and output it to the typewriter via calls to
/ `putc'. The `a' is clobbered.
/

putb:
	push	bc		/ Save `bc' and the
	mov a,c			/ argument.

	rlc a			/ Top 2 biits
	rlc a
	and $3,a
	call	2f

	mov c,a			/ Middle 3 bits
	rrc a
	rrc a
	rrc a
	call	1f

	mov c,a			/ Low 3 bits
	call	1f

	pop bc			/ Restore and
	ret			/ return

1:	and $7,a		/ Mask off 3 bits
2:	add $'0,a		/ Make ascii
	rst PUTC		/ Put it out
	ret			/

	.page
/
/ Command table.
/

cmtab:
	.byte	'/		/ Open location as word
	.word	slash
	.byte	'\		/ Open location as byte
	.word	bslsh
	.byte	CR		/ Close location
	.word	close
	.byte	LF		/ Close location, open next
	.word	close
	.byte	'^		/ Close location, open previous
	.word	close
	.byte	'b		/ Set breakpoint
	.word	bcom
	.byte	'c		/ Clear breakpoint
	.word	ccom
	.byte	'g		/ Go
	.word	go
	.byte	'r		/ Read Intel tape
	.word	rcom
	.byte	'w		/ Where are the breakpoints
	.word	wcom

NCMTAB	=	[.-cmtab]%3

/
/ Special names table.
/

Q	=	7	/ A quote is legal
W	=	6	/ Word legal
B	=	5	/ Byte legal

BQ	=	0200	/ Bit masks
BW	=	0100	/ for the
BB	=	040	/ above
BD	=	037	/ flags

sntab:
	.byte	'b, BQ+BW+BB+15
	.byte	'c, BQ+BB+14
	.byte	'd, BQ+BW+BB+17
	.byte	'e, BQ+BB+16
	.byte	'h, BQ+BW+BB+19
	.byte	'l, BQ+BB+18
	.byte	'a, BQ+BB+13
	.byte	'f, BQ+BB+12
	.byte	'p, BW+21
	.byte	's, BW+23
	.byte	'x, BW+3
	.byte	'y, BW+1

NSNTAB	=	[.-sntab]%2

/
/ Instruction length tables.
/

hltab:
	.byte	0365, 0147, 0065, 0157, 0265, 0147, 0265, 0143
	.byte	0165, 0147, 0165, 0143, 0165, 0147, 0165, 0143

lltab:
	.byte	0135, 0145, 0125, 0145, 0136, 0145, 0126, 0145
	.byte	0176, 0145, 0166, 0145, 0176, 0145, 0166, 0145

pltab:
	.byte	0000, 0000, 0004, 0000, 0000, 0000, 0004, 0000
	.byte	0174, 0000, 0164, 0000, 0000, 0072, 0004, 0000

/
/ Special case table.
/

sctab:
	.byte	0020		/ sob
	.word	xdjnz
	.byte	0030		/ br
	.word	xjr
	.byte	0070		/ bcs
	.word	xcjr
	.byte	0060		/ bcc
	.word	xcjr
	.byte	0050		/ beq
	.word	xcjr
	.byte	0040		/ bne
	.word	xcjr
	.byte	0311		/ ret
	.word	xret
	.byte	0315		/ call
	.word	xcall
	.byte	0303		/ jmp
	.word	xjmp
	.byte	0351		/ jmp (hl)
	.word	xpchl

NSCTAB	=	[.-sctab]%3

/
/ Messages.
/

bmsg:
	.asciz	"Break at "	/ Breakpoint hit
cmsg:
	.byte	CR, LF		/ Checksum error (rcom)
	.asciz	"Bad checksum"
emsg:
	.ascii	"?"		/ General error
	.byte	CR, LF, 0
imsg:
	.ascii	"Z-80 Xdb"	/ Introduction message (restart)
	.byte	CR, LF, 0
rmsg:
	.asciz	"Entry at "	/ Bad entry message

	.page
/
/ Scratch stuff.
/ The order is (very) carefully chosen.
/ This sits at the base of the user Ram.
/

.	=	020000		/ Hex page 20

	.blkb	40		/ Debugger's stack
iysave: .blkb	2		/ Index registers
ixsave: .blkb	2
afsave: .blkb	1		/ Alternate registers
aasave: .blkb	1
acsave: .blkb	1
absave: .blkb	1
aesave: .blkb	1
adsave: .blkb	1
alsave: .blkb	1
ahsave: .blkb	1
nfsave: .blkb	1		/ Normal registers
nasave: .blkb	1
ncsave: .blkb	1
nbsave: .blkb	1
nesave: .blkb	1
ndsave: .blkb	1
nlsave: .blkb	1
nhsave: .blkb	1
pcsave: .blkb	2
spsave: .blkb	2

dot:	.blkb	2		/ Current location
btab:	.blkb	3*NBTAB		/ Break table
xbuf:	.blkb	8		/ Execution buffer
	.end
