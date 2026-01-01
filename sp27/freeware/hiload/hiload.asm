; This is version 1.01 of HILOAD
;
;		See accompanying .DOC file for theory of
;		operation and instructions
;
;		No guarantees, but the author would appreciate
;		information on bugs.
;
;		Larry Shannon 18 Jun 89
;
; Equates
;
		CR	EQU	0D
		LF	EQU	0A
		SPACE	EQU	020
		MON	EQU	MOV	; Common typo
		ONE	EQU	1
		TWO	EQU	2
		DOLLAR	EQU	024
		ZERO	EQU	0
		BELL	EQU	07
;.....
;
; Macros
;
PRINT		 MACRO			; Usage: print MSG1
		PUSH	AX		; All registers preserved
		PUSH	DX
		MOV	AH,9
		LEA	DX, #1
		INT	021
		POP	DX
		POP	AX
		#EM
;
PRINT$		 MACRO			; Usage: print$,"MESSAGE"
		PUSH	AX		; Prints at current cursor position
		PUSH	DX
		JMP	>M1
M0:
		DB	#1
		DB	"$"
M1:
		MOV	AH,9		; All registers preserved
		LEA	DX,M0
		INT	021
		POP	DX
		POP	AX
		#EM
;
QUIT		 MACRO			; Usage: quit 0
		MOV	AH,04C		; Must give some value
		MOV	AL,#1
		INT	021
		#EM
;
NEWLINE		 MACRO			; Equivalent to CR,LF
		PUSH	AX		; Scrolls if off screen
		PUSH	DX
		JMP	> M1
M0:
		DB	0D,0A,'$'
M1:
		LEA	DX,M0
		MOV	AH,9
		INT	021
		POP	DX
		POP	AX
		#EM
;
SPLIT		 MACRO	AAM 16	#EM	; Be careful with these with
;					; Nec v-20/v-30 chips!
UNSPLIT		 MACRO			; This macro will effectively
		PUSH	CX		; Do the same thing, and should be
		MOV	CX,4		; Compatible with all pc's
		ROL	AH,CL
		AND	AH,0F0
		OR	AL,AH
		POP	CX
		#EM
;
HEX_TO_PRNT	 MACRO			; Changes an 8-bit register quantity
		OR	#1,030		; From 0-f to the ascii equivalent
		CMP	#1,039		; Register must be in form 00 to 0f
;
		 IF	A ADD #1,7
		#EM
;
PRINT_REG	 MACRO			; Used to print a register (or any 16-bit
		JMP	> M1		; Quantity) at the current cursor position
M0:
		DB	5 DUP ('$')
M1:
		PUSH	AX		; Usage - print_reg AX
		MOV	AX,#1		; Prints the 16-bit quantity in hex
		XCHG	AH,AL
		PUSH	AX
		MAKE_HEX_ASCII
		XCHG	AH,AL
		MOV	W[M0],AX
		POP	AX
		XCHG	AH,AL
		MAKE_HEX_ASCII
		XCHG	AH,AL
		MOV	W[M0+2],AX
		PRINT	M0
		POP	AX
		#EM
;
PRINT_32_DEC	 MACRO			; Macro to print a 32-bit hex number
		PUSH	AX		; As a decimal string
		PUSH	DX		; Enter with si pointing to two-word
		PUSH	DI		; (four byte) quantity to be converted
		MOV	DX,W[SI]	; Most significant word first
		MOV	AX,W[SI+2]	; Prints at current cursor position
		JMP	> M1		; All registers restored
M0:
		DB	11 DUP ('$')
M1:
		LEA	DI,M0
		ADD	DI,9
		CALL	LARGE_HEX_TO_ASCII
		MOV	DX,DI
		MOV	AH,9
		INT	021
		POP	DI
		POP	DX
		POP	AX
		#EM
;
REG_TO_PRINT	 MACRO			; Converts a 16-bit quantity to ascii
		PUSH	AX		; And puts the resultant string in a
		PUSH	BX		; Place pointed to by ds:si
		MOV	BX,#1		; All registers restored
		MOV	AL,BH
		CALL	HEX2PRNT
		MOV	[SI],AX
		MOV	AL,BL
		CALL	HEX2PRNT
		MOV	[SI+2],AX
		POP	BX
		POP	AX
		#EM
