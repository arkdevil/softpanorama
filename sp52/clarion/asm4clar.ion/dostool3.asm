	MASM
	PAGE	60,120
;-----------------------------------------------------------------------;
;	FOR USE WITH CLARION VERSION 2.0				;
;									;
;	MODULE: DOSTOOLS.ASM						;
;									;
;  DOS FUNCTIONS:							;
;									;
;		DOSVER()						;
;			RETURN DOS VERSION				;
;									;
;		CHK8087()						;
;			CHECK FOR 8087 PROCESSOR 0-NO 1-YES		;
;									;
;		GETVERFY()						;
;			RETURN READ / WRITE VERIFY SWITCH		;
;									;
;		PRINTSCN()						;
;			PRINT SCREEN ON LPT1 0-OK 1-ERROR 2-ACTIVE	;
;									;
;		PRTSTAT(PRINTER ID) - LPT1 - LPT2 - LPT3		;
;			RETURN PRINTER STATUS - ERROR CODE		;
;									;
;		GETATTR(FILE NAME)					;
;			GET FILE ATTRIBUTES				;
;			    FILE NAME - STRING				;
;									;
;		GETFILSZ(FILE NAME)					;
;			GET FILE SIZE					;
;			    FILE NAME - STRING				;
;									;
;		CURDISK()						;
;			RETURN CURRENT DISK DRIVE LETTER		;
;									;
;		CURPATH()						;
;			RETURN CURRENT PATH AS STRING			;
;									;
;		PGMPATH()						;
;			RETURN CURRENT PROGRAM PATH AS STRING		;
;									;
;		COMMAND_LINE()						;
;			RETURN COMMAND LINE				;
;									;
;		ENVIRONMENT( environment variable )			;
;			Return value of an enironment variable		;
;									;
;		PROPER( STRING )					;
;			RETURN STRING W/1st CHAR EACH WORD IN CAPS	;
;									;
;  DOS PROCEDURES:							;
;									;
;		SETATTR(FILE NAME,ATTR,ONOFF)				;
;			SET FILE ATTRIBUTES				;
;			  ATTR	- 20H - ARCHIVE				;
;				- 04H - SYSTEM				;
;				- 02H - HIDDEN				;
;				- 01H - READONLY			;
;									;
;			  ONOFF - 0 - ON				;
;				  1 - OFF				;
;									;
;		SETVERFY(SWITCH)					;
;			SET READ / WRITE VERIFY SWITCH			;
;			  SWITCH - 1 - ON				;
;				   0 - OFF				;
;									;
;		SETFIRST(MASK)						;
;			SEARCH FOR FIRST DIRECTORY ENTRY		;
;			    MASK - DIRECTORY MASK EX: *.*		;
;									;
;		FINDFIRST(MASK,FINDFGRP)				;
;			SEARCH FOR AND RETURN FIRST DIRECTORY ENTRY	;
;			    MASK - DIRECTORY MASK EX: *.*		;
;									;
;			    FINDFGRP GROUP				;
;			    TYPE       STRING(1)    !ENTRY TYPE		;
;						    ! 1 - CUR DIRECTORY ;
;						    ! 2 - PRE DIRECTORY ;
;						    ! 3 - SUB DIRECTORY ;
;						    ! 4 - FILE		;
;			    ATTRIB     STRING(4)    !ATTRIBUTES OF FILE ;
;			    TIME       STRING(5)    !TIME HH:MM		;
;			    DATE       STRING(8)    !DATE MM/DD/YY	;
;			    SIZE       LONG	    !SIZE OF FILE	;
;			    NAME       STRING(8)    !FILE NAME		;
;			    EXT	       STRING(3)    !FILE EXTENSION	;
;				    .					;
;									;
;		FINDNEXT(FINDFGRP)					;
;			SEARCH FOR NEXT DIRECTORY ENTRY			;
;			    FINDFGRP GROUP - SAME AS FINDFIRST		;
;									;
;		DELFILE(FILE NAME)					;
;			DELETE FILE					;
;			    FILE NAME - STRING				;
;									;
;		CHPATH(PATH NAME)					;
;			CHANGE PATH					;
;			    PATH NAME - STRING				;
;									;
;		RMPATH(PATH NAME)					;
;			REMOVE PATH					;
;			    PATH NAME - STRING				;
;									;
;		MKPATH(PATH NAME)					;
;			MAKE NEW PATH					;
;			    PATH NAME - STRING				;
;									;
;		SETDISK(DISK LETTER)					;
;			CHANE CURRENT DISK DRIVE			;
;			    DISK LETTER - STRING			;
;									;
;		SPOOL(FILE NAME)					;
;			QUEUE A FILE TO BE PRINTED			;
;									;
;		BROWSE(FILE NAME)					;
;			TYPE TEXT FILE TO SCREEN UP,DN,LF,RT		;
;									;
;	TO MAKE .BIN:	MASM DOSTOOLS;					;
;			LINK DOSTOOLS;					;
;			EXE2BIN DOSTOOLS				;
;									;
;-----------------------------------------------------------------------;

;-----------------------------------------------------------------------;
; CLARION LEM EQUATES							;
;-----------------------------------------------------------------------;
TSTRING	  EQU  0		    ;STRING
TSHORT	  EQU  1		    ;SIGNED WORD (16 BITS)
TLONG	  EQU  2		    ;SIGNED DOUBLE WORD (32 BITS)
TREAL	  EQU  4		    ;DOUBLE PRECISION FLOAT (8087)

PROCEDURE EQU  0		    ;L.E.M. PROCEDURE
FUNCTION  EQU  1		    ;L.E.M. FUNCTION

NAMELTH = 0
.XCREF
.XLIST

;-----------------------------------------------------------------------;
;  LEM ROUTINE 'ROUTINE NAME', PROC LABEL, TYPE,			;
;			NUMBER OF PARAMETERS				;
;-----------------------------------------------------------------------;
LEMRTN	  MACRO RNAME, RPROC, RTYPE, RPARMS
	  LOCAL LBLSTRT,X1
LBLSTRT	 DB	&RNAME
NAMELTH	 =	$-LBLSTRT	  ;PADD NAME WITH NULLS TO 13 BYTES
X1	 EQU	13-NAMELTH
	IF NAMELTH GT 12
	  .ERR
	  %OUT ROUTINE NAME TOO LONG
	ELSE
	 DB   &X1 DUP (0)	  ;REST OF NAME AREA
	 DW   &RPROC		  ;OFFSET WITHIN BINARY MODULE
	 DB   &RTYPE		  ;ROUTINE TYPE = PROCEDURE OR FUNCTION
	 DB   &RPARMS		  ;NUMBER OF PARAMETERS
	ENDIF
	ENDM			  ;END OF MACRO

;-----------------------------------------------------------------------;
;  LEM PARAMETER,LABEL OF PARAMETER, TYPE OF PARAMETER
;-----------------------------------------------------------------------;
LEMPRM	MACRO	PLBL, PTYPE
	DB	&PTYPE		   ;;Type = STRING, SHORT, LONG, or REAL
&PLBL	DD	0		   ;;Address of PARAMETER data
&PLBL&L DW	0		   ;;Length of PARAMETER data
	ENDM

.CREF
.LIST

;-----------------------------------------------------------------------;
DOSTOOLS SEGMENT BYTE			;WILL BE LOADED ON A BYTE BOUNDARY
	 ASSUME CS:DOSTOOLS,DS:DOSTOOLS

;-------LEM MODULE HEADER

	DB	'BIO'		   ;LIM SIGNATURE
LIBVEC	DD	0		   ;RESERVED FOR RUNTIME LIBRARY VECTOR!
	DW	DOSTEND		   ;LENGTH OF LEM MODULE
	DB	25		   ;NUMBER ROUTINES IN THIS LEM

;-----------------------------------------------------------------------;
;-------DOSVER			   ;RETURN CURRENT DOS VERSION		;
;-----------------------------------------------------------------------;
	LEMRTN 'DOSVER',DOSVER,FUNCTION,0

;-----------------------------------------------------------------------;
;-------CHK8087			   ;RETURN STATUS OF 8087 CHIP		;
;-----------------------------------------------------------------------;
	LEMRTN 'CHK8087',CHK8087,FUNCTION,0

;-----------------------------------------------------------------------;
;-------GETVERFY		   ;RETURN VERIFY SWITCH SATUS		;
;-----------------------------------------------------------------------;
	LEMRTN 'GETVERFY',GETVERFY,FUNCTION,0

;-----------------------------------------------------------------------;
;-------PRINTSCN		   ;PRINT SCREEN TO LPT1		;
;-----------------------------------------------------------------------;
	LEMRTN 'PRINTSCN',PRINTSCN,FUNCTION,0

;-----------------------------------------------------------------------;
;-------PRTSTAT			   ;RETURN PRINTER STATUS		;
;-----------------------------------------------------------------------;
	LEMRTN 'PRTSTAT',PRTSTAT,FUNCTION,1

;-------PRTSTAT PARAMETER
	LEMPRM PRTID,TSTRING		;STRING PRINTER ID

;-----------------------------------------------------------------------;
;-------GETATTR			   ;RETURN FILE ATTR HAS A LONG		;
;-----------------------------------------------------------------------;
	LEMRTN 'GETATTR',GETATTR,FUNCTION,1

;-------GETATTR PARAMETER
	LEMPRM GFNAME,TSTRING		;STRING FILE NAME

;-----------------------------------------------------------------------;
;-------GETFILSZ		   ;RETURN FILE SIZE HAS A LONG		;
;-----------------------------------------------------------------------;
	LEMRTN 'GETFILSZ',GETFILSZ,FUNCTION,1

;-------GETFILSZ PARAMETER
	LEMPRM SZNAME,TSTRING		;FILE NAME

