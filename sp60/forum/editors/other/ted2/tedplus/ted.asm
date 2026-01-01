;======================================================================
;  TED.ASM -- The Tiny EDitor.
;  PC Magazine * Tom Kihlken * tktktk
;----------------------------------------------------------------------
CSEG		SEGMENT
		ASSUME	CS:CSEG, DS:CSEG, ES:CSEG
		ORG	100H		;Beginning for .COM programs
START:
		JMP	BEGIN

;-----------------------------------------------------------------------
; Local data area
;-----------------------------------------------------------------------
TAB		EQU	9
CR		EQU	13
LF		EQU	10
LFCR		EQU	0A0DH

COPYRIGHT	DB	CR,LF,"TED 1.0 (c) 1988 Ziff Communications Co."
		DB	CR,LF,"PC Magazine ",254," Tom Kihlken$",1AH

FILE_TOO_BIG	DB	"File too big$"
READ_ERR_MESS	DB	"Read error$"
MEMORY_ERROR	DB	"Not enough memory$"

PROMPT_STRING	DB	"1ABORT",0,"2UNDO",0,"3PRINT",0
		DB	"4MARK",0,"5CUT",0,"6PASTE",0,"7EXIT",0
		DB	"8DEL EOL",0,"9FIND",0,"10UDEL L",0,0
PROMPT_LENGTH	=	$ - OFFSET PROMPT_STRING

SAVE_MESS	DB	"Save as: ",0
DOT_$$$		DB	".$$$",0
DOT_BAK		DB	".BAK",0
SRCH_PROMPT     DB      "SEARCH STRING> ",0
SRCH_MAX	DB	66
SRCH_SIZ	DB	0
SRCH_STR        DB      66 DUP (0)
SRCH_FLG	DB	0
SRCH_END	DW	0
SRCH_BASE	DW	0
SRCH_CLR	DB	244
KP_CR		DB	0
DIRTY_BITS	DB	1
ORGATR  	DB	0
NORMAL		DB	91
INVERSE		DB	33
LEFT_MARGIN	DB	0
MARGIN_COUNT	DB	0
INSERT_MODE	DB	-1
MARK_MODE	DB	0
ROWS		DB	23
SAVE_COLUMN	DB	0
SAVE_ROW	DB	0
LINE_FLAG	DB	0
EVEN
NAME_POINTER	DW	81H
NAME_END	DW	81H
STATUS_REG	DW	?
VIDEO_SEG	DW	0B000H
LINE_LENGTH	DW	0
UNDO_LENGTH	DW	0
CUR_POSN	DW	0
MARK_START	DW	0FFFFH
MARK_END	DW	0
MARK_HOME	DW	0
TOP_OF_SCREEN	DW	0
CURSOR		DW	0
LAST_CHAR	DW	0
COLUMNSB	LABEL	BYTE
COLUMNS		DW	?
PASTE_SEG	DW	?
PASTE_SIZE	DW	0
PAGE_PROC	DW	?
OLDINT24	DD	?
DISPATCH_TABLE	DW	OFFSET ABORT    ,OFFSET UNDO   ,OFFSET PRINT
		DW	OFFSET MARK    ,OFFSET CUT    ,OFFSET PASTE
		DW	OFFSET EXIT    ,OFFSET DEL_EOL,OFFSET FIND_STR
		DW	OFFSET UDEL_L  ,OFFSET BAD_KEY,OFFSET BAD_KEY
		DW	OFFSET HOME    ,OFFSET UP     ,OFFSET PGUP
		DW	OFFSET BAD_KEY ,OFFSET LEFT   ,OFFSET BAD_KEY
		DW	OFFSET RIGHT   ,OFFSET BAD_KEY,OFFSET ENDD
		DW	OFFSET DOWN    ,OFFSET PGDN   ,OFFSET INSERT
		DW	OFFSET DEL_CHAR

; The following machine instruction removes the desnow delay.  It is
; inserted into the code for EGA, VGA, and MONO displays.

NO_DESNOW = 0EBH + (OFFSET WRITE_IT - OFFSET HWAIT - 2) * 256

;-----------------------------------------------------------------------
; We start by initialize the display, then allocate memory for the file
; and paste segments.  Parse the command line for a filename, if one was
; input, read in the file.  Finally set the INT 23 and 24 vectors.
;-----------------------------------------------------------------------
BEGIN:
		XOR	AX,AX
		MOV	DS,AX		;Get a zero into DS
		ASSUME	DS:NOTHING
		MOV	AH,12H
		MOV	BL,10H		;Get EGA info
		INT	10H
		CMP	BL,10H		;Did BL change?
		JE	NOT_EGA		;If not, no EGA in system
		TEST	BYTE PTR DS:[0487H],8	;Is EGA active?
		JNZ	NOT_EGA
		MOV	WORD PTR CS:HWAIT,NO_DESNOW ;Get rid of desnow
		MOV	AX,DS:[0484H]	;Get number of rows
		DEC	AL		;Last row is for prompt line
	 	MOV	CS:[ROWS],AL	;Save the number of rows
NOT_EGA:
		MOV	AX,DS:[044AH]	;Get number of columns
		MOV	CS:COLUMNS,AX	;and store it
		MOV	AX,DS:[0463H]	;Address of display card
		ADD	AX,6		;Add six to get status port
		PUSH	CS
		POP	DS
		ASSUME	DS:CSEG
		MOV	STATUS_REG,AX
		CMP	AX,3BAH		;Is this a MONO display?
		JNE	COLOR		;If not, must be a CGA
		MOV	WORD PTR HWAIT,NO_DESNOW ;Get rid of desnow
		JMP	SHORT MOVE_STACK
COLOR:
		MOV	VIDEO_SEG,0B800H;Segment for color card
		XOR	BH,BH		;Use page zero
		MOV	AH,8		;Get current attribute
		INT	10H
		MOV	ORGATR,AH	;Save the original attribute
MOVE_STACK:
		MOV	BX,OFFSET NEW_STACK
		MOV	SP,BX		;Move the stack downward
		ADD	BX,15
		MOV	CL,4		;Convert program size to
		SHR	BX,CL		; paragraphs
		MOV	AH,4AH		;Deallocate unused memory
		INT	21H
		MOV	BX,1000H	;Request 64K for file segment
		MOV	AH,48H
		INT	21H
		MOV	ES,AX
		ASSUME	ES:FILE_SEG
		MOV	AH,48H
		INT	21H		;Request 64K for paste buffer
		JNC	GOT_ENOUGH	;If enough memory, continue
NOT_ENOUGH:
		MOV	DX,OFFSET MEMORY_ERROR
ERR_EXIT:
		PUSH	CS
		POP	DS
		MOV	AH,9		;Write the error message
		INT	21H		;DOS display service
		JMP	EXIT_TO_DOS	;Exit this program
GOT_ENOUGH:
		MOV	PASTE_SEG,AX	;Use this for the paste buffer
GET_FILENAME:
		MOV	SI,80H		;Point to parameters
		MOV	CL,[SI]		;Get number of characters
		XOR	CH,CH		;Make it a word
		INC	SI		;Point to first character
		PUSH	SI
		ADD	SI,CX		;Point to last character
		MOV	BYTE PTR [SI],0	;Make it an ASCII string
		MOV	NAME_END,SI	;Save pointer to last character
		POP	SI		;Get back pointer to filename
		CLD
		JCXZ	NO_FILENAME	;If no params, just exit
DEL_SPACES:	LODSB			;Get character into AL
		CMP	AL," "		;Is it a space?
		JNE	FOUND_LETTER
		LOOP	DEL_SPACES
FOUND_LETTER:
		DEC	SI		;Backup pointer to first letter
		MOV	NAME_POINTER,SI	;Save pointer to filename
		MOV	DX,SI
		MOV	AX,3D00H	;Setup to open file
		INT	21H
		JC	NO_FILENAME 	;If we can't open, must be new file
FILE_OPENED:
		PUSH	ES
		POP	DS		;DS has file segment also
		ASSUME	DS:FILE_SEG
		MOV	BX,AX		;Get the handle into BX
		XOR	DX,DX		;Point to file buffer
		MOV	AH,3FH		;Read service
		MOV	CX,0FFFEH	;Read almost 64K bytes
		INT	21H
		MOV	DI,AX		;Number of bytes read in
		JNC	NO_RD_ERR	;If no error, take jump
		MOV	DX,OFFSET READ_ERR_MESS
		JMP	SHORT ERR_EXIT