;
MAKE_CAP	 MACRO			; Makes letters capitals
		CMP	#1,061		; Useage  make_cap AH
		JB	> M1		; Ah contains a candidate ascii letter
		CMP	#1,07A		; From A-Z or a-z
		JA	> M1		; Returns A-Z
		AND	#1,0DF
M1:
		NOP
		#EM
;
MAKE_HEX_ASCII	 MACRO			; Makes al in hex into two ascii
		SPLIT			; Characters in ah:al
		HEX_TO_PRNT AH
		HEX_TO_PRNT AL
		#EM
;.....
;
; Data and strings
;
;
		ORG	0100
;
;
HILOAD:		JMP	LONG > L0

LOAD_BLOCK	DW	0,0
FILE_STRING	DB	65 DUP('$')
TAIL_PTR	DW	0
FILE_PTR	DW	0
OLD_INT_27	DW	0,0
OLD_INT_21	DW	0,0
START_ADDR	DW	0100,0
TAIL_BFR	DB	127 DUP	('020')
SW2127		DB	0
TEMPWRDS	DW	0,0
BAR		DB	40 DUP ('*'),'$'
RESET_MSG	DB	CR,LF,'Resetting ICA area',CR,LF,'$'
DEFAULT_ENV	DB	'HILOAD',0
INT_MSG		DB	'Interupt '
INT_NUM		DB	0,0,'H is now located at '
INT_SEG		DB	0,0,0,0,':'
INT_OFF		DB	0,0,0,0,CR,LF,'$'
TEMP		DW	0
LOAD_POINT	DW	0,0
LP_PLUS_BYTES	DW	0,0
INT_ADDR_1	DW	0
INT_ADDR_2	DW	0
;
NEW_INT21:
        	CMP	AH,031		; New address for int 21h
		JE	> Z21		; Is it TSR termination?
		CMP	AX,02521	; Setting vector for int 21h?
		JE	> Z25		; If so, save it
		CMP	AX,03521	; Request for int 21h address?
		JE	> Z35		; If so, give him original address
		CS	JMP D[OLD_INT_21] ; Otherwise, do real int 21h
Z25:
		CS	MOV OLD_INT_21,DX ; Here we save int 21h address info
		CS	MOV OLD_INT_21+2,DS
		IRET			; And return to caller
Z35:
		CS	MOV BX,[OLD_INT_21] ; Here we give him original address
		CS	MOV ES,[OLD_INT_21+2]
		IRET			; And return to caller
Z21:
		CS	MOV SW2127,0	; Exiting via int 21 - set switch for
		JMP	> Z22		; Storage return handling
;.....
;
NEW_INT27:
		CS	MOV SW2127,1	; Trap for int 27h - set switch
Z22:
		MOV	AX,CS		; Get our code segment
		MOV	BX,DX		; Save return size info
		MOV	DS,AX		; Set up local addressability
		MOV	ES,AX		; Make sure other registers are
		MOV	SS,AX		; What they should be
		MOV	DX,[OLD_INT_27]	; Find original address of int 27h
		MOV	AX,[OLD_INT_27+2] ; Segment portion
		MOV	ES,0		; Addressing bottom page
		ES	MOV W[09C],DX	; Store vector addresses directly
		ES	MOV W[09E],AX	; Since int 21h cannot be used to do
		MOV	DX,[OLD_INT_21]	; The job - we've trapped it above!
		MOV	AX,[OLD_INT_21 + 2] ; Do the same with int 21h
		MOV	ES,0
		ES	MOV W[084],DX	; And store its address in the
		ES	MOV W[086],AX	; Proper place in the table
		NEWLINE			; Space a line
		PRINT$	'Saved bytes = ' ; Start of message
		CMP	SW2127,1	; See how we terminated; 1=int 27h so
		JE	> Q2		; Returns bytes - int 21h returns para-
		MOV	AX,BX		; Graphs - here we're converting
		XOR	DX,DX		; Paragraphs to bytes by multiplying
		MOV	CX,4		; By 4 (shift left 4 places)
Q1:
		RCL	AX,1		; Have to allow for greater than 64k
		PUSHF			; Save flags with state of carry bit
		ROL	DX,1
		POPF			; Get flags back
		ADC	DX,0		; Add in and include carry
		LOOP	Q1		; Carry on
		JMP	> Q3
Q2:
		MOV	AX,BX		; Size info in bx - do setup for
		XOR	DX,DX		; Conversion