;-----------------------------------------------------------------------;
;-------CURDISK			   ;RETURN CURRENT DISK DRIVE LETTER	;
;-----------------------------------------------------------------------;
	LEMRTN 'CURDISK',CURDISK,FUNCTION,0

;-----------------------------------------------------------------------;
;-------CURPATH			   ;RETURN CURRENT PATH NAME		;
;-----------------------------------------------------------------------;
	LEMRTN 'CURPATH',CURPATH,FUNCTION,0

;-----------------------------------------------------------------------;
;-------PGMPATH			   ;RETURN CURRENT PROGRAM PATH NAME	;
;-----------------------------------------------------------------------;
	LEMRTN 'PGMPATH',PGMPATH,FUNCTION,0

;-----------------------------------------------------------------------;
;-------SETATTR			   ;SET FILE ATTR ON/OFF		;
;-----------------------------------------------------------------------;
	LEMRTN 'SETATTR',SETATTR,PROCEDURE,3

;-------SETATTR PARAMETER
	LEMPRM SFNAME,TSTRING		;STRING FILE NAME
	LEMPRM SFATTR,TSHORT		;FILE ATTR
	LEMPRM SFSTAT,TSHORT		;ON / OFF SWITCH

;-----------------------------------------------------------------------;
;-------SETVERFY		   ;SET VERIFY SWITCH ON/OFF		;
;-----------------------------------------------------------------------;
	LEMRTN 'SETVERFY',SETVERFY,PROCEDURE,1

;-------SETVERFY PARAMETER
	LEMPRM ONOFFSW,TSHORT		;CONVERT TO SHORT

;-----------------------------------------------------------------------;
;-------SETFIRST		   ;SET AT FIRST DIR ENTRY		;
;-----------------------------------------------------------------------;
	LEMRTN 'SETFIRST',SETFIRST,PROCEDURE,1

;-------SETFIRST PARAMETER

	LEMPRM SETFNAM,TSTRING

;-----------------------------------------------------------------------;
;-------FINDFIRST		   ;FIND FIRST DIR ENTRY AND RETURN IT	;
;-----------------------------------------------------------------------;
	LEMRTN 'FINDFIRST',FINDFIRST,PROCEDURE,2

;-------FINDFIRST PARAMETER

	LEMPRM FINDFNAM,TSTRING
	LEMPRM FINDFGRP,TSTRING

;-----------------------------------------------------------------------;
;-------FINDNEXT		   ;FIND NEXT DIR ENTRY AND RETURN IT	;
;-----------------------------------------------------------------------;
	LEMRTN 'FINDNEXT',FINDNEXT,PROCEDURE,1

;-------FINDNEXT PARAMETER

	LEMPRM FINDNGRP,TSTRING

;-----------------------------------------------------------------------;
;-------DELFILE			   ;DELETE A FILE			;
;-----------------------------------------------------------------------;
	LEMRTN 'DELFILE',DELFILE,PROCEDURE,1

;-------DELFILE PARAMETER
	LEMPRM DELFNAM,TSTRING	   ;FILE NAME FOR DELETE

;-----------------------------------------------------------------------;
;-------CHPATH			   ;CHANGE PATH				;
;-----------------------------------------------------------------------;
	LEMRTN 'CHPATH',CHPATH,PROCEDURE,1

;-------CHPATH PARAMETER
	LEMPRM CHPATHN,TSTRING	   ;PATH NAME

;-----------------------------------------------------------------------;
;-------RMPATH			   ;REMOVE PATH IF EMPTY		;
;-----------------------------------------------------------------------;
	LEMRTN 'RMPATH',RMPATH,PROCEDURE,1

;-------RMPATH PARAMETER
	LEMPRM RMPATHN,TSTRING	   ;PATH NAME

;-----------------------------------------------------------------------;
;-------MKPATH			   ;MAKE NEW PATH			;
;-----------------------------------------------------------------------;
	LEMRTN 'MKPATH',MKPATH,PROCEDURE,1

;-------MKPATH PARAMETER
	LEMPRM MKPATHN,TSTRING	   ;PATH NAME

;-----------------------------------------------------------------------;
;-------SETDISK			   ;SET NEW CURRENT DISK DRIVE		;
;-----------------------------------------------------------------------;
	LEMRTN 'SETDISK',SETDISK,PROCEDURE,1

;-------SETDISK PARAMETER
	LEMPRM SDISKLTR,TSTRING	   ;STRING DRIVE LETTER

;-----------------------------------------------------------------------;
;-------SPOOL			   ;QUEUE A FILE TO PRINT		;
;-----------------------------------------------------------------------;
	LEMRTN 'SPOOL',SPOOL,PROCEDURE,1

;-------SPOOL PARAMETER
	LEMPRM SPOOLFILE,TSTRING   ;STRING PRINT FILE NAME

;-----------------------------------------------------------------------;
;-------COMMAND_LINE		   ;RETURN PROGRAM COMMAND LINE		;
;-----------------------------------------------------------------------;
	LEMRTN 'COMMAND_LINE',COMMAND_LINE,FUNCTION,0

;-----------------------------------------------------------------------;
;-------ENVIRONMENT		   ;RETURN VALUE OF ENVIRONMENT VARIABLE;
;-----------------------------------------------------------------------;
	LEMRTN 'ENVIRONMENT',ENVIRONMENT,FUNCTION,1

;-------ENVIRONMENT PARAMETER
	LEMPRM ENVVAR,TSTRING		;STRING OF ENVIRONMENT VARIABLE

;-----------------------------------------------------------------------;
;-------PROPER			   ;MAKE 1st CHAR EACH WORD UPCASE	;
;-----------------------------------------------------------------------;
	LEMRTN 'PROPER',PROPER,FUNCTION,1

;-------PROPER PARAMETER
	LEMPRM PROPSTR,TSTRING		;STRING OF ENVIRONMENT VARIABLE

;-----------------------------------------------------------------------;
;-------BROWSE			   ;TYPE A TEXT FILE TO SCREEN		;
;-----------------------------------------------------------------------;
	LEMRTN 'BROWSE',BROWSE,PROCEDURE,1

;-------BROWSE PARAMETER
	LEMPRM BRWFILE,TSTRING	   ;STRING PRINT FILE NAME

;-----------------------------------------------------------------------;
; STORAGE WORK AREA							;
;-----------------------------------------------------------------------;
ERROROP LABEL BYTE
ERRORST DW     0		   ;ERROR STATUS FROM DOS
VERFYOP LABEL BYTE
VERFYSW DW     0		   ;TEMP COPY OF VERFYSW
	DW     0		   ;DUMMY AREA FOR CLARION
FILEHAD DW     0		   ;FILE HANDLE
AREAOFF DW     0		   ;AREA OFFSET
FINDFSW DB     0		   ;SWITCH FOR DIR SEARCH
DIRIBUF DB     21 DUP(0)	   ;INPUT BUFFER
DIRIATR DB     0		   ;FILE ATTR
DIRITIM DW     0		   ;TIME
DIRIDAT DW     0		   ;DATE
DIRISIZ DD     0		   ;FILE SIZE
DIRINAM DB     13 DUP(0)	   ;FILE NAME
	ORG    DIRIBUF
FILEIN	DB     129 DUP(0)	   ;COPY INPUT NAME TO HERE
BUFFER	DB     256 DUP(0)	   ;WORKING STORAGE
DIROBUF LABEL BYTE
DIROTYP DB     0		   ;TYPE OF DIR ENTRY
DIROATR DD     0		   ;FILE ATTR FOUR BYTES
DIROTIM DB     5 DUP(0)		   ;TIME  HH:MM
DIROAPM DW     0		   ;AM/PM
DIRODAT DB     8 DUP(0)		   ;DATE  MM/DD/YY
DIROSIZ DD     0		   ;FILE SIZE
DIRONAM DB     8 DUP(0)		   ;FILE NAME
DIROEXT DB     3 DUP(0)		   ;FILE NAME EXTENSION
	ORG    DIROBUF
FILEOUT DB     129 DUP(0)	   ;COPY OUTPUT NAME TO HERE
STRLEN	DB     0		   ;LENGTH OF STRING FROM BINTODEC
STRWORK DB     20 DUP(0)	   ;WORK AREA FOR BINTODEC
PRTNUMO LABEL BYTE
PRTNUM	DW     0		   ;TEMP COPY OF PRTNUM
VERDOS	DB     0		   ;DOS VERSION NUMBER
EXPOFF	DW     0		   ;EXECUTION PATH NAME OFFSET
ENVLTH	DW     0		   ;LENGTH OF PATH EXECUTABLE NAME (DOS 3).

PACKET	DB     0		   ;FORM CLARION DOS1.ASM
FNPTR	DD     0		   ; FOR USE W/SPOOL ADDED FROM DOS1.ASM

;-----------------------------------------------------------------------;
; DOSVER FUNCTION							;
;-----------------------------------------------------------------------;
DOSVER	 PROC  FAR
	 MOV   AX,0000H		   ;CLEAR FIELD
	 MOV   VERFYSW,AX	   ;DO IT
	 MOV   AH,30H		   ;SET GET DOS VERSION
	 INT   21H		   ;DO IT
	 ADD   AL,AH		   ;ADD MAJOR & MINOR
	 MOV   VERFYOP,AL	   ;MOVE IT
	 MOV   AL,2		   ;SET LONG
	 MOV   CX,4		   ;NO LENGTH
	 MOV   BX,OFFSET DOSTOOLS:VERFYSW
	 RET			   ;RETURN TO CLARION
DOSVER	 ENDP