NO_RD_ERR:
		MOV	LAST_CHAR,DI	;Save the file size
		CMP	CX,AX		;Did the buffer fill?
		MOV	DX,OFFSET FILE_TOO_BIG
		JE	ERR_EXIT	;If yes, it is too big
		MOV	AH,3EH
		INT	21H		;Close the file
NO_FILENAME:
		PUSH	ES
		PUSH	ES		;Save file segment
		MOV	AX,3524H	;Get INT 24 vector
		INT	21H
		MOV	WORD PTR OLDINT24,BX  ;Store the offset
		MOV	WORD PTR OLDINT24+2,ES;And the segment

		PUSH	CS
		POP	DS
		MOV	DX,OFFSET NEWINT24    ;Point to new vector
		MOV	AX,2524H	;Now change INT 24 vector
		INT	21H	

		MOV	DX,OFFSET NEWINT23
		MOV	AX,2523H	;Set the INT 23 vector also
		INT	21H

		POP	ES		;Get back file segment
		POP	DS
		ASSUME	DS:FILE_SEG, ES:FILE_SEG
		CALL	REDO_PROMPT	;Draw the prompt line

;-----------------------------------------------------------------------
; Here's the main loop.  It updates the screen, then reads a keystroke.
;-----------------------------------------------------------------------
READ_A_KEY:
		CMP	MARK_MODE,0	;Is the mark state on?
		JE	MARK_OFF	;If not, skip this
		OR	DIRTY_BITS,4	;Refresh the current row
		MOV	DX,CUR_POSN
		CMP	SAVE_ROW,DH	;Are we on the save row?
		JE	SAME_ROW	;If yes, then redo the row only
		MOV	DIRTY_BITS,1	;Refresh the whole screen
SAME_ROW:
		MOV	AX,CURSOR	;Get cursor location
		MOV	BX,MARK_HOME	;Get the anchor mark position
		CMP	AX,BX		;Moving backward in file?
		JAE	S1
		MOV	MARK_START,AX	;Switch start and end position
		MOV	MARK_END,BX
		JMP	SHORT MARK_OFF
S1:
		MOV	MARK_END,AX	;Store start and end marks
		MOV	MARK_START,BX
MARK_OFF:
		MOV	DX,CUR_POSN
		MOV	SAVE_ROW,DH
		CALL	SET_CURSOR	;Position the cursor
		TEST	DIRTY_BITS,1	;Look at screen dirty bit
		JZ	SCREEN_OK	;If zero, screen is OK

		MOV	AH,1		;Get keyboard status
		INT	16H		;Any keys ready?
		JNZ	CURRENT_OK	;If yes, skip the update
		CALL	DISPLAY_SCREEN	;Redraw the screen
		MOV	DIRTY_BITS,0	;Mark screen as OK
SCREEN_OK:
		TEST	DIRTY_BITS,4	;Is the current line dirty?
		JZ	CURRENT_OK	;If not, take jump
		CALL	DISPLAY_CURRENT	;Redraw the current line
		MOV	DIRTY_BITS,0	;Mark screen as OK
CURRENT_OK:
		MOV	KP_CR,0
		MOV	AH,10H		;Read the next key
		INT	16H
		CMP	SRCH_FLG,0
		JE	CKEXT
		MOV	SRCH_FLG,0
		MOV	DIRTY_BITS,1
CKEXT:		CMP	AL,0		;Is this an extended code?
		JE	EXTENDED_CODE
		CMP	AL,0E0H		;Is this an extended code?
		JNE	DO_BAD
		CMP	AH,0
		JNE	EXTENDED_CODE
DO_BAD:
		CMP	AH,0EH		;Was it the backspace key?
		JE	BACK_SPACE
		CALL	INSERT_KEY	;Put this character in the file
		JMP	READ_A_KEY	;Get another key
BACK_SPACE:
		CMP	CURSOR,0	;At start of file?
		JE	BAD_KEY		;If at start, can't backspace
		CALL	LEFT		;Move left one space
		CALL	DEL_CHAR	;And delete the character
		JMP	READ_A_KEY
EXTENDED_CODE:
		MOV	AL,0
		CMP	AH,84H		;Is it control PgUp?
		JNE	NOT_TOP
		CALL	TOP
		JMP	READ_A_KEY
NOT_TOP:
		CMP	AH,76H		;Is it control PgDn?
		JNE	NOT_BOTTOM
		CALL	BOTTOM
		JMP	READ_A_KEY
BAD_KEY:
		MOV	AL,AH
		JMP	SHORT DO_BAD
NOT_BOTTOM:
		CMP	AH,66H		;Is it shift F9
		JNE	NOT_RPT
		CALL	FIND_STR
		JMP	READ_A_KEY
NOT_RPT:
		CMP	AH,73H		;Is it control left arrow?
		JE	SH_LEFT
		CMP	AH,74H		;Is it control right arrow?
		JE	SH_RIGHT
		CMP	AH,53H		;Skip high numbered keys
		JA	BAD_KEY
		XCHG	AH,AL
		SUB	AL,3BH		;Also skip low numbered keys
		JC	BAD_KEY
		SHL	AX,1		;Make the code an offset
		MOV	BX,AX		;Put offset in BX
		CALL	CS:DISPATCH_TABLE[BX] ;Call the key procedure
		JMP	READ_A_KEY	;Then read another key

;-----------------------------------------------------------------------
; These two routines shift the display right or left to allow editing
; files which contain lines longer than 80 columns.
;-----------------------------------------------------------------------
SH_RIGHT	PROC	NEAR
		CMP	LEFT_MARGIN,255 - 8 ;Past max allowable margin?
		JAE	NO_SHIFT	;Then can't move any more
		ADD	LEFT_MARGIN,8	;This moves the margin over
SH_RETURN:
		CALL	CURSOR_COL	;Compute column for cursor
		MOV	DX,CUR_POSN
		MOV	SAVE_COLUMN,DL	;Save the current column
		MOV	DIRTY_BITS,1	;Redraw the screen
NO_SHIFT:
		JMP	READ_A_KEY
SH_RIGHT	ENDP

SH_LEFT		PROC	NEAR
		CMP	LEFT_MARGIN,0	;At start of line already?
		JE	NO_SHIFT	;If yes, then don't shift
		SUB	LEFT_MARGIN,8	;Move the window over
		JMP	SH_RETURN
SH_LEFT		ENDP

;-----------------------------------------------------------------------
; This moves the cursor to the top of the file.
;-----------------------------------------------------------------------
TOP		PROC	NEAR
		XOR	AX,AX		;Get a zero into AX
		MOV	CURSOR,AX	;Cursor to start of file
		MOV	TOP_OF_SCREEN,AX
		MOV	LEFT_MARGIN,AL	;Move to far left margin
		MOV	DIRTY_BITS,1	;Redraw the screen
		MOV	CUR_POSN,AX	;Home the cursor
		MOV	SAVE_COLUMN,AL	;Save the cursor column
		RET
TOP		ENDP

;-----------------------------------------------------------------------
; This moves the cursor to the bottom of the file
;-----------------------------------------------------------------------
BOTTOM		PROC	NEAR
		MOV	DH,ROWS		;Get screen size
		MOV	SI,LAST_CHAR	;Point to last character
		DEC	SI
		MOV	LEFT_MARGIN,0	;Set window to start of line
		CALL	LOCATE		;Adjust the screen position
		CALL	HOME		;Move cursor to start of line
		MOV	DIRTY_BITS,1	;This will redraw the screen
		RET
BOTTOM		ENDP

;-----------------------------------------------------------------------
; Search for a string
;-----------------------------------------------------------------------
FIND_STR	PROC	NEAR
		PUSH	DS
		MOV	BX,CS
		MOV	DS,BX
		CMP	AH,66H		;Is it shift F9
		JE	RPT_FIND
		MOV	DH,ROWS
		INC	DH		;Last row on the screen
		XOR	DL,DL		;First column
		MOV	SI,OFFSET SRCH_PROMPT
		CALL	TTY_STRING	;Display search prompt
		MOV	DX, OFFSET SRCH_MAX
		MOV	AH,0Ah
		INT	21h		;Read input string