Q3:
		MOV	TEMPWRDS,DX	; Temporarily store upper and lower
		MOV	TEMPWRDS + 2,AX	; Halves of return size info (32 bits)
		PUSH	DX		; Save dx
		MOV	DX,[LOAD_POINT]	; Get where we started
		MOV	LP_PLUS_BYTES,DX ; Put it here
		POP	DX		; Retrieve dx
		ADD	LP_PLUS_BYTES,DX ; Add size info
		MOV	LP_PLUS_BYTES+2,AX ; Store upper half here
		LEA	SI,TEMPWRDS	; Point to temporary storage
		PRINT_32_DEC		; Print out size in bytes
		NEWLINE			; Do new line
		MOV	DX,[TEMPWRDS]	; Get back size info
		MOV	AX,[TEMPWRDS+2]
		CLC			; Clear the carry
		MOV	CX,4		; We're going to convert to a 32-bit
Q7:
		SHR	DX,1		; Number here and store it in
		PUSHF			; The ica area
		RCR	AX,1
		POPF
		LOOP	Q7
		MOV	ES,040		; Point to segment of ica
		ES	MOV BX,[0F0]	; Get what was there
		ADD	DX,BX		; Add new size
		ES	MOV [0F0],DX	; And put it back
		ES	MOV BX,[0F2]	; Get old lower half
		ADD	AX,BX		; Add new bytes saved data
		INC	AX		; Allow for truncation
		ES	MOV [0F2],AX	; And put it back

		NEWLINE			; Start of trap info
		PRINT$	'This TSR traps the following interrupts:'
		NEWLINE			; Some spaces
		NEWLINE
;
; Here is where we look to see what interrupts are trapped
;
		MOV	CX,0FF		; Look at 256 interrupts
		MOV	AX,03500	; Set up call
H1:
		PUSH	CX		; Save registers
		PUSH	AX
		INT	021		; Get interrupt addresses
		MOV	AX,BX		; Ax is offset
		MOV	DX,ES		; Dx:ax is addr of interrupt
		MOV	INT_ADDR_1,AX	; Store offset away
		MOV	INT_ADDR_2,DX	; Store segment
		CALL	ADD_SEG_OFF	; Convert to 32-bit number
		XCHG	BX,DX		; Now bx:cx is int addr
		XCHG	CX,AX		; In 32-bit form
		MOV	DX,[LOAD_POINT]	; Where do we start
		XOR	AX,AX		; No offset from start
		CALL	ADD_SEG_OFF	; Make 32-bitter
		CALL	CMP_32		; Is int address beyond start point?
		JNC	> H2		; If below, can't be us - get out
		MOV	DX,[LP_PLUS_BYTES]
		MOV	AX,[LP_PLUS_BYTES + 2] ; Dx:ax now address of end of pgm
		CALL	ADD_SEG_OFF	; Make 32-bits
		CALL	CMP_32		; Compare them
		JC	> H2		; If greater - beyond me
		POP	AX		; We got one - retrieve interrupt
		PUSH	AX		; And save function and int number
		CALL	HEX2PRNT	; Get interrupt number in ascii
		LEA	SI,INT_NUM	; Point to proper place
		MOV	W[SI],AX	; Store it
		LEA	SI,INT_SEG	; Point to place
		REG_TO_PRINT [INT_ADDR_2] ; Get segment in ascii
		LEA	SI,INT_OFF	; Point to place
		REG_TO_PRINT [INT_ADDR_1] ; Print offset in ascii
		PRINT	INT_MSG		; Print whole message
H2:
		POP	AX		; Get registers back
		INC	AX
		POP	CX
		DEC	CX
		JCXZ	> H3		; Are we done?
		JMP	LONG H1		; No - go back for more
H3:
		QUIT	0		; We're done - exit
;.....
;
;=======================================================================
; Main program starts here
;=======================================================================
;
L0:
		NEWLINE			; Give us some space
		PRINT	BAR		; Print banner bar
		NEWLINE			; Another space
		MOV	AH,[080]	; See if any comand tail
		CMP	AH,1
		JA	> L1
L00:
		MOV	ES,040		; If no tail, reset ica
		ES	MOV W[0F0],0
		ES	MOV W[0F2],0
		PRINT	RESET_MSG	; Write message
		QUIT	0		; And get out - normal exit
L1:
		MOV	DI,080		; Point to command tail