;-----------------------------------------------------------------------;
; CHK8087 FUNCTION							;
;-----------------------------------------------------------------------;
CHK8087	 PROC  FAR
	 MOV   AX,0000H		   ;CLEAR FIELD
	 MOV   VERFYSW,AX	   ;DO IT
	 INT   11H		   ;GET CONFIGURATION (BIOS CALL)
	 MOV   VERFYOP,0H	   ;ASSUME NO 8087
	 TEST  AL,10B		   ;COPROCESSOR
	 JZ    NO87		   ;NO? DONE
	 MOV   VERFYOP,1H	   ;SET CODE
NO87:	 MOV   AL,2		   ;SET LONG
	 MOV   CX,4		   ;LENGTH
	 MOV   BX,OFFSET DOSTOOLS:VERFYSW
	 RET			   ;RETURN TO CLARION
CHK8087	 ENDP

;-----------------------------------------------------------------------;
; GETVERFY FUNCTION							;
;-----------------------------------------------------------------------;
GETVERFY PROC  FAR
	 MOV   AX,0000H		   ;CLEAR FIELD
	 MOV   VERFYSW,AX	   ;DO IT
	 MOV   AH,54H		   ;SET GET VERIFY SWITCH
	 INT   21H		   ;DO IT
	 MOV   VERFYOP,AL	   ;GET CODE
	 MOV   AL,2		   ;SET LONG
	 MOV   CX,2		   ;LENGTH
	 MOV   BX,OFFSET DOSTOOLS:VERFYSW
	 RET			   ;RETURN TO CLARION
GETVERFY ENDP

;-----------------------------------------------------------------------;
; PRINTSCN FUNCTION							;
;-----------------------------------------------------------------------;
PRINTSCN PROC  FAR
	 MOV   AX,0000H		   ;CLEAR FIELD
	 MOV   VERFYSW,AX	   ;DO IT
	 MOV   AX,50H		   ;POINT TO STATUS AREA
	 MOV   ES,AX		   ;AT
	 MOV   DI,00H		   ;0500
	 MOV   AL,0FFH		   ;SET ERROR CODE
	 CMP   ES:[DI],AL	   ;CHECK FOR ERROR
	 JE    PRTRTN1		   ;RETURN WITH ERROR
	 MOV   AH,05H		   ;SET PRINT SCREEN (BIOS CALL)
	 INT   5H		   ;DO IT
	 MOV   AL,0FFH		   ;SET ERROR CODE
	 CMP   ES:[DI],AL	   ;CHECK FOR ERROR
	 JE    PRTRTN1		   ;RETURN WITH ERROR
PRTRTN0: MOV   VERFYOP,00H	   ;GET CODE
	 JMP   PRTRTNA		   ;BRANCH AROUND
PRTRTN1: MOV   VERFYOP,01H	   ;GET CODE
PRTRTNA: MOV   AL,2		   ;SET LONG
	 MOV   CX,2		   ;LENGTH
	 MOV   BX,OFFSET DOSTOOLS:VERFYSW
	 RET			   ;RETURN TO CLARION
PRINTSCN ENDP

;-----------------------------------------------------------------------;
; PRTSTAT FUNCTION							;
;-----------------------------------------------------------------------;
PRTSTAT	 PROC  FAR
	 LES   DI,PRTID		   ;COPY PRINTER ID TO LOCAL STORAGE
	 MOV   AL,BYTE PTR ES:[DI]+3 ;GET PRINTER ID
	 MOV   PRTNUMO,00H	   ;CLEAR PRINTER NUMBER
	 MOV   CX,PRTIDL	   ;GET LENGTH OF ID
	 CMP   CX,04H		   ;ONLY 3 BYTES
	 JNE   GETPRTS		   ;YES USE DEFAULT '0'
	 SUB   AL,'1'-0		   ;CONVERT TO BINARY
	 MOV   PRTNUMO,AL	   ;GET PRINTER NUMBER
GETPRTS: MOV   DX,PRTNUM	   ;PRINTER NO
	 MOV   AH,02H		   ;SET GET PRINTER STATUS (BIOS CALL)
	 INT   17H		   ;DO IT
	 MOV   VERFYOP,00H	   ;SET OK
	 CMP   AH,90H		   ;NOT BUSY & SELECTED (90H = 10010000)
	 JZ    PRTRTN		   ;RETURN FALSE IF OTHER THAN ABOVE
	 MOV   AL,0FFH		   ;SET 255
	 SUB   AL,80H		   ;255 - 80H
	 AND   AH,AL		   ;TURN OFF HIGH ORDER BIT
	 MOV   VERFYOP,AH	   ;SET TRUE
PRTRTN:	 MOV   AL,2		   ;SET LONG
	 MOV   CX,4		   ;NO LENGTH
	 MOV   BX,OFFSET DOSTOOLS:VERFYSW
	 RET			   ;RETURN TO CLARION
PRTSTAT ENDP

;-----------------------------------------------------------------------;
; GETATTR FUNCTION							;
;-----------------------------------------------------------------------;
GETATTR	 PROC  FAR
	 LES   SI,DWORD PTR GFNAME ;COPY NAME TO FILEIN
	 MOV   BP,ES		   ;GET THE DIRECTORY NAME
	 MOV   CX,GFNAMEL	   ;GET THE LENGTH OF THE NAME
	 LEA   AX,FILEIN	   ;DESTINATION = FILEIN
	 MOV   AREAOFF,AX	   ;SAVE POINTER
	 CALL  COPYNAME		   ;GO COPY NAME
	 JNC   GETATTA		   ;ERROR IF NAME TOO LONG
	 RET			   ;RETURN TO CLARION NAME ERROR
GETATTA: PUSH  DS
	 MOV   DX,OFFSET FILEIN	   ;POINT TO FILE NAME
	 MOV   AX,4300H		   ;SET GET ATTRIBUTES
	 INT   21H		   ;DO IT
	 POP   DS
	 JNC   GETFRTN		   ;ERROR IF CARRY
	 CALL  SETEXTERR	   ;GO SET ERROR CODE
	 RET			   ;RETURN TO CLARION NAME ERROR
GETFRTN: MOV   VERFYSW,CX	   ;DO IT
	 MOV   AL,2		   ;SET LONG
	 MOV   CX,4		   ;LENGTH
	 MOV   BX,OFFSET DOSTOOLS:VERFYSW
	 RET			   ;RETURN TO CLARION
GETATTR ENDP

;-----------------------------------------------------------------------;
; GETFILSZ FUNCTION							;
;-----------------------------------------------------------------------;
GETFILSZ PROC FAR
	 LES   SI,DWORD PTR SZNAME ;COPY NAME TO FILEIN
	 MOV   BP,ES		   ;GET THE FILE NAME
	 MOV   CX,SZNAMEL	   ;GET THE LENGTH OF THE NAME
	 LEA   AX,DIRONAM	   ;DESTINATION = DIRONAM
	 MOV   AREAOFF,AX	   ;SAVE POINTER
	 CALL  COPYNAME		   ;COPY FIND FILE TO BUFFER
	 JNC   GETFIZA		   ;FILE NAME TOO LONG?
	 RET			   ;RETURN TO CLARION
GETFIZA: MOV   DIROTYP,16H	   ;GO FIND ENTRY
	 CALL  SETFDIR		   ;GO FIND ENTRY
	 JNC   GETFIZR		   ;ERROR ON SEARCH
	 RET			   ;YES RETURN TO CLARION
GETFIZR: MOV AL,2		   ;SET LONG
	 MOV CX,4		   ;LENGTH
	 MOV BX,OFFSET DOSTOOLS:DIRISIZ
	 RET			   ;RETURN TO CLARION
GETFILSZ ENDP

;-----------------------------------------------------------------------;
; CURDISK FUNCTION CURRENT DISK LETTER RETURNED AS STRING		;
;-----------------------------------------------------------------------;
CURDISK	 PROC  FAR
	 MOV   AH,19H		   ;SET GET CURRENT DISK
	 INT   21H		   ;GET CURRENT DISK
	 ADD   AL,'A'		   ;CONVERT TO STRING
	 MOV   VERFYOP,AL	   ;SET ERROR CODE
CDISKRT: MOV   AL,0		   ;SET STRING
	 MOV   CX,1		   ;LENGTH
	 MOV   BX,OFFSET DOSTOOLS:VERFYSW
	 RET			   ;RETURN TO CLARION
CURDISK	 ENDP

;-----------------------------------------------------------------------;
; CURPATH FUNCTION CURRENT PATH RETURNED AS STRING			;
;-----------------------------------------------------------------------;
CURPATH	 PROC FAR
	 CALL CLEARERR		   ;GO CLEAR ERROR CODE
	 MOV AH,19H		   ;SET GET CURRENT DISK
	 INT 21H		   ;GET CURRENT DISK
	 ADD AL,'A'		   ;CONVERT TO STRING,
	 MOV FILEOUT,AL		   ;MOVE DRIVE LETTER
	 MOV FILEOUT+1,':'	   ;MOVE : TO STRING
	 MOV FILEOUT+2,'\'	   ;MOVE \ TO STRING
	 MOV AH,47H		   ;SET GET PATH NAME
	 MOV DL,00H		   ;SET CURRENT DRIVE
	 LEA SI,FILEOUT+3	   ;SET AREA ADDRESS
	 INT 21H		   ;GET CURRENT DISK
	 JNC CPATHRT		   ;ERROR IF CARRY
CURPERR: CALL SETEXTERR
	 RET
CPATHRT: MOV AX,DS		   ;POINT TO PATH NAME
	 MOV ES,AX		   ;IN ES
	 LEA DI,FILEOUT		   ;POINT TO PATH NAME
	 CLD			   ;FORWARD
	 SUB AL,AL		   ;LOOK FOR NULL
	 MOV CX,128		   ;MAX LENGTH
	 REPNZ SCASB		   ;SCAN IT
	 MOV AX,CX
	 MOV CX,127		   ;SET MAX-1
	 SUB CX,AX		   ;FIND LENGTH
	 MOV AL,0		   ;SET STRING
	 MOV BX,OFFSET DOSTOOLS:FILEOUT
	 RET			   ;RETURN TO CLARION