RPT_FIND:
		XOR	DX,DX
		MOV	DL, BYTE PTR SRCH_SIZ
		ADD	DX, OFFSET SRCH_STR
		MOV	DI,DX
		DEC	DI
		MOV	SRCH_END,DI
		XOR	DX,DX
		MOV	SI,CURSOR
		INC	SI
		MOV	SRCH_BASE,SI
S_REDO:		MOV	DI,OFFSET SRCH_STR
		MOV	BX,SRCH_BASE
S_CYCLE:	MOV	AL,[DI]
		MOV	AH,AL		;CONVERT AL TO OPPOSITE AND PUT IN AH
		CMP	AL,65
		JB	S_CMP
		CMP	AL,90
		JA	TSTLO
		XOR	AH,20H
		JMP	SHORT S_CMP
TSTLO:		CMP	AL,97
		JB	S_CMP
		XOR	AH,20H
S_CMP:		CMP	BX,LAST_CHAR
		JA	END_MCH
		CMP	AL,ES:[BX]
		JE	S_MCH
		CMP	AH,ES:[BX]
		JE	S_MCH
		CMP	DI,OFFSET SRCH_STR
		JNE	S_REDO
		INC	BX
		CMP	WORD PTR ES:[BX]-1,LFCR
		JNE	S_BX1
		INC	DL
S_BX1:		JMP	SHORT S_CMP
		
S_MCH:		INC	BX
		CMP	DI,OFFSET SRCH_STR
		JNE	NO_BSE
		MOV	SRCH_BASE,BX
NO_BSE:		ADD	DH,DL
		XOR	DL,DL
		CMP	DI,SRCH_END
		JE	YEA_MCH
		INC	DI
		JMP	SHORT S_CYCLE
YEA_MCH:	
		MOV	SRCH_FLG,1
		MOV	SI,SRCH_BASE
		DEC	SI
		MOV	SRCH_BASE,SI
		MOV	CURSOR,SI
		XOR	BX,BX
		MOV	BL,BYTE PTR SRCH_SIZ
		ADD	BX,SI
		MOV	SRCH_END,BX
		XOR	DL,DL
		ADD	DX,CUR_POSN
		CMP	DH,ROWS
		JBE	NEW_S
		XOR	DX,DX
NEW_S:		POP	DS
		CALL	LOCATE
		MOV	DIRTY_BITS,1	;This will redraw the screen
		CALL	REDO_PROMPT
		RET
END_MCH:		
		POP	DS
		CALL	REDO_PROMPT
		RET
FIND_STR	ENDP

;-----------------------------------------------------------------------
; This deletes from the cursor position to the end of line.
;-----------------------------------------------------------------------
DEL_EOL		PROC	NEAR
		MOV	CX,CUR_POSN
		OR	CL,CL		;At first column?
		JZ	DEL_L		;If yes, then do line delete function
		MOV	LINE_FLAG,0
		PUSH	CURSOR		;Save starting cursor location
		CALL	ENDD		;Move the the end of line
		POP	SI		;Get back starting cursor
		MOV	CX,CURSOR	;Offset of the end of line
		MOV	CURSOR,SI	;Restore starting cursor
		JMP	DEL_END		;Delete characters to end
DEL_EOL		ENDP


;-----------------------------------------------------------------------
; This deletes a line, placing it in the line buffer.
;-----------------------------------------------------------------------
DEL_L		PROC	NEAR
		MOV	LINE_FLAG,1
		CALL	FIND_START	;Find start of this line
		MOV	CURSOR,SI	;This will be the new cursor
		PUSH	SI		;Save the cursor position
		CALL	FIND_NEXT	;Find the next line
		MOV	CX,SI		;CX will hold line length
		POP	SI		;Get back new cursor location
DEL_END:
		SUB	CX,SI		;Number of bytes on line
		OR	CH,CH		;Is line too long to fit
		JZ	NOT_TOO_LONG
		MOV	CX,100H		;Only save 256 characters
NOT_TOO_LONG:
		MOV	LINE_LENGTH,CX	;Store length of deleted line
		JCXZ	NO_DEL_L
		MOV	DI,OFFSET LINE_BUFFER ;Buffer for deleted line

		PUSH	CX
		PUSH	ES
		PUSH	CS
		POP	ES		;Line buffer is in CSEG
		REP	MOVSB		;Put deleted line in buffer
		POP	ES		;Get back file segment
		POP	AX

		MOV	CX,LAST_CHAR	;Get the file size
		SUB	LAST_CHAR,AX	;Subtract the deleted line
		MOV	SI,CURSOR	;Get new cursor location
		MOV	DI,SI
		ADD	SI,AX		;SI points to end of file
		SUB	CX,SI		;Length of remaining file
		JCXZ	NO_DEL_L
		REP	MOVSB		;Shift remainder of file up
NO_DEL_L:
		MOV	DX,CUR_POSN	;Get cursor row/column
		MOV	SI,CURSOR	;Get cursor offset
		CALL	LOCATE		;Adjust the screen position
		MOV	DIRTY_BITS,1	;Redraw the screen
		RET
DEL_L		ENDP

;-----------------------------------------------------------------------
; This undeletes a line by copying it from the line buffer into the file
;-----------------------------------------------------------------------
UDEL_L		PROC	NEAR
		CMP	LINE_FLAG,0	;Is this an end of line only?
		JE	UDEL_EOL	;If yes, don't home the cursor
		CALL	HOME		;Move cursor to home
UDEL_EOL:
		MOV	AX,LINE_LENGTH	;Length of deleted line
		MOV	SI,OFFSET LINE_BUFFER
		JMP	INSERT_STRING
UDEL_L		ENDP

;-----------------------------------------------------------------------
; These routines move the cursor left and right.
;-----------------------------------------------------------------------
LEFT		PROC	NEAR
		CMP	CURSOR,0	;At start of file?
		JZ	LR_NO_CHANGE	;Then can't move left
		MOV	DX,CUR_POSN
		OR	DL,DL		;At first column?
		JZ	MOVE_UP		;If yes, then move up one
		DEC	CURSOR		;Shift the cursor offset
LR_RETURN:
		CALL	CURSOR_COL	;Compute column for cursor
		MOV	SAVE_COLUMN,DL	;Save the cursor column
LR_NO_CHANGE:
		MOV	UNDO_LENGTH,0
		RET
MOVE_UP:
		CALL	UP		;Move up to next row
		JMP	SHORT ENDD	;And move to end of line
LEFT		ENDP

RIGHT		PROC	NEAR
		MOV	SI,CURSOR
		CMP	SI,LAST_CHAR	;At end of file?
		JE	LR_NO_CHANGE	;If yes, then can't move
		CMP	BYTE PTR [SI],CR;If CR
		JNE	INC_RIGHT	;If yes, then test LF
		INC	SI
		CMP	SI,LAST_CHAR	;At end of file?
		DEC	SI
		JE	INC_RIGHT	;If yes, then increment
		CMP	BYTE PTR [SI+1],LF;If LF
		JE	MOVE_DOWN	;If yes, then move to next line
INC_RIGHT:
		INC	CURSOR		;Advance the cursor
		JMP	LR_RETURN
MOVE_DOWN:
		CALL	HOME		;Move to start of line
		JMP	DOWN		;And move down one row
RIGHT		ENDP

;-----------------------------------------------------------------------
; This moves the cursor to the start of the current line.
;-----------------------------------------------------------------------
HOME		PROC	NEAR
		CALL	FIND_START	;Find start of line
		MOV	CURSOR,SI	;Save the new cursor
		MOV	SAVE_COLUMN,0	;Save the cursor column
		MOV	BYTE PTR CUR_POSN,0 ;Store column number
		RET
HOME		ENDP

;-----------------------------------------------------------------------
; This moves the cursor to the end of the current line
;-----------------------------------------------------------------------
ENDD		PROC	NEAR
		MOV	SI,CURSOR
		CALL	FIND_EOL	;Find end of this line
		MOV	CURSOR,SI	;Store the new cursor
		CALL	CURSOR_COL	;Compute the correct column
		MOV	SAVE_COLUMN,DL	;Save the cursor column
		RET
ENDD		ENDP