L22:
		INC	DI
		MOV	AH,[DI]
		CMP	AH,020		; Bumping past the spaces here
		JE	L22
		MOV	FILE_PTR,DI	; Point to file name
L222:
		MOV	AH,[DI]
		CMP	AH,SPACE
		JE	> L555
		CMP	AH,CR
		JE	> L555
		INC	DI
		JMP	L222
		MOV	AL,CR		; Look for carriage return
		MOV	CX,0100		; Look for a long time!
		CLD
		REPNE	SCASB
		JCXZ	L00		; Get out if no find one
		DEC	DI
L555:
		MOV	TAIL_PTR,DI	; Save pointer to command tail
		PUSH	DI
		LEA	BX,TAIL_BFR	; Point to command tail (saved)
L16:
		MOV	AH,[DI]		; Get element
		CMP	AH,CR		; End of tail?
		JE	> L17
		MOV	[BX],AH		; Stuff it away
		INC	DI		; Bump pointers
		INC	BX
		JMP	L16		; Do again
L17:
		MOV	B[BX],CR	; Terminate tail
		POP	DI
		LEA	BX,FILE_STRING	; Point to buffer to store file name
		MOV	DI,[FILE_PTR]	; Get pointer to program in command tail
L33:
		MOV	AH,[DI]		; Build the name, char by char
		MAKE_CAP AH		; Make sure all caps
		MOV	[BX],AH		; Stuff it away
		INC	BX		; Bump pointers
		INC	DI
		CMP	DI,[TAIL_PTR]	; Are we done?
		JB	L33		; If not, carry on
		MOV	W[BX],'C.'	; Stick in ".COM" extension
		MOV	W[BX+2],'MO'	; Reversed - that's the way intel works
		MOV	B[BX+4],0	; End with 0 to make asciiz string
		LEA	DX,FILE_STRING	; Point dx to the file
		MOV	AH,04E		; Find file
		MOV	CX,027		; File attribute byte - this works
		INT	021		; Do it
		JC	> L77		; Did we find it?
		JMP	LONG L78	; Got it! go process it
L77:
		NEWLINE			; Couldn't find file
		NEWLINE
		PRINT$	'Cant find file ' ; So say so
		MOV	B[DI-1],'$'	; Put in string delimiter and print
		PRINT	FILE_STRING	; What we were looking for
		PRINT$	' ...ABORTING'	; Sorry charlie
		NEWLINE
		NEWLINE
		QUIT	3		; Quit with error level = 3
L78:
		MOV	AL,' '		; Looking for a space
		MOV	CX,100		; Up to 256 bytes back
		STD			; Scan backwards
		REPNE	SCASB		; And search
		LEA	DX,FILE_STRING	; Ok, now at start of file string
		PUSH	DI		; Save pointer
		MOV	B[DI-1],0	; Make asciiz string
		PUSH	BX
		PUSH	CX
		MOV	AH,030		; Check dos version level
		INT	021
		POP	CX
		POP	BX
		CMP	AL,2		; At least version 2?
		JAE	> V1
		NEWLINE			; If not, dump out
		PRINT$	'Requires DOS 2.0 or above ... ABORTING'
		NEWLINE
		QUIT	2		; Bad dos version - error level = 2
V1:
		CMP	AL,3		; Version 3.0 or above?
		JAE	> V2		; If it is, we're ok
		LEA	SI,DEFAULT_ENV	; Set up default envir var name
		JMP	> V3
V2:
		CALL	WHOAMI		; Find out this programs'name
V3:
		CALL	GET_ENV_VAR	; Get the environment value
		JC	> L88		; Did we get a match?
		JMP	LONG L888	; Yes, we did
L88:
		NEWLINE			; No we didn't
		PRINT$	'No address given ... ABORTING'
		QUIT	1		; Bad environment variable - error