CURPATH	 ENDP

;-----------------------------------------------------------------------;
; PGMPATH FUNCTION CURRENT PROGRAM PATH RETURNED AS STRING		;
;-----------------------------------------------------------------------;
PGMPATH	 PROC FAR
	 PUSH  DS		   ;SAVE DATA SEGMENT
	 CALL  CLEARERR		   ;GO CLEAR ERROR CODE
	 MOV   AH,30H		   ;SET GET DOS VERSION
	 INT   21H		   ;DO IT
	 MOV   VERDOS,AL	   ;SAVE IT
	 MOV   AH,62H		   ;GET ADDRESS OF _PSP
	 INT   21H		   ;DO IT
	 MOV   ES,BX		   ;GET SEGMENT OF PSP
	 MOV   DI,2CH		   ;OFFSET OF ENVIRONMENT POINTER
	 MOV   ES,ES:[DI]	   ;GET SEGMENT OF ENVIRONMENT
PGMPTHI: CMP   VERDOS,2		   ;IS IT VERSION 3 OR MORE?
	 JNA   PGMPTHR		   ;NO GO EXIT
	 SUB   DI,DI		   ;ENVIRONMENT OFFSET = 0
	 MOV   CX,-1		   ;FOR REP INSTRUCTIONS.
	 SUB   AX,AX		   ;STRINGS PART ENDS WITH NULLS
	 CLD			   ;FORWARD
PGMPTHL: REPNE SCASB		   ;NO: SKIP NEXT ENVIRONMENT STRING.
	 CMP   BYTE PTR ES:[DI],AL ;END OF  ENVIRONMENT?
	 JE    PGMPTHM
	 JMP   PGMPTHL
PGMPTHM: ADD   DI,3		   ;GET OVER NULLS AND MYSTERY WORD.
	 MOV   EXPOFF,DI	   ;SAVE POINTER TO IT.
	 SUB   DX,DX
PGMPTHP: MOV   AL,BYTE PTR ES:[DI] ;GET LENGTH OF PATH NAME PORTION
	 INC   DI
	 INC   DX
	 CMP   AL,0		   ;OF THIS NAME.
	 JZ    PGMPTHR
	 CMP   AL,':'		   ;A VALID SEPARATOR?
	 JZ    PGMPTHY
	 CMP   AL,'/'
	 JZ    PGMPTHY
	 CMP   AL,'\'
	 JZ    PGMPTHY
	 JMP   PGMPTHP
PGMPTHY: MOV   ENVLTH,DX
	 JMP   PGMPTHP
PGMPTHR: POP   DS		   ;RESET DATA SEGMENT
	 LEA   AX,FILEOUT	   ;DESTINATION = FILEOUT
	 MOV   AREAOFF,AX	   ;SAVE POINTER
	 MOV   CX,ENVLTH	   ;GET CONTENTS LENGTH
	 CMP   CX,03H		   ;MAIN PATH
	 JNAE  PGMPTHX
	 DEC   CX		   ;FIX UP LENGTH
	 MOV   ENVLTH,CX	   ;SAVE NEW LENGTH
PGMPTHX: MOV   BP,ES		   ;SEGMENT OF CONTENTS
	 MOV   SI,EXPOFF	   ;OFFSET OF CONTENTS
	 CALL  COPYNAME		   ;COPY CONTENTS
	 MOV   CX,ENVLTH	   ;GET CONTENTS LENGTH
	 MOV   AL,0		   ;SET STRING
	 MOV   BX,OFFSET DOSTOOLS:FILEOUT
	 RET			   ;RETURN TO CLARION
PGMPATH	 ENDP

;-----------------------------------------------------------------------;
; SETATTR USED TO CHANGE FILE ATTR'S					;
;-----------------------------------------------------------------------;
SETATTR	 PROC FAR
	 LES   SI,DWORD PTR SFNAME ;COPY NAME TO FILEIN
	 MOV   BP,ES		   ;GET THE DIRECTORY NAME
	 MOV   CX,SFNAMEL	   ;GET THE LENGTH OF THE NAME
	 LEA   AX,FILEIN	   ;DESTINATION = FILEIN
	 MOV   AREAOFF,AX	   ;SAVE POINTER
	 CALL  COPYNAME		   ;GET FILE NAME
	 JNC   SETATTA		   ;ERROR IF NAME TOO LONG
	 RET			   ;RETURN TO CLARION NAME ERROR
SETATTA: LES   DI,SFATTR	   ;COPY ATTR BYTES
	 MOV   AX,ES:[DI]	   ;POINT TO PARM
	 MOV   CX,AX		   ;GET FILE ATTR
	 CMP   CX,00H		   ;RESET ALL ATTR
	 JE    SETFATR		   ;YES
	 MOV   VERFYSW,AX	   ;SAVE ATTR
	 LES   DI,SFSTAT	   ;COPY ON / OFF SWITCH
	 MOV   AX,ES:[DI]	   ;POINT TO PARM
	 MOV   PRTNUM,AX	   ;SAVE ON /OF SWITCH
	 PUSH  DS		   ;SAVE DS
	 MOV   DX,OFFSET FILEIN	   ;POINT TO FILE NAME
	 MOV   AX,4300H		   ;SET GET ATTRIBUTES
	 INT   21H		   ;DO IT
	 POP   DS		   ;RESTORE DS
	 JNC   SETATTC		   ;ERROR IF CARRY
	 CALL  SETEXTERR	   ;GO SET ERROR CODE
	 RET			   ;RETURN TO CLARION NAME ERROR
SETATTC: CMP   PRTNUMO,00H	   ;SET ON
	 JE    SETFAON		   ;YES
	 MOV   AL,0FFH		   ;SET 255
	 SUB   AL,VERFYOP	   ;255 - KEY CODE
	 MOV   VERFYOP,AL	   ;SET BYTE FOR AND
	 MOV   VERFYOP+1,0FFH	   ;PLAY IT SAFE
	 AND   CX,VERFYSW	   ;SET ATTR OFF
	 JMP   SHORT SETFATR	   ;BRANCH AROUND
SETFAON: OR    CX,VERFYSW	   ;SET ATTR ON
SETFATR: PUSH  DS		   ;SAVE DS
	 MOV   DX,OFFSET FILEIN	   ;POINT TO FILE NAME
	 MOV   AX,4301H		   ;SET SET ATTRIBUTES)
	 INT   21H		   ;DO IT
	 POP   DS		   ;RESTORE DS
	 JNC   SETFRTN		   ;ERROR IF CARRY
	 CALL  SETEXTERR	   ;GO SET ERROR CODE
SETFRTN: RET			   ;RETURN TO CLARION
SETATTR	 ENDP

;-----------------------------------------------------------------------;
; SETVERFY PROCEDURE							;
;-----------------------------------------------------------------------;
SETVERFY PROC  FAR
	 LES   DI,ONOFFSW	   ;COPY PARAMETER
	 MOV   AX,ES:[DI]	   ;POINT TO PARM
	 MOV   VERFYSW,AX	   ;GET VERIFY SWITCH
	 MOV   AL,VERFYOP	   ;VERIFY SWITCH
	 MOV   AH,2EH		   ;SET VERIFY SWITCH
	 INT   21H		   ;DO IT
	 RET			   ;RETURN TO CLARION
SETVERFY ENDP

;-----------------------------------------------------------------------;
; SETFIRST PROCEDURE							;
;-----------------------------------------------------------------------;
SETFIRST PROC FAR
	 MOV   CX,SETFNAML		;GET LENGTH MASK
	 LES   SI,DWORD PTR SETFNAM	;GET ADDRESS OF FILE NAME
	 MOV   BP,ES			;BP:SI POINTS TO FIND NAME
	 LEA   AX,DIRONAM		;DESTINATION = DIRONAM
	 MOV   AREAOFF,AX		;SAVE POINTER
	 CALL  COPYNAME			;COPY FIND FILE TO BUFFER
	 JNC   SETFRA			;FILE NAME TOO LONG?
	 RET				;RETURN TO CLARION
SETFRA:	 MOV   DIROTYP,16H		;GO FIND ENTRY
	 CALL  SETFDIR			;GO FIND ENTRY
	 JNC   SETFRB			;ERROR ON SEARCH
	 RET				;YES RETURN TO CLARION
SETFRB:	 MOV   FINDFSW,1		;SET SWITCH FOR FINDNEXT
	 RET				;RETURN TO CLARION PROGRAM
SETFIRST ENDP				;END OF FINDFIRST

;-----------------------------------------------------------------------;
; FINDFIRST PROCEDURE							;
;-----------------------------------------------------------------------;
FINDFIRST PROC FAR
	 MOV   CX,FINDFNAML		;GET LENGTH FINDFNAM
	 LES   SI,DWORD PTR FINDFNAM	;GET ADDRESS OF FILE NAME
	 MOV   BP,ES			;BP:SI POINTS TO FIND NAME
	 LEA   AX,DIRONAM		;DESTINATION = DIRONAM
	 MOV   AREAOFF,AX		;SAVE POINTER
	 CALL  COPYNAME			;COPY FIND FILE TO BUFFER
	 JNC   FINDFA			;FILE NAME TOO LONG?
	 RET				;RETURN TO CLARION
FINDFA:	 MOV   DIROTYP,16H		;GO FIND ENTRY
	 CALL  SETFDIR			;GO FIND ENTRY
	 JNC   FINDFB			;ERROR ON SEARCH
	 RET				;YES RETURN TO CLARION