;-----------------------------------------------------------------------
; This moves the cursor up one row.  If the cursor is at the first row,
; the screen is scrolled down.
;-----------------------------------------------------------------------
UP		PROC	NEAR
		MOV	UNDO_LENGTH,0
		MOV	DX,CUR_POSN
		MOV	SI,CURSOR
		OR	DH,DH		;At top row already?
		JZ	SCREEN_DN	;If yes, then scroll down
		DEC	DH		;Move cursor up one row
		CALL	FIND_CR		;Find the beginning of this row
		MOV	CURSOR,SI
		CALL	FIND_START	;Find start of this row
		MOV	CURSOR,SI
		CALL	SHIFT_RIGHT	;Skip over to current column
AT_TOP:
		RET
SCREEN_DN:
		MOV	SI,TOP_OF_SCREEN
		OR	SI,SI		;At start of file?
		JZ	AT_TOP		;If at top, then do nothing
		CALL	FIND_PREVIOUS	;Find the preceeding line
		MOV	TOP_OF_SCREEN,SI;Save new top of screen
		MOV	SI,CURSOR
		CALL	FIND_PREVIOUS	;Find the preceeding line
		MOV	CURSOR,SI	;This is the new cursor
SHIFT_RET:
		MOV	DIRTY_BITS,1	;Need to redraw screen
		MOV	SI,CURSOR
		MOV	DX,CUR_POSN
		JMP	SHIFT_RIGHT	;Move cursor to current column
UP		ENDP

;-----------------------------------------------------------------------
; This moves the cursor down one row.  When the last row is reached,
; the screen is shifted up one row.
;-----------------------------------------------------------------------
DOWN		PROC	NEAR
		MOV	UNDO_LENGTH,0
		MOV	DX,CUR_POSN
		CMP	DH,ROWS		;At bottom row already?
		MOV	SI,CURSOR	;Get position in file
		JE	SCREEN_UP	;If at bottom, then scroll up
		CALL	FIND_NEXT	;Find the start of next line
		JC	DOWN_RET	;If no more lines, then return
		MOV	CURSOR,SI
		INC	DH		;Advance cursor to next row
		CALL	SHIFT_RIGHT	;Move cursor to current column
DOWN_RET:
		RET
SCREEN_UP:
		CMP	SI,LAST_CHAR	;Get cursor offset
		JE	DOWN_RET
		CALL	FIND_START	;Find the start of this line
		MOV	CURSOR,SI	;This is the new cursor
		CALL	FIND_NEXT	;Find the offset of next line
		JC	SHIFT_RET	;If no more lines then return
		MOV	CURSOR,SI	;This is the new cursor
		MOV	SI,TOP_OF_SCREEN;Get the start of the top row
		CALL	FIND_NEXT	;And find the next line
		MOV	TOP_OF_SCREEN,SI;Store the new top of screen
		JMP	SHIFT_RET
DOWN		ENDP

;-----------------------------------------------------------------------
; These two routines move the screen one page at a time by calling the
; UP and DOWN procedures.
;-----------------------------------------------------------------------
PGDN		PROC	NEAR
		MOV	PAGE_PROC,OFFSET DOWN
PAGE_UP_DN:
		MOV	CL,ROWS		;Get length of the screen
		SUB	CL,5		;Don't page a full screen
		XOR	CH,CH		;Make it a word
PAGE_LOOP:
		PUSH	CX
		CALL	PAGE_PROC	;Move the cursor down
		POP	CX
		LOOP	PAGE_LOOP	;Loop for one page length
		RET
PGDN		ENDP

PGUP		PROC	NEAR
		MOV	PAGE_PROC,OFFSET UP
		JMP	PAGE_UP_DN
PGUP		ENDP

;-----------------------------------------------------------------------
; This toggles the insert/overstrike mode.
;-----------------------------------------------------------------------
INSERT		PROC	NEAR
		NOT	INSERT_MODE	;Toggle the switch
		JMP	REDO_PROMPT	;Redraw the insert status
INSERT		ENDP

;-----------------------------------------------------------------------
; This deletes the character at the cursor by shifting the remaining 
; characters forward.
;-----------------------------------------------------------------------
DEL_CHAR	PROC	NEAR
		MOV	CX,LAST_CHAR
		MOV	SI,CURSOR
		MOV	DI,SI
		CMP	SI,CX		;Are we at end of file?
		JAE	NO_DEL		;If yes, then don't delete
		LODSB
		CALL	SAVE_CHAR	;Save it for UNDO function
		MOV	AH,[SI]		;Look at the next character also
		PUSH	AX		;Save character were deleting
		DEC	LAST_CHAR	;Shorten the file by one
		SUB	CX,SI
		REP	MOVSB		;Move file down one notch

		POP	AX		;Get back character we deleted
		CMP	AL,CR		;Did we delete a CR?
		JE	COMBINE
		OR	DIRTY_BITS,4	;Current line is dirty
NO_DEL:
		RET
COMBINE:
		CMP	AH,LF		;Was the next character a LF?
		JNE	NO_DEL_LF
		CALL	DEL_CHAR	;Now delete the line feed
NO_DEL_LF:
		CALL	DISPLAY_BOTTOM	;Repaint bottom of the screen
		MOV	DX,CUR_POSN
		MOV	SAVE_COLUMN,DL	;Save the cursor column
		RET
DEL_CHAR	ENDP

;-----------------------------------------------------------------------
; This toggles the mark state and resets the paste buffer pointers.
;-----------------------------------------------------------------------
MARK		PROC	NEAR
		XOR	AX,AX
		NOT	MARK_MODE	;Toggle the mode flag
		CMP	MARK_MODE,AL	;Turning mode ON?
		JNE	MARK_ON
		MOV	DIRTY_BITS,1	;Need to redraw the screen
		MOV	MARK_START,0FFFFH
		JMP	SHORT MARK_RET
MARK_ON:
		MOV	AX,CURSOR	;Get the cursor offset
		MOV	MARK_START,AX	;Start of marked range
MARK_RET:
		MOV	MARK_END,  AX	;End of marked range
		MOV	MARK_HOME, AX	;Center of marked range
		RET
MARK		ENDP

;-----------------------------------------------------------------------
; This removes the marked text and places it in the paste buffer
;-----------------------------------------------------------------------
CUT		PROC	NEAR
		CMP	MARK_MODE,0	;Is the mark mode on?
		JE	NO_MARK		;If not, then do nothing
		MOV	CX,MARK_END	;Get end of mark region
		MOV	SI,MARK_START	;Get start of mark region
		SUB	CX,SI		;Number of bytes selected
		MOV	PASTE_SIZE,CX
		JCXZ	NO_MARK
		XOR	DI,DI		;Point to paste bufferf

		PUSH	CX
		PUSH	ES
		MOV	ES,PASTE_SEG	;Get the paste segment
		REP	MOVSB		;Put deleted text in buffer
		POP	ES
		POP	AX

		MOV	CX,LAST_CHAR
		SUB	LAST_CHAR,AX	;Shorten the file this much
		MOV	DI,MARK_START
		MOV	SI,MARK_END
		SUB	CX,SI
		JCXZ	NO_DELETE
		REP	MOVSB		;Shorten the file
NO_DELETE:
		MOV	DX,CUR_POSN
		MOV	SI,MARK_START
		CALL	LOCATE		;Adjust the screen position
		CALL	MARK		;This turns off select
NO_MARK:
		RET
CUT		ENDP

;-----------------------------------------------------------------------
; This copies the paste buffer into the file at the cursor location
;-----------------------------------------------------------------------
PASTE		PROC	NEAR
		MOV	AX,PASTE_SIZE	;Number of characters in buffer
		OR	AX,AX		;Any there?
		JZ	NO_PASTE	;If not, nothing to paste
		MOV	SI,CURSOR	;Get cursor location
		PUSH	AX
		PUSH	SI
		CALL	OPEN_SPACE	;Make room for new characters
		POP	DI
		POP	CX
		JC	NO_PASTE	;If no room, just exit
		XOR	SI,SI		;Point to paste buffer
		PUSH	DS
		MOV	DS,PASTE_SEG	;Segment of paste buffer
		REP	MOVSB		;Copy in the new characters
		POP	DS
		MOV	SI,DI
		MOV	CURSOR,SI	;Cursor moved to end of insert
		MOV	DX,CUR_POSN	;Get current cursor row
		CALL	LOCATE		;Adjust the screen position
		MOV	DIRTY_BITS,1	;Redraw the screen
NO_PASTE:
		RET
PASTE		ENDP