L888:
		PUSH	DS
		PUSH	ES
		POP	DS
		CALL	ASC_2_NUMS	; Convert the ascii to hex values
		POP	DS
		MOV	START_ADDR+2,AX	; That's our starting address
		MOV	ES,040
		ES	ADD AX,[0F0]	; Add the last loads' space
		ES	ADD AX,[0F2]
		ADD	AX,010		; Allow for psp
		MOV	LOAD_BLOCK,AX	; This is out new loading address
		SUB	AX,010		; Remove psp allowance
		NEWLINE			; Starting load message
		PRINT$	'Loading '
		POP	DI
		MOV	B[DI-1],'$'	; Make printable
		PRINT	FILE_STRING	; And print it
		PRINT$	'at segment '
		PRINT_REG AX		; Print segment address
		LEA	BX,LOAD_BLOCK	; Where we load
		PUSH	ES
		PUSH	DS
		POP	ES
		MOV	AH,04B		; Dos exec function
		MOV	AL,3		; Load but don't execute
		INT	021		; Do it
		POP	ES
		MOV	AX,[LOAD_BLOCK]	; Loading address again
		SUB	AX,010		; Allow for psp
		MOV	START_ADDR + 2,AX ; Stuff it away
		MOV	LOAD_POINT,AX	; And here
		MOV	LP_PLUS_BYTES,AX ; And here, too
		MOV	ES,AX		; Segment of where tsr is loaded
		MOV	CX,0100		; Going to transfer 256 bytes
		XOR	SI,SI		; Of the psp (we're using the one
		XOR	DI,DI		; We got from dos)
		CLD			; Set direction flag
		REP	MOVSB		; Transfer it
		MOV	DI,081		; Point to com tail in new psp
		LEA	SI,TAIL_BFR
		XOR	AL,AL		; Count of command tail length
L98:
		MOV	AH,[SI]
		CMP	AH,CR		; Any command tail at all?
		JE	> L99
		ES	MOV [DI],AH	; If so, start transferring the
		INC	AL		; Tsr's command tail - he might
		INC	DI		; Need it
		INC	SI
		JMP	L98
L99:
		MOV	B[SI],'$'	; Again, for dos int 21h printing
		NEWLINE
		PRINT$	'Command tail = ' ; Printing out the supplied
		PRINT	TAIL_BFR	; Command tail
		MOV	B[SI],CR	; Terminate
		ES	MOV B[DI],CR	; Terminate new tail
		ES	MOV [080],AL	; Put in count
		ES	MOV B[081],SPACE ; And normal space
;
; Here we start revectoring the appropriate interrupts
;
		MOV	AH,035		; The 'gimme address' function
		MOV	AL,027		; For interrupt 27h
		INT	021		; Go get it
		MOV	AX,ES		; Its segment
		MOV	OLD_INT_27,BX	; Store offset value
		MOV	(OLD_INT_27 + 2),AX ; Store segment value
		LEA	DX,NEW_INT27	; Where we're going to point to
		MOV	AH,025		; Tell dos about it
		MOV	AL,027		; For int 27h
		INT	021		; Do it
		MOV	AH,035		; Get address function again
		MOV	AL,021		; This time for int 21h
		INT	021		; Do it
		MOV	AX,ES
		MOV	OLD_INT_21,BX	; Save offset
		MOV	(OLD_INT_21 + 2),AX ; And segment
		LEA	DX,NEW_INT21	; Point to my routine
		MOV	AH,025		; And tell dos
		MOV	AL,021
		INT	021
		MOV	AX,[START_ADDR+2] ; Get address of routine
		MOV	ES,AX		; Set up registers
		MOV	DS,AX		; But don't change stack reg (ss)!!
		CS	JMP D[START_ADDR] ; And execute the program
;...
;
; This is the end of the regular program.  We exit when the TSR executes
; and INT 27H or an INT 21H with function 31H.
;
; The following are the various subroutines used
;
;	routine to compare two 32-bit quantities
;	if BX:CX > DX:AX, carry bit is set
;	if BX:CX < DX:AX, carry bit is cleared
;	if BX:CX = DX:AX, zero flag is set
;
;	all registers unchanged
;
CMP_32:
		CMP	BX,DX
		JAE	> L0
		JMP	> L1
L0:
		JA	> L2
		CMP	CX,AX
		JB	> L1
L2:
		STC
		RET
L1:
		CLC
		RET
;.....
;
; Routine to form 32-bit sum of (typically) a segment and offset pair
;
;	enter with "segment" value in DX, "offset" in AX
;	returns with sum in DX:AX
;
;	all other registers restored
;
ADD_SEG_OFF:
        	PUSH	BX,CX
		XOR	BX,BX
		MOV	CX,4
L0:
		SHL	BX,1
		SHL	DX,1
		ADC	BX,0
		LOOP	L0
		ADD	AX,DX
		ADC	BX,0
		MOV	DX,BX
		POP	CX,BX
		RET