FINDFB:	 CALL  FORMATENT		;GO FORMAT ENTRY
	 MOV   FINDFSW,0		;SET SWITCH FOR FINDNEXT
FINDFR:	 MOV   CX,FINDFGRPL		;GET LENGTH GROUP
	 LES   DI,DWORD PTR FINDFGRP	;GET ADDRESS OF GROUP
	 LEA   SI,DIROTYP		;POINT TO START
	 CLD				;FORWARD
	 REP   MOVSB			;MOVE IT
	 RET				;RETURN TO CLARION PROGRAM
FINDFIRST ENDP				;END OF FINDFIRST

;-----------------------------------------------------------------------;
; FINDNEXT PROCEDURE							;
;-----------------------------------------------------------------------;
FINDNEXT PROC  FAR
	 CMP   FINDFSW,1		;USED SETFIRST
	 JE    FINDNB			;YES GO RETURN FIRST ENTRY
	 CALL  SETNEXT			;GO FIND ENTRY
	 JNC   FINDNB			;ERROR ON SEARCH
	 RET				;YES RETURN TO CLARION
FINDNB:	 CALL  FORMATENT		;SAVE DS
	 MOV   FINDFSW,0		;RESET SWITCH FOR FINDNEXT
FINDNR:	 MOV   CX,FINDNGRPL		;GET LENGTH GROUP
	 LES   DI,DWORD PTR FINDNGRP	;GET ADDRESS OF GROUP
	 LEA   SI,DIROTYP		;POINT TO START
	 CLD				;FORWARD
	 REP   MOVSB			;MOVE IT
	 RET				;RETURN TO CLARION PROGRAM
FINDNEXT ENDP				;END OF FINDNEXT

;-----------------------------------------------------------------------;
; DELFILE PROCEDURE							;
;-----------------------------------------------------------------------;
DELFILE	 PROC  FAR
	 LES   SI,DWORD PTR DELFNAM ;COPY NAME TO FILEIN
	 MOV   BP,ES		   ;GET THE DIRECTORY NAME
	 MOV   CX,DELFNAML	   ;GET THE LENGTH OF THE NAME
	 LEA   AX,FILEIN	   ;DESTINATION = FILEIN
	 MOV   AREAOFF,AX	   ;SAVE POINTER
	 CALL  COPYNAME
	 JNC   DELFILA		   ;NAME TOO LONG
	 RET			   ;RETURN TO CLARION NAME ERROR
DELFILA: PUSH  DS
	 MOV   DX,OFFSET FILEIN	   ;POINT TO FILE NAME
	 MOV   AH,41H		   ;SET DELETE FILE
	 INT   21H		   ;DO IT
	 POP   DS
	 JNC   DELFRTN		   ;NO ERROR IF NOT CARRY
	 CALL  SETEXTERR	   ;GO SET ERROR CODE
DELFRTN: RET
DELFILE	 ENDP

;-----------------------------------------------------------------------;
; CHPATH PROCEDURE CHANGE DIRECTORY PATHS				;
;-----------------------------------------------------------------------;
CHPATH	 PROC FAR
	 LES SI,DWORD PTR CHPATHN  ;COPY NAME TO FILEIN
	 MOV   BP,ES		   ;GET THE DIRECTORY NAME
	 MOV   CX,CHPATHNL	   ;GET THE LENGTH OF THE NAME
	 LEA   AX,FILEIN	   ;DESTINATION = FILEIN
	 MOV   AREAOFF,AX	   ;SAVE POINTER
	 CALL  COPYNAME
	 JNC   CHPATHA		   ;NAME TOO LONG
	 RET			   ;RETURN TO CLARION NAME ERROR
CHPATHA: PUSH  DS
	 MOV   DX,OFFSET FILEIN	   ;POINT TO FILE NAME
	 MOV   AH,3BH		   ;SET CHANGE PATH
	 INT   21H		   ;DO IT
	 POP   DS
	 JNC   CHPATHR		   ;NO ERROR IF NOT CARRY
	 CALL  SETEXTERR	   ;GO SET ERROR CODE
CHPATHR: RET
CHPATH	 ENDP

;-----------------------------------------------------------------------;
; RMPATH PROCEDURE REMOVE DIRECTORY PATHS				;
;-----------------------------------------------------------------------;
RMPATH	 PROC  FAR
	 LES   SI,DWORD PTR RMPATHN ;COPY NAME TO FILEIN
	 MOV   BP,ES		   ;GET THE DIRECTORY NAME
	 MOV   CX,RMPATHNL	   ;GET THE LENGTH OF THE NAME
	 LEA   AX,FILEIN	   ;DESTINATION = FILEIN
	 MOV   AREAOFF,AX	   ;SAVE POINTER
	 CALL  COPYNAME
	 JNC   RMPATHA		   ;NAME TOO LONG
	 RET			   ;RETURN TO CLARION NAME ERROR
RMPATHA: PUSH  DS
	 MOV   DX,OFFSET FILEIN	   ;POINT TO FILE NAME
	 MOV   AH,3AH		   ;SET REMOVE PATH
	 INT   21H		   ;DO IT
	 POP   DS
	 JNC   RMPATHR		   ;NO ERROR IF NOT CARRY
	 CALL  SETEXTERR	   ;GO SET ERROR CODE
RMPATHR: RET
RMPATH	 ENDP

;-----------------------------------------------------------------------;
; MKPATH PROCEDURE MAKE DIRECTORY PATHS					;
;-----------------------------------------------------------------------;
MKPATH	 PROC FAR
	 LES   SI,DWORD PTR MKPATHN ;COPY NAME TO FILEIN
	 MOV   BP,ES		   ;GET THE DIRECTORY NAME
	 MOV   CX,MKPATHNL	   ;GET THE LENGTH OF THE NAME
	 LEA   AX,FILEIN	   ;DESTINATION = FILEIN
	 MOV   AREAOFF,AX	   ;SAVE POINTER
	 CALL  COPYNAME
	 JNC   MKPATHA		   ;NAME TOO LONG
	 RET			   ;RETURN TO CLARION NAME ERROR
MKPATHA: PUSH  DS
	 MOV   DX,OFFSET FILEIN	   ;POINT TO FILE NAME
	 MOV   AH,39H		   ;SET REMOVE PATH
	 INT   21H		   ;DO IT
	 POP   DS
	 JNC   MKPATHR		   ;NO ERROR IF NOT CARRY
	 CALL  SETEXTERR	   ;GO SET ERROR CODE
MKPATHR: RET
MKPATH	 ENDP

;-----------------------------------------------------------------------;
; SETDISK PROCEDURE SET TO DRIVE LETTER PASSED				;
;-----------------------------------------------------------------------;
SETDISK	 PROC  FAR
	 LES   DI,SDISKLTR	   ;COPY DISK DRIVE LETTER
	 MOV   DL,BYTE PTR ES:[DI] ;GET DRIVE LETTER
	 SUB   DL,'A'		   ;CONVERT TO BINARY
	 MOV   AH,0EH		   ;SET CHANGE CURRENT DISK
	 INT   21H		   ;SET CURRENT DISK
	 RET			   ;RETURN TO CLARION
SETDISK	 ENDP

;-----------------------------------------------------------------------;
; COPYNAME								;
;	INTERNAL SUBROUTINE FOR THE DOS L.E.M.				;
;	COPIES SOURCE TO FILEIN AND CLIPS TRAILING SPACES		;
;	CALLS COPYSTRING						;
;	RETURNS CARRY SET IF LENGTH LONGER THAN SIZE OF FILEIN - 1	;
;									;
;	CX    = LENGTH OF SOURCE					;
;	BP:SI = ADDRESS OF SOURCE					;
;-----------------------------------------------------------------------;
COPYNAME PROC NEAR
	CALL   CLEARERR		   ;CLEAR ERROR CODE
	CMP    CX,128		   ;MAX OF A 128 BYTES ALLOWED
	JBE    DOCOPY		   ;SIZE OK GO DO COPY
	MOV    AX,2		   ;SET FILE SIZE NAME ERROR
	CALL   SETGLOBERR	   ;GO SET ERROR
	STC			   ;SET ERROR FLAG
	RET			   ;RETURN TO CALLER
DOCOPY: PUSH   CX		   ;SAVE LENGTH
	PUSH   DS		   ;SAVE DATA SEGMENT
	PUSH   DS		   ;ES:DI = DESTINATION
	POP    ES		   ;SET IT
	MOV    DI,AREAOFF	   ;GET OFFSET
	LEA    DI,FILEIN	   ;DESTINATION = FILEIN
	MOV    DS,BP		   ;BP:SI POINTS TO SOURCE
	CALL   COPYSTRING	   ;GO COPY STRING
	POP    DS		   ;RESTORE DS
	MOV    STRLEN,CL	   ;SAVE NUMBER OF DIGITS
	POP    CX		   ;RESTORE CX
	RET			   ;RETURN TO CALLER
COPYNAME ENDP			   ;END OF COPYNAME