;-----------------------------------------------------------------------
; This prints the marked text.  If printer fails, it is canceled.
;-----------------------------------------------------------------------
PRINT		PROC	NEAR
		CMP	MARK_MODE,0	;Is mark mode on?
		JE	PRINT_RET	;If not, nothing to print
		MOV	CX,MARK_END	;End of marked region
		MOV	SI,MARK_START	;Start of marked region
		SUB	CX,SI		;Number of bytes selected
		JCXZ	PRINT_DONE	;If nothing to print, return

		MOV	AH,2
		XOR	DX,DX		;Select printer 0
		INT	17H		;Get printer status
		TEST	AH,10000000B	;Is busy bit set?
		JZ	PRINT_DONE
		TEST	AH,00100000B	;Is printer out of paper?
		JNZ	PRINT_DONE
PRINT_LOOP:
		LODSB
		XOR	AH,AH
		INT	17H		;Print the character
		ROR	AH,1		;Check time out bit
		JC	PRINT_DONE	;If set, quit printing
		LOOP	PRINT_LOOP
		MOV	AL,CR
		XOR	AH,0
		INT	17H		;Finish with a CR
PRINT_DONE:
		CALL	MARK		;Turn off the mark state
PRINT_RET:
		RET
PRINT		ENDP

;-----------------------------------------------------------------------
; This command restores any characters which have recently been deleted.
;-----------------------------------------------------------------------
UNDO		PROC	NEAR
		XOR	AX,AX
		XCHG	AX,UNDO_LENGTH	;Get buffer length
		MOV	SI,OFFSET UNDO_BUFFER
		JMP	INSERT_STRING
UNDO		ENDP

;-----------------------------------------------------------------------
; This inserts AX characters from CS:SI into the file.
;-----------------------------------------------------------------------
INSERT_STRING	PROC	NEAR
		PUSH	SI		;Save string buffer
		MOV	SI,CURSOR	;Get cursor offset
		PUSH	AX		;Save length of string
		PUSH	SI
		CALL	OPEN_SPACE	;Make space to insert string
		POP	DI		;Get back cursor position
		POP	CX		;Get back string length
		POP	SI		;Get back string buffer
		JC	NO_SPACE	;If no space available, exit

		PUSH	DS
		PUSH	CS
		POP	DS
		ASSUME	DS:CSEG
		REP	MOVSB		;Copy the characters in
		MOV	SI,CURSOR	;Get the new cursor offset
		MOV	DX,CUR_POSN	;Also get the current row
		MOV	DIRTY_BITS,1	;And redraw the screen
		POP	DS
		ASSUME	DS:NOTHING
		CALL	LOCATE		;Adjust the screen position
NO_SPACE:
		RET
INSERT_STRING	ENDP

;-----------------------------------------------------------------------
; This adds a character to the undo buffer.
;-----------------------------------------------------------------------
SAVE_CHAR	PROC	NEAR
		MOV	BX,UNDO_LENGTH
		OR	BH,BH		;Is buffer filled?
		JNZ	NO_SAVE
		INC	UNDO_LENGTH
		MOV	BYTE PTR CS:UNDO_BUFFER[BX],AL
NO_SAVE:
		RET
SAVE_CHAR	ENDP

;-----------------------------------------------------------------------
; This prompts for a verify keystroke then exits without saving the file
;-----------------------------------------------------------------------
ABORT		PROC	NEAR
		ASSUME	DS:CSEG
		PUSH	CS
		POP	DS
		MOV	DH,ROWS		;Last row on display
		INC	DH		;Bottom row of screen
		XOR	DL,DL		;First column
FINISHED:
		MOV     AH,ORGATR
		MOV	NORMAL,AH	;Go back to black and white
		MOV	DH,ROWS		;Move to last row on screen
		XOR	DL,DL		;And column zero
		CALL	SET_CURSOR
		INC	DH
		CALL	ERASE_EOL	;Erase the last row
EXIT_TO_DOS:
		PUSH	CS
		POP	DS		;Point to code segment
		MOV	AX,4C00H
		INT	21H

ABORT		ENDP

;-----------------------------------------------------------------------
; This prompts for a filename then writes the file.  The original file
; is renamed to filename.BAK.  If an invalid filename is entered, the 
; speaker is beeped.
;-----------------------------------------------------------------------
EXIT		PROC	NEAR

		PUSH	DS
		PUSH	ES
		MOV	AX,CS
		MOV	DS,AX
		MOV	ES,AX
		ASSUME	DS:CSEG, ES:CSEG
NEXT_LETTER:
		MOV	DH,ROWS
		INC	DH		;Last row on the screen
		XOR	DL,DL		;First column
		MOV	SI,OFFSET SAVE_MESS
		PUSH	DX
		CALL	TTY_STRING	;Display a prompt
		POP	DX
		ADD	DL,9		;Move right 9 spaces
		MOV	SI,NAME_POINTER
		CALL	TTY_STRING	;Display the filename

		XOR	AH,AH		;Read the next key
		INT	16H
		MOV	DI,NAME_END	;This points to last letter
		OR	AL,AL		;Is it a real character?
		JZ	NEXT_LETTER	;Ignore special keys
		CMP	AL,27		;Is it escape?
		JNE	NOT_ESCAPE

		MOV	DIRTY_BITS,1	;Redraw the screen
		POP	ES		;Get back file segments
		POP	DS
		JMP	REDO_PROMPT	;Redraw the prompt
NOT_ESCAPE:
		CMP	AL,CR		;Is it CR?
		JE	GOT_NAME
		CMP	AL,8		;Is it a backspace?
		JNE	NORMAL_LETTER
		CMP	DI,NAME_POINTER	;At first letter?
		JLE	NEXT_LETTER	;If yes, dont erase it
		MOV	BYTE PTR [DI-1],0
		DEC	NAME_END
		JMP	NEXT_LETTER
NORMAL_LETTER:
		CMP	DI,81H + 65	;Too many letters?
		JG	NEXT_LETTER	;If yes, ignore them
		XOR	AH,AH
		STOSW			;Store the new letter
		INC	NAME_END	;Name is one character longer
		JMP	NEXT_LETTER	;Read another keystroke
GOT_NAME:
		MOV	DX,NAME_POINTER	;Point to the filename
		MOV	AX,4300H	;Get the files attribute
		INT	21H
		JNC	NAME_OK		;If no error, filename is OK
		CMP	AX,3		;Was it path not found error?
		JE	BAD_NAME	;If yes, filename was bad
NAME_OK:
		MOV	SI,OFFSET DOT_$$$	;Point to the ".$$$"
		MOV	DI,OFFSET NAME_DOT_$$$
		CALL	CHG_EXTENSION		;Add the new extension

		MOV	DX,OFFSET NAME_DOT_$$$	;Point to the temp filename
		MOV	AH,3CH			;Function to create file
		MOV	CX,0020H		;Attribute for new file
		INT	21H			;Try to create the file
		JNC	NAME_WAS_OK		;Continue if name was OK
BAD_NAME:
		MOV	AX,0E07H	;Write a bell character
		INT	10H		;BIOS tty service
		JMP	NEXT_LETTER	;Get another letter
WRITE_ERROR:
		MOV	AH,3EH		;Close the file
		INT	21H
		JMP	BAD_NAME	;Filename must be bad
NAME_WAS_OK:
		XOR	DX,DX		;This is the file buffer
		MOV	CX,LAST_CHAR	;Number of chars in file
		MOV	DI,CX
		MOV	BX,AX		;This is the handle
		MOV	AH,40H		;Write to the file
		POP	DS		;Recover buffer segment
		INT	21H		;Write the buffer contents
		POP	DS
		JC	WRITE_ERROR	;Exit on a write error
		CMP	AX,CX		;Was entire file written?
		JNE	WRITE_ERROR	;If not, exit

		PUSH	CS
		POP	DS		;Get the code segment
		MOV	AH,3EH
		INT	21H			;Close the temp file
		MOV	SI,OFFSET DOT_BAK	;Point to the ".BAK"
		MOV	DI,OFFSET NAME_DOT_BAK
		CALL	CHG_EXTENSION		;Make the backup filename

		MOV	DX,OFFSET NAME_DOT_BAK	;Point to the backup name
		MOV	AH,41H
		INT	21H			;Delete existing backup file
		MOV	DI,OFFSET NAME_DOT_BAK
		MOV	DX,NAME_POINTER
		MOV	AH,56H
		INT	21H

		MOV	DI,NAME_POINTER	;Point to new filename
		MOV	DX,OFFSET NAME_DOT_$$$ ;Point to temporary file
		MOV	AH,56H		;Rename temp to new file
		INT	21H		;DOS function to rename
		POP	AX		;Restore the stack
		POP	AX
		JMP	FINISHED