;.....
;
; Routine to convert a HEX digit to a two byte word containing the
; equivalent ASCII characters
;
;	Enter with the byte to be converted in AL
;	Return with the ASCII string in AX in 'backwords' format
;	i.e., an AL value of 47 would return AX = 3734
;	so a MOV W[SI],AX for example would store the values
;	in memory in the proper order
;
;	All other registers restored
;
;	This is essentially identical to the macro MAKE_HEX_ASCII
;	except the macro does not interchange AH and AL
;
HEX2PRNT:
		XOR	AH,AH		; Zero out upper half
		AAM	16		; Split into two
		ADD	AX,03030	; Make ASCII
		CMP	AH,039		; Check for a - f
		 IF	A ADD AH,7
		CMP	AL,039
		 IF	A ADD AL,7
		XCHG	AH,AL		; Put in proper order
		RET			; For a MOV innstruction
;.....
;
; Routine to find out the program name.
;	no parameters on entry.
;	return with SI pointing to a string containing the file name
;	with no extent or period.
;	the string is terminated with a 0.
;	all registers (except SI) are restored
;
WHOAMI:
		JMP	> L0
MY_NAME:
		DB	9 DUP (0)
L0:
		PUSH	AX
		PUSH	BX
		PUSH	CX
		PUSH	ES
		PUSH	DI
		MOV	BX,[02C]	; Get seg addr of env
		MOV	ES,BX		; Put in es
		XOR	DI,DI		; Zero out di
		XOR	AX,AX		; Looking for double zeros
		MOV	CX,08000	; Max environment length = 32k
		CLD			; Set direction flag
L3:
		REPNE	SCASB		; Look for zero
		ES	MOV BX,W[DI-1]
		CMP	BX,0		; Got two bytes of zero?
		JNE	L3
		MOV	AL,'.'
		REPNE	SCASB		; Looking for extent
		MOV	BX,DI		; Save end of string pointer
L6:
		ES	MOV AL,[DI]
		CMP	AL,'\'
		JE	> L7
		CMP	AL,0
		JE	> L7
		DEC	DI
		JMP	L6
L7:
		MOV	SI,DI
		INC	SI		; Point to first byte of asciiz
		LEA	DI,MY_NAME	; Will store it in this segment
L2:
		ES	MOV AH,[SI]
		CMP	AH,'.'
		JE	> L1
		MAKE_CAP AH		; Make sure all names are capitals
		MOV	[DI],AH
		INC	DI
		INC	SI
		JMP	L2
L1:
		LEA	SI,MY_NAME
		POP	DI
		POP	ES
		POP	CX
		POP	BX
		POP	AX
		RET
;.....
;
; Routine to find a match between a given string and an environment
; variable.
;
;	Enter with DS:SI pointing to a string, terminated by a 0,
;	which contains the string to be matched.
;
;	Returns with SI pointing to the end of the matching
;	string in in the environment.
;
;	The environment variables are of the form NAME=string
;	This routine returns SI pointing to the string, just
;	after the equal sign.
;
;	ES points to the environment segment on return
;
;	If a matching string is found, the carry bit will be
;	clear. If no match is found, the carry will be set.
;
;	All other registers are restored; SI not guaranteed.
;
GET_ENV_VAR:
		JMP	> L0
STRING_COUNT:
		DW	0
L0:
		PUSH	AX
		PUSH	CX
		PUSH	DI
		XOR	CX,CX		; Zero out counter
		PUSH	SI		; Save pointer
L1:
		MOV	AL,[SI]
		CMP	AL,0		; At end of string?
		JE	> L2
		INC	SI		; Bump pointer
		INC	CX		; Bump counter
		JMP	L1
L2:
		CS	MOV STRING_COUNT,CX ; Save counter
		POP	SI		; Restore pointer
		CALL	GET_ENV_LENGTH	; Get length of environment
		MOV	CX,AX		; Set up count
		XOR	DI,DI		; Start at beginning
		MOV	AX,[02C]	; Environment segment
		MOV	ES,AX
		CLD			; Scan forward
		MOV	AL,[SI]		; Look for first letter
L3:
		REPNE	SCASB		; Scan for it
		DEC	DI		; Back off to point to match
		JCXZ	> L99		; Get out if not there
		PUSH	CX		; Save counter
		CS	MOV CX,[STRING_COUNT]
		PUSH	SI		; Save my old place
		REPE	CMPSB		; See if they're all equal
		POP	SI		; Restore my place
		JZ	> L4
		POP	CX		; No match, so carry on
		JMP	L3