;-----------------------------------------------------------------------;
; COPYSTRING								;
;	INTERNAL SUBROUTINE FOR THE DOS L.E.M.				;
;	COPIES A STRING AND CLIPS TRAILING SPACES FROM THE DESTINATION	;
;									;
; EXPECTS:								;
;	CX    = LENGTH OF SOURCE					;
;	DS:SI = ADDRESS OF SOURCE					;
;	ES:DI = ADDRESS OF DESTINATION					;
;									;
; RETURNS:								;
;	CX = THE LENGTH OF THE RESULTANT DESTINATION AFTER CLIPPING	;
;-----------------------------------------------------------------------;
COPYSTRING PROC NEAR
	 PUSH  CX		   ;SAVE LENGTH
	 PUSH  SI		   ;SAVE SOURCE OFFSET
	 PUSH  DI		   ;SAVE DEST OFFSET
	 CLD			   ;FORWARD
	 REP   MOVSB		   ;MOVE IT
	 MOV   BYTE PTR ES:[DI],0  ;ADD NULL AT END
	 POP   DI		   ;RESTORE DEST OFFSET
	 POP   SI		   ;RESTORE SOURCE OFFSET
	 POP   CX		   ;RESTORE LENGTH
	 PUSH  DI		   ;SAVE DEST OFFSET AGAIN
	 MOV   AX,CX		   ;SET UP COUNT REGISTER
	 DEC   AX		   ;MAKE RELATIVE TO ZERO
	 ADD   DI,AX		   ;POINT TO END
	 MOV   AL,20H		   ;LOOK FOR SPACES
	 STD			   ;BACKWARDS DIRECTION
	 REPZ  SCASB		   ;SCAN WHILE EQUAL TO SPACES
	 JNZ   COPYSRB
	 MOV   BYTE PTR ES:1[DI],0 ;STRING ALL SPACES;PUT NULL AT BEGIN
	 JMP   SHORT COPYSRT
COPYSRB: INC   CX		   ;FIX CX WHICH IS 1 TOO SMALL
	 MOV   BYTE PTR ES:2[DI],0 ;NULL TERMINATE AFTER NON-SPACE
COPYSRT: CLD			   ;BACK TO FORWARD
	 CLC			   ;NO ERROR
	 POP   DI		   ;RESTORE DEST OFFSET
	 RET			   ;RETURN TO CALLER
COPYSTRING ENDP

;-----------------------------------------------------------------------;
; PROCEDURE BINTODEC							;
; PURPOSE   CONVERT BINARY NUMBER IN AX TO STRING			;
; INPUT	    VALUE IN AX							;
; OUTPUT    VALUE STRING IN STRWORK					;
; AL CONTAINS NUMBER TO BE CONVERTED					;
;-----------------------------------------------------------------------;
BINTODEC PROC NEAR
	 PUSH  AX		   ;SAVE AX
	 PUSH  DS		   ;SAVE DS
	 POP   ES		   ;PUT IN ES
	 LEA   DI,STRWORK	   ;GET ADDRESS OF FILE NAME
	 CLD			   ;FORWARD
	 MOV   CX,20		   ;CLEAR OUTPUT AREA
	 MOV   AL,20H		   ;FILL WITH SPACES
	 REP   STOSB		   ;DO IT
	 POP   AX		   ;RESTORE NUMBER
	 SUB   CX,CX		   ;CLEAR COUNTER
	 MOV   BX,10		   ;GET READY TO DIVIDE BY 10
GETNUM:	 SUB   DX,DX		   ;CLEAR TOP
	 DIV   BX		   ;REMAINDER IS LAST DIGIT
	 ADD   DL,'0'		   ;CONVERT TO ASCII
	 PUSH  DX		   ;PUT ON STACK
	 INC   CX		   ;COUNT CHARACTER
	 OR    AX,AX		   ;IS QUOTIENT 0?
	 JNZ   GETNUM		   ;NO? GET ANOTHER
	 MOV   STRLEN,CL	   ;SAVE NUMBER OF DIGITS
	 MOV   AX,DS		   ;LOAD DS TO ES
	 MOV   ES,AX		   ;COMPLETE LOAD
	 MOV   DI,OFFSET STRWORK   ;LOAD SOURCE
PUTNUM:	 POP   AX		   ;GET A DIGIT OFF STACK
	 STOSB			   ;STORE IT TO STRING
	 LOOP  PUTNUM		   ;LOOP UNTIL COMPLETE
	 RET
BINTODEC ENDP

;-----------------------------------------------------------------------;
; SETFDIR								;
;	INTERNAL SUBROUTINE FOR THE DOS TOOLS.				;
;	FIND FIRST DIRECTORY ENTRY					;
;									;
;	FILEOUT - CONTAINS PATTEN FOR SEARCH				;
;	DIROTYP - CONTAINS ATTR BYTE FOR SEARCH				;
;	DIRIBUF - WILL CONTAIN ENTRY AFTER SEARCH			;
;-----------------------------------------------------------------------;
SETFDIR	 PROC NEAR
	 CALL  CLEARERR		   ;GO CLEAR ERROR CODE
	 PUSH  DS		   ;SAVE DATA SEGMENT
	 LEA   DX,DIRIBUF	   ;GET ADDRESS OF BUFFER
	 MOV   AH,1AH		   ;SET DTA FUNCTION CODE
	 INT   21H		   ;CALL DOS
	 POP   DS		   ;RESET DS
	 LEA   DX,DIRONAM	   ;GET ADDRESS OF PATTERN
	 MOV   CL,DIROTYP	   ;SET SEARCH TYPE
	 MOV   AH,4EH		   ;FIND FIRST FUNCTION CODE
	 INT   21H		   ;CALL DOS
	 JNC   SETFRRT		   ;ERROR?
	 CALL  SETEXTERR	   ;YES - SET ERROR AND EXIT
	 STC			   ;SET CARRY FLAG FOR ERROR
	 RET			   ;RETURN TO CALLER
SETFRRT: MOV   FINDFSW,1	   ;MARK AS FIRST TIME FOR FINDNEXT
	 RET			   ;RETURN TO CALLER
SETFDIR	 ENDP

;-----------------------------------------------------------------------;
; SETNEXT								;
;	INTERNAL SUBROUTINE FOR THE DOS TOOLS.				;
;	FIND NEXT DIRECTORY ENTRY					;
;									;
;	DIRIBUF - CONTAINS PATTEN FOR CURRENT SEARCH			;
;	DIRIBUF - WILL CONTAIN NEXT ENTRY AFTER SEARCH			;
;-----------------------------------------------------------------------;
SETNEXT	 PROC NEAR
	 CALL  CLEARERR		   ;GO CLEAR ERROR CODE
	 PUSH  DS		   ;SAVE DATA SEGMENT
	 LEA   DX,DIRIBUF	   ;GET ADDRESS OF BUFFER
	 MOV   AH,1AH		   ;SET DTA FUNCTION CODE
	 INT   21H		   ;CALL DOS
	 POP   DS		   ;RESET DS
	 MOV   AH,4FH		   ;FIND NEXT FUNCTION
	 INT   21H		   ;CALL DOS
	 JNC   SETNXRT		   ;ERROR?
	 CALL  SETEXTERR	   ;YES - SET ERROR AND EXIT
	 MOV   FINDFSW,0	   ;RESET SWITCH ON ERROR
	 STC			   ;SET CARRY FLAG FOR ERROR
SETNXRT: RET			   ;RETURN TO CALLER
SETNEXT	 ENDP

;-----------------------------------------------------------------------;
; FORMAT ENTRY								;
;	INTERNAL SUBROUTINE FOR THE DOS TOOLS.				;
;	FORMAT DIRECTORY ENTRY						;
;-----------------------------------------------------------------------;
FORMATENT PROC NEAR

	 PUSH  DS		   ;SAVE DS
	 POP   ES		   ;PUT IN ES
	 LEA   DI,DIROTYP	   ;GET ADDRESS OF OUTPUT AREA
	 CLD			   ;FORWARD
	 MOV   CX,45		   ;CLEAR OUTPUT AREA
	 MOV   AL,20H		   ;FILL WITH SPACES
	 REP   STOSB		   ;DO IT

	 MOV   DIROTYP,'4'	   ;SET FILE ENTRY
	 TEST  DIRIATR,10H	   ;SUB DIR
	 JZ    FORFA9		   ;NO
	 MOV   DIROTYP,'3'	   ;SET SUB DIR ENTRY
	 CMP   WORD PTR DIRINAM,'..' ;PREV DIR ENTRY
	 JNE   FORFA1		   ;NO
	 MOV   CX,2		   ;SET CX
	 MOV   DIROTYP,'2'	   ;SET PRE DIR ENTRY
	 JMP   SHORT FORFA7	   ;BRANCH AROUND
FORFA1:	 CMP   BYTE PTR DIRINAM,'.' ;CURRENT DIR ENTRY
	 JNE   FORFA5		   ;NO
	 MOV   CX,1		   ;SET CX
	 MOV   DIROTYP,'1'	   ;SET CUR DIR ENTRY
	 JMP   SHORT FORFA7	   ;BRANCH AROUND
FORFA5:	 MOV   CX,8		   ;SET CX
FORFA7:	 LEA   DI,DIRONAM	   ;POINT TO OUTPUT NAME
	 LEA   SI,DIRINAM	   ;POINT TO INPUT NAME
	 CLD			   ;FORWARD
	 REP   MOVSB		   ;MOVE IT
	 RET			   ;RETURN TO CALLER

FORFA9:	 MOV   BYTE PTR DIROATR,'.'	;SET FORMAT
	 TEST  DIRIATR,01H		;READ ONLY
	 JZ    FORFA
	 MOV   BYTE PTR DIROATR,'R'	;SET READ ONLY
FORFA:	 MOV   BYTE PTR DIROATR+1,'.'	;SET FORMAT
	 TEST  DIRIATR,20H		;ARCHIVE
	 JZ    FORFB
	 MOV   BYTE PTR DIROATR+1,'A'	;SET ARCHIVE
FORFB:	 MOV   BYTE PTR DIROATR+2,'.'	;SET FORMAT
	 TEST  DIRIATR,04H		;SYSTEM
	 JZ    FORFC
	 MOV   BYTE PTR DIROATR+2,'S'	;SET ARCHIVE
FORFC:	 MOV   BYTE PTR DIROATR+3,'.'	;SET FORMAT
	 TEST  DIRIATR,02H		;HIDDEN
	 JZ    FORFD
	 MOV   BYTE PTR DIROATR+3,'H'	;SET ARCHIVE