EXIT		ENDP

;-----------------------------------------------------------------------
; This subroutine displays a character by writing directly
; to the screen buffer.  To avoid screen noise (snow) on the color
; card, the horizontal retrace has to be monitored.
;-----------------------------------------------------------------------
WRITE_INVERSE	PROC	NEAR
		ASSUME	DS:FILE_SEG, ES:FILE_SEG
		MOV	BH,INVERSE	;Attribute for inverse video
		JMP	SHORT WRITE_SCREEN
WRITE_NORMAL:
		MOV	BH,NORMAL	;Attribute for normal video
		JMP	SHORT WRITE_SCREEN
WRITE_FIND:
		MOV	BH,SRCH_CLR	;Attribute for find string
WRITE_SCREEN:
		MOV	BL,AL		;Save the character
		PUSH	ES
		MOV	DX,STATUS_REG 	;Retrieve status register
		MOV	ES,VIDEO_SEG	;Get segment of video buffer
HWAIT:
		IN	AL,DX		;Get video status
		ROR	AL,1		;Look at horizontal retrace
		JNC	HWAIT		;Wait for retrace
WRITE_IT:
		MOV	AX,BX		;Get the character/attribute
		STOSW			;Write the character
		POP	ES
		RET
WRITE_INVERSE	ENDP

;-----------------------------------------------------------------------
; This moves the cursor to the row/column in DX.
;-----------------------------------------------------------------------
SET_CURSOR	PROC	NEAR
		XOR	BH,BH		;Were using page zero
		MOV	AH,2		;BIOS set cursor function
		INT	10H
		RET
SET_CURSOR	ENDP

;-----------------------------------------------------------------------
; This computes the video buffer offset for the row/column in DX
;----------------------------------------------------------------------
POSITION	PROC	NEAR
		MOV	AX,COLUMNS	;Take columns per row
		MUL	DH		;Times row number
		XOR	DH,DH
		ADD	AX,DX		;Add in the column number
		SHL	AX,1		;Times 2 for offset
		MOV	DI,AX		;Return result in DI
		RET
POSITION	ENDP

;-----------------------------------------------------------------------
; This erases from the location in DX to the right edge of the screen
;-----------------------------------------------------------------------
ERASE_EOL	PROC	NEAR
		CALL	POSITION	;Find screen offset
		MOV	CX,COLUMNS	;Get screen size
		SUB	CL,DL		;Subtract current position
		JCXZ	NO_CLEAR
ERASE_LOOP:
		MOV	AL," "		;Write blanks to erase
		CALL	WRITE_NORMAL	;Display it
		LOOP	ERASE_LOOP
NO_CLEAR:	RET
ERASE_EOL	ENDP

;-----------------------------------------------------------------------
; This displays the function key prompt and insert mode state
;-----------------------------------------------------------------------
REDO_PROMPT	PROC	NEAR
		ASSUME	DS:NOTHING, ES:NOTHING
		PUSH	DS
		PUSH	CS
		POP	DS
		ASSUME	DS:CSEG
		MOV	DH,ROWS		;Put prompt at last row
		INC	DH
		XOR	DL,DL		;And column 0
		CALL	POSITION	;Convert to screen offset
		MOV	SI,OFFSET PROMPT_STRING
KEY_LOOP:
		MOV	AL,"F"		;Display an "F"
		CALL	WRITE_NORMAL
		LODSB
		OR	AL,AL		;Last key in prompt?
		JZ	PROMPT_DONE
		CALL	WRITE_NORMAL

		CMP	BYTE PTR CS:[SI],"0"	;Is it F10?
		JNE	TEXT_LOOP
		LODSB
		CALL	WRITE_NORMAL
TEXT_LOOP:
		LODSB
		OR	AL,AL		;Last letter in word?
		JNZ	WRITE_CHAR

		MOV	AL," "		;Display a space
		CALL	WRITE_NORMAL
		JMP	KEY_LOOP
WRITE_CHAR:
		CALL	WRITE_INVERSE	;Display the letter
		JMP	TEXT_LOOP	;Do the next letter
PROMPT_DONE:
		MOV	DH,ROWS
		INC	DH		;Get to last row on screen
		MOV	DL,PROMPT_LENGTH + 9
		CALL	ERASE_EOL	;Erase to the end of this row
		MOV	AL,"O"		;Write an "O"
		CMP	INSERT_MODE,0	;In insert mode?
		JE	OVERSTRIKE
		MOV	AL,"I"		;Write an "I"
OVERSTRIKE:
		DEC	DI		;Backup one character position
		DEC	DI
		CALL	WRITE_NORMAL
		POP	DS
		RET
REDO_PROMPT	ENDP

;-----------------------------------------------------------------------
; This displays the file buffer on the screen.
;-----------------------------------------------------------------------
DISPLAY_SCREEN	PROC	NEAR
		ASSUME	DS:FILE_SEG, ES:FILE_SEG
		MOV	SI,TOP_OF_SCREEN;Point to first char on screen
		XOR	DH,DH		;Start at first row
		JMP	SHORT NEXT_ROW
DISPLAY_BOTTOM:				;This redraws the bottom only
		CALL	FIND_START	;Find first character on this row
		MOV	DX,CUR_POSN	;Get current cursor row
NEXT_ROW:
		PUSH	DX
		CALL	DISPLAY_LINE	;Display a line
		POP	DX
		INC	DH		;Move to the next row
		CMP	DH,ROWS		;At end of screen yet?
		JBE	NEXT_ROW	;Do all the rows
		RET
DISPLAY_SCREEN	ENDP

;-----------------------------------------------------------------------
; This subroutine displays a single line to the screen. DH holds the 
; row number, SI has the offset into the file buffer. Tabs are expanded.
; Adjustment is made for side shift.
;-----------------------------------------------------------------------
DISPLAY_CURRENT	PROC	NEAR
		CALL	FIND_START
		MOV	DX,CUR_POSN
DISPLAY_LINE:
		XOR	DL,DL		;Start at column zero
		MOV	MARGIN_COUNT,DL
		MOV	CX,DX		;Use CL to count the columns
		CALL	POSITION	;Compute offset into video
NEXT_CHAR:
		CMP	SI,LAST_CHAR	;At end of file?
		JAE	LINE_DONE
		LODSB			;Get next character
		CMP	AL,CR		;Is it a carriage return?
		JE	FOUND_CR	;Quit when a CR is found
		CMP	AL,TAB		;Is this a Tab character
		JE	EXPAND_TAB	;If yes, expand to spaces
DO_PUT:
		CALL	PUT_CHAR	;Put character onto screen
TAB_DONE:
		CMP	CL,COLUMNSB	;At right edge of screen?
		JB	NEXT_CHAR
LN_OVF:		CMP	BYTE PTR [SI],CR
		JNE	DO_DIA
		INC     SI
		CMP	SI,LAST_CHAR	;At end of file?
		JAE	NOT_BEYOUND
		CMP	BYTE PTR [SI],LF;Is this the end of the line?
		DEC	SI
		JE	NOT_BEYOUND
DO_DIA:		DEC	DI		;Backup one character
		DEC	DI
		MOV	AL,4		;Show a diamond
		CALL	WRITE_INVERSE	;In inverse video
NOT_BEYOUND:
		JMP	FIND_NEXT	;Find start of next line
FOUND_CR:
		LODSB			;Look at the next character
		CMP	AL,LF		;Is it a line feed?
		JE	LINE_DONE
		MOV	AL,CR
		DEC	SI
		JMP	SHORT DO_PUT
LINE_DONE:
		MOV	DX,CX
		JMP	ERASE_EOL	;Erase the rest of the line
EXPAND_TAB:
		MOV	AL," "		;Convert Tabs to spaces
		CALL	PUT_CHAR
		MOV	AL,MARGIN_COUNT
		ADD	AL,CL
		TEST	AL,00000111B	;At even multiple of eight?
		JNZ	EXPAND_TAB	;If not keep adding spaces
		JMP	TAB_DONE