L99:
		STC			; Set the carry
		JMP	> L5
L4:
		POP	CX		; Clear stack
		MOV	SI,DI		; Put pointer in si
		INC	SI		; Skip past equal sign
		CLC			; Clear carry
L5:
		POP	DI
		POP	CX
		POP	AX
		RET
;.....
;
; Routine to find length of environment
;
;	IF CARRY IS CLEAR, RESULT RETURNED IN AX
;	IF CARRY IS SET, ERROR CONDITION
;
;	IN EITHER EVENT, ALL REGISTERS OTHER THAN AX ARE RESTORED
;
GET_ENV_LENGTH:
		PUSH	CX
		PUSH	ES
		PUSH	DI
		MOV	AX,[02C]	; Get segment of environment
		MOV	ES,AX
		XOR	DI,DI		; Start at beginning of env
		MOV	CX,08000	; Maximum env string = 32k
L9:
		ES	MOV AX,W[DI]
		CMP	AX,0
		JE	> L0
		INC	DI
		LOOP	L9
		JCXZ	>L1		; If cx=0, we're in big trouble
L0:
		MOV	AX,DI		; Si is length of env - put it in ax
		CLC			; Clear carry bit - result ok
		JMP	> L2
L1:
		STC			; Set the carry - error
L2:
		POP	DI
		POP	ES
		POP	CX
		RET
;.....
;
; Routine to convert a 2-digit ASCII pair into a hex number e.g.,
; convert 3741 into 7A.
;
;	Enter with the ASCII pair in AX, return with the hex digit
;	in AL
;
;	If all is well, the carry bit is clear
;	If the carry bit is set, at least one of the proposed digits
;	was not in the range (0-9) snd (A-F) (Routine accepts small
;	letters and makes them caps)
;
;	All other registers unaffected.
;
ASC_2_HEX:
		XCHG	AH,AL
		CMP	AH,039
		JBE	> L0
		AND	AH,0DF		; Make caps
		CMP	AH,'F'
		JA	> L3
		SUB	AH,7
L0:
		CMP	AH,030
		JB	> L3
		CMP	AL,039
		JBE	> L1
		AND	AL,0DF
		CMP	AL,'F'
		JA	> L3
		SUB	AL,7
L1:
		CMP	AL,030
		JB	> L3
		SUB	AX,03030
		UNSPLIT
		CLC
		RET
L3:
		STC
		RET
;.....
;
; Routine to convert a 4-digit ASCII number representation into a
; 4-digit hex number e.g., 31374230 -> 17B0
;
;	Enter with DS:SI pointing to the string.
;	Return with the number in AX, in the proper order
;	i.e., 31374230 -> AH = 17, AL = B0
;
;	Carry bit set indicates bad ASCII number (out of range) see above
;
ASC_2_NUMS:
		PUSH	BX
		MOV	AX,W[SI]
		CALL	ASC_2_HEX
		JC	> L1
		MOV	BX,AX
		MOV	AX,W[SI+2]
		CALL	ASC_2_HEX
		JC	> L1
		MOV	AH,BL
		POP	BX
		CLC
L1:
		RET
;.....
;
; Routine to convert a 32-bit number to a decimal ASCII string enter
; with the number to be converted in DX:AX and DI pointing to the last
; byte of the result string area.  Return with DI pointing to first
; non-zero character of resultant conversion.
;
;	BX, CX, and SI unchanged
;
;	This routine was cribbed from FREE by Art Merrill - I don't really
;	understand it all, but it works!
;
LARGE_HEX_TO_ASCII:
		PUSH BX
		PUSH	CX
		XCHG	CX,DX
		MOV	BX,10
L1:
		CMP	CX,0
		JE	> L2
		XCHG	AX,CX
		XOR	DX,DX
		DIV	BX
		XCHG	AX,CX
		DIV	BX
		OR	DL,030
		MOV	[DI],DL
		DEC	DI
		JMP	L1
L2:
		XOR	DX,DX
		DIV	BX
		OR	DL,030
		MOV	[DI],DL
		DEC	DI
		CMP	AX,0
		JNE	L2
		INC	DI		; Back up pointer to first char
		POP	CX
		POP	BX
		RET
;
                end