FORFD:	 PUSH  DS			;SAVE DS
	 POP   ES			;PUT IN ES
	 LEA   DI,DIRINAM		;GET ADDRESS OF FILE NAME
	 CLD				;FORWARD
	 MOV   CX,13			;MAKE ALL SPACES AFTER NULL
FORFE:	 CMP   BYTE PTR ES:[DI],0	;FIND A NULL?
	 JNE   FORFF
	 MOV   AL,20H			;YES - FILL OUT WITH SPACES
	 REP   STOSB			;*
	 JMP   SHORT FORFG		;DONE
FORFF:	 INC   DI
	 LOOP  FORFE			;LOOP

FORFG:	 PUSH  DS			;SAVE DS
	 POP   ES			;PUT IN ES
	 LEA   SI,DIRINAM		;GET ADDRESS OF FILE NAME
	 CLD				;FORWARD
	 MOV   CX,13			;FIND FILE EXTENSION
FORFH:	 CMP   BYTE PTR ES:[SI],'.'     ;FIND A '.'
	 JNE   FORFI
	 MOV   AX,CX
	 MOV   CX,3		   ;SET MAX FOR EXTENSION
	 INC   SI		   ;FIX FOR MOVE
	 LEA   DI,DIROEXT	   ;POINT TO OUTPUT EXTENSION
	 CLD			   ;FORWARD
	 REP   MOVSB		   ;MOVE IT
	 MOV   CX,13		   ;RESTORE CX
	 SUB   CX,AX		   ;FIX FOR MOVE
	 LEA   DI,DIRONAM	   ;POINT TO OUTPUT NAME
	 LEA   SI,DIRINAM	   ;POINT TO INPUT NAME
	 CLD			   ;FORWARD
	 REP   MOVSB		   ;MOVE IT
	 JMP   SHORT FORFN	   ;DONE
FORFI:	 INC   SI
	 LOOP  FORFH		   ;LOOP

FORFN:	 MOV   DIROAPM,'MA'	   ;SET AM
	 MOV   AX,DIRITIM	   ;GET TIME
	 AND   AX,0F800H	   ;KEEP HOURS ONLY
	 MOV   CL,11		   ;SET FOR SHIFT
	 SHR   AX,CL		   ;PUT INTO AL
	 CMP   AL,12		   ;FIND AM/PM
	 JBE   FORFM		   ;TIME IS AM
	 MOV   DIROAPM,'MP'	   ;SET PM
	 SUB   AL,12		   ;ADJUST TIME
FORFM:	 CALL  BINTODEC		   ;GO CONVERT IT
	 MOV   AX,WORD PTR STRWORK
	 CMP   STRWORK+1,20H	   ;BLANK
	 JNE   FORFM1
	 XCHG  AL,AH		   ;SWAP
FORFM1:	 MOV   WORD PTR DIROTIM,AX
	 MOV   BYTE PTR DIROTIM+2,':' ;FIX FORMAT
	 MOV   AX,DIRITIM	   ;GET TIME
	 AND   AX,07E0H		   ;KEEP MINS ONLY
	 MOV   CL,5		   ;SET FOR SHIFT
	 SHR   AX,CL		   ;PUT INTO AL
	 CALL  BINTODEC		   ;GO CONVERT IT
	 MOV   AX,WORD PTR STRWORK
	 CMP   STRWORK+1,20H	   ;BLANK
	 JNE   FORFM2
	 XCHG  AL,AH		   ;SWAP
	 MOV   AL,'0'		   ;FIX UP
FORFM2:	 MOV   WORD PTR DIROTIM+3,AX

	 MOV   AX,DIRIDAT	   ;GET DATE
	 AND   AX,01E0H		   ;KEEP MONTH ONLY
	 MOV   CL,5		   ;SET FOR SHIFT
	 SHR   AX,CL		   ;PUT INTO AL
	 CALL  BINTODEC		   ;GO CONVERT IT
	 MOV   AX,WORD PTR STRWORK
	 CMP   STRWORK+1,20H	   ;BLANK
	 JNE   FORFM3
	 XCHG  AL,AH		   ;SWAP
FORFM3:	 MOV   WORD PTR DIRODAT,AX
	 MOV   BYTE PTR DIRODAT+2,'/' ;FIX FORMAT
	 MOV   AX,DIRIDAT	   ;GET DATE
	 AND   AX,001FH		   ;KEEP DAY ONLY
	 CALL  BINTODEC		   ;GO CONVERT IT
	 MOV   AX,WORD PTR STRWORK
	 CMP   STRWORK+1,20H	   ;BLANK
	 JNE   FORFM4
	 XCHG  AL,AH		   ;SWAP
	 MOV   AL,'0'		   ;FIX UP
FORFM4:	 MOV   WORD PTR DIRODAT+3,AX
	 MOV   BYTE PTR DIRODAT+5,'/' ;FIX FORMAT
	 MOV   AX,DIRIDAT	   ;GET DATE
	 AND   AX,0FE00H	   ;KEEP YEAR ONLY
	 MOV   CL,9		   ;SET FOR SHIFT
	 SHR   AX,CL		   ;PUT INTO AL
	 ADD   AX,1980		   ;FIND YEAR
	 CALL  BINTODEC		   ;GO CONVERT IT
	 MOV   AX,WORD PTR STRWORK+2
	 MOV   WORD PTR DIRODAT+6,AX
	 MOV   AX,WORD PTR DIRISIZ ;GET FIRST HALF OF SIZE
	 MOV   WORD PTR DIROSIZ,AX ;STORE FIRST HALF OF SIZE
	 MOV   AX,WORD PTR DIRISIZ+2 ;GET SECOND HALF OF SIZE
	 MOV   WORD PTR DIROSIZ+2,AX ;STORE SECOND HALF OF SIZE
	 RET			   ;RETURN TO CALLER

FORMATENT ENDP

;-----------------------------------------------------------------------;
; CLEARERR								;
;	INTERNAL SUBROUTINE FOR THE DOS TOOLS.				;
;	CLEAR ERROR CODE AREA						;
;-----------------------------------------------------------------------;
CLEARERR PROC NEAR
	 MOV   AX,0000H		   ;CLEAR ERROR CODE
	 CALL  SETGLOBERR	   ;GO SET ERRORCODE()
	 RET			   ;RETURN
CLEARERR ENDP

;-----------------------------------------------------------------------;
; SETEXTERR								;
;	INTERNAL SUBROUTINE FOR THE DOS TOOLS.				;
;	GET DOS EXTENDED ERROR CODE AND CALL SETGLOBER.			;
;									;
;	AX = ERROR CODE FROM DOS FUNCTION				;
;-----------------------------------------------------------------------;
SETEXTERR PROC NEAR
	 PUSH  ES		   ;SAVE USED REGISTERS
	 PUSH  DI
	 MOV   BX,0000H		   ;SET FOR DOS
	 MOV   AH,59H		   ;SET GET ERROR
	 INT   21		   ;GET ERROR CODE
	 MOV   ERROROP,AL	   ;SAVE ERROR CODE
	 MOV   AX,ERRORST	   ;LOAD FOR CLARION
	 CALL  SETGLOBERR	   ;GO SET ERRORCODE()
	 POP   DI		   ;RESTORE USED REGISTERS
	 POP   ES
	 RET			   ;RETURN
SETEXTERR ENDP

;-----------------------------------------------------------------------;
; SETGLOBERR								;
;	INTERNAL SUBROUTINE FOR THE DOS L.E.M.				;
;	SET GLOBAL ERROR RETURNED BY ERROR() AND ERRORCODE()		;
;									;
;	AX = ERROR CODE							;
;-----------------------------------------------------------------------;
SETGLOBERR PROC NEAR
	PUSH   ES		   ;SAVE USED REGISTERS
	PUSH   DI
	PUSH   AX		   ;SAVE ERROR CODE
	MOV    ERRORST,AX	   ;SAVE ERROR CODE FOR US
	MOV    AH,0FFH		   ;GET ADDRESS OF GLOBERR
	MOV    AL,29
	CALL   DWORD PTR LIBVEC
	POP    AX		   ;GET ERROR CODE
	MOV    ES:[DI],AX	   ;SET GLOBERR
	POP    DI		   ;RESTORE USED REGISTERS
	POP    ES
	RET			   ;RETURN TO CALLER IN L.E.M.
SETGLOBERR     ENDP		   ;END OF SETGLOBERR

;-----------------------------------------------------------------------;
; SPOOL procedure							;
;-----------------------------------------------------------------------;
	PUBLIC	SPOOL
SPOOL		PROC	FAR

	SUB	AX,AX			;Clear the global error
	CALL	SETGLOBERR

	MOV	AH,30h
	INT	21h			;Get DOS version number

	CMP	AL,3			;Must be 3.00 or greater for PRINT
	JB	ACCESS_DENIED
	MOV	AX,0100h		;Check installed state
	INT	2Fh
	JC	ACCESS_DENIED		;Is PRINT installed?
	CMP	AL,0FFh
	JNE	ACCESS_DENIED
	MOV	CX,SPOOLFILEL		;Get length of filename
	LES	SI,SPOOLFILE		;Get the filename
	MOV	BP,ES			;BP:SI is filename
	CALL	COPYNAME		;Copy DS:SI to FILEIN
	JC	NAME_TOO_LONG		;Error from COPYNAME
	MOV	AX,DS			;Get segment of FILEIN
	MOV	WORD PTR FNPTR+2,AX	;Store segment of FILEIN
	LEA	AX,FILEIN		;Get offset of FILEIN
	MOV	WORD PTR FNPTR,AX	;FNPTR has address of FILEIN
	LEA	DX,PACKET		;DS:DX - pointer to submit packet
	MOV	AX,0101h		;Submit file to PRINT
	INT	2Fh			;Call DOS
	JC	ERROR_FROM_PRINT	;Error from PRINT?
	RET				;No - RETURN to Clarion program