DISPLAY_CURRENT	ENDP

;-----------------------------------------------------------------------
; This displays a single character to the screen.  If the character is 
; marked, it is shown in inverse video.  Characters outside the current
; margin are not displayed. Characters left of the margin are skipped.
;-----------------------------------------------------------------------
PUT_CHAR	PROC	NEAR
		MOV	BL,MARGIN_COUNT	;Get distance to left margin
		CMP	BL,LEFT_MARGIN	;Are we inside left margin?
		JAE	IN_WINDOW	;If yes, show the character
		INC	BL
		MOV	MARGIN_COUNT,BL
		RET
IN_WINDOW:	CMP	SRCH_FLG,0
		JE	CKM
		CMP	SI,SRCH_BASE
		JBE	CKM
		CMP	SI,SRCH_END
		JA	CKM
		CALL	WRITE_FIND
		JMP	SHORT NEXT_COL
CKM:
		CMP	SI,MARK_START	;Is this character marked?
		JBE	NOT_MARKED
		CMP	SI,MARK_END
		JA	NOT_MARKED
		CALL	WRITE_INVERSE	;Marked characters shown inverse
		JMP	SHORT NEXT_COL
NOT_MARKED:
		CALL	WRITE_NORMAL
NEXT_COL:
		INC	CL		;Increment the column count
		RET
PUT_CHAR	ENDP

;-----------------------------------------------------------------------
; This routine adds a character into the file.  In insert mode, remaining
; characters are pushed forward. If a CR is inserted, a LF is added also.
;-----------------------------------------------------------------------
INSERT_KEY	PROC	NEAR
		MOV	SI,CURSOR
		CMP	AL,CR		;Was this a carriage return
		JNE	CK_INS
		CMP	AH,1CH
		JE	NEW_LINE
CK_INS:
		MOV	SI,CURSOR
		CMP	INSERT_MODE,0	;In insert mode?
		JNE	INSERT_CHAR
		CMP	SI,LAST_CHAR	;At end of file?
		JE	INSERT_CHAR
		CMP	BYTE PTR [SI],CR
		INC	SI
		CMP	SI,LAST_CHAR	;At end of file?
		DEC	SI
		JE	INSERT_CHAR
		CMP	BYTE PTR [SI+1],LF;At end of line?
		JE	INSERT_CHAR
		MOV	DI,SI
		XCHG	DS:[SI],AL	;Switch new character for old one
		CALL	SAVE_CHAR	;Store the old character
		JMP	SHORT ADVANCE
INSERT_CHAR:
		PUSH	SI
		PUSH	AX		;Save the new character
		MOV	AX,1
		CALL	OPEN_SPACE	;Make room for it
		POP	AX		;Get back the new character
		POP	DI
		JC	FILE_FULL
		STOSB			;Insert character in file buffer
ADVANCE:
		OR	DIRTY_BITS,4	;Current line is dirty
		PUSH	UNDO_LENGTH
		CALL	RIGHT		;Move cursor to next letter
		POP	UNDO_LENGTH
FILE_FULL:
		RET
NEW_LINE:
		PUSH	SI
		MOV	AX,2
		CALL	OPEN_SPACE	;Make space for CR and LF
		POP	DI		;Get back old cursor location
		JC	FILE_FULL
		MOV	AX,LF*256+CR
		STOSW			;Store the CR and LF
		CALL	DISPLAY_BOTTOM	;Repaint bottom of the screen
		CALL	HOME		;Cursor to start of line
		JMP	DOWN		;Move down to the new line
INSERT_KEY	ENDP

;-----------------------------------------------------------------------
; This subroutine inserts spaces into the file buffer.  On entry AX
; contains the number of spaces to be inserted.  On return, CF=1 if
; there was not enough space in the file buffer.
;-----------------------------------------------------------------------
OPEN_SPACE	PROC	NEAR
		MOV	CX,LAST_CHAR	;Last character in the file
		MOV	SI,CX
		MOV	DI,CX
		ADD	DI,AX		;Offset for new end of file
		JC	NO_ROOM		;If no more room, return error
		MOV	LAST_CHAR,DI	;Save offset of end of file
		SUB	CX,CURSOR	;Number of characters to shift
		DEC	DI
		DEC	SI
		STD			;String moves goes forward
		REP	MOVSB		;Shift the file upward
		CLD
		CLC
NO_ROOM:
		RET
OPEN_SPACE	ENDP

;-----------------------------------------------------------------------
; This subroutine adjusts the cursor position ahead to the saved cursor
; column.  On entry DH has the cursor row.
;-----------------------------------------------------------------------
SHIFT_RIGHT	PROC	NEAR
		MOV	CL,SAVE_COLUMN	;Keep the saved cursor offset
		XOR	CH,CH
		MOV	BP,CX		;Keep the saved cursor position
		ADD	CL,LEFT_MARGIN	;Shift into visable window also
		ADC	CH,0
		XOR	DL,DL
		MOV	CUR_POSN,DX	;Get cursor row/column
		JCXZ	NO_CHANGE
RIGHT_AGAIN:
		PUSH	CX
		CMP	BYTE PTR [SI],CR;At end of line?
		JE	DONT_MOVE	;If at end, stop moving
		CALL	RIGHT		;Move right one character
DONT_MOVE:
		POP	CX

		MOV	AL,SAVE_COLUMN
		XOR	AH,AH
		CMP	AX,CX		;Is cursor still in margin?
		JL	IN_MARGIN	;If yes, keep moving

		MOV	DX,CUR_POSN	;Get cursor column again
		XOR	DH,DH
		CMP	DX,BP		;At saved cursor position?
		JE	RIGHT_DONE	;If yes, were done
		JA	RIGHT_TOO_FAR	;Did we go too far?
IN_MARGIN:
		LOOP	RIGHT_AGAIN
RIGHT_DONE:
		MOV	CX,BP
		MOV	SAVE_COLUMN,CL	;Get back saved cursor position
NO_CHANGE:
		RET
RIGHT_TOO_FAR:
		CALL	LEFT		;Move back left one place
		MOV	CX,BP
		MOV	SAVE_COLUMN,CL	;Get back saved cursor position
		RET
SHIFT_RIGHT	ENDP

;-----------------------------------------------------------------------
; This subroutine skips past the CR and LF at SI.  SI returns new offset
;-----------------------------------------------------------------------
SKIP_CR_LF	PROC	NEAR
		CMP	SI,LAST_CHAR	;At last char in the file?
		JAE	NO_SKIP		;If yes, dont skip anything
		CMP	BYTE PTR [SI],CR;Is first character a CR?
		JNE	NO_SKIP
		INC	SI		;Look at next character
		CMP	SI,LAST_CHAR	;Is it at the end of file?
		JAE	NO_SKIP		;If yes, dont skip anymore
		CMP	BYTE PTR [SI],LF;Is next character a line feed?
		JNE	NO_SKIP		;Skip any line feeds also
		INC	SI
NO_SKIP:
		RET
SKIP_CR_LF	ENDP

;-----------------------------------------------------------------------
; This subroutine finds the beginning of the previous line.
;-----------------------------------------------------------------------
FIND_PREVIOUS	PROC	NEAR
		PUSH	CURSOR		;Save the cursor location
		CALL	FIND_CR		;Find start of this line
		MOV	CURSOR,SI	;Save the new cursor
		CALL	FIND_START	;Find the start of this line
		POP	CURSOR		;Get back starting cursor
		RET
FIND_PREVIOUS	ENDP

;-----------------------------------------------------------------------
; This searches for the previous carriage return.  Search starts at SI.
;-----------------------------------------------------------------------
FIND_CR		PROC	NEAR
		PUSH	CX
		MOV	AL,LF		;Look for a carriage return
		MOV	DI,SI
		MOV	CX,SI
		JCXZ	AT_BEGINNING
		DEC	DI
		STD			;Search backwards
LF_PREV:
		REPNE	SCASB		;Scan for the character
		JCXZ    LF_END
		CMP	BYTE PTR [DI],CR
		JNE	LF_PREV
		DEC	DI
LF_END:
		CLD			;Restore direction flag
		INC	DI
		MOV	SI,DI
AT_BEGINNING:
		POP	CX
		RET
FIND_CR		ENDP