ERROR_FROM_PRINT:
	CMP	AX,8			;Was the error code less than 8?
	JB	SET_GLOBERR		;  Yes, leave error code as is
	CMP	AX,12			;Was the error code greater than 12?
	JA	SET_GLOBERR		;  Yes, leave error code as is
ACCESS_DENIED:
	MOV	AX,5			;If 8,9, or 12 -> 'access denied'
	JMP	SHORT SET_GLOBERR
NAME_TOO_LONG:
	MOV	AX,2			;'file not found' if name too long
	JMP	SHORT SET_GLOBERR
SET_GLOBERR:
	CALL	SETGLOBERR		;Set GLOBERR to AX
	RET				;Return to Clarion program
SPOOL		ENDP			;End of SPOOL

;-----------------------------------------------------------------------;
; COMMAND_LINE() function						;
;-----------------------------------------------------------------------;
COMMAND_LINE		PROC	FAR
	MOV	AH,0FFh			;Get address of _PSP
	MOV	AL,68
	CALL	DWORD PTR LIBVEC
	MOV	ES,ES:[DI]		;Get segment of PSP
	MOV	SI,80h			;Offset of command line length
	SUB	CH,CH
	MOV	CL,BYTE PTR ES:[SI]	;Get the command line length
	INC	SI			;Offset of command line
	MOV	BP,ES			;Copyname expects segment in BP
	CALL	COPYNAME		;Get command line
	JNC	EXIT_COMMAND_LINE	;Check for command line length error
	MOV	FILEIN,0		;Error - return empty string
	SUB	CX,CX			;Clear the string length
EXIT_COMMAND_LINE:
	MOV	AX,TSTRING		;AX = 0, returning a string
	LEA	BX,FILEIN		;Offset of copied command line
					;CX = length of string
	RET
COMMAND_LINE	ENDP

;-----------------------------------------------------------------------;
; ENVIRONMENT() function						;
;-----------------------------------------------------------------------;
ENVIRONMENT		PROC	FAR
	PUSH	DS			;Save data segment
	PUSH	DS			;Make ES = DS
	POP	ES			;
	MOV	CX,ENVVARL		;Get the length of the variable
	CMP	CX,SIZE BUFFER - 1	;Cant be greater than 255
	JA	BAD_SEARCH_LENGTH
	JMP	SHORT SET_UP_SEARCH
BAD_SEARCH_LENGTH:
	JMP	ENVIRONMENT_NOT_FOUND
SET_UP_SEARCH:
	LEA	DI,BUFFER		;Get offset of BUFFER
	LDS	SI,DWORD PTR ENVVAR	;Get the search variable
	CALL	COPYSTRING		;Copy search var to buffer
	ADD	DI,CX			;Length of clipped destination
	DEC	DI			;Point to last byte
	CMP	BYTE PTR ES:[DI],'='	;Ends in an equal sign?
	JE	SEARCH_ENVIRONMENT	;Yes, ready for search
	INC	DI			;No, add a '=' to end
	MOV	BYTE PTR ES:[DI],'='	;Add null at end
	INC	CX			;New compare length
SEARCH_ENVIRONMENT:
	POP	DS			;Reset data segment
	PUSH	DS
	MOV	CS:ENVVARL,CX		;Save the length of the variable
	LEA	SI,BUFFER		;Source is now BUFFER
UPSTRING_LOOP:
	CALL	UPCHAR			;Convert BUFFER to upper case
	INC	SI
	LOOP	UPSTRING_LOOP

	MOV	AH,0FFh			;Get address of _PSP
	MOV	AL,68
	CALL	DWORD PTR LIBVEC
	MOV	ES,ES:[DI]		;Get segment of PSP
	MOV	DI,2Ch			;Offset of environment pointer
	MOV	ES,ES:[DI]		;Get segment of environment
	SUB	DI,DI			;Environment offset = 0
	MOV	DX,DI			;Save offset of environment
	CLD				;Forward
NEXT_ENVIRONMENT:
	CMP	BYTE PTR ES:[DI],0	;First byte a null?
	JZ	ENVIRONMENT_NOT_FOUND	;Yes, done searching
	MOV	CX,CS:ENVVARL		;Get the length of the variable
	LEA	SI,BUFFER		;Restore offset of search variable
	REP	CMPSB			;Is this the variable?
	JZ	ENVIRONMENT_FOUND	;Yes, found it
	MOV	DI,DX			;Restore offset of current entry
	SUB	AL,AL			;Look for next null
	MOV	CX,128			;Max scan length = 128
	REPNZ	SCASB			;Find end of this entry
	JNZ	ENVIRONMENT_NOT_FOUND	;Didn't find the null
	MOV	DX,DI			;Save new offset
	JMP	SHORT NEXT_ENVIRONMENT	;Continue searching
ENVIRONMENT_FOUND:
	POP	DS			;Restore data segment
	MOV	AREAOFF,DI		;Save beginning offset
	SUB	AL,AL			;Look for ending null
	MOV	CX,128			;Max scan length = 128
	REPNZ	SCASB			;Find end of this entry
	JNZ	EXIT_ENVIRONMENT	;Error if couldn't find null
	MOV	CX,DI			;Compute length of contents
	SUB	CX,AREAOFF		;Subtract pos. from start
	DEC	CX			;Subtract out the null
	MOV	ENVLTH,CX		;Save contents length
	MOV	BP,ES			;Segment of contents
	MOV	SI,AREAOFF		;Offset of contents
	CALL	COPYNAME		;Copy contents to FILEIN
	JMP	SHORT EXIT_ENVIRONMENT
ENVIRONMENT_NOT_FOUND:
	POP	DS			;Restore data segment
	MOV	ENVLTH,0		;Length of found contents
	MOV	FILEIN,0		;Assume variable not found
EXIT_ENVIRONMENT:
	MOV	CX,ENVLTH		;CX = contents length
	MOV	AX,TSTRING		;AX = 0, returning a string
	LEA	BX,FILEIN		;Offset of copied command line
	RET
ENVIRONMENT	ENDP

;-----------------------------------------------------------------------;
; UPCHAR								;
;	Internal subroutine for the DOS L.E.M.				;
;	Makes a character upper case if its between 'a' and 'z'		;
;									;
;	DS:SI = address of character					;
;-----------------------------------------------------------------------;
UPCHAR		PROC	NEAR
	MOV	AL,BYTE PTR DS:[SI]
	CMP	AL,'a'
	JB	EXIT_UPCHAR
	CMP	AL,'z'
	JA	EXIT_UPCHAR
	SUB	AL,20h
	MOV	BYTE PTR DS:[SI],AL
EXIT_UPCHAR:
	RET
UPCHAR		ENDP

LOWCHAR		PROC	NEAR
	MOV	AL,BYTE PTR DS:[SI]
	CMP	AL,'A'
	JB	EXIT_LOWCHAR
	CMP	AL,'Z'
	JA	EXIT_LOWCHAR
	ADD	AL,20h
	MOV	BYTE PTR DS:[SI],AL
EXIT_LOWCHAR:
	RET
LOWCHAR		ENDP

;-----------------------------------------------------------------------;
; PROPER								;
;	       MAKE STRING INTO FIRST LETTER OF EACH WORD		;
;-----------------------------------------------------------------------;
PROPER	      PROC   FAR
	PUSH DS			       ;SAVE DS FOR LATER
	PUSH DS
	POP  ES			       ;MAKE ES=DS, WHILE STILL SAVING DS
	MOV  CX,CS:PROPSTRL	       ;MOVE STRING LENGTH INTO CX
	LEA  DI,BUFFER		       ;SET DESTINATION BUFFER dI
	LDS  SI,DWORD PTR PROPSTR      ;SET SOURCE TO CLARION STRING sI
	 CLD			   ;FORWARD
	 REP   MOVSB		   ;MOVE IT
	POP  DS			       ;BRING BACK DS
	PUSH DS
	POP  ES
	LEA  SI,BUFFER		       ;NOW POINT TO BUFFER TO WORK ON
	MOV  CX,CS:PROPSTRL	       ;RESTORE LENGTH
	JCXZ LOW_D
LOWER:	CALL LOWCHAR
	INC  SI			       ;POINT TO NEXT CHAR
	LOOP LOWER		       ;DEC CX AND GO BACK TO BEG OF LOOP

LOW_D:	LEA  DI,BUFFER		       ;NOW POINT TO BUFFER TO WORK ON
	MOV  CX,CS:PROPSTRL	       ;RESTORE LENGTH
	JCXZ DONE_IT
FIND_SPACE:
	MOV  SI,DI
	CALL UPCHAR
	MOV  AL,' '
	PUSH CX
	REPNE SCASB		       ;FIND SPACE, NEEDS ES:DI
	POP  CX
	MOV  SI,DI
	CALL UPCHAR		       ;UPCASE THE FIRST CHAR OF STRING
	LOOP FIND_SPACE
DONE_IT:     SUB AX,AX		       ;MAKE AX=0, MEANING CLARION STRING VAR.
	     MOV BX,OFFSET BUFFER      ;SET BX TO POINT TO NEW STRING
	     MOV CX,CS:PROPSTRL	       ;SET CX TO NEW LENGTH, MAYBE CLIPPED
	RET			       ;DONE, BYE
PROPER		ENDP

;-----------------------------------------------------------------------;
; BROWSE								;
;	       TYPE TEXT FILE TO SCREEN WITH UP,DOWN,LEFT,& RIGHT	;
;-----------------------------------------------------------------------;
INCLUDE BROWSE.ASM

DOSTEND LABEL BYTE

DOSTOOLS ENDS

	END