;-----------------------------------------------------------------------
; This subroutine computes the location of the start of current line.
; Returns SI pointing to the first character of the current line.
;-----------------------------------------------------------------------
FIND_START	PROC	NEAR
		MOV	SI,CURSOR	;Get the current cursor
		OR	SI,SI		;At start of the file?
		JZ	AT_START	;If yes, were done
		CALL	FIND_CR		;Find the 
		CALL	SKIP_CR_LF
AT_START:
		RET
FIND_START	ENDP

;-----------------------------------------------------------------------
; This finds the offset of the start of the next line.  The search is 
; started at location ES:SI.  On return CF=1 of no CR was found.
;-----------------------------------------------------------------------
FIND_NEXT	PROC	NEAR
		PUSH	CX
		CALL	FIND_EOL	;Find the end of this line
		JC	AT_NEXT		;If at end of file, return
		CALL	SKIP_CR_LF	;Skip past CR and LF
		CLC			;Indicate end of line found
AT_NEXT:                  
		POP	CX
		RET
FIND_NEXT	ENDP

;-----------------------------------------------------------------------
; This searches for the next carriage return in the file.  The search
; starts at the offset in register SI.
;-----------------------------------------------------------------------
FIND_EOL	PROC	NEAR
		MOV	AL,CR		;Look for a carriage return
CR_SCAN:
		MOV	CX,LAST_CHAR	;Last letter in the file
		SUB	CX,SI		;Count for the search
		MOV	DI,SI
		JCXZ	AT_END		;If nothing to search, return
		REPNE	SCASB		;Scan for the character
		MOV	SI,DI		;Return the location of the CR
		JCXZ	AT_END		;If not found, return
		CMP	BYTE PTR [SI],LF
		JNE	CR_SCAN
		DEC	SI
		CLC			;Indicate the CR was found
		RET
AT_END:
		STC			;Indicate CR was not found
		RET
FIND_EOL	ENDP

;-----------------------------------------------------------------------
; This subroutine positions the screen with the cursor at the row
; selected in register DH.  On entry, SI holds the cursor offset.
;-----------------------------------------------------------------------
LOCATE		PROC	NEAR
		MOV	CL,DH
		XOR	CH,CH
		MOV	CURSOR,SI
		XOR	DX,DX		;Start at top of the screen
		OR	SI,SI		;At start of buffer?
		JZ	LOCATE_FIRST

		CALL	FIND_START	;Get start of this row
		XOR	DX,DX		;Start at top of the screen
		OR	SI,SI		;Is cursor at start of file?
		JZ	LOCATE_FIRST
		JCXZ	LOCATE_FIRST	;If locating to top row were done
FIND_TOP:
		PUSH	SI
		PUSH	CX
		CALL	FIND_CR		;Find previous row
		POP	CX
		POP	AX
		CMP	BYTE PTR [SI],CR
		JNE	LOCATE_FIRST
		CMP	BYTE PTR [SI+1],LF
		JNE	LOCATE_FIRST
		CMP	SI,AX		;Did it change?
		JE	LOCATE_DONE	;If not, quit moving
		INC	DH		;Cursor moves to next row
		LOOP	FIND_TOP

LOCATE_DONE:
		PUSH	CURSOR
		MOV	CURSOR,SI
		CALL	FIND_START	;Find start of top of screen
		POP	CURSOR
LOCATE_FIRST:
		MOV	TOP_OF_SCREEN,SI
		MOV	CUR_POSN,DX
		CALL	CURSOR_COL
		MOV	SAVE_COLUMN,DL
		RET
LOCATE		ENDP

;-----------------------------------------------------------------------
; This subroutine computes the correct column for the cursor.  No
; inputs.  On exit, CUR_POSN is set and DX has the row/column.
;-----------------------------------------------------------------------
CURSOR_COL	PROC	NEAR
		MOV	SI,CURSOR	;Get cursor offset
		CALL	FIND_START	;Find start of this line
		MOV	CX,CURSOR
		SUB	CX,SI
		MOV	DX,CUR_POSN	;Get current row
		XOR	DL,DL		;Start at column zero
		MOV	MARGIN_COUNT,DL	;Count past the left margin
		JCXZ	COL_DONE
CURSOR_LOOP:
		LODSB			;Get the next character
		CMP	AL,CR		;Is it the end of line?
		JNE	NOT_EOL
		CMP	BYTE PTR [SI],LF
		JE	COL_DONE	;If end, were done
NOT_EOL:
		CMP	AL,TAB		;Is it a tab?
		JNE	NOT_A_TAB

		MOV	BL,MARGIN_COUNT
		OR	BL,00000111B
		MOV	MARGIN_COUNT,BL
		CMP	BL,LEFT_MARGIN	;Inside visible window yet?
		JB	NOT_A_TAB	;If not, don't advance cursor
		OR	DL,00000111B	;Move to multiple of eight
NOT_A_TAB:
		MOV	BL,MARGIN_COUNT
		INC	BL
		MOV	MARGIN_COUNT,BL
		CMP	BL,LEFT_MARGIN
		JBE	OUT_OF_WINDOW
		INC	DL		;Were at next column now
OUT_OF_WINDOW:
		LOOP	CURSOR_LOOP
COL_DONE:
		CMP	DL,COLUMNSB	;Past end of display?
		JB	COLUMN_OK	;If not, were OK?
		MOV	DL,COLUMNSB
		DEC	DL		;Leave cursor at last column
COLUMN_OK:
		MOV	CUR_POSN,DX	;Store the row/column
		RET
CURSOR_COL	ENDP

;-----------------------------------------------------------------------
; This displays the string at CS:SI at the location in DX.  The 
; remainder of the row is erased.  Cursor is put at the end of the line.
;-----------------------------------------------------------------------
TTY_STRING	PROC	NEAR
		ASSUME	DS:CSEG
		PUSH	DX
		CALL	POSITION	;Compute offset into video
		POP	DX
TTY_LOOP:
		LODSB
		OR	AL,AL		;At end of string yet?
		JZ	TTY_DONE
		INC	DL
		PUSH	DX
		CALL	WRITE_INVERSE	;Write in inverse video
		POP	DX
		JMP	TTY_LOOP
TTY_DONE:
		CALL	SET_CURSOR	;Move cursor to end of string
		JMP	ERASE_EOL	;Erase the rest of line
TTY_STRING	ENDP

;-----------------------------------------------------------------------
; This copies the input filename to CS:DI and changes the extension
;-----------------------------------------------------------------------
CHG_EXTENSION	PROC	NEAR
		ASSUME	DS:CSEG, ES:CSEG

		PUSH	SI
		MOV	SI,NAME_POINTER
CHG_LOOP:
		LODSB		
		CMP	AL,"."		;Look for the extension
		JE	FOUND_DOT
		OR	AL,AL
		JZ	FOUND_DOT
		STOSB			;Copy a character
		JMP	CHG_LOOP
FOUND_DOT:
		MOV	CX,5		;Five chars in extension
		POP	SI
		REP	MOVSB		;Move new extension in
		RET
CHG_EXTENSION	ENDP

;-----------------------------------------------------------------------
; This is the control break handler.  It ignores the break.
;-----------------------------------------------------------------------
NEWINT23	PROC	FAR
		ASSUME	DS:NOTHING, ES:NOTHING
		MOV	CS:DIRTY_BITS,1
		CLC			;Tell DOS to ignore break
		IRET
NEWINT23	ENDP

;-----------------------------------------------------------------------
; This is the severe error handler.  It homes the cursor before 
; processing the error.
;-----------------------------------------------------------------------
NEWINT24	PROC	FAR
		ASSUME	DS:NOTHING, ES:NOTHING
		PUSHF
		PUSH	AX
		PUSH	BX
		PUSH	DX
		MOV	CS:DIRTY_BITS,1
		XOR	DX,DX
		CALL	SET_CURSOR	;Put cursor at home
		POP	DX
		POP	BX
		POP	AX
		POPF
		JMP	CS:OLDINT24
NEWINT24	ENDP
;-----------------------------------------------------------------------
EVEN
NAME_DOT_$$$	EQU	$
NAME_DOT_BAK	EQU	$ + 80H
UNDO_BUFFER	EQU	$ + 100H
LINE_BUFFER	EQU	$ + 200H
NEW_STACK	EQU	$ + 500H
CSEG		ENDS
;-----------------------------------------------------------------------
FILE_SEG	SEGMENT
FILE_SEG	ENDS
END		START
